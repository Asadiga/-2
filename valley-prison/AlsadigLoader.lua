--[[
    🚀 لودر الصادق — Alsadig Loader v1
    تطوير الصادق — Developed by Alsadig
    ============================================================
    لودر خاص بك على طريقة دلتا: رابط واحد يفتح قائمة فيها كل
    سكربتاتك، وتضغط على أي سكربت فيعمل مباشرة.

    طريقة التشغيل (على الهاتف):
    1) انسخ هذا السكربت كاملاً
    2) الصقه في دلتا واضغط تشغيل (Execute) وأنت داخل أي لعبة
    3) ستظهر قائمة اللودر — اضغط "تشغيل" بجانب السكربت الذي تريده
    4) سيعمل السكربت وتظهر قائمته الخاصة بزرها العائم

    السكربتات في القائمة:
    • ⛓️ سكربت الصادق الشامل — الكتالوج الكامل (سايلنت إيم، طيران،
      اختراق جدران، حماية، سرعة، ESP، تنقل)
    • 🛡️ البودي جارد — حراس شخصيون يتبعونك ويحمونك ممن يتهجم عليك

    ⚠️ ملاحظات مهمة بصراحة — اقرأها قبل التشغيل:
    • اللودر نفسه لا يطلق النار ولا يتجاوز حماية أي لعبة؛ هو فقط
      قائمة تشغّل سكربتاتك. الطرد الذي يأتي من سيرفر اللعبة
      (مضاد الغش يكشف المنفّذ نفسه) لا يستطيع أي سكربت منعه.
    • البودي جارد لم يُنشر على GitHub بعد — إذا ضغطت "تشغيل" عليه
      قبل نشره ستظهر رسالة "غير منشور بعد". أخبر الصادق ليرفعه،
      وسيعمل بعدها من نفس اللودر دون تغيير أي رابط.
    • الشامل يُحمَّل من نفس رابط GitHub الذي تعرفه، فأي تحديث
      جديد له يصلك تلقائياً دون تغيير اللودر.
    • الفلوس والخبرة (XP) والمستويات وأشياء الروبكس مجاناً:
      مستحيلة في أي ماب، لأنها محفوظة في سيرفر اللعبة وليس في
      جهازك، وأي سكربت أو فيديو يدّعي أنه يعطيك إياها فهو نصب
      لسرقة حسابك.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ================= ألوان وهوية الصادق (نفس الشامل) =================
local GOLD = Color3.fromRGB(241, 185, 47)
local GOLD_LIGHT = Color3.fromRGB(255, 220, 130)
local GOLD_DARK = Color3.fromRGB(180, 135, 20)
local BG_DARK = Color3.fromRGB(16, 16, 24)
local CARD_DARK = Color3.fromRGB(24, 24, 38)
local TEXT_WHITE = Color3.fromRGB(255, 255, 255)
local TEXT_MUTED = Color3.fromRGB(170, 170, 190)

local BASE_URL = "https://raw.githubusercontent.com/Asadiga/-2/refs/heads/main/"

-- ================= قائمة السكربتات =================
-- لإضافة سكربت جديد لاحقاً: أضف سطراً واحداً هنا فقط.
local SCRIPTS = {
	{
		key = "hub",
		icon = "⛓️",
		name = "سكربت الصادق الشامل",
		desc = "سايلنت إيم • طيران • اختراق جدران • حماية • سرعة • ESP • تنقل",
		url = BASE_URL .. "valley-prison/ValleyPrison.lua",
	},
	{
		key = "bodyguard",
		icon = "🛡️",
		name = "البودي جارد",
		desc = "حراس شخصيون يتبعونك ويحمونك ممن يتهجم عليك",
		url = BASE_URL .. "bodyguard/Bodyguard.lua",
		unpublished = true,
	},
}

-- ================= بناء الواجهة =================
-- إذا شغّلت اللودر مرتين، احذف النسخة القديمة أولاً.
local oldGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("AlsadigLoaderGui")
if oldGui then
	pcall(function() oldGui:Destroy() end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AlsadigLoaderGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function addRichGoldGradient(obj)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, GOLD_LIGHT),
		ColorSequenceKeypoint.new(0.5, GOLD),
		ColorSequenceKeypoint.new(1, GOLD_DARK),
	})
	g.Rotation = 45
	g.Parent = obj
	return g
end

-- زر عائم يفتح اللودر ويغلقه (اسحبه لأي مكان يعجبك)
local floatButton = Instance.new("TextButton")
floatButton.Name = "FloatButton"
floatButton.Size = UDim2.new(0, 68, 0, 68)
floatButton.Position = UDim2.new(1, -88, 1, -340)
floatButton.BackgroundColor3 = GOLD
floatButton.Text = "🚀"
floatButton.TextSize = 30
floatButton.TextColor3 = Color3.fromRGB(25, 18, 5)
floatButton.Font = Enum.Font.GothamBold
floatButton.Active = true
floatButton.Draggable = true
floatButton.Parent = screenGui
addRichGoldGradient(floatButton)
local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(1, 0)
fc.Parent = floatButton
local fst = Instance.new("UIStroke")
fst.Color = GOLD_DARK
fst.Thickness = 2
fst.Parent = floatButton
task.spawn(function()
	while floatButton.Parent do
		TweenService:Create(floatButton, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 72, 0, 72) }):Play()
		task.wait(0.9)
		if not floatButton.Parent then break end
		TweenService:Create(floatButton, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 68, 0, 68) }):Play()
		task.wait(0.9)
	end
end)

-- القائمة الرئيسية
local menuFrame = Instance.new("Frame")
menuFrame.Name = "Menu"
menuFrame.Size = UDim2.new(0, 330, 0, 430)
menuFrame.Position = UDim2.new(0.5, -165, 0.5, -215)
menuFrame.BackgroundColor3 = BG_DARK
menuFrame.BorderSizePixel = 0
menuFrame.Active = true
menuFrame.Draggable = true
menuFrame.Parent = screenGui
local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 18)
mc.Parent = menuFrame
local ms = Instance.new("UIStroke")
ms.Color = Color3.fromRGB(60, 60, 80)
ms.Thickness = 1
ms.Parent = menuFrame

-- شريط العنوان
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 56)
titleBar.BackgroundColor3 = GOLD
titleBar.BorderSizePixel = 0
titleBar.Parent = menuFrame
addRichGoldGradient(titleBar)
local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 14)
tc.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🚀 لودر الصادق"
titleLabel.TextColor3 = Color3.fromRGB(25, 18, 5)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Right
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(0, 8, 0, 8)
closeButton.BackgroundColor3 = Color3.fromRGB(25, 18, 5)
closeButton.BackgroundTransparency = 0.25
closeButton.Text = "✕"
closeButton.TextColor3 = TEXT_WHITE
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = titleBar
local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 10)
cc.Parent = closeButton

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -24, 0, 24)
subtitle.Position = UDim2.new(0, 12, 0, 64)
subtitle.BackgroundTransparency = 1
subtitle.Text = "اضغط «تشغيل» بجانب السكربت الذي تريده"
subtitle.TextColor3 = TEXT_MUTED
subtitle.Font = Enum.Font.GothamBold
subtitle.TextSize = 14
subtitle.TextXAlignment = Enum.TextXAlignment.Right
subtitle.Parent = menuFrame

-- قائمة السكربتات (قابلة للتمرير عند إضافة المزيد)
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, -24, 1, -150)
listFrame.Position = UDim2.new(0, 12, 0, 94)
listFrame.BackgroundTransparency = 1
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.ScrollBarImageColor3 = GOLD
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.Parent = menuFrame
local ll = Instance.new("UIListLayout")
ll.Padding = UDim.new(0, 10)
ll.Parent = listFrame

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -24, 0, 44)
footer.Position = UDim2.new(0, 12, 1, -52)
footer.BackgroundTransparency = 1
footer.Text = "تطوير الصادق • اللودر قائمة فقط، ولا يتجاوز حماية أي لعبة"
footer.TextColor3 = TEXT_MUTED
footer.Font = Enum.Font.GothamBold
footer.TextSize = 12
footer.TextWrapped = true
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.Parent = menuFrame

-- ================= تشغيل سكربت =================
local function runScript(entry, statusLabel, runButton)
	if entry.loading then return end
	entry.loading = true
	runButton.Text = "⏳ جارٍ التحميل…"
	statusLabel.Text = "⏳ جارٍ التحميل من GitHub…"
	statusLabel.TextColor3 = TEXT_MUTED

	task.spawn(function()
		local ok, source = pcall(function()
			return game:HttpGet(entry.url)
		end)
		if not ok or not source or source == "" then
			if entry.unpublished then
				statusLabel.Text = "❌ غير منشور بعد — أخبر الصادق ليرفعه على GitHub"
			else
				statusLabel.Text = "❌ فشل التحميل — تحقق من الإنترنت وأعد المحاولة"
			end
			statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
			runButton.Text = "▶ تشغيل"
			entry.loading = false
			return
		end

		local fn, loadErr = loadstring(source)
		if not fn then
			statusLabel.Text = "❌ خطأ في السكربت: " .. tostring(loadErr)
			statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
			runButton.Text = "▶ تشغيل"
			entry.loading = false
			return
		end

		local runOk, runErr = pcall(fn)
		if not runOk then
			statusLabel.Text = "❌ تعذّر التشغيل: " .. tostring(runErr)
			statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
			runButton.Text = "▶ تشغيل"
			entry.loading = false
			return
		end

		entry.loaded = true
		entry.loading = false
		statusLabel.Text = "✅ يعمل الآن — افتح قائمته من زره العائم"
		statusLabel.TextColor3 = Color3.fromRGB(120, 255, 140)
		runButton.Text = "↻ إعادة التشغيل"
	end)
end

-- ================= بطاقة كل سكربت =================
for _, entry in ipairs(SCRIPTS) do
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 132)
	card.BackgroundColor3 = CARD_DARK
	card.BorderSizePixel = 0
	card.Parent = listFrame
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 14)
	cardCorner.Parent = card
	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = GOLD
	cardStroke.Transparency = 0.88
	cardStroke.Thickness = 1
	cardStroke.Parent = card

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -20, 0, 28)
	nameLabel.Position = UDim2.new(0, 10, 0, 8)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = entry.icon .. "  " .. entry.name
	nameLabel.TextColor3 = GOLD
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 17
	nameLabel.TextXAlignment = Enum.TextXAlignment.Right
	nameLabel.Parent = card

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -20, 0, 36)
	descLabel.Position = UDim2.new(0, 10, 0, 36)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = entry.desc
	descLabel.TextColor3 = TEXT_WHITE
	descLabel.Font = Enum.Font.GothamBold
	descLabel.TextSize = 13
	descLabel.TextWrapped = true
	descLabel.TextXAlignment = Enum.TextXAlignment.Right
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.Parent = card

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1, -20, 0, 18)
	statusLabel.Position = UDim2.new(0, 10, 0, 74)
	statusLabel.BackgroundTransparency = 1
	if entry.unpublished then
		statusLabel.Text = "⚠️ لم يُنشر على GitHub بعد"
		statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	else
		statusLabel.Text = "جاهز للتشغيل"
		statusLabel.TextColor3 = TEXT_MUTED
	end
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextSize = 12
	statusLabel.TextXAlignment = Enum.TextXAlignment.Right
	statusLabel.Parent = card

	local runButton = Instance.new("TextButton")
	runButton.Size = UDim2.new(1, -20, 0, 44)
	runButton.Position = UDim2.new(0, 10, 1, -52)
	runButton.BackgroundColor3 = GOLD
	runButton.Text = "▶ تشغيل"
	runButton.TextColor3 = Color3.fromRGB(25, 18, 5)
	runButton.Font = Enum.Font.GothamBold
	runButton.TextSize = 16
	runButton.Parent = card
	addRichGoldGradient(runButton)
	local rbCorner = Instance.new("UICorner")
	rbCorner.CornerRadius = UDim.new(0, 10)
	rbCorner.Parent = runButton

	runButton.MouseButton1Click:Connect(function()
		runScript(entry, statusLabel, runButton)
	end)
end

-- ================= فتح وإغلاق القائمة =================
local menuVisible = true
local function toggleMenu()
	menuVisible = not menuVisible
	menuFrame.Visible = menuVisible
end
floatButton.MouseButton1Click:Connect(toggleMenu)
closeButton.MouseButton1Click:Connect(function()
	menuVisible = false
	menuFrame.Visible = false
end)
