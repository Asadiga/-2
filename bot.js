// tab-bot — bot.js
// منطق الردود، منفصل عن واتساب حتى يمكن اختباره بدون اتصال.
// الأوامر:
//   /help                    — عرض المساعدة
//   /project <الاسم> | <وصف> — إضافة مشروع جديد
//   /projects                — عرض المشاريع الحالية
//   /note <نص>               — حفظ ملاحظة
// أي رسالة أخرى: رد ذكاء اصطناعي (عبر askAI) أو رد احتياطي بدون مفتاح.
const { loadMemory, checkAndCountUsage, addProject, listProjects, addNote } = require("./memory");

const DAILY_LIMIT = parseInt(process.env.DAILY_LIMIT || "50", 10);
const BOT_NAME = process.env.BOT_NAME || "مساعد";

// دالة الذكاء الاصطناعي القابلة للتبديل.
// بدون مفتاح API لا تتصل بأي خدمة، وتعيد رداً احتياطياً واضحاً.
// لربط مزود حقيقي: ضع مفتاحك في .env (AI_API_KEY) ثم عدّل هذه الدالة
// لتستدعي واجهة المزود الذي تختاره، مع إبقاء المفتاح في env فقط.
async function askAI(userText, memory) {
  const apiKey = process.env.AI_API_KEY;
  if (!apiKey) {
    return (
      "وصلتني رسالتك: \"" + userText + "\".\n" +
      "الذكاء الاصطناعي غير مفعّل بعد في هذا البوت، لأن مفتاح API غير مضبوط.\n" +
      "أضف AI_API_KEY في ملف .env ثم أعد تشغيل البوت، أو استخدم الأوامر:\n" +
      "/help — المساعدة\n" +
      "/projects — عرض مشاريعك\n" +
      "/project <الاسم> | <وصف> — إضافة مشروع\n" +
      "/note <نص> — حفظ ملاحظة"
    );
  }

  // مثال عام (عدّله حسب مزودك): طلب HTTP إلى AI_API_URL إن وُجد.
  // لا يوجد هنا أي مفتاح حقيقي مضمّن؛ المفتاح يأتي من env فقط.
  const apiUrl = process.env.AI_API_URL;
  const model = process.env.AI_MODEL || "";
  if (!apiUrl) {
    return "مفتاح AI_API_KEY مضبوط، لكن AI_API_URL غير مضبوط. أضف رابط واجهة المزود في .env.";
  }
  try {
    const res = await fetch(apiUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer " + apiKey
      },
      body: JSON.stringify({
        model: model,
        messages: [
          {
            role: "system",
            content:
              "أنت مساعد ذكاء اصطناعي يتحدث العربية. المستخدم اسمه " +
              (memory.user.name || "الصادق") +
              ". مشاريعه الحالية: " +
              (memory.projects.map((p) => p.name).join("، ") || "لا يوجد") +
              "."
          },
          { role: "user", content: userText }
        ]
      })
    });
    const data = await res.json();
    const text =
      data &&
      data.choices &&
      data.choices[0] &&
      data.choices[0].message &&
      data.choices[0].message.content;
    return text || "وصلني رد فارغ من مزود الذكاء الاصطناعي. حاول مرة أخرى.";
  } catch (err) {
    console.error("خطأ في طلب الذكاء الاصطناعي:", err.message);
    return "حدث خطأ أثناء الاتصال بالذكاء الاصطناعي. حاول مرة أخرى لاحقاً.";
  }
}

function helpText() {
  return (
    "أهلاً، أنا " + BOT_NAME + "، مساعدك في واتساب.\n\n" +
    "الأوامر:\n" +
    "/help — عرض هذه المساعدة\n" +
    "/project <الاسم> | <وصف> — إضافة مشروع جديد\n" +
    "مثال: /project فيلدورا | مدينة حياة واقعية في روبلوكس\n" +
    "/projects — عرض مشاريعك الحالية\n" +
    "/note <نص> — حفظ ملاحظة\n" +
    "مثال: /note راجع درس الجامعة غداً\n\n" +
    "أي رسالة أخرى أرد عليها كمساعد ذكاء اصطناعي.\n" +
    "الحد اليومي للرسائل: " + DAILY_LIMIT + " رسالة (قابل للتعديل من DAILY_LIMIT في .env)."
  );
}

// handleMessage: تأخذ نص الرسالة وتعيد الرد بالعربية.
// لا تتصل بواتساب من هنا؛ index.js هو من يرسل الرد.
async function handleMessage(text, senderName) {
  const memory = loadMemory();
  const clean = (text || "").trim();
  if (!clean) return "أرسل لي رسالة أو استخدم /help لعرض الأوامر.";

  // حد الاستخدام اليومي أولاً (مثل مشكلة Tab السابقة مع الحد اليومي).
  if (!checkAndCountUsage(memory, DAILY_LIMIT)) {
    return (
      "وصلت اليوم إلى الحد اليومي للاستخدام (" + DAILY_LIMIT + " رسالة).\n" +
      "سأكون متاحاً مرة أخرى غداً، أو يمكنك رفع الحد من DAILY_LIMIT في ملف .env ثم إعادة تشغيل البوت."
    );
  }

  if (clean === "/help" || clean === "مساعدة" || clean === "المساعدة") {
    return helpText();
  }

  if (clean.startsWith("/project ")) {
    const rest = clean.slice("/project ".length).trim();
    const parts = rest.split("|");
    const name = (parts[0] || "").trim();
    const description = (parts[1] || "").trim();
    if (!name) return "اكتب اسم المشروع بعد /project، مثال: /project فيلدورا | مدينة حياة واقعية";
    const project = addProject(memory, name, description);
    return "تم حفظ المشروع: " + project.name + (description ? " — " + description : "") + "\nعدد مشاريعك الآن: " + memory.projects.length;
  }

  if (clean === "/projects") {
    const projects = listProjects(memory);
    if (!projects.length) return "لا توجد مشاريع محفوظة بعد. أضف مشروعاً بالأمر: /project <الاسم> | <وصف>";
    return (
      "مشاريعك (" + projects.length + "):\n" +
      projects.map((p, i) => (i + 1) + ". " + p.name + (p.description ? " — " + p.description : "") + " (" + p.status + ")").join("\n")
    );
  }

  if (clean.startsWith("/note ")) {
    const noteText = clean.slice("/note ".length).trim();
    if (!noteText) return "اكتب نص الملاحظة بعد /note.";
    addNote(memory, noteText);
    return "تم حفظ الملاحظة: " + noteText;
  }

  if (clean.startsWith("/")) {
    return "أمر غير معروف. استخدم /help لعرض الأوامر المتاحة.";
  }

  // رسالة عادية: رد ذكاء اصطناعي (أو رد احتياطي إن لم يكن المفتاح مضبوطاً).
  return await askAI(clean, memory);
}

module.exports = { handleMessage, helpText, askAI, DAILY_LIMIT };
