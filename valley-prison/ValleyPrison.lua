--[[
    ⛓️ سكربت الصادق — Alsadig Script v1
    تطوير الصادق — Developed by Alsadig
    ============================================================
    للعبة Valley Prison [V3] (سجن الوادي) — سجن ولعب أدوار.
    يعمل على Solara (وغيره من المنفذات) — يستخدم دوالاً قياسية
    فقط، وأي ميزة لا يدعمها منفذك يتخطاها السكربت تلقائياً.

    قائمة تحكم كاملة باللمس (بدون كتابة أوامر):
    • زر عائم ⛓️ يفتح القائمة ويغلقها
    • دم لا ينتهي، طيران بأزرار لمس ▲▼، سرعة، قفز، ركض لا نهائي
    • عبور الجدران (Noclip) — امشِ عبر الجدران والفتحات
    • كشف اللاعبين (ESP) بألوان فرقهم + الاسم والمسافة والصحة
    • كشف الأغراض (بطاقة، مفك، قميص، بنطال، سترة، سلاح، سكين...)
    • تصويب صامت (Silent Aim) على الحراس والشرطة — الرصاصة تذهب
      للهدف دون أن تتحرك الكاميرا، مع دائرة كبيرة: أي شخص يدخلها يجيه هيدشوت
    • تصويب عادي بالكاميرا كخيار ثانوي (اختياري)
    • يعمل على Delta Mobile باللمس كاملاً — كل الميزات من القائمة
    • نقل فوري: 5 مواقع محفوظة + أقرب لاعب + اتباع أي لاعب

    طريقة التشغيل:
    1) انسخ هذا السكربت كاملاً
    2) الصقه في دلتا (أو Solara) واضغط تشغيل (Execute) وأنت داخل اللعبة
    3) ستظهر قائمة التحكم — اسحبها لأي مكان يعجبك

    الأوامر من الشات ما زالت تعمل أيضاً (احتياط):
    ;god, ;fly, ;speed <16/22/30/50>, ;jump <50/70/100>, ;sprint,
    ;noclip, ;esp, ;itemesp, ;aim, ;aimfov <30-180>, ;aimrange <n>,
    ;aimsmooth, ;aimvis, ;aimwall, ;aimmode, ;tp <اسم>, ;nearest,
    ;follow <اسم>, ;stop, ;wp save <اسم>, ;wp <اسم>, ;menu, ;help

    ⚠️ ملاحظات مهمة بصراحة — اقرأها قبل التشغيل:
    • الفلوس والخبرة (XP) والمستويات وفتح الفرق وأشياء الروبكس:
      مستحيلة في أي ماب، لأنها محفوظة في سيرفر اللعبة وليس في
      جهازك، وأي سكربت أو فيديو يدّعي أنه يعطيك فلوساً أو خبرة
      مجاناً فهو نصب لسرقة حسابك. لا تصدقه أبداً.
    • الدم الذي لا ينتهي والطيران والكشف (ESP) والتصويب كلها
      تعمل من جهازك (Client) فقط، وقد لا تنجو من تحقق السيرفر
      في الألعاب المحمية؛ والسيرفر هو من يقرر صحتك وضررك في النهاية.
    • الأسلحة يجب أن تلتقطها داخل اللعبة (مثلاً Beretta والسكين
      والشاش من مخزن الهروب) — السكربت لا يستطيع منحك أسلحة اللعبة.
    • التصويب الصامت يعتمد على طريقة إطلاق النار في اللعبة: السكربت
      يوجّه قراءة الفأرة (mouse.Hit) نحو رأس الهدف، فإذا كان نظام
      إطلاق النار في V3 يستخدم ريموت إطلاق مخصص لا يقرأ الفأرة،
      أو كان السيرفر يتحقق من الطلقات، فقد لا يعمل التصويب الصامت
      — السكربت يستخدم الطريقة العامة ويقول ذلك بصراحة.
    • ⚠️ التصويب التلقائي والصامت ملاحَظ بسهولة من اللاعبين الآخرين
      ومن إدارة اللعبة، واستخدامه قد يؤدي إلى حظر حسابك (بان) —
      استخدمه على مسؤوليتك الخاصة، ويفضل إبقاؤه مغلقاً إلا عند الحاجة.
    • حماية الطرد تمنع أوامر الطرد التي تأتي من جهازك (Kick) فقط،
      وتقلل خطر الكشف (التصويب الصامت لا يحرّك الكاميرا، والسكربت
      لا يرسل أي شيء للسيرفر ولا يستدعي أي ريموت — يقرأ حالة اللعبة
      فقط) — أما الباند من السيرفر فلا يوجد أي سكربت يستطيع منعه،
      لأن القرار يتم في السيرفر وليس في جهازك.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ================= حماية ضد الطرد (Anti-Kick) =================
pcall(function()
	if hookmetamethod and getnamecallmethod then
		local oldNamecall
		local function hook(self, ...)
			local method = getnamecallmethod()
			if method == "Kick" and self == LocalPlayer then
				warn("⛓️ تم منع محاولة طرد!")
				return nil
			end
			return oldNamecall(self, ...)
		end
		if newcclosure then
			hook = newcclosure(hook)
		end
		oldNamecall = hookmetamethod(game, "__namecall", hook)
		print("⛓️ حماية ضد الطرد: مفعّلة")
	end
end)

-- ================= الإعدادات =================
local PREFIX = ";"
local MAX_WAYPOINTS = 5

-- ================= الحالة =================
local godMode = false
local flying = false
local flySpeed = 50
local flyUp = false
local flyDown = false
local walkSpeed = 16
local jumpPower = 50
local infiniteSprint = false
local noclip = false
local espOn = false
local itemEspOn = false

-- التصويب التلقائي
local aimMode = "hold" -- hold | always
local aimFov = 180 -- درجات (30 - 180) — دائرة كبيرة: أي شخص يدخل الدائرة يجيه هيدشوت
local aimRange = 200 -- ستود (100 - 1000)
local aimSmooth = true
local aimVisibleOnly = true -- فحص الرؤية بالشعاع
local aimThroughWalls = false -- يسمح بالتصويب عبر الجدران (يلغي فحص الرؤية)
local aimTarget = nil

-- النقل والاتباع
local waypoints = {} -- { {name=..., pos=Vector3} }
local followTarget = nil

-- ================= أدوات مساعدة =================
local function getCharacter()
	return LocalPlayer.Character
end

local function getHRP(char)
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
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

local function findPlayerByName(partial)
	partial = string.lower(partial)
	local best = nil
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local name = string.lower(plr.Name)
			local disp = string.lower(plr.DisplayName)
			if name == partial or disp == partial then
				return plr
			elseif string.find(name, partial, 1, true) or string.find(disp, partial, 1, true) then
				best = plr
			end
		end
	end
	return best
end

local function getTeamName(plr)
	if plr and plr.Team then
		return plr.Team.Name or ""
	end
	return ""
end

local function teamColorFor(plr)
	local name = string.lower(getTeamName(plr))
	if string.find(name, "correction", 1, true) then
		return Color3.fromRGB(0, 140, 255) -- حراس السجن: أزرق
	elseif string.find(name, "police", 1, true) or string.find(name, "state", 1, true) then
		return Color3.fromRGB(120, 80, 255) -- شرطة الولاية: بنفسجي مزرق
	elseif string.find(name, "escapee", 1, true) then
		return Color3.fromRGB(255, 60, 60) -- هارب: أحمر
	elseif string.find(name, "inmate", 1, true) then
		return Color3.fromRGB(255, 140, 0) -- سجين: برتقالي
	elseif string.find(name, "civilian", 1, true) then
		return Color3.fromRGB(60, 200, 90) -- مدني: أخضر
	end
	if plr and plr.TeamColor then
		return plr.TeamColor.Color
	end
	return Color3.fromRGB(200, 200, 200) -- غير معروف: رمادي
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

-- ================= دم لا ينتهي (God Mode) =================
-- يعيد صحتك للكاملة فور نقصانها، ويمنع حالة الموت من جهازك.
-- يعمل في الألعاب التي لا تتحقق من الصحة في السيرفر؛ وفي
-- الألعاب المحمية قد لا يعمل لأن السيرفر هو من يقرر صحتك.
task.spawn(function()
	while true do
		task.wait(0.1)
		if godMode then
			local hum = getHumanoid(getCharacter())
			if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
				pcall(function()
					hum.Health = hum.MaxHealth
				end)
			end
		end
	end
end)

local function setGodMode(on)
	godMode = on
	local hum = getHumanoid(getCharacter())
	if hum then
		pcall(function()
			hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not on)
		end)
		if on then
			pcall(function()
				hum.Health = hum.MaxHealth
			end)
		end
	end
	if on then
		print("⛓️ الدم لا ينتهي: ON")
	else
		print("⛓️ الدم لا ينتهي: OFF")
	end
end

-- ================= السرعة والقفز والركض =================
local function applyMovement()
	local hum = getHumanoid(getCharacter())
	if not hum then return end
	local targetSpeed = walkSpeed
	if infiniteSprint then
		targetSpeed = 30 -- الركض الكامل أثناء الركض اللانهائي
	end
	pcall(function()
		hum.WalkSpeed = targetSpeed
		hum.JumpPower = jumpPower
	end)
end

local function setWalkSpeed(n)
	walkSpeed = n
	applyMovement()
	print("⛓️ السرعة: " .. n)
end

local function setJumpPower(n)
	jumpPower = n
	applyMovement()
	print("⛓️ القفز: " .. n)
end

local function setInfiniteSprint(on)
	infiniteSprint = on
	applyMovement()
	print("⛓️ الركض اللانهائي: " .. (on and "ON" or "OFF"))
end

-- ================= عبور الجدران (Noclip) =================
-- كل إطار يجعل أجزاء شخصيتك غير قابلة للتصادم، فتمشي عبر
-- الجدران والأبواب وفتحات التهوية.
RunService.Stepped:Connect(function()
	if not noclip then return end
	local char = getCharacter()
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function()
				part.CanCollide = false
			end)
		end
	end
end)

local function setNoclip(on)
	noclip = on
	if not on then
		-- أعد التصادم لأجزاء شخصيتك عند الإيقاف
		local char = getCharacter()
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					pcall(function()
						part.CanCollide = true
					end)
				end
			end
		end
	end
	print("⛓️ عبور الجدران: " .. (on and "ON" or "OFF"))
end

-- ================= الطيران =================
local flyBV, flyBG = nil, nil

local function stopFly()
	flying = false
	flyUp = false
	flyDown = false
	local hum = getHumanoid(getCharacter())
	if hum then
		pcall(function()
			hum.PlatformStand = false
		end)
	end
	if flyBV then
		pcall(function() flyBV:Destroy() end)
		flyBV = nil
	end
	if flyBG then
		pcall(function() flyBG:Destroy() end)
		flyBG = nil
	end
end

local function startFly()
	local hrp = getHRP(getCharacter())
	local hum = getHumanoid(getCharacter())
	if not hrp or not hum then return end
	stopFly()
	flying = true
	flyBV = Instance.new("BodyVelocity")
	flyBV.MaxForce = Vector3.new(100000, 100000, 100000)
	flyBV.Velocity = Vector3.new(0, 0, 0)
	flyBV.Parent = hrp
	flyBG = Instance.new("BodyGyro")
	flyBG.MaxTorque = Vector3.new(100000, 100000, 100000)
	flyBG.CFrame = hrp.CFrame
	flyBG.Parent = hrp
	pcall(function()
		hum.PlatformStand = true
	end)
	print("⛓️ الطيران: ON")
end

function toggleFly()
	if flying then
		stopFly()
		print("⛓️ الطيران: OFF")
	else
		startFly()
	end
	refreshUI()
end

RunService.RenderStepped:Connect(function()
	if not flying or not flyBV then return end
	local hrp = getHRP(getCharacter())
	local hum = getHumanoid(getCharacter())
	local cam = workspace.CurrentCamera
	if not hrp or not hum or not cam then return end
	local moveDir = Vector3.new(0, 0, 0)
	local camCF = cam.CFrame
	local forward = camCF.LookVector
	local right = camCF.RightVector
	if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + forward end
	if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - forward end
	if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + right end
	if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - right end
	if UIS:IsKeyDown(Enum.KeyCode.Space) or flyUp then moveDir = moveDir + Vector3.new(0, 1, 0) end
	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) or flyDown then moveDir = moveDir - Vector3.new(0, 1, 0) end
	-- عصا التحكم في الهاتف تعطي اتجاه الحركة مباشرة
	local md = hum.MoveDirection
	if md.Magnitude > 0.1 then
		moveDir = moveDir + Vector3.new(md.X, 0, md.Z)
	end
	if moveDir.Magnitude > 0 then
		moveDir = moveDir.Unit
	end
	flyBV.Velocity = moveDir * flySpeed
	flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + camCF.LookVector)
end)

-- ================= إعادة تطبيق الإعدادات بعد الموت/الظهور =================
local function reapplyOnRespawn(char)
	-- انتظر قليلاً حتى تكتمل الشخصية الجديدة
	task.wait(0.5)
	local hum = getHumanoid(char)
	if not hum then return end
	if godMode then
		pcall(function()
			hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			hum.Health = hum.MaxHealth
		end)
	end
	applyMovement()
	if flying then
		stopFly()
	end
	aimTarget = nil
	followTarget = nil
	refreshUI()
end

LocalPlayer.CharacterAdded:Connect(function(char)
	task.spawn(reapplyOnRespawn, char)
end)

-- ================= كشف اللاعبين (ESP) =================
-- تظليل يظهر من خلال الجدران بلون فريق اللاعب + بطاقة فيها
-- الاسم والمسافة والصحة. الأعداء (الحراس والشرطة) أزرق/بنفسجي،
-- السجناء برتقالي، الهاربون أحمر، المدنيون أخضر.

local function ensurePlayerEsp(plr)
	local char = plr.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end

	local hl = char:FindFirstChild("VPESP_Highlight")
	if not hl then
		hl = Instance.new("Highlight")
		hl.Name = "VPESP_Highlight"
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.FillTransparency = 0.65
		hl.OutlineTransparency = 0.2
		hl.Parent = char
	end
	local col = teamColorFor(plr)
	hl.FillColor = col
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.Enabled = espOn

	local tag = head:FindFirstChild("VPESP_Tag")
	if not tag then
		tag = Instance.new("BillboardGui")
		tag.Name = "VPESP_Tag"
		tag.Size = UDim2.new(0, 180, 0, 44)
		tag.StudsOffset = Vector3.new(0, 3.2, 0)
		tag.AlwaysOnTop = true
		tag.Adornee = head
		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.TextSize = 14
		label.TextStrokeTransparency = 0
		label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.Parent = tag
		tag.Parent = head
	end
	tag.Enabled = espOn
	local label = tag:FindFirstChild("Label")
	if label then
		local hum = getHumanoid(char)
		local hrp = getHRP(char)
		local myHRP = getHRP(getCharacter())
		local dist = 0
		if hrp and myHRP then
			dist = math.floor((hrp.Position - myHRP.Position).Magnitude)
		end
		local hp = hum and math.floor(hum.Health) or 0
		local hpMax = hum and math.floor(hum.MaxHealth) or 100
		label.Text = plr.DisplayName .. " [" .. teamLabelFor(plr) .. "]\n" .. dist .. "m • ❤️ " .. hp .. "/" .. hpMax
	end
end

local function clearPlayerEsp(plr)
	local char = plr and plr.Character
	if not char then return end
	local hl = char:FindFirstChild("VPESP_Highlight")
	if hl then
		pcall(function() hl:Destroy() end)
	end
	local head = char:FindFirstChild("Head")
	if head then
		local tag = head:FindFirstChild("VPESP_Tag")
		if tag then
			pcall(function() tag:Destroy() end)
		end
	end
end

task.spawn(function()
	while true do
		task.wait(0.5)
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				if espOn and isAlive(plr) then
					pcall(ensurePlayerEsp, plr)
				else
					pcall(clearPlayerEsp, plr)
				end
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	pcall(clearPlayerEsp, plr)
end)

local function setEsp(on)
	espOn = on
	if not on then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				pcall(clearPlayerEsp, plr)
			end
		end
	end
	print("⛓️ كشف اللاعبين: " .. (on and "ON" or "OFF"))
end

-- ================= كشف الأغراض (Item ESP) =================
-- يعلّم الأشياء الملقاة على الأرض في السجن: بطاقة، مفك، قميص،
-- بنطال، سترة، سلاح، سكين، شاش، كشاف. لا يعلّم ما في يد لاعب.

local ITEM_KEYWORDS = {
	{ "keycard", "🔑 بطاقة" },
	{ "screwdriver", "🪛 مفك" },
	{ "shirt", "👕 قميص" },
	{ "pants", "👖 بنطال" },
	{ "vest", "🦺 سترة" },
	{ "beretta", "🔫 بيريتا" },
	{ "pistol", "🔫 مسدس" },
	{ "rifle", "🔫 بندقية" },
	{ "gun", "🔫 سلاح" },
	{ "shiv", "🔪 سكين" },
	{ "knife", "🔪 سكين" },
	{ "gauze", "🩹 شاش" },
	{ "flashlight", "🔦 كشاف" },
}

local function isWorldPickup(inst)
	-- تجاهل أي شيء داخل شخصية لاعب أو حقيبته
	local node = inst
	while node and node ~= workspace do
		if node:IsA("Model") then
			local plr = Players:GetPlayerFromCharacter(node)
			if plr then
				return false
			end
		end
		if node:IsA("Backpack") or node:IsA("PlayerGui") then
			return false
		end
		node = node.Parent
	end
	return true
end

local function matchItemKeyword(nameLower)
	for _, pair in ipairs(ITEM_KEYWORDS) do
		if string.find(nameLower, pair[1], 1, true) then
			return pair[2]
		end
	end
	return nil
end

local function tagItem(inst, labelText)
	if inst:FindFirstChild("VPItemESP") then return end
	local anchor = inst
	if inst:IsA("Model") then
		anchor = inst.PrimaryPart or inst:FindFirstChildOfClass("BasePart")
		if not anchor then return end
	end
	local bb = Instance.new("BillboardGui")
	bb.Name = "VPItemESP"
	bb.Size = UDim2.new(0, 140, 0, 26)
	bb.StudsOffset = Vector3.new(0, 2, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = anchor
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 0.3
	label.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	label.Text = labelText .. " • " .. inst.Name
	label.TextColor3 = Color3.fromRGB(255, 220, 100)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Parent = bb
	bb.Parent = inst
end

local function clearItemEsp()
	for _, inst in ipairs(workspace:GetDescendants()) do
		local tag = inst:FindFirstChild("VPItemESP")
		if tag then
			pcall(function() tag:Destroy() end)
		end
	end
end

task.spawn(function()
	while true do
		task.wait(2)
		if not itemEspOn then
			-- لا نمسح كل مرة؛ المسح يتم عند الإيقاف فقط
		else
			for _, inst in ipairs(workspace:GetDescendants()) do
				if inst:IsA("Tool") or inst:IsA("Part") or inst:IsA("MeshPart") or inst:IsA("Model") or inst:IsA("UnionOperation") then
					if isWorldPickup(inst) then
						local label = matchItemKeyword(string.lower(inst.Name))
						if label then
							pcall(tagItem, inst, label)
						end
					end
				end
			end
		end
	end
end)

local function setItemEsp(on)
	itemEspOn = on
	if not on then
		clearItemEsp()
	end
	print("⛓️ كشف الأغراض: " .. (on and "ON" or "OFF"))
end

-- ================= التصويب (التصويب الصامت + التصويب العادي) =================
-- التصويب الصامت هو الوضع الأساسي: الكاميرا لا تتحرك أبداً، بل
-- يوجّه السكربت قراءة الفأرة (mouse.Hit / UnitRay / Target) نحو
-- رأس الهدف، فتذهب طلقات اللعبة إليه مباشرة. يعمل هذا فقط إذا كان
-- نظام إطلاق النار في اللعبة يقرأ الفأرة؛ أما إذا كان يستخدم ريموت
-- إطلاق مخصص أو يتحقق السيرفر من الطلقات فقد لا يعمل — وهذا مذكور
-- بصراحة في ترويسة السكربت.
-- التصويب العادي بالكاميرا خيار ثانوي: يحرّك الكاميرا نحو الهدف
-- أثناء الضغط على زر التصويب (زر الفأرة الأيمن أو Q) أو دائماً.

local silentAimOn = false
local cameraAimOn = false
local silentAimSupported = false
local mouseHookInstalled = false
local mouse = LocalPlayer:GetMouse()

local function getAimPoint()
	if not aimTarget or not isAlive(aimTarget) then return nil, nil end
	local char = aimTarget.Character
	if not char then return nil, nil end
	local head = char:FindFirstChild("Head")
	if not head then return nil, nil end
	return head.Position, head
end

local function installMouseHook()
	if mouseHookInstalled then return end
	if not hookmetamethod then
		print("⛓️ التصويب الصامت غير مدعوم في هذا المنفذ — استخدم التصويب العادي")
		return
	end
	local ok, err = pcall(function()
		local oldIndex
		local function hook(self, key)
			if silentAimOn and (key == "Hit" or key == "UnitRay" or key == "Target") then
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
		warn("⛓️ تعذر تثبيت التصويب الصامت: " .. tostring(err))
	end
end

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
-- لاعب آخر. الأولوية: الأقرب لمركز الشاشة داخل مدى الرؤية، ثم الأقرب مسافة.
local function pickTarget()
	local cam = workspace.CurrentCamera
	if not cam then return nil end
	local camPos = cam.CFrame.Position
	local camDir = cam.CFrame.LookVector
	local enemies = {}
	local others = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and isAlive(plr) then
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

local function setSilentAim(on)
	if on and not silentAimSupported and not mouseHookInstalled then
		installMouseHook()
	end
	if on and not silentAimSupported then
		print("⛓️ التصويب الصامت غير متاح في هذا المنفذ")
		silentAimOn = false
		return
	end
	silentAimOn = on
	if not on then
		aimTarget = nil
	end
	print("⛓️ التصويب الصامت: " .. (on and "ON" or "OFF"))
end

local function setCameraAim(on)
	cameraAimOn = on
	if not on then
		aimTarget = nil
	end
	print("⛓️ التصويب العادي: " .. (on and "ON" or "OFF"))
end

-- دائرة مدى الرؤية على الشاشة (تظهر عند تشغيل أي تصويب)
local ui = {}
local function updateFovCircle()
	local circle = ui.fovCircle
	if not circle then return end
	local show = silentAimOn or cameraAimOn
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

-- حلقة التصويب: إعادة اختيار الهدف كل إطار، وإسقاط القفل فور موت
-- الهدف أو مغادرته أو خروجه من المدى/الرؤية أو اختفائه خلف جدار
-- (عندما يكون فحص الرؤية مفعّلاً)، وتحريك الكاميرا للتصويب العادي.
RunService.RenderStepped:Connect(function()
	if silentAimOn or cameraAimOn then
		aimTarget = pickTarget()
	else
		aimTarget = nil
	end
	updateFovCircle()
	if cameraAimOn and aimTarget then
		local aiming = false
		if aimMode == "always" then
			aiming = true
		else
			aiming = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
				or UIS:IsKeyDown(Enum.KeyCode.Q)
		end
		if aiming then
			local cam = workspace.CurrentCamera
			local head = aimTarget.Character and aimTarget.Character:FindFirstChild("Head")
			if cam and head then
				local desired = CFrame.new(cam.CFrame.Position, head.Position)
				if aimSmooth then
					cam.CFrame = cam.CFrame:Lerp(desired, 0.35)
				else
					cam.CFrame = desired
				end
			end
		end
	end
end)

-- ================= النقل الفوري (Teleport) =================
-- حتى 5 مواقع محفوظة باسم تختاره، والانتقال لأقرب لاعب، واتباع
-- أي لاعب من القائمة (اضغط عليه مرة لتبدأ الاتباع، ومرة أخرى لتتوقف).

local function teleportTo(pos)
	local char = getCharacter()
	if not char then return end
	pcall(function()
		char:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)))
	end)
end

local function saveWaypoint(name)
	if #waypoints >= MAX_WAYPOINTS then
		print("⛓️ وصلت للحد الأقصى (5 مواقع) — احذف واحداً أولاً")
		return false
	end
	local hrp = getHRP(getCharacter())
	if not hrp then return false end
	if not name or name == "" then
		name = "موقع " .. (#waypoints + 1)
	end
	table.insert(waypoints, { name = name, pos = hrp.Position })
	print("⛓️ حُفظ الموقع: " .. name)
	refreshUI()
	return true
end

local function deleteWaypoint(index)
	if waypoints[index] then
		print("⛓️ حُذف الموقع: " .. waypoints[index].name)
		table.remove(waypoints, index)
		refreshUI()
	end
end

local function teleportToNearestPlayer()
	local myHRP = getHRP(getCharacter())
	if not myHRP then return end
	local best, bestD = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and isAlive(plr) then
			local th = getHRP(plr.Character)
			if th then
				local d = (th.Position - myHRP.Position).Magnitude
				if d < bestD then
					best, bestD = plr, d
				end
			end
		end
	end
	if best then
		local th = getHRP(best.Character)
		if th then
			teleportTo(th.Position)
		end
		print("⛓️ انتقلت إلى: " .. best.DisplayName)
	else
		print("⛓️ لا يوجد لاعبون آخرون")
	end
end

-- حلقة الاتباع: تنقلك باستمرار لمكان اللاعب المتبوع حتى تتوقف
task.spawn(function()
	while true do
		task.wait(0.25)
		if followTarget then
			if isAlive(followTarget) then
				local th = getHRP(followTarget.Character)
				if th then
					teleportTo(th.Position + Vector3.new(2, 0, 2))
				end
			else
				followTarget = nil
				refreshUI()
			end
		end
	end
end)

local function toggleFollow(plr)
	if followTarget == plr then
		followTarget = nil
		print("⛓️ توقفت عن اتباع " .. plr.DisplayName)
	else
		followTarget = plr
		print("⛓️ تتبع: " .. plr.DisplayName .. " (اضغط عليه مرة أخرى للتوقف)")
	end
	refreshUI()
end

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

	-- دائرة مدى الرؤية (تظهر عند تشغيل أي تصويب)
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

	-- أزرار الصعود والنزول أثناء الطيران (تظهر فقط عند الطيران)
	ui.flyUpBtn = Instance.new("TextButton")
	ui.flyUpBtn.Name = "FlyUp"
	ui.flyUpBtn.Size = UDim2.new(0, 60, 0, 60)
	ui.flyUpBtn.Position = UDim2.new(1, -88, 1, -340)
	ui.flyUpBtn.BackgroundColor3 = GOLD
	ui.flyUpBtn.Text = "▲"
	ui.flyUpBtn.TextSize = 26
	ui.flyUpBtn.TextColor3 = Color3.fromRGB(25, 18, 5)
	ui.flyUpBtn.Font = Enum.Font.GothamBold
	ui.flyUpBtn.Visible = false
	ui.flyUpBtn.Parent = screenGui
	addGoldGradient(ui.flyUpBtn)
	local fuc = Instance.new("UICorner")
	fuc.CornerRadius = UDim.new(1, 0)
	fuc.Parent = ui.flyUpBtn
	ui.flyUpBtn.MouseButton1Down:Connect(function() flyUp = true end)
	ui.flyUpBtn.MouseButton1Up:Connect(function() flyUp = false end)

	ui.flyDownBtn = Instance.new("TextButton")
	ui.flyDownBtn.Name = "FlyDown"
	ui.flyDownBtn.Size = UDim2.new(0, 60, 0, 60)
	ui.flyDownBtn.Position = UDim2.new(1, -164, 1, -340)
	ui.flyDownBtn.BackgroundColor3 = GOLD
	ui.flyDownBtn.Text = "▼"
	ui.flyDownBtn.TextSize = 26
	ui.flyDownBtn.TextColor3 = Color3.fromRGB(25, 18, 5)
	ui.flyDownBtn.Font = Enum.Font.GothamBold
	ui.flyDownBtn.Visible = false
	ui.flyDownBtn.Parent = screenGui
	local fdc2 = Instance.new("UICorner")
	fdc2.CornerRadius = UDim.new(1, 0)
	fdc2.Parent = ui.flyDownBtn
	ui.flyDownBtn.MouseButton1Down:Connect(function() flyDown = true end)
	ui.flyDownBtn.MouseButton1Up:Connect(function() flyDown = false end)

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

	-- الحالة
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

	-- 💪 قوتي
	sectionLabel(scroll, "💪 قوتي")
	makeToggle(scroll, "god", "دم لا ينتهي", false, function(v) setGodMode(v) end)
	makeToggle(scroll, "fly", "الطيران", false, function(v)
		if v then startFly() else stopFly() end
	end)
	sectionLabel(scroll, "💨 سرعة الطيران")
	local rowFlySpeed = makeRow(scroll)
	ui.flySpeedBtns = {}
	for _, s in ipairs({16, 50, 100}) do
		local b = makeButton(rowFlySpeed, tostring(s), 96)
		addPress(b)
		ui.flySpeedBtns[s] = b
		b.MouseButton1Click:Connect(function() flySpeed = s end)
	end

	-- 🏃 الحركة
	sectionLabel(scroll, "🏃 الحركة")
	sectionLabel(scroll, "السرعة")
	local rowSpeed = makeRow(scroll)
	ui.speedBtns = {}
	for _, s in ipairs({16, 22, 30, 50}) do
		local b = makeButton(rowSpeed, tostring(s), 72)
		addPress(b)
		ui.speedBtns[s] = b
		b.MouseButton1Click:Connect(function() setWalkSpeed(s) end)
	end
	sectionLabel(scroll, "القفز")
	local rowJump = makeRow(scroll)
	ui.jumpBtns = {}
	for _, j in ipairs({50, 70, 100}) do
		local b = makeButton(rowJump, tostring(j), 96)
		addPress(b)
		ui.jumpBtns[j] = b
		b.MouseButton1Click:Connect(function() setJumpPower(j) end)
	end
	makeToggle(scroll, "sprint", "ركض لا نهائي", false, function(v) setInfiniteSprint(v) end)
	makeToggle(scroll, "noclip", "عبور الجدران", false, function(v) setNoclip(v) end)

	-- 👁️ الكشف
	sectionLabel(scroll, "👁️ الكشف")
	makeToggle(scroll, "esp", "كشف اللاعبين (ألوان الفرق)", false, function(v) setEsp(v) end)
	makeToggle(scroll, "itemesp", "كشف الأغراض", false, function(v) setItemEsp(v) end)

	-- 🎯 التصويب الصامت
	sectionLabel(scroll, "🎯 التصويب الصامت")
	makeToggle(scroll, "silentAim", "تصويب صامت (الكاميرا ثابتة)", false, function(v) setSilentAim(v) end)
	makeToggle(scroll, "cameraAim", "تصويب عادي بالكاميرا", false, function(v) setCameraAim(v) end)
	sectionLabel(scroll, "مدى الرؤية (درجات)")
	local rowFov = makeRow(scroll)
	ui.fovBtns = {}
	for _, f in ipairs({45, 60, 90, 120, 180}) do
		local b = makeButton(rowFov, tostring(f) .. "°", 58)
		addPress(b)
		ui.fovBtns[f] = b
		b.MouseButton1Click:Connect(function() aimFov = f end)
	end
	sectionLabel(scroll, "أقصى مسافة (ستود)")
	local rowRange = makeRow(scroll)
	ui.rangeBtns = {}
	for _, r in ipairs({100, 200, 500, 1000}) do
		local b = makeButton(rowRange, tostring(r), 72)
		addPress(b)
		ui.rangeBtns[r] = b
		b.MouseButton1Click:Connect(function() aimRange = r end)
	end
	makeToggle(scroll, "smooth", "تصويب ناعم (بدون قفز)", true, function(v) aimSmooth = v end)
	makeToggle(scroll, "visOnly", "فقط إذا كان الهدف مرئياً", true, function(v)
		aimVisibleOnly = v
		if v then aimThroughWalls = false end
	end)
	makeToggle(scroll, "throughWalls", "التصويب عبر الجدران", false, function(v)
		aimThroughWalls = v
		if v then aimVisibleOnly = false end
	end)
	sectionLabel(scroll, "وضع التصويب العادي")
	local rowAimMode = makeRow(scroll)
	ui.aimModeBtns = {}
	local modes = {{"hold", "اضغط للتصويب"}, {"always", "دائم"}}
	for _, m in ipairs(modes) do
		local b = makeButton(rowAimMode, m[2], 146)
		addPress(b)
		ui.aimModeBtns[m[1]] = b
		b.MouseButton1Click:Connect(function() aimMode = m[1] end)
	end

	-- 🗺️ النقل
	sectionLabel(scroll, "🗺️ النقل الفوري")
	ui.wpBox = Instance.new("TextBox")
	ui.wpBox.Size = UDim2.new(1, 0, 0, 42)
	ui.wpBox.BackgroundColor3 = CARD_DARK
	ui.wpBox.TextColor3 = TEXT_WHITE
	ui.wpBox.PlaceholderText = "اسم الموقع... (فارغ = اسم تلقائي)"
	ui.wpBox.PlaceholderColor3 = TEXT_MUTED
	ui.wpBox.Font = Enum.Font.GothamBold
	ui.wpBox.TextSize = 15
	ui.wpBox.TextXAlignment = Enum.TextXAlignment.Right
	ui.wpBox.ClearTextOnFocus = false
	ui.wpBox.Parent = scroll
	local wbc = Instance.new("UICorner")
	wbc.CornerRadius = UDim.new(0, 10)
	wbc.Parent = ui.wpBox
	local rowSave = makeRow(scroll)
	ui.saveWpBtn = makeButton(rowSave, "💾 حفظ موقعي الحالي", 200, true)
	addPress(ui.saveWpBtn)
	ui.saveWpBtn.MouseButton1Click:Connect(function()
		saveWaypoint(ui.wpBox.Text)
		ui.wpBox.Text = ""
	end)
	ui.wpList = Instance.new("Frame")
	ui.wpList.Size = UDim2.new(1, 0, 0, 0)
	ui.wpList.BackgroundTransparency = 1
	ui.wpList.Parent = scroll
	local wpLayout = Instance.new("UIListLayout")
	wpLayout.Padding = UDim.new(0, 4)
	wpLayout.Parent = ui.wpList
	local rowNearest = makeRow(scroll)
	ui.nearestBtn = makeButton(rowNearest, "📍 انتقل لأقرب لاعب", 200, true)
	addPress(ui.nearestBtn)
	ui.nearestBtn.MouseButton1Click:Connect(teleportToNearestPlayer)

	-- 👤 اللاعبون
	sectionLabel(scroll, "👤 اللاعبون — اضغط على أي لاعب لاتباعه")
	local rowPlayers = makeRow(scroll)
	ui.refreshBtn = makeButton(rowPlayers, "🔄 تحديث القائمة", 200)
	addPress(ui.refreshBtn)
	ui.refreshBtn.MouseButton1Click:Connect(function()
		refreshPlayerList(true)
	end)
	ui.playerList = Instance.new("Frame")
	ui.playerList.Size = UDim2.new(1, 0, 0, 0)
	ui.playerList.BackgroundTransparency = 1
	ui.playerList.Parent = scroll
	local plLayout = Instance.new("UIListLayout")
	plLayout.Padding = UDim.new(0, 4)
	plLayout.Parent = ui.playerList

	-- تذييل: تطوير الصادق
	local footer = Instance.new("TextLabel")
	footer.Size = UDim2.new(1, 0, 0, 26)
	footer.BackgroundTransparency = 1
	footer.Text = "الصادق • Valley Prison v1"
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
function refreshUI()
	if not ui.statusLabel then return end
	local parts = {}
	table.insert(parts, godMode and "دم ON" or "دم OFF")
	table.insert(parts, flying and "طيران ON" or "طيران OFF")
	table.insert(parts, (silentAimOn and "صامت ON" or "صامت OFF"))
	table.insert(parts, espOn and "كشف ON" or "كشف OFF")
	table.insert(parts, "سرعة " .. walkSpeed)
	if followTarget then
		table.insert(parts, "أتبع: " .. followTarget.DisplayName)
	end
	ui.statusLabel.Text = "⛓️ " .. table.concat(parts, " • ")

	local function syncToggle(key, state)
		local t = ui.toggles and ui.toggles[key]
		if t then t.set(state) end
	end
	syncToggle("god", godMode)
	syncToggle("fly", flying)
	syncToggle("sprint", infiniteSprint)
	syncToggle("noclip", noclip)
	syncToggle("esp", espOn)
	syncToggle("itemesp", itemEspOn)
	syncToggle("silentAim", silentAimOn)
	syncToggle("cameraAim", cameraAimOn)
	syncToggle("smooth", aimSmooth)
	syncToggle("visOnly", aimVisibleOnly)
	syncToggle("throughWalls", aimThroughWalls)

	for s, b in pairs(ui.flySpeedBtns or {}) do setActive(b, flySpeed == s) end
	for s, b in pairs(ui.speedBtns or {}) do setActive(b, walkSpeed == s) end
	for j, b in pairs(ui.jumpBtns or {}) do setActive(b, jumpPower == j) end
	for f, b in pairs(ui.fovBtns or {}) do setActive(b, aimFov == f) end
	for r, b in pairs(ui.rangeBtns or {}) do setActive(b, aimRange == r) end
	for m, b in pairs(ui.aimModeBtns or {}) do setActive(b, aimMode == m) end

	if ui.flyUpBtn then ui.flyUpBtn.Visible = flying end
	if ui.flyDownBtn then ui.flyDownBtn.Visible = flying end

	refreshWaypoints()

	if ui.playerButtons then
		for _, plr in ipairs(Players:GetPlayers()) do
			local btn = ui.playerButtons[plr.Name]
			if btn then
				setActive(btn, followTarget == plr)
			end
		end
	end
end

function refreshWaypoints()
	if not ui.wpList then return end
	for _, child in ipairs(ui.wpList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	for i, wp in ipairs(waypoints) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 46)
		row.BackgroundTransparency = 1
		row.Parent = ui.wpList
		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		layout.Padding = UDim.new(0, 6)
		layout.Parent = row
		local tpBtn = makeButton(row, "📍 " .. wp.name, 236)
		addPress(tpBtn)
		tpBtn.MouseButton1Click:Connect(function()
			teleportTo(wp.pos)
			print("⛓️ انتقلت إلى: " .. wp.name)
		end)
		local delBtn = makeButton(row, "✕", 46)
		delBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
		addPress(delBtn)
		delBtn.MouseButton1Click:Connect(function()
			deleteWaypoint(i)
		end)
	end
	ui.wpList.Size = UDim2.new(1, 0, 0, #waypoints * 50)
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
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 40)
		btn.BackgroundColor3 = BTN_DARK
		btn.TextColor3 = TEXT_WHITE
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 15
		btn.Text = "👤 " .. (plr and plr.DisplayName or name) .. " [" .. teamLabelFor(plr) .. "]"
		btn.Parent = ui.playerList
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 10)
		c.Parent = btn
		addPress(btn)
		ui.playerButtons[name] = btn
		btn.MouseButton1Click:Connect(function()
			if plr then
				toggleFollow(plr)
			end
		end)
	end
	ui.playerList.Size = UDim2.new(1, 0, 0, #names * 44)
	refreshUI()
end

-- ================= الأوامر من الشات (احتياط — القائمة هي الأساس) =================
local function printHelp()
	print("⛓️ أوامر الصادق (القائمة باللمس هي الأساس):")
	print(";god, ;fly, ;speed <16/22/30/50>, ;jump <50/70/100>, ;sprint")
	print(";noclip, ;esp, ;itemesp, ;menu, ;help")
	print(";aim (تصويب صامت), ;aimcam (تصويب عادي), ;aimfov <30-180>")
	print(";aimrange <100-1000>, ;aimsmooth, ;aimvis, ;aimwall, ;aimmode")
	print(";tp <اسم>, ;nearest, ;follow <اسم>, ;stop")
	print(";wp save <اسم>, ;wp <اسم>, ;help")
end

LocalPlayer.Chatted:Connect(function(msg)
	if msg:sub(1, 1) ~= PREFIX then return end
	local parts = string.split(msg:sub(2), " ")
	local cmd = string.lower(parts[1] or "")

	if cmd == "god" then
		setGodMode(not godMode)
	elseif cmd == "fly" then
		toggleFly()
	elseif cmd == "speed" then
		local n = tonumber(parts[2])
		if n then setWalkSpeed(clampNum(n, 16, 50)) end
	elseif cmd == "jump" then
		local n = tonumber(parts[2])
		if n then setJumpPower(clampNum(n, 50, 100)) end
	elseif cmd == "sprint" then
		setInfiniteSprint(not infiniteSprint)
	elseif cmd == "noclip" then
		setNoclip(not noclip)
	elseif cmd == "esp" then
		setEsp(not espOn)
	elseif cmd == "itemesp" then
		setItemEsp(not itemEspOn)
	elseif cmd == "aim" then
		setSilentAim(not silentAimOn)
	elseif cmd == "aimcam" then
		setCameraAim(not cameraAimOn)
	elseif cmd == "aimfov" then
		local n = tonumber(parts[2])
		if n then
			aimFov = clampNum(n, 30, 180)
			print("⛓️ مدى الرؤية: " .. aimFov .. "°")
		end
	elseif cmd == "aimrange" then
		local n = tonumber(parts[2])
		if n then
			aimRange = clampNum(n, 100, 1000)
			print("⛓️ أقصى مسافة: " .. aimRange)
		end
	elseif cmd == "aimsmooth" then
		aimSmooth = not aimSmooth
	elseif cmd == "aimvis" then
		aimVisibleOnly = not aimVisibleOnly
		if aimVisibleOnly then aimThroughWalls = false end
	elseif cmd == "aimwall" then
		aimThroughWalls = not aimThroughWalls
		if aimThroughWalls then aimVisibleOnly = false end
	elseif cmd == "aimmode" then
		aimMode = aimMode == "hold" and "always" or "hold"
		print("⛓️ وضع التصويب العادي: " .. aimMode)
	elseif cmd == "tp" then
		local target = findPlayerByName(parts[2] or "")
		if target and isAlive(target) then
			local th = getHRP(target.Character)
			if th then
				teleportTo(th.Position)
				print("⛓️ انتقلت إلى: " .. target.DisplayName)
			end
		else
			print("⛓️ لم أجد لاعباً بهذا الاسم")
		end
	elseif cmd == "nearest" then
		teleportToNearestPlayer()
	elseif cmd == "follow" then
		local target = findPlayerByName(parts[2] or "")
		if target then
			toggleFollow(target)
		else
			print("⛓️ لم أجد لاعباً بهذا الاسم")
		end
	elseif cmd == "stop" then
		followTarget = nil
		aimTarget = nil
		print("⛓️ توقفت عن الاتباع والتصويب")
	elseif cmd == "wp" then
		if string.lower(parts[2] or "") == "save" then
			local name = table.concat(parts, " ", 3)
			saveWaypoint(name)
		else
			local query = string.lower(table.concat(parts, " ", 2))
			local found = nil
			for _, wp in ipairs(waypoints) do
				if string.lower(wp.name) == query then
					found = wp
					break
				end
			end
			if not found then
				local idx = tonumber(parts[2])
				if idx then found = waypoints[idx] end
			end
			if found then
				teleportTo(found.pos)
				print("⛓️ انتقلت إلى: " .. found.name)
			else
				print("⛓️ لم أجد موقعاً بهذا الاسم")
			end
		end
	elseif cmd == "menu" then
		if menuFrame then
			menuFrame.Visible = not menuFrame.Visible
		end
	elseif cmd == "help" then
		printHelp()
	end
	refreshUI()
end)

-- ================= التشغيل =================
print("⛓️ سكربت الصادق v1 يعمل! — اضغط زر ⛓️ لفتح القائمة")
printHelp()
installMouseHook()
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
