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

async function start() {
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

      const text =
        msg.message.conversation ||
        (msg.message.extendedTextMessage && msg.message.extendedTextMessage.text) ||
        "";
      if (!text.trim()) continue;

      const sender = msg.pushName || msg.key.remoteJid;
      console.log("رسالة من " + sender + ": " + text);

      try {
        const reply = await handleMessage(text, sender);
        await sock.sendMessage(msg.key.remoteJid, { text: reply });
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

start().catch((err) => {
  console.error("فشل تشغيل البوت:", err);
  process.exit(1);
});
