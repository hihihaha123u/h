--[ SERVICES ]--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--[ VARIABLES ]--
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--[ UI CONFIGURATION ]--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TradeHelperUI"
screenGui.ResetOnSpawn = false -- Giữ UI không mất khi nhân vật reset
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 160)
mainFrame.Position = UDim2.new(0.5, -140, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Thêm Gradient cho đẹp
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
}
gradient.Rotation = 45
gradient.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Trade Scam Freeze"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 30)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Waiting..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = mainFrame

--[ UTILS ]--
local function createToggle(name, posY)
    local toggleData = {Enabled = false}
    
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 240, 0, 35)
    btn.Position = UDim2.new(0.5, -120, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = btn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 40, 0, 20)
    indicator.Position = UDim2.new(1, -50, 0.5, -10)
    indicator.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    indicator.Parent = btn
    
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = indicator
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    function toggleData:Update(state)
        self.Enabled = state
        local targetColor = state and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 75)
        local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        
        TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = state and Color3.new(1,1,1) or Color3.fromRGB(200,200,200)}):Play()
    end

    btn.MouseButton1Click:Connect(function()
        toggleData:Update(not toggleData.Enabled)
    end)

    return toggleData
end

local freezeToggle = createToggle("Freeze Trade", 65)
local forceToggle = createToggle("Force Accept", 105)

--[ LOGIC DRAG ]-- (Hệ thống kéo thả mượt hơn)
local dragging, dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--[ TRADE CHECKER ]--
local function getTradePartner()
    local main = playerGui:FindFirstChild("Main")
    if main and main:FindFirstChild("Trade") and main.Trade.Visible then
        -- Cố gắng tìm tên partner từ UI của game
        local container = main.Trade:FindFirstChild("Container")
        if container then
            for i = 1, 2 do
                local frame = container:FindFirstChild(tostring(i))
                local label = frame and frame:FindFirstChild("TextLabel")
                if label and label.Text ~= player.Name and label.Text ~= player.DisplayName then
                    return label.Text
                end
            end
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    local partner = getTradePartner()
    if partner then
        statusLabel.Text = "Trading with: " .. partner
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    else
        statusLabel.Text = "Status: Not in trade"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        -- Tự động tắt toggle nếu thoát trade
        if freezeToggle.Enabled then freezeToggle:Update(false) end
        if forceToggle.Enabled then forceToggle:Update(false) end
    end
end)

-- Intro Animation
mainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0, 280, 0, 160)}):Play()
