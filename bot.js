// tab-bot — bot.js
// منطق الردود، منفصل عن واتساب حتى يمكن اختباره بدون اتصال.
// يعمل باللغة الطبيعية مباشرة مثل Tab: اكتب ما تريده بالعربية
// (افتح موقع، احفظ مشروع، سجل موعد...) فينفذه فوراً بلا أوامر.
// الأوامر القديمة (/help, /project, /projects, /note, /appointment,
// /appointments, /browse) ما زالت تعمل كبدائل للتوافق، لكنها ليست مطلوبة أبداً
// ولا تُذكر للمستخدم.
// أي رسالة أخرى: رد ذكاء اصطناعي (عبر askAI) أو رد احتياطي بدون مفتاح.
const { loadMemory, checkAndCountUsage, addProject, listProjects, addNote, addAppointment, listAppointments } = require("./memory");
const { browsePage } = require("./browser");
const tools = require("./tools");

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
  if (/^(سلام|مرحبا|مرحباً|هلا|اهلا|أهلا|صباح|مساء)(\s|$)/.test(lower) || /^(hi|hello|hey)\b/i.test(lower)) {
    return "أهلاً " + (memory.user.name || "بك") + "! كيف أقدر أساعدك اليوم؟ اكتب لي مباشرة ما تريده، مثلاً: افتح موقع، أو احفظ مشروع، أو سجل موعد.";
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
    return listProjectsReply(memory);
  }
  return (
    "وصلتني رسالتك: \"" + t + "\".\n" +
    "تعذر الاتصال بالذكاء الاصطناعي الآن، لكنني سأرد عليك فور عودة الاتصال. جرب مرة أخرى بعد قليل، أو اكتب لي مباشرة ما تريده: افتح موقع، احفظ مشروع، سجل ملاحظة، أو سجل موعد."
  );
}

function listProjectsReply(memory) {
  const projects = listProjects(memory);
  if (!projects.length) return "لا توجد مشاريع محفوظة بعد. اكتب لي مثلاً: احفظ مشروع فيلدورا | مدينة حياة واقعية";
  return (
    "مشاريعك (" + projects.length + "):\n" +
    projects.map((p, i) => (i + 1) + ". " + p.name + (p.description ? " — " + p.description : "") + " (" + p.status + ")").join("\n")
  );
}

function listAppointmentsReply(memory) {
  const appts = listAppointments(memory);
  if (!appts.length) return "لا توجد مواعيد محفوظة بعد. اكتب لي مثلاً: سجل موعد 2026-11-20 10:00 | موعد طبيب";
  return (
    "مواعيدك (" + appts.length + "):\n" +
    appts.map((a, i) => (i + 1) + ". " + a.title + " — " + a.date + (a.time ? " " + a.time : "") + " (" + a.status + ")").join("\n")
  );
}

// استخراج رابط أو نطاق من نص طبيعي، مثل "افتح موقع east-sources.com".
function extractUrlOrDomain(text) {
  const m = text.match(/(https?:\/\/[^\s\u0600-\u06FF]+|www\.[^\s\u0600-\u06FF]+|[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+(\/[^\s\u0600-\u06FF]*)?)/);
  return m ? m[1] : null;
}

// تحليل موعد من لغة طبيعية: "سجل موعد 2026-11-20 10:00 | موعد طبيب"
// أو "احجز موعد طبيب يوم 2026-11-20 الساعة 10:00".
function parseAppointmentNatural(text) {
  const dateMatch = text.match(/(\d{4}-\d{2}-\d{2})/);
  const timeMatch = text.match(/(\d{1,2}:\d{2})/);
  if (!dateMatch) return null;
  const date = dateMatch[1];
  const time = timeMatch ? timeMatch[1] : "";
  // العنوان: ما بعد | إن وجد، وإلا ما تبقى بعد حذف التاريخ والوقت وكلمات الأمر.
  let title = "";
  const pipeParts = text.split("|");
  if (pipeParts.length > 1) {
    title = pipeParts.slice(1).join("|").trim();
  } else {
    title = text
      .replace(/^(احجز|سجل|احفظ|سجّل)\s*(موعد|ميعاد)?\s*/i, "")
      .replace(date, "")
      .replace(time, "")
      .replace(/يوم|الساعة|في/g, "")
      .replace(/\s+/g, " ")
      .trim();
  }
  return { date, time, title: title || "موعد" };
}

async function browseReply(target) {
  const result = await browsePage(target);
  if (!result.ok) return result.text;
  return "فتحت الصفحة في متصفحي: " + (result.title || result.url) + "\n" + result.url + "\n\n" + result.text;
}

function helpText() {
  return (
    "أهلاً، أنا " + BOT_NAME + "، مساعدك الشخصي في واتساب.\n\n" +
    "اكتب لي مباشرة ما تريده، بدون أوامر، مثلاً:\n" +
    "• افتح موقع east-sources.com — أفتح لك أي موقع في متصفحي الخاص وألخصه لك\n" +
    "• ابحث عن أفضل شركات الاستيراد — أبحث لك في الإنترنت\n" +
    "• احفظ مشروع فيلدورا | مدينة حياة واقعية — أحفظ مشروعك\n" +
    "• مشاريعي — أعرض لك مشاريعك المحفوظة\n" +
    "• احفظ ملاحظة راجع درس الجامعة غداً — أحفظ ملاحظتك\n" +
    "• سجل موعد 2026-11-20 10:00 | موعد طبيب — أسجل موعدك\n" +
    "• مواعيدي — أعرض لك مواعيدك\n" +
    "• سجل دخول بحسابي في يوتيوب — أسجل دخول بأي حساب تعطيني إياه (يوتيوب، انستقرام، تيك توك...)\n" +
    "• نزل فيديو في حسابي على يوتيوب — أنشر بعد موافقتك\n" +
    "• صمم صورة مدينة مستقبلية — أصمم لك صورة فوراً وأرسلها لك\n" +
    "• اعمل فيديو عن فيلدورا — توليد الفيديو يحتاج مفتاحاً مدفوعاً، وسأشرح لك البديل\n" +
    "• الطقس في الخرطوم — أخبرك بالطقس الآن\n" +
    "• حول 100 دولار إلى جنيه سوداني — أحوّل لك العملات\n" +
    "• أوقات الصلاة في الخرطوم — أخبرك بمواقيت الصلاة\n" +
    "• سورة الفاتحة — أعرض لك السورة\n" +
    "• ترجم صباح الخير إلى الإنجليزية — أترجم لك\n" +
    "• اعمل QR لرابط example.com — أنشئ لك رمز QR\n" +
    "• أخبار اليوم — أعرض لك أهم العناوين\n" +
    "• ما معنى كلمة اجتهاد — أشرح لك معناها\n\n" +
    "وأي سؤال أو موضوع آخر، اسألني عنه مباشرة وسأرد عليك.\n" +
    "تنبيه: لا ترسل كلمة المرور هنا في المحادثة أبداً؛ الحساب يُربط بطريقة آمنة، ولا أنشر شيئاً إلا بعد موافقتك.\n" +
    (DAILY_LIMIT > 0
      ? "الحد اليومي للرسائل: " + DAILY_LIMIT + " رسالة (قابل للتعديل من DAILY_LIMIT في .env)."
      : "لا يوجد حد يومي للرسائل.")
  );
}

// handleMessage: تأخذ نص الرسالة وتعيد الرد بالعربية.
// لا تتصل بواتساب من هنا؛ index.js هو من يرسل الرد.
// ===== تصميم الصور والفيديو =====
// الصور: مجانية عبر Pollinations Image API، بلا مفتاح. نبني رابط الصورة
// ونعيده كوسائط (mediaUrl) فيرسله index.js كصورة واتساب.
// الفيديو: لا يوجد توليد فيديو مجاني موثوق في هذا البوت، فلا ندعي ذلك.
// نرد بصدق: توليد الفيديو يحتاج مفتاح API مدفوعاً، ونعرض بديل تصميم الصور.
// أدوات الفيديو البسيطة (قص/تحويل فيديو يرسله المستخدم) تعتمد على ffmpeg
// إن كان مثبتاً على جهاز البوت، ونتحقق منه وقت الطلب فقط.
function ffmpegAvailable() {
  try {
    require("child_process").execSync("command -v ffmpeg", { stdio: "ignore" });
    return true;
  } catch (e) {
    return false;
  }
}

// يعيد { text, mediaUrl } عند طلب تصميم صورة، أو null إن لم يكن الطلب صورة.
function imageDesignReply(clean) {
  let prompt = null;
  let m = clean.match(/^(صمم|صمّم|ارسم|اعمل|أنشئ|انشئ|سوّي|سوي|اصنع)\s+(لي\s+)?(صورة|صور|رسم|لوحة|تصميم)\s*(عن|لـ|ل|من)?\s*(.+)$/);
  if (m && m[5]) prompt = m[5].trim();
  if (!prompt) {
    m = clean.match(/^(ارسم|صمم|صمّم)\s+(.+)$/);
    if (m && m[2] && !/فيديو|مقطع/.test(m[2])) prompt = m[2].trim();
  }
  if (!prompt) return null;
  const url =
    "https://image.pollinations.ai/prompt/" +
    encodeURIComponent(prompt) +
    "?width=1024&height=1024&nologo=true";
  return {
    text: "صممت لك هذه الصورة: " + prompt + "\nإن أردت تعديلاً اكتب لي وصفاً جديداً، مثلاً: صمم صورة " + prompt + " بألوان مختلفة.",
    mediaUrl: url
  };
}

// يعيد رداً نصياً صادقاً عند طلب فيديو، أو null إن لم يكن الطلب فيديو.
function videoReply(clean) {
  const wantsVideo =
    /(اعمل|صمم|أنشئ|انشئ|سوّي|سوي|اصنع|أنشئ لي|اعمل لي)\s+(لي\s+)?(فيديو|مقطع فيديو|فلم|فيلم)/.test(clean) ||
    /^(فيديو|مقطع فيديو)\s+(عن|لـ|ل)\s+/.test(clean);
  if (!wantsVideo) return null;
  let reply =
    "أتمنى أقدر، لكن توليد الفيديو من نص غير متوفر مجاناً في أثير حالياً، ولا يوجد بديل مجاني موثوق.\n\n" +
    "لتصميم فيديو أحتاج مفتاح API مدفوعاً لخدمة توليد فيديو. إن وفّرت لي مفتاحاً سأربطه وأصمم لك الفيديو.\n\n" +
    "بديل مجاني الآن: أستطيع تصميم صورة لك فوراً، اكتب مثلاً: صمم صورة مدينة مستقبلية.";
  if (ffmpegAvailable()) {
    reply += "\n\nوإن أرسلت لي فيديو جاهزاً، أستطيع مساعدتك بأدوات بسيطة عليه (مثل القص والتحويل) لأن أداة ffmpeg مثبتة على جهازي.";
  } else {
    reply += "\n\nحتى أدوات الفيديو البسيطة (قص أو تحويل فيديو ترسله لي) غير مثبتة على هذا الجهاز بعد.";
  }
  return reply;
}

async function handleMessage(text, senderName) {
  const memory = loadMemory();
  const clean = (text || "").trim();
  if (!clean) return "اكتب لي مباشرة ما تريده، مثلاً: افتح موقع، أو احفظ مشروع، أو سجل موعد.";

  // بلا حد يومي افتراضياً: إن كان DAILY_LIMIT أكبر من 0 فقط يُطبَّق الحد.
  if (DAILY_LIMIT > 0 && !checkAndCountUsage(memory, DAILY_LIMIT)) {
    return (
      "وصلت اليوم إلى الحد اليومي للاستخدام (" + DAILY_LIMIT + " رسالة).\n" +
      "سأكون متاحاً مرة أخرى غداً، أو يمكنك رفع الحد من DAILY_LIMIT في ملف .env ثم إعادة تشغيل البوت."
    );
  }

  // ===== اللغة الطبيعية أولاً: اكتب ما تريده مباشرة، بلا أوامر =====

  // مساعدة باللغة الطبيعية أيضاً
  if (clean === "مساعدة" || clean === "المساعدة" || clean === "ماذا تستطيع أن تفعل" || clean === "ماذا تستطيع ان تفعل" || clean === "وش تقدر تسوي") {
    return helpText();
  }

  // مواعيدي باللغة الطبيعية
  if (/^(مواعيدي|اعرض مواعيدي|أعرض مواعيدي|وش مواعيدي|ما هي مواعيدي|عرض المواعيد|المواعيد)$/.test(clean)) {
    return listAppointmentsReply(memory);
  }

  // مشاريعي باللغة الطبيعية
  if (/^(مشاريعي|اعرض مشاريعي|أعرض مشاريعي|وش مشاريعي|ما هي مشاريعي|عرض المشاريع|مشاريع)$/.test(clean)) {
    return listProjectsReply(memory);
  }

  // تسجيل موعد باللغة الطبيعية: "سجل موعد 2026-11-20 10:00 | موعد طبيب"
  if (/^(احجز|سجل|احفظ|سجّل)\s+(موعد|ميعاد)(?:\s|$)/.test(clean)) {
    const parsed = parseAppointmentNatural(clean);
    if (!parsed) return "لحجز موعد اكتب لي مثلاً: سجل موعد 2026-11-20 10:00 | موعد طبيب";
    const appt = addAppointment(memory, parsed.date, parsed.time, parsed.title);
    return "تم حجز موعدك: " + appt.title + " — " + appt.date + (appt.time ? " " + appt.time : "") + "\nعدد مواعيدك الآن: " + memory.appointments.length;
  }

  // حفظ مشروع باللغة الطبيعية: "احفظ مشروع فيلدورا | مدينة حياة واقعية"
  {
    const m = clean.match(/^(احفظ|سجل|ضيف|أضف|اضف|سجّل)\s+(مشروع|مشاريع)\s+(.+)$/);
    if (m) {
      const parts = m[3].split("|");
      const name = (parts[0] || "").trim();
      const description = (parts[1] || "").trim();
      if (!name) return "اكتب اسم المشروع، مثال: احفظ مشروع فيلدورا | مدينة حياة واقعية";
      const project = addProject(memory, name, description);
      return "تم حفظ المشروع: " + project.name + (description ? " — " + description : "") + "\nعدد مشاريعك الآن: " + memory.projects.length;
    }
    const m2 = clean.match(/^مشروع جديد\s+(.+)$/);
    if (m2) {
      const parts = m2[1].split("|");
      const name = (parts[0] || "").trim();
      const description = (parts[1] || "").trim();
      if (!name) return "اكتب اسم المشروع، مثال: احفظ مشروع فيلدورا | مدينة حياة واقعية";
      const project = addProject(memory, name, description);
      return "تم حفظ المشروع: " + project.name + (description ? " — " + description : "") + "\nعدد مشاريعك الآن: " + memory.projects.length;
    }
  }

  // حفظ ملاحظة باللغة الطبيعية: "احفظ ملاحظة راجع درس الجامعة غداً"
  {
    const m = clean.match(/^(احفظ|سجل|اكتب|سجّل)\s+(ملاحظة|ملاحظه|ملحوظة)\s+(.+)$/);
    if (m) {
      addNote(memory, m[3].trim());
      return "تم حفظ الملاحظة: " + m[3].trim();
    }
  }

  // بحث في الإنترنت باللغة الطبيعية: "ابحث عن ..."
  {
    const m = clean.match(/^(ابحث|ابحث لي|دور|دور لي|دور على)\s+(عن\s+)?(.+)$/);
    if (m && m[3]) {
      const q = m[3].trim();
      return await browseReply("https://html.duckduckgo.com/html/?q=" + encodeURIComponent(q));
    }
  }

  // فتح موقع باللغة الطبيعية: "افتح موقع east-sources.com" / "ادخل على ..."
  if (/^(افتح|ادخل|شوف|شاهد|تصفح|روح|زر)(\s|$)/.test(clean)) {
    const target = extractUrlOrDomain(clean);
    if (!target) return "اكتب رابط الموقع أو اسمه، مثال: افتح موقع east-sources.com";
    return await browseReply(target);
  }

  // رابط مباشر بلا أي كلمة: "https://example.com" أو "east-sources.com"
  {
    const target = extractUrlOrDomain(clean);
    if (target && (clean === target || clean.replace(/^https?:\/\//, "") === target.replace(/^https?:\/\//, ""))) {
      return await browseReply(target);
    }
  }

// تسجيل الدخول بأي حساب يعطيه الصادق والتصرف فيه بعد موافقته.
// لا نطلب كلمة مرور في المحادثة أبداً، ولا نسجل دخولاً فعلياً هنا:
// الرد يوضح الخطوات، ويطلب المنصة والبريد/اسم المستخدم فقط،
// ويؤكد أن أي نشر يتم بعد عرض العنوان والوجهة للموافقة.
const ACCOUNT_PLATFORMS = [
  "يوتيوب", "يوتوب", "youtube",
  "انستقرام", "إنستقرام", "انستغرام", "instagram",
  "تيك توك", "تيكتوك", "tiktok",
  "فيسبوك", "فيس بوك", "facebook",
  "تويتر", "إكس",
  "تيليجرام", "تليجرام", "telegram",
  "جوجل", "جيميل", "google", "gmail",
  "روبلوكس", "roblox",
  "واتساب", "whatsapp"
];

function findPlatform(text) {
  const lower = text.toLowerCase();
  return ACCOUNT_PLATFORMS.find((p) => lower.includes(p.toLowerCase())) || null;
}

function findEmail(text) {
  const m = text.match(/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/);
  return m ? m[0] : null;
}

function accountIntentReply(clean) {
  const isLogin =
    /(سجل|سجّل|تسجيل)\s*(دخول|الدخول|دخولي)/.test(clean) ||
    /ادخل (في |إلى |الى |على )?حسابي/.test(clean) ||
    /افتح حسابي/.test(clean) ||
    /سجل دخولي/.test(clean);
  const isUpload =
    /(نزل|انشر|ارفع|حمّل|حمل|انشر لي|نزل لي|ارفع لي)/.test(clean) &&
    /(فيديو|منشور|صورة|مقطع|ريلز|ستوري)/.test(clean) &&
    /(حسابي|يوتيوب|انستقرام|إنستقرام|تيك توك|تيكتوك|فيسبوك|تويتر)/.test(clean);
  if (!isLogin && !isUpload) return null;

  const platform = findPlatform(clean);
  const email = findEmail(clean);
  const action = isUpload ? "أنشر" : "أسجل دخول";

  let reply =
    "تمام، أقدر " + action + " بحسابك وأتصرف فيه بعد موافقتك.\n\n" +
    "⚠️ لا ترسل كلمة المرور هنا في المحادثة أبداً. الحساب يُربط بطريقة آمنة، وليس برسالة واتساب.\n\n";
  if (platform) reply += "المنصة: " + platform + "\n";
  else reply += "أخبرني أولاً: ما هي المنصة؟ (يوتيوب، انستقرام، تيك توك، أو أي منصة أخرى)\n";
  if (email) reply += "البريد: " + email + "\n";
  else reply += "أخبرني: ما هو البريد أو اسم المستخدم للحساب؟\n";
  if (isUpload) {
    reply +=
      "\nبعدها سأفتح متصفحي الخاص لصفحة تسجيل الدخول، وأستخدم الجلسة المحفوظة إن كانت موجودة، " +
      "وقبل النشر سأعرض لك العنوان والمكان الذي سأنشر فيه، ولن أنشر شيئاً إلا بعد موافقتك.";
  } else {
    reply +=
      "\nبعدها سأفتح متصفحي الخاص لصفحة تسجيل الدخول، وأستخدم الجلسة المحفوظة إن كانت موجودة، " +
      "وبعد الاتصال بالحساب سأخبرك، ولن أنشر أو أتصرف في الحساب إلا بعد موافقتك.";
  }
  return reply;
}

  // تسجيل دخول بحساب / نشر في حساب: رد يطلب المنصة والبريد فقط، بلا كلمة مرور.
  const accountReply = accountIntentReply(clean);
  if (accountReply) return accountReply;

  // تصميم صورة: يعيد وسائط (صورة) يرسلها index.js كصورة واتساب.
  const imageReply = imageDesignReply(clean);
  if (imageReply) return imageReply;

  // طلب فيديو: رد صادق — لا توليد فيديو مجاني، مع بديل تصميم الصور.
  const videoText = videoReply(clean);
  if (videoText) return videoText;

  // ===== أدوات مجانية (بلا مفاتيح) =====
  try {
    // الطقس: "الطقس في الخرطوم"
    {
      const m = clean.match(/^(الطقس|طقس)\s*(في\s+)?(.+)$/);
      if (m && m[3]) {
        const r = await tools.getWeather(m[3].trim());
        return r.text;
      }
    }
    // العملات: "حول 100 دولار إلى جنيه سوداني"
    {
      const m = clean.match(/^(حوّل|حول|كم يساوي|كم سعر)\s+(\d+(?:\.\d+)?)\s+(.+)$/);
      if (m) {
        const parts = m[3].split(/\s+(إلى|الى)\s+/);
        if (parts.length >= 3) {
          const r = await tools.convertCurrency(parseFloat(m[2]), parts[0].trim(), parts[2].trim());
          return r.text;
        }
      }
    }
    // أوقات الصلاة: "أوقات الصلاة في الخرطوم" (الخرطوم افتراضياً)
    if (/(أوقات|مواقيت)\s*(الصلاة|صلاة)/.test(clean)) {
      const m = clean.match(/في\s+(.+)$/);
      const r = await tools.getPrayerTimes(m ? m[1].trim() : "الخرطوم");
      return r.text;
    }
    // القرآن: "سورة الفاتحة" أو "سورة 36"
    {
      const m = clean.match(/^سورة\s+(.+)$/);
      if (m) {
        const r = await tools.getSurah(m[1].trim());
        return r.text;
      }
    }
    // الترجمة: "ترجم صباح الخير إلى الإنجليزية"
    {
      const m = clean.match(/^ترجم\s+(.+?)\s+(إلى|الى)\s+(الإنجليزية|الانجليزية|العربية|الفرنسية|الإسبانية|الاسبانية)\s*$/);
      if (m) {
        const target = /العربية/.test(m[3]) ? "ar" : /الفرنسية/.test(m[3]) ? "fr" : "en";
        const r = await tools.translateText(m[1].trim(), target);
        return r.text;
      }
    }
    // QR: "اعمل QR لرابط https://example.com"
    {
      const m = clean.match(/^(اعمل|أنشئ|انشئ|سوي|سوّي)\s+(QR|كيو آر|رمز|باركود)\s*(ل|لرابط|للرابط)?\s*(.+)$/i);
      if (m && m[4]) {
        const buf = await tools.generateQRBuffer(m[4].trim());
        return { text: "هذا رمز QR لما طلبته:\n" + m[4].trim(), mediaBuffer: buf, fileName: "qr.png", mimetype: "image/png" };
      }
    }
    // عد تنازلي: "كم باقي على 2026-11-20"
    {
      const m = clean.match(/^كم باقي\s+(على|ل|لي)?\s*(.+)$/);
      if (m) {
        const dateMatch = m[2].match(/(\d{4}-\d{2}-\d{2})/);
        if (dateMatch) {
          const label = m[2].replace(dateMatch[1], "").trim();
          return tools.countdownTo(dateMatch[1], label || dateMatch[1]);
        }
      }
    }
    // عشوائي: "اختار لي رقم"
    if (/^(اختار|اختر)\s+(لي\s+)?(رقم|عدد)/.test(clean)) {
      return "الرقم العشوائي: " + (Math.floor(Math.random() * 100) + 1) + " (من 1 إلى 100)";
    }
    // حقائق ونكت محلية
    if (/^(حقيقة|معلومة|أخبرني حقيقة|قل لي حقيقة)/.test(clean)) {
      return "💡 " + tools.randomPick(tools.FACTS);
    }
    if (/^(نكتة|اضحكني|قل نكتة|قول نكتة)/.test(clean)) {
      return "😄 " + tools.randomPick(tools.JOKES);
    }
    // ملف نصي أو جدول CSV: "اعمل ملف نصي باسم ملاحظات فيه ..."
    {
      const m = clean.match(/^(اعمل|أنشئ|انشئ)\s+(ملف نصي|ملف|جدول)\s+(.+)$/);
      if (m) {
        const rest = m[3];
        const nameMatch = rest.match(/باسم\s+([^\s]+)/);
        const name = nameMatch ? nameMatch[1].replace(/\.(txt|md|csv)$/i, "") : "ملف";
        const contentMatch = rest.match(/فيه\s+(.+)$/);
        const content = contentMatch ? contentMatch[1] : "";
        if (m[2] === "جدول") {
          const rows = content ? content.split(/[;؛]/).map((r) => r.trim()).filter(Boolean) : ["الاسم,القيمة", "مثال,1"];
          const csv = rows.join("\n");
          return { text: "أنشأت لك الجدول: " + name + ".csv", documentBuffer: Buffer.from(csv, "utf8"), fileName: name + ".csv", mimetype: "text/csv" };
        }
        const text = content || "ملف أنشأه أثير.\n";
        return { text: "أنشأت لك الملف: " + name + ".txt", documentBuffer: Buffer.from(text, "utf8"), fileName: name + ".txt", mimetype: "text/plain" };
      }
    }
    // الأخبار: "أخبار اليوم"
    if (/^(أخبار|اخبار|أخبار اليوم|اخبار اليوم|ما هي الأخبار|وش الأخبار)/.test(clean)) {
      const r = await tools.getNews();
      return r.text;
    }
    // معنى كلمة: "ما معنى كلمة ..."
    // إن لم يجد القاموس المجاني معنى، نترك الرد للذكاء الاصطناعي بدلاً من الفشل.
    {
      const m = clean.match(/^ما معنى\s+(كلمة\s+)?(.+?)\s*\??$/);
      if (m && m[2]) {
        const r = await tools.defineWord(m[2].trim());
        if (r.ok) return r.text;
      }
    }
  } catch (err) {
    console.error("خطأ في أداة مجانية:", err.message);
    return "تعذرت هذه الخدمة المجانية الآن. حاول مرة أخرى بعد قليل.";
  }

  // ===== الأوامر القديمة: بدائل للتوافق فقط، ليست مطلوبة =====

  if (clean === "/help" || clean === "مساعدة" || clean === "المساعدة") {
    return helpText();
  }

  if (clean.startsWith("/project ")) {
    const rest = clean.slice("/project ".length).trim();
    const parts = rest.split("|");
    const name = (parts[0] || "").trim();
    const description = (parts[1] || "").trim();
    if (!name) return "اكتب اسم المشروع، مثال: احفظ مشروع فيلدورا | مدينة حياة واقعية";
    const project = addProject(memory, name, description);
    return "تم حفظ المشروع: " + project.name + (description ? " — " + description : "") + "\nعدد مشاريعك الآن: " + memory.projects.length;
  }

  if (clean === "/projects") {
    return listProjectsReply(memory);
  }

  if (clean.startsWith("/note ")) {
    const noteText = clean.slice("/note ".length).trim();
    if (!noteText) return "اكتب نص الملاحظة، مثال: احفظ ملاحظة راجع درس الجامعة غداً";
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
    if (!date) return "اكتب التاريخ والوقت، مثال: سجل موعد 2026-11-20 10:00 | موعد طبيب";
    const appt = addAppointment(memory, date, time, title);
    return "تم حجز موعدك: " + appt.title + " — " + appt.date + (appt.time ? " " + appt.time : "") + "\nعدد مواعيدك الآن: " + memory.appointments.length;
  }

  if (clean === "/appointments" || clean === "/مواعيد" || clean === "مواعيدي") {
    return listAppointmentsReply(memory);
  }

  if (clean.startsWith("/browse ")) {
    const url = clean.slice("/browse ".length).trim();
    return await browseReply(url);
  }

  if (clean.startsWith("/")) {
    return "لم أفهم طلبك. اكتب لي مباشرة ما تريده، مثلاً: افتح موقع، احفظ مشروع، سجل ملاحظة، أو سجل موعد.";
  }

  // أسئلة سريعة يرد عليها محلياً فوراً، دون انتظار الذكاء الاصطناعي البطيء.
  if ((/^(سلام|مرحبا|مرحباً|هلا|اهلا|أهلا|صباح|مساء)(\s|$)/.test(clean) || /^(hi|hello|hey)\b/i.test(clean)) || /من أنت|من انت|who are you/i.test(clean) || /^\s*-?[\d.]+\s*[+\-*/×÷]\s*-?[\d.]+\s*$/.test(clean) || /الساعة|الوقت|التاريخ/.test(clean)) {
    return localFallback(clean, memory);
  }

  // رسالة عادية: رد ذكاء اصطناعي (أو رد احتياطي إن لم يكن المفتاح مضبوطاً).
  return await askAI(clean, memory);
}

module.exports = { handleMessage, helpText, askAI, DAILY_LIMIT };
