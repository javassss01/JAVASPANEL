-- StarterPlayer/StarterPlayerScripts/AdvancedModMenu.luau
-- Roblox Luau | Engine: Roblox Studio | Target: StarterPlayerScripts (LocalScript)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

-- Status Fitur
local speedEnabled = false
local jumpEnabled = false
local flyEnabled = false
local noclipEnabled = false
local invisEnabled = false
local espEnabled = false
local btoolEnabled = false
local fullbrightEnabled = false
local infJumpEnabled = false
local fovEnabled = false

local flySpeed = 50
local bodyVelocity = nil
local bodyGyro = nil
local flyConnection = nil
local noclipConnection = nil
local espFolder = Instance.new("Folder")
espFolder.Name = "ESPFolder"
espFolder.Parent = Workspace

-- ScreenGui & Panel Utama (Diperbesar tingginya menjadi 480)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedModMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 50, 0, 50)
openButton.Position = UDim2.new(0, 10, 0.4, 0)
openButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.TextSize = 14
openButton.Font = Enum.Font.SourceSansBold
openButton.Text = "MENU"
openButton.Draggable = true
openButton.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = openButton

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 480)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Visible = false
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "ULTIMATE MOD MENU"
titleLabel.Parent = mainFrame

local function createFeatureButton(name, positionY, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 190, 0, 32)
	btn.Position = UDim2.new(0.5, -95, 0, positionY)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 13
	btn.Font = Enum.Font.SourceSansBold
	btn.Text = name .. ": OFF"
	btn.Parent = mainFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	local active = false
	btn.MouseButton1Click:Connect(function()
		active = not active
		if active then
			btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			btn.Text = name .. ": ON"
		else
			btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			btn.Text = name .. ": OFF"
		end
		callback(active)
	end)
end

openButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- 1. Speed
createFeatureButton("Speed (100)", 40, function(state)
	speedEnabled = state
	local char = player.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char.Humanoid.WalkSpeed = speedEnabled and 100 or 16
	end
end)

-- 2. Super Jump (Fixed)
createFeatureButton("Super Jump", 77, function(state)
	jumpEnabled = state
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid.UseJumpPower = true
	humanoid.JumpPower = jumpEnabled and 150 or 50

	if jumpEnabled then
		task.spawn(function()
			while jumpEnabled and player.Character == char do
				if humanoid and humanoid.UseJumpPower and humanoid.JumpPower ~= 150 then
					humanoid.JumpPower = 150
				end
				task.wait(0.5)
			end
		end)
	end
end)

-- 3. Fly Mode
createFeatureButton("Fly Mode", 114, function(state)
	flyEnabled = state
	local char = player.Character
	if not char then return end
	local rootPart = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChild("Humanoid")
	if not (rootPart and humanoid) then return end

	if flyEnabled then
		humanoid.PlatformStand = true
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.Parent = rootPart

		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.CFrame = rootPart.CFrame
		bodyGyro.Parent = rootPart

		flyConnection = RunService.RenderStepped:Connect(function()
			if not flyEnabled or not char.Parent then return end
			local moveDir = humanoid.MoveDirection
			local camLookFlat = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
			local camRightFlat = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z).Unit

			local velocity = Vector3.new(0, 0, 0)
			if moveDir.Magnitude > 0 then
				velocity = (camLookFlat * (-moveDir.Z) + camRightFlat * moveDir.X).Unit * flySpeed
			else
				velocity = Vector3.new(0, 0.1, 0)
			end
			bodyVelocity.Velocity = velocity
			bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + camLookFlat)
		end)
	else
		humanoid.PlatformStand = false
		if bodyVelocity then bodyVelocity:Destroy() end
		if bodyGyro then bodyGyro:Destroy() end
		if flyConnection then flyConnection:Disconnect() end
	end
end)

-- 4. Noclip
createFeatureButton("Noclip", 151, function(state)
	noclipEnabled = state
	if noclipConnection then noclipConnection:Disconnect() end
	if noclipEnabled then
		noclipConnection = RunService.Stepped:Connect(function()
			local char = player.Character
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	end
end)

-- 5. Invisibility
createFeatureButton("Invisibility", 188, function(state)
	invisEnabled = state
	local char = player.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = invisEnabled and 1 or 0
		elseif part:IsA("Decal") then
			part.Transparency = invisEnabled and 1 or 0
		end
	end
end)

-- 6. Player ESP
createFeatureButton("Player ESP", 225, function(state)
	espEnabled = state
	espFolder:ClearAllChildren()

	if espEnabled then
		RunService.RenderStepped:Connect(function()
			if not espEnabled then return end
			espFolder:ClearAllChildren()
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local hrp = p.Character.HumanoidRootPart
					local box = Instance.new("BoxHandleAdornment")
					box.Size = p.Character:GetExtentsSize()
					box.Adornitee = hrp
					box.AlwaysOnTop = true
					box.ZIndex = 5
					box.Transparency = 0.5
					box.Color3 = Color3.fromRGB(255, 0, 0)
					box.Parent = espFolder
				end
			end
		end)
	end
end)

-- 7. Give BTools
createFeatureButton("Give BTools", 262, function(state)
	btoolEnabled = state
	if btoolEnabled then
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			for _, toolName in ipairs({"Hammer", "Clone", "Delete"}) do
				local tool = Instance.new("HopperBin")
				tool.BinType = Enum.BinType[toolName] or Enum.BinType.Hammer
				tool.Parent = backpack
			end
		end
	end
end)

-- 8. FITUR BARU: Fullbright (Anti-Gelap)
createFeatureButton("Fullbright", 299, function(state)
	fullbrightEnabled = state
	if fullbrightEnabled then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
	else
		Lighting.Brightness = 1
		Lighting.GlobalShadows = true
	end
end)

-- 9. FITUR BARU: Infinite Jump (Loncat di Udara)
createFeatureButton("Infinite Jump", 336, function(state)
	infJumpEnabled = state
end)

UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled then
		local char = player.Character
		if char and char:FindFirstChildOfClass("Humanoid") then
			char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- 10. FITUR BARU: FOV Changer (Sudut Pandang Luas)
createFeatureButton("Wide FOV", 373, function(state)
	fovEnabled = state
	camera.FieldOfView = fovEnabled and 110 or 70
end)

-- Reset saat karakter respawn
player.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid")
	speedEnabled = false
	jumpEnabled = false
	flyEnabled = false
	noclipEnabled = false
	invisEnabled = false
	espEnabled = false
	btoolEnabled = false
	fullbrightEnabled = false
	infJumpEnabled = false
	fovEnabled = false
	espFolder:ClearAllChildren()
end)
