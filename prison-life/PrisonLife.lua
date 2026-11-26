-- ============================================================
--  ⛓️ سكربت الصادق — حياة السجن (Alsadig Prison Life)
--  سكربت Prison Life لدلتا موبايل — تطوير الصادق
-- ============================================================
--  المميزات:
--   • كشف اللاعبين (ESP) بألوان الفرق: أزرق حراس، برتقالي سجناء، أحمر مجرمين
--   • كشف الأسلحة والأدوات في العالم (مسدسات، سكاكين، مطارق، بطاقات)
--   • انتقال فوري: قاعدة المجرمين، الساحة، المجاري، مخزن الأسلحة، الزنازين
--   • زر هروب: ينقلك لقاعدة المجرمين فتصبح مجرماً
--   • سايلنت إيم للأسلحة النارية: دائرة تصويب + نسبة إصابة + قائمة استثناء
--   • مساعدة قتال قريب (سكين/مطرقة): توجيه الضربة لأقرب عدو
--   • طيران، عبور جدران، سرعة وقفز، وضع عدم الموت، حماية من الطرد والقذف
-- ============================================================
--  ⚠️ حدود صريحة:
--   • لا فلوس ولا أسلحة مجانية ولا تلفيل — كلها في سيرفر اللعبة.
--     كشف الأسلحة يُريك أين الأسلحة فقط، لا يخلقها.
--   • السايلنت إيم يعتمد على نظام أسلحة اللعبة؛ قد لا يعمل في كل الحالات.
--   • السكربت لا يطلق النار وحده أبداً — يحوّل طلقاتك أنت فقط إلى الرأس.
--   • وضع عدم الموت من طرفك فقط؛ ضرر السيرفر قد يقتلك رغم ذلك.
--   • أهداف الانتقال تُبحث بالاسم؛ إن غيّرت اللعبة أسماء الأجزاء قد يفشل زر.
--   • تم التحقق من سلامة الكود فقط؛ لم يُجرَّب داخل روبلوكس بعد.
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ================= الإعدادات =================
local S = {
    playerESP = false,
    weaponESP = false,
    silentAim = false,
    aimMethod = "Remote",       -- Remote / Camera / Mouse
    aimFov = 180,
    aimRange = 500,
    hitChance = 100,
    ignoreTeam = true,
    meleeAssist = false,
    fly = false,
    flySpeed = 50,
    noclip = false,
    speedBoost = false,
    walkSpeed = 32,
    jumpPower = 75,
    godMode = false,
    antiKick = true,
    antiFling = false,
    excluded = {},              -- [اسم اللاعب] = true
    lastTeleport = "—",
}

local hooksInstalled = false
local mouseHookInstalled = false
local currentTarget = nil
local currentTargetPart = nil
local hitRoll = true
local lastRollTime = 0

-- ================= أدوات مساعدة =================
local function getChar(plr)
    plr = plr or LocalPlayer
    return plr and plr.Character
end

local function getHRP(plr)
    local c = getChar(plr)
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(plr)
    local c = getChar(plr)
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function isAlive(plr)
    local h = getHumanoid(plr)
    return h and h.Health > 0
end

-- نوع الفريق: Guard / Inmate / Criminal / Neutral
local function teamKind(plr)
    if not plr then return "Neutral" end
    local t = plr.Team
    if t then
        local n = string.lower(t.Name)
        if string.find(n, "guard", 1, true) then return "Guard" end
        if string.find(n, "inmate", 1, true) or string.find(n, "prisoner", 1, true) then return "Inmate" end
        if string.find(n, "criminal", 1, true) then return "Criminal" end
    end
    return "Neutral"
end

local TEAM_AR = {Guard = "حارس", Inmate = "سجين", Criminal = "مجرم", Neutral = "محايد"}
local TEAM_COLOR = {
    Guard = Color3.fromRGB(60, 140, 255),
    Inmate = Color3.fromRGB(255, 140, 40),
    Criminal = Color3.fromRGB(255, 60, 60),
    Neutral = Color3.fromRGB(180, 180, 180),
}

local function isEnemy(plr)
    if not plr or plr == LocalPlayer then return false end
    if S.excluded[plr.Name] then return false end
    local myKind = teamKind(LocalPlayer)
    local theirKind = teamKind(plr)
    if theirKind == "Neutral" then return false end
    if S.ignoreTeam and myKind == theirKind then return false end
    return true
end

local function aimPartOf(plr)
    local c = getChar(plr)
    if not c then return nil end
    return c:FindFirstChild("Head")
        or c:FindFirstChild("HumanoidRootPart")
        or c:FindFirstChild("UpperTorso")
        or c:FindFirstChild("Torso")
end

local function distanceTo(plr)
    local myHRP, theirHRP = getHRP(), getHRP(plr)
    if not myHRP or not theirHRP then return math.huge end
    return (myHRP.Position - theirHRP.Position).Magnitude
end

-- تنبيهات (Toast) — تُعرَّف فعلياً بعد بناء الواجهة
local toastLabel = nil
local toastUntil = 0
local function toast(msg)
    if toastLabel then
        toastLabel.Text = msg
        toastLabel.Visible = true
        toastUntil = os.clock() + 2.5
    end
end

-- ================= الواجهة =================
local guiParent = nil
pcall(function()
    if gethui then guiParent = gethui() end
end)
if not guiParent then
    pcall(function() guiParent = game:GetService("CoreGui") end)
end
if not guiParent then guiParent = LocalPlayer:WaitForChild("PlayerGui") end

-- ألوان التصميم: سجن — رمادي داكن + برتقالي سجناء
local C_BG = Color3.fromRGB(26, 28, 34)
local C_CARD = Color3.fromRGB(38, 41, 50)
local C_CARD2 = Color3.fromRGB(46, 50, 61)
local C_ORANGE = Color3.fromRGB(255, 140, 40)
local C_BLUE = Color3.fromRGB(60, 140, 255)
local C_TEXT = Color3.fromRGB(240, 242, 245)
local C_MUTED = Color3.fromRGB(160, 166, 178)
local C_OFF = Color3.fromRGB(90, 95, 108)

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function makeLabel(parent, text, size, color, bold)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = size or 14
    l.TextColor3 = color or C_TEXT
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AlsadigPrisonLife"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

-- زر عائم ⛓️
local floatBtn = Instance.new("TextButton")
floatBtn.Name = "FloatBtn"
floatBtn.Size = UDim2.new(0, 58, 0, 58)
floatBtn.Position = UDim2.new(0, 16, 0.5, -29)
floatBtn.BackgroundColor3 = C_ORANGE
floatBtn.Text = "⛓️"
floatBtn.TextSize = 26
floatBtn.AutoButtonColor = true
floatBtn.Parent = screenGui
corner(floatBtn, 29)
local floatStroke = Instance.new("UIStroke")
floatStroke.Color = C_BG
floatStroke.Thickness = 2
floatStroke.Parent = floatBtn

-- النافذة الرئيسية
local window = Instance.new("Frame")
window.Name = "MainWindow"
window.Size = UDim2.new(0, 340, 0, 480)
window.Position = UDim2.new(0.5, -170, 0.5, -240)
window.BackgroundColor3 = C_BG
window.BorderSizePixel = 0
window.Visible = false
window.Parent = screenGui
corner(window, 16)
local winStroke = Instance.new("UIStroke")
winStroke.Color = C_ORANGE
winStroke.Thickness = 1.5
winStroke.Transparency = 0.4
winStroke.Parent = window
local winScale = Instance.new("UIScale")
winScale.Parent = window

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 64)
header.BackgroundColor3 = C_CARD
header.BorderSizePixel = 0
header.Parent = window
corner(header, 16)

local title = makeLabel(header, "⛓️ سكربت الصادق — حياة السجن", 17, C_TEXT, true)
title.Size = UDim2.new(1, -60, 0, 26)
title.Position = UDim2.new(0, 14, 0, 8)

local subtitle = makeLabel(header, "Prison Life  •  تطوير الصادق", 12, C_ORANGE, false)
subtitle.Size = UDim2.new(1, -60, 0, 20)
subtitle.Position = UDim2.new(0, 14, 0, 36)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -48, 0, 14)
closeBtn.BackgroundColor3 = C_CARD2
closeBtn.Text = "✕"
closeBtn.TextSize = 16
closeBtn.TextColor3 = C_TEXT
closeBtn.Parent = header
corner(closeBtn, 10)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -16, 1, -80)
content.Position = UDim2.new(0, 8, 0, 72)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = C_ORANGE
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = window
local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 10)
contentLayout.Parent = content

-- شريط تنبيه
toastLabel = Instance.new("TextLabel")
toastLabel.Size = UDim2.new(0, 300, 0, 40)
toastLabel.Position = UDim2.new(0.5, -150, 0, 70)
toastLabel.BackgroundColor3 = C_CARD
toastLabel.TextColor3 = C_TEXT
toastLabel.TextSize = 14
toastLabel.Font = Enum.Font.GothamBold
toastLabel.Visible = false
toastLabel.Parent = screenGui
corner(toastLabel, 10)
local toastStroke = Instance.new("UIStroke")
toastStroke.Color = C_ORANGE
toastStroke.Thickness = 1
toastStroke.Parent = toastLabel

-- دائرة التصويب (FOV)
local fovCircle = Instance.new("Frame")
fovCircle.Name = "FovCircle"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundColor3 = C_ORANGE
fovCircle.BackgroundTransparency = 0.92
fovCircle.BorderSizePixel = 0
fovCircle.Visible = false
fovCircle.Parent = screenGui
corner(fovCircle, 999)
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = C_ORANGE
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.25
fovStroke.Parent = fovCircle

local function updateFovCircle()
    local vp = Camera.ViewportSize
    local d = math.min(S.aimFov * 2, math.min(vp.X, vp.Y) * 0.96)
    fovCircle.Size = UDim2.new(0, d, 0, d)
    fovCircle.Visible = S.silentAim
end

-- ===== أدوات بناء عناصر الواجهة =====
local function makeSection(titleText)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = C_CARD
    card.BorderSizePixel = 0
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.Size = UDim2.new(1, 0, 0, 0)
    card.Parent = content
    corner(card, 12)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.Parent = card
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = card
    local head = makeLabel(card, titleText, 15, C_ORANGE, true)
    head.Size = UDim2.new(1, 0, 0, 22)
    return card
end

local function makeToggle(parent, text, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundTransparency = 1
    row.Parent = parent
    local lbl = makeLabel(row, text, 14, C_TEXT, false)
    lbl.Size = UDim2.new(1, -60, 1, 0)
    local pill = Instance.new("TextButton")
    pill.Size = UDim2.new(0, 48, 0, 26)
    pill.Position = UDim2.new(1, -48, 0.5, -13)
    pill.Text = ""
    pill.AutoButtonColor = false
    pill.Parent = row
    corner(pill, 13)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = pill
    corner(knob, 10)
    local state = default and true or false
    local function refresh()
        pill.BackgroundColor3 = state and C_ORANGE or C_OFF
        knob.Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    end
    refresh()
    pill.MouseButton1Click:Connect(function()
        state = not state
        refresh()
        if callback then callback(state) end
    end)
    return {
        set = function(v) state = v and true or false; refresh() end,
        get = function() return state end,
    }
end

local function makeButton(parent, text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = color or C_CARD2
    btn.Text = text
    btn.TextSize = 14
    btn.TextColor3 = C_TEXT
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = true
    btn.Parent = parent
    corner(btn, 10)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

local function makeCycle(parent, text, options, defaultIdx, callback)
    local idx = defaultIdx or 1
    local btn = makeButton(parent, "", function()
        idx = idx % #options + 1
        btn.Text = text .. ": " .. tostring(options[idx])
        if callback then callback(options[idx], idx) end
    end)
    btn.Text = text .. ": " .. tostring(options[idx])
    return btn
end

local function makeInfo(parent, text)
    local l = makeLabel(parent, text, 13, C_MUTED, false)
    l.Size = UDim2.new(1, 0, 0, 20)
    l.TextWrapped = true
    return l
end

-- سحب العناصر
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
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
makeDraggable(floatBtn)
makeDraggable(window, header)

-- فتح/إغلاق النافذة
local windowOpen = false
local function setWindow(open)
    windowOpen = open
    if open then
        window.Visible = true
        winScale.Scale = 0.85
        local tw = game:GetService("TweenService"):Create(winScale,
            TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Scale = 1})
        tw:Play()
    else
        local tw = game:GetService("TweenService"):Create(winScale,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Scale = 0.85})
        tw:Play()
        tw.Completed:Connect(function()
            if not windowOpen then window.Visible = false end
        end)
    end
end
floatBtn.MouseButton1Click:Connect(function() setWindow(not windowOpen) end)
closeBtn.MouseButton1Click:Connect(function() setWindow(false) end)

-- ================= كشف اللاعبين (Player ESP) =================
local playerTags = {}   -- [Player] = {highlight, billboard, label}
local espPlayerCount = 0

local function clearPlayerTag(plr)
    local t = playerTags[plr]
    if t then
        if t.highlight then t.highlight:Destroy() end
        if t.billboard then t.billboard:Destroy() end
        playerTags[plr] = nil
    end
end

local function updatePlayerESP()
    espPlayerCount = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = getChar(plr)
            local head = char and char:FindFirstChild("Head")
            if S.playerESP and char and head and isAlive(plr) then
                local t = playerTags[plr]
                if not t then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = 0.55
                    hl.OutlineTransparency = 0.1
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = char
                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.new(0, 180, 0, 44)
                    bb.StudsOffset = Vector3.new(0, 2.6, 0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = head
                    bb.Parent = head
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextSize = 13
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextStrokeTransparency = 0.4
                    lbl.Parent = bb
                    t = {highlight = hl, billboard = bb, label = lbl}
                    playerTags[plr] = t
                end
                local kind = teamKind(plr)
                local col = TEAM_COLOR[kind]
                t.highlight.FillColor = col
                t.highlight.OutlineColor = col
                local hum = getHumanoid(plr)
                local hp = hum and math.floor(hum.Health) or 0
                local dist = math.floor(distanceTo(plr))
                t.label.TextColor3 = col
                t.label.Text = plr.DisplayName .. " [" .. TEAM_AR[kind] .. "]\n❤️ " .. hp .. "  •  📏 " .. dist
                espPlayerCount = espPlayerCount + 1
            else
                clearPlayerTag(plr)
            end
        end
    end
    -- تنظيف من غادروا
    for plr in pairs(playerTags) do
        if not plr.Parent then clearPlayerTag(plr) end
    end
end

Players.PlayerRemoving:Connect(clearPlayerTag)

-- ================= كشف الأسلحة (Weapon ESP) =================
local WEAPON_KEYWORDS = {
    "m9", "mp5", "remington", "ak-47", "ak47", "fal", "m4a1", "revolver",
    "m700", "taser", "crude knife", "knife", "hammer", "keycard", "c4",
    "shiv", "gun", "pistol", "rifle", "shotgun", "sniper",
}
local WEAPON_AR = {
    ["m9"] = "مسدس M9", ["mp5"] = "رشاش MP5", ["remington"] = "شوتقن Remington",
    ["ak-47"] = "كلاشنكوف AK-47", ["ak47"] = "كلاشنكوف AK-47", ["fal"] = "بندقية FAL",
    ["m4a1"] = "بندقية M4A1", ["revolver"] = "مسدس Revolver", ["m700"] = "قناص M700",
    ["taser"] = "صاعق", ["crude knife"] = "سكين", ["knife"] = "سكين",
    ["hammer"] = "مطرقة", ["keycard"] = "بطاقة مفتاح", ["c4"] = "متفجرات C4",
    ["shiv"] = "سكين", ["gun"] = "سلاح", ["pistol"] = "مسدس",
    ["rifle"] = "بندقية", ["shotgun"] = "شوتقن", ["sniper"] = "قناص",
}

local weaponTags = {}   -- [Instance] = {highlight, billboard}
local worldWeapons = {} -- قائمة آخر مسح (لأقرب سلاح)
local espWeaponCount = 0

local function weaponKindOf(inst)
    local n = string.lower(inst.Name)
    for _, kw in ipairs(WEAPON_KEYWORDS) do
        if string.find(n, kw, 1, true) then
            return WEAPON_AR[kw] or inst.Name
        end
    end
    return nil
end

local function isInPlayerInventory(inst)
    local p = inst.Parent
    while p do
        if p:IsA("Backpack") then return true end
        local plr = Players:GetPlayerFromCharacter(p)
        if plr then return true end
        p = p.Parent
    end
    return false
end

local function partOf(inst)
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") or inst:IsA("Tool") then
        return inst:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

local function posOf(inst)
    if inst:IsA("BasePart") then return inst.Position end
    if inst:IsA("Model") or inst:IsA("Tool") then
        local ok, piv = pcall(function() return inst:GetPivot() end)
        if ok and piv then return piv.Position end
        local part = partOf(inst)
        if part then return part.Position end
    end
    return nil
end

local function scanWeapons()
    worldWeapons = {}
    local seen = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Tool") or obj:IsA("Model") or obj:IsA("BasePart")) then
            local kind = weaponKindOf(obj)
            if kind and not isInPlayerInventory(obj) then
                local pos = posOf(obj)
                if pos and not seen[obj] then
                    seen[obj] = true
                    table.insert(worldWeapons, {inst = obj, kind = kind, pos = pos})
                    if #worldWeapons >= 60 then break end
                end
            end
        end
    end
    return worldWeapons
end

local function clearWeaponTag(inst)
    local t = weaponTags[inst]
    if t then
        if t.highlight then t.highlight:Destroy() end
        if t.billboard then t.billboard:Destroy() end
        weaponTags[inst] = nil
    end
end

local function updateWeaponESP()
    espWeaponCount = 0
    if not S.weaponESP then
        for inst in pairs(weaponTags) do clearWeaponTag(inst) end
        return
    end
    local found = {}
    for _, w in ipairs(worldWeapons) do
        local inst = w.inst
        if inst.Parent then
            found[inst] = true
            local part = partOf(inst)
            if part then
                local t = weaponTags[inst]
                if not t then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = C_ORANGE
                    hl.OutlineColor = C_ORANGE
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0.1
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = inst
                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.new(0, 150, 0, 36)
                    bb.StudsOffset = Vector3.new(0, 1.4, 0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = part
                    bb.Parent = part
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextSize = 12
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextColor3 = C_ORANGE
                    lbl.TextStrokeTransparency = 0.4
                    lbl.Parent = bb
                    t = {highlight = hl, billboard = bb, label = lbl}
                    weaponTags[inst] = t
                end
                local myHRP = getHRP()
                local dist = myHRP and math.floor((myHRP.Position - w.pos).Magnitude) or 0
                t.label.Text = "🔫 " .. w.kind .. "\n📏 " .. dist
                espWeaponCount = espWeaponCount + 1
            end
        end
    end
    for inst in pairs(weaponTags) do
        if not found[inst] then clearWeaponTag(inst) end
    end
end

-- ================= السايلنت إيم =================
local function rollHit()
    local now = os.clock()
    if now - lastRollTime >= 0.15 then
        lastRollTime = now
        hitRoll = math.random(1, 100) <= S.hitChance
    end
    return hitRoll
end

local function pickTarget()
    currentTarget = nil
    currentTargetPart = nil
    if not S.silentAim then return end
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local bestDist = math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and isAlive(plr) then
            local part = aimPartOf(plr)
            if part then
                local dist = distanceTo(plr)
                if dist <= S.aimRange then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d2 = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if d2 <= S.aimFov and d2 < bestDist then
                            bestDist = d2
                            currentTarget = plr
                            currentTargetPart = part
                        end
                    end
                end
            end
        end
    end
end

local function holdingTool()
    local c = getChar()
    if not c then return nil end
    return c:FindFirstChildOfClass("Tool")
end

-- إعادة كتابة وسيط واحد نحو الهدف
local function rewriteArg(v, targetPos, depth)
    depth = depth or 0
    if typeof(v) == "Vector3" then
        if v.Magnitude > 2 then return targetPos end
        return v
    elseif typeof(v) == "CFrame" then
        return CFrame.new(targetPos)
    elseif typeof(v) == "Instance" and v:IsA("BasePart") then
        local plr = Players:GetPlayerFromCharacter(v.Parent)
        if plr and plr ~= LocalPlayer and currentTargetPart then
            return currentTargetPart
        end
        return v
    elseif typeof(v) == "table" and depth < 2 then
        local out = {}
        for k, val in pairs(v) do
            out[k] = rewriteArg(val, targetPos, depth + 1)
        end
        return out
    end
    return v
end

local function installHooks()
    if hooksInstalled then return end
    hooksInstalled = true
    if not hookmetamethod then return end

    -- هوك __namecall: منع الطرد + إعادة توجيه الريموت
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod and getnamecallmethod() or ""
            -- منع الطرد
            if S.antiKick and method == "Kick" and self == LocalPlayer then
                return nil
            end
            -- إعادة توجيه الطلقات (ريموت)
            if S.silentAim and S.aimMethod == "Remote"
                and (method == "FireServer" or method == "InvokeServer")
                and currentTargetPart and holdingTool() and rollHit() then
                local args = {...}
                local targetPos = currentTargetPart.Position
                for i, a in ipairs(args) do
                    args[i] = rewriteArg(a, targetPos, 0)
                end
                return oldNamecall(self, unpack(args))
            end
            return oldNamecall(self, ...)
        end)
    end)
end

local function installMouseHook()
    if mouseHookInstalled then return end
    mouseHookInstalled = true
    if not hookmetamethod then return end
    pcall(function()
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", function(self, key)
            if S.silentAim and S.aimMethod == "Mouse" and self == Mouse
                and currentTargetPart and holdingTool() and rollHit() then
                if key == "Hit" then
                    return CFrame.new(currentTargetPart.Position)
                elseif key == "Target" then
                    return currentTargetPart
                end
            end
            return oldIndex(self, key)
        end)
    end)
end

-- طريقة الكاميرا عند الإطلاق: توجيه الكاميرا للهدف لحظة تفعيل السلاح
local cameraAimBound = false
local function bindCameraAim()
    if cameraAimBound then return end
    cameraAimBound = true
    local function hookChar(char)
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                child.Activated:Connect(function()
                    if S.silentAim and S.aimMethod == "Camera"
                        and currentTargetPart and rollHit() then
                        local camPos = Camera.CFrame.Position
                        Camera.CFrame = CFrame.lookAt(camPos, currentTargetPart.Position)
                    end
                end)
            end
        end)
    end
    if LocalPlayer.Character then hookChar(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(hookChar)
end

-- ================= مساعدة القتال القريب =================
local MELEE_KEYWORDS = {"knife", "shiv", "hammer", "crude"}
local function isMeleeTool(tool)
    if not tool then return false end
    local n = string.lower(tool.Name)
    for _, kw in ipairs(MELEE_KEYWORDS) do
        if string.find(n, kw, 1, true) then return true end
    end
    return false
end

local meleeBound = false
local function bindMeleeAssist()
    if meleeBound then return end
    meleeBound = true
    local function hookChar(char)
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                child.Activated:Connect(function()
                    if not S.meleeAssist then return end
                    if not isMeleeTool(child) then return end
                    local myHRP = getHRP()
                    if not myHRP then return end
                    -- أقرب عدو ضمن 14 ستود
                    local best, bestD = nil, 14
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if isEnemy(plr) and isAlive(plr) then
                            local d = distanceTo(plr)
                            if d < bestD then best, bestD = plr, d end
                        end
                    end
                    if best then
                        local tHRP = getHRP(best)
                        if tHRP then
                            -- توجيه الشخصية نحو العدو حتى تصل الضربة
                            local look = Vector3.new(tHRP.Position.X, myHRP.Position.Y, tHRP.Position.Z)
                            myHRP.CFrame = CFrame.lookAt(myHRP.Position, look)
                        end
                    end
                end)
            end
        end)
    end
    if LocalPlayer.Character then hookChar(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(hookChar)
end

-- ================= الحركة: طيران / عبور / سرعة =================
local flyBV, flyBG = nil, nil
local flyUp, flyDown = false, false

local function setFly(on)
    S.fly = on
    local hrp = getHRP()
    if on and hrp then
        if not flyBV then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            flyBV.Velocity = Vector3.zero
            flyBV.Parent = hrp
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
            flyBG.P = 1e4
            flyBG.Parent = hrp
        end
    else
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
    end
end

local function updateFly()
    if not S.fly then return end
    local hrp = getHRP()
    local hum = getHumanoid()
    if not hrp or not hum then return end
    if not flyBV or flyBV.Parent ~= hrp then
        setFly(false)
        setFly(true)
        if not flyBV then return end
    end
    local camCF = Camera.CFrame
    local move = hum.MoveDirection
    local vel = Vector3.zero
    if move.Magnitude > 0.05 then
        -- اتجاه الحركة نسبة للكاميرا (أفقي)
        local fwd = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
        local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
        -- MoveDirection أصلاً عالمي؛ نستخدمه مباشرة
        vel = move * S.flySpeed
        if fwd.Magnitude == 0 then vel = move * S.flySpeed end
        if right.Magnitude == 0 then vel = move * S.flySpeed end
    end
    local vert = 0
    if flyUp then vert = vert + S.flySpeed end
    if flyDown then vert = vert - S.flySpeed end
    flyBV.Velocity = Vector3.new(vel.X, vert, vel.Z)
    flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z))
end

-- أزرار الطيران ▲▼
local flyBtns = Instance.new("Frame")
flyBtns.Size = UDim2.new(0, 52, 0, 116)
flyBtns.Position = UDim2.new(1, -68, 0.5, -58)
flyBtns.BackgroundTransparency = 1
flyBtns.Visible = false
flyBtns.Parent = screenGui
local function flyHoldBtn(text, y, setter)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 52, 0, 52)
    b.Position = UDim2.new(0, 0, 0, y)
    b.BackgroundColor3 = C_CARD
    b.Text = text
    b.TextSize = 20
    b.TextColor3 = C_ORANGE
    b.Parent = flyBtns
    corner(b, 26)
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            setter(true)
        end
    end)
    b.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            setter(false)
        end
    end)
    return b
end
flyHoldBtn("▲", 0, function(v) flyUp = v end)
flyHoldBtn("▼", 60, function(v) flyDown = v end)

local function updateNoclip()
    if not S.noclip then return end
    local c = getChar()
    if not c then return end
    for _, part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function updateSpeed()
    local hum = getHumanoid()
    if not hum then return end
    if S.speedBoost then
        hum.WalkSpeed = S.walkSpeed
        hum.UseJumpPower = true
        hum.JumpPower = S.jumpPower
    end
end

-- ================= الحماية: عدم الموت / ضد القذف =================
local godConn = nil
local function bindGodMode()
    if godConn then godConn:Disconnect(); godConn = nil end
    local hum = getHumanoid()
    if hum then
        godConn = hum.HealthChanged:Connect(function()
            if S.godMode and hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
    end
end

local function updateGod()
    if not S.godMode then return end
    local hum = getHumanoid()
    if hum and hum.Health < hum.MaxHealth then
        hum.Health = hum.MaxHealth
    end
end

local function updateAntiFling()
    if not S.antiFling then return end
    local hrp = getHRP()
    if hrp and hrp.AssemblyLinearVelocity.Magnitude > 160 then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    bindGodMode()
    if S.fly then setFly(true) end
end)

-- ================= الانتقال الفوري =================
local function findPlace(keywords)
    local best, bestScore = nil, -1
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n = string.lower(obj.Name)
            for _, kw in ipairs(keywords) do
                if string.find(n, kw, 1, true) then
                    local score = 0
                    if obj:IsA("SpawnLocation") then score = score + 10 end
                    if obj:IsA("Model") then score = score + 3 end
                    if obj:IsA("BasePart") then score = score + math.min(obj.Size.Magnitude / 10, 5) end
                    if score > bestScore then
                        best, bestScore = obj, score
                    end
                    break
                end
            end
        end
    end
    return best
end

local function teleportTo(pos, label)
    local hrp = getHRP()
    if not hrp then
        toast("⚠️ لا توجد شخصية الآن")
        S.lastTeleport = label .. ": فشل (لا شخصية)"
        return false
    end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
    S.lastTeleport = label .. ": تم ✓"
    toast("✅ انتقلت إلى: " .. label)
    return true
end

local function teleportToPlace(keywords, label)
    local obj = findPlace(keywords)
    if not obj then
        toast("⚠️ " .. label .. " غير موجود")
        S.lastTeleport = label .. ": غير موجود"
        return
    end
    local pos = posOf(obj)
    if pos then
        teleportTo(pos, label)
    else
        toast("⚠️ تعذر تحديد موقع " .. label)
        S.lastTeleport = label .. ": تعذر الموقع"
    end
end

local function teleportToNearestGun()
    if #worldWeapons == 0 then scanWeapons() end
    local myHRP = getHRP()
    if not myHRP then return end
    local best, bestD = nil, math.huge
    for _, w in ipairs(worldWeapons) do
        local d = (myHRP.Position - w.pos).Magnitude
        if d < bestD then best, bestD = w, d end
    end
    if best then
        teleportTo(best.pos, "أقرب سلاح (" .. best.kind .. ")")
    else
        toast("⚠️ لم يُعثر على أي سلاح")
        S.lastTeleport = "أقرب سلاح: غير موجود"
    end
end

local function teleportToNearestPlayer()
    local best, bestD = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            local d = distanceTo(plr)
            if d < bestD then best, bestD = plr, d end
        end
    end
    if best then
        local tHRP = getHRP(best)
        if tHRP then
            teleportTo(tHRP.Position, "أقرب لاعب (" .. best.DisplayName .. ")")
        end
    else
        toast("⚠️ لا يوجد لاعبون آخرون")
        S.lastTeleport = "أقرب لاعب: غير موجود"
    end
end

local function autoEscape()
    local before = teamKind(LocalPlayer)
    teleportToPlace({"warehouse", "criminal"}, "قاعدة المجرمين")
    task.delay(1.2, function()
        local after = teamKind(LocalPlayer)
        if after == "Criminal" and before ~= "Criminal" then
            toast("🎉 هربت! أنت الآن مجرم")
        elseif after == "Criminal" then
            toast("✅ أنت في قاعدة المجرمين")
        else
            toast("ℹ️ انتقلت — إن لم يتغير فريقك جرّب الخروج من حدود السجن")
        end
    end)
end

-- ================= بناء أقسام الواجهة =================
-- قسم السايلنت إيم
local secAim = makeSection("🎯 السايلنت إيم (للأسلحة النارية)")
makeToggle(secAim, "تفعيل السايلنت إيم", false, function(v)
    S.silentAim = v
    if v then
        installHooks()
        installMouseHook()
        bindCameraAim()
    end
    updateFovCircle()
    toast(v and "🎯 السايلنت إيم: يعمل" or "🎯 السايلنت إيم: متوقف")
end)
makeCycle(secAim, "الطريقة", {"Remote", "Camera", "Mouse"}, 1, function(v)
    S.aimMethod = v
    installHooks()
    installMouseHook()
    bindCameraAim()
end)
makeInfo(secAim, "على الهاتف: Remote أولاً، ثم Camera. Mouse الأضعف.")
makeCycle(secAim, "حجم الدائرة", {90, 140, 180, 240, 320}, 3, function(v)
    S.aimFov = v
    updateFovCircle()
end)
makeCycle(secAim, "نسبة الإصابة", {100, 75, 50, 25}, 1, function(v)
    S.hitChance = v
end)
makeCycle(secAim, "المدى (ستود)", {200, 500, 1000, 1500}, 2, function(v)
    S.aimRange = v
end)
makeToggle(secAim, "🛡️ تجاهل فريقي", true, function(v)
    S.ignoreTeam = v
end)
makeToggle(secAim, "🔪 مساعدة القتال القريب", false, function(v)
    S.meleeAssist = v
    if v then bindMeleeAssist() end
end)

-- قائمة الاستثناء
local exclInfo = makeInfo(secAim, "قائمة الاستثناء: اضغط اسم لاعب لاستثنائه من التصويب")
local exclList = Instance.new("Frame")
exclList.Size = UDim2.new(1, 0, 0, 0)
exclList.AutomaticSize = Enum.AutomaticSize.Y
exclList.BackgroundTransparency = 1
exclList.Parent = secAim
local exclLayout = Instance.new("UIListLayout")
exclLayout.Padding = UDim.new(0, 4)
exclLayout.Parent = exclList

local function refreshExclusionList()
    for _, ch in ipairs(exclList:GetChildren()) do
        if ch:IsA("TextButton") then ch:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local excluded = S.excluded[plr.Name]
            local b = makeButton(exclList,
                (excluded and "🚫 " or "✅ ") .. plr.DisplayName .. " [" .. TEAM_AR[teamKind(plr)] .. "]",
                function()
                    S.excluded[plr.Name] = not S.excluded[plr.Name] or nil
                    refreshExclusionList()
                end,
                excluded and Color3.fromRGB(120, 45, 45) or C_CARD2)
            b.Size = UDim2.new(1, 0, 0, 32)
            b.TextSize = 13
        end
    end
    local count = 0
    for _ in pairs(S.excluded) do count = count + 1 end
    exclInfo.Text = "المستثنون من التصويب: " .. count .. " — اضغط اسماً للتبديل"
end
makeButton(secAim, "🧹 مسح قائمة الاستثناء", function()
    S.excluded = {}
    refreshExclusionList()
    toast("🧹 تم مسح الاستثناءات")
end)

-- قسم الكشف
local secESP = makeSection("👁️ الكشف (ESP)")
makeToggle(secESP, "كشف اللاعبين", false, function(v)
    S.playerESP = v
    if not v then
        for plr in pairs(playerTags) do clearPlayerTag(plr) end
    end
end)
makeToggle(secESP, "كشف الأسلحة والأدوات", false, function(v)
    S.weaponESP = v
    if v then scanWeapons() end
end)
makeInfo(secESP, "أزرق = حراس • برتقالي = سجناء • أحمر = مجرمون")

-- قسم الانتقال
local secTP = makeSection("🗺️ الانتقال الفوري")
makeButton(secTP, "🏃 هروب! (إلى قاعدة المجرمين)", function() autoEscape() end, C_ORANGE)
makeButton(secTP, "🏭 قاعدة المجرمين (المستودع)", function()
    teleportToPlace({"warehouse", "criminal"}, "قاعدة المجرمين")
end)
makeButton(secTP, "🏟️ ساحة السجن", function()
    teleportToPlace({"yard"}, "ساحة السجن")
end)
makeButton(secTP, "🕳️ المجاري", function()
    teleportToPlace({"sewer"}, "المجاري")
end)
makeButton(secTP, "🔫 مخزن الأسلحة (Armory)", function()
    teleportToPlace({"armory", "armoury"}, "مخزن الأسلحة")
end)
makeButton(secTP, "🔒 الزنازين", function()
    teleportToPlace({"cell"}, "الزنازين")
end)
makeButton(secTP, "🚪 بوابة السجن", function()
    teleportToPlace({"gate"}, "بوابة السجن")
end)
makeButton(secTP, "🔫 أقرب سلاح", function() teleportToNearestGun() end)
makeButton(secTP, "👤 أقرب لاعب", function() teleportToNearestPlayer() end)

-- قسم الحركة
local secMove = makeSection("✈️ الحركة")
makeToggle(secMove, "الطيران", false, function(v)
    setFly(v)
    flyBtns.Visible = v
end)
makeCycle(secMove, "سرعة الطيران", {16, 50, 100}, 2, function(v)
    S.flySpeed = v
end)
makeToggle(secMove, "👻 عبور الجدران", false, function(v)
    S.noclip = v
end)
makeToggle(secMove, "🏃 سرعة وقفز أعلى", false, function(v)
    S.speedBoost = v
    if not v then
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end
end)
makeCycle(secMove, "سرعة المشي", {24, 32, 50}, 2, function(v)
    S.walkSpeed = v
end)

-- قسم الحماية
local secProt = makeSection("🛡️ الحماية")
makeToggle(secProt, "❤️ وضع عدم الموت", false, function(v)
    S.godMode = v
    if v then bindGodMode() end
end)
makeToggle(secProt, "🚫 منع الطرد (Anti-Kick)", true, function(v)
    S.antiKick = v
    installHooks()
end)
makeToggle(secProt, "🧲 منع القذف (Anti-Fling)", false, function(v)
    S.antiFling = v
end)

-- قسم التشخيص
local secDiag = makeSection("⚙️ التشخيص")
local diagTeam = makeInfo(secDiag, "فريقي: —")
local diagTarget = makeInfo(secDiag, "الهدف: —")
local diagAim = makeInfo(secDiag, "السايلنت إيم: —")
local diagESP = makeInfo(secDiag, "الكشف: —")
local diagTP = makeInfo(secDiag, "آخر انتقال: —")
local diagHooks = makeInfo(secDiag, "الهوكات: —")

local function updateDiagnostics()
    local myKind = teamKind(LocalPlayer)
    diagTeam.Text = "فريقي: " .. TEAM_AR[myKind]
    if currentTarget then
        diagTarget.Text = "الهدف: " .. currentTarget.DisplayName
            .. " [" .. TEAM_AR[teamKind(currentTarget)] .. "]"
            .. " 📏 " .. math.floor(distanceTo(currentTarget))
    else
        diagTarget.Text = "الهدف: لا يوجد (داخل الدائرة)"
    end
    diagAim.Text = "السايلنت إيم: " .. (S.silentAim and "يعمل" or "متوقف")
        .. " • الطريقة: " .. S.aimMethod
        .. " • الإصابة: " .. S.hitChance .. "%"
        .. " • الدائرة: " .. S.aimFov
    diagESP.Text = "الكشف: لاعبون " .. espPlayerCount .. " • أسلحة " .. espWeaponCount
    diagTP.Text = "آخر انتقال: " .. S.lastTeleport
    diagHooks.Text = "الهوكات: ريموت/طرد " .. (hooksInstalled and "مثبتة" or "غير مثبتة بعد")
        .. " • ماوس " .. (mouseHookInstalled and "مثبت" or "غير مثبت بعد")
end

-- ================= الحلقات الرئيسية =================
installHooks()
bindGodMode()
refreshExclusionList()
updateFovCircle()

task.spawn(function()
    while true do
        pcall(updatePlayerESP)
        pcall(updateDiagnostics)
        task.wait(0.25)
    end
end)

task.spawn(function()
    while true do
        if S.weaponESP then
            pcall(scanWeapons)
            pcall(updateWeaponESP)
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        pcall(refreshExclusionList)
        task.wait(4)
    end
end)

RunService.Heartbeat:Connect(function()
    pcall(pickTarget)
    pcall(updateFly)
    pcall(updateGod)
    pcall(updateAntiFling)
    pcall(updateSpeed)
    if toastLabel and toastLabel.Visible and os.clock() > toastUntil then
        toastLabel.Visible = false
    end
end)

RunService.Stepped:Connect(function()
    pcall(updateNoclip)
end)

toast("⛓️ سكربت الصادق — حياة السجن جاهز! اضغط الزر البرتقالي")
