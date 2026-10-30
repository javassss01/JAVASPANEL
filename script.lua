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
local fullbrightEnabled = false
local infJumpEnabled = false
local fovEnabled = false

local flySpeed = 50
local bodyVelocity = nil
local bodyGyro = nil
local flyConnection = nil
local noclipConnection = nil
local savedPosition = nil

local espFolder = Instance.new("Folder")
espFolder.Name = "ESPFolder"
espFolder.Parent = Workspace

-- ScreenGui Utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedModMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Tombol Floating Buka/Tutup Menu (Aesthetic Minimalist)
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 48, 0, 48)
openButton.Position = UDim2.new(0, 15, 0.4, 0)
openButton.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
openButton.TextColor3 = Color3.fromRGB(230, 230, 242)
openButton.TextSize = 13
openButton.Font = Enum.Font.GothamBold
openButton.Text = "JVPNL"
openButton.Draggable = true
openButton.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 12)
openCorner.Parent = openButton

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(75, 75, 100)
openStroke.Thickness = 1.5
openStroke.Parent = openButton

-- Frame Utama Panel Menu (Grid Layout 2 Kolom, rapi & tidak terlalu panjang)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 340, 0, 340)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -170)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 21)
mainFrame.Visible = false
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(50, 50, 70)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- Header / Judul Panel
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "JAVAXPANEL"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Garis Pembatas Header
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -30, 0, 1)
divider.Position = UDim2.new(0, 15, 0, 45)
divider.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

-- ScrollingFrame dengan sistem Grid 2 Kolom
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -10, 1, -55)
scrollingFrame.Position = UDim2.new(0, 5, 0, 50)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollingFrame.ScrollBarThickness = 3
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 110)
scrollingFrame.Parent = mainFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 156, 0, 36)
gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = scrollingFrame

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 8)
uiPadding.PaddingBottom = UDim.new(0, 12)
uiPadding.PaddingLeft = UDim.new(0, 4)
uiPadding.PaddingRight = UDim.new(0, 4)
uiPadding.Parent = scrollingFrame

-- Fungsi Pembuat Tombol Grid yang Aesthetic
local function createFeatureButton(name, callback, isAction)
	local btn = Instance.new("TextButton")
	btn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
	btn.TextColor3 = Color3.fromRGB(190, 190, 205)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamMedium
	btn.Text = isAction and name or (name .. " : OFF")
	btn.Parent = scrollingFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(45, 45, 60)
	stroke.Thickness = 1
	stroke.Parent = btn

	if isAction then
		btn.MouseButton1Click:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
			stroke.Color = Color3.fromRGB(120, 120, 180)
			task.wait(0.15)
			btn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
			stroke.Color = Color3.fromRGB(45, 45, 60)
			callback()
		end)
	else
		local active = false
		btn.MouseButton1Click:Connect(function()
			active = not active
			if active then
				btn.BackgroundColor3 = Color3.fromRGB(24, 75, 52)
				btn.TextColor3 = Color3.fromRGB(235, 255, 245)
				stroke.Color = Color3.fromRGB(46, 204, 113)
				btn.Text = name .. " : ON"
			else
				btn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
				btn.TextColor3 = Color3.fromRGB(190, 190, 205)
				stroke.Color = Color3.fromRGB(45, 45, 60)
				btn.Text = name .. " : OFF"
			end
			callback(active)
		end)
	end
end

openButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- ================= DAFTAR FITUR =================

createFeatureButton("Speed (100)", function(state)
	speedEnabled = state
	local char = player.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char.Humanoid.WalkSpeed = speedEnabled and 100 or 16
	end
end, false)

createFeatureButton("Super Jump", function(state)
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
end, false)

createFeatureButton("Save Pos", function()
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		savedPosition = char.HumanoidRootPart.CFrame
	end
end, true)

createFeatureButton("Teleport Back", function()
	if savedPosition then
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = savedPosition
		end
	end
end, true)

createFeatureButton("Fly Mode", function(state)
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
end, false)

createFeatureButton("Noclip", function(state)
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
end, false)

createFeatureButton("Invisibility", function(state)
	invisEnabled = state
	local char = player.Character
	if not char then return end
	for _, item in ipairs(char:GetDescendants()) do
		if item:IsA("BasePart") and item.Name ~= "HumanoidRootPart" then
			item.Transparency = invisEnabled and 1 or 0
		elseif item:IsA("Accessory") then
			for _, part in ipairs(item:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = invisEnabled and 1 or 0
				end
			end
		elseif item:IsA("Decal") then
			item.Transparency = invisEnabled and 1 or 0
		elseif item:IsA("BillboardGui") then
			item.Enabled = not invisEnabled
		end
	end
end, false)

createFeatureButton("Player ESP", function(state)
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
					box.Color3 = Color3.fromRGB(255, 90, 90)
					box.Parent = espFolder
				end
			end
		end)
	end
end, false)

createFeatureButton("Fullbright", function(state)
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
end, false)

createFeatureButton("Infinite Jump", function(state)
	infJumpEnabled = state
end, false)

UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled then
		local char = player.Character
		if char and char:FindFirstChildOfClass("Humanoid") then
			char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

createFeatureButton("Wide FOV", function(state)
	fovEnabled = state
	camera.FieldOfView = fovEnabled and 110 or 70
end, false)

player.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid")
	speedEnabled = false
	jumpEnabled = false
	flyEnabled = false
	noclipEnabled = false
	invisEnabled = false
	espEnabled = false
	fullbrightEnabled = false
	infJumpEnabled = false
	fovEnabled = false
	savedPosition = nil
	espFolder:ClearAllChildren()
end)
