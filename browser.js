// tab-bot — browser.js
// متصفح أثير الخاص: يفتح صفحة في Chromium headless داخل Codespace
// ويعيد عنوانها ونصها المختصر، ليستطيع أثير تصفح المواقع من واتساب.
// لا يسجل دخولاً تلقائياً ولا يملأ كلمات مرور؛ التصفح للقراءة أولاً.
let playwright = null;
try {
  playwright = require("playwright");
} catch (e) {
  playwright = null;
}

async function browsePage(url) {
  if (!playwright) {
    return { ok: false, text: "المتصفح غير مثبت بعد في جهاز أثير. أخبر كاي ليثبته." };
  }
  let fullUrl = (url || "").trim();
  if (!fullUrl) return { ok: false, text: "اكتب رابط الموقع، مثال: افتح موقع example.com" };
  if (!/^https?:\/\//i.test(fullUrl)) fullUrl = "https://" + fullUrl;
  let browser = null;
  try {
    browser = await playwright.chromium.launch({ args: ["--no-sandbox"] });
    const page = await browser.newPage();
    await page.goto(fullUrl, { waitUntil: "domcontentloaded", timeout: 30000 });
    await page.waitForTimeout(2000);
    const title = await page.title();
    let text = await page.evaluate(() => document.body ? document.body.innerText.slice(0, 3000) : "");
    text = (text || "").replace(/\s+/g, " ").trim();
    return { ok: true, title, url: fullUrl, text: text.slice(0, 1500) || "(الصفحة بلا نص ظاهر)" };
  } catch (err) {
    return { ok: false, text: "تعذر فتح الصفحة: " + err.message.slice(0, 200) };
  } finally {
    if (browser) await browser.close().catch(() => {});
  }
}

module.exports = { browsePage, browserAvailable: !!playwright };
