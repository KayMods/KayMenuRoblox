-- KayMenu Script by AI
-- Funciones: Interfaz RGB, Fly y Notificaciones
-- Controles: Shift Derecho para abrir/cerrar el menú, WASD para volar.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Variables de estado
local menuOpen = false
local flying = false
local flySpeed = 50
local control = {F = 0, B = 0, L = 0, R = 0}
local lastControl = {F = 0, B = 0, L = 0, R = 0}
local maxSpeed = 500
local camera = game.Workspace.CurrentCamera

-- Función para crear una notificación
local function showNotification(text, duration)
	duration = duration or 3
	local notificationGui = Instance.new("ScreenGui")
	notificationGui.Name = "NotificationGui"
	notificationGui.Parent = game:GetService("CoreGui")
	notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local notificationFrame = Instance.new("Frame")
	notificationFrame.Name = "NotificationFrame"
	notificationFrame.Parent = notificationGui
	notificationFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	notificationFrame.BackgroundTransparency = 0.3
	notificationFrame.BorderSizePixel = 2
	notificationFrame.Position = UDim2.new(1, -220, 1, 50) -- Comienza fuera de la pantalla por la derecha
	notificationFrame.Size = UDim2.new(0, 200, 0, 50)

	local notificationLabel = Instance.new("TextLabel")
	notificationLabel.Name = "NotificationLabel"
	notificationLabel.Parent = notificationFrame
	notificationLabel.BackgroundColor3 = Color3.new(1, 1, 1)
	notificationLabel.BackgroundTransparency = 1
	notificationLabel.Position = UDim2.new(0, 10, 0, 0)
	notificationLabel.Size = UDim2.new(1, -20, 1, 0)
	notificationLabel.Font = Enum.Font.SourceSans
	notificationLabel.Text = text
	notificationLabel.TextColor3 = Color3.new(1, 1, 1)
	notificationLabel.TextScaled = true
	notificationLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Animación de entrada
	local tweenInInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local tweenIn = TweenService:Create(notificationFrame, tweenInInfo, {Position = UDim2.new(1, -220, 1, -60)})
	tweenIn:Play()

	-- Animación de salida y destrucción
	task.wait(duration)
	local tweenOutInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	local tweenOut = TweenService:Create(notificationFrame, tweenOutInfo, {Position = UDim2.new(1, 20, 1, -60)})
	tweenOut:Play()
	tweenOut.Completed:Connect(function()
		notificationGui:Destroy()
	end)
end

-- Crear la interfaz principal (ScreenGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KayMenu"
screenGui.Parent = game:GetService("CoreGui")
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Enabled = false -- Comienza oculto

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 2
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Active = true
mainFrame.Draggable = true

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Parent = mainFrame
titleLabel.BackgroundColor3 = Color3.new(1, 1, 1)
titleLabel.BackgroundTransparency = 1
titleLabel.BorderSizePixel = 0
titleLabel.Position = UDim2.new(0, 0, 0, 10)
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "KayMenu"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextScaled = true

-- Botón de Fly
local flyButton = Instance.new("TextButton")
flyButton.Name = "FlyButton"
flyButton.Parent = mainFrame
flyButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
flyButton.BorderSizePixel = 1
flyButton.Position = UDim2.new(0, 50, 0, 60)
flyButton.Size = UDim2.new(0, 200, 0, 40)
flyButton.Font = Enum.Font.SourceSans
flyButton.Text = "Activar Fly"
flyButton.TextColor3 = Color3.new(1, 1, 1)
flyButton.TextScaled = true

-- Botón de Cerrar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Parent = mainFrame
closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
closeButton.BorderSizePixel = 0
closeButton.Position = UDim2.new(1, -30, 0, 10)
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Font = Enum.Font.SourceSans
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextScaled = true

-- Función para el efecto RGB
local function rgbEffect()
	local hue = 0
	while true do
		if not screenGui.Enabled then -- Detener el efecto si el menú está cerrado
			task.wait()
			continue
		end
		hue = hue + 0.01
		if hue >= 1 then hue = 0 end
		local color = Color3.fromHSV(hue, 1, 1)
		mainFrame.BorderColor3 = color
		titleLabel.TextColor3 = color
		flyButton.BorderColor3 = color
		task.wait(0.1)
	end
end

-- Iniciar el efecto RGB en un hilo separado
task.spawn(rgbEffect)

-- Función para el Fly
local function startFly()
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		showNotification("Error: No se encontró el personaje.", 3)
		return
	end
	local bg = Instance.new("BodyGyro", player.Character.HumanoidRootPart)
	bg.P = 9e4
	bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
	bg.cframe = camera.CFrame
	local bv = Instance.new("BodyVelocity", player.Character.HumanoidRootPart)
	bv.velocity = Vector3.new(0, 0, 0)
	bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
	flying = true
	showNotification("Fly Activado", 2)

	RunService.Stepped:Connect(function()
		if flying then
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				player.Character.Humanoid.PlatformStand = true
			end
			if control.L + control.R ~= 0 or control.F + control.B ~= 0 then
				control.Speed = flySpeed
			elseif not control.Speed then
				control.Speed = 0
			end
			control.F = control.F - lastControl.F
			control.B = control.B - lastControl.B
			control.L = control.L - lastControl.L
			control.R = control.R - lastControl.R
			lastControl = {F = control.F, B = control.B, L = control.L, R = control.R}
			bv.velocity = (camera.CoordinateFrame.lookVector * (control.F + control.B) + camera.CoordinateFrame * Vector3.new(control.L + control.R, (control.F + control.B) * 0.2, 0).unit * control.Speed) * 0.9
			bg.cframe = camera.CoordinateFrame * CFrame.Angles(-math.rad((control.F + control.B) * 50 * control.Speed / maxSpeed), 0, 0)
		end
	end)
end

-- Función para detener el Fly
local function stopFly()
	flying = false
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.PlatformStand = false
	end
	if player.Character and player.Character:FindFirstChild("HumanoidRoot
