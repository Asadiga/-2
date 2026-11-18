// tab-bot — index.js
// نقطة الدخول: اتصال واتساب عبر Baileys (WhatsApp Web) مع مسح QR.
// لا يوجد هنا أي تسجيل دخول تلقائي ولا أي بيانات اعتماد مضمّنة.
// عند التشغيل تظهر QR في الطرفية؛ امسحها من واتساب في الهاتف الذي
// يحمل رقم البوت، وستُحفظ الجلسة في مجلد ./auth بعد أول مسح ناجح.
require("dotenv").config();
const qrcode = require("qrcode-terminal");
const {
  default: makeWASocket,
  useMultiFileAuthState,
  DisconnectReason
} = require("@whiskeysockets/baileys");
const { handleMessage } = require("./bot");

// هوية المالك: رقم هاتفه، ومعرّف واتساب LID الخاص به.
// واتساب يرسل أحياناً رسائل المالك بمعرّف LID (مثل 158239916294218@lid)
// بدلاً من رقم الهاتف، فكان البوت يتجاهلها خطأً. نقبل الاثنين.
// OWNER_LID في .env، وافتراضياً معرّف LID المرصود لرسائل المالك.
const OWNER_NUMBER = (process.env.OWNER_NUMBER || "249127271642").replace(/\D/g, "");
const OWNER_LID = (process.env.OWNER_LID || "158239916294218").replace(/\D/g, "");

// يستخرج كل معرّفات المرسل المحتملة من رسالة Baileys (رقم هاتف أو LID).
function senderIdentifiers(msg) {
  const key = (msg && msg.key) || {};
  const raw = [
    key.remoteJid,
    key.participant,
    key.senderLid,
    key.participantLid,
    key.remoteJidAlt,
    key.participantAlt,
    msg.participant,
    msg.senderLid
  ].filter(Boolean);
  return raw.map((jid) => String(jid).split("@")[0].replace(/\D/g, "")).filter(Boolean);
}

// هل هذه الرسالة من المالك؟ تقبل رقم الهاتف أو LID، في المحادثة الخاصة فقط.
function isOwnerMessage(msg) {
  const key = (msg && msg.key) || {};
  if (String(key.remoteJid || "").endsWith("@g.us")) return false; // مجموعات: تجاهل دائماً
  const ids = senderIdentifiers(msg);
  return ids.some((id) => id === OWNER_NUMBER || (OWNER_LID && id === OWNER_LID));
}

async function start() {
  // خادم HTTP صغير لخدمات الويب المجانية (مثل Render Web Service):
  // يرد على المنفذ PORT حتى لا تعتبر الخدمة متوقفة.
  const port = process.env.PORT ? parseInt(process.env.PORT, 10) : 0;
  if (port) {
    try {
      const http = require("http");
      http
        .createServer((req, res) => {
          res.writeHead(200, { "Content-Type": "text/plain; charset=utf-8" });
          res.end("أثير يعمل الآن.\n");
        })
        .listen(port, () => console.log("خادم الحالة يعمل على المنفذ " + port));
    } catch (e) {
      console.error("تعذر تشغيل خادم الحالة:", e.message);
    }
  }

  const { state, saveCreds } = await useMultiFileAuthState("./auth");

  // هذه البيئة تمنع TLS المباشر (بوابة الخروج تعيد "wrong version number")
  // لذا يجب تمرير وكيل البروكسي صراحةً إلى WebSocket الخاص بـ Baileys،
  // لأن مكتبة ws لا تقرأ متغيرات البروكسي من البيئة تلقائياً.
  // لا نطبع رابط البروكسي أبداً لأنه يحتوي بيانات اعتماد.
  let proxyAgent = undefined;
  const proxyUrl = process.env.HTTPS_PROXY || process.env.https_proxy;
  if (proxyUrl) {
    try {
      const { HttpsProxyAgent } = require("https-proxy-agent");
      proxyAgent = new HttpsProxyAgent(proxyUrl);
      console.log("يتم الاتصال بواتساب عبر بروكسي الخروج.");
    } catch (e) {
      console.error("تعذر إنشاء وكيل البروكسي:", e.message);
    }
  }

  const sock = makeWASocket({
    auth: state,
    agent: proxyAgent,
    fetchAgent: proxyAgent,
    printQRInTerminal: false // نعرض QR بأنفسنا عبر qrcode-terminal
  });

  // ربط برقم الهاتف بدلاً من QR (لمن ليس لديه جهاز آخر للمسح):
  // ضع رقم البوت في .env باسم PAIRING_NUMBER بصيغة دولية بلا +، مثال 249997560126،
  // وسيطبع البوت رمز ربط من 8 أرقام تدخله في واتساب نفسه:
  // الإعدادات > الأجهزة المرتبطة > ربط جهاز > الربط برقم الهاتف بدلاً من ذلك.
  const pairingNumber = (process.env.PAIRING_NUMBER || "").replace(/\D/g, "");
  if (pairingNumber && !state.creds.registered) {
    // انتظر قليلاً حتى يتهيأ الاتصال قبل طلب الرمز.
    setTimeout(async () => {
      try {
        const code = await sock.requestPairingCode(pairingNumber);
        console.log("رمز ربط واتساب برقم الهاتف (" + pairingNumber + "): " + code);
        console.log("أدخل هذا الرمز في واتساب: الإعدادات > الأجهزة المرتبطة > ربط جهاز > الربط برقم الهاتف.");
        try {
          require("fs").writeFileSync("./pairing.txt", code, "utf8");
          console.log("تم حفظ رمز الربط في ./pairing.txt");
        } catch (e) {
          console.error("تعذر حفظ pairing.txt:", e.message);
        }
      } catch (e) {
        console.error("تعذر طلب رمز الربط:", e.message);
      }
    }, 5000);
  }

  sock.ev.on("creds.update", saveCreds);

  sock.ev.on("connection.update", (update) => {
    const { connection, lastDisconnect, qr } = update;
    if (qr) {
      console.log("امسح رمز QR التالي من واتساب في هاتف رقم البوت:");
      console.log("QR_RAW:" + qr);
      try {
        require("fs").writeFileSync("./qr.txt", qr, "utf8");
        console.log("تم حفظ رمز QR الخام في ./qr.txt");
      } catch (e) {
        console.error("تعذر حفظ qr.txt:", e.message);
      }
      try {
        const QRCode = require("qrcode");
        QRCode.toFile("./qr.png", qr, { width: 512, margin: 2 }).then(
          () => console.log("تم حفظ صورة QR في ./qr.png"),
          (e) => console.error("تعذر إنشاء qr.png:", e.message)
        );
      } catch (e) {
        console.log("حزمة qrcode غير مثبتة، لن تُنشأ صورة PNG (الرمز يظهر في الطرفية فقط).");
      }
      qrcode.generate(qr, { small: true });
    }
    if (connection === "open") {
      console.log("تم الاتصال بواتساب بنجاح. البوت يعمل الآن.");
    }
    if (connection === "close") {
      const shouldReconnect =
        lastDisconnect &&
        lastDisconnect.error &&
        lastDisconnect.error.output &&
        lastDisconnect.error.output.statusCode !== DisconnectReason.loggedOut;
      console.log("انقطع الاتصال.", shouldReconnect ? "سأعيد الاتصال..." : "تم تسجيل الخروج، امسح QR من جديد.");
      if (shouldReconnect) start();
    }
  });

  sock.ev.on("messages.upsert", async ({ messages }) => {
    for (const msg of messages) {
      if (!msg.message || msg.key.fromMe) continue;
      // تجاهل رسائل الحالة (status) والقنوات
      if (msg.key.remoteJid === "status@broadcast") continue;

      // خاص بصاحبه فقط: يرد فقط على رقم الصادق أو معرّف LID الخاص به،
      // ويتجاهل أي رقم أو معرّف آخر. المجموعات تُتجاهل دائماً.
      // سجّل تشخيصي: معرّفات المرسل فقط، دون نص الرسالة.
      console.log(
        "معرّفات المرسل: remoteJid=" + (msg.key.remoteJid || "") +
        " participant=" + (msg.key.participant || "") +
        " senderLid=" + (msg.key.senderLid || "") +
        " participantLid=" + (msg.key.participantLid || "")
      );
      if (msg.key.remoteJid.endsWith("@g.us")) continue;
      if (!isOwnerMessage(msg)) {
        console.log("تجاهل رسالة من رقم غير مصرّح: " + senderIdentifiers(msg).join(","));
        continue;
      }
      console.log("رسالة من المالك.");

      const text =
        msg.message.conversation ||
        (msg.message.extendedTextMessage && msg.message.extendedTextMessage.text) ||
        "";
      if (!text.trim()) continue;

      const sender = msg.pushName || msg.key.remoteJid;
      console.log("رسالة من " + sender + ": " + text);

      try {
        const reply = await handleMessage(text, sender);
        // قد يعيد handleMessage نصاً، أو كائن وسائط { text, mediaUrl }
        // (مثل تصميم صورة) فيرسل كصورة واتساب مع تعليق، أو ملف/مستند.
        if (reply && typeof reply === "object") {
          if (reply.mediaUrl) {
            await sock.sendMessage(msg.key.remoteJid, {
              image: { url: reply.mediaUrl },
              caption: reply.text || ""
            });
          } else if (reply.documentBuffer) {
            await sock.sendMessage(msg.key.remoteJid, {
              document: reply.documentBuffer,
              fileName: reply.fileName || "file.txt",
              mimetype: reply.mimetype || "text/plain",
              caption: reply.text || ""
            });
          } else if (reply.mediaBuffer) {
            await sock.sendMessage(msg.key.remoteJid, {
              image: reply.mediaBuffer,
              caption: reply.text || ""
            });
          } else {
            await sock.sendMessage(msg.key.remoteJid, { text: reply.text || "تم." });
          }
        } else {
          await sock.sendMessage(msg.key.remoteJid, { text: reply });
        }
      } catch (err) {
        console.error("خطأ أثناء معالجة رسالة:", err.message);
        try {
          await sock.sendMessage(msg.key.remoteJid, {
            text: "حدث خطأ مؤقت. حاول مرة أخرى."
          });
        } catch (e) {
          console.error("تعذر إرسال رسالة الخطأ:", e.message);
        }
      }
    }
  });
}

if (require.main === module) {
  start().catch((err) => {
    console.error("فشل تشغيل البوت:", err);
    process.exit(1);
  });
}

module.exports = { isOwnerMessage, senderIdentifiers, OWNER_NUMBER, OWNER_LID };
