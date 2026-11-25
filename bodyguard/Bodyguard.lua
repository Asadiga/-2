--[[
    🛡️ سكربت البودي جارد — Bodyguard Script v4
    ============================================================
    يعمل على Solara (وغيره من المنفذات) — يستخدم دوالاً قياسية
    فقط، وأي ميزة لا يدعمها منفذك يتخطاها السكربت تلقائياً.

    قائمة تحكم كاملة باللمس (بدون كتابة أوامر):
    • زر عائم 🛡️ يفتح القائمة ويغلقها
    • تشغيل/إيقاف، متابعة/وقوف، إحضار، زر طوارئ 🚨
    • عدد الحراس (1-4)، السلاح (بندقية/سيف/بدون)، السرعة،
      مسافة الحراسة، التشكيل (خط/دائرة)
    • حماية: مضاد للدفع، مضاد للسقوط، الرد التلقائي، التخفي
    • قائمة بكل اللاعبين في السيرفر — اضغط على أي لاعب لمهاجمته
    • صحة كل حارس، ومن يتهجم عليك الآن، وتنبيه عند الهجوم عليك
    • دم لا ينتهي (God Mode) + طيران بأزرار لمس ▲▼
    • أسلحة لك أنت: بندقية وسيف — جهّزها واضرب بها

    كيف يعمل:
    • الحراس ببدلات سوداء ومعهم أسلحة، يتبعونك أينما ذهبت
    • لا يهاجمون أحداً من تلقاء أنفسهم — فقط من يتهجم عليك
      (إذا نقصت صحتك أو لمسك لاعب، يحددونه كمهاجم ويطاردونه
      ويطلقون عليه النار ويدفعونه بعيداً عنك لمدة 10 ثوانٍ)
    • حماية ضد الطرد (Anti-Kick) + إعادة إنشاء الواجهة تلقائياً

    طريقة التشغيل:
    1) انسخ هذا السكربت كاملاً
    2) الصقه في Solara واضغط تشغيل (Execute) وأنت داخل أي لعبة
    3) ستظهر قائمة التحكم — اسحبها لأي مكان يعجبك

    الأوامر من الشات ما زالت تعمل أيضاً (احتياط):
    ;guards on/off, ;follow, ;stay, ;attack <اسم>, ;stop, ;bring,
    ;count <1-4>, ;weapon <rifle/sword/none>, ;panic, ;speed <n>,
    ;circle, ;line, ;antifling, ;antivoid, ;stealth, ;menu, ;god, ;fly,
    ;gun, ;sword, ;help

    ملاحظات مهمة بصراحة:
    • هذا سكربت يعمل من جهازك (Client) — الحراس يظهرون لك أنت
      بشكل أساسي، وفي معظم الألعاب المحمية لا يستطيعون إلحاق ضرر
      حقيقي باللاعبين الآخرين لأن السيرفر يتحقق من الضربات، لكنهم
      يتبعونك ويطاردون من يتهجم عليك ويحاولون دفعه.
    • حماية الطرد تمنع أوامر الطرد التي تأتي من جهازك (Kick) —
      أما الباند من السيرفر فلا يوجد أي سكربت يستطيع منعه، لأن
      القرار يتم في السيرفر وليس في جهازك. السكربت يقلل الخطر:
      لا يرسل أي شيء للسيرفر، ولا يهاجم إلا من يتهجم عليك.
    • إذا أردت حراساً حقيقيين يراهم الجميع ويقاتلون فعلاً، يجب أن
      يكونوا سكربت سيرفر داخل لعبتك أنت (مثل فيلدورا) — أخبرني.
    • الفلوس وشراء أشياء الروبكس مجاناً: مستحيل في أي ماب، لأن
      الفلوس والمشتريات محفوظة في سيرفر اللعبة وليس في جهازك،
      وأي سكربت يدّعي ذلك فهو نصب لسرقة حسابك. في لعبتك أنت
      (فيلدورا) تستطيع إعطاء نفسك فلوساً وأشياء مجاناً لأنك المالك.
    • الدم الذي لا ينتهي يعمل في الألعاب التي لا تتحقق من الصحة
      في السيرفر؛ وفي الألعاب المحمية قد لا يعمل.
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
			if method == "Kick" then
				warn("🛡️ تم منع محاولة طرد!")
				return nil
			end
			return oldNamecall(self, ...)
		end
		if newcclosure then
			hook = newcclosure(hook)
		end
		oldNamecall = hookmetamethod(game, "__namecall", hook)
		print("🛡️ حماية ضد الطرد: مفعّلة")
	end
end)

-- ================= الإعدادات =================
local PREFIX = ";"
local DEFAULT_GUARD_COUNT = 2
local MAX_GUARDS = 4
local TELEPORT_DISTANCE = 60
local MARK_DURATION = 10
local SHOOT_RANGE = 30
local SHOOT_HOLD = 12

-- ================= الحالة =================
local guardsEnabled = true
local mode = "follow" -- follow | stay | attack
local attackTargetName = nil
local guardCount = DEFAULT_GUARD_COUNT
local currentWeapon = "rifle" -- rifle | sword | none
local formation = "line" -- line | circle
local formationDistance = 5 -- 3 | 5 | 8
local guardSpeed = 22 -- 16 | 22 | 30
local antiFling = false
local antiVoid = false
local autoRetaliate = true
local stealth = false
local godMode = false
local flying = false
local flySpeed = 50
local flyUp = false
local flyDown = false

local guards = {}
local currentThreat = nil
local markedAttackers = {}

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

local function markAttacker(plr)
	if plr and plr ~= LocalPlayer then
		markedAttackers[plr] = tick() + MARK_DURATION
	end
end

-- ================= إنشاء حارس =================
local function addNameTag(model, text)
	local head = model:FindFirstChild("Head")
	if not head then return end
	local bb = Instance.new("BillboardGui")
	bb.Name = "GuardTag"
	bb.Size = UDim2.new(0, 140, 0, 36)
	bb.StudsOffset = Vector3.new(0, 2.6, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = head
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.Parent = bb
	bb.Parent = model
end

local function dressAsBodyguard(model)
	for _, v in ipairs(model:GetDescendants()) do
		if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("Accessory") then
			v:Destroy()
		end
	end
	local bc = model:FindFirstChildOfClass("BodyColors")
	if bc then
		local black = Color3.fromRGB(15, 15, 15)
		bc.TorsoColor3 = black
		bc.LeftArmColor3 = black
		bc.RightArmColor3 = black
		bc.LeftLegColor3 = black
		bc.RightLegColor3 = black
	end
end

local function weldPartsToBody(gun, body)
	for _, p in ipairs(gun:GetChildren()) do
		if p ~= body then
			local w = Instance.new("Weld")
			w.Part0 = body
			w.Part1 = p
			w.C0 = body.CFrame:Inverse() * p.CFrame
			w.Parent = body
		end
	end
end

local function weldToHand(model, body)
	local rightArm = model:FindFirstChild("Right Arm")
	if not rightArm then return end
	local weld = Instance.new("Weld")
	weld.Part0 = rightArm
	weld.Part1 = body
	weld.C0 = CFrame.new(0, -1.3, 0) * CFrame.Angles(math.rad(-90), 0, 0)
	weld.Parent = body
end

local function giveRifle(model)
	local gun = Instance.new("Model")
	gun.Name = "Rifle"
	local function makePart(size, color, cf)
		local p = Instance.new("Part")
		p.Size = size
		p.Color = color
		p.Material = Enum.Material.Metal
		p.CanCollide = false
		p.Anchored = false
		p.CFrame = cf
		p.Parent = gun
		return p
	end
	local body = makePart(Vector3.new(0.25, 0.35, 1.6), Color3.fromRGB(20, 20, 20), CFrame.new(0, 0, 0))
	makePart(Vector3.new(0.12, 0.12, 0.8), Color3.fromRGB(45, 45, 45), CFrame.new(0, 0.05, -1.1))
	makePart(Vector3.new(0.2, 0.5, 0.3), Color3.fromRGB(60, 40, 20), CFrame.new(0, -0.3, 0.6))
	makePart(Vector3.new(0.15, 0.4, 0.2), Color3.fromRGB(20, 20, 20), CFrame.new(0, -0.35, -0.2))
	weldPartsToBody(gun, body)
	weldToHand(model, body)
	gun.Parent = model
	return body
end

local function giveSword(model)
	local gun = Instance.new("Model")
	gun.Name = "Sword"
	local function makePart(size, color, cf, material)
		local p = Instance.new("Part")
		p.Size = size
		p.Color = color
		p.Material = material or Enum.Material.Metal
		p.CanCollide = false
		p.Anchored = false
		p.CFrame = cf
		p.Parent = gun
		return p
	end
	local blade = makePart(Vector3.new(0.12, 0.3, 1.8), Color3.fromRGB(200, 200, 210), CFrame.new(0, 0, -0.9), Enum.Material.Neon)
	makePart(Vector3.new(0.18, 0.18, 0.3), Color3.fromRGB(60, 40, 20), CFrame.new(0, 0, 0.25))
	makePart(Vector3.new(0.3, 0.08, 0.1), Color3.fromRGB(255, 200, 0), CFrame.new(0, 0, 0.05))
	weldPartsToBody(gun, blade)
	weldToHand(model, blade)
	gun.Parent = model
	return blade
end

local function applyStealth(guard)
	if not guard.model then return end
	local transparency = stealth and 0.7 or 0
	for _, v in ipairs(guard.model:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = transparency
		elseif v:IsA("BillboardGui") then
			v.Enabled = not stealth
		end
	end
end

local function createGuardModel(index)
	local model = nil
	for _ = 1, 3 do
		local ok, desc = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
		end)
		if ok and desc then
			local ok2, m = pcall(function()
				return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
			end)
			if ok2 and m then
				model = m
				break
			end
		end
		task.wait(1)
	end
	if not model then
		warn("🛡️ تعذر إنشاء الحارس رقم " .. index)
		return nil
	end

	model.Name = "Bodyguard_" .. index
	dressAsBodyguard(model)

	local hum = model:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = guardSpeed
		hum.JumpPower = 50
		hum.MaxHealth = 100
		hum.Health = 100
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end

	addNameTag(model, "🛡️ حارس " .. index)

	local ownerHRP = getHRP(getCharacter())
	if ownerHRP then
		model:PivotTo(ownerHRP.CFrame * CFrame.new(index == 1 and -4 or 4, 0, 3))
	end
	model.Parent = workspace
	return model
end

-- ================= حركة وقتال الحارس =================
local function getMotor(torso, name)
	if not torso then return nil end
	return torso:FindFirstChild(name)
end

local function setMotorC0(motor, pos, angleX)
	if motor then
		motor.C0 = CFrame.new(pos.X, pos.Y, pos.Z) * CFrame.Angles(angleX, 0, 0)
	end
end

local function swingLimbs(guard, phase)
	local torso = guard.model:FindFirstChild("Torso")
	if not torso then return end
	local s = math.sin(phase) * 0.55
	setMotorC0(getMotor(torso, "Right Shoulder"), Vector3.new(1, 0.5, 0), s)
	setMotorC0(getMotor(torso, "Left Shoulder"), Vector3.new(-1, 0.5, 0), -s)
	setMotorC0(getMotor(torso, "Right Hip"), Vector3.new(1, -1, 0), -s)
	setMotorC0(getMotor(torso, "Left Hip"), Vector3.new(-1, -1, 0), s)
end

local function resetLimbs(guard)
	local torso = guard.model:FindFirstChild("Torso")
	if not torso then return end
	setMotorC0(getMotor(torso, "Right Shoulder"), Vector3.new(1, 0.5, 0), 0)
	setMotorC0(getMotor(torso, "Left Shoulder"), Vector3.new(-1, 0.5, 0), 0)
	setMotorC0(getMotor(torso, "Right Hip"), Vector3.new(1, -1, 0), 0)
	setMotorC0(getMotor(torso, "Left Hip"), Vector3.new(-1, -1, 0), 0)
end

local function aimPose(guard, aiming)
	local torso = guard.model:FindFirstChild("Torso")
	local shoulder = getMotor(torso, "Right Shoulder")
	if not shoulder then return end
	if aiming then
		shoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
	else
		shoulder.C0 = CFrame.new(1, 0.5, 0)
	end
end

local function swingArm(guard, angle)
	local torso = guard.model:FindFirstChild("Torso")
	local shoulder = getMotor(torso, "Right Shoulder")
	if not shoulder then return end
	local orig = shoulder.C0
	pcall(function()
		shoulder.C0 = orig * CFrame.Angles(math.rad(angle), 0, 0)
		task.wait(0.15)
		shoulder.C0 = orig
	end)
end

local function pushTarget(targetChar)
	local hrp = getHRP(targetChar)
	local ownerHRP = getHRP(getCharacter())
	if not hrp or not ownerHRP then return end
	local dir = hrp.Position - ownerHRP.Position
	if dir.Magnitude < 0.1 then dir = Vector3.new(0, 0, 1) end
	pcall(function()
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(100000, 100000, 100000)
		bv.Velocity = dir.Unit * 60 + Vector3.new(0, 45, 0)
		bv.Parent = hrp
		task.delay(0.25, function()
			pcall(function() bv:Destroy() end)
		end)
	end)
end

local function fireBullet(guard, targetChar)
	local targetHRP = getHRP(targetChar)
	if not targetHRP or not guard.weaponPart then return end
	local startPos = guard.weaponPart.CFrame * CFrame.new(0, 0, -1.6)
	local endPos = targetHRP.Position
	task.spawn(function()
		local bullet = Instance.new("Part")
		bullet.Name = "Bullet"
		bullet.Size = Vector3.new(0.2, 0.2, 1.2)
		bullet.Color = Color3.fromRGB(255, 220, 0)
		bullet.Material = Enum.Material.Neon
		bullet.CanCollide = false
		bullet.Anchored = true
		bullet.CFrame = CFrame.new(startPos, endPos)
		bullet.Parent = workspace
		local steps = 8
		for i = 1, steps do
			local t = i / steps
			local pos = startPos:Lerp(endPos, t)
			bullet.CFrame = CFrame.new(pos, endPos)
			task.wait(0.015)
		end
		pcall(function() bullet:Destroy() end)
	end)
	task.delay(0.15, function()
		pushTarget(targetChar)
	end)
end

local function formationPos(index, ownerHRP)
	if formation == "circle" then
		local angle = (index - 1) / guardCount * math.pi * 2
		local offset = Vector3.new(math.cos(angle) * formationDistance, 0, math.sin(angle) * formationDistance)
		return ownerHRP.Position + offset
	else
		local spread = (index - (guardCount + 1) / 2) * 3
		return (ownerHRP.CFrame * CFrame.new(spread, 0, formationDistance)).Position
	end
end

local function guardLoop(guard, index)
	local hum = guard.humanoid
	local hrp = guard.hrp
	local phase = 0
	local lastPos = hrp and hrp.Position or Vector3.new(0, 0, 0)

	while guard.model.Parent and hum and hum.Health > 0 do
		local ownerChar = getCharacter()
		local ownerHRP = getHRP(ownerChar)

		if ownerHRP and hrp then
			local distToOwner = (hrp.Position - ownerHRP.Position).Magnitude

			if distToOwner > TELEPORT_DISTANCE then
				guard.model:PivotTo(ownerHRP.CFrame * CFrame.new(index == 1 and -4 or 4, 0, 3))
			else
				local targetChar = nil
				if mode == "attack" and attackTargetName then
					local targetPlr = findPlayerByName(attackTargetName)
					if targetPlr and targetPlr.Character then
						targetChar = targetPlr.Character
					else
						mode = "follow"
						attackTargetName = nil
						print("🛡️ الهدف غادر — عاد الحراس للمتابعة")
					end
				elseif currentThreat and currentThreat.Character then
					targetChar = currentThreat.Character
				end

				local engaging = targetChar ~= nil
				if engaging then
					local targetHRP = getHRP(targetChar)
					if targetHRP then
						local dist = (hrp.Position - targetHRP.Position).Magnitude
						if currentWeapon == "rifle" then
							aimPose(guard, true)
							if dist > SHOOT_HOLD then
								hum:MoveTo(targetHRP.Position)
							elseif tick() - guard.lastShot > 0.5 and dist <= SHOOT_RANGE then
								guard.lastShot = tick()
								fireBullet(guard, targetChar)
							end
						elseif currentWeapon == "sword" then
							if dist > 5 then
								hum:MoveTo(targetHRP.Position)
							elseif tick() - guard.lastShot > 0.6 then
								guard.lastShot = tick()
								swingArm(guard, -120)
								pushTarget(targetChar)
							end
						else -- بدون سلاح: لكم ودفع
							if dist > 4 then
								hum:MoveTo(targetHRP.Position)
							elseif tick() - guard.lastShot > 0.6 then
								guard.lastShot = tick()
								swingArm(guard, -100)
								pushTarget(targetChar)
							end
						end
					end
				else
					aimPose(guard, false)
					if mode == "follow" then
						hum:MoveTo(formationPos(index, ownerHRP))
					end
				end
			end

			if not currentThreat and not (mode == "attack" and attackTargetName) then
				if (hrp.Position - lastPos).Magnitude > 0.15 then
					phase = phase + 0.35
					swingLimbs(guard, phase)
				else
					resetLimbs(guard)
				end
			end
			lastPos = hrp.Position
		end
		task.wait(0.25)
	end

	task.wait(3)
	if guardsEnabled and guards[index] == guard then
		spawnGuard(index)
	end
end

function spawnGuard(index)
	local old = guards[index]
	if old and old.model then
		pcall(function() old.model:Destroy() end)
	end
	local model = createGuardModel(index)
	if not model then return end
	local weaponPart = nil
	if currentWeapon == "rifle" then
		weaponPart = giveRifle(model)
	elseif currentWeapon == "sword" then
		weaponPart = giveSword(model)
	end
	local guard = {
		model = model,
		humanoid = model:FindFirstChildOfClass("Humanoid"),
		hrp = model:FindFirstChild("HumanoidRootPart"),
		weaponPart = weaponPart,
		lastShot = 0,
	}
	guards[index] = guard
	applyStealth(guard)
	task.spawn(guardLoop, guard, index)
end

local function spawnAll()
	for i = 1, guardCount do
		task.spawn(spawnGuard, i)
	end
end

local function clearGuards()
	for i, guard in pairs(guards) do
		if guard.model then
			pcall(function() guard.model:Destroy() end)
		end
		guards[i] = nil
	end
end

local function setWeapon(w)
	if w ~= "rifle" and w ~= "sword" and w ~= "none" then return end
	if currentWeapon == w then return end
	currentWeapon = w
	clearGuards()
	if guardsEnabled then spawnAll() end
	print("🛡️ السلاح الآن: " .. w)
end

local function setGuardSpeed(n)
	guardSpeed = n
	for _, guard in pairs(guards) do
		if guard.humanoid then
			guard.humanoid.WalkSpeed = n
		end
	end
end

local function panic()
	local ownerHRP = getHRP(getCharacter())
	if not ownerHRP then return end
	for i, guard in pairs(guards) do
		if guard.model then
			guard.model:PivotTo(ownerHRP.CFrame * CFrame.new(i == 1 and -4 or 4, 0, 3))
		end
	end
	local nearest, nd = nil, 30
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local th = getHRP(plr.Character)
			local hh = getHumanoid(plr.Character)
			if th and hh and hh.Health > 0 then
				local d = (th.Position - ownerHRP.Position).Magnitude
				if d < nd then
					nearest, nd = plr, d
				end
			end
		end
	end
	if nearest then
		markAttacker(nearest)
		print("🚨 طوارئ! الحراس يهاجمون: " .. nearest.DisplayName)
	else
		print("🚨 تم استدعاء الحراس إليك")
	end
end

-- ================= كشف من يتهجم عليك =================
task.spawn(function()
	local lastHealth = nil
	while true do
		local hum = getHumanoid(getCharacter())
		if hum then
			if lastHealth and hum.Health < lastHealth and autoRetaliate then
				local ownerHRP = getHRP(getCharacter())
				if ownerHRP then
					local nearest, nd = nil, 25
					for _, plr in ipairs(Players:GetPlayers()) do
						if plr ~= LocalPlayer and plr.Character then
							local th = getHRP(plr.Character)
							local hh = getHumanoid(plr.Character)
							if th and hh and hh.Health > 0 then
								local d = (th.Position - ownerHRP.Position).Magnitude
								if d < nd then
									nearest, nd = plr, d
								end
							end
						end
					end
					if nearest then
						markAttacker(nearest)
						showAlert("⚠️ " .. nearest.DisplayName .. " يتهجم عليك!")
						print("🛡️ " .. nearest.DisplayName .. " تهجم عليك! الحراس يردون عليه")
					end
				end
			end
			lastHealth = hum.Health
		else
			lastHealth = nil
		end
		task.wait(0.2)
	end
end)

local function setupTouchWatch(char)
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	if not hrp then return end
	hrp.Touched:Connect(function(other)
		if not autoRetaliate then return end
		local plr = Players:GetPlayerFromCharacter(other.Parent)
		if plr and plr ~= LocalPlayer then
			markAttacker(plr)
			showAlert("⚠️ " .. plr.DisplayName .. " يتهجم عليك!")
		end
	end)
end
LocalPlayer.CharacterAdded:Connect(setupTouchWatch)
if getCharacter() then
	task.spawn(setupTouchWatch, getCharacter())
end

task.spawn(function()
	while true do
		if guardsEnabled then
			if mode == "attack" and attackTargetName then
				currentThreat = findPlayerByName(attackTargetName)
			else
				local ownerHRP = getHRP(getCharacter())
				local best, bestD = nil, math.huge
				for plr, untilTime in pairs(markedAttackers) do
					if tick() > untilTime then
						markedAttackers[plr] = nil
					elseif plr.Character then
						local th = getHRP(plr.Character)
						local hh = getHumanoid(plr.Character)
						if th and hh and hh.Health > 0 and ownerHRP then
							local d = (th.Position - ownerHRP.Position).Magnitude
							if d < bestD then
								best, bestD = plr, d
							end
						end
					end
				end
				currentThreat = best
			end
		else
			currentThreat = nil
		end
		task.wait(0.4)
	end
end)

-- ================= حماية إضافية =================
-- مضاد للدفع: يحذف أي قوة دفع يضعها لاعب آخر على شخصيتك
task.spawn(function()
	while true do
		task.wait(0.5)
		if antiFling then
			local char = getCharacter()
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BodyVelocity") or part:IsA("BodyAngularVelocity") or part:IsA("BodyGyro") or part:IsA("BodyPosition") then
						pcall(function() part:Destroy() end)
					end
				end
			end
		end
	end
end)

-- مضاد للسقوط في الفراغ: يعيدك لآخر مكان آمن
local lastSafePos = nil
task.spawn(function()
	while true do
		task.wait(0.5)
		local hrp = getHRP(getCharacter())
		if hrp then
			if hrp.Position.Y > 0 then
				lastSafePos = hrp.Position
			elseif antiVoid and hrp.Position.Y < -50 and lastSafePos then
				getCharacter():PivotTo(CFrame.new(lastSafePos + Vector3.new(0, 3, 0)))
			end
		end
	end
end)

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
end

function toggleFly()
	if flying then
		stopFly()
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

-- إيقاف الطيران عند تغيير الشخصية (موت/إعادة ظهور)
LocalPlayer.CharacterAdded:Connect(function()
	stopFly()
end)

-- ================= أسلحتي =================
local function firePlayerBullet(fromPos, targetPos, targetChar)
	task.spawn(function()
		local bullet = Instance.new("Part")
		bullet.Name = "Bullet"
		bullet.Size = Vector3.new(0.2, 0.2, 1.2)
		bullet.Color = Color3.fromRGB(255, 220, 0)
		bullet.Material = Enum.Material.Neon
		bullet.CanCollide = false
		bullet.Anchored = true
		bullet.CFrame = CFrame.new(fromPos, targetPos)
		bullet.Parent = workspace
		local steps = 8
		for i = 1, steps do
			local t = i / steps
			local pos = fromPos:Lerp(targetPos, t)
			bullet.CFrame = CFrame.new(pos, targetPos)
			task.wait(0.015)
		end
		pcall(function() bullet:Destroy() end)
	end)
	if targetChar then
		task.delay(0.15, function()
			pushTarget(targetChar)
		end)
	end
end

function giveGunTool()
	local backpack = LocalPlayer:WaitForChild("Backpack")
	if backpack:FindFirstChild("بندقيتي") then
		print("🔫 البندقية معك بالفعل")
		return
	end
	local tool = Instance.new("Tool")
	tool.Name = "بندقيتي"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.3, 0.4, 1.6)
	handle.Color = Color3.fromRGB(20, 20, 20)
	handle.Material = Enum.Material.Metal
	handle.CanCollide = false
	handle.Parent = tool
	local barrel = Instance.new("Part")
	barrel.Size = Vector3.new(0.12, 0.12, 0.8)
	barrel.Color = Color3.fromRGB(45, 45, 45)
	barrel.Material = Enum.Material.Metal
	barrel.CanCollide = false
	barrel.CFrame = CFrame.new(0, 0, -1)
	barrel.Parent = tool
	local w = Instance.new("Weld")
	w.Part0 = handle
	w.Part1 = barrel
	w.C0 = CFrame.new(0, 0, -1)
	w.Parent = handle
	tool.Parent = backpack
	tool.Activated:Connect(function()
		local mouse = LocalPlayer:GetMouse()
		local targetPos = mouse.Hit.Position
		local hrp = getHRP(getCharacter())
		if not hrp then return end
		local targetChar = nil
		if mouse.Target then
			local plr = Players:GetPlayerFromCharacter(mouse.Target.Parent)
			if plr and plr ~= LocalPlayer then
				targetChar = plr.Character
			end
		end
		firePlayerBullet(handle.Position, targetPos, targetChar)
	end)
	print("🔫 تم إعطاؤك بندقية — جهّزها واضغط للتصويب")
end

function giveSwordTool()
	local backpack = LocalPlayer:WaitForChild("Backpack")
	if backpack:FindFirstChild("سيفي") then
		print("🗡️ السيف معك بالفعل")
		return
	end
	local tool = Instance.new("Tool")
	tool.Name = "سيفي"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.15, 0.35, 2.0)
	handle.Color = Color3.fromRGB(200, 200, 210)
	handle.Material = Enum.Material.Neon
	handle.CanCollide = false
	handle.Parent = tool
	local guardPart = Instance.new("Part")
	guardPart.Size = Vector3.new(0.4, 0.1, 0.15)
	guardPart.Color = Color3.fromRGB(255, 200, 0)
	guardPart.Material = Enum.Material.Metal
	guardPart.CanCollide = false
	guardPart.CFrame = CFrame.new(0, 0, 0.9)
	guardPart.Parent = tool
	local w = Instance.new("Weld")
	w.Part0 = handle
	w.Part1 = guardPart
	w.C0 = CFrame.new(0, 0, 0.9)
	w.Parent = handle
	tool.Parent = backpack
	local lastHit = 0
	handle.Touched:Connect(function(other)
		if tick() - lastHit < 0.5 then return end
		local plr = Players:GetPlayerFromCharacter(other.Parent)
		if plr and plr ~= LocalPlayer then
			local hh = getHumanoid(plr.Character)
			if hh and hh.Health > 0 then
				lastHit = tick()
				pcall(function() hh:TakeDamage(25) end)
				pushTarget(plr.Character)
			end
		end
	end)
	print("🗡️ تم إعطاؤك سيفاً — جهّزه واضرب به")
end

function removeMyWeapons()
	local backpack = LocalPlayer:WaitForChild("Backpack")
	for _, name in ipairs({"بندقيتي", "سيفي"}) do
		local t = backpack:FindFirstChild(name)
		if t then
			pcall(function() t:Destroy() end)
		end
		local char = getCharacter()
		if char then
			local t2 = char:FindFirstChild(name)
			if t2 then
				pcall(function() t2:Destroy() end)
			end
		end
	end
end

-- ================= القائمة (GUI) =================
local ui = {}
local alertToken = 0
local screenGui, menuFrame, floatButton

local function sectionLabel(parent, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 28)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(255, 210, 80)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 16
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function makeButton(parent, text, width)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, width or 96, 0, 38)
	b.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 15
	b.Text = text
	b.Parent = parent
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = b
	return b
end

local function makeRow(parent)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 42)
	row.BackgroundTransparency = 1
	row.Parent = parent
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 6)
	layout.Parent = row
	return row
end

local function setActive(btn, active)
	if not btn then return end
	btn.BackgroundColor3 = active and Color3.fromRGB(0, 170, 90) or Color3.fromRGB(45, 45, 60)
end

function toggleGuards()
	guardsEnabled = not guardsEnabled
	if guardsEnabled then
		mode = "follow"
		spawnAll()
		print("🛡️ الحراس: شغال")
	else
		clearGuards()
		print("🛡️ الحراس: متوقف")
	end
	refreshUI()
end

function showAlert(text)
	if not ui.alertLabel then return end
	alertToken = alertToken + 1
	local myToken = alertToken
	ui.alertLabel.Text = text
	ui.alertLabel.Visible = true
	task.delay(5, function()
		if myToken == alertToken and ui.alertLabel then
			ui.alertLabel.Visible = false
		end
	end)
end

function refreshUI()
	if not ui.statusLabel then return end
	local modeText = mode == "follow" and "متابعة" or (mode == "stay" and "وقوف" or "هجوم")
	local weaponText = currentWeapon == "rifle" and "بندقية" or (currentWeapon == "sword" and "سيف" or "بدون")
	ui.statusLabel.Text = "الحالة: " .. (guardsEnabled and "شغال" or "متوقف") .. " • الوضع: " .. modeText .. " • الحراس: " .. guardCount .. " • السلاح: " .. weaponText

	if ui.guardsBtn then
		ui.guardsBtn.Text = guardsEnabled and "إيقاف الحراس" or "تشغيل الحراس"
	end
	setActive(ui.followBtn, mode == "follow")
	setActive(ui.stayBtn, mode == "stay")
	for i, b in pairs(ui.countBtns or {}) do setActive(b, guardCount == i) end
	for w, b in pairs(ui.weaponBtns or {}) do setActive(b, currentWeapon == w) end
	for s, b in pairs(ui.speedBtns or {}) do setActive(b, guardSpeed == s) end
	for d, b in pairs(ui.distBtns or {}) do setActive(b, formationDistance == d) end
	for f, b in pairs(ui.formBtns or {}) do setActive(b, formation == f) end
	setActive(ui.antiFlingBtn, antiFling)
	setActive(ui.antiVoidBtn, antiVoid)
	setActive(ui.autoRetBtn, autoRetaliate)
	setActive(ui.stealthBtn, stealth)
	setActive(ui.godBtn, godMode)
	setActive(ui.flyBtn, flying)
	if ui.godBtn then ui.godBtn.Text = "دم لا ينتهي: " .. (godMode and "ON" or "OFF") end
	if ui.flyBtn then ui.flyBtn.Text = "الطيران: " .. (flying and "ON" or "OFF") end
	if ui.flyUpBtn then ui.flyUpBtn.Visible = flying end
	if ui.flyDownBtn then ui.flyDownBtn.Visible = flying end
	for s, b in pairs(ui.flySpeedBtns or {}) do setActive(b, flySpeed == s) end
	if ui.antiFlingBtn then ui.antiFlingBtn.Text = "مضاد للدفع: " .. (antiFling and "ON" or "OFF") end
	if ui.antiVoidBtn then ui.antiVoidBtn.Text = "مضاد للسقوط: " .. (antiVoid and "ON" or "OFF") end
	if ui.autoRetBtn then ui.autoRetBtn.Text = "الرد التلقائي: " .. (autoRetaliate and "ON" or "OFF") end
	if ui.stealthBtn then ui.stealthBtn.Text = "التخفي: " .. (stealth and "ON" or "OFF") end

	if ui.hpLabel then
		local lines = {}
		for i = 1, guardCount do
			local g = guards[i]
			if g and g.humanoid then
				table.insert(lines, "حارس " .. i .. ": ❤️ " .. math.floor(g.humanoid.Health))
			else
				table.insert(lines, "حارس " .. i .. ": ...")
			end
		end
		ui.hpLabel.Text = table.concat(lines, "   ")
	end

	if ui.attackersLabel then
		local names = {}
		for plr, untilTime in pairs(markedAttackers) do
			if tick() <= untilTime then
				table.insert(names, plr.DisplayName)
			end
		end
		if attackTargetName then
			local t = findPlayerByName(attackTargetName)
			if t then
				table.insert(names, t.DisplayName .. " (بأمرك)")
			end
		end
		ui.attackersLabel.Text = #names > 0 and table.concat(names, "، ") or "لا أحد"
	end

	if ui.playerButtons then
		for name, btn in pairs(ui.playerButtons) do
			btn.BackgroundColor3 = (attackTargetName == name) and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(45, 45, 60)
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
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 36)
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 15
		btn.Text = "👤 " .. (plr and plr.DisplayName or name) .. " (@" .. name .. ")"
		btn.Parent = ui.playerList
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 8)
		c.Parent = btn
		ui.playerButtons[name] = btn
		btn.MouseButton1Click:Connect(function()
			if attackTargetName == name then
				mode = "follow"
				attackTargetName = nil
			else
				mode = "attack"
				attackTargetName = name
			end
			refreshUI()
		end)
	end
	ui.playerList.Size = UDim2.new(1, 0, 0, #names * 40)
end

local function buildGui()
	if screenGui then
		pcall(function() screenGui:Destroy() end)
	end
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BodyguardGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	-- زر عائم يفتح القائمة ويغلقها
	floatButton = Instance.new("TextButton")
	floatButton.Name = "FloatButton"
	floatButton.Size = UDim2.new(0, 64, 0, 64)
	floatButton.Position = UDim2.new(1, -84, 1, -240)
	floatButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	floatButton.BackgroundTransparency = 0.2
	floatButton.Text = "🛡️"
	floatButton.TextSize = 30
	floatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	floatButton.Font = Enum.Font.GothamBold
	floatButton.Active = true
	floatButton.Draggable = true
	floatButton.Parent = screenGui
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(0, 32)
	fc.Parent = floatButton

	-- أزرار الصعود والنزول أثناء الطيران (تظهر فقط عند الطيران)
	ui.flyUpBtn = Instance.new("TextButton")
	ui.flyUpBtn.Name = "FlyUp"
	ui.flyUpBtn.Size = UDim2.new(0, 60, 0, 60)
	ui.flyUpBtn.Position = UDim2.new(1, -84, 1, -330)
	ui.flyUpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
	ui.flyUpBtn.Text = "▲"
	ui.flyUpBtn.TextSize = 26
	ui.flyUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	ui.flyUpBtn.Font = Enum.Font.GothamBold
	ui.flyUpBtn.Visible = false
	ui.flyUpBtn.Parent = screenGui
	local fuc = Instance.new("UICorner")
	fuc.CornerRadius = UDim.new(0, 30)
	fuc.Parent = ui.flyUpBtn
	ui.flyUpBtn.MouseButton1Down:Connect(function() flyUp = true end)
	ui.flyUpBtn.MouseButton1Up:Connect(function() flyUp = false end)

	ui.flyDownBtn = Instance.new("TextButton")
	ui.flyDownBtn.Name = "FlyDown"
	ui.flyDownBtn.Size = UDim2.new(0, 60, 0, 60)
	ui.flyDownBtn.Position = UDim2.new(1, -160, 1, -330)
	ui.flyDownBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
	ui.flyDownBtn.Text = "▼"
	ui.flyDownBtn.TextSize = 26
	ui.flyDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	ui.flyDownBtn.Font = Enum.Font.GothamBold
	ui.flyDownBtn.Visible = false
	ui.flyDownBtn.Parent = screenGui
	local fdc = Instance.new("UICorner")
	fdc.CornerRadius = UDim.new(0, 30)
	fdc.Parent = ui.flyDownBtn
	ui.flyDownBtn.MouseButton1Down:Connect(function() flyDown = true end)
	ui.flyDownBtn.MouseButton1Up:Connect(function() flyDown = false end)

	-- القائمة الرئيسية
	menuFrame = Instance.new("Frame")
	menuFrame.Name = "Menu"
	menuFrame.Size = UDim2.new(0, 330, 0, 470)
	menuFrame.Position = UDim2.new(0.5, -165, 0.5, -235)
	menuFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
	menuFrame.BorderSizePixel = 0
	menuFrame.Active = true
	menuFrame.Draggable = true
	menuFrame.Parent = screenGui
	local mc = Instance.new("UICorner")
	mc.CornerRadius = UDim.new(0, 12)
	mc.Parent = menuFrame

	-- شريط العنوان
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 44)
	titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = menuFrame
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(0, 12)
	tc.Parent = titleBar

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -50, 1, 0)
	title.Position = UDim2.new(0, 12, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "🛡️ قائمة البودي جارد"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -42, 0, 2)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
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
	scroll.Size = UDim2.new(1, 0, 1, -44)
	scroll.Position = UDim2.new(0, 0, 0, 44)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.Parent = menuFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = scroll

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.Parent = scroll

	-- الحالة + تنبيه الهجوم
	ui.statusLabel = sectionLabel(scroll, "الحالة: شغال")
	ui.statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ui.statusLabel.TextSize = 15

	ui.alertLabel = Instance.new("TextLabel")
	ui.alertLabel.Size = UDim2.new(1, 0, 0, 30)
	ui.alertLabel.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
	ui.alertLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ui.alertLabel.Font = Enum.Font.GothamBold
	ui.alertLabel.TextSize = 15
	ui.alertLabel.Text = ""
	ui.alertLabel.Visible = false
	ui.alertLabel.Parent = scroll
	local ac = Instance.new("UICorner")
	ac.CornerRadius = UDim.new(0, 8)
	ac.Parent = ui.alertLabel

	-- التحكم
	sectionLabel(scroll, "⚙️ التحكم")
	local row1 = makeRow(scroll)
	ui.guardsBtn = makeButton(row1, "إيقاف الحراس", 96)
	ui.followBtn = makeButton(row1, "متابعة", 96)
	ui.stayBtn = makeButton(row1, "وقوف", 96)
	local row2 = makeRow(scroll)
	ui.bringBtn = makeButton(row2, "إحضار الحراس", 146)
	ui.panicBtn = makeButton(row2, "🚨 طوارئ", 146)
	ui.panicBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)

	ui.guardsBtn.MouseButton1Click:Connect(toggleGuards)
	ui.followBtn.MouseButton1Click:Connect(function()
		mode = "follow"
		attackTargetName = nil
	end)
	ui.stayBtn.MouseButton1Click:Connect(function()
		mode = "stay"
		attackTargetName = nil
	end)
	ui.bringBtn.MouseButton1Click:Connect(function()
		local ownerHRP = getHRP(getCharacter())
		if ownerHRP then
			for i, guard in pairs(guards) do
				if guard.model then
					guard.model:PivotTo(ownerHRP.CFrame * CFrame.new(i == 1 and -4 or 4, 0, 3))
				end
			end
		end
	end)
	ui.panicBtn.MouseButton1Click:Connect(panic)

	-- عدد الحراس
	sectionLabel(scroll, "👥 عدد الحراس")
	local rowCount = makeRow(scroll)
	ui.countBtns = {}
	for i = 1, 4 do
		local b = makeButton(rowCount, tostring(i), 72)
		ui.countBtns[i] = b
		b.MouseButton1Click:Connect(function()
			guardCount = i
			clearGuards()
			if guardsEnabled then spawnAll() end
		end)
	end

	-- السلاح
	sectionLabel(scroll, "⚔️ السلاح")
	local rowWeapon = makeRow(scroll)
	ui.weaponBtns = {}
	local weapons = {{"rifle", "🔫 بندقية"}, {"sword", "🗡️ سيف"}, {"none", "🥊 بدون"}}
	for _, w in ipairs(weapons) do
		local b = makeButton(rowWeapon, w[2], 96)
		ui.weaponBtns[w[1]] = b
		b.MouseButton1Click:Connect(function()
			setWeapon(w[1])
		end)
	end

	-- السرعة
	sectionLabel(scroll, "💨 سرعة الحراس")
	local rowSpeed = makeRow(scroll)
	ui.speedBtns = {}
	for _, s in ipairs({16, 22, 30}) do
		local b = makeButton(rowSpeed, tostring(s), 96)
		ui.speedBtns[s] = b
		b.MouseButton1Click:Connect(function()
			setGuardSpeed(s)
		end)
	end

	-- مسافة الحراسة
	sectionLabel(scroll, "📏 مسافة الحراسة")
	local rowDist = makeRow(scroll)
	ui.distBtns = {}
	local dists = {{3, "قريب"}, {5, "متوسط"}, {8, "بعيد"}}
	for _, d in ipairs(dists) do
		local b = makeButton(rowDist, d[2], 96)
		ui.distBtns[d[1]] = b
		b.MouseButton1Click:Connect(function()
			formationDistance = d[1]
		end)
	end

	-- التشكيل
	sectionLabel(scroll, "🔷 التشكيل")
	local rowForm = makeRow(scroll)
	ui.formBtns = {}
	local forms = {{"line", "— خط —"}, {"circle", "○ دائرة"}}
	for _, f in ipairs(forms) do
		local b = makeButton(rowForm, f[2], 146)
		ui.formBtns[f[1]] = b
		b.MouseButton1Click:Connect(function()
			formation = f[1]
		end)
	end

	-- الحماية
	sectionLabel(scroll, "🛡️ الحماية")
	local rowProt1 = makeRow(scroll)
	ui.antiFlingBtn = makeButton(rowProt1, "مضاد للدفع", 146)
	ui.antiVoidBtn = makeButton(rowProt1, "مضاد للسقوط", 146)
	local rowProt2 = makeRow(scroll)
	ui.autoRetBtn = makeButton(rowProt2, "الرد التلقائي", 146)
	ui.stealthBtn = makeButton(rowProt2, "التخفي", 146)
	ui.antiFlingBtn.MouseButton1Click:Connect(function()
		antiFling = not antiFling
	end)
	ui.antiVoidBtn.MouseButton1Click:Connect(function()
		antiVoid = not antiVoid
	end)
	ui.autoRetBtn.MouseButton1Click:Connect(function()
		autoRetaliate = not autoRetaliate
	end)
	ui.stealthBtn.MouseButton1Click:Connect(function()
		stealth = not stealth
		for _, guard in pairs(guards) do
			applyStealth(guard)
		end
	end)

	-- قوتي (دم لا ينتهي + طيران)
	sectionLabel(scroll, "💪 قوتي")
	local rowPower = makeRow(scroll)
	ui.godBtn = makeButton(rowPower, "دم لا ينتهي", 146)
	ui.flyBtn = makeButton(rowPower, "الطيران", 146)
	ui.godBtn.MouseButton1Click:Connect(function()
		setGodMode(not godMode)
		refreshUI()
	end)
	ui.flyBtn.MouseButton1Click:Connect(function()
		toggleFly()
	end)
	sectionLabel(scroll, "💨 سرعة الطيران")
	local rowFlySpeed = makeRow(scroll)
	ui.flySpeedBtns = {}
	for _, s in ipairs({16, 50, 100}) do
		local b = makeButton(rowFlySpeed, tostring(s), 96)
		ui.flySpeedBtns[s] = b
		b.MouseButton1Click:Connect(function()
			flySpeed = s
		end)
	end

	-- أسلحتي
	sectionLabel(scroll, "⚔️ أسلحتي")
	local rowMyWeapons = makeRow(scroll)
	ui.gunBtn = makeButton(rowMyWeapons, "🔫 بندقية لي", 146)
	ui.swordBtn = makeButton(rowMyWeapons, "🗡️ سيف لي", 146)
	ui.gunBtn.MouseButton1Click:Connect(giveGunTool)
	ui.swordBtn.MouseButton1Click:Connect(giveSwordTool)
	local rowMyWeapons2 = makeRow(scroll)
	ui.removeWeaponsBtn = makeButton(rowMyWeapons2, "🗑️ أزل أسلحتي", 200)
	ui.removeWeaponsBtn.MouseButton1Click:Connect(removeMyWeapons)

	-- صحة الحراس
	sectionLabel(scroll, "❤️ صحة الحراس")
	ui.hpLabel = Instance.new("TextLabel")
	ui.hpLabel.Size = UDim2.new(1, 0, 0, 30)
	ui.hpLabel.BackgroundTransparency = 1
	ui.hpLabel.Text = ""
	ui.hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ui.hpLabel.Font = Enum.Font.GothamBold
	ui.hpLabel.TextSize = 15
	ui.hpLabel.TextXAlignment = Enum.TextXAlignment.Left
	ui.hpLabel.Parent = scroll

	-- اللاعبون
	sectionLabel(scroll, "👤 اللاعبون — اضغط على أي لاعب لمهاجمته")
	local rowPlayers = makeRow(scroll)
	ui.refreshBtn = makeButton(rowPlayers, "🔄 تحديث القائمة", 200)
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

	-- المهاجمون الحاليون
	sectionLabel(scroll, "🎯 من يتهجم عليك الآن")
	ui.attackersLabel = Instance.new("TextLabel")
	ui.attackersLabel.Size = UDim2.new(1, 0, 0, 30)
	ui.attackersLabel.BackgroundTransparency = 1
	ui.attackersLabel.Text = "لا أحد"
	ui.attackersLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ui.attackersLabel.Font = Enum.Font.GothamBold
	ui.attackersLabel.TextSize = 15
	ui.attackersLabel.TextXAlignment = Enum.TextXAlignment.Left
	ui.attackersLabel.Parent = scroll

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

-- ================= الأوامر من الشات (احتياط) =================
local function printHelp()
	print("🛡️ أوامر البودي جارد (القائمة باللمس هي الأساس):")
	print(";guards on/off, ;follow, ;stay, ;attack <اسم>, ;stop, ;bring")
	print(";count <1-4>, ;weapon <rifle/sword/none>, ;panic, ;speed <n>")
	print(";circle, ;line, ;antifling, ;antivoid, ;stealth, ;menu")
	print(";god, ;fly, ;gun, ;sword, ;help")
end

LocalPlayer.Chatted:Connect(function(msg)
	if msg:sub(1, 1) ~= PREFIX then return end
	local parts = string.split(msg:sub(2), " ")
	local cmd = string.lower(parts[1] or "")

	if cmd == "guards" then
		local arg = string.lower(parts[2] or "")
		if arg == "on" and not guardsEnabled then
			toggleGuards()
		elseif arg == "off" and guardsEnabled then
			toggleGuards()
		end
	elseif cmd == "follow" then
		mode = "follow"
		attackTargetName = nil
	elseif cmd == "stay" then
		mode = "stay"
		attackTargetName = nil
	elseif cmd == "attack" then
		local target = findPlayerByName(parts[2] or "")
		if target then
			mode = "attack"
			attackTargetName = target.Name
			print("🛡️ الحراس يهاجمون: " .. target.DisplayName)
		else
			print("🛡️ لم أجد لاعباً بهذا الاسم")
		end
	elseif cmd == "stop" then
		mode = "follow"
		attackTargetName = nil
	elseif cmd == "bring" then
		local ownerHRP = getHRP(getCharacter())
		if ownerHRP then
			for i, guard in pairs(guards) do
				if guard.model then
					guard.model:PivotTo(ownerHRP.CFrame * CFrame.new(i == 1 and -4 or 4, 0, 3))
				end
			end
		end
	elseif cmd == "count" then
		local n = tonumber(parts[2])
		if n and n >= 1 and n <= MAX_GUARDS then
			guardCount = n
			clearGuards()
			if guardsEnabled then spawnAll() end
		end
	elseif cmd == "weapon" then
		setWeapon(string.lower(parts[2] or ""))
	elseif cmd == "panic" then
		panic()
	elseif cmd == "speed" then
		local n = tonumber(parts[2])
		if n then setGuardSpeed(n) end
	elseif cmd == "circle" then
		formation = "circle"
	elseif cmd == "line" then
		formation = "line"
	elseif cmd == "antifling" then
		antiFling = not antiFling
	elseif cmd == "antivoid" then
		antiVoid = not antiVoid
	elseif cmd == "stealth" then
		stealth = not stealth
		for _, guard in pairs(guards) do
			applyStealth(guard)
		end
	elseif cmd == "god" then
		setGodMode(not godMode)
	elseif cmd == "fly" then
		toggleFly()
	elseif cmd == "gun" then
		giveGunTool()
	elseif cmd == "sword" then
		giveSwordTool()
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
print("🛡️ سكربت البودي جارد v4 يعمل على Solara! اضغط زر 🛡️ لفتح القائمة")
printHelp()
buildGui()
spawnAll()

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
