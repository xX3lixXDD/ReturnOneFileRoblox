local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local savedCFrame = nil
local savedPart = nil
local touchedDebounces = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ReturnGuiSingle"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 320, 0, 180)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(34,34,34)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0,0)
frame.Active = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 30)
title.Position = UDim2.new(0, 8, 0, 8)
title.BackgroundTransparency = 1
title.Text = "ReturnOneFile by: xX_3lixXDD"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 18
closeBtn.Parent = frame

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -56, 0, 8)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 18
minimizeBtn.Parent = frame

local setBtn = Instance.new("TextButton")
setBtn.Size = UDim2.new(0, 150, 0, 36)
setBtn.Position = UDim2.new(0, 8, 0, 48)
setBtn.BackgroundColor3 = Color3.fromRGB(50,150,50)
setBtn.TextColor3 = Color3.fromRGB(255,255,255)
setBtn.Font = Enum.Font.SourceSans
setBtn.TextSize = 16
setBtn.Text = "Set Return (My Pos)"
setBtn.Parent = frame

local setBlockBtn = Instance.new("TextButton")
setBlockBtn.Size = UDim2.new(0, 150, 0, 36)
setBlockBtn.Position = UDim2.new(0, 164, 0, 48)
setBlockBtn.BackgroundColor3 = Color3.fromRGB(60,120,200)
setBlockBtn.TextColor3 = Color3.fromRGB(255,255,255)
setBlockBtn.Font = Enum.Font.SourceSans
setBlockBtn.TextSize = 16
setBlockBtn.Text = "Save Block Under Me"
setBlockBtn.Parent = frame

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0, 150, 0, 36)
tpBtn.Position = UDim2.new(0, 8, 0, 92)
tpBtn.BackgroundColor3 = Color3.fromRGB(180,120,30)
tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
tpBtn.Font = Enum.Font.SourceSans
tpBtn.TextSize = 16
tpBtn.Text = "Teleport Now"
tpBtn.Parent = frame

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 150, 0, 36)
clearBtn.Position = UDim2.new(0, 164, 0, 92)
clearBtn.BackgroundColor3 = Color3.fromRGB(140,40,40)
clearBtn.TextColor3 = Color3.fromRGB(255,255,255)
clearBtn.Font = Enum.Font.SourceSans
clearBtn.TextSize = 16
clearBtn.Text = "Clear Saved"
clearBtn.Parent = frame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -16, 0, 36)
infoLabel.Position = UDim2.new(0, 8, 0, 140)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(220,220,220)
infoLabel.Text = "No return location set."
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextSize = 15
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = frame

local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://2101148"
clickSound.Volume = 0.8
clickSound.Parent = frame

local function playClick()
    clickSound:Play()
end

closeBtn.MouseButton1Click:Connect(function()
    playClick()
    screenGui:Destroy()
end)

local isMinimized = false
local originalSize = frame.Size
local originalChildren = {}

for _, child in ipairs(frame:GetChildren()) do
    if child ~= title and child ~= closeBtn and child ~= minimizeBtn then
        table.insert(originalChildren, child)
    end
end

minimizeBtn.MouseButton1Click:Connect(function()
    playClick()
    isMinimized = not isMinimized
    if isMinimized then
        for _, child in ipairs(originalChildren) do
            child.Visible = false
        end
        frame.Size = UDim2.new(0, 320, 0, 46)
    else
        for _, child in ipairs(originalChildren) do
            child.Visible = true
        end
        frame.Size = originalSize
    end
end)

setBtn.MouseButton1Click:Connect(function()
    playClick()
    local char = player.Character
    if not char then infoLabel.Text = "No character found!" return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then infoLabel.Text = "No HumanoidRootPart found!" return end
    savedCFrame = hrp.CFrame
    savedPart = nil
    infoLabel.Text = "CFrame position saved."
end)

setBlockBtn.MouseButton1Click:Connect(function()
    playClick()
    local char = player.Character
    if not char then infoLabel.Text = "No character found!" return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then infoLabel.Text = "No HumanoidRootPart found!" return end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local ray = Workspace:Raycast(hrp.Position, Vector3.new(0, -500, 0), params)
    if ray and ray.Instance and ray.Instance:IsA("BasePart") then
        savedPart = ray.Instance
        savedCFrame = nil
        infoLabel.Text = "Saved block: ".. (savedPart.Name or "Part")
    else
        infoLabel.Text = "No block found under you."
    end
end)

tpBtn.MouseButton1Click:Connect(function()
    playClick()
    local char = player.Character
    if not char then infoLabel.Text = "No character found!" return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then infoLabel.Text = "No HumanoidRootPart found!" return end
    if savedPart and savedPart:IsDescendantOf(Workspace) and savedPart:IsA("BasePart") then
        local topOffset = (savedPart.Size.Y / 2) + 3
        hrp.CFrame = savedPart.CFrame + Vector3.new(0, topOffset, 0)
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.Sit = false end
        infoLabel.Text = "Returned to saved block."
        return
    end
    if savedCFrame then
        hrp.CFrame = savedCFrame + Vector3.new(0, 3, 0)
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.Sit = false end
        infoLabel.Text = "Returned to saved CFrame."
        return
    end
    infoLabel.Text = "No saved location to teleport to."
end)

clearBtn.MouseButton1Click:Connect(function()
    playClick()
    savedPart = nil
    savedCFrame = nil
    infoLabel.Text = "Saved location cleared."
end)

local dragging = false
local dragStartPos = nil
local frameStartPos = nil

local function clampFramePosition(x,y)
    local cam = Workspace.CurrentCamera
    local screenSize = Vector2.new(1920,1080)
    if cam then screenSize = cam.ViewportSize end
    x = math.clamp(x, 0, screenSize.X - frame.Size.X.Offset)
    y = math.clamp(y, 0, screenSize.Y - frame.Size.Y.Offset)
    return x, y
end

local function updateDragFromPosition(currentPos)
    if not dragging or not dragStartPos or not frameStartPos then return end
    local delta = currentPos - dragStartPos
    local newX = frameStartPos.X.Offset + delta.X
    local newY = frameStartPos.Y.Offset + delta.Y
    newX, newY = clampFramePosition(newX, newY)
    frame.Position = UDim2.new(0, newX, 0, newY)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        if input.Position then
            dragStartPos = input.Position
        else
            dragStartPos = UserInputService:GetMouseLocation()
        end
        frameStartPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position
        if not pos then pos = UserInputService:GetMouseLocation() end
        updateDragFromPosition(pos)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        dragStartPos = nil
        frameStartPos = nil
    end
end)

local function getReturnParts()
    local p = Workspace:FindFirstChild("ReturnArea")
    if p and p:IsA("BasePart") then
        return {p}
    end
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
    return {}
end

local function attachReturnTouch(part)
    if not part or not part:IsA("BasePart") then return end
    if touchedDebounces[part] then return end
    touchedDebounces[part] = {last = 0}

    part.Touched:Connect(function(hit)
        if not savedCFrame and not savedPart then
            infoLabel.Text = "No return location set."
            return
        end
        if not hit or not hit.Parent then return end
        local char = player.Character
        if not char then return end
        if not hit:IsDescendantOf(char) then return end

        local now = tick()
        local db = touchedDebounces[part]
        if db.last and now - db.last < 1 then return end
        db.last = now

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if savedPart and savedPart:IsDescendantOf(Workspace) and savedPart:IsA("BasePart") then
            local topOffset = (savedPart.Size.Y / 2) + 3
            hrp.CFrame = savedPart.CFrame + Vector3.new(0, topOffset, 0)
        elseif savedCFrame then
            hrp.CFrame = savedCFrame + Vector3.new(0, 3, 0)
        end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.Sit = false end
        infoLabel.Text = "Returned to saved location."
    end)
end

local parts = getReturnParts()
if #parts == 0 then
    warn("ReturnOneFile: No 'ReturnArea' or 'ReturnAreas' found in Workspace. Create a Part named 'ReturnArea' or a Folder named 'ReturnAreas' containing Parts.")
else
    for _, p in ipairs(parts) do attachReturnTouch(p) end
end

Workspace.ChildAdded:Connect(function(child)
    if child.Name == "ReturnArea" and child:IsA("BasePart") then
        attachReturnTouch(child)
    elseif child.Name == "ReturnAreas" and child:IsA("Folder") then
        for _, v in ipairs(child:GetChildren()) do
            if v:IsA("BasePart") then
                attachReturnTouch(v)
            end
        end
    end
end)

local returnFolder = Workspace:FindFirstChild("ReturnAreas")
if returnFolder and returnFolder:IsA("Folder") then
    returnFolder.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") then
            attachReturnTouch(child)
        end
    end)
end
