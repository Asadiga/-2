// tab-bot — tools.js
// أدوات مجانية بالكامل، بلا مفاتيح API وبلا دفع. كل أداة هنا تستدعي
// خدمة مجانية مفتوحة (Open-Meteo, Aladhan, AlQuran Cloud, MyMemory,
// er-api, Wiktionary, RSS) أو تعمل محلياً (حساب، QR، ملفات نصية/CSV).
// إن فشلت خدمة، نعيد رسالة عربية واضحة ولا ندعي نجاحاً لم يحدث.
// PDF غير متوفر: لا توجد مكتبة PDF مثبتة، فلا ندعي إنشاء PDF.

async function fetchJson(url, timeoutMs = 12000) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(url, { signal: controller.signal, headers: { "User-Agent": "AtheerBot/1.0" } });
    if (!res.ok) throw new Error("HTTP " + res.status);
    return await res.json();
  } finally {
    clearTimeout(timer);
  }
}

async function fetchText(url, timeoutMs = 12000) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(url, { signal: controller.signal, headers: { "User-Agent": "AtheerBot/1.0" } });
    if (!res.ok) throw new Error("HTTP " + res.status);
    return await res.text();
  } finally {
    clearTimeout(timer);
  }
}

// مدن شائعة لدى المستخدم: عربي -> إحداثيات + اسم إنجليزي + دولة.
const CITIES = {
  "الخرطوم": { lat: 15.5, lon: 32.56, en: "Khartoum", country: "Sudan" },
  "أم درمان": { lat: 15.65, lon: 32.48, en: "Omdurman", country: "Sudan" },
  "ام درمان": { lat: 15.65, lon: 32.48, en: "Omdurman", country: "Sudan" },
  "بورتسودان": { lat: 19.62, lon: 37.22, en: "Port Sudan", country: "Sudan" },
  "مدني": { lat: 14.4, lon: 33.52, en: "Wad Madani", country: "Sudan" },
  "الرياض": { lat: 24.71, lon: 46.68, en: "Riyadh", country: "Saudi Arabia" },
  "جدة": { lat: 21.49, lon: 39.19, en: "Jeddah", country: "Saudi Arabia" },
  "مكة": { lat: 21.42, lon: 39.83, en: "Mecca", country: "Saudi Arabia" },
  "المدينة": { lat: 24.47, lon: 39.61, en: "Medina", country: "Saudi Arabia" },
  "الدمام": { lat: 26.42, lon: 50.09, en: "Dammam", country: "Saudi Arabia" },
  "القاهرة": { lat: 30.04, lon: 31.24, en: "Cairo", country: "Egypt" },
  "دبي": { lat: 25.2, lon: 55.27, en: "Dubai", country: "United Arab Emirates" },
  "الدوحة": { lat: 25.29, lon: 51.53, en: "Doha", country: "Qatar" },
  "الكويت": { lat: 29.38, lon: 47.98, en: "Kuwait City", country: "Kuwait" },
  "عمّان": { lat: 31.95, lon: 35.93, en: "Amman", country: "Jordan" },
  "عمان": { lat: 31.95, lon: 35.93, en: "Amman", country: "Jordan" },
  "إسطنبول": { lat: 41.01, lon: 28.98, en: "Istanbul", country: "Turkey" },
  "اسطنبول": { lat: 41.01, lon: 28.98, en: "Istanbul", country: "Turkey" },
  "لندن": { lat: 51.51, lon: -0.13, en: "London", country: "United Kingdom" },
  "باريس": { lat: 48.86, lon: 2.35, en: "Paris", country: "France" }
};

const CURRENCIES = {
  "دولار": "USD", "دولار أمريكي": "USD", "دولار امريكي": "USD",
  "جنيه سوداني": "SDG", "جنيه": "SDG",
  "ريال سعودي": "SAR", "ريال": "SAR",
  "جنيه مصري": "EGP",
  "درهم": "AED", "درهم إماراتي": "AED",
  "يورو": "EUR",
  "ريال قطري": "QAR",
  "دينار كويتي": "KWD", "دينار": "KWD",
  "جنيه إسترليني": "GBP", "باوند": "GBP",
  "ليرة تركية": "TRY",
  "ريال يمني": "YER"
};

function findCurrency(text) {
  const lower = text;
  // الأطول أولاً حتى يسبق "جنيه سوداني" كلمة "جنيه" وحدها.
  const names = Object.keys(CURRENCIES).sort((a, b) => b.length - a.length);
  for (const name of names) {
    if (lower.includes(name)) return { name, code: CURRENCIES[name] };
  }
  const code = text.match(/\b(USD|SDG|SAR|EGP|AED|EUR|QAR|KWD|GBP|TRY)\b/i);
  if (code) return { name: code[1].toUpperCase(), code: code[1].toUpperCase() };
  return null;
}

// ---- الطقس (Open-Meteo، مجاني بلا مفتاح) ----
async function getWeather(cityAr) {
  const city = CITIES[cityAr.trim()];
  let lat, lon, display;
  if (city) {
    lat = city.lat; lon = city.lon; display = cityAr.trim();
  } else {
    // مدينة غير معروفة: جرّب خدمة تحديد المواقع المجانية من Open-Meteo.
    const geo = await fetchJson("https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(cityAr.trim()) + "&count=1&language=ar&format=json");
    if (!geo.results || !geo.results.length) return { ok: false, text: "لم أعرف مدينة '" + cityAr.trim() + "'. جرّب مدينة معروفة مثل الخرطوم أو الرياض." };
    lat = geo.results[0].latitude; lon = geo.results[0].longitude; display = geo.results[0].name;
  }
  const data = await fetchJson("https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&timezone=auto");
  const c = data.current;
  const desc = { 0: "صافٍ", 1: "صافٍ غالباً", 2: "غائم جزئياً", 3: "غائم", 45: "ضباب", 48: "ضباب متجمد", 51: "رذاذ خفيف", 61: "مطر خفيف", 63: "مطر", 65: "مطر غزير", 71: "ثلج خفيف", 80: "زخات مطر", 95: "عاصفة رعدية" }[c.weather_code] || "طقس متغير";
  return { ok: true, text: "طقس " + display + " الآن:\n🌡 الحرارة: " + c.temperature_2m + "°م\n☁️ الحالة: " + desc + "\n💧 الرطوبة: " + c.relative_humidity_2m + "%\n💨 الرياح: " + c.wind_speed_10m + " كم/س" };
}

// ---- العملات (er-api، مجاني بلا مفتاح) ----
async function convertCurrency(amount, fromText, toText) {
  const from = findCurrency(fromText);
  const to = findCurrency(toText);
  if (!from || !to) return { ok: false, text: "لم أعرف العملة. اكتب مثلاً: حول 100 دولار إلى جنيه سوداني" };
  const data = await fetchJson("https://open.er-api.com/v6/latest/" + from.code);
  const rate = data.rates && data.rates[to.code];
  if (!rate) return { ok: false, text: "تعذر جلب سعر الصرف الآن. حاول مرة أخرى بعد قليل." };
  const result = amount * rate;
  return { ok: true, text: amount + " " + from.name + " = " + result.toLocaleString("ar", { maximumFractionDigits: 2 }) + " " + to.name + "\nسعر الصرف: 1 " + from.name + " = " + rate.toLocaleString("ar", { maximumFractionDigits: 2 }) + " " + to.name };
}

// ---- أوقات الصلاة (Aladhan، مجاني بلا مفتاح) ----
async function getPrayerTimes(cityAr) {
  const city = CITIES[cityAr.trim()];
  const en = city ? city.en : cityAr.trim();
  const country = city ? city.country : "";
  const data = await fetchJson("https://api.aladhan.com/v1/timingsByCity?city=" + encodeURIComponent(en) + "&country=" + encodeURIComponent(country) + "&method=5");
  if (!data.data || !data.data.timings) return { ok: false, text: "تعذر جلب أوقات الصلاة الآن. حاول مرة أخرى بعد قليل." };
  const t = data.data.timings;
  const date = data.data.date && data.data.date.readable ? data.data.date.readable : "";
  return { ok: true, text: "أوقات الصلاة في " + cityAr.trim() + (date ? " (" + date + ")" : "") + ":\n🕌 الفجر: " + t.Fajr + "\n🌅 الشروق: " + t.Sunrise + "\n☀️ الظهر: " + t.Dhuhr + "\n🌤 العصر: " + t.Asr + "\n🌆 المغرب: " + t.Maghrib + "\n🌙 العشاء: " + t.Isha };
}

// ---- القرآن (AlQuran Cloud، مجاني بلا مفتاح) ----
const SURAHS = {
  "الفاتحة": 1, "البقرة": 2, "آل عمران": 3, "النساء": 4, "المائدة": 5,
  "الأنعام": 6, "الأعراف": 7, "الأنفال": 8, "التوبة": 9, "يونس": 10,
  "هود": 11, "يوسف": 12, "الرعد": 13, "إبراهيم": 14, "الحجر": 15,
  "النحل": 16, "الإسراء": 17, "الكهف": 18, "مريم": 19, "طه": 20,
  "الأنبياء": 21, "الحج": 22, "المؤمنون": 23, "النور": 24, "الفرقان": 25,
  "الشعراء": 26, "النمل": 27, "القصص": 28, "العنكبوت": 29, "الروم": 30,
  "لقمان": 31, "السجدة": 32, "الأحزاب": 33, "سبأ": 34, "فاطر": 35,
  "يس": 36, "الصافات": 37, "ص": 38, "الزمر": 39, "غافر": 40,
  "فصلت": 41, "الشورى": 42, "الزخرف": 43, "الدخان": 44, "الجاثية": 45,
  "الأحقاف": 46, "محمد": 47, "الفتح": 48, "الحجرات": 49, "ق": 50,
  "الذاريات": 51, "الطور": 52, "النجم": 53, "القمر": 54, "الرحمن": 55,
  "الواقعة": 56, "الحديد": 57, "المجادلة": 58, "الحشر": 59, "الممتحنة": 60,
  "الصف": 61, "الجمعة": 62, "المنافقون": 63, "التغابن": 64, "الطلاق": 65,
  "التحريم": 66, "الملك": 67, "القلم": 68, "الحاقة": 69, "المعارج": 70,
  "نوح": 71, "الجن": 72, "المزمل": 73, "المدثر": 74, "القيامة": 75,
  "الإنسان": 76, "المرسلات": 77, "النبأ": 78, "النازعات": 79, "عبس": 80,
  "التكوير": 81, "الانفطار": 82, "المطففين": 83, "الانشقاق": 84, "البروج": 85,
  "الطارق": 86, "الأعلى": 87, "الغاشية": 88, "الفجر": 89, "البلد": 90,
  "الشمس": 91, "الليل": 92, "الضحى": 93, "الشرح": 94, "التين": 95,
  "العلق": 96, "القدر": 97, "البينة": 98, "الزلزلة": 99, "العاديات": 100,
  "القارعة": 101, "التكاثر": 102, "العصر": 103, "الهمزة": 104, "الفيل": 105,
  "قريش": 106, "الماعون": 107, "الكوثر": 108, "الكافرون": 109, "النصر": 110,
  "المسد": 111, "الإخلاص": 112, "الفلق": 113, "الناس": 114
};

async function getSurah(nameOrNum) {
  const num = /^\d+$/.test(nameOrNum.trim()) ? parseInt(nameOrNum.trim(), 10) : SURAHS[nameOrNum.trim()];
  if (!num || num < 1 || num > 114) return { ok: false, text: "لم أعرف السورة '" + nameOrNum.trim() + "'. اكتب مثلاً: سورة الفاتحة أو سورة 36" };
  const data = await fetchJson("https://api.alquran.cloud/v1/surah/" + num);
  if (!data.data || !data.data.ayahs) return { ok: false, text: "تعذر جلب السورة الآن. حاول مرة أخرى بعد قليل." };
  const ayahs = data.data.ayahs.map((a) => a.text).join(" ");
  const shown = ayahs.length > 1500 ? ayahs.slice(0, 1500) + "…" : ayahs;
  return { ok: true, text: "سورة " + data.data.name + " (" + data.data.numberOfAyahs + " آية):\n\n" + shown };
}

// ---- الترجمة (MyMemory، مجانية بلا مفتاح، مع حد للاستخدام) ----
async function translateText(text, targetLang) {
  const pair = targetLang === "ar" ? "en|ar" : targetLang === "fr" ? "ar|fr" : "ar|en";
  const data = await fetchJson("https://api.mymemory.translated.net/get?q=" + encodeURIComponent(text) + "&langpair=" + pair);
  const translated = data && data.responseData && data.responseData.translatedText;
  if (!translated) return { ok: false, text: "تعذرت الترجمة الآن (الخدمة المجانية محدودة). حاول مرة أخرى بعد قليل." };
  return { ok: true, text: "الترجمة:\n" + translated };
}

// ---- QR محلي (حزمة qrcode المثبتة أصلاً) ----
async function generateQRBuffer(text) {
  const QRCode = require("qrcode");
  return await QRCode.toBuffer(text, { width: 512, margin: 2 });
}

// ---- الأخبار (RSS مجاني، بلا مفتاح) ----
async function getNews() {
  const feeds = [
    { name: "بي بي سي عربي", url: "https://feeds.bbci.co.uk/arabic/rss.xml" },
    { name: "الجزيرة", url: "https://www.aljazeera.net/aljazeerarss" }
  ];
  for (const feed of feeds) {
    try {
      const xml = await fetchText(feed.url, 10000);
      const titles = [...xml.matchAll(/<item>[\s\S]*?<title>(?:<!\[CDATA\[)?([\s\S]*?)(?:\]\]>)?<\/title>/g)]
        .map((m) => m[1].replace(/<[^>]+>/g, "").trim())
        .filter(Boolean)
        .slice(0, 5);
      if (titles.length) {
        return { ok: true, text: "أخبار اليوم — " + feed.name + ":\n\n" + titles.map((t, i) => (i + 1) + ". " + t).join("\n") };
      }
    } catch (e) {
      // جرّب المصدر التالي.
    }
  }
  return { ok: false, text: "تعذر جلب الأخبار الآن. حاول مرة أخرى بعد قليل." };
}

// ---- معنى كلمة (ويكاموس العربي المجاني، ثم قاموس إنجليزي مجاني) ----
async function defineWord(word) {
  const w = word.trim();
  try {
    const data = await fetchJson("https://ar.wiktionary.org/w/api.php?action=query&prop=extracts&explaintext=1&titles=" + encodeURIComponent(w) + "&format=json&origin=*");
    const pages = data.query && data.query.pages ? Object.values(data.query.pages) : [];
    const page = pages.length ? pages[0] : null;
    const extract = page && page.extract ? page.extract.trim() : "";
    // صفحة غير موجودة تحمل مفتاح missing؛ وصفحة موجودة قد يكون ملخصها فارغاً.
    if (extract && !(page && "missing" in page)) {
      return { ok: true, text: "معنى '" + w + "':\n\n" + extract.slice(0, 1200) };
    }
  } catch (e) {
    // جرّب القاموس الإنجليزي إن كانت الكلمة إنجليزية.
  }
  try {
    const data = await fetchJson("https://api.dictionaryapi.dev/api/v2/entries/en/" + encodeURIComponent(w));
    const def = data && data[0] && data[0].meanings && data[0].meanings[0] && data[0].meanings[0].definitions && data[0].meanings[0].definitions[0];
    if (def && def.definition) {
      return { ok: true, text: "معنى '" + w + "' (بالإنجليزية):\n" + def.definition + (def.example ? "\nمثال: " + def.example : "") };
    }
  } catch (e) {
    // لا شيء.
  }
  return { ok: false, text: "لم أجد معنى لكلمة '" + w + "'. تأكد من الإملاء وحاول مرة أخرى." };
}

// ---- محلي: عد تنازلي، عشوائي، حقائق ----
function countdownTo(dateStr, label) {
  const target = new Date(dateStr + "T00:00:00");
  if (isNaN(target.getTime())) return null;
  const now = new Date();
  const diff = Math.ceil((target - now) / (1000 * 60 * 60 * 24));
  if (diff < 0) return "مرّ على " + (label || dateStr) + " " + Math.abs(diff) + " يوماً.";
  if (diff === 0) return "اليوم هو موعد " + (label || dateStr) + "!";
  return "باقي على " + (label || dateStr) + ": " + diff + " يوماً.";
}

const FACTS = [
  "السودان من أكبر الدول الأفريقية مساحة، ويمر به نهر النيل وروافده.",
  "الخرطوم ملتقى النيلين: النيل الأبيض والنيل الأزرق.",
  "أول من اخترع الكتابة هم السومريون قبل أكثر من 5000 سنة.",
  "قلب الإنسان ينبض نحو 100 ألف مرة في اليوم.",
  "الضوء من الشمس يصل إلى الأرض في نحو 8 دقائق.",
  "القهوة من أكثر المشروبات انتشاراً في العالم، وأصلها من اليمن وإثيوبيا."
];

const JOKES = [
  "قال المعلم للتلميذ: لماذا تأخرت؟ قال: لأن الساعة عندنا متأخرة!",
  "واحد قال لصاحبه: أنا أسرع واحد في القراءة، أقرأ صفحة في ثانية. قال له: كيف؟ قال: أقرأ العنوان فقط!",
  "سأل الأستاذ التلميذ: ما هو أسرع شيء في العالم؟ قال: الفطور، لأن أمي تقول: كُل بسرعة!"
];

function randomPick(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

module.exports = {
  CITIES, CURRENCIES,
  getWeather, convertCurrency, getPrayerTimes, getSurah, translateText,
  generateQRBuffer, getNews, defineWord, countdownTo,
  FACTS, JOKES, randomPick, findCurrency
};
