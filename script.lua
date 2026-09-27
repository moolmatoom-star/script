-- ==========================================
-- สร้างปุ่มลอย Toggle UI (จำลองการกดปุ่ม K)
-- ==========================================
local coreGui = game:GetService("CoreGui")
local virtualInputManager = game:GetService("VirtualInputManager")
local tweenService = game:GetService("TweenService")

-- 1. สร้าง ScreenGui สำหรับปุ่มลอย
local mobileGui = Instance.new("ScreenGui")
mobileGui.Name = "MobileToggleButtonGui"
mobileGui.Parent = (gethui and gethui()) or coreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
mobileGui.ResetOnSpawn = false

-- 2. สร้างปุ่มรูปภาพ (ImageButton)
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = mobileGui
toggleButton.Size = UDim2.new(0, 50, 0, 50) -- ขนาดปุ่ม (กว้าง x สูง)
toggleButton.Position = UDim2.new(0.1, 0, 0.2, 0) -- ตำแหน่งเริ่มต้นบนหน้าจอ
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleButton.BackgroundTransparency = 0.2

-- ใส่ ID รูปภาพของคุณ
toggleButton.Image = "rbxassetid://99070098832551"

toggleButton.Active = true
toggleButton.Draggable = true -- สามารถลากย้ายตำแหน่งปุ่มได้

-- ทำขอบมนให้ปุ่ม
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = toggleButton

-- ทำเส้นขอบปุ่ม
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(255, 255, 255)
uiStroke.Transparency = 0.8
uiStroke.Thickness = 1.5
uiStroke.Parent = toggleButton

-- ==========================================
-- ฟังก์ชันเมื่อกดปุ่มลอย -> จำลองการกดปุ่ม K
-- ==========================================
toggleButton.MouseButton1Click:Connect(function()
    -- เอฟเฟกต์ย่อ/ขยายปุ่มเวลากด
    tweenService:Create(toggleButton, TweenInfo.new(0.08), {Size = UDim2.new(0, 42, 0, 42)}):Play()
    task.wait(0.08)
    tweenService:Create(toggleButton, TweenInfo.new(0.08), {Size = UDim2.new(0, 50, 0, 50)}):Play()

    -- สั่งจำลองการกดปุ่ม 'K' ผ่าน VirtualInputManager
    pcall(function()
        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.K, false, game)
        task.wait(0.05)
        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.K, false, game)
    end)
end)
local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()  
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
local Window = Starlight:CreateWindow({
    Name = "Marc X New x Hub",
    Subtitle = "v1.0",
    Icon = 99070098832551,

    LoadingSettings = {
        Title = "My Script Hub",
        Subtitle = "Welcome to Marc X New + Hub",
    },

    FileSettings = {
        ConfigFolder = "Marc X New + Hub"
    },
})
local TabSection = Window:CreateTabSection("Main")
local Tab = TabSection:CreateTab({
    Name = "Main suppot",
    Icon = NebulaIcons:GetIcon('view_in_ar', 'Material'),
    Columns = 2,
}, "INDEX") 
local Groupbox = Tab:CreateGroupbox({
    Name = "esp",
    Column = 1,
}, "INDEX")
-- ==========================================
-- เตรียมระบบ ESP (วางไว้นอก Toggle)
-- ==========================================
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
local workspace = game:GetService("Workspace")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local espEnabled = false
local espConnections = {}
local espObjects = {}

-- โฟลเดอร์เก็บ UI ป้ายชื่อ
local guiContainer = Instance.new("Folder")
guiContainer.Name = "MM2_ESP_Folder"
guiContainer.Parent = gethui and gethui() or coreGui

-- ฟังก์ชันเช็กบทบาทผู้เล่น
local function getPlayerRole(p)
    local char = p.Character
    local backpack = p:FindFirstChild("Backpack")
    
    local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
    local hasGun = (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) or (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver")))
    
    if hasKnife then 
        return "MURDERER", Color3.fromRGB(255, 0, 0)   -- 🔴 ฆาตกร (แดง)
    elseif hasGun then 
        return "SHERIFF", Color3.fromRGB(0, 170, 255)   -- 🔵 นายอำเภอ (ฟ้า)
    else 
        return "INNOCENT", Color3.fromRGB(0, 255, 0)   -- 🟢 ประชาชน (เขียว)
    end
end

-- ฟังก์ชันลบ ESP ของผู้เล่น 1 คน
local function removePlayerESP(p)
    if espConnections[p] then
        espConnections[p]:Disconnect()
        espConnections[p] = nil
    end
    if espObjects[p] then
        pcall(function()
            if espObjects[p].Highlight then espObjects[p].Highlight:Destroy() end
            if espObjects[p].Billboard then espObjects[p].Billboard:Destroy() end
            if espObjects[p].Tracer then 
                espObjects[p].Tracer.Visible = false
                espObjects[p].Tracer:Remove() 
            end
        end)
        espObjects[p] = nil
    end
end

-- ฟังก์ชันสร้าง ESP ให้ผู้เล่น 1 คน
local function applyPlayerESP(p)
    if p == localPlayer then return end
    removePlayerESP(p)

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1.5
    tracer.Transparency = 1

    local function setupChar(char)
        if not char or not espEnabled then return end

        local highlight = Instance.new("Highlight")
        highlight.Name = "MM2_Highlight"
        highlight.Adornee = char
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = char

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_" .. p.Name
        billboard.Size = UDim2.new(0, 150, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 2.8, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = guiContainer

        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextStrokeTransparency = 0
        label.TextSize = 13
        label.Font = Enum.Font.SourceSansBold

        espObjects[p] = {
            Highlight = highlight,
            Billboard = billboard,
            Tracer = tracer
        }

        espConnections[p] = runService.RenderStepped:Connect(function()
            local head = char:FindFirstChild("Head")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")

            if not espEnabled or not char or not char.Parent or not head or not hrp or not hum or hum.Health <= 0 then
                removePlayerESP(p)
                return
            end

            local role, color = getPlayerRole(p)

            highlight.FillColor = color
            highlight.OutlineColor = color
            billboard.Adornee = head
            label.Text = p.Name .. "\n[" .. role .. "]"
            label.TextColor3 = color

            -- เส้น Tracer ลากจากศูนย์กลางจอภาพ
            local targetPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                tracer.To = Vector2.new(targetPos.X, targetPos.Y)
                tracer.Color = color
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        end)
    end

    if p.Character then setupChar(p.Character) end
    p.CharacterAdded:Connect(setupChar)
end

local Toggle = Groupbox:CreateToggle({
    Name = "ESP ON OFF",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        espEnabled = Value

        if espEnabled then
            -- เมื่อกดเปิด: สร้าง ESP ให้ทุกคน
            for _, p in ipairs(players:GetPlayers()) do
                applyPlayerESP(p)
            end
        else
            -- เมื่อกดปิด: ลบ ESP ของทุกคนออก
            for p, _ in pairs(espObjects) do
                removePlayerESP(p)
            end
        end
    end
}, "INDEX")

-- อัปเดต ESP เมื่อมีคนเข้า/ออกจากเซิร์ฟเวอร์
players.PlayerAdded:Connect(function(p)
    if espEnabled then
        applyPlayerESP(p)
    end
end)

players.PlayerRemoving:Connect(function(p)
    removePlayerESP(p)
end)

-- ==========================================
-- ระบบ Lock Target (วางไว้นอก Toggle)
-- ==========================================
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local lockEnabled = false
local lockConnection = nil

-- ฟังก์ชันค้นหาหัวของ Murderer
local function getMurdererHead()
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            local char = p.Character
            local backpack = p:FindFirstChild("Backpack")
            
            -- ตรวจหา Knife ในตัวหรือในกระเป๋า
            local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
            
            if hasKnife then
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    return head
                end
            end
        end
    end
    return nil
end
local Groupbox = Tab:CreateGroupbox({
    Name = "AIMBOT",
    Column = 1,
}, "INDEX")

local LockToggle = Groupbox:CreateToggle({
    Name = "Lock Murderer Head",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        lockEnabled = Value

        if lockEnabled then
            -- เริ่มลูปล็อคหัวทุกๆ เฟรม
            lockConnection = runService.RenderStepped:Connect(function()
                if not lockEnabled then return end
                
                local targetHead = getMurdererHead()
                if targetHead then
                    -- ล็อคเป้าองศากล้องไปที่หัวของ Murderer
                    camera.CFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
                end
            end)
        else
            -- ยกเลิกลูปการล็อคเมื่อปิด Toggle
            if lockConnection then
                lockConnection:Disconnect()
                lockConnection = nil
            end
        end
    end
}, "LOCK_TOGGLE_INDEX")
-- ==========================================
-- เตรียมระบบ Lock Target All (วางไว้นอก Toggle)
-- ==========================================
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local lockAllEnabled = false
local lockAllConnection = nil

-- ฟังก์ชันค้นหาหัวของผู้เล่นที่อยู่ใกล้เป้ากลางจอที่สุด
local function getClosestPlayerHead()
    local closestHead = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in ipairs(players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")

            if head and hum and hum.Health > 0 then
                -- แปลงตำแหน่ง 3D ของหัว เป็นตำแหน่ง 2D บนหน้าจอ
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    -- คำนวณระยะห่างระหว่างหัวเป้าหมายกับจุดศูนย์กลางหน้าจอ
                    local distance = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestHead = head
                    end
                end
            end
        end
    end

    return closestHead
end

-- ==========================================
-- โค้ด Toggle สำหรับใส่ใน UI
-- ==========================================
local LockAllToggle = Groupbox:CreateToggle({
    Name = "Lock All Players",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        lockAllEnabled = Value

        if lockAllEnabled then
            -- เริ่มล็อคเป้าหมายที่ใกล้ที่สุดทุกเฟรม
            lockAllConnection = runService.RenderStepped:Connect(function()
                if not lockAllEnabled then return end

                local targetHead = getClosestPlayerHead()
                if targetHead then
                    -- หมุนกล้องล็อคตรงไปที่หัวเป้าหมาย
                    camera.CFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
                end
            end)
        else
            -- ปิดการทำงานเมื่อ Toggle = false
            if lockAllConnection then
                lockAllConnection:Disconnect()
                lockAllConnection = nil
            end
        end
    end
}, "LOCK_ALL_INDEX")
local Groupbox = Tab:CreateGroupbox({
    Name = "GODmode bate",
    Column = 1,
}, "INDEX")
-- ==========================================
-- เตรียมระบบ God Mode (วางไว้นอก Toggle)
-- ==========================================
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer

local godModeEnabled = false
local godConnection = nil

local function enableGodMode(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        -- ป้องกันการลงไปนอน/ล้ม หรือโดนจังหวะอนิเมชันสังหาร
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
end

-- ==========================================
-- โค้ด Toggle สำหรับใส่ใน UI
-- ==========================================
local GodModeToggle = Groupbox:CreateToggle({
    Name = "God Mode (อมตะ)",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        godModeEnabled = Value

        if godModeEnabled then
            -- ตั้งค่าตัวละครปัจจุบัน
            if localPlayer.Character then
                enableGodMode(localPlayer.Character)
            end

            -- ลูปดึงเลือดกลับเต็ม 100 ตลอดเวลาทุกเฟรม
            godConnection = runService.RenderStepped:Connect(function()
                if not godModeEnabled then return end
                
                local char = localPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if hum then
                    if hum.Health < hum.MaxHealth and hum.Health > 0 then
                        hum.Health = hum.MaxHealth
                    end
                end
            end)
        else
            -- ปิดการทำงาน และคืนค่าปกติ
            if godConnection then
                godConnection:Disconnect()
                godConnection = nil
            end
            
            local char = localPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            end
        end
    end
}, "GODMODE_INDEX")

-- ทำงานอัตโนมัติเมื่อตัวละครเกิดใหม่ (Respawn)
localPlayer.CharacterAdded:Connect(function(char)
    if godModeEnabled then
        task.wait(0.5)
        enableGodMode(char)
    end
end)
local Groupbox = Tab:CreateGroupbox({
    Name = "walk and jump",
    Column = 1,
}, "INDEX")
-- ==========================================
-- เตรียมระบบ Speed & Jump (วางไว้นอก Groupbox)
-- ==========================================
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

local walkSpeedValue = 16 -- ค่าเริ่มต้นปกติคือ 16
local jumpPowerValue = 50 -- ค่าเริ่มต้นปกติคือ 50

-- ลูปรักษาค่าความเร็วและความสูงการกระโดดไว้ตลอดเวลา
runService.RenderStepped:Connect(function()
    local char = localPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            -- ปรับความเร็วเดิน
            hum.WalkSpeed = walkSpeedValue
            
            -- ปรับความสูงการกระโดด
            hum.UseJumpPower = true
            hum.JumpPower = jumpPowerValue
        end
    end
end)

-- ==========================================
-- โค้ด Slider 2 อันสำหรับใส่ใน UI
-- ==========================================

-- 1. Slider ปรับความเร็วเดิน (WalkSpeed)
local SpeedSlider = Groupbox:CreateSlider({
    Name = "Walk Speed (ความเร็วเดิน)",
    Icon = NebulaIcons:GetIcon('chart-no-axes-column-increasing', 'Lucide'),
    Range = {16, 200}, -- ปรับช่วงความเร็วได้ตามต้องการ (ปกติ 16 - สูงสุด 200)
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        walkSpeedValue = Value
    end,
}, "SPEED_SLIDER_INDEX")

-- 2. Slider ปรับความสูงการกระโดด (Jump Power)
local JumpSlider = Groupbox:CreateSlider({
    Name = "Jump Power (ความสูงกระโดด)",
    Icon = NebulaIcons:GetIcon('chart-no-axes-column-increasing', 'Lucide'),
    Range = {50, 300}, -- ปรับช่วงความสูงได้ตามต้องการ (ปกติ 50 - สูงสุด 300)
    Increment = 1,
    CurrentValue = 50,
    Callback = function(Value)
        jumpPowerValue = Value
    end,
}, "JUMP_SLIDER_INDEX")
local Groupbox = Tab:CreateGroupbox({
    Name = "Auto Teleport To Gun",
    Column = 2,
}, "INDEX")
-- ==========================================
-- เตรียมระบบ Teleport Gun (วางไว้นอก Toggle)
-- ==========================================
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local localPlayer = players.LocalPlayer

local tpGunEnabled = false
local tpGunConnection = nil
local isTeleporting = false

-- ฟังก์ชันค้นหาปืนที่ตกอยู่บนพื้น
local function getDroppedGun()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj.Name == "GunDrop" or obj.Name == "Gun") and obj:IsA("BasePart") then
            return obj
        end
    end
    return nil
end

-- ==========================================
-- โค้ด Toggle สำหรับใส่ใน UI
-- ==========================================
local TpGunToggle = Groupbox:CreateToggle({
    Name = "Auto Teleport To Gun",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        tpGunEnabled = Value

        if tpGunEnabled then
            -- เริ่มลูปตรวจหาปืนตกทุกเฟรม
            tpGunConnection = runService.RenderStepped:Connect(function()
                if not tpGunEnabled or isTeleporting then return end

                local char = localPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    local droppedGun = getDroppedGun()

                    if droppedGun then
                        isTeleporting = true
                        
                        -- บันทึกตำแหน่งเดิมก่อนวาร์ป
                        local oldCFrame = hrp.CFrame

                        -- วาร์ปไปที่ปืน
                        hrp.CFrame = droppedGun.CFrame
                        
                        -- รอเก็บปืน 0.3 วินาที แล้ววาร์ปกลับตำแหน่งเดิม
                        task.delay(0.3, function()
                            if hrp and hrp.Parent then
                                hrp.CFrame = oldCFrame
                            end
                            isTeleporting = false
                        end)
                    end
                end
            end)
        else
            -- ยกเลิกลูปเมื่อกดปิด Toggle
            if tpGunConnection then
                tpGunConnection:Disconnect()
                tpGunConnection = nil
            end
            isTeleporting = false
        end
    end
}, "TP_GUN_INDEX")
-- ==========================================
-- เตรียมระบบ Teleport to Murderer (วางไว้นอก Toggle)
-- ==========================================
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local localPlayer = players.LocalPlayer

local tpMurdererEnabled = false
local tpMurdererConnection = nil

-- ฟังก์ชันค้นหาผู้เล่นที่เป็น Murderer
local function getMurdererHRP()
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            local char = p.Character
            local backpack = p:FindFirstChild("Backpack")
            
            -- ตรวจหา Knife ในตัวหรือในกระเป๋า
            local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
            
            if hasKnife then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    return hrp
                end
            end
        end
    end
    return nil
end

-- ==========================================
-- โค้ด Toggle สำหรับใส่ใน UI
-- ==========================================
local TpMurdererToggle = Groupbox:CreateToggle({
    Name = "Teleport To Murderer",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        tpMurdererEnabled = Value

        if tpMurdererEnabled then
            -- เริ่มลูปรักษาระยะวาร์ปติดหลัง Murderer ทุกเฟรม
            tpMurdererConnection = runService.RenderStepped:Connect(function()
                if not tpMurdererEnabled then return end

                local myChar = localPlayer.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

                if myHRP and myHum and myHum.Health > 0 then
                    local murdererHRP = getMurdererHRP()
                    if murdererHRP then
                        -- วาร์ปไปตำแหน่งด้านหลังของ Murderer (ระยะห่าง 3.5 Studs)
                        myHRP.CFrame = murdererHRP.CFrame * CFrame.new(0, 0, 3.5)
                    end
                end
            end)
        else
            -- ยกเลิกการวาร์ปเมื่อกดปิด Toggle
            if tpMurdererConnection then
                tpMurdererConnection:Disconnect()
                tpMurdererConnection = nil
            end
        end
    end
}, "TP_MURDERER_INDEX")
local Groupbox = Tab:CreateGroupbox({
    Name = "FE Invisible",
    Column = 2,
}, "INDEX")
-- ==========================================
-- เตรียมระบบ Invisible FE (วางไว้นอก Toggle)
-- ==========================================
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

local invisEnabled = false
local savedCFrame = nil
local invisClone = nil

-- ฟังก์ชันจัดการซ่อนตัวละคร
local function setInvisState(state)
    local char = localPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if state then
        -- บันทึกตำแหน่งก่อนซ่อน
        savedCFrame = hrp.CFrame
        
        -- แยก RootJoint เพื่อตัดการซิงค์ตำแหน่งกับเซิร์ฟเวอร์ (FE Invisible Bypass)
        local lowerTorso = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
        local rootJoint = hrp:FindFirstChild("RootJoint") or (lowerTorso and lowerTorso:FindFirstChild("RootJoint"))
        
        if rootJoint then
            rootJoint.Parent = nil -- แยกข้อต่อออก
        end
        
        -- ย้าย HumanoidRootPart ไปไว้ใต้แมพชั่วคราวเพื่อซ่อนตัวจากเซิร์ฟเวอร์
        hrp.CFrame = savedCFrame * CFrame.new(0, -500, 0)
    else
        -- ดึงตัวละครกลับมาตำแหน่งเดิมเมื่อปิดใช้งาน
        local lowerTorso = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
        if hrp and savedCFrame then
            hrp.CFrame = savedCFrame
        end
        
        -- รีเซ็ตตัวละครกลับสภาพเดิม
        if char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

-- ==========================================
-- โค้ด Toggle สำหรับใส่ใน UI
-- ==========================================
local InvisToggle = Groupbox:CreateToggle({
    Name = "FE Invisible (หายตัว)",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        invisEnabled = Value
        setInvisState(invisEnabled)
    end
}, "FE_INVIS_INDEX")

-- รีเซ็ตระบบเมื่อตัวละครเกิดใหม่ (Respawn)
localPlayer.CharacterAdded:Connect(function()
    invisEnabled = false
end)
local Groupbox = Tab:CreateGroupbox({
    Name = "Boots fps",
    Column = 2,
}, "INDEX")
local Button = Groupbox:CreateButton({
    Name = "Boots fps",
    Icon = NebulaIcons:GetIcon('check', 'Material'),
    Callback = function()
-- FPS Booster + Unlocked FPS Counter
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- UNLOCK FPS
setfpscap(0)
pcall(function()
    settings().Rendering.FrameRateManager = Enum.FrameRateManagerMode.Disabled
end)

-- FPS COUNTER UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSCounter"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 120, 0, 30)
frame.Position = UDim2.new(0.5, -60, 0, 8)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.4
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "FPS: --"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 15
label.Font = Enum.Font.GothamBold
label.Parent = frame

local fpsBuffer = {}
local bufferSize = 30

RunService.RenderStepped:Connect(function(dt)
    table.insert(fpsBuffer, 1 / dt)
    if #fpsBuffer > bufferSize then
        table.remove(fpsBuffer, 1)
    end

    local sum = 0
    for _, v in ipairs(fpsBuffer) do sum = sum + v end
    local fps = math.floor(sum / #fpsBuffer)

    if fps >= 120 then
        label.TextColor3 = Color3.fromRGB(80, 255, 120)
    elseif fps >= 60 then
        label.TextColor3 = Color3.fromRGB(130, 220, 255)
    elseif fps >= 30 then
        label.TextColor3 = Color3.fromRGB(255, 210, 50)
    else
        label.TextColor3 = Color3.fromRGB(255, 80, 80)
    end

    label.Text = "FPS: " .. fps
end)

-- FPS BOOSTER
Lighting.GlobalShadows = false
Lighting.FogEnd = 100000
Lighting.FogStart = 100000
Lighting.Brightness = 2
Lighting.Ambient = Color3.fromRGB(178, 178, 178)
Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)

for _, effect in ipairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") or effect:IsA("Sky") then
        effect:Destroy()
    end
end

settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

local function removeEffects(parent)
    for _, obj in ipairs(parent:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam")
            or obj:IsA("Trail") or obj:IsA("Sparkles")
            or obj:IsA("Fire") or obj:IsA("Smoke")
            or obj:IsA("SelectionBox")
        then
            obj.Enabled = false
        end
    end
end

removeEffects(workspace)

local function cleanCharacter(char)
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
            or obj:IsA("Sparkles") or obj:IsA("Fire") or obj:IsA("Smoke")
        then
            obj.Enabled = false
        end
        if obj:IsA("BasePart") then
            obj.CastShadow = false
        end
    end
end

if LocalPlayer.Character then
    cleanCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    cleanCharacter(char)
end)

workspace.Terrain.WaterWaveSize = 0
workspace.Terrain.WaterWaveSpeed = 0
workspace.Terrain.WaterReflectance = 0
workspace.Terrain.WaterTransparency = 0
    end,
}, "INDEX")
local Groupbox = Tab:CreateGroupbox({
    Name = "spin player",
    Column = 2,
}, "INDEX")
-- ==========================================
-- เตรียมระบบ Spin Bot (วางไว้นอก Toggle/Slider)
-- ==========================================
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

local spinEnabled = false
local spinSpeed = 20 -- ค่าเริ่มต้นความเร็วการหมุน
local spinConnection = nil

-- ==========================================
-- 1. โค้ด Toggle เปิด/ปิด การหมุนตัว
-- ==========================================
local SpinToggle = Groupbox:CreateToggle({
    Name = "Spin Bot (หมุนตัว)",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        spinEnabled = Value

        if spinEnabled then
            -- เริ่มลูปหมุนตัวละครทุกเฟรม
            spinConnection = runService.RenderStepped:Connect(function()
                if not spinEnabled then return end
                
                local char = localPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    -- คำนวณการหมุนแนวแกน Y (หมุนรอบตัวเอง)
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
                end
            end)
        else
            -- ปิดการทำงานเมื่อกด Toggle = false
            if spinConnection then
                spinConnection:Disconnect()
                spinConnection = nil
            end
        end
    end
}, "SPIN_BOT_INDEX")

-- ==========================================
-- 2. โค้ด Slider ปรับความเร็วการหมุน
-- ==========================================
local SpinSpeedSlider = Groupbox:CreateSlider({
    Name = "Spin Speed (ความเร็วการหมุน)",
    Icon = NebulaIcons:GetIcon('rotate-cw', 'Lucide'),
    Range = {1, 100}, -- ปรับได้ตั้งแต่ 1 ถึง 100
    Increment = 1,
    CurrentValue = 20,
    Callback = function(Value)
        spinSpeed = Value
    end,
}, "SPIN_SPEED_INDEX")
local Groupbox = Tab:CreateGroupbox({
    Name = "Bring All Players FE",
    Column = 1,
}, "INDEX")
-- ==========================================
-- เตรียมระบบ Bring All FE (วางไว้นอก Toggle)
-- ==========================================
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer

local bringAllEnabled = false
local bringConnection = nil

local function getOtherPlayers()
    local targetList = {}
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            local char = p.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                table.insert(targetList, hrp)
            end
        end
    end
    return targetList
end

-- ==========================================
-- ใส่ใน Toggle ของคุณ
-- ==========================================
local BringAllToggle = Groupbox:CreateToggle({
    Name = "Bring All Players FE",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        bringAllEnabled = Value

        if bringAllEnabled then
            bringConnection = runService.RenderStepped:Connect(function()
                if not bringAllEnabled then return end

                local myChar = localPlayer.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

                if myHRP and myHum and myHum.Health > 0 then
                    local frontPos = myHRP.CFrame * CFrame.new(0, 0, -3)
                    for _, targetHRP in ipairs(getOtherPlayers()) do
                        pcall(function()
                            targetHRP.CFrame = frontPos
                        end)
                    end
                end
            end)
        else
            if bringConnection then
                bringConnection:Disconnect()
                bringConnection = nil
            end
        end
    end
}, "BRING_ALL_TOGGLE_INDEX")
local Groupbox = Tab:CreateGroupbox({
    Name = "Xray",
    Column = 2,
}, "INDEX")
-- ==========================================
-- เตรียมระบบ X-Ray MM2 (วางไว้นอก Toggle)
-- ==========================================
local workspace = game:GetService("Workspace")
local players = game:GetService("Players")

local xrayEnabled = false
local originalData = {} -- บันทึกค่าเดิมของวัตถุไว้คืนค่า

-- ฟังก์ชันเช็คว่าวัตถุเป็นชิ้นส่วนของตัวละครหรือไม่
local function isPlayerPart(obj)
    for _, p in ipairs(players:GetPlayers()) do
        if p.Character and obj:IsDescendantOf(p.Character) then
            return true
        end
    end
    return false
end

-- ฟังก์ชันเปิด/ปิด X-Ray
local function toggleXray(state)
    local mapFolder = workspace:FindFirstChild("Normal") or workspace:FindFirstChild("Map") or workspace
    
    for _, obj in ipairs(mapFolder:GetDescendants()) do
        if obj:IsA("BasePart") and not isPlayerPart(obj) and obj.Name ~= "HumanoidRootPart" then
            if state then
                -- บันทึกค่าดั้งเดิมก่อนเปลี่ยน
                if not originalData[obj] then
                    originalData[obj] = {
                        Transparency = obj.Transparency,
                        Material = obj.Material
                    }
                end
                
                -- ปรับความทะลุและเปลี่ยนชนิดพื้นผิวเป็น ForceField/Glass เพื่อให้มองทะลุ 100%
                if obj.Transparency < 0.7 then
                    obj.Transparency = 0.75 -- ปรับความโปร่งแสง (ยิ่งใกล้ 1 ยิ่งใสมาก)
                    obj.Material = Enum.Material.ForceField -- เปลี่ยน Material ให้ทะลุกำแพงเนียนๆ
                end
            else
                -- คืนค่าเดิมเมื่อปิด Toggle
                if originalData[obj] then
                    obj.Transparency = originalData[obj].Transparency
                    obj.Material = originalData[obj].Material
                end
            end
        end
    end
    
    if not state then
        table.clear(originalData)
    end
end

-- ==========================================
-- โค้ด Toggle สำหรับใส่ใน UI
-- ==========================================
local XrayToggle = Groupbox:CreateToggle({
    Name = "X-Ray Map (ทะลุกำแพง 100%)",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        xrayEnabled = Value
        toggleXray(xrayEnabled)
    end
}, "XRAY_TOGGLE_INDEX")
-- ==========================================
-- 1. โค้ด Toggle เปิด/ปิด Hitbox
-- ==========================================
local HitboxToggle = Groupbox:CreateToggle({
    Name = "Expand Hitbox (ขยายฮิตบ็อกซ์)",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        hitboxEnabled = Value

        if hitboxEnabled then
            -- ลูปอัปเดต Hitbox ตลอดเวลาเพื่อรองรับคนเกิดใหม่
            hitboxConnection = runService.RenderStepped:Connect(function()
                if not hitboxEnabled then return end
                updateHitboxes()
            end)
        else
            -- ยกเลิกการทำงานและคืนค่า Hitbox ดั้งเดิม
            if hitboxConnection then
                hitboxConnection:Disconnect()
                hitboxConnection = nil
            end
            updateHitboxes()
        end
    end
}, "HITBOX_TOGGLE_INDEX")

-- ==========================================
-- 2. โค้ด Slider ปรับขนาด Hitbox
-- ==========================================
local HitboxSlider = Groupbox:CreateSlider({
    Name = "Hitbox Size (ขนาดฮิตบ็อกซ์)",
    Icon = NebulaIcons:GetIcon('maximize-2', 'Lucide'),
    Range = {2, 50}, -- ปรับได้ตั้งแต่ 2 (ปกติ) ถึง 50 (กล่องใหญ่มาก)
    Increment = 1,
    CurrentValue = 10,
    Callback = function(Value)
        hitboxSize = Value
    end,
}, "HITBOX_SLIDER_INDEX")
local Groupbox = Tab:CreateGroupbox({
    Name = "Noclip",
    Column = 1,
}, "INDEX")
-- ==========================================
-- เตรียมระบบ Noclip (วางไว้นอก Toggle)
-- ==========================================
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

local noclipEnabled = false
local noclipConnection = nil

-- ฟังก์ชันปิดชนกำแพงของตัวละคร
local function disableCollision()
    local char = localPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end

-- ==========================================
-- โค้ด Toggle สำหรับใส่ใน UI
-- ==========================================
local NoclipToggle = Groupbox:CreateToggle({
    Name = "Noclip (เดินทะลุกำแพง)",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        noclipEnabled = Value

        if noclipEnabled then
            -- ใช้ Stepped เพื่อปิด CanCollide ทุกเฟรมก่อนฟิสิกส์ประมวลผล
            noclipConnection = runService.Stepped:Connect(function()
                if not noclipEnabled then return end
                disableCollision()
            end)
        else
            -- ยกเลิกลูปเมื่อปิด Toggle
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            -- คืนค่าให้กลับมาชนกำแพงตามปกติ
            local char = localPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CanCollide = true
                end
            end
        end
    end
}, "NOCLIP_TOGGLE_INDEX")
local TabSection = Window:CreateTabSection("Fram")
local Tab = TabSection:CreateTab({
    Name = "Fram",
    Icon = NebulaIcons:GetIcon('view_in_ar', 'Material'),
    Columns = 2,
}, "INDEX")
local Groupbox = Tab:CreateGroupbox({
    Name = "Fram",
    Column = 1,
}, "INDEX")
-- ==========================================
-- ระบบวาร์ปเก็บเหรียญ MM2 (วางไว้นอก Toggle)
-- ==========================================
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local task = task or getfenv().task
local localPlayer = players.LocalPlayer

local coinFarmEnabled = false
local coinFarmThread = nil

-- ฟังก์ชันดึงตำแหน่งเหรียญในแมพ MM2
local function getMM2Coins()
    local coins = {}
    
    -- ค้นหาโฟลเดอร์ CoinContainer ใน Workspace หรือดึงจากโมเดลแมพ
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "CoinContainer" or obj.Name == "Coin_Container" then
            for _, coin in ipairs(obj:GetChildren()) do
                if coin:IsA("BasePart") or coin:IsA("Model") then
                    local part = coin:IsA("BasePart") and coin or coin:FindFirstChildWhichIsA("BasePart")
                    if part and part.Transparency < 1 then
                        table.insert(coins, part)
                    end
                end
            end
        elseif (obj.Name == "Coin" or obj.Name == "MainCoin") and obj:IsA("BasePart") then
            if obj.Transparency < 1 then
                table.insert(coins, obj)
            end
        end
    end
    
    return coins
end

-- ==========================================
-- โค้ด Toggle สำหรับใส่ใน UI
-- ==========================================
local CoinFarmToggle = Groupbox:CreateToggle({
    Name = "Auto Farm Coin (Teleport)",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        coinFarmEnabled = Value

        if coinFarmEnabled then
            coinFarmThread = task.spawn(function()
                while coinFarmEnabled do
                    local char = localPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")

                    if hrp and hum and hum.Health > 0 then
                        local coinList = getMM2Coins()
                        
                        if #coinList > 0 then
                            for _, coinPart in ipairs(coinList) do
                                if not coinFarmEnabled then break end
                                
                                if coinPart and coinPart.Parent and coinPart.Transparency < 1 then
                                    -- วาร์ปตรงไปที่ตำแหน่งเหรียญ
                                    hrp.CFrame = coinPart.CFrame
                                    task.wait(0.15) -- ปรับความเร็วในการสลับวาร์ปเก็บเหรียญได้ที่นี่
                                end
                            end
                        else
                            -- ถ้ายังไม่มีเหรียญเกิดในแมพ ให้รอ 0.5 วินาที
                            task.wait(0.5)
                        end
                    else
                        task.wait(0.5)
                    end
                end
            end)
        else
            -- ปิดลูปเมื่อกด Toggle ปิด
            if coinFarmThread then
                task.cancel(coinFarmThread)
                coinFarmThread = nil
            end
        end
    end
}, "TP_COIN_FARM_INDEX")
-- ==========================================
-- ระบบบินเก็บเหรียญ MM2 (วางไว้นอก Toggle)
-- ==========================================
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local tweenService = game:GetService("TweenService")
local task = task or getfenv().task
local localPlayer = players.LocalPlayer

local flyFarmEnabled = false
local flyFarmThread = nil
local flySpeed = 25 -- ความเร็วในการบิน (20 - 30 กำลังดี ไม่หลุด Anti-Cheat)

-- ฟังก์ชันดึงตำแหน่งเหรียญในแมพ MM2
local function getMM2Coins()
    local coins = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "CoinContainer" or obj.Name == "Coin_Container" then
            for _, coin in ipairs(obj:GetChildren()) do
                if coin:IsA("BasePart") or coin:IsA("Model") then
                    local part = coin:IsA("BasePart") and coin or coin:FindFirstChildWhichIsA("BasePart")
                    if part and part.Transparency < 1 then
                        table.insert(coins, part)
                    end
                end
            end
        elseif (obj.Name == "Coin" or obj.Name == "MainCoin") and obj:IsA("BasePart") then
            if obj.Transparency < 1 then
                table.insert(coins, obj)
            end
        end
    end
    return coins
end

-- ==========================================
-- โค้ด Toggle สำหรับใส่ใน UI
-- ==========================================
local FlyCoinFarmToggle = Groupbox:CreateToggle({
    Name = "Auto Farm Coin (Fly / Tween)",
    CurrentValue = false,
    Style = 1,
    Callback = function(Value)
        flyFarmEnabled = Value

        if flyFarmEnabled then
            flyFarmThread = task.spawn(function()
                while flyFarmEnabled do
                    local char = localPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")

                    if hrp and hum and hum.Health > 0 then
                        local coinList = getMM2Coins()
                        
                        if #coinList > 0 then
                            for _, coinPart in ipairs(coinList) do
                                if not flyFarmEnabled then break end
                                
                                if coinPart and coinPart.Parent and coinPart.Transparency < 1 then
                                    -- คำนวณเวลาร่อนบินตามระยะห่างจริง
                                    local distance = (hrp.Position - coinPart.Position).Magnitude
                                    local flyTime = distance / flySpeed

                                    local tweenInfo = TweenInfo.new(flyTime, Enum.EasingStyle.Linear)
                                    local tween = tweenService:Create(hrp, tweenInfo, {CFrame = coinPart.CFrame})
                                    
                                    tween:Play()
                                    
                                    -- รอจนกว่าจะบินลอยไปถึงเหรียญ
                                    local completed = false
                                    local conn
                                    conn = tween.Completed:Connect(function()
                                        completed = true
                                        conn:Disconnect()
                                    end)

                                    repeat task.wait() until completed or not flyFarmEnabled
                                    task.wait(0.05)
                                end
                            end
                        else
                            task.wait(0.5)
                        end
                    else
                        task.wait(0.5)
                    end
                end
            end)
        else
            -- ปิดลูปเมื่อกด Toggle ปิด
            if flyFarmThread then
                task.cancel(flyFarmThread)
                flyFarmThread = nil
            end
        end
    end
}, "FLY_COIN_FARM_INDEX")
