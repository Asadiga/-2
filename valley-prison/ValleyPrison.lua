--[[
    ⛓️ سكربت الصادق v3 — Alsadig Script v3
    تطوير الصادق — Developed by Alsadig
    ============================================================
    للعبة Valley Prison [V3] (سجن الوادي) — سجن ولعب أدوار.
    سكربت تصويب صامت فقط (Silent Aim Only) — بلا أي ميزة أخرى.
    يعمل على Delta Mobile باللمس كاملاً — كل شيء من القائمة.

    قائمة تحكم كاملة باللمس (بدون كتابة أوامر):
    • زر عائم ⛓️ يفتح القائمة ويغلقها
    • لوحة تشخيص في أعلى القائمة توضح حالة السايلنت إيم ولماذا
      قد لا يعمل (هل الهوك مثبّت؟ ما الهدف الحالي؟ كم النسبة؟)
    • تصويب صامت بثلاث طرق — جرّبها بالترتيب:
      1) الفأرة: يوجّه قراءة الفأرة (mouse.Hit) نحو رأس الهدف.
      2) الريموت: يعدّل الريموت الذي يطلقه السلاح نحو رأس الهدف.
      3) كاميرا عند الإطلاق: يوجّه الكاميرا للهدف وأنت تطلق النار
         (ليست صامتة — الكاميرا تتحرك، لكنها تعمل مهما كان نظام السلاح).
    • نسبة إصابة (25 / 50 / 75 / 100%): كل طلقة لها هذه النسبة
      لتتوجّه للهدف، وإلا تذهب عادياً.
    • قائمة لاعبين: اضغط على أي لاعب لاستبعاده من الاستهداف
      (اضغط مرة أخرى لإعادته)، مع زر مسح الكل.
    • دائرة ذهبية كبيرة (180° افتراضياً): أي شخص يدخلها يجيه هيدشوت.

    طريقة التشغيل:
    1) انسخ هذا السكربت كاملاً
    2) الصقه في دلتا (أو Solara) واضغط تشغيل (Execute) وأنت داخل اللعبة
    3) ستظهر قائمة التحكم — اسحبها لأي مكان يعجبك

    ⚠️ ملاحظات مهمة بصراحة — اقرأها قبل التشغيل:
    • اللعبة حدّثت (V3 0.01) وتغيّر نظام إطلاق النار، فتوقفت طريقة
      الفأرة عن العمل عند بعض اللاعبين. لهذا أضفنا ثلاث طرق: جرّب
      الفأرة أولاً، فإن لم تعمل جرّب الريموت، فإن لم يعمل فطريقة
      الكاميرا تعمل مهما كان نظام السلاح لأنها تحرّك الكاميرا نفسها.
      لوحة التشخيص في أعلى القائمة تخبرك أي هوك مثبّت وأي طريقة
      تعمل في منفّذك — إذا ظهر "هوك الفأرة: لا" فالمنفذ لا يدعم
      تلك الطريقة وجرّب غيرها.
    • التصويب الصامت يعتمد على طريقة إطلاق النار في اللعبة: إذا كان
      السيرفر يتحقق من الطلقات أو كان نظام السلاح يقرأ شيئاً آخر
      غير الفأرة والريموت، فقد لا يعمل التصويب الصامت إطلاقاً.
    • طريقة الريموت تخمين (heuristic): تعدّل فقط الريموتات التي
      يبدو اسمها متعلقاً بإطلاق النار (shoot/fire/bullet/gun/
      hit/damage/attack) وتستبدل أي رقم موضع (Vector3) أو إطار
      (CFrame) فيها بموقع رأس الهدف. إذا كان سلاح اللعبة يطلق
      ريموتاً باسم آخر أو بلا موضع، فلن تفيد هذه الطريقة.
    • الفلوس والخبرة (XP) والمستويات وفتح الفرق وأشياء الروبكس:
      مستحيلة في أي ماب، لأنها محفوظة في سيرفر اللعبة وليس في
      جهازك، وأي سكربت أو فيديو يدّعي أنه يعطيك فلوساً أو خبرة
      مجاناً فهو نصب لسرقة حسابك. لا تصدقه أبداً.
    • ⚠️ التصويب التلقائي والصامت ملاحَظ بسهولة من اللاعبين الآخرين
      ومن إدارة اللعبة، واستخدامه قد يؤدي إلى حظر حسابك (بان) —
      استخدمه على مسؤوليتك الخاصة، ويفضل إبقاؤه مغلقاً إلا عند الحاجة.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ================= الحالة =================
local silentAimOn = false
local aimMethod = "mouse" -- mouse | remote | camera
local aimFov = 180 -- درجات (30 - 180) — دائرة كبيرة: أي شخص يدخل الدائرة يجيه هيدشوت
local aimRange = 200 -- ستود (100 - 1000)
local aimVisibleOnly = true -- فحص الرؤية بالشعاع
local aimThroughWalls = false -- يسمح بالتصويب عبر الجدران (يلغي فحص الرؤية)
local aimTarget = nil

-- نسبة الإصابة: كل طلقة لها هذه النسبة لتتوجّه لرأس الهدف
local hitChance = 100 -- 25 / 50 / 75 / 100
local hitRollPass = true -- نتيجة السحب الحالية (تتجدد كل 0.15 ثانية)

-- المستبعدون من الاستهداف: [اسم اللاعب] = true (تبقى طوال الجلسة)
local excluded = {}

-- حالة الهوكات (تظهر في لوحة التشخيص)
local mouseHookInstalled = false
local silentAimSupported = false
local remoteHookInstalled = false
local remoteHookSupported = false
local mouse = LocalPlayer:GetMouse()

-- لمس زر الإطلاق في الهاتف (لطريقة الكاميرا)
local touchCount = 0

-- ================= أدوات مساعدة =================
local function getCharacter()
	return LocalPlayer.Character
end

local function getHumanoid(char)
	if not char then return nil end
	return char:FindFirstChildOfClass("Humanoid")
end

local function isAlive(plr)
	local char = plr and plr.Character
	local hum = getHumanoid(char)
	return char and hum and hum.Health > 0
end

local function getTeamName(plr)
	if plr and plr.Team then
		return plr.Team.Name or ""
	end
	return ""
end

local function teamLabelFor(plr)
	local name = getTeamName(plr)
	if name ~= "" then return name end
	return "؟"
end

-- هل هذا اللاعب عدو للاعب المحلي؟ (لسجين/هارب: الحراس والشرطة)
local function isEnemy(plr)
	local myTeam = string.lower(getTeamName(LocalPlayer))
	local theirTeam = string.lower(getTeamName(plr))
	if theirTeam == "" then
		return false -- فريق غير معروف: لا نعتبره عدواً مؤكداً
	end
	local iAmGuard = string.find(myTeam, "correction", 1, true)
		or string.find(myTeam, "police", 1, true)
		or string.find(myTeam, "state", 1, true)
	local theyAreGuard = string.find(theirTeam, "correction", 1, true)
		or string.find(theirTeam, "police", 1, true)
		or string.find(theirTeam, "state", 1, true)
	local theyArePrisoner = string.find(theirTeam, "inmate", 1, true)
		or string.find(theirTeam, "escapee", 1, true)
	if iAmGuard then
		return theyArePrisoner
	else
		return theyAreGuard
	end
end

local function clampNum(v, lo, hi)
	if v < lo then return lo end
	if v > hi then return hi end
	return v
end

-- ================= المستبعدون من الاستهداف =================
local function isExcluded(plr)
	return plr and excluded[plr.Name] == true
end

local function excludedCount()
	local n = 0
	for _ in pairs(excluded) do
		n = n + 1
	end
	return n
end

local function toggleExcluded(name)
	if excluded[name] then
		excluded[name] = nil
		print("⛓️ أعدنا استهداف: " .. name)
	else
		excluded[name] = true
		print("⛓️ استبعدنا من الاستهداف: " .. name)
	end
	if aimTarget and aimTarget.Name == name then
		aimTarget = nil
	end
	refreshPlayerList(true)
	refreshUI()
end

local function clearExcluded()
	table.clear(excluded)
	print("⛓️ مسحنا كل المستبعدين")
	refreshPlayerList(true)
	refreshUI()
end

-- ================= نسبة الإصابة (سحب كل 0.15 ثانية) =================
-- سحب واحد مشترك لكل قراءات الفأرة/الريموت داخل نفس الطلقة، حتى
-- لا تتغير النتيجة في منتصف الطلقة الواحدة.
task.spawn(function()
	while true do
		task.wait(0.15)
		hitRollPass = math.random(1, 100) <= hitChance
	end
end)

-- ================= نقطة التصويب (رأس الهدف) =================
local function getAimPoint()
	if not aimTarget or not isAlive(aimTarget) then return nil, nil end
	local char = aimTarget.Character
	if not char then return nil, nil end
	local head = char:FindFirstChild("Head")
	if not head then return nil, nil end
	return head.Position, head
end

-- ================= الطريقة 1: الفأرة =================
-- يوجّه قراءة الفأرة (mouse.Hit / UnitRay / Target) نحو رأس الهدف.
-- تعمل فقط إذا كان نظام إطلاق النار في اللعبة يقرأ الفأرة.
local function installMouseHook()
	if mouseHookInstalled then return end
	if not hookmetamethod then
		print("⛓️ هوك الفأرة غير مدعوم في هذا المنفذ — جرّب طريقة الريموت أو الكاميرا")
		return
	end
	local ok, err = pcall(function()
		local oldIndex
		local function hook(self, key)
			if silentAimOn and aimMethod == "mouse" and hitRollPass and (key == "Hit" or key == "UnitRay" or key == "Target") then
				local pos, part = getAimPoint()
				if pos then
					if key == "Hit" then
						return CFrame.new(pos)
					elseif key == "Target" then
						return part
					elseif key == "UnitRay" then
						local cam = workspace.CurrentCamera
						if cam then
							local origin = cam.CFrame.Position
							local dir = pos - origin
							if dir.Magnitude > 0.01 then
								return Ray.new(origin, dir.Unit * dir.Magnitude)
							end
						end
					end
				end
			end
			return oldIndex(self, key)
		end
		if newcclosure then
			hook = newcclosure(hook)
		end
		oldIndex = hookmetamethod(mouse, "__index", hook)
		mouseHookInstalled = true
		silentAimSupported = true
	end)
	if not ok then
		warn("⛓️ تعذر تثبيت هوك الفأرة: " .. tostring(err))
	end
end

-- ================= الطريقة 2: الريموت =================
-- تخمين: يعدّل الريموتات التي يبدو اسمها متعلقاً بإطلاق النار،
-- ويستبدل أي رقم موضع (Vector3) يبدو نقطة تصويب (مقداره أكبر
-- من 2، فالاتجاهات تكون وحدوية ~1) وأي إطار (CFrame) بموقع رأس الهدف.
-- يفيد فقط إذا كان سلاح اللعبة يطلق ريموتاً كهذا فيه موضع.
local GUN_REMOTE_WORDS = { "shoot", "fire", "bullet", "gun", "hit", "damage", "attack" }

local function isGunRemoteName(nameLower)
	for _, word in ipairs(GUN_REMOTE_WORDS) do
		if string.find(nameLower, word, 1, true) then
			return true
		end
	end
	return false
end

local function installRemoteHook()
	if remoteHookInstalled then return end
	if not hookmetamethod or not getnamecallmethod then
		print("⛓️ هوك الريموت غير مدعوم في هذا المنفذ — جرّب طريقة الفأرة أو الكاميرا")
		return
	end
	local ok, err = pcall(function()
		local oldNamecall
		local function hook(self, ...)
			local method = getnamecallmethod()
			if method == "FireServer" and silentAimOn and aimMethod == "remote" and hitRollPass then
				local pos, _part = getAimPoint()
				if pos then
					local remoteName = ""
					pcall(function()
						remoteName = string.lower(tostring(self.Name or ""))
					end)
					if isGunRemoteName(remoteName) then
						local args = { ... }
						local changed = false
						for i, v in ipairs(args) do
							if typeof(v) == "Vector3" and v.Magnitude > 2 then
								args[i] = pos
								changed = true
							elseif typeof(v) == "CFrame" then
								args[i] = CFrame.new(pos)
								changed = true
							end
						end
						if changed then
							return oldNamecall(self, table.unpack(args))
						end
					end
				end
			end
			return oldNamecall(self, ...)
		end
		if newcclosure then
			hook = newcclosure(hook)
		end
		oldNamecall = hookmetamethod(game, "__namecall", hook)
		remoteHookInstalled = true
		remoteHookSupported = true
	end)
	if not ok then
		warn("⛓️ تعذر تثبيت هوك الريموت: " .. tostring(err))
	end
end

-- ================= اختيار الطريقة والتشغيل =================
local function methodDisplayName()
	if aimMethod == "mouse" then
		return "الفأرة"
	elseif aimMethod == "remote" then
		return "الريموت"
	else
		return "كاميرا عند الإطلاق"
	end
end

local function ensureMethodHook()
	if aimMethod == "mouse" then
		installMouseHook()
		return silentAimSupported
	elseif aimMethod == "remote" then
		installRemoteHook()
		return remoteHookSupported
	end
	return true -- الكاميرا لا تحتاج هوكاً
end

local function setSilentAim(on)
	if on and not ensureMethodHook() then
		print("⛓️ هذه الطريقة غير مدعومة في هذا المنفذ — جرّب طريقة أخرى من القائمة")
		silentAimOn = false
		refreshUI()
		return
	end
	silentAimOn = on
	if not on then
		aimTarget = nil
	end
	print("⛓️ التصويب الصامت: " .. (on and "ON" or "OFF") .. " (" .. methodDisplayName() .. ")")
	refreshUI()
end

local function setAimMethod(m)
	aimMethod = m
	if silentAimOn and not ensureMethodHook() then
		print("⛓️ هذه الطريقة غير مدعومة في هذا المنفذ — أوقفنا التصويب الصامت")
		silentAimOn = false
		aimTarget = nil
	end
	print("⛓️ طريقة التصويب: " .. methodDisplayName())
	refreshUI()
end

-- ================= فحص الرؤية واختيار الهدف =================
local function isVisibleToCamera(char, targetPos)
	if aimThroughWalls or not aimVisibleOnly then return true end
	local cam = workspace.CurrentCamera
	if not cam then return false end
	local origin = cam.CFrame.Position
	local dir = targetPos - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local myChar = getCharacter()
	if myChar then
		params.FilterDescendantsInstances = { myChar }
	end
	local result = workspace:Raycast(origin, dir, params)
	if not result then return true end
	return result.Instance:IsDescendantOf(char)
end

-- اختيار الهدف كل إطار: الأعداء أولاً (الحراس والشرطة)، وإلا أقرب
-- لاعب آخر — مع تخطّي المستبعدين دائماً. الأولوية: الأقرب لمركز
-- الشاشة داخل مدى الرؤية، ثم الأقرب مسافة.
local function pickTarget()
	local cam = workspace.CurrentCamera
	if not cam then return nil end
	local camPos = cam.CFrame.Position
	local camDir = cam.CFrame.LookVector
	local enemies = {}
	local others = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and isAlive(plr) and not isExcluded(plr) then
			if isEnemy(plr) then
				table.insert(enemies, plr)
			else
				table.insert(others, plr)
			end
		end
	end
	local pool = #enemies > 0 and enemies or others
	local best = nil
	local bestAngle = math.huge
	local bestDist = math.huge
	for _, plr in ipairs(pool) do
		local char = plr.Character
		local head = char and char:FindFirstChild("Head")
		if head then
			local toHead = head.Position - camPos
			local dist = toHead.Magnitude
			if dist <= aimRange and dist > 0.5 then
				local angle = math.deg(math.acos(clampNum(camDir:Dot(toHead.Unit), -1, 1)))
				if angle <= aimFov / 2 then
					if angle < bestAngle - 0.5 or (math.abs(angle - bestAngle) <= 0.5 and dist < bestDist) then
						if isVisibleToCamera(char, head.Position) then
							best = plr
							bestAngle = angle
							bestDist = dist
						end
					end
				end
			end
		end
	end
	return best
end

-- ================= دائرة مدى الرؤية =================
local ui = {}
local function updateFovCircle()
	local circle = ui.fovCircle
	if not circle then return end
	local show = silentAimOn
	circle.Visible = show
	if ui.fovDot then
		ui.fovDot.Visible = show
	end
	if not show then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	local vp = cam.ViewportSize
	local radius = math.tan(math.rad(aimFov / 2)) / math.tan(math.rad(cam.FieldOfView / 2)) * (math.min(vp.X, vp.Y) / 2)
	-- دائرة كبيرة: حدّ أقصى يملأ الشاشة تقريباً حتى لا تختفي عند 180°
	radius = math.min(radius, math.min(vp.X, vp.Y) * 0.48)
	circle.Size = UDim2.new(0, radius * 2, 0, radius * 2)
	local stroke = circle:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Color = aimTarget and Color3.fromRGB(255, 210, 80) or Color3.fromRGB(255, 255, 255)
	end
end

-- ================= حلقة التصويب =================
-- إعادة اختيار الهدف كل إطار، وإسقاط القفل فور موت الهدف أو
-- مغادرته أو خروجه من المدى/الرؤية. طريقة الكاميرا: أثناء
-- الضغط على زر الإطلاق (فأرة أو لمس) توجّه الكاميرا لرأس الهدف.
UIS.InputBegan:Connect(function(input, _gpe)
	if input.UserInputType == Enum.UserInputType.Touch then
		touchCount = touchCount + 1
	end
end)
UIS.InputEnded:Connect(function(input, _gpe)
	if input.UserInputType == Enum.UserInputType.Touch then
		touchCount = math.max(0, touchCount - 1)
	end
end)

RunService.RenderStepped:Connect(function()
	if silentAimOn then
		aimTarget = pickTarget()
	else
		aimTarget = nil
	end
	updateFovCircle()
	if silentAimOn and aimMethod == "camera" and aimTarget and hitRollPass then
		local firing = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or touchCount > 0
		if firing then
			local cam = workspace.CurrentCamera
			local head = aimTarget.Character and aimTarget.Character:FindFirstChild("Head")
			if cam and head then
				cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, head.Position), 0.5)
			end
		end
	end
end)

-- ================= القائمة (GUI) — تصميم عصري =================
-- ثيم داكن مع ذهبي، زوايا مستديرة، تدرجات ذهبية، مفاتيح منزلقة،
-- وأزرار كبيرة باللمس لشاشة الهاتف (390px). كل الميزات من القائمة
-- وحدها — لا حاجة للوحة مفاتيح أو فأرة (Delta Mobile).

local TweenService = game:GetService("TweenService")

local GOLD = Color3.fromRGB(241, 185, 47)
local GOLD_LIGHT = Color3.fromRGB(255, 220, 130)
local GOLD_DARK = Color3.fromRGB(180, 135, 20)
local BG_DARK = Color3.fromRGB(16, 16, 24)
local CARD_DARK = Color3.fromRGB(28, 28, 40)
local BTN_DARK = Color3.fromRGB(45, 45, 60)
local TEXT_WHITE = Color3.fromRGB(255, 255, 255)
local TEXT_MUTED = Color3.fromRGB(170, 170, 190)

local screenGui, menuFrame, floatButton
ui.toggles = {}

local function darkenColor(c, f)
	return Color3.new(c.R * f, c.G * f, c.B * f)
end

local function addGoldGradient(obj)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, GOLD_LIGHT),
		ColorSequenceKeypoint.new(1, GOLD),
	})
	g.Rotation = 90
	g.Parent = obj
	return g
end

local function sectionLabel(parent, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 30)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = GOLD
	l.Font = Enum.Font.GothamBold
	l.TextSize = 16
	l.TextXAlignment = Enum.TextXAlignment.Right
	l.Parent = parent
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 2)
	bar.Position = UDim2.new(0, 0, 1, -2)
	bar.BackgroundColor3 = GOLD
	bar.BorderSizePixel = 0
	bar.Parent = l
	addGoldGradient(bar)
	return l
end

local function makeButton(parent, text, width, gold)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, width or 96, 0, 42)
	b.BackgroundColor3 = gold and GOLD or BTN_DARK
	b.TextColor3 = gold and Color3.fromRGB(25, 18, 5) or TEXT_WHITE
	b.Font = Enum.Font.GothamBold
	b.TextSize = 15
	b.Text = text
	b.Parent = parent
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = b
	if gold then
		addGoldGradient(b)
	end
	return b
end

local function makeRow(parent, height)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, height or 48)
	row.BackgroundTransparency = 1
	row.Parent = parent
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.Padding = UDim.new(0, 6)
	layout.Parent = row
	return row
end

-- رد فعل ضغط ناعم: يغمق الزر لحظياً ثم يعيد الألوان عبر refreshUI
local function addPress(btn)
	btn.MouseButton1Down:Connect(function()
		btn.BackgroundColor3 = darkenColor(btn.BackgroundColor3, 0.65)
	end)
	btn.MouseButton1Up:Connect(function()
		refreshUI()
	end)
end

local function setActive(btn, active)
	if not btn then return end
	btn.BackgroundColor3 = active and GOLD or BTN_DARK
	btn.TextColor3 = active and Color3.fromRGB(25, 18, 5) or TEXT_WHITE
end

-- مفتاح منزلق عصري: صف فيه نص على اليمين ومفتاح على اليسار
local function makeToggle(parent, key, text, initial, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 42)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -66, 1, 0)
	label.Position = UDim2.new(0, 66, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = TEXT_WHITE
	label.Font = Enum.Font.GothamBold
	label.TextSize = 15
	label.TextXAlignment = Enum.TextXAlignment.Right
	label.Parent = row

	local switch = Instance.new("Frame")
	switch.Size = UDim2.new(0, 54, 0, 28)
	switch.Position = UDim2.new(0, 0, 0.5, -14)
	switch.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
	switch.BorderSizePixel = 0
	switch.Parent = row
	local sc = Instance.new("UICorner")
	sc.CornerRadius = UDim.new(1, 0)
	sc.Parent = switch

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 22, 0, 22)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 14, 0.5, 0)
	knob.BackgroundColor3 = TEXT_WHITE
	knob.BorderSizePixel = 0
	knob.Parent = switch
	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = knob

	local state = initial
	local function render(on)
		state = on
		local goal = on and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 14, 0.5, 0)
		TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = goal }):Play()
		switch.BackgroundColor3 = on and GOLD or Color3.fromRGB(70, 70, 85)
	end
	ui.toggles[key] = { set = render, get = function() return state end }
	render(initial)

	local tap = Instance.new("TextButton")
	tap.Size = UDim2.new(1, 0, 1, 0)
	tap.BackgroundTransparency = 1
	tap.Text = ""
	tap.Parent = row
	tap.MouseButton1Click:Connect(function()
		local newState = not state
		render(newState)
		if callback then callback(newState) end
		refreshUI()
	end)
	return row
end

local function buildGui()
	if screenGui then
		pcall(function() screenGui:Destroy() end)
	end
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AlsadigGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	-- دائرة مدى الرؤية (تظهر عند تشغيل التصويب الصامت)
	ui.fovCircle = Instance.new("Frame")
	ui.fovCircle.Name = "FovCircle"
	ui.fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	ui.fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
	ui.fovCircle.Size = UDim2.new(0, 0, 0, 0)
	ui.fovCircle.BackgroundTransparency = 1
	ui.fovCircle.Visible = false
	ui.fovCircle.Parent = screenGui
	local fcc = Instance.new("UICorner")
	fcc.CornerRadius = UDim.new(1, 0)
	fcc.Parent = ui.fovCircle
	local fs = Instance.new("UIStroke")
	fs.Thickness = 3
	fs.Color = GOLD
	fs.Transparency = 0.1
	fs.Parent = ui.fovCircle
	ui.fovCircle.BackgroundColor3 = GOLD
	ui.fovCircle.BackgroundTransparency = 0.94

	ui.fovDot = Instance.new("Frame")
	ui.fovDot.Name = "FovDot"
	ui.fovDot.AnchorPoint = Vector2.new(0.5, 0.5)
	ui.fovDot.Position = UDim2.new(0.5, 0, 0.5, 0)
	ui.fovDot.Size = UDim2.new(0, 8, 0, 8)
	ui.fovDot.BackgroundColor3 = GOLD
	ui.fovDot.BorderSizePixel = 0
	ui.fovDot.Visible = false
	ui.fovDot.Parent = screenGui
	local fdc = Instance.new("UICorner")
	fdc.CornerRadius = UDim.new(1, 0)
	fdc.Parent = ui.fovDot

	-- زر عائم عصري يفتح القائمة ويغلقها
	floatButton = Instance.new("TextButton")
	floatButton.Name = "FloatButton"
	floatButton.Size = UDim2.new(0, 68, 0, 68)
	floatButton.Position = UDim2.new(1, -88, 1, -250)
	floatButton.BackgroundColor3 = GOLD
	floatButton.Text = "⛓️"
	floatButton.TextSize = 30
	floatButton.TextColor3 = Color3.fromRGB(25, 18, 5)
	floatButton.Font = Enum.Font.GothamBold
	floatButton.Active = true
	floatButton.Draggable = true
	floatButton.Parent = screenGui
	addGoldGradient(floatButton)
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(1, 0)
	fc.Parent = floatButton
	local fst = Instance.new("UIStroke")
	fst.Color = GOLD_DARK
	fst.Thickness = 2
	fst.Parent = floatButton
	-- نبض ذهبي خفيف للزر العائم
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
	menuFrame = Instance.new("Frame")
	menuFrame.Name = "Menu"
	menuFrame.Size = UDim2.new(0, 330, 0, 500)
	menuFrame.Position = UDim2.new(0.5, -165, 0.5, -250)
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

	-- شريط العنوان بتدرج ذهبي
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 48)
	titleBar.BackgroundColor3 = GOLD
	titleBar.BorderSizePixel = 0
	titleBar.Parent = menuFrame
	addGoldGradient(titleBar)
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(0, 14)
	tc.Parent = titleBar
	local titleBottom = Instance.new("Frame")
	titleBottom.Size = UDim2.new(1, 0, 0, 14)
	titleBottom.Position = UDim2.new(0, 0, 1, -14)
	titleBottom.BackgroundColor3 = GOLD
	titleBottom.BorderSizePixel = 0
	titleBottom.Parent = titleBar

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -54, 1, 0)
	title.Position = UDim2.new(0, 12, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "⛓️ الصادق"
	title.TextColor3 = Color3.fromRGB(25, 18, 5)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 19
	title.TextXAlignment = Enum.TextXAlignment.Right
	title.Parent = titleBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 44, 0, 44)
	closeBtn.Position = UDim2.new(0, 2, 0, 2)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(25, 18, 5)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 20
	closeBtn.Parent = titleBar
	closeBtn.MouseButton1Click:Connect(function()
		menuFrame.Visible = false
	end)

	floatButton.MouseButton1Click:Connect(function()
		menuFrame.Visible = not menuFrame.Visible
	end)

	-- منطقة التمرير
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -48)
	scroll.Position = UDim2.new(0, 0, 0, 48)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 5
	scroll.ScrollBarImageColor3 = GOLD
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.Parent = menuFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = scroll

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.Parent = scroll

	-- لوحة التشخيص (أعلى القائمة)
	ui.diagLabel = Instance.new("TextLabel")
	ui.diagLabel.Size = UDim2.new(1, 0, 0, 150)
	ui.diagLabel.BackgroundColor3 = CARD_DARK
	ui.diagLabel.TextColor3 = TEXT_WHITE
	ui.diagLabel.Font = Enum.Font.GothamBold
	ui.diagLabel.TextSize = 13
	ui.diagLabel.TextXAlignment = Enum.TextXAlignment.Right
	ui.diagLabel.TextYAlignment = Enum.TextYAlignment.Top
	ui.diagLabel.TextWrapped = true
	ui.diagLabel.Text = "⏳ جارٍ فحص الحالة..."
	ui.diagLabel.Parent = scroll
	local dlc = Instance.new("UICorner")
	dlc.CornerRadius = UDim.new(0, 10)
	dlc.Parent = ui.diagLabel

	-- سطر الحالة المختصر
	ui.statusLabel = Instance.new("TextLabel")
	ui.statusLabel.Size = UDim2.new(1, 0, 0, 30)
	ui.statusLabel.BackgroundColor3 = CARD_DARK
	ui.statusLabel.TextColor3 = TEXT_WHITE
	ui.statusLabel.Font = Enum.Font.GothamBold
	ui.statusLabel.TextSize = 14
	ui.statusLabel.Text = "⛓️ الصادق — جاهز"
	ui.statusLabel.Parent = scroll
	local slc = Instance.new("UICorner")
	slc.CornerRadius = UDim.new(0, 10)
	slc.Parent = ui.statusLabel

	-- 🎯 التصويب الصامت
	sectionLabel(scroll, "🎯 التصويب الصامت")
	makeToggle(scroll, "silentAim", "تصويب صامت", false, function(v) setSilentAim(v) end)
	sectionLabel(scroll, "طريقة التصويب")
	local rowMethod = makeRow(scroll)
	ui.methodBtns = {}
	local methods = { { "mouse", "الفأرة" }, { "remote", "الريموت" }, { "camera", "كاميرا ⚠️" } }
	for _, m in ipairs(methods) do
		local b = makeButton(rowMethod, m[2], 96)
		addPress(b)
		ui.methodBtns[m[1]] = b
		b.MouseButton1Click:Connect(function() setAimMethod(m[1]) end)
	end
	local camNote = Instance.new("TextLabel")
	camNote.Size = UDim2.new(1, 0, 0, 30)
	camNote.BackgroundTransparency = 1
	camNote.Text = "⚠️ طريقة الكاميرا ليست صامتة: الكاميرا تتحرك وأنت تطلق النار"
	camNote.TextColor3 = TEXT_MUTED
	camNote.Font = Enum.Font.GothamBold
	camNote.TextSize = 12
	camNote.TextXAlignment = Enum.TextXAlignment.Right
	camNote.TextWrapped = true
	camNote.Parent = scroll

	-- 🎲 نسبة الإصابة
	sectionLabel(scroll, "🎲 نسبة الإصابة")
	local rowChance = makeRow(scroll)
	ui.chanceBtns = {}
	for _, c in ipairs({ 25, 50, 75, 100 }) do
		local b = makeButton(rowChance, tostring(c) .. "%", 72)
		addPress(b)
		ui.chanceBtns[c] = b
		b.MouseButton1Click:Connect(function()
			hitChance = c
			print("⛓️ نسبة الإصابة: " .. c .. "%")
		end)
	end

	-- مدى الرؤية
	sectionLabel(scroll, "مدى الرؤية (درجات)")
	local rowFov = makeRow(scroll)
	ui.fovBtns = {}
	for _, f in ipairs({ 45, 60, 90, 120, 180 }) do
		local b = makeButton(rowFov, tostring(f) .. "°", 58)
		addPress(b)
		ui.fovBtns[f] = b
		b.MouseButton1Click:Connect(function() aimFov = f end)
	end

	-- أقصى مسافة
	sectionLabel(scroll, "أقصى مسافة (ستود)")
	local rowRange = makeRow(scroll)
	ui.rangeBtns = {}
	for _, r in ipairs({ 100, 200, 500, 1000 }) do
		local b = makeButton(rowRange, tostring(r), 72)
		addPress(b)
		ui.rangeBtns[r] = b
		b.MouseButton1Click:Connect(function() aimRange = r end)
	end

	makeToggle(scroll, "visOnly", "فقط إذا كان الهدف مرئياً", true, function(v)
		aimVisibleOnly = v
		if v then aimThroughWalls = false end
	end)
	makeToggle(scroll, "throughWalls", "التصويب عبر الجدران", false, function(v)
		aimThroughWalls = v
		if v then aimVisibleOnly = false end
	end)

	-- 👤 اللاعبون — الاستبعاد من الاستهداف
	sectionLabel(scroll, "👤 اللاعبون — اضغط على لاعب لاستبعاده")
	local rowPlayers = makeRow(scroll)
	ui.refreshBtn = makeButton(rowPlayers, "🔄 تحديث", 146)
	addPress(ui.refreshBtn)
	ui.refreshBtn.MouseButton1Click:Connect(function()
		refreshPlayerList(true)
	end)
	ui.clearBtn = makeButton(rowPlayers, "🧹 مسح الكل", 146)
	addPress(ui.clearBtn)
	ui.clearBtn.MouseButton1Click:Connect(function()
		clearExcluded()
	end)
	ui.excludedLabel = Instance.new("TextLabel")
	ui.excludedLabel.Size = UDim2.new(1, 0, 0, 26)
	ui.excludedLabel.BackgroundTransparency = 1
	ui.excludedLabel.Text = "المستبعدون من الاستهداف: 0"
	ui.excludedLabel.TextColor3 = TEXT_MUTED
	ui.excludedLabel.Font = Enum.Font.GothamBold
	ui.excludedLabel.TextSize = 13
	ui.excludedLabel.TextXAlignment = Enum.TextXAlignment.Right
	ui.excludedLabel.Parent = scroll
	ui.playerList = Instance.new("Frame")
	ui.playerList.Size = UDim2.new(1, 0, 0, 0)
	ui.playerList.BackgroundTransparency = 1
	ui.playerList.Parent = scroll
	local plLayout = Instance.new("UIListLayout")
	plLayout.Padding = UDim.new(0, 4)
	plLayout.Parent = ui.playerList

	-- تذييل: الصادق
	local footer = Instance.new("TextLabel")
	footer.Size = UDim2.new(1, 0, 0, 26)
	footer.BackgroundTransparency = 1
	footer.Text = "الصادق • Valley Prison v3"
	footer.TextColor3 = GOLD
	footer.Font = Enum.Font.GothamBold
	footer.TextSize = 14
	footer.Parent = scroll

	refreshUI()
	refreshPlayerList(true)
end

-- حارس الواجهة: إذا حذفت اللعبة القائمة، يعيد بناءها تلقائياً
task.spawn(function()
	while true do
		task.wait(2)
		if not screenGui or not screenGui.Parent then
			buildGui()
		end
	end
end)

-- ================= تحديث الواجهة =================
local function buildDiagText()
	local lines = {}
	table.insert(lines, "السايلنت إيم: " .. (silentAimOn and "ON ✅" or "OFF ❌"))
	table.insert(lines, "الطريقة: " .. methodDisplayName())
	table.insert(lines, "هوك الفأرة: " .. (mouseHookInstalled and "نعم ✅" or "لا ❌"))
	table.insert(lines, "هوك الريموت: " .. (remoteHookInstalled and "نعم ✅" or "لا ❌"))
	local targetText = "لا يوجد هدف"
	if aimTarget then
		targetText = aimTarget.DisplayName .. " [" .. teamLabelFor(aimTarget) .. "]"
	end
	table.insert(lines, "الهدف: " .. targetText)
	table.insert(lines, "نسبة الإصابة: " .. hitChance .. "%")
	table.insert(lines, "المستبعدون: " .. excludedCount())
	table.insert(lines, "المدى: " .. aimFov .. "° • المسافة: " .. aimRange)
	return table.concat(lines, "\n")
end

function refreshUI()
	if not ui.statusLabel then return end
	if ui.diagLabel then
		ui.diagLabel.Text = buildDiagText()
	end
	local targetText = "—"
	if aimTarget then
		targetText = aimTarget.DisplayName
	end
	ui.statusLabel.Text = "⛓️ صامت " .. (silentAimOn and "ON" or "OFF")
		.. " • " .. methodDisplayName()
		.. " • " .. hitChance .. "%"
		.. " • الهدف: " .. targetText
	if ui.excludedLabel then
		ui.excludedLabel.Text = "المستبعدون من الاستهداف: " .. excludedCount()
	end

	local function syncToggle(key, state)
		local t = ui.toggles and ui.toggles[key]
		if t then t.set(state) end
	end
	syncToggle("silentAim", silentAimOn)
	syncToggle("visOnly", aimVisibleOnly)
	syncToggle("throughWalls", aimThroughWalls)

	for m, b in pairs(ui.methodBtns or {}) do setActive(b, aimMethod == m) end
	for c, b in pairs(ui.chanceBtns or {}) do setActive(b, hitChance == c) end
	for f, b in pairs(ui.fovBtns or {}) do setActive(b, aimFov == f) end
	for r, b in pairs(ui.rangeBtns or {}) do setActive(b, aimRange == r) end

	if ui.playerButtons then
		for _, plr in ipairs(Players:GetPlayers()) do
			local btn = ui.playerButtons[plr.Name]
			if btn then
				local ex = isExcluded(plr)
				btn.BackgroundColor3 = ex and Color3.fromRGB(150, 40, 40) or BTN_DARK
				btn.TextColor3 = TEXT_WHITE
			end
		end
	end
end

local lastPlayerSig = ""
function refreshPlayerList(force)
	if not ui.playerList then return end
	local names = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			table.insert(names, plr.Name)
		end
	end
	table.sort(names)
	local sig = table.concat(names, ",")
	if sig == lastPlayerSig and not force then return end
	lastPlayerSig = sig

	for _, child in ipairs(ui.playerList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	ui.playerButtons = {}
	for _, name in ipairs(names) do
		local plr = Players:FindFirstChild(name)
		local ex = plr and isExcluded(plr)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 40)
		btn.BackgroundColor3 = ex and Color3.fromRGB(150, 40, 40) or BTN_DARK
		btn.TextColor3 = TEXT_WHITE
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 15
		btn.Text = "👤 " .. (plr and plr.DisplayName or name) .. " [" .. teamLabelFor(plr) .. "]" .. (ex and " ✕ مستبعد" or "")
		btn.Parent = ui.playerList
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 10)
		c.Parent = btn
		addPress(btn)
		ui.playerButtons[name] = btn
		btn.MouseButton1Click:Connect(function()
			toggleExcluded(name)
		end)
	end
	ui.playerList.Size = UDim2.new(1, 0, 0, #names * 44)
	refreshUI()
end

-- ================= التشغيل =================
print("⛓️ سكربت الصادق v3 يعمل! تصويب صامت فقط — اضغط زر ⛓️ لفتح القائمة")
installMouseHook()
installRemoteHook()
buildGui()

task.spawn(function()
	while true do
		task.wait(0.5)
		refreshUI()
	end
end)

task.spawn(function()
	while true do
		task.wait(3)
		refreshPlayerList(false)
	end
end)
