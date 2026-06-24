local plr = game.Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui", 5) or plr.PlayerGui

-- Membersihkan UI lama jika script di-execute ulang
if PlayerGui:FindFirstChild("STARGOD_AUTO_BUMP_V2") then
    PlayerGui["STARGOD_AUTO_BUMP_V2"]:Destroy()
end

-- ==========================================
-- UI INTERFACE MINIMALIS
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "STARGOD_AUTO_BUMP_V2"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 110)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 0, 0, 8); Title.Size = UDim2.new(1, 0, 0, 20)
Title.Font = Enum.Font.GothamBold; Title.Text = "★ BUMP MONSTER V2 ★"; Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.TextSize = 10

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = MainFrame; ToggleBtn.Position = UDim2.new(0, 15, 0, 40); ToggleBtn.Size = UDim2.new(1, -30, 0, 35)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 42, 58); ToggleBtn.Font = Enum.Font.GothamSemibold; ToggleBtn.Text = "AUTO FIGHT : OFF"; ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200); ToggleBtn.TextSize = 10
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 5)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame; StatusLabel.BackgroundTransparency = 1; StatusLabel.Position = UDim2.new(0, 0, 0, 80); StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Font = Enum.Font.Gotham; StatusLabel.Text = "Status: Idle"; StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 175); StatusLabel.TextSize = 9

-- ==========================================
-- ENGINE LOGIC
-- ==========================================
local isAutoBumpOn = false

ToggleBtn.MouseButton1Click:Connect(function()
    isAutoBumpOn = not isAutoBumpOn
    if isAutoBumpOn then
        ToggleBtn.Text = "AUTO FIGHT : ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        StatusLabel.Text = "Status: Mencari Target..."
    else
        ToggleBtn.Text = "AUTO FIGHT : OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 42, 58)
        ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        StatusLabel.Text = "Status: Idle"
    end
end)

local function getNearestMonster()
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local closestMonster = nil
    local shortestDistance = 500

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char and not game.Players:GetPlayerFromCharacter(obj) then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            local hum = obj:FindFirstChildOfClass("Humanoid")
            
            if root and hum and hum.Health > 0 then
                local dist = (root.Position - hrp.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestMonster = root
                end
            end
        end
    end
    return closestMonster
end

-- ==========================================
-- BACKGROUND WORKER (TELEPORT + WALK)
-- ==========================================
task.spawn(function()
    while true do
        task.wait(0.5) 
        if isAutoBumpOn then
            pcall(function()
                local char = plr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                
                if hrp and humanoid and not hrp.Anchored then
                    local target = getNearestMonster()
                    
                    if target then
                        StatusLabel.Text = "Status: Menabrak " .. target.Parent.Name .. "!"
                        
                        -- METODE BARU: 
                        -- 1. Teleport ke jarak 4 studs (sedikit di atas dan di belakang/depan monster)
                        hrp.CFrame = target.CFrame * CFrame.new(0, 3, 4)
                        task.wait(0.1)
                        
                        -- 2. Paksa karakter berjalan lurus menabrak monster agar sistem benturan game bereaksi!
                        humanoid:MoveTo(target.Position)
                        
                        -- Jeda 3.5 detik untuk memastikan transisi masuk ke layar battle
                        task.wait(3.5)
                    else
                        StatusLabel.Text = "Status: Menunggu Monster Spawn..."
                    end
                elseif hrp and hrp.Anchored then
                    StatusLabel.Text = "Status: Dalam Pertarungan..."
                end
            end)
        end
    end
end)
