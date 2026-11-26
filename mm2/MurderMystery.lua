-- ============================================================
--  🔪 سكربت الصادق — الغموض (Alsadig Mystery)
--  سكربت Murder Mystery 2 لدلتا موبايل — تطوير الصادق
-- ============================================================
--  المميزات:
--   • كشف الأدوار: قاتل 🔪 / شريف 🔫 / بريء 😇 (اسم + مسافة + تظليل)
--   • قائمة أدوار حية لكل اللاعبين
--   • تجميع عملات تلقائي مع تأخير قابل للضبط
--   • التقاط مسدس الشريف فور سقوطه
--   • إظهار اللاعبين، تنبيهات قتل، حالة الجولة، مشاهدة، سرعة، حماية
--
--  ⚠️ حدود صريحة:
--   • الأدوار تُكشف من الأدوات الظاهرة (سكين/مسدس) في حقيبة اللاعب أو
--     شخصيته؛ لو أخفاها الماب أو غيّر أسماءها قد يفشل الكشف.
--   • سكين القاتل يصل بعد 10 ثوانٍ من بدء الجولة، ففي أول الجولة قد
--     يظهر القاتل كبريء مؤقتاً.
--   • العملات محدودة في كل جولة: 40 (أو 50 مع Elite) — لا عملات ولا
--     عناصر ولا مستويات مجانية، كلها في السيرفر.
--   • اللعبة يجب أن تبقى مفتوحة أثناء عمل السكربت.
--   • تم التحقق من الكود فقط؛ لم يُجرَّب داخل روبلوكس/دلتا بعد.
-- ============================================================

-- منع التشغيل المزدوج
if getgenv and getgenv().AlsadigMysteryLoaded then
    return
end
if getgenv then
    getgenv().AlsadigMysteryLoaded = true
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ====== الحالة ======
local state = {
    roleESP = false,        -- كشف الأدوار
    playerESP = false,      -- إظهار اللاعبين
    coinFarm = false,       -- تجميع العملات
    gunGrab = false,        -- التقاط المسدس
    killAlert = true,       -- تنبيهات القتل
    speedOn = false,        -- سرعة المشي
    speedValue = 32,
    coinDelay = 0.5,        -- تأخير بين العملات (ثوانٍ)
    coinsCollected = 0,     -- عملات هذه الجولة
    spectating = false,
    spectateIndex = 0,
}

-- ====== أدوات مساعدة ======
local function getChar(plr)
    plr = plr or LocalPlayer
    return plr and plr.Character
end

local function getHRP(plr)
    local ch = getChar(plr)
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function getHum(plr)
    local ch = getChar(plr)
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

local function isAlive(plr)
    local hum = getHum(plr)
    return hum ~= nil and hum.Health > 0
end

local function hasTool(plr, name)
    local bp = plr:FindFirstChildOfClass("Backpack")
    if bp and bp:FindFirstChild(name) then
        return true
    end
    local ch = plr.Character
    if ch and ch:FindFirstChild(name) then
        return true
    end
    return false
end

-- كشف الدور من الأدوات: سكين = قاتل، مسدس = شريف، غير ذلك = بريء
local function getRole(plr)
    if hasTool(plr, "Knife") then
        return "Murderer"
    elseif hasTool(plr, "Gun") then
        return "Sheriff"
    end
    return "Innocent"
end

local ROLE_INFO = {
    Murderer = { emoji = "🔪", name = "قاتل", color = Color3.fromRGB(255, 50, 70) },
    Sheriff  = { emoji = "🔫", name = "شريف", color = Color3.fromRGB(60, 160, 255) },
    Innocent = { emoji = "😇", name = "بريء", color = Color3.fromRGB(80, 255, 170) },
}

-- أسماء العملات المحتملة (عملات عادية + عملات فعاليات)
local COIN_NAMES = { Coin = true, Candy = true, Token = true, Gem = true }

local function findCoins()
    local coins = {}
    -- مجلد العملات إن وجد
    local container = Workspace:FindFirstChild("CoinContainer")
    if container then
        for _, v in ipairs(container:GetDescendants()) do
            if v:IsA("BasePart") and COIN_NAMES[v.Name] then
                table.insert(coins, v)
            end
        end
        if #coins > 0 then
            return coins
        end
    end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and COIN_NAMES[v.Name] then
            table.insert(coins, v)
        end
    end
    return coins
end

-- البحث عن مسدس الشريف الساقط في الأرض
local function findDroppedGun()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v.Name == "Gun" and (v:IsA("Tool") or v:IsA("Model")) then
            local parent = v.Parent
            -- المسدس الساقط يكون في العالم، ليس في يد لاعب
            if parent == Workspace or (parent and parent:IsA("Folder")) then
                local handle = v:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    return v, handle
                end
            end
        end
    end
    return nil, nil
end

local function countAlive()
    local n = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if isAlive(plr) then
            n = n + 1
        end
    end
    return n
end

local function findByRole(roleName)
    for _, plr in ipairs(Players:GetPlayers()) do
        if getRole(plr) == roleName then
            return plr
        end
    end
    return nil
end

-- ============================================================
--  الواجهة — هوية غموض جديدة: بنفسجي عميق + وردي/أحمر نيون
-- ============================================================

local COLORS = {
    bg       = Color3.fromRGB(26, 16, 48),    -- بنفسجي عميق
    bgCard   = Color3.fromRGB(40, 26, 72),    -- بطاقة
    bgCard2  = Color3.fromRGB(52, 34, 92),    -- بطاقة أفتح
    accent   = Color3.fromRGB(255, 45, 120),  -- وردي نيون
    accent2  = Color3.fromRGB(150, 60, 255),  -- بنفسجي نيون
    text     = Color3.fromRGB(245, 240, 255),
    muted    = Color3.fromRGB(185, 170, 225),
    off      = Color3.fromRGB(90, 75, 130),
    stroke   = Color3.fromRGB(110, 70, 180),
}

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 14)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or COLORS.stroke
    s.Thickness = thickness or 1
    s.Transparency = 0.4
    s.Parent = parent
    return s
end

local function label(parent, text, size, color, bold)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or COLORS.text
    l.TextSize = size or 15
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Right
    l.Parent = parent
    return l
end

-- جذر الواجهة
local guiParent = nil
pcall(function()
    if gethui then
        guiParent = gethui()
    end
end)
if not guiParent then
    guiParent = game:GetService("CoreGui")
end

local gui = Instance.new("ScreenGui")
gui.Name = "AlsadigMystery"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = guiParent

-- تنبيه سريع (Toast)
local toastFrame = Instance.new("Frame")
toastFrame.Size = UDim2.new(0, 320, 0, 44)
toastFrame.Position = UDim2.new(0.5, -160, 0, 70)
toastFrame.BackgroundColor3 = COLORS.bgCard2
toastFrame.BackgroundTransparency = 1
toastFrame.Visible = false
toastFrame.ZIndex = 50
toastFrame.Parent = gui
corner(toastFrame, 14)
stroke(toastFrame, COLORS.accent, 1.5)

local toastLabel = label(toastFrame, "", 15, COLORS.text, true)
toastLabel.Size = UDim2.new(1, -16, 1, 0)
toastLabel.Position = UDim2.new(0, 8, 0, 0)
toastLabel.TextXAlignment = Enum.TextXAlignment.Center
toastLabel.ZIndex = 51

local toastToken = 0
local function showToast(text)
    toastToken = toastToken + 1
    local myToken = toastToken
    toastLabel.Text = text
    toastFrame.Visible = true
    TweenService:Create(toastFrame, TweenInfo.new(0.25), { BackgroundTransparency = 0.1 }):Play()
    task.spawn(function()
        task.wait(2.6)
        if toastToken == myToken then
            TweenService:Create(toastFrame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            task.wait(0.32)
            if toastToken == myToken then
                toastFrame.Visible = false
            end
        end
    end)
end

-- الزر العائم 🔪
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 58, 0, 58)
floatBtn.Position = UDim2.new(0, 16, 0.5, -29)
floatBtn.BackgroundColor3 = COLORS.accent
floatBtn.Text = "🔪"
floatBtn.TextSize = 26
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatBtn.AutoButtonColor = true
floatBtn.ZIndex = 40
floatBtn.Parent = gui
corner(floatBtn, 29)
stroke(floatBtn, Color3.fromRGB(255, 255, 255), 1.5)

local floatGrad = Instance.new("UIGradient")
floatGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLORS.accent),
    ColorSequenceKeypoint.new(1, COLORS.accent2),
})
floatGrad.Rotation = 45
floatGrad.Parent = floatBtn

-- جعل الزر قابلاً للسحب
do
    local dragging = false
    local dragStart, startPos
    floatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = floatBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            floatBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- الإطار الرئيسي
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 350, 0, 520)
main.Position = UDim2.new(0.5, -175, 0.5, -260)
main.BackgroundColor3 = COLORS.bg
main.Visible = false
main.ZIndex = 30
main.Parent = gui
corner(main, 20)
stroke(main, COLORS.stroke, 1.5)

local mainScale = Instance.new("UIScale")
mainScale.Scale = 0.85
mainScale.Parent = main

-- ترويسة متدرجة
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 74)
header.BackgroundColor3 = COLORS.accent
header.BorderSizePixel = 0
header.ZIndex = 31
header.Parent = main
corner(header, 20)

local headerGrad = Instance.new("UIGradient")
headerGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 20, 160)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(180, 30, 130)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 45, 90)),
})
headerGrad.Rotation = 20
headerGrad.Parent = header

local title = label(header, "🔪 سكربت الصادق — الغموض", 19, Color3.fromRGB(255, 255, 255), true)
title.Size = UDim2.new(1, -70, 0, 30)
title.Position = UDim2.new(0, 14, 0, 10)
title.ZIndex = 32

local subtitle = label(header, "Murder Mystery 2  •  تطوير الصادق", 12, Color3.fromRGB(255, 225, 240), false)
subtitle.Size = UDim2.new(1, -70, 0, 20)
subtitle.Position = UDim2.new(0, 14, 0, 42)
subtitle.ZIndex = 32

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -48, 0, 19)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundTransparency = 0.75
closeBtn.Text = "✕"
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.ZIndex = 32
closeBtn.Parent = header
corner(closeBtn, 18)

-- محتوى قابل للتمرير
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -94)
scroll.Position = UDim2.new(0, 10, 0, 84)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = COLORS.accent2
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ZIndex = 31
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local orderCounter = 0
local function nextOrder()
    orderCounter = orderCounter + 1
    return orderCounter
end

-- بطاقة قسم
local function makeCard(cardTitle)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = COLORS.bgCard
    card.LayoutOrder = nextOrder()
    card.ZIndex = 32
    card.Parent = scroll
    corner(card, 16)
    stroke(card, COLORS.stroke, 1)

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.Parent = card

    local cl = Instance.new("UIListLayout")
    cl.Padding = UDim.new(0, 8)
    cl.SortOrder = Enum.SortOrder.LayoutOrder
    cl.Parent = card

    local t = label(card, cardTitle, 16, COLORS.accent, true)
    t.Size = UDim2.new(1, 0, 0, 22)
    t.LayoutOrder = 0
    t.ZIndex = 33
    return card
end

-- مفتاح تبديل (Toggle)
local function makeToggle(parent, text, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = COLORS.bgCard2
    row.LayoutOrder = nextOrder()
    row.ZIndex = 33
    row.Parent = parent
    corner(row, 12)

    local lbl = label(row, text, 15, COLORS.text, false)
    lbl.Size = UDim2.new(1, -76, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.ZIndex = 34

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 54, 0, 28)
    switch.Position = UDim2.new(1, -64, 0.5, -14)
    switch.BackgroundColor3 = default and COLORS.accent or COLORS.off
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.ZIndex = 34
    switch.Parent = row
    corner(switch, 14)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = default and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.ZIndex = 35
    knob.Parent = switch
    corner(knob, 11)

    local value = default
    local function refresh()
        TweenService:Create(switch, TweenInfo.new(0.2), {
            BackgroundColor3 = value and COLORS.accent or COLORS.off,
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = value and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11),
        }):Play()
    end

    switch.MouseButton1Click:Connect(function()
        value = not value
        refresh()
        if callback then
            callback(value)
        end
    end)
    return row
end

-- زر إجراء كبير
local function makeButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 46)
    btn.BackgroundColor3 = COLORS.accent2
    btn.Text = text
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.LayoutOrder = nextOrder()
    btn.ZIndex = 34
    btn.Parent = parent
    corner(btn, 12)
    btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    return btn
end

-- صف اختيار قيمة (أزرار صغيرة)
local function makeChoice(parent, text, options, defaultIndex, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = COLORS.bgCard2
    row.LayoutOrder = nextOrder()
    row.ZIndex = 33
    row.Parent = parent
    corner(row, 12)

    local lbl = label(row, text, 14, COLORS.text, false)
    lbl.Size = UDim2.new(0, 120, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.ZIndex = 34

    local selected = defaultIndex
    local buttons = {}
    local n = #options
    for i, opt in ipairs(options) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 52, 0, 30)
        b.Position = UDim2.new(1, -10 - (n - i + 1) * 56 + 4, 0.5, -15)
        b.BackgroundColor3 = (i == selected) and COLORS.accent or COLORS.off
        b.Text = opt.label
        b.TextSize = 13
        b.Font = Enum.Font.GothamBold
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.ZIndex = 34
        b.Parent = row
        corner(b, 10)
        buttons[i] = b
        b.MouseButton1Click:Connect(function()
            selected = i
            for j, bb in ipairs(buttons) do
                bb.BackgroundColor3 = (j == selected) and COLORS.accent or COLORS.off
            end
            if callback then
                callback(opt.value)
            end
        end)
    end
    return row
end

-- ============================================================
--  بناء الأقسام
-- ============================================================

-- قسم كشف الأدوار
local cardRoles = makeCard("🎭 كشف الأدوار")
makeToggle(cardRoles, "كشف الأدوار (قاتل/شريف/بريء)", false, function(v)
    state.roleESP = v
end)
makeToggle(cardRoles, "إظهار اللاعبين والمسافة", false, function(v)
    state.playerESP = v
end)

-- قائمة الأدوار الحية
local roleListTitle = label(cardRoles, "📋 أدوار اللاعبين الآن:", 14, COLORS.muted, true)
roleListTitle.Size = UDim2.new(1, 0, 0, 20)
roleListTitle.LayoutOrder = nextOrder()
roleListTitle.ZIndex = 33

local roleListFrame = Instance.new("Frame")
roleListFrame.Size = UDim2.new(1, 0, 0, 0)
roleListFrame.AutomaticSize = Enum.AutomaticSize.Y
roleListFrame.BackgroundTransparency = 1
roleListFrame.LayoutOrder = nextOrder()
roleListFrame.ZIndex = 33
roleListFrame.Parent = cardRoles

local roleListLayout = Instance.new("UIListLayout")
roleListLayout.Padding = UDim.new(0, 4)
roleListLayout.SortOrder = Enum.SortOrder.LayoutOrder
roleListLayout.Parent = roleListFrame

-- قسم العملات والمسدس
local cardFarm = makeCard("🪙 العملات والمسدس")
makeToggle(cardFarm, "تجميع العملات تلقائياً", false, function(v)
    state.coinFarm = v
    if v then
        showToast("🪙 بدأ تجميع العملات")
    end
end)
makeChoice(cardFarm, "تأخير العملة", {
    { label = "0.3ث", value = 0.3 },
    { label = "0.5ث", value = 0.5 },
    { label = "1ث", value = 1.0 },
}, 2, function(v)
    state.coinDelay = v
end)
makeToggle(cardFarm, "التقاط المسدس فور سقوطه", false, function(v)
    state.gunGrab = v
    if v then
        showToast("🔫 بانتظار سقوط المسدس...")
    end
end)

-- قسم الإضافات
local cardExtra = makeCard("⚙️ إضافات")
makeToggle(cardExtra, "تنبيه عند موت لاعب", true, function(v)
    state.killAlert = v
end)
makeToggle(cardExtra, "سرعة مشي أعلى", false, function(v)
    state.speedOn = v
    local hum = getHum()
    if hum then
        hum.WalkSpeed = v and state.speedValue or 16
    end
end)
makeChoice(cardExtra, "قيمة السرعة", {
    { label = "24", value = 24 },
    { label = "32", value = 32 },
    { label = "50", value = 50 },
}, 2, function(v)
    state.speedValue = v
    if state.speedOn then
        local hum = getHum()
        if hum then
            hum.WalkSpeed = v
        end
    end
end)
makeButton(cardExtra, "👁️ مشاهدة اللاعب التالي", function()
    spectateNext()
end)
makeButton(cardExtra, "🚫 إيقاف المشاهدة", function()
    stopSpectate()
end)

-- قسم التشخيص
local cardDiag = makeCard("🩺 التشخيص")
local diagLabels = {}
local function diagLine(key, text)
    local l = label(cardDiag, text, 14, COLORS.text, false)
    l.Size = UDim2.new(1, 0, 0, 20)
    l.LayoutOrder = nextOrder()
    l.ZIndex = 33
    diagLabels[key] = l
    return l
end
diagLine("myRole", "دورك: —")
diagLine("murderer", "🔪 القاتل: —")
diagLine("sheriff", "🔫 الشريف: —")
diagLine("coins", "🪙 العملات: 0 موجودة / 0 مجموعة")
diagLine("gun", "🔫 المسدس الساقط: لا يوجد")
diagLine("alive", "❤️ الأحياء: —")

-- فتح/إغلاق القائمة بحركة ناعمة
local menuOpen = false
local function setMenu(open)
    menuOpen = open
    if open then
        main.Visible = true
        TweenService:Create(mainScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Scale = 1,
        }):Play()
    else
        local tw = TweenService:Create(mainScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Scale = 0.85,
        })
        tw:Play()
        tw.Completed:Connect(function()
            if not menuOpen then
                main.Visible = false
            end
        end)
    end
end

floatBtn.MouseButton1Click:Connect(function()
    setMenu(not menuOpen)
end)
closeBtn.MouseButton1Click:Connect(function()
    setMenu(false)
end)

-- ============================================================
--  كشف الأدوار + إظهار اللاعبين
-- ============================================================

local espObjects = {} -- [player] = {billboard, textLabel, highlight}

local function clearESP(plr)
    local obj = espObjects[plr]
    if obj then
        if obj.billboard then obj.billboard:Destroy() end
        if obj.highlight then obj.highlight:Destroy() end
        espObjects[plr] = nil
    end
end

local function ensureESP(plr)
    local ch = plr.Character
    if not ch then
        return nil
    end
    local head = ch:FindFirstChild("Head")
    if not head then
        return nil
    end
    local obj = espObjects[plr]
    if obj and obj.billboard and obj.billboard.Parent == head then
        return obj
    end
    clearESP(plr)

    local bb = Instance.new("BillboardGui")
    bb.Name = "AlsadigTag"
    bb.Size = UDim2.new(0, 170, 0, 46)
    bb.StudsOffset = Vector3.new(0, 2.4, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.TextSize = 14
    tl.Font = Enum.Font.GothamBold
    tl.TextStrokeTransparency = 0.3
    tl.Parent = bb

    local hl = Instance.new("Highlight")
    hl.Name = "AlsadigHL"
    hl.FillTransparency = 0.55
    hl.OutlineTransparency = 0.1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = ch

    obj = { billboard = bb, textLabel = tl, highlight = hl }
    espObjects[plr] = obj
    return obj
end

local function refreshESP()
    local myHRP = getHRP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then
            clearESP(plr)
        elseif not (state.roleESP or state.playerESP) then
            clearESP(plr)
        else
            local obj = ensureESP(plr)
            if obj then
                local hrp = getHRP(plr)
                local dist = 0
                if hrp and myHRP then
                    dist = math.floor((hrp.Position - myHRP.Position).Magnitude)
                end
                if state.roleESP then
                    local role = getRole(plr)
                    local info = ROLE_INFO[role]
                    obj.textLabel.Text = info.emoji .. " " .. plr.DisplayName
                        .. "\n" .. info.name .. "  •  " .. dist .. "م"
                    obj.textLabel.TextColor3 = info.color
                    obj.highlight.FillColor = info.color
                    obj.highlight.OutlineColor = info.color
                    obj.highlight.FillTransparency = (role == "Innocent") and 0.7 or 0.45
                    obj.highlight.Enabled = true
                else
                    obj.textLabel.Text = plr.DisplayName .. "\n" .. dist .. "م"
                    obj.textLabel.TextColor3 = COLORS.text
                    obj.highlight.FillColor = COLORS.accent2
                    obj.highlight.OutlineColor = COLORS.accent2
                    obj.highlight.FillTransparency = 0.6
                    obj.highlight.Enabled = true
                end
                obj.billboard.Enabled = true
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(plr)
    clearESP(plr)
end)

-- ============================================================
--  تنبيهات القتل
-- ============================================================

local function watchDeaths(plr)
    local function hook(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Died:Connect(function()
                if state.killAlert and plr ~= LocalPlayer then
                    showToast("💀 مات اللاعب: " .. plr.DisplayName)
                end
            end)
        end
    end
    if plr.Character then
        hook(plr.Character)
    end
    plr.CharacterAdded:Connect(hook)
end

for _, plr in ipairs(Players:GetPlayers()) do
    watchDeaths(plr)
end
Players.PlayerAdded:Connect(watchDeaths)

-- ============================================================
--  تجميع العملات
-- ============================================================

local function coinFarmLoop()
    while true do
        if state.coinFarm and isAlive(LocalPlayer) then
            local hrp = getHRP()
            if hrp then
                local coins = findCoins()
                if #coins == 0 then
                    task.wait(1)
                elseif state.coinsCollected >= 50 then
                    state.coinFarm = false
                    showToast("🪙 امتلأت حقيبة العملات")
                else
                    -- أقرب عملة أولاً
                    table.sort(coins, function(a, b)
                        return (a.Position - hrp.Position).Magnitude
                            < (b.Position - hrp.Position).Magnitude
                    end)
                    local coin = coins[1]
                    hrp.CFrame = CFrame.new(coin.Position + Vector3.new(0, 2, 0))
                    task.wait(state.coinDelay)
                    if coin.Parent == nil then
                        state.coinsCollected = state.coinsCollected + 1
                    end
                end
            else
                task.wait(0.5)
            end
        else
            task.wait(0.5)
        end
    end
end

-- ============================================================
--  التقاط المسدس
-- ============================================================

local lastGunToast = 0
local function gunGrabLoop()
    while true do
        if state.gunGrab and isAlive(LocalPlayer) and not hasTool(LocalPlayer, "Gun") then
            local gun, handle = findDroppedGun()
            if gun and handle then
                local hrp = getHRP()
                if hrp then
                    if tick() - lastGunToast > 5 then
                        lastGunToast = tick()
                        showToast("🔫 سقط المسدس! جارٍ الالتقاط...")
                    end
                    hrp.CFrame = CFrame.new(handle.Position + Vector3.new(0, 2, 0))
                    task.wait(0.3)
                end
            else
                task.wait(0.25)
            end
        else
            task.wait(0.5)
        end
    end
end

-- ============================================================
--  المشاهدة
-- ============================================================

function spectateNext()
    local targets = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            table.insert(targets, plr)
        end
    end
    if #targets == 0 then
        showToast("👁️ لا يوجد لاعب للمشاهدة")
        return
    end
    state.spectateIndex = state.spectateIndex + 1
    if state.spectateIndex > #targets then
        state.spectateIndex = 1
    end
    local target = targets[state.spectateIndex]
    local hum = getHum(target)
    if hum then
        Camera.CameraSubject = hum
        state.spectating = true
        showToast("👁️ تشاهد: " .. target.DisplayName)
    end
end

function stopSpectate()
    local hum = getHum()
    if hum then
        Camera.CameraSubject = hum
    end
    state.spectating = false
    state.spectateIndex = 0
end

-- ============================================================
--  حماية: ضد الطرد وضد القذف (مثل الهب)
-- ============================================================

pcall(function()
    if hookmetamethod and getnamecallmethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" and self == LocalPlayer then
                return nil
            end
            return oldNamecall(self, ...)
        end)
    end
end)

RunService.Heartbeat:Connect(function()
    local hrp = getHRP()
    if hrp and hrp.AssemblyLinearVelocity.Magnitude > 150 then
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end)

-- إعادة تطبيق السرعة وتصفير العملات عند كل ظهور جديد (جولة جديدة)
LocalPlayer.CharacterAdded:Connect(function(char)
    state.coinsCollected = 0
    stopSpectate()
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and state.speedOn then
        hum.WalkSpeed = state.speedValue
    end
end)

-- ============================================================
--  تحديث قائمة الأدوار والتشخيص
-- ============================================================

local function refreshRoleList()
    for _, child in ipairs(roleListFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    local myHRP = getHRP()
    local idx = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        idx = idx + 1
        local role = getRole(plr)
        local info = ROLE_INFO[role]
        local hrp = getHRP(plr)
        local dist = ""
        if hrp and myHRP and plr ~= LocalPlayer then
            dist = "  •  " .. math.floor((hrp.Position - myHRP.Position).Magnitude) .. "م"
        end
        local dead = isAlive(plr) and "" or "  💀"
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 20)
        l.BackgroundTransparency = 1
        l.Text = info.emoji .. " " .. plr.DisplayName .. " — " .. info.name .. dist .. dead
        l.TextColor3 = info.color
        l.TextSize = 14
        l.Font = Enum.Font.GothamBold
        l.TextXAlignment = Enum.TextXAlignment.Right
        l.LayoutOrder = idx
        l.ZIndex = 34
        l.Parent = roleListFrame
    end
end

local function refreshDiag()
    local myRole = getRole(LocalPlayer)
    diagLabels.myRole.Text = "دورك: " .. ROLE_INFO[myRole].emoji .. " " .. ROLE_INFO[myRole].name

    local mur = findByRole("Murderer")
    diagLabels.murderer.Text = "🔪 القاتل: " .. (mur and mur.DisplayName or "غير معروف بعد")

    local shr = findByRole("Sheriff")
    diagLabels.sheriff.Text = "🔫 الشريف: " .. (shr and shr.DisplayName or "غير معروف بعد")

    local coins = findCoins()
    diagLabels.coins.Text = "🪙 العملات: " .. #coins .. " موجودة / " .. state.coinsCollected .. " مجموعة"

    local gun = findDroppedGun()
    diagLabels.gun.Text = "🔫 المسدس الساقط: " .. (gun and "موجود في الأرض!" or "لا يوجد")

    diagLabels.alive.Text = "❤️ الأحياء: " .. countAlive() .. " / " .. #Players:GetPlayers()
end

-- ============================================================
--  حلقات التشغيل
-- ============================================================

task.spawn(function()
    while true do
        pcall(refreshESP)
        task.wait(0.25)
    end
end)

task.spawn(function()
    while true do
        pcall(refreshRoleList)
        pcall(refreshDiag)
        task.wait(1)
    end
end)

task.spawn(coinFarmLoop)
task.spawn(gunGrabLoop)

showToast("🔪 سكربت الصادق — الغموض جاهز! اضغط الزر لفتح القائمة")
