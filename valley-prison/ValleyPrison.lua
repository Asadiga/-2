--[[
    ⛓️ سكربت الصادق الشامل v3 — Alsadig Hub v3
    تطوير الصادق — Developed by Alsadig
    ============================================================
    كتالوج شامل يعمل في أي ماب (روبلكس) — كل الميزات في قائمة واحدة.
    يعمل على Delta Mobile باللمس كاملاً — كل شيء من القائمة.

    قائمة تحكم كاملة باللمس (بدون كتابة أوامر):
    • زر عائم ⛓️ يفتح القائمة ويغلقها (اسحب الزر لأي مكان يعجبك)
    • لوحة تشخيص في أعلى القائمة توضح حالة السايلنت إيم ولماذا
      قد لا يعمل (هل الهوك مثبّت؟ ما الهدف الحالي؟ كم النسبة؟)

    الكتالوج — 8 بطاقات:
    1) 🎯 سايلنت إيم: تصويب صامت بأربع طرق (الفأرة / الريموت /
       كاميرا عند الإطلاق / كاميرا مستمرة)، نسبة إصابة، دائرة
       ذهبية (180° افتراضياً)،
       مدى ومسافة، مرئي فقط أو عبر الجدران، تجاهل فريقي، وقائمة
       لاعبين لاستبعاد من لا تريد استهدافه.
    2) ✈️ الطيران: طيران بالجويستيك ولوحة المفاتيح وأزرار ▲▼،
       بسرعات 16 / 50 / 100.
    3) 👻 اختراق الجدران: امشِ عبر الجدران والأبواب.
    4) 🛡️ حماية: وضع إلهي (صحة كاملة دائماً) + حماية الطرد والبان
       مفعّلة دائماً.
    5) 🏃 السرعة والقفز: سرعة مشي (16 / 22 / 30 / 50)، قوة قفز
       (50 / 70 / 100)، وركض لا نهائي.
    6) 👁️ ESP للاعبين: اسم كل لاعب وفريقه ومسافته وصحته.
    7) 🔫 إظهار الأسلحة: يعلّم الأسلحة الملقاة على الأرض باسمها
       والمسافة — التقطها بنفسك.
    8) 🗺️ التنقل: احفظ حتى 5 نقاط وانتقل إليها، أو انتقل لأقرب
       لاعب أو لأي لاعب من القائمة.

    طريقة التشغيل:
    1) انسخ هذا السكربت كاملاً
    2) الصقه في دلتا (أو Solara) واضغط تشغيل (Execute) وأنت داخل أي لعبة
    3) ستظهر قائمة التحكم — اضغط زر ⛓️ لفتح الكتالوج

    ⚠️ ملاحظات مهمة بصراحة — اقرأها قبل التشغيل:
    • السكربت لا يطلق النار أبداً من نفسه — التصويب الصامت يوجّه
      طلقاتك أنت فقط لرأس الهدف في اللحظة التي تطلق فيها.
    • التصويب الصامت يعتمد على نظام إطلاق النار في اللعبة: جرّب
      الفأرة أولاً، فإن لم تعمل جرّب الريموت، فإن لم يعمل فطريقة
      الكاميرا تعمل مهما كان نظام السلاح لأنها تحرّك الكاميرا نفسها،
      وطريقة الكاميرا المستمرة توجّه الكاميرا للهدف طوال الوقت فتعمل
      في معظم المابات — لكنها ليست صامتة (الكاميرا تتحرك بوضوح).
      ولا يوجد سكربت يعمل في 100% من المابات: بعض الألعاب يتحقق
      سيرفرها من الطلقات فيرفض الطلقات الموجَّهة.
    • الفلوس والخبرة (XP) والمستويات وأشياء الروبكس: مستحيلة في أي
      ماب، لأنها محفوظة في سيرفر اللعبة وليس في جهازك، وأي سكربت أو
      فيديو يدّعي أنه يعطيك فلوساً أو خبرة مجاناً فهو نصب لسرقة حسابك.
    • الوضع الإلهي والطيران واختراق الجدران وESP كلها في جهازك فقط
      (client-side)، وقد يهزمها تحقق السيرفر فلا تعمل في بعض المابات.
    • في المابات التي يطبّق فيها السيرفر الضرر (مثل سجن الوادي)،
      الوضع الإلهي لا يضمن النجاة — السيرفر هو الذي يقرر الموت؛
      هذه الحلقة تعيد صحتك بأسرع ما يمكن فقط.
    • الضرر هو ضرر السلاح نفسه ويقرره السيرفر — الهيدشوت يعطي
      ضرر رأس السلاح، ولا يجبر القتل أبداً.
    • التصويب الصامت ملاحَظ بسهولة من اللاعبين الآخرين ومن إدارة
      اللعبة، واستخدامه قد يؤدي إلى حظر حسابك (بان) — استخدمه على
      مسؤوليتك الخاصة، ويفضل إبقاؤه مغلقاً إلا عند الحاجة.
    • حماية الطرد تمنع أوامر الطرد التي تأتي من جهازك فقط، وتعيد
      تثبيت الهوكات وبناء القائمة تلقائياً — أما البان من السيرفر
      فلا يوجد أي سكربت يستطيع منعه، لأن القرار يتم في السيرفر
      وليس في جهازك.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ================= حماية ضد الطرد والبان (Anti-Kick / Anti-Ban) =================
-- تمنع محاولات الطرد التي تأتي من جهازك فقط، وتقلل خطر الكشف:
-- السكربت لا يرسل أي شيء للسيرفر ولا يحرّك الكاميرا في طريقتي
-- الفأرة والريموت. أما البان من السيرفر فلا يوجد سكربت يمنعه.
local antiKickInstalled = false
local function installAntiKick()
	if antiKickInstalled then return end
	if not hookmetamethod or not getnamecallmethod then return end
	local ok, err = pcall(function()
		local oldNamecall
		local function hook(self, ...)
			local method = getnamecallmethod()
			if method == "Kick" and self == LocalPlayer then
				print("⛓️ تم منع محاولة طرد!")
				return nil
			end
			return oldNamecall(self, ...)
		end
		if newcclosure then hook = newcclosure(hook) end
		oldNamecall = hookmetamethod(game, "__namecall", hook)
		antiKickInstalled = true
	end)
	if not ok then warn("⛓️ تعذر تثبيت حماية الطرد: " .. tostring(err)) end
end

-- ================= الحالة =================
local silentAimOn = false
local aimMethod = "mouse" -- mouse | remote | camera | camera2
local aimFov = 180 -- درجات (30 - 180) — دائرة كبيرة: أي شخص يدخل الدائرة يجيه هيدشوت
local aimRange = 200 -- ستود (100 - 1000)
local aimVisibleOnly = true -- فحص الرؤية بالشعاع
local aimThroughWalls = false -- يسمح بالتصويب عبر الجدران (يلغي فحص الرؤية)
local ignoreSameTeam = true -- تجاهل لاعبي فريقي (في المابات بلا فرق يستهدف الجميع)
local wideCompat = false -- وضع التوافق الواسع: الريموت يعدّل أي ريموت (افتراضياً مغلق)
local aimTarget = nil

-- نسبة الإصابة: كل طلقة لها هذه النسبة لتتوجّه لرأس الهدف
local hitChance = 100 -- 25 / 50 / 75 / 100
local hitRollPass = true -- نتيجة السحب الحالية (تتجدد كل 0.15 ثانية)

-- المستبعدون من الاستهداف: [اسم اللاعب] = true (تبقى طوال الجلسة)
local excluded = {}

-- إظهار الأسلحة: تتبع علامات الأسلحة الملقاة على الأرض
local weaponEspOn = false
local weaponEspMarks = {} -- [instance] = {highlight, billboard, label}

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

-- هل هذا اللاعب في فريقي؟ (يُتجاهل إذا كان خيار "تجاهل فريقي" مفعّلاً؛
-- في المابات التي بلا فرق لا أحد في فريقك، فيستهدف الجميع)
local function isSameTeam(plr)
	local myTeam = LocalPlayer.Team
	local theirTeam = plr and plr.Team
	if not myTeam or not theirTeam then return false end
	return myTeam == theirTeam
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
-- جزء التصويب في جسم الهدف: الرأس أولاً، ثم بدائل لمن لا يملكون
-- رأساً (شخصيات مخصصة في بعض المابات).
local function getAimPart(char)
	if not char then return nil end
	return char:FindFirstChild("Head")
		or char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
end

local function getAimPoint()
	if not aimTarget or not isAlive(aimTarget) then return nil, nil end
	local char = aimTarget.Character
	if not char then return nil, nil end
	local head = getAimPart(char)
	if not head then return nil, nil end
	return head.Position, head
end

-- ================= الطريقة 1: الفأرة =================
-- يوجّه قراءة الفأرة (mouse.Hit / UnitRay / Target / X / Y) نحو رأس الهدف.
-- تعمل فقط إذا كان نظام إطلاق النار في اللعبة يقرأ الفأرة؛
-- وX/Y تغطيان الأسلحة التي تحسب التصويب من موضع الفأرة على الشاشة.
local function installMouseHook()
	if mouseHookInstalled then return end
	if not hookmetamethod then
		print("⛓️ هوك الفأرة غير مدعوم في هذا المنفذ — جرّب طريقة الريموت أو الكاميرا")
		return
	end
	local ok, err = pcall(function()
		local oldIndex
		local function hook(self, key)
			if silentAimOn and aimMethod == "mouse" and hitRollPass and (key == "Hit" or key == "UnitRay" or key == "Target" or key == "X" or key == "Y") then
				local pos, part = getAimPoint()
				if pos then
					if key == "Hit" then
						return CFrame.new(pos)
					elseif key == "Target" then
						return part
					elseif key == "X" or key == "Y" then
						local cam = workspace.CurrentCamera
						if cam then
							local sp = cam:WorldToScreenPoint(pos)
							if key == "X" then return sp.X end
							return sp.Y
						end
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

-- يعيد كتابة أي موضع تصويب داخل وسيط: Vector3/CFrame في المستوى
-- الأعلى أو متداخلاً داخل جدول (حتى عمق 2)، وأي جزء جسم (BasePart
-- يخص شخصية) يستبدل برأس الهدف — فالعديد من أنظمة الأسلحة ترسل
-- وسيطاً واحداً جدولاً فيه الموضع أو الجزء المصاب.
local function rewriteAimArg(v, pos, headPart, depth)
	local t = typeof(v)
	if t == "Vector3" then
		if v.Magnitude > 2 then return pos, true end
		return v, false
	elseif t == "CFrame" then
		return CFrame.new(pos), true
	elseif t == "Instance" then
		if headPart and v:IsA("BasePart") then
			local model = v:FindFirstAncestorOfClass("Model")
			if model and model:FindFirstChildOfClass("Humanoid") then
				return headPart, true
			end
		end
		return v, false
	elseif t == "table" and depth < 2 then
		local changed = false
		local copy = {}
		for k, val in pairs(v) do
			local newVal, ch = rewriteAimArg(val, pos, headPart, depth + 1)
			copy[k] = newVal
			if ch then changed = true end
		end
		if changed then return copy, true end
		return v, false
	end
	return v, false
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
			if (method == "FireServer" or method == "InvokeServer") and silentAimOn and aimMethod == "remote" and hitRollPass then
				local pos, headPart = getAimPoint()
				if pos then
					local remoteName = ""
					pcall(function()
						remoteName = string.lower(tostring(self.Name or ""))
					end)
					if wideCompat or isGunRemoteName(remoteName) then
						local args = { ... }
						local changed = false
						for i, v in ipairs(args) do
							local newVal, ch = rewriteAimArg(v, pos, headPart, 0)
							if ch then
								args[i] = newVal
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
	elseif aimMethod == "camera2" then
		return "كاميرا مستمرة"
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

-- اختيار الهدف كل إطار: أقرب لاعب آخر داخل الدائرة — مع تخطّي
-- المستبعدين ولاعبي فريقي (إذا كان خيار "تجاهل فريقي" مفعّلاً).
-- الأولوية: الأقرب لمركز الشاشة داخل مدى الرؤية، ثم الأقرب مسافة.
local function pickTarget()
	local cam = workspace.CurrentCamera
	if not cam then return nil end
	local camPos = cam.CFrame.Position
	local camDir = cam.CFrame.LookVector
	local best = nil
	local bestAngle = math.huge
	local bestDist = math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and isAlive(plr) and not isExcluded(plr) and not (ignoreSameTeam and isSameTeam(plr)) then
			local char = plr.Character
			local head = char and getAimPart(char)
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
	if ui.fovGlow then
		ui.fovGlow.Visible = show
	end
	if not show then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	local vp = cam.ViewportSize
	local radius = math.tan(math.rad(aimFov / 2)) / math.tan(math.rad(cam.FieldOfView / 2)) * (math.min(vp.X, vp.Y) / 2)
	-- دائرة كبيرة: حدّ أقصى يملأ الشاشة تقريباً حتى لا تختفي عند 180°
	radius = math.min(radius, math.min(vp.X, vp.Y) * 0.48)
	circle.Size = UDim2.new(0, radius * 2, 0, radius * 2)
	if ui.fovGlow then
		ui.fovGlow.Size = UDim2.new(0, radius * 2 + 28, 0, radius * 2 + 28)
	end
	local stroke = circle:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Color = aimTarget and Color3.fromRGB(255, 210, 80) or Color3.fromRGB(255, 255, 255)
	end
end

-- ================= حلقة التصويب =================
-- إعادة اختيار الهدف كل إطار، وإسقاط القفل فور موت الهدف أو
-- مغادرته أو خروجه من المدى/الرؤية. طريقة الكاميرا: أثناء
-- الضغط على زر الإطلاق (فأرة أو لمس) توجّه الكاميرا لرأس الهدف.
-- طريقة الكاميرا المستمرة: توجّه الكاميرا لرأس الهدف طوال الوقت
-- (ليست صامتة — الكاميرا تتحرك — لكنها تعمل في معظم المابات).
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
	if silentAimOn and aimTarget and hitRollPass and (aimMethod == "camera" or aimMethod == "camera2") then
		local firing = aimMethod == "camera2" or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or touchCount > 0
		if firing then
			local cam = workspace.CurrentCamera
			local pos = getAimPoint()
			if cam and pos then
				cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, pos), 0.5)
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

-- تدرج ذهبي غني بثلاث درجات (فاتح → ذهبي → داكن) بشكل مائل
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

-- بطاقة قسم مستديرة بخلفية داكنة خفيفة وحافة ذهبية رفيعة
local function makeCard(parent)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundColor3 = Color3.fromRGB(24, 24, 38)
	card.BorderSizePixel = 0
	card.Parent = parent
	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0, 14)
	cc.Parent = card
	local cs = Instance.new("UIStroke")
	cs.Color = GOLD
	cs.Transparency = 0.88
	cs.Thickness = 1
	cs.Parent = card
	local cl = Instance.new("UIListLayout")
	cl.Padding = UDim.new(0, 6)
	cl.Parent = card
	local cp = Instance.new("UIPadding")
	cp.PaddingLeft = UDim.new(0, 10)
	cp.PaddingRight = UDim.new(0, 10)
	cp.PaddingTop = UDim.new(0, 8)
	cp.PaddingBottom = UDim.new(0, 10)
	cp.Parent = card
	return card
end

-- سطر توضيحي صغير بلون باهت داخل البطاقات
local function noteLabel(parent, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 20)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = TEXT_MUTED
	l.Font = Enum.Font.GothamBold
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Right
	l.Parent = parent
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
	local g = btn:FindFirstChild("ActiveGold")
	if active and not g then
		g = Instance.new("UIGradient")
		g.Name = "ActiveGold"
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, GOLD_LIGHT),
			ColorSequenceKeypoint.new(0.5, GOLD),
			ColorSequenceKeypoint.new(1, GOLD_DARK),
		})
		g.Rotation = 45
		g.Parent = btn
	elseif not active and g then
		g:Destroy()
	end
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
	local glow = Instance.new("UIStroke")
	glow.Color = GOLD
	glow.Thickness = 2
	glow.Transparency = 1
	glow.Parent = switch

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
		glow.Transparency = on and 0.25 or 1
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

-- ================= إظهار الأسلحة (Weapon ESP) =================
-- يعلّم الأسلحة الملقاة على الأرض فقط (أدوات/أجزاء في Workspace
-- اسمها يطابق كلمة سلاح)، بإطار ذهبي واسم السلاح والمسافة.
-- لا يضع السلاح في يدك — عليك الذهاب والتقاطه بنفسك في اللعبة.
-- الأسلحة المحمولة بيد لاعب (داخل شخصيته) لا تُعلَّم.
local WEAPON_GOLD = Color3.fromRGB(241, 185, 47)
local WEAPON_WORDS = { "beretta", "pistol", "gun", "rifle", "shotgun", "smg", "shiv", "knife" }

local function isWeaponName(nameLower)
	for _, word in ipairs(WEAPON_WORDS) do
		if string.find(nameLower, word, 1, true) then
			return true
		end
	end
	return false
end

-- هل هذه القطعة داخل شخصية لاعب (محمولة بيده)؟
local function isHeldByPlayer(inst)
	local cur = inst
	while cur do
		if cur:IsA("Model") then
			local plr = Players:GetPlayerFromCharacter(cur)
			if plr then return true end
		end
		cur = cur.Parent
	end
	return false
end

-- هل أحد أسلاف هذه القطعة سلاح مطابق؟ (حتى لا نعلّم القطعة والسلاح معاً)
local function hasWeaponAncestor(inst)
	local cur = inst.Parent
	while cur and cur ~= workspace do
		if (cur:IsA("Tool") or cur:IsA("Model")) and isWeaponName(string.lower(tostring(cur.Name or ""))) then
			return true
		end
		cur = cur.Parent
	end
	return false
end

local function getWeaponPos(inst)
	if inst:IsA("BasePart") then
		return inst.Position
	end
	if inst:IsA("Model") then
		local ok, cf = pcall(function() return inst:GetPivot() end)
		if ok then return cf.Position end
	end
	local handle = inst:FindFirstChild("Handle")
	if handle and handle:IsA("BasePart") then
		return handle.Position
	end
	return nil
end

local function clearWeaponEsp()
	for _, mark in pairs(weaponEspMarks) do
		pcall(function() mark.highlight:Destroy() end)
		pcall(function() mark.billboard:Destroy() end)
	end
	table.clear(weaponEspMarks)
end

local function refreshWeaponEsp()
	if not weaponEspOn then
		clearWeaponEsp()
		return
	end
	local myChar = getCharacter()
	local myPos = nil
	if myChar then
		local hrp = myChar:FindFirstChild("HumanoidRootPart")
		if hrp then myPos = hrp.Position end
	end
	local seen = {}
	local ok, descendants = pcall(function() return workspace:GetDescendants() end)
	if not ok then return end
	for _, inst in ipairs(descendants) do
		if (inst:IsA("Tool") or inst:IsA("BasePart") or inst:IsA("Model"))
			and isWeaponName(string.lower(tostring(inst.Name or "")))
			and not isHeldByPlayer(inst)
			and not hasWeaponAncestor(inst) then
			local pos = getWeaponPos(inst)
			if pos then
				seen[inst] = true
				local dist = myPos and math.floor((pos - myPos).Magnitude + 0.5) or nil
				local labelText = "🔫 " .. inst.Name .. (dist and (" — " .. dist .. "م") or "")
				local mark = weaponEspMarks[inst]
				if not mark then
					local hl = Instance.new("Highlight")
					hl.FillColor = WEAPON_GOLD
					hl.FillTransparency = 0.7
					hl.OutlineColor = WEAPON_GOLD
					hl.OutlineTransparency = 0
					hl.Adornee = inst
					hl.Parent = inst
					local bb = Instance.new("BillboardGui")
					bb.Name = "WeaponEspLabel"
					bb.Size = UDim2.new(0, 200, 0, 30)
					bb.StudsOffset = Vector3.new(0, 2, 0)
					bb.AlwaysOnTop = true
					bb.Adornee = inst
					bb.Parent = inst
					local tl = Instance.new("TextLabel")
					tl.Size = UDim2.new(1, 0, 1, 0)
					tl.BackgroundTransparency = 1
					tl.Text = labelText
					tl.TextColor3 = WEAPON_GOLD
					tl.Font = Enum.Font.GothamBold
					tl.TextSize = 14
					tl.TextStrokeTransparency = 0.5
					tl.Parent = bb
					weaponEspMarks[inst] = { highlight = hl, billboard = bb, label = tl }
				else
					mark.label.Text = labelText
				end
			end
		end
	end
	for inst, mark in pairs(weaponEspMarks) do
		if not seen[inst] then
			pcall(function() mark.highlight:Destroy() end)
			pcall(function() mark.billboard:Destroy() end)
			weaponEspMarks[inst] = nil
		end
	end
end

-- ================= الطيران =================
local flyOn = false
local flySpeed = 50
local flyBV = nil
local flyBG = nil
local flyUp = false
local flyDown = false

local function stopFlyParts()
    if flyBV then
        pcall(function() flyBV:Destroy() end)
        flyBV = nil
    end
    if flyBG then
        pcall(function() flyBG:Destroy() end)
        flyBG = nil
    end
end

local function setFly(on)
    flyOn = on
    if not on then
        stopFlyParts()
        flyUp = false
        flyDown = false
    else
        local char = getCharacter()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            print("⛓️ لا توجد شخصية للطيران بعد — جرّب بعد ظهورك")
            flyOn = false
            refreshUI()
            return
        end
        stopFlyParts()
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBG.P = 10000
        flyBG.Parent = hrp
    end
    if ui.flyUpBtn then ui.flyUpBtn.Visible = flyOn end
    if ui.flyDownBtn then ui.flyDownBtn.Visible = flyOn end
    print("⛓️ الطيران: " .. (flyOn and "ON" or "OFF"))
    refreshUI()
end

-- حلقة الطيران: الاتجاه من جويستيك الهاتف (Humanoid.MoveDirection)
-- ولوحة المفاتيح (WASD + مسافة/Ctrl) وأزرار ▲▼ على الشاشة
task.spawn(function()
    while true do
        task.wait(0.05)
        if flyOn and flyBV and flyBV.Parent then
            pcall(function()
                local char = getCharacter()
                local hum = getHumanoid(char)
                local cam = workspace.CurrentCamera
                if not hum or not cam then return end
                local move = hum.MoveDirection
                local fwd = cam.CFrame.LookVector
                local right = cam.CFrame.RightVector
                local dir = Vector3.new(move.X, 0, move.Z)
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Vector3.new(fwd.X, 0, fwd.Z) end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Vector3.new(fwd.X, 0, fwd.Z) end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Vector3.new(right.X, 0, right.Z) end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Vector3.new(right.X, 0, right.Z) end
                if dir.Magnitude > 1 then dir = dir.Unit end
                local y = 0
                if flyUp or UIS:IsKeyDown(Enum.KeyCode.Space) then y = 1 end
                if flyDown or UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.C) then y = -1 end
                flyBV.Velocity = Vector3.new(dir.X * flySpeed, y * flySpeed, dir.Z * flySpeed)
                if flyBG and flyBV.Parent then
                    local flat = Vector3.new(fwd.X, 0, fwd.Z)
                    if flat.Magnitude > 0.01 then
                        flyBG.CFrame = CFrame.new(flyBV.Parent.Position, flyBV.Parent.Position + flat)
                    end
                end
            end)
        end
    end
end)

-- ================= اختراق الجدران =================
local noclipOn = false
task.spawn(function()
    while true do
        task.wait(0.1)
        if noclipOn then
            pcall(function()
                local char = getCharacter()
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        end
    end
end)

-- ================= الحماية (وضع إلهي) =================
local godOn = false

-- يعيد الصحة للكاملة فوراً ويمنع حالة الموت
local function restoreGodHealth()
	pcall(function()
		local hum = getHumanoid(getCharacter())
		if hum then
			hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
		end
	end)
end

-- يربط استعادة الصحة الفورية بحدث HealthChanged للشخصية الحالية
-- (يعاد ربطه عند كل شخصية جديدة)
local godHealthConn = nil
local godBoundHum = nil
local function bindGodHealth()
	local hum = getHumanoid(getCharacter())
	if hum == godBoundHum and godHealthConn then return end
	if godHealthConn then
		pcall(function() godHealthConn:Disconnect() end)
		godHealthConn = nil
	end
	godBoundHum = hum
	if hum then
		godHealthConn = hum.HealthChanged:Connect(function()
			if godOn then restoreGodHealth() end
		end)
	end
end

-- حلقة كل إطار: تعيد الصحة وتمنع حالة الموت باستمرار
RunService.Heartbeat:Connect(function()
	if godOn then
		bindGodHealth()
		restoreGodHealth()
	end
end)

-- ================= السرعة والقفز =================
local walkSpeed = 16
local jumpPower = 50
local sprintOn = false
local SPRINT_SPEED = 50

local function applySpeed()
    pcall(function()
        local hum = getHumanoid(getCharacter())
        if hum then
            hum.WalkSpeed = sprintOn and SPRINT_SPEED or walkSpeed
            hum.JumpPower = jumpPower
        end
    end)
end

-- إعادة تطبيق السرعة باستمرار أثناء الركض (السيرفر قد يعيدها)
task.spawn(function()
    while true do
        task.wait(0.5)
        if sprintOn then applySpeed() end
    end
end)

-- ================= ESP للاعبين =================
local playerEspOn = false
local playerEspMarks = {} -- [player] = {highlight, billboard, label}

local function clearPlayerEsp()
    for _, mark in pairs(playerEspMarks) do
        pcall(function() mark.highlight:Destroy() end)
        pcall(function() mark.billboard:Destroy() end)
    end
    table.clear(playerEspMarks)
end

local function refreshPlayerEsp()
    if not playerEspOn then
        clearPlayerEsp()
        return
    end
    local myChar = getCharacter()
    local myPos = nil
    if myChar then
        local hrp = myChar:FindFirstChild("HumanoidRootPart")
        if hrp then myPos = hrp.Position end
    end
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = getHumanoid(char)
            if char and hrp and hum then
                seen[plr] = true
                local dist = myPos and math.floor((hrp.Position - myPos).Magnitude + 0.5) or nil
                local teamName = teamLabelFor(plr)
                local color = (plr.Team and plr.TeamColor.Color) or Color3.fromRGB(241, 185, 47)
                local labelText = "👤 " .. plr.DisplayName .. " [" .. teamName .. "]" .. (dist and (" — " .. dist .. "م") or "") .. " ❤️" .. math.floor(hum.Health + 0.5) .. "/" .. math.floor(hum.MaxHealth + 0.5)
                local mark = playerEspMarks[plr]
                if not mark then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = color
                    hl.FillTransparency = 0.7
                    hl.OutlineColor = color
                    hl.OutlineTransparency = 0
                    hl.Adornee = char
                    hl.Parent = char
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "PlayerEspLabel"
                    bb.Size = UDim2.new(0, 220, 0, 30)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = hrp
                    bb.Parent = hrp
                    local tl = Instance.new("TextLabel")
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.BackgroundTransparency = 1
                    tl.Text = labelText
                    tl.TextColor3 = color
                    tl.Font = Enum.Font.GothamBold
                    tl.TextSize = 14
                    tl.TextStrokeTransparency = 0.5
                    tl.Parent = bb
                    playerEspMarks[plr] = { highlight = hl, billboard = bb, label = tl }
                else
                    mark.label.Text = labelText
                    mark.highlight.FillColor = color
                    mark.highlight.OutlineColor = color
                    mark.label.TextColor3 = color
                end
            end
        end
    end
    for plr, mark in pairs(playerEspMarks) do
        if not seen[plr] then
            pcall(function() mark.highlight:Destroy() end)
            pcall(function() mark.billboard:Destroy() end)
            playerEspMarks[plr] = nil
        end
    end
end

-- ================= التنقل =================
local waypoints = {} -- حتى 5 نقاط Vector3

local function teleportToPos(pos)
    pcall(function()
        local char = getCharacter()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        end
    end)
end

local function rebuildWaypointButtons()
    if not ui.waypointList then return end
    for _, child in ipairs(ui.waypointList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for i, pos in ipairs(waypoints) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = BTN_DARK
        btn.TextColor3 = TEXT_WHITE
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 15
        btn.Text = "📍 نقطة " .. i .. " (" .. math.floor(pos.X + 0.5) .. ", " .. math.floor(pos.Z + 0.5) .. ")"
        btn.Parent = ui.waypointList
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 10)
        c.Parent = btn
        addPress(btn)
        local target = pos
        btn.MouseButton1Click:Connect(function() teleportToPos(target) end)
    end
    ui.waypointList.Size = UDim2.new(1, 0, 0, #waypoints * 44)
end

local function saveWaypoint()
    local char = getCharacter()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        print("⛓️ لا توجد شخصية لحفظ النقطة بعد")
        return
    end
    if #waypoints >= 5 then
        table.remove(waypoints, 1)
        print("⛓️ وصلت للحد (5 نقاط) — حذفنا أقدم نقطة")
    end
    table.insert(waypoints, hrp.Position)
    print("⛓️ حفظنا نقطة " .. #waypoints)
    rebuildWaypointButtons()
end

local function teleportToNearest()
    local myChar = getCharacter()
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    local best = nil
    local bestDist = math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myHrp.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = plr
                end
            end
        end
    end
    if best then
        local hrp = best.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            teleportToPos(hrp.Position)
            print("⛓️ انتقلنا إلى " .. best.DisplayName)
        end
    else
        print("⛓️ لا يوجد لاعب للانتقال إليه")
    end
end

local function refreshFollowList()
    if not ui.followList then return end
    for _, child in ipairs(ui.followList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(names, plr.Name) end
    end
    table.sort(names)
    for _, name in ipairs(names) do
        local plr = Players:FindFirstChild(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = BTN_DARK
        btn.TextColor3 = TEXT_WHITE
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 15
        btn.Text = "👤 " .. (plr and plr.DisplayName or name) .. " [" .. teamLabelFor(plr) .. "]"
        btn.Parent = ui.followList
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 10)
        c.Parent = btn
        addPress(btn)
        local targetPlr = plr
        btn.MouseButton1Click:Connect(function()
            if targetPlr then
                local hrp = targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then teleportToPos(hrp.Position) end
            end
        end)
    end
    ui.followList.Size = UDim2.new(1, 0, 0, #names * 44)
end

-- ================= أمان إعادة الظهور =================
-- الطيران يتوقف عند إعادة الظهور (أجزاؤه تخص الشخصية القديمة)،
-- والوضع الإلهي والسرعة/القفز يعاد تطبيقهما على الشخصية الجديدة.
LocalPlayer.CharacterAdded:Connect(function()
    if flyOn then
        flyOn = false
        stopFlyParts()
        if ui.flyUpBtn then ui.flyUpBtn.Visible = false end
        if ui.flyDownBtn then ui.flyDownBtn.Visible = false end
    end
    task.wait(0.5)
    bindGodHealth()
    applySpeed()
    pcall(refreshUI)
end)

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

	-- حلقة توهج خافتة حول دائرة مدى الرؤية
	ui.fovGlow = Instance.new("Frame")
	ui.fovGlow.Name = "FovGlow"
	ui.fovGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	ui.fovGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
	ui.fovGlow.Size = UDim2.new(0, 0, 0, 0)
	ui.fovGlow.BackgroundTransparency = 1
	ui.fovGlow.Visible = false
	ui.fovGlow.Parent = screenGui
	local fgc = Instance.new("UICorner")
	fgc.CornerRadius = UDim.new(1, 0)
	fgc.Parent = ui.fovGlow
	local fgs = Instance.new("UIStroke")
	fgs.Thickness = 1
	fgs.Color = GOLD
	fgs.Transparency = 0.85
	fgs.Parent = ui.fovGlow

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
	addRichGoldGradient(floatButton)
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

	-- شريط العنوان بتدرج ذهبي غني
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 56)
	titleBar.BackgroundColor3 = GOLD
	titleBar.BorderSizePixel = 0
	titleBar.Parent = menuFrame
	addRichGoldGradient(titleBar)
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(0, 14)
	tc.Parent = titleBar
	local titleBottom = Instance.new("Frame")
	titleBottom.Size = UDim2.new(1, 0, 0, 8)
	titleBottom.Position = UDim2.new(0, 0, 1, -8)
	titleBottom.BackgroundColor3 = GOLD
	titleBottom.BorderSizePixel = 0
	titleBottom.Parent = titleBar

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -54, 0, 26)
	title.Position = UDim2.new(0, 12, 0, 4)
	title.BackgroundTransparency = 1
	title.Text = "⛓️ الصادق"
	title.TextColor3 = Color3.fromRGB(25, 18, 5)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Right
	title.Parent = titleBar

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1, -54, 0, 16)
	subtitle.Position = UDim2.new(0, 12, 0, 30)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "سايلنت إيم • الصادق"
	subtitle.TextColor3 = Color3.fromRGB(70, 52, 10)
	subtitle.Font = Enum.Font.GothamBold
	subtitle.TextSize = 12
	subtitle.TextXAlignment = Enum.TextXAlignment.Right
	subtitle.Parent = titleBar

	-- فتح/إغلاق ناعم للقائمة (تكبير/تصغير بحركة)
	local menuOpen = true
	local function setMenuOpen(open)
		menuOpen = open
		if open then
			menuFrame.Visible = true
			menuFrame.Size = UDim2.new(0, 300, 0, 460)
			TweenService:Create(menuFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 330, 0, 500) }):Play()
		else
			local tw = TweenService:Create(menuFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0, 300, 0, 460) })
			tw:Play()
			tw.Completed:Connect(function()
				if not menuOpen then
					menuFrame.Visible = false
				end
			end)
		end
	end

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 44, 0, 44)
	closeBtn.Position = UDim2.new(0, 2, 0, 6)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(25, 18, 5)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 20
	closeBtn.Parent = titleBar
	closeBtn.MouseButton1Click:Connect(function()
		setMenuOpen(false)
	end)

	floatButton.MouseButton1Click:Connect(function()
		setMenuOpen(not menuOpen)
	end)

	-- منطقة التمرير
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -56)
	scroll.Position = UDim2.new(0, 0, 0, 56)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 5
	scroll.ScrollBarImageColor3 = GOLD
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.Parent = menuFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = scroll

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.Parent = scroll

	-- بطاقة الحالة: لوحة التشخيص + سطر الحالة
	local cardStatus = makeCard(scroll)
	sectionLabel(cardStatus, "📊 الحالة")
	ui.diagLabel = Instance.new("TextLabel")
	ui.diagLabel.Size = UDim2.new(1, 0, 0, 186)
	ui.diagLabel.BackgroundColor3 = CARD_DARK
	ui.diagLabel.TextColor3 = TEXT_WHITE
	ui.diagLabel.Font = Enum.Font.GothamBold
	ui.diagLabel.TextSize = 13
	ui.diagLabel.TextXAlignment = Enum.TextXAlignment.Right
	ui.diagLabel.TextYAlignment = Enum.TextYAlignment.Top
	ui.diagLabel.TextWrapped = true
	ui.diagLabel.Text = "⏳ جارٍ فحص الحالة..."
	ui.diagLabel.Parent = cardStatus
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
	ui.statusLabel.Parent = cardStatus
	local slc = Instance.new("UICorner")
	slc.CornerRadius = UDim.new(0, 10)
	slc.Parent = ui.statusLabel


    -- بطاقة 1: التصويب الصامت
    local cardAim = makeCard(scroll)
    sectionLabel(cardAim, "🎯 سايلنت إيم")
    noteLabel(cardAim, "يوجّه طلقاتك أنت فقط لرأس الهدف — لا يطلق النار من نفسه")
    makeToggle(cardAim, "silentAim", "تصويب صامت", false, function(v) setSilentAim(v) end)
    sectionLabel(cardAim, "طريقة التصويب")
    local rowMethod = makeRow(cardAim)
    local rowMethod2 = makeRow(cardAim)
    ui.methodBtns = {}
    local methods = { { "mouse", "الفأرة", rowMethod }, { "remote", "الريموت", rowMethod }, { "camera", "كاميرا ⚠️", rowMethod2 }, { "camera2", "كاميرا مستمرة ⚠️", rowMethod2 } }
    for _, m in ipairs(methods) do
        local b = makeButton(m[3], m[2], 146)
        addPress(b)
        ui.methodBtns[m[1]] = b
        b.MouseButton1Click:Connect(function() setAimMethod(m[1]) end)
    end
    local camNote = Instance.new("TextLabel")
    camNote.Size = UDim2.new(1, 0, 0, 44)
    camNote.BackgroundTransparency = 1
    camNote.Text = "⚠️ طريقتا الكاميرا ليستا صامتتين — والمستمرة توجّه الكاميرا للهدف طوال الوقت"
    camNote.TextColor3 = TEXT_MUTED
    camNote.Font = Enum.Font.GothamBold
    camNote.TextSize = 12
    camNote.TextXAlignment = Enum.TextXAlignment.Right
    camNote.TextWrapped = true
    camNote.Parent = cardAim
    makeToggle(cardAim, "ignoreTeam", "🛡️ تجاهل فريقي", true, function(v) ignoreSameTeam = v end)
    makeToggle(cardAim, "wideCompat", "🎯 وضع التوافق الواسع", false, function(v) wideCompat = v end)
    noteLabel(cardAim, "⚠️ التوافق الواسع يعدّل أي ريموت أثناء التصويب — قد يسبب سلوكاً غريباً في بعض الألعاب؛ أغلقه إذا تصرفت اللعبة بشكل غريب")
    noteLabel(cardAim, "نسبة الإصابة")
    local rowChance = makeRow(cardAim)
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
    noteLabel(cardAim, "مدى الرؤية (درجات)")
    local rowFov = makeRow(cardAim)
    ui.fovBtns = {}
    for _, f in ipairs({ 45, 60, 90, 120, 180 }) do
        local b = makeButton(rowFov, tostring(f) .. "°", 58)
        addPress(b)
        ui.fovBtns[f] = b
        b.MouseButton1Click:Connect(function() aimFov = f end)
    end
    noteLabel(cardAim, "أقصى مسافة (ستود)")
    local rowRange = makeRow(cardAim)
    ui.rangeBtns = {}
    for _, r in ipairs({ 100, 200, 500, 1000 }) do
        local b = makeButton(rowRange, tostring(r), 72)
        addPress(b)
        ui.rangeBtns[r] = b
        b.MouseButton1Click:Connect(function() aimRange = r end)
    end
    makeToggle(cardAim, "visOnly", "فقط إذا كان الهدف مرئياً", true, function(v)
        aimVisibleOnly = v
        if v then aimThroughWalls = false end
    end)
    makeToggle(cardAim, "throughWalls", "التصويب عبر الجدران", false, function(v)
        aimThroughWalls = v
        if v then aimVisibleOnly = false end
    end)
    sectionLabel(cardAim, "👤 اللاعبون — اضغط على لاعب لاستبعاده")
    local rowPlayers = makeRow(cardAim)
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
    ui.excludedLabel.Parent = cardAim
    ui.playerList = Instance.new("Frame")
    ui.playerList.Size = UDim2.new(1, 0, 0, 0)
    ui.playerList.BackgroundTransparency = 1
    ui.playerList.Parent = cardAim
    local plLayout = Instance.new("UIListLayout")
    plLayout.Padding = UDim.new(0, 4)
    plLayout.Parent = ui.playerList

    -- بطاقة 2: الطيران
    local cardFly = makeCard(scroll)
    sectionLabel(cardFly, "✈️ الطيران")
    noteLabel(cardFly, "طِر بيدك — جويستيك أو WASD للحركة، والأسهم للصعود والنزول")
    makeToggle(cardFly, "fly", "الطيران", false, function(v) setFly(v) end)
    noteLabel(cardFly, "سرعة الطيران")
    local rowFlySpeed = makeRow(cardFly)
    ui.flySpeedBtns = {}
    for _, s in ipairs({ 16, 50, 100 }) do
        local b = makeButton(rowFlySpeed, tostring(s), 96)
        addPress(b)
        ui.flySpeedBtns[s] = b
        b.MouseButton1Click:Connect(function() flySpeed = s end)
    end
    local rowFlyBtns = makeRow(cardFly)
    ui.flyUpBtn = makeButton(rowFlyBtns, "▲", 146)
    ui.flyUpBtn.Visible = false
    ui.flyUpBtn.MouseButton1Down:Connect(function() flyUp = true end)
    ui.flyUpBtn.MouseButton1Up:Connect(function() flyUp = false end)
    ui.flyDownBtn = makeButton(rowFlyBtns, "▼", 146)
    ui.flyDownBtn.Visible = false
    ui.flyDownBtn.MouseButton1Down:Connect(function() flyDown = true end)
    ui.flyDownBtn.MouseButton1Up:Connect(function() flyDown = false end)

    -- بطاقة 3: اختراق الجدران
    local cardNoclip = makeCard(scroll)
    sectionLabel(cardNoclip, "👻 اختراق الجدران")
    noteLabel(cardNoclip, "امشِ عبر الجدران والأبواب — قد يكشفه تحقق السيرفر")
    makeToggle(cardNoclip, "noclip", "اختراق الجدران", false, function(v) noclipOn = v end)

    -- بطاقة 4: الحماية
    local cardProtect = makeCard(scroll)
    sectionLabel(cardProtect, "🛡️ حماية")
    noteLabel(cardProtect, "وضع إلهي — يعيد صحتك للكاملة باستمرار")
    makeToggle(cardProtect, "god", "وضع إلهي (لا تموت)", false, function(v) godOn = v end)
    noteLabel(cardProtect, "حماية الطرد والبان مفعّلة دائماً: تمنع أوامر الطرد من جهازك وتعيد تثبيت الهوكات وبناء القائمة تلقائياً")

    -- بطاقة 5: السرعة والقفز
    local cardSpeed = makeCard(scroll)
    sectionLabel(cardSpeed, "🏃 السرعة والقفز")
    noteLabel(cardSpeed, "سرعة المشي")
    local rowWalk = makeRow(cardSpeed)
    ui.walkBtns = {}
    for _, s in ipairs({ 16, 22, 30, 50 }) do
        local b = makeButton(rowWalk, tostring(s), 72)
        addPress(b)
        ui.walkBtns[s] = b
        b.MouseButton1Click:Connect(function()
            walkSpeed = s
            applySpeed()
        end)
    end
    noteLabel(cardSpeed, "قوة القفز")
    local rowJump = makeRow(cardSpeed)
    ui.jumpBtns = {}
    for _, j in ipairs({ 50, 70, 100 }) do
        local b = makeButton(rowJump, tostring(j), 96)
        addPress(b)
        ui.jumpBtns[j] = b
        b.MouseButton1Click:Connect(function()
            jumpPower = j
            applySpeed()
        end)
    end
    makeToggle(cardSpeed, "sprint", "ركض لا نهائي", false, function(v)
        sprintOn = v
        applySpeed()
    end)

    -- بطاقة 6: ESP للاعبين
    local cardEsp = makeCard(scroll)
    sectionLabel(cardEsp, "👁️ ESP للاعبين")
    noteLabel(cardEsp, "يظهر اسم كل لاعب وفريقه ومسافته وصحته")
    makeToggle(cardEsp, "playerEsp", "ESP للاعبين", false, function(v)
        playerEspOn = v
        refreshPlayerEsp()
    end)

    -- بطاقة 7: إظهار الأسلحة
    local cardWeapons = makeCard(scroll)
    sectionLabel(cardWeapons, "🔫 إظهار الأسلحة")
    noteLabel(cardWeapons, "يعلّم الأسلحة الملقاة على الأرض باسمها والمسافة")
    makeToggle(cardWeapons, "weaponEsp", "🔫 إظهار الأسلحة", false, function(v)
        weaponEspOn = v
        refreshWeaponEsp()
    end)
    noteLabel(cardWeapons, "تُظهر الأسلحة الملقاة على الأرض فقط — التقطها بنفسك")

    -- بطاقة 8: التنقل
    local cardTp = makeCard(scroll)
    sectionLabel(cardTp, "🗺️ التنقل")
    local rowTp = makeRow(cardTp)
    ui.saveWpBtn = makeButton(rowTp, "📍 حفظ نقطة", 146)
    addPress(ui.saveWpBtn)
    ui.saveWpBtn.MouseButton1Click:Connect(function() saveWaypoint() end)
    ui.nearestBtn = makeButton(rowTp, "👤 أقرب لاعب", 146)
    addPress(ui.nearestBtn)
    ui.nearestBtn.MouseButton1Click:Connect(function() teleportToNearest() end)
    noteLabel(cardTp, "نقاطي المحفوظة (حتى 5) — اضغط على نقطة للانتقال إليها")
    ui.waypointList = Instance.new("Frame")
    ui.waypointList.Size = UDim2.new(1, 0, 0, 0)
    ui.waypointList.BackgroundTransparency = 1
    ui.waypointList.Parent = cardTp
    local wpLayout = Instance.new("UIListLayout")
    wpLayout.Padding = UDim.new(0, 4)
    wpLayout.Parent = ui.waypointList
    sectionLabel(cardTp, "👤 اضغط على لاعب للانتقال إليه")
    ui.followList = Instance.new("Frame")
    ui.followList.Size = UDim2.new(1, 0, 0, 0)
    ui.followList.BackgroundTransparency = 1
    ui.followList.Parent = cardTp
    local flLayout = Instance.new("UIListLayout")
    flLayout.Padding = UDim.new(0, 4)
    flLayout.Parent = ui.followList
    rebuildWaypointButtons()
    refreshFollowList()

	-- تذييل: الصادق
	local footer = Instance.new("TextLabel")
	footer.Size = UDim2.new(1, 0, 0, 26)
	footer.BackgroundTransparency = 1
	footer.Text = "الصادق • الشامل v3"
	footer.TextColor3 = GOLD
	footer.Font = Enum.Font.GothamBold
	footer.TextSize = 14
	footer.Parent = scroll

	refreshUI()
	refreshPlayerList(true)
end

-- حارس الواجهة والهوكات: إذا حذفت اللعبة القائمة يعيد بناءها
-- تلقائياً، ويعيد تثبيت أي هوك لم يُثبَّت بعد.
task.spawn(function()
	while true do
		task.wait(2)
		if not screenGui or not screenGui.Parent or not menuFrame or not menuFrame.Parent or not floatButton or not floatButton.Parent then
			buildGui()
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(5)
		if not mouseHookInstalled then
			installMouseHook()
		end
		if not remoteHookInstalled then
			installRemoteHook()
		end
		if not antiKickInstalled then
			installAntiKick()
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
	table.insert(lines, "حماية الطرد: " .. (antiKickInstalled and "نعم ✅" or "لا ❌"))
	table.insert(lines, "تجاهل فريقي: " .. (ignoreSameTeam and "نعم ✅" or "لا ❌"))
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
	syncToggle("ignoreTeam", ignoreSameTeam)
	syncToggle("wideCompat", wideCompat)
	syncToggle("fly", flyOn)
	syncToggle("noclip", noclipOn)
	syncToggle("god", godOn)
	syncToggle("sprint", sprintOn)
	syncToggle("playerEsp", playerEspOn)
	syncToggle("weaponEsp", weaponEspOn)
	if ui.flyUpBtn then ui.flyUpBtn.Visible = flyOn end
	if ui.flyDownBtn then ui.flyDownBtn.Visible = flyOn end
	for s, b in pairs(ui.flySpeedBtns or {}) do setActive(b, flySpeed == s) end
	for s, b in pairs(ui.walkBtns or {}) do setActive(b, walkSpeed == s) end
	for j, b in pairs(ui.jumpBtns or {}) do setActive(b, jumpPower == j) end

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
print("⛓️ سكربت الصادق الشامل v3 يعمل! اضغط زر ⛓️ لفتح الكتالوج")
installAntiKick()
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

task.spawn(function()
	while true do
		task.wait(1)
		refreshPlayerEsp()
		refreshWeaponEsp()
	end
end)

task.spawn(function()
	while true do
		task.wait(3)
		refreshFollowList()
	end
end)
