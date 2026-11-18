// tab-bot — bot.js
// منطق الردود، منفصل عن واتساب حتى يمكن اختباره بدون اتصال.
// الأوامر:
//   /help                    — عرض المساعدة
//   /project <الاسم> | <وصف> — إضافة مشروع جديد
//   /projects                — عرض المشاريع الحالية
//   /note <نص>               — حفظ ملاحظة
// أي رسالة أخرى: رد ذكاء اصطناعي (عبر askAI) أو رد احتياطي بدون مفتاح.
const { loadMemory, checkAndCountUsage, addProject, listProjects, addNote, addAppointment, listAppointments } = require("./memory");
const { browsePage } = require("./browser");

const DAILY_LIMIT = parseInt(process.env.DAILY_LIMIT || "0", 10); // 0 = بلا حد يومي
const BOT_NAME = process.env.BOT_NAME || "أثير";

// دالة الذكاء الاصطناعي القابلة للتبديل.
// بدون مفتاح API لا تتصل بأي خدمة، وتعيد رداً احتياطياً واضحاً.
// لربط مزود حقيقي: ضع مفتاحك في .env (AI_API_KEY) ثم عدّل هذه الدالة
// لتستدعي واجهة المزود الذي تختاره، مع إبقاء المفتاح في env فقط.
async function askAI(userText, memory) {
  const apiKey = process.env.AI_API_KEY;
  const apiUrl = process.env.AI_API_URL;
  const model = process.env.AI_MODEL || "";

  // 1) مزود المستخدم أولاً إن كان مضبوطاً (مفتاح + رابط).
  if (apiKey && apiUrl) {
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
                "أنت أثير، المساعد الشخصي الخاص بالصادق. تحدث العربية بأسلوب ودود وشخصي مثل مساعد يعرفه جيداً. أجب عن أي سؤال أو موضوع دون قيود على المواضيع. المستخدم اسمه " +
                (memory.user.name || "الصادق") +
                ". مشاريعه الحالية: " +
                (memory.projects.map((p) => p.name).join("، ") || "لا يوجد") +
                ". هو طالب تقنية معلومات، ويعمل على مشروع فيلدورا، مدينة حياة واقعية في روبلوكس."
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
      if (text) return text;
    } catch (err) {
      console.error("خطأ في طلب الذكاء الاصطناعي:", err.message);
    }
  }

  // 2) بلا مفتاح: ذكاء اصطناعي مجاني مفتوح (Pollinations) حتى يرد البوت على أي شيء.
  // الخدمة المجانية تحد نفسها إلى رد كل 45 ثانية تقريباً لكل IP، فنعيد المحاولة
  // مرة بعد الانتظار المطلوب بدلاً من رفض الرسالة.
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      const prompt =
        "أنت أثير، المساعد الشخصي الخاص بالصادق. تحدث العربية بأسلوب ودود وشخصي مثل مساعد يعرفه جيداً. أجب عن أي سؤال أو موضوع دون قيود على المواضيع. المستخدم اسمه " +
        (memory.user.name || "الصادق") +
        ". مشاريعه الحالية: " +
        (memory.projects.map((p) => p.name).join("، ") || "لا يوجد") +
        ". هو طالب تقنية معلومات، ويعمل على مشروع فيلدورا، مدينة حياة واقعية في روبلوكس. سؤال المستخدم: " +
        userText;
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), 30000);
      const res = await fetch(
        "https://text.pollinations.ai/" + encodeURIComponent(prompt) + "?model=openai",
        { signal: controller.signal }
      );
      clearTimeout(timer);
      const text = (await res.text()).trim();
      if (!text) continue;
      // الخدمة قد تعيد خطأ JSON بدل نص (مثل 503 عند الضغط) — لا نرسله للمستخدم.
      if (!res.ok || /"success":\s*false|SERVICE_UNAVAILABLE/i.test(text)) {
        console.error("الخدمة المجانية مشغولة الآن:", text.slice(0, 200));
        if (attempt === 0) {
          await new Promise((r) => setTimeout(r, 12000));
          continue;
        }
        break;
      }
      const waitMatch = text.match(/wait (\d+) seconds/i);
      if (waitMatch && attempt === 0) {
        const waitMs = (parseInt(waitMatch[1], 10) + 2) * 1000;
        console.log("الخدمة المجانية طلبت الانتظار " + waitMs + "ms، سأعيد المحاولة.");
        await new Promise((r) => setTimeout(r, waitMs));
        continue;
      }
      if (waitMatch) return localFallback(userText, memory);
      return text;
    } catch (err) {
      console.error("خطأ في الذكاء الاصطناعي المجاني:", err.message);
    }
  }

  // 3) احتياطي محلي بسيط إن تعذر الاتصال: رد على التحيات والحساب والوقت،
  // ولا نرفض أي رسالة.
  return localFallback(userText, memory);
}

function localFallback(userText, memory) {
  const t = (userText || "").trim();
  const lower = t.toLowerCase();
  if (/^(سلام|مرحبا|مرحباً|هلا|اهلا|أهلا|صباح|مساء|hi|hello|hey)\b/.test(lower)) {
    return "أهلاً " + (memory.user.name || "بك") + "! كيف أقدر أساعدك اليوم؟ اسألني عن أي شيء، أو استخدم /help لعرض الأوامر.";
  }
  if (/من أنت|من انت|who are you/.test(lower)) {
    return "أنا " + BOT_NAME + "، مساعدك الشخصي في واتساب. أعرفك يا صادق، وأتذكر مشاريعك وملاحظاتك، وأرد على أي سؤال أو موضوع. اسألني عن أي شيء.";
  }
  const math = t.match(/^\s*(-?[\d.]+)\s*([+\-*/×÷])\s*(-?[\d.]+)\s*$/);
  if (math) {
    const a = parseFloat(math[1]);
    const b = parseFloat(math[3]);
    const op = math[2];
    let r = null;
    if (op === "+" || op === "-") r = op === "+" ? a + b : a - b;
    if (op === "*" || op === "×") r = a * b;
    if ((op === "/" || op === "÷") && b !== 0) r = a / b;
    if (r !== null) return t + " = " + r;
  }
  if (/الساعة|الوقت|التاريخ|اليوم/.test(t)) {
    return "الآن: " + new Date().toLocaleString("ar", { timeZone: "Africa/Khartoum" }) + ".";
  }
  if (/مشاريع/.test(t)) {
    const projects = listProjects(memory);
    if (!projects.length) return "لا توجد مشاريع محفوظة بعد. أضف مشروعاً بالأمر: /project <الاسم> | <وصف>";
    return "مشاريعك (" + projects.length + "):\n" + projects.map((p, i) => (i + 1) + ". " + p.name).join("\n");
  }
  return (
    "وصلتني رسالتك: \"" + t + "\".\n" +
    "تعذر الاتصال بالذكاء الاصطناعي الآن، لكنني سأرد عليك فور عودة الاتصال. جرب مرة أخرى بعد قليل، أو استخدم الأوامر:\n" +
    "/help — المساعدة\n" +
    "/projects — عرض مشاريعك\n" +
    "/project <الاسم> | <وصف> — إضافة مشروع\n" +
    "/note <نص> — حفظ ملاحظة"
  );
}

function helpText() {
  return (
    "أهلاً، أنا " + BOT_NAME + "، مساعدك الشخصي في واتساب.\n\n" +
    "الأوامر:\n" +
    "/help — عرض هذه المساعدة\n" +
    "/project <الاسم> | <وصف> — إضافة مشروع جديد\n" +
    "مثال: /project فيلدورا | مدينة حياة واقعية في روبلوكس\n" +
    "/projects — عرض مشاريعك الحالية\n" +
    "/note <نص> — حفظ ملاحظة\n" +
    "مثال: /note راجع درس الجامعة غداً\n" +
    "/appointment <التاريخ> <الوقت> | <الموعد> — حجز موعد\n" +
    "مثال: /appointment 2026-11-20 10:00 | موعد طبيب\n" +
    "/appointments — عرض مواعيدك\n" +
    "/browse <رابط> — فتح موقع في متصفح أثير الخاص\n" +
    "مثال: /browse https://example.com\n\n" +
    "أي رسالة أخرى أرد عليها كمساعد ذكاء اصطناعي.\n" +
    (DAILY_LIMIT > 0
      ? "الحد اليومي للرسائل: " + DAILY_LIMIT + " رسالة (قابل للتعديل من DAILY_LIMIT في .env)."
      : "لا يوجد حد يومي للرسائل.")
  );
}

// handleMessage: تأخذ نص الرسالة وتعيد الرد بالعربية.
// لا تتصل بواتساب من هنا؛ index.js هو من يرسل الرد.
async function handleMessage(text, senderName) {
  const memory = loadMemory();
  const clean = (text || "").trim();
  if (!clean) return "أرسل لي رسالة أو استخدم /help لعرض الأوامر.";

  // بلا حد يومي افتراضياً: إن كان DAILY_LIMIT أكبر من 0 فقط يُطبَّق الحد.
  if (DAILY_LIMIT > 0 && !checkAndCountUsage(memory, DAILY_LIMIT)) {
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

  if (clean.startsWith("/appointment ")) {
    const rest = clean.slice("/appointment ".length).trim();
    const parts = rest.split("|");
    const when = (parts[0] || "").trim().split(/\s+/);
    const date = when[0] || "";
    const time = when[1] || "";
    const title = (parts[1] || "").trim() || "موعد";
    if (!date) return "اكتب التاريخ والوقت، مثال: /appointment 2026-11-20 10:00 | موعد طبيب";
    const appt = addAppointment(memory, date, time, title);
    return "تم حجز موعدك: " + appt.title + " — " + appt.date + (appt.time ? " " + appt.time : "") + "\nعدد مواعيدك الآن: " + memory.appointments.length;
  }

  if (clean === "/appointments" || clean === "/مواعيد" || clean === "مواعيدي") {
    const appts = listAppointments(memory);
    if (!appts.length) return "لا توجد مواعيد محفوظة بعد. احجز موعداً بالأمر: /appointment <التاريخ> <الوقت> | <الموعد>";
    return (
      "مواعيدك (" + appts.length + "):\n" +
      appts.map((a, i) => (i + 1) + ". " + a.title + " — " + a.date + (a.time ? " " + a.time : "") + " (" + a.status + ")").join("\n")
    );
  }

  if (/^احجز موعد/.test(clean)) {
    return "لحجز موعد أرسل: /appointment <التاريخ> <الوقت> | <الموعد>\nمثال: /appointment 2026-11-20 10:00 | موعد طبيب";
  }

  if (clean.startsWith("/browse ")) {
    const url = clean.slice("/browse ".length).trim();
    const result = await browsePage(url);
    if (!result.ok) return result.text;
    return "فتحت الصفحة في متصفحي: " + (result.title || result.url) + "\n" + result.url + "\n\n" + result.text;
  }

  if (clean.startsWith("/")) {
    return "أمر غير معروف. استخدم /help لعرض الأوامر المتاحة.";
  }

  // أسئلة سريعة يرد عليها محلياً فوراً، دون انتظار الذكاء الاصطناعي البطيء.
  if (/^(سلام|مرحبا|مرحباً|هلا|اهلا|أهلا|صباح|مساء|hi|hello|hey)\b/i.test(clean) || /من أنت|من انت|who are you/i.test(clean) || /^\s*-?[\d.]+\s*[+\-*/×÷]\s*-?[\d.]+\s*$/.test(clean) || /الساعة|الوقت|التاريخ/.test(clean)) {
    return localFallback(clean, memory);
  }

  // رسالة عادية: رد ذكاء اصطناعي (أو رد احتياطي إن لم يكن المفتاح مضبوطاً).
  return await askAI(clean, memory);
}

module.exports = { handleMessage, helpText, askAI, DAILY_LIMIT };
