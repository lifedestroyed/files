-- ShadowX Premium Script v3.2
-- Universal (Executor/LocalScript)

--[[
  Credits:
  - UI Design: ShadowX Team
  - Fly System: Advanced inertia flight
  - ESP System: Optimized rendering
  - Core Scripting: ShadowX Dev Team
  - Special Thanks: Infinite Yield for inspiration
]]

-- Environment detection
local isExecutor = (syn and true) or (protect_gui and true) or 
	(getgenv and true) or (is_sirhurt_closure and true) or false

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

-- Main variables
local selectedPlayer = nil
local walkspeed = 16
local jumppower = 50
local flying = false
local noclip = false
local espEnabled = false
local godmode = false
local flySpeed = 2
local flyBoost = 5
local espFolders = {}
local connections = {}

-- Improved Fly System
local flyBodyVelocity
local flyBodyGyro
local lastCamera = workspace.CurrentCamera.CFrame

local function StartFly()
	local character = LocalPlayer.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or not humanoid.RootPart then return end

	-- Create flight controls
	flyBodyVelocity = Instance.new("BodyVelocity")
	flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
	flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	flyBodyVelocity.P = 1000
	flyBodyVelocity.Parent = humanoid.RootPart

	flyBodyGyro = Instance.new("BodyGyro")
	flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	flyBodyGyro.P = 10000
	flyBodyGyro.Parent = humanoid.RootPart

	-- Flight control function
	connections.flyLoop = RunService.Heartbeat:Connect(function(delta)
		if not flying or not character:FindFirstChild("HumanoidRootPart") then 
			if flyBodyVelocity then flyBodyVelocity:Destroy() end
			if flyBodyGyro then flyBodyGyro:Destroy() end
			return 
		end

		local root = humanoid.RootPart
		local camera = workspace.CurrentCamera
		lastCamera = camera.CFrame

		-- Get control inputs
		local forward = UserInputService:IsKeyDown(Enum.KeyCode.W) and -1 or UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0
		local right = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0
		local up = UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -1 or 0

		-- Calculate movement direction
		local speed = flySpeed
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			speed = flySpeed * flyBoost
		end

		local lookVector = camera.CFrame.LookVector
		local rightVector = camera.CFrame.RightVector
		local upVector = Vector3.new(0, 1, 0)

		local moveDirection = (lookVector * forward) + (rightVector * right) + (upVector * up)
		moveDirection = moveDirection.Unit * speed * 100

		-- Apply movement
		flyBodyVelocity.Velocity = moveDirection
		flyBodyGyro.CFrame = camera.CFrame
	end)
end

local function StopFly()
	if flyBodyVelocity then flyBodyVelocity:Destroy() end
	if flyBodyGyro then flyBodyGyro:Destroy() end
	if connections.flyLoop then connections.flyLoop:Disconnect() end
end

-- ESP System
local function CreateESP(player)
	if not player or not player.Character then return end

	-- Remove existing ESP if any
	if espFolders[player] then
		espFolders[player]:Destroy()
		espFolders[player] = nil
	end

	local character = player.Character
	local espFolder = Instance.new("Folder")
	espFolder.Name = player.Name.."_ESP"
	espFolder.Parent = character

	-- Highlight
	local highlight = Instance.new("Highlight")
	highlight.Name = "Highlight"
	highlight.Adornee = character
	highlight.FillColor = Color3.fromRGB(255, 50, 50)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.Parent = espFolder

	-- Name Tag
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameTag"
	billboard.Adornee = character:WaitForChild("Head")
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = espFolder

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.Parent = billboard

	-- Health Bar
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local healthBar = Instance.new("BillboardGui")
		healthBar.Name = "HealthBar"
		healthBar.Adornee = character:WaitForChild("Head")
		healthBar.Size = UDim2.new(2, 0, 0.2, 0)
		healthBar.StudsOffset = Vector3.new(0, 2, 0)
		healthBar.AlwaysOnTop = true
		healthBar.Parent = espFolder

		local healthFrame = Instance.new("Frame")
		healthFrame.Size = UDim2.new(1, 0, 1, 0)
		healthFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		healthFrame.BorderSizePixel = 0
		healthFrame.Parent = healthBar

		local healthFill = Instance.new("Frame")
		healthFill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
		healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		healthFill.BorderSizePixel = 0
		healthFill.Parent = healthFrame

		-- Update health
		connections.healthChanged = humanoid.HealthChanged:Connect(function()
			healthFill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
			healthFill.BackgroundColor3 = Color3.fromHSV(humanoid.Health / humanoid.MaxHealth * 0.3, 1, 1)
		end)
	end

	espFolders[player] = espFolder

	-- Cleanup when character changes
	connections.characterRemoving = player.CharacterRemoving:Connect(function()
		if espFolders[player] then
			espFolders[player]:Destroy()
			espFolders[player] = nil
		end
	end)
end

-- GUI Creation
local ShadowX = Instance.new("ScreenGui")
ShadowX.Name = "ShadowXPremium_"..tostring(math.random(1, 10000))
ShadowX.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ShadowX.ResetOnSpawn = false

if isExecutor then
	ShadowX.Parent = CoreGui
else
	ShadowX.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Styling
local mainColor = Color3.fromRGB(28, 28, 36)
local accentColor = Color3.fromRGB(0, 120, 215)
local textColor = Color3.fromRGB(240, 240, 240)
local errorColor = Color3.fromRGB(255, 60, 60)

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = mainColor
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ShadowX

-- UI Elements
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 0, 0)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.7
UIStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TitleBar.BackgroundTransparency = 0.1
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 8)
UICorner2.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SHADOW X"
Title.TextColor3 = accentColor
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundColor3 = errorColor
CloseButton.BackgroundTransparency = 0.7
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = textColor
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.Parent = TitleBar

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 6)
UICorner3.Parent = CloseButton

-- Close animation
CloseButton.MouseButton1Click:Connect(function()
	local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 400, 0, 0)})
	tween:Play()
	tween.Completed:Wait()
	ShadowX:Destroy()
end)

-- Tabs
local Tabs = {"Players", "Local", "Visuals", "Weapons", "Admin", "Credits"}
local TabButtons = {}
local TabFrames = {}

local function CreateTab(tabName)
	local index = #TabButtons + 1

	-- Tab Button
	local TabButton = Instance.new("TextButton")
	TabButton.Name = tabName.."TabButton"
	TabButton.Size = UDim2.new(0.166, 0, 0, 30)
	TabButton.Position = UDim2.new(0.166 * (index - 1), 0, 0, 40)
	TabButton.BackgroundColor3 = index == 1 and accentColor or Color3.fromRGB(40, 40, 50)
	TabButton.BackgroundTransparency = index == 1 and 0.3 or 0.7
	TabButton.BorderSizePixel = 0
	TabButton.Text = tabName
	TabButton.TextColor3 = textColor
	TabButton.Font = Enum.Font.Gotham
	TabButton.TextSize = 14
	TabButton.Parent = MainFrame

	local UICorner4 = Instance.new("UICorner")
	UICorner4.CornerRadius = UDim.new(0, 6)
	UICorner4.Parent = TabButton

	-- Tab Frame
	local TabFrame = Instance.new("Frame")
	TabFrame.Name = tabName.."TabFrame"
	TabFrame.Size = UDim2.new(1, -20, 1, -80)
	TabFrame.Position = UDim2.new(0, 10, 0, 80)
	TabFrame.BackgroundTransparency = 1
	TabFrame.Visible = index == 1
	TabFrame.Parent = MainFrame

	-- ScrollingFrame
	local ScrollFrame = Instance.new("ScrollingFrame")
	ScrollFrame.Name = "ScrollFrame"
	ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
	ScrollFrame.Position = UDim2.new(0, 0, 0, 0)
	ScrollFrame.BackgroundTransparency = 1
	ScrollFrame.ScrollBarThickness = 5
	ScrollFrame.ScrollBarImageColor3 = accentColor
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollFrame.Parent = TabFrame

	TabButton.MouseButton1Click:Connect(function()
		for _, frame in pairs(TabFrames) do
			frame.Visible = false
		end
		TabFrame.Visible = true

		for _, button in pairs(TabButtons) do
			button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			button.BackgroundTransparency = 0.7
		end
		TabButton.BackgroundColor3 = accentColor
		TabButton.BackgroundTransparency = 0.3
	end)

	table.insert(TabButtons, TabButton)
	table.insert(TabFrames, TabFrame)

	return ScrollFrame
end

-- Create Tabs
local PlayersTab = CreateTab("Players")
local LocalTab = CreateTab("Local")
local VisualsTab = CreateTab("Visuals")
local WeaponsTab = CreateTab("Weapons")
local AdminTab = CreateTab("Admin")
local CreditsTab = CreateTab("Credits")

-- UI Element Functions
local function AddButton(parent, text, callback)
	local button = Instance.new("TextButton")
	button.Name = text.."Button"
	button.Size = UDim2.new(1, 0, 0, 35)
	button.Position = UDim2.new(0, 0, 0, #parent:GetChildren() * 40 + 5)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	button.BackgroundTransparency = 0.5
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = textColor
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.Parent = parent

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 6)
	UICorner.Parent = button

	parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 40 + 10)

	-- Hover effects
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
	end)

	button.MouseButton1Click:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = accentColor}):Play()
		TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
		callback()
	end)

	return button
end

local function AddSlider(parent, text, min, max, default, callback)
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Name = text.."SliderFrame"
	sliderFrame.Size = UDim2.new(1, 0, 0, 60)
	sliderFrame.Position = UDim2.new(0, 0, 0, #parent:GetChildren() * 65 + 5)
	sliderFrame.BackgroundTransparency = 1
	sliderFrame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text..": "..default
	label.TextColor3 = textColor
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = sliderFrame

	local slider = Instance.new("Frame")
	slider.Name = "Slider"
	slider.Size = UDim2.new(1, 0, 0, 10)
	slider.Position = UDim2.new(0, 0, 0, 30)
	slider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	slider.BorderSizePixel = 0
	slider.Parent = sliderFrame

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 5)
	UICorner.Parent = slider

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
	fill.Position = UDim2.new(0, 0, 0, 0)
	fill.BackgroundColor3 = accentColor
	fill.BorderSizePixel = 0
	fill.Parent = slider

	local UICorner2 = Instance.new("UICorner")
	UICorner2.CornerRadius = UDim.new(0, 5)
	UICorner2.Parent = fill

	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Size = UDim2.new(0, 20, 0, 20)
	button.Position = UDim2.new((default - min)/(max - min), -10, 0.5, -10)
	button.BackgroundColor3 = textColor
	button.BorderSizePixel = 0
	button.Text = ""
	button.Parent = slider

	local UICorner3 = Instance.new("UICorner")
	UICorner3.CornerRadius = UDim.new(0, 10)
	UICorner3.Parent = button

	parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 65 + 10)

	local dragging = false

	button.MouseButton1Down:Connect(function()
		dragging = true
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	local connection
	connection = UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local x = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
			x = math.clamp(x, 0, 1)
			local value = math.floor(min + (max - min) * x)
			fill.Size = UDim2.new(x, 0, 1, 0)
			button.Position = UDim2.new(x, -10, 0.5, -10)
			label.Text = text..": "..value
			callback(value)
		end
	end)

	sliderFrame.Destroying:Connect(function()
		connection:Disconnect()
	end)

	return sliderFrame
end

local function AddToggle(parent, text, default, callback)
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Name = text.."ToggleFrame"
	toggleFrame.Size = UDim2.new(1, 0, 0, 40)
	toggleFrame.Position = UDim2.new(0, 0, 0, #parent:GetChildren() * 45 + 5)
	toggleFrame.BackgroundTransparency = 1
	toggleFrame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = textColor
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = toggleFrame

	local toggle = Instance.new("Frame")
	toggle.Name = "Toggle"
	toggle.Size = UDim2.new(0, 60, 0, 30)
	toggle.Position = UDim2.new(1, -60, 0.5, -15)
	toggle.BackgroundColor3 = default and accentColor or Color3.fromRGB(80, 80, 80)
	toggle.BackgroundTransparency = 0.5
	toggle.BorderSizePixel = 0
	toggle.Parent = toggleFrame

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 15)
	UICorner.Parent = toggle

	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Size = UDim2.new(0, 26, 0, 26)
	button.Position = default and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
	button.BackgroundColor3 = textColor
	button.BorderSizePixel = 0
	button.Text = ""
	button.Parent = toggle

	local UICorner2 = Instance.new("UICorner")
	UICorner2.CornerRadius = UDim.new(0, 13)
	UICorner2.Parent = button

	parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 45 + 10)

	local state = default

	button.MouseButton1Click:Connect(function()
		state = not state
		if state then
			TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = accentColor}):Play()
			TweenService:Create(button, TweenInfo.new(0.2), {Position = UDim2.new(1, -28, 0.5, -13)}):Play()
		else
			TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
			TweenService:Create(button, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -13)}):Play()
		end
		callback(state)
	end)

	return toggleFrame
end

-- Player Functions
local function GetCharacter(player)
	return player.Character or player.CharacterAdded:Wait()
end

local function GetHumanoid(player)
	local character = GetCharacter(player)
	return character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart(player)
	local character = GetCharacter(player)
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso")
end

-- Update player list
local function UpdatePlayerList()
	for _, child in ipairs(PlayersTab:GetChildren()) do
		if child:IsA("TextButton") and child.Name ~= "RefreshButton" then
			child:Destroy()
		end
	end

	for i, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			AddButton(PlayersTab, player.Name, function()
				selectedPlayer = player
			end)
		end
	end
end

AddButton(PlayersTab, "⟳ Refresh", UpdatePlayerList)
UpdatePlayerList()

-- Player Functions
AddButton(PlayersTab, "Teleport to Player", function()
	if selectedPlayer then
		local targetRoot = GetRootPart(selectedPlayer)
		local myRoot = GetRootPart(LocalPlayer)

		if targetRoot and myRoot then
			myRoot.CFrame = targetRoot.CFrame
		end
	end
end)

AddButton(PlayersTab, "Kill Player", function()
	if selectedPlayer then
		local humanoid = GetHumanoid(selectedPlayer)
		if humanoid then
			humanoid.Health = 0
		end
	end
end)

AddButton(PlayersTab, "Spectate Player", function()
	if selectedPlayer then
		workspace.CurrentCamera.CameraSubject = GetHumanoid(selectedPlayer)
	end
end)

AddButton(PlayersTab, "Copy Outfit", function()
	if selectedPlayer then
		local targetChar = GetCharacter(selectedPlayer)
		local myChar = GetCharacter(LocalPlayer)

		for _, part in ipairs(myChar:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "Head" then
				part:Destroy()
			end
		end

		for _, part in ipairs(targetChar:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "Head" then
				local fake = part:Clone()
				fake.Parent = myChar
				fake.CanCollide = false

				local weld = Instance.new("WeldConstraint")
				weld.Part0 = myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("UpperTorso")
				weld.Part1 = fake
				weld.Parent = fake
			end
		end
	end
end)

-- Local Player Functions
AddSlider(LocalTab, "WalkSpeed", 16, 200, 16, function(value)
	walkspeed = value
	local humanoid = GetHumanoid(LocalPlayer)
	if humanoid then
		humanoid.WalkSpeed = value
	end
end)

AddSlider(LocalTab, "Jump Power", 50, 500, 50, function(value)
	jumppower = value
	local humanoid = GetHumanoid(LocalPlayer)
	if humanoid then
		humanoid.JumpPower = value
	end
end)

AddSlider(LocalTab, "Fly Speed", 1, 10, 2, function(value)
	flySpeed = value
end)

AddToggle(LocalTab, "Fly", false, function(state)
	flying = state
	if state then
		StartFly()
	else
		StopFly()
	end
end)

AddToggle(LocalTab, "Noclip", false, function(state)
	noclip = state
end)

AddToggle(LocalTab, "Invisibility", false, function(state)
	local character = GetCharacter(LocalPlayer)
	if character then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = state and 1 or 0
				if part:FindFirstChildOfClass("Decal") then
					part:FindFirstChildOfClass("Decal").Transparency = state and 1 or 0
				end
			end
		end
	end
end)

AddToggle(LocalTab, "God Mode", false, function(state)
	godmode = state
	local humanoid = GetHumanoid(LocalPlayer)
	if humanoid then
		if state then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		else
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
		end
	end
end)

-- Visuals
AddToggle(VisualsTab, "ESP", false, function(state)
	espEnabled = state

	if state then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				CreateESP(player)
			end
		end

		connections.playerAdded = Players.PlayerAdded:Connect(function(player)
			player.CharacterAdded:Connect(function()
				if espEnabled then
					CreateESP(player)
				end
			end)
		end)
	else
		for player, folder in pairs(espFolders) do
			folder:Destroy()
			espFolders[player] = nil
		end

		if connections.playerAdded then
			connections.playerAdded:Disconnect()
		end
	end
end)

-- Weapons
AddButton(WeaponsTab, "Give Gun", function()
	local character = GetCharacter(LocalPlayer)
	if not character then return end

	local tool = Instance.new("Tool")
	tool.Name = "ShadowX Gun"
	tool.RequiresHandle = false
	tool.Parent = LocalPlayer.Backpack

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://131735724"
	sound.Volume = 1
	sound.Parent = tool

	tool.Activated:Connect(function()
		sound:Play()

		local rayOrigin = workspace.CurrentCamera.CFrame.Position
		local rayDirection = workspace.CurrentCamera.CFrame.LookVector * 1000
		local ray = Ray.new(rayOrigin, rayDirection)

		local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {character})

		-- Bullet tracer
		local bulletTracer = Instance.new("Part")
		bulletTracer.Size = Vector3.new(0.1, 0.1, (position - rayOrigin).Magnitude)
		bulletTracer.CFrame = CFrame.new(rayOrigin + (position - rayOrigin)/2, position)
		bulletTracer.Anchored = true
		bulletTracer.CanCollide = false
		bulletTracer.Color = Color3.fromRGB(255, 255, 0)
		bulletTracer.Material = Enum.Material.Neon
		bulletTracer.Parent = workspace
		game:GetService("Debris"):AddItem(bulletTracer, 0.1)

		if hit then
			-- Hit effect
			local hitEffect = Instance.new("Part")
			hitEffect.Size = Vector3.new(0.5, 0.5, 0.5)
			hitEffect.CFrame = CFrame.new(position)
			hitEffect.Anchored = true
			hitEffect.CanCollide = false
			hitEffect.Color = Color3.fromRGB(255, 100, 0)
			hitEffect.Material = Enum.Material.Neon
			hitEffect.Parent = workspace
			game:GetService("Debris"):AddItem(hitEffect, 0.5)

			-- Damage
			local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:TakeDamage(25)
			end
		end
	end)
end)

-- Admin
AddButton(AdminTab, "Kill All", function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local humanoid = GetHumanoid(player)
			if humanoid then
				humanoid.Health = 0
			end
		end
	end
end)

AddButton(AdminTab, "Freeze All", function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local humanoid = GetHumanoid(player)
			if humanoid then
				humanoid.PlatformStand = true
			end
		end
	end
end)

AddButton(AdminTab, "Unfreeze All", function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local humanoid = GetHumanoid(player)
			if humanoid then
				humanoid.PlatformStand = false
			end
		end
	end
end)

AddButton(AdminTab, "Server Hop", function()
	if isExecutor then
		local servers = {}
		local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
		for _, server in ipairs(game:GetService("HttpService"):JSONDecode(req).data) do
			if server.playing < server.maxPlayers and server.id ~= game.JobId then
				table.insert(servers, server.id)
			end
		end
		if #servers > 0 then
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
		else
			game:GetService("TeleportService"):Teleport(game.PlaceId)
		end
	else
		local message = Instance.new("Message")
		message.Text = "Server hop works only with executors"
		message.Parent = workspace
		wait(2)
		message:Destroy()
	end
end)

-- Credits
local creditsText = [[
ShadowX Premium Script v3.2

Credits:
- UI Design: ShadowX Team
- Fly System: Advanced inertia flight
- ESP System: Optimized rendering
- Core Scripting: ShadowX Dev Team
- Special Thanks: Infinite Yield for inspiration

Features:
- Improved Fly with inertia
- Working ESP with health bars
- God Mode
- Noclip
- Player utilities
- Weapon system
- Admin tools
]]

local creditsLabel = Instance.new("TextLabel")
creditsLabel.Name = "CreditsLabel"
creditsLabel.Size = UDim2.new(1, -20, 1, -20)
creditsLabel.Position = UDim2.new(0, 10, 0, 10)
creditsLabel.BackgroundTransparency = 1
creditsLabel.Text = creditsText
creditsLabel.TextColor3 = textColor
creditsLabel.Font = Enum.Font.Gotham
creditsLabel.TextSize = 14
creditsLabel.TextXAlignment = Enum.TextXAlignment.Left
creditsLabel.TextYAlignment = Enum.TextYAlignment.Top
creditsLabel.TextWrapped = true
creditsLabel.Parent = CreditsTab

-- Noclip loop
connections.noclipLoop = RunService.Stepped:Connect(function()
	if noclip and LocalPlayer.Character then
		for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- Update on character spawn
LocalPlayer.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")

	humanoid.WalkSpeed = walkspeed
	humanoid.JumpPower = jumppower

	if flying then
		StartFly()
	end

	if godmode then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	end
end)

-- Auto-update player list
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

-- GUI Protection
local function ProtectGUI(gui)
	if isExecutor then
		if protect_gui then
			protect_gui(gui)
		elseif syn and syn.protect_gui then
			syn.protect_gui(gui)
		elseif getgenv().protectgui then
			getgenv().protectgui(gui)
		end
	end
end

ProtectGUI(ShadowX)

-- Cleanup
game:GetService("Players").PlayerRemoving:Connect(function(player)
	if player == LocalPlayer then
		StopFly()
		for _, connection in pairs(connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
end)

-- Initialization animation
MainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.5), {Size = UDim2.new(0, 400, 0, 500)}):Play()
