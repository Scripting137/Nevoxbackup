--Ink Games

-- Load Dependencies
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/Beta.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Window and Tabs
local Window = Fluent:CreateWindow({
    Title = "Nevox 1.27",
    SubTitle = "by Madness.idk",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Arctic",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "building-2" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "wand" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    Credits = Window:AddTab({ Title = "Credits", Icon = "award" })
}

local Options = Fluent.Options

--------------------------------------------------------
-- MAIN TAB
--------------------------------------------------------

Tabs.Main:AddSection("Doll And Nights Out", "swords")

Tabs.Main:AddButton({
    Title = "Teleport to Doll",
    Description = "Teleport to End of Red light Green Light",
    Callback = function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(
                -43.903019, 1023.78497, 109.140228,
                0.996178031, -2.33398328e-10, 0.0873463005,
                2.82470547e-10, 1, -5.4945215e-10,
                -0.0873463005, 5.72024872e-10, 0.996178031
            )
        else
            Fluent:Notify({
                Title = "Error",
                Content = "HumanoidRootPart not found.",
                Duration = 4
            })
        end
    end
})

Tabs.Main:AddButton({
    Title = "Lights Out Safe Space",
    Description = "Teleport to a safe space in Lights Out",
    Callback = function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(
                254.13707, 54.2937241, -240.751587,
                0.310818881, 2.00976213e-08, 0.950469136,
                -2.11078834e-08, 1, -1.42423273e-08,
                -0.950469136, -1.56356084e-08, 0.310818881
            )
        else
            Fluent:Notify({
                Title = "Error",
                Content = "HumanoidRootPart not found.",
                Duration = 4
            })
        end
    end
})

--------------------------------------------------------
-- Auto Teleport/Attack
--------------------------------------------------------

local TargetName = ""
local autoTPEnabled, autoAttackEnabled = false, false
local autoTPConnection, attackConnection

Tabs.Main:AddInput("AutoTPPlayerInput", {
    Title = "Target Player",
    Placeholder = "Enter player name",
    Default = "",
    Callback = function(val) TargetName = val end
})

local function findPlayer(name)
    local nameLower = name:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(nameLower) or player.DisplayName:lower():find(nameLower) then
            return player
        end
    end
    return nil
end

local function equipWeapon()
    local char = LocalPlayer.Character
    if not char then return end
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    local weaponNames = {"Fork", "Bottle"}
    for _, name in ipairs(weaponNames) do
        local tool = char:FindFirstChild(name)
        if tool and tool:IsA("Tool") then return end
    end
    for _, name in ipairs(weaponNames) do
        local tool = backpack:FindFirstChild(name)
        if tool and tool:IsA("Tool") then
            char.Humanoid:EquipTool(tool)
            return
        end
    end
end

Tabs.Main:AddToggle("AutoTPBehindToggle", {
    Title = "Auto Teleport Behind Player",
    Description = "Keeps teleporting behind the chosen player and equips weapon",
    Default = false
}):OnChanged(function(state)
    autoTPEnabled = state
    if autoTPEnabled then
        if autoTPConnection then autoTPConnection:Disconnect() end
        autoTPConnection = RunService.Heartbeat:Connect(function()
            local target = findPlayer(TargetName)
            local char = LocalPlayer.Character
            if target and target.Character and char then
                local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if targetHRP and hrp then
                    equipWeapon()
                    local behindCFrame = targetHRP.CFrame * CFrame.new(0, 0, -3)
                    local lookAt = CFrame.new(behindCFrame.Position, targetHRP.Position)
                    hrp.CFrame = lookAt
                end
            end
        end)
    else
        if autoTPConnection then autoTPConnection:Disconnect() end
        autoTPConnection = nil
    end
end)

Tabs.Main:AddToggle("AutoAttackToggle", {
    Title = "Auto Attack",
    Description = "Spam-activates your equipped weapon",
    Default = false
}):OnChanged(function(state)
    autoAttackEnabled = state
    if autoAttackEnabled then
        if attackConnection then attackConnection:Disconnect() end
        attackConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            local tool = humanoid:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end)
    else
        if attackConnection then attackConnection:Disconnect() end
        attackConnection = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
    if autoTPEnabled then
        if autoTPConnection then autoTPConnection:Disconnect() end
        autoTPConnection = RunService.Heartbeat:Connect(function()
            local target = findPlayer(TargetName)
            if target and target.Character and character and character.Parent then
                local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if targetHRP and hrp then
                    equipWeapon()
                    local behindCFrame = targetHRP.CFrame * CFrame.new(0, 0, -3)
                    local lookAt = CFrame.new(behindCFrame.Position, targetHRP.Position)
                    hrp.CFrame = lookAt
                end
            end
        end)
    end
    if autoAttackEnabled then
        if attackConnection then attackConnection:Disconnect() end
        attackConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            local tool = humanoid:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end)
    end
end)

--------------------------------------------------------
-- Exit Door ESP: Models with Exit Signs
--------------------------------------------------------

Tabs.Main:AddSection("Hide And Seek And Glass Bridge")

-- Utility: Recursively find all models in a folder that have a child named "ExitSign" (case-insensitive)
local function findExitModels(rootFolder)
    local models = {}
    if not rootFolder then return models end
    for _, obj in ipairs(rootFolder:GetDescendants()) do
        if obj:IsA("Model") then
            for _, part in ipairs(obj:GetChildren()) do
                if part:IsA("BasePart") and part.Name:lower():find("exitsign") then
                    table.insert(models, obj)
                    break
                end
            end
        end
    end
    return models
end

local exitESPMarkers = {}

local function createExitESP(model)
    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    if exitESPMarkers[model] then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ExitESP"
    billboard.Size = UDim2.new(0, 120, 0, 36)
    billboard.AlwaysOnTop = true
    billboard.Adornee = part
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🚪 EXIT"
    label.TextColor3 = Color3.fromRGB(255, 50, 50)
    label.TextStrokeTransparency = 0.5
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    exitESPMarkers[model] = billboard
end

local function clearExitESP()
    for _, marker in pairs(exitESPMarkers) do
        marker:Destroy()
    end
    exitESPMarkers = {}
end

local function enableExitESP()
    clearExitESP()
    local map = Workspace:FindFirstChild("HideAndSeekMap")
    local doors = map and map:FindFirstChild("NEWFIXEDDOORS")
    if not doors then return end
    for i = 1, 3 do
        local floor = doors:FindFirstChild("Floor" .. i)
        if floor then
            local exitModels = findExitModels(floor)
            for _, model in ipairs(exitModels) do
                createExitESP(model)
            end
        end
    end
end

Tabs.Main:AddToggle("ExitESP", {
    Title = "Exit Door ESP",
    Description = "ESP every exit model with an ExitSign",
    Default = false
}):OnChanged(function(state)
    if state then
        enableExitESP()
    else
        clearExitESP()
    end
end)

Tabs.Main:AddButton({
    Title = "Finish Glass Bridge",
    Description = "Teleport to the end of the Glass Bridge",
    Callback = function()
        local endPart = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("End")
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if endPart and hrp then
            hrp.CFrame = endPart.CFrame + Vector3.new(0, 5, 0)
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Could not find GlassBridge End or your character.",
                Duration = 4
            })
        end
    end
})

--------------------------------------------------------
-- MISC TAB
--------------------------------------------------------

Tabs.Misc:AddSlider("WalkSpeed", {
    Title = "Walkspeed",
    Description = "Adjust your WalkSpeed",
    Default = 50,
    Min = 10,
    Max = 300,
    Rounding = 1,
    Callback = function(val)
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
})

Tabs.Misc:AddSlider("JumpPower", {
    Title = "JumpPower",
    Description = "Adjust your JumpPower",
    Default = 50,
    Min = 10,
    Max = 300,
    Rounding = 1,
    Callback = function(val)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = val
            end
        end
    end
})

local MiscTargetName = ""
Tabs.Misc:AddInput("TPPlayerInput", {
    Title = "Teleport To Player",
    Placeholder = "Enter player name",
    Default = "",
    Callback = function(val) MiscTargetName = val end
})

Tabs.Misc:AddButton({
    Title = "Teleport",
    Description = "Teleport to player",
    Callback = function()
        local target = findPlayer(MiscTargetName)
        local char = LocalPlayer.Character
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Could not teleport. Check name or display name.",
                Duration = 4
            })
        end
    end
})

-- ESP for Players
local playerESPEnabled = false
local espTags = {}

local function createBillboard(player)
    if player == LocalPlayer then return end
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    if espTags[player] then espTags[player]:Destroy() end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NevoxESP"
    billboard.Size = UDim2.new(0, 150, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = hrp
    billboard.AlwaysOnTop = true
    billboard.Parent = hrp
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard
    espTags[player] = billboard
end

local function removeBillboard(player)
    if espTags[player] then
        espTags[player]:Destroy()
        espTags[player] = nil
    end
end

Tabs.Misc:AddToggle("ESPToggle", {
    Title = "Enable ESP",
    Description = "Green names above heads of all players",
    Default = false
}):OnChanged(function(state)
    playerESPEnabled = state
    if playerESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createBillboard(player)
                player.CharacterAdded:Connect(function()
                    if playerESPEnabled then
                        task.wait(1)
                        createBillboard(player)
                    end
                end)
            end
        end
    else
        for player, gui in pairs(espTags) do
            if gui then gui:Destroy() end
        end
        espTags = {}
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if playerESPEnabled then
            task.wait(1)
            createBillboard(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeBillboard(player)
end)

-- NoClip
local noClipEnabled = false
local noClipConnection

local function setNoClip(state)
    local character = LocalPlayer.Character
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide ~= nil then
            part.CanCollide = not state
        end
    end
end

Tabs.Misc:AddToggle("NoClipToggle", {
    Title = "NoClip",
    Description = "Walk through walls",
    Default = false
}):OnChanged(function(state)
    noClipEnabled = state
    if noClipEnabled then
        setNoClip(true)
        noClipConnection = RunService.Stepped:Connect(function()
            setNoClip(true)
        end)
    else
        if noClipConnection then noClipConnection:Disconnect() end
        noClipConnection = nil
        setNoClip(false)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    if noClipEnabled then
        character:WaitForChild("HumanoidRootPart", 5)
        setNoClip(true)
    end
end)

-- Script Executors
Tabs.Misc:AddSection("Script Executors", "terminal")
Tabs.Misc:AddButton({
    Title = "Run Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})
Tabs.Misc:AddButton({
    Title = "Run Hydroxide",
    Callback = function()
        local function webImport(file)
            return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/" .. file .. ".lua"))()
        end
        webImport("init")
        webImport("ui/main")
    end
})
Tabs.Misc:AddButton({
    Title = "Remote Spy",
    Description = "Launches Richie’s Remote Spy",
    Callback = function()
        loadstring(game:HttpGetAsync("https://github.com/richie0866/remote-spy/releases/latest/download/RemoteSpy.lua"))()
    end
})
Tabs.Misc:AddButton({
    Title = "Run Dark Dex",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua"))()
    end
})

--------------------------------------------------------
-- CREDITS TAB
--------------------------------------------------------

Tabs.Credits:AddSection("Nevox Credits", "award")
Tabs.Credits:AddParagraph({ Title = "Created By", Content = "Madness.idk" })
Tabs.Credits:AddButton({
    Title = "Copy Link",
    Description = "Copies discord link to clipboard",
    Callback = function()
        setclipboard("https://discord.gg/FcUtaMfZkM")
        Fluent:Notify({
            Title = "Discord",
            Content = "Link copied to clipboard. Paste in browser to join.",
            Duration = 6
        })
    end
})
Tabs.Credits:AddParagraph({ Title = "Discord", Content = "https://discord.gg/FcUtaMfZkM" })

--------------------------------------------------------
-- SETTINGS, SAVE/LOAD CONFIG
--------------------------------------------------------

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("NevoxHub")
SaveManager:SetFolder("NevoxHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({
    Title = "Nevox",
    Content = "Script Loaded.",
    Duration = 8
})
SaveManager:LoadAutoloadConfig()
