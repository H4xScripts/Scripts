repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "H4xScripts",
    LoadingTitle = "Grow a Garden🍅",
    LoadingSubtitle = "by H4x",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "H4xScripts",
        FileName = "GrowAGarden"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false
})

local Tabs = {
    Main = Window:CreateTab("Main", 4483362458),
    Shop = Window:CreateTab("Shop", 4483362458),
    Player = Window:CreateTab("Players", 4483362458),
    Misc = Window:CreateTab("Misc", 4483362458),
    Visuals = Window:CreateTab("Visuals", 4483362458)
}

local lp = game.Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local oldCFrame = hrp.CFrame
local selectedFruit = "Carrot"

local autoFarmEnabled = false
local autoSellEnabled = false
local farms = {}
local plants = {}

local function updateFarmData()
    farms = {}
    plants = {}
    for _, farm in pairs(workspace.Farm:GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == lp.Name then
            table.insert(farms, farm)
            local plantsFolder = farm.Important.Plants_Physical
            if plantsFolder then
                for _, plantModel in pairs(plantsFolder:GetChildren()) do
                    for _, part in pairs(plantModel:GetDescendants()) do
                        if part:IsA("BasePart") and part:FindFirstChildOfClass("ProximityPrompt") then
                            table.insert(plants, part)
                        end
                    end
                end
            end
        end
    end
end

local function isInventoryFull()
    return game:GetService("CoreGui").RobloxGui.Backpack.Inventory.ScrollingFrame.UIGridFrame:FindFirstChild("200") ~= nil
end

local function sellItems()
    local steven = workspace.NPCS:FindFirstChild("Steven")
    if not steven then return end

    local originalPosition = hrp.CFrame
    hrp.CFrame = steven.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
    for _ = 1, 5 do
        game:GetService("ReplicatedStorage").GameEvents.Sell_Inventory:FireServer()
        task.wait(0.1)
    end

    if #farms > 0 and farms[1]:FindFirstChild("Spawn_Point") then
        hrp.CFrame = farms[1].Spawn_Point.CFrame + Vector3.new(0, 3, 0)
    else
        hrp.CFrame = originalPosition
    end
end

local autoFarmThread
local function instantFarm()
    if autoFarmThread then
        task.cancel(autoFarmThread)
    end

    autoFarmThread = task.spawn(function()
        while autoFarmEnabled do
            if isInventoryFull() then
                repeat
                    if not autoFarmEnabled then return end
                    task.wait(1)
                until not isInventoryFull()
            end

            if not autoFarmEnabled then return end

            updateFarmData()
            
            for _, part in pairs(plants) do
                if not autoFarmEnabled then return end
                
                if part and part.Parent then
                    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                        task.wait(0.05)

                        for _, farm in pairs(farms) do
                            if not autoFarmEnabled then return end
                            
                            local validPrompts = farm:GetDescendants()
                            for _, obj in pairs(validPrompts) do
                                if not autoFarmEnabled then return end
                                
                                if obj:IsA("ProximityPrompt") then
                                    local parentStr = tostring(obj.Parent)
                                    if not (parentStr:find("Grow_Sign") or parentStr:find("Core_Part")) then
                                        fireproximityprompt(obj, 1)
                                    end
                                end
                            end
                        end

                        if not autoFarmEnabled then return end
                        task.wait(0.2)
                    end
                end
            end
            
            if autoFarmEnabled then
                task.wait(0.1)
            end
        end
    end)
end

local function Oshop()
    local shop = workspace.NPCS.Sam.HumanoidRootPart.ProximityPrompt
    if shop then 
        fireproximityprompt(shop, 1)
    end
end

local function OGear()
    local ShopGear = workspace.NPCS.Eloise.HumanoidRootPart.ProximityPrompt
    if ShopGear then 
        fireproximityprompt(ShopGear, 1)
    end
end

local function Sell()
    local steven = workspace.NPCS:FindFirstChild("Steven")
    if steven then
        hrp.CFrame = steven.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        wait(0.2)
        
        game:GetService("ReplicatedStorage").GameEvents.Sell_Inventory:FireServer()
        
        local farms = workspace.Farm:GetChildren()
        for _, farm in pairs(farms) do
            local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
            if data and data:FindFirstChild("Owner") and data.Owner.Value == lp.Name then
                local spawn = farm:FindFirstChild("Spawn_Point")
                if spawn then
                    hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end
    end
end

local function HSell()
    local steven = workspace.NPCS:FindFirstChild("Steven")
    if steven then
        hrp.CFrame = steven.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        wait(0.2)
        
        game:GetService("ReplicatedStorage").GameEvents.Sell_Item:FireServer()
        
        local farms = workspace.Farm:GetChildren()
        for _, farm in pairs(farms) do
            local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
            if data and data:FindFirstChild("Owner") and data.Owner.Value == lp.Name then
                local spawn = farm:FindFirstChild("Spawn_Point")
                if spawn then
                    hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end
    end
end

local ESP = {
    Enabled = false,
    Color = Color3.fromRGB(0, 255, 255),
    Mode = "FullBody",
    Players = {}
}

local function CreateHighlights(player, character)
    if not character then return end
    if ESP.Players[player] then
        for _, v in pairs(ESP.Players[player]) do
            if v then v:Destroy() end
        end
    end
    ESP.Players[player] = {}

    if ESP.Enabled then
        if ESP.Mode == "FullBody" then
            local h = Instance.new("Highlight")
            h.FillColor = ESP.Color
            h.OutlineColor = ESP.Color
            h.FillTransparency = 0.5
            h.Adornee = character
            h.Parent = character
            table.insert(ESP.Players[player], h)
        else
            local head = character:FindFirstChild("Head")
            if head then
                local h = Instance.new("Highlight")
                h.FillColor = ESP.Color
                h.OutlineColor = ESP.Color
                h.FillTransparency = 0.5
                h.Adornee = head
                h.Parent = head
                table.insert(ESP.Players[player], h)
            end
        end
    end
end

local function UpdatePlayer(player)
    if player == game.Players.LocalPlayer then return end
    if player.Character then
        CreateHighlights(player, player.Character)
    end
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        CreateHighlights(player, char)
    end)
end

local function UpdateAll()
    for _, player in pairs(game.Players:GetPlayers()) do
        UpdatePlayer(player)
    end
end

local function DestroySign()
    for _, farm in pairs(workspace.Farm:GetChildren()) do
        local sign = farm:FindFirstChild("Sign")
        if sign then
            local core = sign:FindFirstChild("Core_Part")
            if core then
                for _, obj in pairs(core:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        obj:Destroy()
                    end
                end
            end
        end
        local growSign = farm:FindFirstChild("Grow_Sign")
        if growSign then
            for _, obj in pairs(growSign:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    obj:Destroy()
                end
            end
        end
    end
end

local function hasSeed(fruitName)
    local inventory = lp.Backpack:GetChildren()
    for _, item in pairs(inventory) do
        if string.match(item.Name, fruitName .. " %[X%d+%]") then
            return item
        end
    end
    return nil
end

local fastClickEnabled = false
local fastClickThread
local CLICK_DELAY = 0.02
local MAX_DISTANCE = 10

local function isValidPrompt(prompt)
    local parent = prompt.Parent
    if not parent then return false end
    local parentName = parent.Name:lower()
    return not (parentName:find("sign") or parentName:find("core"))
end

local function fastClickFarm()
    if fastClickThread then task.cancel(fastClickThread) end
    
    fastClickThread = task.spawn(function()
        while fastClickEnabled do
            if not isInventoryFull() then
                local character = lp.Character
                if character then
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        for _, farm in pairs(workspace.Farm:GetChildren()) do
                            local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
                            if data and data.Owner.Value == lp.Name then
                                for _, descendant in pairs(farm:GetDescendants()) do
                                    if fastClickEnabled and descendant:IsA("ProximityPrompt") and isValidPrompt(descendant) then
                                        local part = descendant.Parent
                                        if part:IsA("BasePart") then
                                            local distance = (humanoidRootPart.Position - part.Position).Magnitude
                                            if distance <= MAX_DISTANCE then
                                                fireproximityprompt(descendant, 1)
                                                task.wait(CLICK_DELAY)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                Rayfield:Notify({
                    Title = "Fast Click",
                    Content = "Paused (Backpack Full)",
                    Duration = 3
                })
                while fastClickEnabled and isInventoryFull() do
                    task.wait(1)
                end
            end
            task.wait()
        end
    end)
end

-- Main Tab
Tabs.Main:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        autoFarmEnabled = Value
        if Value then
            updateFarmData()
            instantFarm()
        end
    end
})

Tabs.Main:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Flag = "AutoSellToggle",
    Callback = function(Value)
        autoSellEnabled = Value
    end
})

spawn(function()
    while true do
        task.wait(1)
        if autoSellEnabled and isInventoryFull() then
            sellItems()
        end
    end
end)

Tabs.Main:CreateToggle({
    Name = "Auto Collect",
    CurrentValue = false,
    Flag = "FastClickToggle",
    Callback = function(Value)
        fastClickEnabled = Value
        if Value then
            fastClickFarm()
        elseif fastClickThread then
            task.cancel(fastClickThread)
        end
    end
})

Tabs.Main:CreateButton({
    Name = "Destroy Annoying Gamepass Message",
    Callback = DestroySign
})

-- Misc Tab
local fruitOptions = {
    "Carrot Seed", "Strawberry Seed", "Blueberry Seed", "Tomato Seed", "Corn Seed", 
    "Watermelon Seed", "Pumpkin Seed", "Apple Seed", "Bamboo Seed", "Coconut Seed", 
    "Cactus Seed", "DragonFruit Seed", "Mango Seed"
}

Tabs.Misc:CreateDropdown({
    Name = "Select Fruit",
    Options = fruitOptions,
    CurrentOption = "Carrot Seed",
    Flag = "FruitDropdown",
    Callback = function(value)
        selectedFruit = value
        local seed = hasSeed(selectedFruit)
        if not seed then
            Rayfield:Notify({
                Title = "H4xScripts",
                Content = "You don't have " .. selectedFruit .. " in your inventory!",
                Duration = 5
            })
        else
            lp.Character:WaitForChild("Humanoid"):EquipTool(seed)
        end
    end
})

Tabs.Misc:CreateButton({
    Name = "Plant Selected Fruit",
    Description = "You can place multiple at same location",
    Callback = function()
        local plantPosition = hrp.Position
        local fruitName = string.match(selectedFruit, "(%a+)")
        local args = {
            [1] = plantPosition,
            [2] = fruitName
        }

        game:GetService("ReplicatedStorage").GameEvents.Plant_RE:FireServer(unpack(args))
    end
})

Tabs.Misc:CreateSection("Trading")

Tabs.Misc:CreateDropdown({
    Name = "Select a Player",
    Description = "Sends Trade to Selected Player",
    Options = {"Soon"},
    CurrentOption = "Soon",
    Flag = "AutoTrade"
})

Tabs.Misc:CreateDropdown({
    Name = "Select a Object",
    Description = "Sends Trade to Selected Player",
    Options = {"Soon"},
    CurrentOption = "Soon",
    Flag = "AutoTradeITem"
})

Tabs.Misc:CreateInput({
    Name = "Amount",
    PlaceholderText = "Amount",
    RemoveTextAfterFocusLost = false,
    Numeric = true,
    Callback = function(Text) end
})

Tabs.Misc:CreateButton({
    Name = "Trade",
    Description = "Trades Selected item from inventory",
    Callback = function() end
})

Tabs.Misc:CreateButton({
    Name = "Trade Hand",
    Description = "Trade Holding Item",
    Callback = function() end
})

-- Shop Tab
Tabs.Shop:CreateButton({
    Name = "Gear Shop",
    Callback = OGear
})

Tabs.Shop:CreateButton({
    Name = "Open Shop",
    Callback = Oshop
})

Tabs.Shop:CreateButton({
    Name = "Sell All",
    Description = "Sell everthing in your inventory (ignores Fav)",
    Callback = Sell
})

Tabs.Shop:CreateButton({
    Name = "Sell Hand",
    Description = "Sells whatever you are holding",
    Callback = HSell
})

-- Visuals Tab
Tabs.Visuals:CreateToggle({
    Name = "ESP Enabled",
    CurrentValue = false,
    Flag = "ESPEnabled",
    Callback = function(state)
        ESP.Enabled = state
        UpdateAll()
    end
})

Tabs.Visuals:CreateColorpicker({
    Name = "ESP Color",
    Color = ESP.Color,
    Flag = "ESPColor",
    Callback = function(color)
        ESP.Color = color
        if ESP.Enabled then
            for _, player in pairs(ESP.Players) do
                for _, h in pairs(player) do
                    if h then
                        h.FillColor = color
                        h.OutlineColor = color
                    end
                end
            end
        end
    end
})

Tabs.Visuals:CreateDropdown({
    Name = "ESP Mode",
    Options = {"FullBody", "Head"},
    CurrentOption = "FullBody",
    Flag = "ESPMode",
    Callback = function(mode)
        ESP.Mode = mode
        if ESP.Enabled then
            UpdateAll()
        end
    end
})

-- Player Tab
local flyEnabled = false
local flySpeed = 48
local bodyVelocity, bodyGyro
local flightConnection

Tabs.Player:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(state)
        flyEnabled = state
        
        if flyEnabled then
            local character = game.Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            bodyGyro = Instance.new("BodyGyro")
            bodyVelocity = Instance.new("BodyVelocity")
            
            bodyGyro.P = 9000
            bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.cframe = character.HumanoidRootPart.CFrame
            bodyGyro.Parent = character.HumanoidRootPart
            
            bodyVelocity.velocity = Vector3.new(0, 0, 0)
            bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Parent = character.HumanoidRootPart
            
            humanoid.PlatformStand = true
            
            flightConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not flyEnabled or not character:FindFirstChild("HumanoidRootPart") then
                    if flightConnection then flightConnection:Disconnect() end
                    return
                end
                
                local cam = workspace.CurrentCamera.CFrame
                local moveVec = Vector3.new()
                
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                    moveVec = moveVec + cam.LookVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                    moveVec = moveVec - cam.LookVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                    moveVec = moveVec - cam.RightVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                    moveVec = moveVec + cam.RightVector
                end
                
                if moveVec.Magnitude > 0 then
                    moveVec = moveVec.Unit * flySpeed
                end
                
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                    moveVec = moveVec + Vector3.new(0, flySpeed, 0)
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveVec = moveVec + Vector3.new(0, -flySpeed, 0)
                end
                
                bodyVelocity.velocity = moveVec
                bodyGyro.cframe = cam
            end)
        else
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.PlatformStand = false
                end
            end
            
            if flightConnection then
                flightConnection:Disconnect()
                flightConnection = nil
            end
        end
    end
})

local noClipEnabled = false
local noclipConnection
Tabs.Player:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Callback = function(Value)
        noClipEnabled = Value
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()

        if noClipEnabled then
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

Tabs.Player:CreateInput({
    Name = "Player Speed",
    PlaceholderText = "Enter Speed",
    RemoveTextAfterFocusLost = false,
    Numeric = true,
    Callback = function(Value)
        local speed = tonumber(Value)
        if speed then
            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            if char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = speed
            end
        end
    end
})

Tabs.Player:CreateInput({
    Name = "Player Jump Power",
    PlaceholderText = "Enter Jump Power",
    RemoveTextAfterFocusLost = false,
    Numeric = true,
    Callback = function(Value)
        local jumpPower = tonumber(Value)
        if jumpPower then
            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            if char:FindFirstChild("Humanoid") then
                char.Humanoid.JumpPower = jumpPower
            end
        end
    end
})

-- Initialize ESP
game.Players.PlayerAdded:Connect(UpdatePlayer)
for _, player in pairs(game.Players:GetPlayers()) do
    UpdatePlayer(player)
end

lp.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
end)

print([[
██╗░░██╗░░██╗██╗██╗░░██╗    ░██████╗░█████╗░██████╗░██╗██████╗░████████╗░██████╗
██║░░██║░██╔╝██║╚██╗██╔╝    ██╔════╝██╔══██╗██╔══██╗██║██╔══██╗╚══██╔══╝██╔════╝
███████║██╔╝░██║░╚███╔╝░    ╚█████╗░██║░░╚═╝██████╔╝██║██████╔╝░░░██║░░░╚█████╗░
██╔══██║███████║░██╔██╗░    ░╚═══██╗██║░░██╗██╔══██╗██║██╔═══╝░░░░██║░░░░╚═══██╗
██║░░██║╚════██║██╔╝╚██╗    ██████╔╝╚█████╔╝██║░░██║██║██║░░░░░░░░██║░░░██████╔╝
╚═╝░░╚═╝░░░░░╚═╝╚═╝░░╚═╝    ╚═════╝░░╚════╝░╚═╝░░╚═╝╚═╝╚═╝░░░░░░░░╚═╝░░░╚═════╝░
]])
