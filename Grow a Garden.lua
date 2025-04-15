repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "H4xScripts",
    SubTitle = "Grow a Garden🍅",
    TabWidth = 110,
    Size = UDim2.fromOffset(450, 340),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({Title = "Main", Icon = "locate"}),
    Shop = Window:AddTab({Title = "Shop", Icon = "shopping-cart"}),
    playerTab = Window:AddTab({Title = "Players", Icon = "user"}),
    Misc = Window:AddTab({Title = "Misc", Icon = "align-justify"}),
    Visuals = Window:AddTab({Title = "Visuals", Icon = "eye"})
}
local Main, Shop, playerTab, Misc, Visual = Tabs.Main, Tabs.Shop, Tabs.playerTab, Tabs.Misc, Tabs.Visuals
Window:SelectTab(1)

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
    return CoreGui.RobloxGui.Backpack.Inventory.ScrollingFrame.UIGridFrame:FindFirstChild("200") ~= nil
end

local function sellItems()
    local steven = workspace.NPCS:FindFirstChild("Steven")
    if not steven then return end

    local originalPosition = hrp.CFrame
    hrp.CFrame = steven.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
    for _ = 1, 5 do
        ReplicatedStorage.GameEvents.Sell_Inventory:FireServer()
        task.wait(0.1)
    end

    if #farms > 0 and farms[1]:FindFirstChild("Spawn_Point") then
        hrp.CFrame = farms[1].Spawn_Point.CFrame + Vector3.new(0, 3, 0)
    else
        hrp.CFrame = originalPosition
    end
end

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
local function FeedBack()
    local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1359226208361119794/l-PlzjIlccSxe_dqApkTGnqyh5XkJylGZMgFINxhWJF4nEtE3xi281cxECv0TX1Vib6S"

if CoreGui:FindFirstChild("H4xScriptFeedback") then
    CoreGui.H4xScriptFeedback:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "H4xScriptFeedback"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Text = "H4xScript Feedback"
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Text = "×"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 20
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -50)
contentFrame.Position = UDim2.new(0, 10, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local typeLabel = Instance.new("TextLabel")
typeLabel.Text = "Select Feedback Type:"
typeLabel.Size = UDim2.new(1, 0, 0, 20)
typeLabel.BackgroundTransparency = 1
typeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
typeLabel.Font = Enum.Font.Gotham
typeLabel.TextSize = 14
typeLabel.TextXAlignment = Enum.TextXAlignment.Left
typeLabel.Parent = contentFrame

local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, 0, 0, 30)
buttonContainer.Position = UDim2.new(0, 0, 0, 25)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = contentFrame

local bugButton = Instance.new("TextButton")
bugButton.Name = "BugButton"
bugButton.Text = "Bug Report"
bugButton.Size = UDim2.new(0.32, 0, 1, 0)
bugButton.Position = UDim2.new(0, 0, 0, 0)
bugButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
bugButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bugButton.Font = Enum.Font.GothamBold
bugButton.TextSize = 14
bugButton.Parent = buttonContainer

local bugCorner = Instance.new("UICorner")
bugCorner.CornerRadius = UDim.new(0, 6)
bugCorner.Parent = bugButton

local featureButton = Instance.new("TextButton")
featureButton.Name = "FeatureButton"
featureButton.Text = "Feature"
featureButton.Size = UDim2.new(0.32, 0, 1, 0)
featureButton.Position = UDim2.new(0.34, 0, 0, 0)
featureButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
featureButton.TextColor3 = Color3.fromRGB(255, 255, 255)
featureButton.Font = Enum.Font.GothamBold
featureButton.TextSize = 14
featureButton.Parent = buttonContainer

local featureCorner = Instance.new("UICorner")
featureCorner.CornerRadius = UDim.new(0, 6)
featureCorner.Parent = featureButton

local gameButton = Instance.new("TextButton")
gameButton.Name = "GameButton"
gameButton.Text = "Add Game"
gameButton.Size = UDim2.new(0.32, 0, 1, 0)
gameButton.Position = UDim2.new(0.68, 0, 0, 0)
gameButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
gameButton.TextColor3 = Color3.fromRGB(255, 255, 255)
gameButton.Font = Enum.Font.GothamBold
gameButton.TextSize = 14
gameButton.Parent = buttonContainer

local gameCorner = Instance.new("UICorner")
gameCorner.CornerRadius = UDim.new(0, 6)
gameCorner.Parent = gameButton

local msgBox = Instance.new("TextBox")
msgBox.Name = "MessageBox"
msgBox.Text = ""
msgBox.PlaceholderText = "Type your feedback here..."
msgBox.Size = UDim2.new(1, 0, 0, 200)
msgBox.Position = UDim2.new(0, 0, 0, 65)
msgBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
msgBox.TextColor3 = Color3.fromRGB(255, 255, 255)
msgBox.Font = Enum.Font.Gotham
msgBox.TextSize = 14
msgBox.MultiLine = true
msgBox.TextWrapped = true
msgBox.ClearTextOnFocus = false
msgBox.Parent = contentFrame

local msgCorner = Instance.new("UICorner")
msgCorner.CornerRadius = UDim.new(0, 6)
msgCorner.Parent = msgBox

local msgPadding = Instance.new("UIPadding")
msgPadding.PaddingLeft = UDim.new(0, 8)
msgPadding.PaddingTop = UDim.new(0, 8)
msgPadding.Parent = msgBox

local submitButton = Instance.new("TextButton")
submitButton.Text = "SUBMIT FEEDBACK"
submitButton.Size = UDim2.new(1, 0, 0, 45)
submitButton.Position = UDim2.new(0, 0, 0, 275)
submitButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
submitButton.Font = Enum.Font.GothamBold
submitButton.TextSize = 16
submitButton.Parent = contentFrame

local submitCorner = Instance.new("UICorner")
submitCorner.CornerRadius = UDim.new(0, 6)
submitCorner.Parent = submitButton

local selectedType = "Bug Report"
local isSending = false

local function selectButton(button)
    if button.Name == "BugButton" then
        selectedType = "Bug Report"
        TweenService:Create(bugButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
        TweenService:Create(featureButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
        TweenService:Create(gameButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
    elseif button.Name == "FeatureButton" then
        selectedType = "Feature Request"
        TweenService:Create(featureButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 200, 50)}):Play()
        TweenService:Create(bugButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
        TweenService:Create(gameButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
    else
        selectedType = "Add Game"
        TweenService:Create(gameButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 215, 0)}):Play()
        TweenService:Create(bugButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
        TweenService:Create(featureButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
    end
end

local function sendToDiscord(message, feedbackType)
    if isSending then return false end
    isSending = true
    
    local player = Players.LocalPlayer
    local gameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    
    local color = ({
        ["Bug Report"] = 16711680,
        ["Feature Request"] = 65280,
        ["Add Game"] = 16776960
    })[feedbackType]
    
    local embed = {
        {
            description = string.format(
                "**Name**: [%s](https://www.roblox.com/users/%d/profile)\n"..
                "**Game**: [%s](https://www.roblox.com/games/%d)\n"..
                "**Feedback**: \n```%s```",
                player.DisplayName or player.Name,
                player.UserId,
                gameInfo.Name,
                game.PlaceId,
                message
            ),
            color = color,
            footer = {
                text = os.date("%Y-%m-%d %H:%M:%S")
            }
        }
    }
    
    local success, response = pcall(function()
        local requestFunc = syn and syn.request or http_request or request
        return requestFunc({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                embeds = embed,
                username = "H4xScript Feedback",
                avatar_url = ""
            })
        })
    end)
    
    isSending = false
    return success, response
end

bugButton.MouseButton1Click:Connect(function() selectButton(bugButton) end)
featureButton.MouseButton1Click:Connect(function() selectButton(featureButton) end)
gameButton.MouseButton1Click:Connect(function() selectButton(gameButton) end)

selectButton(bugButton)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local dragging = false
local dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        updateInput(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateInput(input)
    end
end)

submitButton.MouseButton1Click:Connect(function()
    local message = msgBox.Text
    if message == "" then
        local notify = Instance.new("TextLabel")
        notify.Text = "Please enter feedback!"
        notify.Size = UDim2.new(1, -40, 0, 30)
        notify.Position = UDim2.new(0, 20, 0, 340)
        notify.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        notify.TextColor3 = Color3.fromRGB(255, 255, 255)
        notify.Font = Enum.Font.GothamBold
        notify.TextSize = 14
        notify.Parent = mainFrame
        
        task.delay(3, function()
            notify:Destroy()
        end)
        return
    end
    
    local success, response = sendToDiscord(message, selectedType)
    
    if success then
        msgBox.Text = ""
        local notify = Instance.new("TextLabel")
        notify.Text = "Thank You!! We Received your Feedback successfully!"
        notify.Size = UDim2.new(1, -40, 0, 30)
        notify.Position = UDim2.new(0, 20, 0, 365)
        notify.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        notify.TextColor3 = Color3.fromRGB(255, 255, 255)
        notify.Font = Enum.Font.GothamBold
        notify.TextSize = 14
        notify.Parent = mainFrame
        
        task.delay(1, function()
            notify:Destroy()
            screenGui:Destroy()
        end)
    else
        warn("Webhook error:", response)
        local notify = Instance.new("TextLabel")
        notify.Text = "Failed to send feedback!"
        notify.Size = UDim2.new(1, -40, 0, 30)
        notify.Position = UDim2.new(0, 20, 0, 340)
        notify.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        notify.TextColor3 = Color3.fromRGB(255, 255, 255)
        notify.Font = Enum.Font.GothamBold
        notify.TextSize = 14
        notify.Parent = mainFrame
        
        task.delay(3, function()
            notify:Destroy()
        end)
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
        
        game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
        
        local farms = workspace:WaitForChild("Farm"):GetChildren()
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
        
        game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Sell_Item"):FireServer()
        
        local farms = workspace:WaitForChild("Farm"):GetChildren()
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
                Fluent:Notify({
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

Main:AddToggle("AutoFarmToggle", {
    Title = "Auto Farm",
    Description = "Private Server Recommended(Enable Auto Sell or Kinda Buggy)",
    Default = false,
    Callback = function(Value)
        autoFarmEnabled = Value
        if Value then
            updateFarmData()
            instantFarm()
        end
    end
})
Main:AddToggle("AutoSellToggle", {
    Title = "Auto Sell",
    Description = "Auto Sells when inventory full",
    Default = false,
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
Main:AddToggle("FastClickToggle", {
    Title = "Auto Collect",
    Default = false,
    Callback = function(Value)
        fastClickEnabled = Value
        if Value then
            fastClickFarm()
        elseif fastClickThread then
            task.cancel(fastClickThread)
        end
    end
})
Main:AddButton({
    Title = "Destroy Annoying Gamepass Message",
    Callback = DestroySign
})

Misc:AddDropdown("FruitDropdown",{
    Title = "Select Fruit",
    Values = {
        "Carrot Seed", "Strawberry Seed", "Blueberry Seed", "Tomato Seed", "Corn Seed", 
        "Watermelon Seed", "Pumpkin Seed", "Apple Seed", "Bamboo Seed", "Coconut Seed", 
        "Cactus Seed", "DragonFruit Seed", "Mango Seed"
    },
    Multi = false,
    Default = 1,
    Callback = function(value)
        selectedFruit = value
        local seed = hasSeed(selectedFruit)
        if not seed then
            Fluent:Notify({
                Title = "H4xScripts",
                Content = "You don't have " .. selectedFruit .. " in your inventory!",
                Duration = 5
            })
        else
            lp.Character:WaitForChild("Humanoid"):EquipTool(seed)
        end
    end
})
Misc:AddButton({
    Title = "Plant Selected Fruit",
    Description = "You can place multiple at same location",
    Callback = function()
        local plantPosition = hrp.Position
        local fruitName = string.match(selectedFruit, "(%a+)")
        local args = {
            [1] = plantPosition,
            [2] = fruitName
        }

        game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Plant_RE"):FireServer(unpack(args))
    end
})
local Section = Misc:AddSection("Trading")
Misc:AddDropdown("AutoTrade",{
    Title = "Select a Player",
    Description = "Sends Trade to Selected Player",
    Values = {"Soon"},
    Multi = false,
    Default = 1
})
Misc:AddDropdown("AutoTradeITem",{
    Title = "Select a Object",
    Description = "Sends Trade to Selected Player",
    Values = {"Soon"},
    Multi = false,
    Default = 1
})
local Input = Misc:AddInput("Input", {
    Title = "Soon",
    Description = "",
    Default = "",
    Placeholder = "Amount",
    Numeric = true, 
    Finished = false, 
})
Misc:AddButton({
    Title = "Trade ",
    Description = "Trades Selected item from inventory",
})
Misc:AddButton({
    Title = "Trade Hand",
    Description = "Trade Holding Item"
})





Misc:AddButton({
    Title = "FeedBack",
    Description = "Help us imporve our script",
    Callback = FeedBack
})
Shop:AddButton({
    Title = "Gear Shop",
    Callback = OGear
})

Shop:AddButton({
    Title = "Open Shop",
    Callback = Oshop
})

Shop:AddButton({
    Title = "Sell All",
    Description = "Sell everthing in your inventory (ignores Fav)",
    Callback = Sell
})
Shop:AddButton({
    Title = "Sell Hand",
    Description = "Sells whatever you are holding",
    Callback = HSell
})


Visual:AddToggle("ESPEnabled", {
    Title = "ESP Enabled",
    Default = false,
    Callback = function(state)
        ESP.Enabled = state
        UpdateAll()
    end
})
Visual:AddColorpicker("ESPColor", {
    Title = "ESP Color",
    Default = ESP.Color,
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

Visual:AddDropdown("ESPMode", {
    Title = "ESP Mode",
    Values = {"FullBody", "Head"},
    Default = "FullBody",
    Callback = function(mode)
        ESP.Mode = mode
        if ESP.Enabled then
            UpdateAll()
        end
    end
})

game.Players.PlayerAdded:Connect(UpdatePlayer)

for _, player in pairs(game.Players:GetPlayers()) do
    UpdatePlayer(player)
end



lp.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
end)


local flyEnabled = false
local flySpeed = 48
local bodyVelocity, bodyGyro
local flightConnection

local flyToggle = playerTab:AddToggle("FlyToggle", {
    Title = "Fly",
    Description = "Enable or disable flying.",
    Default = false,
    Callback = function(state)
        flyEnabled = state
        
        if flyEnabled then
            -- Start flying
            local character = game.Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            -- Create flight controls
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
            
            -- Flight control
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
                
                -- Up/down controls
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
            -- Stop flying
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

playerTab:AddToggle("NoClipToggle", {
    Title = "No Clip",
    Default = false,
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
local Input = playerTab:AddInput("SpeedInput", {
    Title = "Player Speed",
    Default = "16",
    Placeholder = "Enter Speed",
    Numeric = true,
    Finished = true,
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

local JumpInput = playerTab:AddInput("JumpInput", {
    Title = "Player Jump Power",
    Default = "50",
    Placeholder = "Enter Jump Power",
    Numeric = true,
    Finished = true,
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

print([[

██╗░░██╗░░██╗██╗██╗░░██╗    ░██████╗░█████╗░██████╗░██╗██████╗░████████╗░██████╗
██║░░██║░██╔╝██║╚██╗██╔╝    ██╔════╝██╔══██╗██╔══██╗██║██╔══██╗╚══██╔══╝██╔════╝
███████║██╔╝░██║░╚███╔╝░    ╚█████╗░██║░░╚═╝██████╔╝██║██████╔╝░░░██║░░░╚█████╗░
██╔══██║███████║░██╔██╗░    ░╚═══██╗██║░░██╗██╔══██╗██║██╔═══╝░░░░██║░░░░╚═══██╗
██║░░██║╚════██║██╔╝╚██╗    ██████╔╝╚█████╔╝██║░░██║██║██║░░░░░░░░██║░░░██████╔╝
╚═╝░░╚═╝░░░░░╚═╝╚═╝░░╚═╝    ╚═════╝░░╚════╝░╚═╝░░╚═╝╚═╝╚═╝░░░░░░░░╚═╝░░░╚═════╝░
]]);
local screenGui
repeat
    task.wait()
    for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if v:IsA("ScreenGui") and v:FindFirstChildWhichIsA("Frame") then
            screenGui = v
            break
        end
    end
until screenGui

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 38, 0, 38)
minimizeButton.Position = UDim2.new(0.5, -19, 0.5, -19)
minimizeButton.AnchorPoint = Vector2.new(0.5, 0.5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = ""
minimizeButton.AutoButtonColor = true
minimizeButton.ZIndex = 999
minimizeButton.Parent = screenGui

minimizeButton.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

local dragging = false
local dragStart, startPos

minimizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = minimizeButton.Position
    end
end)

local UIS = game:GetService("UserInputService")

minimizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = minimizeButton.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        minimizeButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
