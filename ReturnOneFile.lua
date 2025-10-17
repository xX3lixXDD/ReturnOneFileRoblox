-- ReturnOneFile.client.lua
-- سكربت واحد (LocalScript):
-- 1) يخلق GUI قابل للسحب (Desktop + Mobile)
-- 2) يرسل/يخزن CFrame محلياً (Set Return)
-- 3) يستمع للأجزاء ReturnArea أو مجلد ReturnAreas ويعيد اللاعب عند الملامسة

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ====== إعداد الحالة المحلية ======
local savedCFrame = nil -- الموقع الذي سيتم العودة إليه (محلي)

-- ====== إنشاء GUI (قابل للسحب على الموبايل والكمبيوتر) ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ReturnGuiSingle"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
-- على بعض الحالات قد تحتاج: screenGui.IgnoreGuiInset = true

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 300, 0, 140)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(34,34,34)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0,0)
frame.Active = true -- مهم للـ Touch
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 30)
title.Position = UDim2.new(0, 8, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Return Tool"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local setBtn = Instance.new("TextButton")
setBtn.Size = UDim2.new(0, 150, 0, 40)
setBtn.Position = UDim2.new(0, 8, 0, 48)
setBtn.BackgroundColor3 = Color3.fromRGB(50,150,50)
setBtn.TextColor3 = Color3.fromRGB(255,255,255)
setBtn.Font = Enum.Font.SourceSans
setBtn.TextSize = 18
setBtn.Text = "Set Return (My Pos)"
setBtn.Parent = frame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -16, 0, 28)
infoLabel.Position = UDim2.new(0, 8, 0, 98)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(220,220,220)
infoLabel.Text = "لم يتم تعيين موقع العودة."
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextSize = 15
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = frame

-- ====== زر التعيين ======
setBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	if not char then
		infoLabel.Text = "لا توجد شخصية!"
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		infoLabel.Text = "لا يوجد HumanoidRootPart!"
		return
	end
	savedCFrame = hrp.CFrame
	infoLabel.Text = "تم تعيين موقع العودة."
end)

-- ====== دعم السحب (Mouse + Touch) ======
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

local function updateDrag(input)
	if not dragging or not dragStart or not startPos then return end
	local currentPos = input.Position
	local delta = currentPos - dragStart
	local newX = startPos.X.Offset + delta.X
	local newY = startPos.Y.Offset + delta.Y
	-- حدود الشاشة
	local cam = workspace.CurrentCamera
	local screenSize = cam and cam.ViewportSize or Vector2.new(1920,1080)
	newX = math.clamp(newX, 0, screenSize.X - frame.Size.X.Offset)
	newY = math.clamp(newY, 0, screenSize.Y - frame.Size.Y.Offset)
	frame.Position = UDim2.new(0, newX, 0, newY)
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		dragInput = input
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				dragInput = nil
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput then
		updateDrag(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input == dragInput then
		dragging = false
		dragInput = nil
	end
end)

-- ====== البحث عن ReturnArea(s) وربط الأحداث محلياً ======
local function getReturnParts()
	-- أ) إذا يوجد جزء اسمه ReturnArea (واحد)
	local p = Workspace:FindFirstChild("ReturnArea")
	if p and p:IsA("BasePart") then
		return {p}
	end
	-- ب) إذا يوجد مجلد ReturnAreas فيه أجزاء
	local folder = Workspace:FindFirstChild("ReturnAreas")
	if folder and folder:IsA("Folder") then
		local parts = {}
		for _, v in ipairs(folder:GetChildren()) do
			if v:IsA("BasePart") then
				table.insert(parts, v)
			end
		end
		return parts
	end
	-- ج) لا شيء
	return {}
end

local function onTouchedPart(part)
	-- نتأكد أن اللاعب لم يحفظ موقع العودة بعد؟ لو لم يحفظ نبلّغه
	if not savedCFrame then
		infoLabel.Text = "لم تحدد موقع العودة بعد."
		return
	end
	-- التأكد أن اللمس هو من الشخصية المحلية (hit parent هو النموذج الخاص بالشخصية)
	local function tryTeleport(hit)
		if not hit or not hit.Parent then return end
		local char = player.Character
		if not char then return end
		-- عادة الـ HumanoidRootPart أو أجزاء الشخصية هي التي تلامس، لذا نقارن الـ Parent
		if hit:FindFirstAncestorOfClass("Model") == char then
			-- نقل HumanoidRootPart إلى savedCFrame (مع رفع بسيط لتجنب الاصطدام)
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = savedCFrame + Vector3.new(0, 3, 0)
				-- إلغاء وضع الجلوس لو كان
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if humanoid then humanoid.Sit = false end
				infoLabel.Text = "تم إرجاعك للموقع."
			end
		end
	end
	-- نربط حدث Touched على الجزء المحدد
	part.Touched:Connect(tryTeleport)
end

-- تشغيل على الأجزاء الحالية (إن وُجدت)
local parts = getReturnParts()
if #parts == 0 then
	warn("ReturnOneFile: لم أجد ReturnArea أو ReturnAreas في Workspace. أنشئ Part باسم 'ReturnArea' أو Folder باسم 'ReturnAreas' يحتوي Parts.")
else
	for _, p in ipairs(parts) do
		-- نوصل event محلي لكل جزء (تابع للتأكد)
		p.Touched:Connect(function(hit) 
			-- مباشرة نجري الفحص لأن tryTeleport داخلي قد لا يحتاج إلى تعريف منفصل
			if not savedCFrame then
				infoLabel.Text = "لم تحدد موقع العودة بعد."
				return
			end
			if not hit or not hit.Parent then return end
			local char = player.Character
			if not char then return end
			if hit:FindFirstAncestorOfClass("Model") == char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.CFrame = savedCFrame + Vector3.new(0, 3, 0)
					local humanoid = char:FindFirstChildOfClass("Humanoid")
					if humanoid then humanoid.Sit = false end
					infoLabel.Text = "تم إرجاعك للموقع."
				end
			end
		end)
	end
end

-- إذا تمت إضافة أجزاء لاحقاً أثناء التشغيل، نتعامل معها كذلك
Workspace.ChildAdded:Connect(function(child)
	if child.Name == "ReturnArea" and child:IsA("BasePart") then
		child.Touched:Connect(function(hit)
			if not savedCFrame then
				infoLabel.Text = "لم تحدد موقع العودة بعد."
				return
			end
			if not hit or not hit.Parent then return end
			if hit:FindFirstAncestorOfClass("Model") == player.Character then
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.CFrame = savedCFrame + Vector3.new(0, 3, 0)
					local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
					if humanoid then humanoid.Sit = false end
					infoLabel.Text = "تم إرجاعك للموقع."
				end
			end
		end)
	elseif child.Name == "ReturnAreas" and child:IsA("Folder") then
		for _, v in ipairs(child:GetChildren()) do
			if v:IsA("BasePart") then
				v.Touched:Connect(function(hit)
					if not savedCFrame then
						infoLabel.Text = "لم تحدد موقع العودة بعد."
						return
					end
					if not hit or not hit.Parent then return end
					if hit:FindFirstAncestorOfClass("Model") == player.Character then
						local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
						if hrp then
							hrp.CFrame = savedCFrame + Vector3.new(0, 3, 0)
							local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
							if humanoid then humanoid.Sit = false end
							infoLabel.Text = "تم إرجاعك للموقع."
						end
					end
				end)
			end
		end
	end
end)

-- انتهى السكربت