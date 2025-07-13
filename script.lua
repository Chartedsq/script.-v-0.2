local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer

local flying = false
local invisible = false
local clickTPEnabled = false
local currentFlySpeed = 150	
local flyAcceleration = 0
local flyDeceleration = 0
local maxFlySpeed = 0
local direction = {F=false, B=false, L=false, R=false, U=false, D=false}
local savedPosition = nil

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FlyInvisTPGui"

-- Fő keret (Kezdetben középen)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 280)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

-- Lekerekített sarkok a fő kerethez
local uiCornerMain = Instance.new("UICorner")
uiCornerMain.CornerRadius = UDim.new(0, 10)
uiCornerMain.Parent = mainFrame

-- Árnyékhatás
local uiStrokeMain = Instance.new("UIStroke")
uiStrokeMain.Color = Color3.fromRGB(0, 0, 0)
uiStrokeMain.Transparency = 0.5
uiStrokeMain.Thickness = 2
uiStrokeMain.Parent = mainFrame

-- Címsor és Bezárás gomb tartó
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local uiCornerTitleBar = Instance.new("UICorner")
uiCornerTitleBar.CornerRadius = UDim.new(0, 8)
uiCornerTitleBar.Parent = titleBar

-- Címsor (ezen keresztül mozgatjuk a GUI-t)
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -30, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.Text = "         Ryder cheats V-0.2"
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
-- >>> ITT A VÁLTOZTATÁS <<<
titleLabel.Active = false -- Ez biztosítja, hogy a kattintás átmenjen a címsor alatti elemekre
titleLabel.Parent = titleBar

-- Bezárás Gomb (X)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 1, 0)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20
closeButton.Text = "X"
closeButton.Parent = titleBar

local uiCornerClose = Instance.new("UICorner")
uiCornerClose.CornerRadius = UDim.new(0, 8)
uiCornerClose.Parent = closeButton

-- Fő gombtartó (ez tartalmazza majd az összes gombot és a TP panelt)
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -20, 1, -40)
buttonContainer.Position = UDim2.new(0.5, 0, 0, 35)
buttonContainer.AnchorPoint = Vector2.new(0.5, 0)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = buttonContainer

-- Gombkészítő segédfüggvény
local function createButton(text, parentFrame)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 200, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextTransparency = 0
	btn.BackgroundTransparency = 0.3
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 18
	btn.Text = text
	btn.Parent = parentFrame

	local uiCornerBtn = Instance.new("UICorner")
	uiCornerBtn.CornerRadius = UDim.new(0, 8)
	uiCornerBtn.Parent = btn

	btn.MouseEnter:Connect(function()
		btn:TweenCustomProperties("BackgroundTransparency", 0, 0.2)
	end)
	btn.MouseLeave:Connect(function()
		btn:TweenCustomProperties("BackgroundTransparency", 0.3, 0.2)
	end)

	return btn
end

-- Gombok (ezek kerülnek először a buttonContainer-be)
local flyButton = createButton("Repülés: KI", buttonContainer)
local invisButton = createButton("Láthatatlanság: KI", buttonContainer)
local clickTPButton = createButton("Kattintás TP: KI", buttonContainer)

-- TP panel (most a buttonContainer gyereke, a többi gomb után)
local tpPanel = Instance.new("Frame")
tpPanel.Size = UDim2.new(1, 0, 0, 100)
tpPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
tpPanel.BorderSizePixel = 0
tpPanel.Parent = buttonContainer

local uiCornerTPPanel = Instance.new("UICorner")
uiCornerTPPanel.CornerRadius = UDim.new(0, 10)
uiCornerTPPanel.Parent = tpPanel

local tpLayout = Instance.new("UIListLayout")
tpLayout.Padding = UDim.new(0, 5)
tpLayout.FillDirection = Enum.FillDirection.Vertical
tpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tpLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tpLayout.SortOrder = Enum.SortOrder.LayoutOrder
tpLayout.Parent = tpPanel

local tpLabel = Instance.new("TextLabel")
tpLabel.Size = UDim2.new(1, 0, 0, 20)
tpLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
tpLabel.BackgroundTransparency = 1
tpLabel.TextColor3 = Color3.new(1,1,1)
tpLabel.Font = Enum.Font.SourceSansBold
tpLabel.TextSize = 16
tpLabel.Text = "Teleport Funkciók"
tpLabel.Parent = tpPanel

-- TP gombok (ezek kerülnek a tpPanel-be)
local setTPButton = createButton("TP Pozíció Beállítása", tpPanel)
local tpBackButton = createButton("Vissza TP", tpPanel)

-- Visszaállítás ikon (ÚJ, MOZGATHATÓ)
local restoreIcon = Instance.new("TextButton")
restoreIcon.Size = UDim2.new(0, 55, 0, 55)
restoreIcon.AnchorPoint = Vector2.new(1, 0)
restoreIcon.Position = UDim2.new(1, -600, 0, 300)
restoreIcon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
restoreIcon.TextColor3 = Color3.fromRGB(200, 0, 0)
restoreIcon.Font = Enum.Font.SourceSansBold
restoreIcon.TextSize = 40
restoreIcon.Text = "R"
restoreIcon.Visible = false
restoreIcon.Parent = gui

local uiCornerRestore = Instance.new("UICorner")
uiCornerRestore.CornerRadius = UDim.new(0, 10)
uiCornerRestore.Parent = restoreIcon

local uiStrokeRestore = Instance.new("UIStroke")
uiStrokeRestore.Color = Color3.fromRGB(255, 0, 0)
uiStrokeRestore.Transparency = 0.7
uiStrokeRestore.Thickness = 2
uiStrokeRestore.Parent = restoreIcon


-- Játékos vezérlés lekérő
local function getControllingPart()
	local character = player.Character
	if not character then return nil end
	local seat = character:FindFirstChildWhichIsA("VehicleSeat") or character:FindFirstChildWhichIsA("Seat")
	if seat and seat.Occupant == character:FindFirstChildOfClass("Humanoid") then
		return seat.Parent and seat.Parent.PrimaryPart or seat
	end
	return character:FindFirstChild("HumanoidRootPart")
end

-- Láthatóság vezérlés
local function setVisibility(instance, visible)
	for _, p in pairs(instance:GetChildren()) do
		if p:IsA("BasePart") then
			p.Transparency = visible and 0 or 1
			p.CanCollide = visible
		elseif p:IsA("Decal") then
			p.Transparency = visible and 0 or 1
		elseif p:IsA("Accessory") and p:FindFirstChild("Handle") then
			if p.Handle:IsA("BasePart") then
				p.Handle.Transparency = visible and 0 or 1
			end
		end
	end
end

-- Fly be/ki
local function toggleFly(state)
	flying = state
	flyButton.Text = "Repülés: " .. (flying and "BE" or "KI")
	flyButton.BackgroundColor3 = flying and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.PlatformStand = flying
		end
		if flying then
			currentFlySpeed = 50
		else
			currentFlySpeed = 0
		end
	end
end

-- Láthatatlanság be/ki
local function toggleInvisibility(state)
	invisible = state
	invisButton.Text = "Láthatatlanság: " .. (invisible and "BE" or "KI")
	invisButton.BackgroundColor3 = invisible and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
	local char = player.Character
	if char then
		setVisibility(char, not invisible)
		local seat = char:FindFirstChildWhichIsA("VehicleSeat") or char:FindFirstChildWhichIsA("Seat")
		if seat and seat.Parent then
			setVisibility(seat.Parent, not invisible)
		end
	end
end

-- Click teleport be/ki
local function toggleClickTP(state)
	clickTPEnabled = state
	clickTPButton.Text = "Kattintás TP: " .. (clickTPEnabled and "BE" or "KI")
	clickTPButton.BackgroundColor3 = clickTPEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end

-- Gomb események
flyButton.MouseButton1Click:Connect(function() toggleFly(not flying) end)
invisButton.MouseButton1Click:Connect(function() toggleInvisibility(not invisible) end)
clickTPButton.MouseButton1Click:Connect(function() toggleClickTP(not clickTPEnabled) end)

setTPButton.MouseButton1Click:Connect(function()
	local part = getControllingPart()
	if part then
		savedPosition = part.CFrame
		setTPButton.Text = "Pozíció Elmentve!"
		setTPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
		task.wait(1)
		setTPButton.Text = "TP Pozíció Beállítása"
		setTPButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end
end)

tpBackButton.MouseButton1Click:Connect(function()
	if savedPosition then
		local part = getControllingPart()
		if part then
			part.CFrame = savedPosition
		end
	else
		tpBackButton.Text = "Nincs Mentett Pozíció!"
		tpBackButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
		task.wait(1)
		tpBackButton.Text = "Vissza TP"
		tpBackButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end
end)

-- *** GUI Mozgatása Függvény ***
local function makeDraggable(guiObject, targetFrame)
    local dragging = false
    local dragStartOffset = Vector2.zero
    targetFrame = targetFrame or guiObject -- Ha nincs megadva targetFrame, akkor a guiObject-et mozgatjuk

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartOffset = UIS:GetMouseLocation() - targetFrame.AbsolutePosition
            -- Az AnchorPoint-ot 0,0-ra kell állítani mozgatás előtt, hogy ne ugráljon a pozíció
            targetFrame.Position = UDim2.new(0, targetFrame.AbsolutePosition.X, 0, targetFrame.AbsolutePosition.Y)
            targetFrame.AnchorPoint = Vector2.new(0, 0)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mouseLocation = UIS:GetMouseLocation()
            local newX = mouseLocation.X - dragStartOffset.X
            local newY = mouseLocation.Y - dragStartOffset.Y

            targetFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Alkalmazzuk a mozgatást a fő panel címsorára és a restoreIcon-ra is
makeDraggable(titleBar, mainFrame) -- Fő panel mozgatása a címsoron keresztül, de a mainFrame-et mozgatjuk
makeDraggable(restoreIcon) -- restoreIcon mozgatása közvetlenül (mivel az AnchorPoint-ja 0,0)

-- Bezárás/Megnyitás logika
closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    restoreIcon.Visible = true
end)

restoreIcon.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    restoreIcon.Visible = false
end)


-- Billentyűk figyelése
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.X then toggleFly(not flying) end
	-- Gyorsítás/Lassítás billentyűk (maradtak)
	if input.KeyCode == Enum.KeyCode.Q then currentFlySpeed = math.min(currentFlySpeed + flyAcceleration, maxFlySpeed) end
	if input.KeyCode == Enum.KeyCode.E then currentFlySpeed = math.max(currentFlySpeed - flyDeceleration, 0) end

	if input.KeyCode == Enum.KeyCode.W then direction.F = true end
	if input.KeyCode == Enum.KeyCode.S then direction.B = true end
	if input.KeyCode == Enum.KeyCode.A then direction.L = true end
	if input.KeyCode == Enum.KeyCode.D then direction.R = true end
	if input.KeyCode == Enum.KeyCode.Space then direction.U = true end
	if input.KeyCode == Enum.KeyCode.LeftControl then direction.D = true end
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then direction.F = false end
	if input.KeyCode == Enum.KeyCode.S then direction.B = false end
	if input.KeyCode == Enum.KeyCode.A then direction.L = false end
	if input.KeyCode == Enum.KeyCode.D then direction.R = false end
	if input.KeyCode == Enum.KeyCode.Space then direction.U = false end
	if input.KeyCode == Enum.KeyCode.LeftControl then direction.D = false end
end)

-- Folyamatos mozgás
RunService.RenderStepped:Connect(function()
	if flying then
		local part = getControllingPart()
		if part then
			for _, p in pairs(part.Parent:GetChildren()) do
				if p:IsA("BasePart") then
					p.CanCollide = false
				end
			end
			local cam = workspace.CurrentCamera
			local moveVec = Vector3.zero
			if direction.F then moveVec += cam.CFrame.LookVector end
			if direction.B then moveVec -= cam.CFrame.LookVector end
			if direction.L then moveVec -= cam.CFrame.RightVector end
			if direction.R then moveVec += cam.CFrame.RightVector end
			if direction.U then moveVec += Vector3.new(0,1,0) end
			if direction.D then moveVec -= Vector3.new(0,1,0) end
			
			if moveVec.Magnitude > 0 then 
				moveVec = moveVec.Unit * currentFlySpeed 
			else
				currentFlySpeed = math.max(currentFlySpeed - flyDeceleration * RunService.RenderStepped:Wait(), 0)
			end
			part.Velocity = moveVec
		end
	end
end)

-- Click teleport működés
UIS.InputBegan:Connect(function(input, gameProcessed)
	if clickTPEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
		local mouse = player:GetMouse()
		local target = mouse.Hit
		if target then
			local part = getControllingPart()
			if part then
				part.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
			end
		end
	end
end)