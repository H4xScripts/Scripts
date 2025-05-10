local HttpService = game:GetService("HttpService")
local key = _G.H4xScriptKeySystem
local function LoadScript()
	
    -- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Local Variables
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local oldCFrame = hrp.CFrame
local leaderstats = lp:FindFirstChild("leaderstats")
local shecklesStat = leaderstats and leaderstats:FindFirstChild("Sheckles")
local seedRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock")
local gearRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyGearStock")
local easterRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyEasterStock")
local seedPath = lp.PlayerGui.Seed_Shop.Frame.ScrollingFrame
local gearPath = lp.PlayerGui.Gear_Shop.Frame.ScrollingFrame
local gearicon = Players.LocalPlayer.PlayerGui.Teleport_UI.Frame.Gear
local seedItems = {"Carrot","Strawberry","Blueberry","Orange Tulip","Tomato","Corn","Daffodil","Watermelon","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit","Mango","Grape","Mushroom","Pepper"}
local gearItems = {"Watering Can","Trowel","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Lightning Rod","Master Sprinkler"}
local autoBuyEnabled = false
local selectedSeeds, selectedGears = {}, {}
local farms = {}
local plants = {}
local mutationOptions = {"Wet","Gold","Frozen","Rainbow","Choc","Chilled","Shocked"}
local selectedMutations = {"Gold","Frozen","Rainbow","Choc","Chilled","Shocked"}
local seedNames = {"Apple","Banana","Bamboo","Blueberry","Candy Blossom","Candy Sunflower","Carrot","Cactus","Chocolate Carrot","Chocolate Sprinkler","Coconut","Corn","Cranberry","Cucumber","Cursed Fruit","Daffodil","Dragon Fruit","Durian","Easter Egg","Eggplant","Grape","Lemon","Lotus","Mango","Mushroom","Pepper","Orange Tulip","Papaya","Passionfruit","Peach","Pear","Pineapple","Pumpkin","Raspberry","Red Lollipop","Soul Fruit","Strawberry","Tomato","Venus Fly Trap","Watermelon"}
local sellThreshold = 200

gearicon.Active = true
gearicon.Visible = true
gearicon.ImageColor3 = Color3.fromRGB( 255, 255, 255)




-- Utility Functions
local function parseMoney(moneyStr)
    if not moneyStr then return 0 end
    moneyStr = tostring(moneyStr):gsub("Â¢", ""):gsub(",", ""):gsub(" ", ""):gsub("%$", "")
    local multiplier = 1
    if moneyStr:lower():find("k") then
        multiplier = 1000
        moneyStr = moneyStr:lower():gsub("k", "")
    elseif moneyStr:lower():find("m") then
        multiplier = 1000000
        moneyStr = moneyStr:lower():gsub("m", "")
    end
    return (tonumber(moneyStr) or 0) * multiplier
end

local function getPlayerMoney()
    return parseMoney((shecklesStat and shecklesStat.Value) or 0)
end

local function isInventoryFull()
    return #lp.Backpack:GetChildren() >= sellThreshold
end

-- Auto Farm Functions
local autoFarmEnabled = false
local farmThread
local excludedVariants = {}
local farms = {}
local plants = {}

local function hasExcludedVariant(model)
    for _, descendant in pairs(model:GetDescendants()) do
        if descendant:IsA("StringValue") and descendant.Name == "Variant" then
            if table.find(excludedVariants, descendant.Value) then
                return true
            end
        end
    end
    return false
end

local function updateFarmData()
    farms = {}
    plants = {}
    for _, farm in pairs(workspace:FindFirstChild("Farm"):GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == lp.Name then
            table.insert(farms, farm)
            local plantsFolder = farm.Important:FindFirstChild("Plants_Physical")
            if plantsFolder then
                for _, plantModel in pairs(plantsFolder:GetChildren()) do
                    if not hasExcludedVariant(plantModel) then
                        for _, part in pairs(plantModel:GetDescendants()) do
                            if part:IsA("BasePart") then
                                local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                                if prompt then
                                    table.insert(plants, part)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function glitchTeleport(pos)
    if not lp.Character then return end
    local root = lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local tween = TweenService:Create(root, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))})
    tween:Play()
end

local function instantFarm()
    if farmThread then task.cancel(farmThread) end
    farmThread = task.spawn(function()
        while autoFarmEnabled do
            while isInventoryFull() do
                if not autoFarmEnabled then return end
                task.wait(1)
            end
            if not autoFarmEnabled then return end
            updateFarmData()
            for _, part in pairs(plants) do
                if not autoFarmEnabled or isInventoryFull() then break end
                if part and part.Parent then
                    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        glitchTeleport(part.Position)
                        task.wait(0.2)
                        for _, farm in pairs(farms) do
                            if not autoFarmEnabled or isInventoryFull() then break end
                            for _, obj in pairs(farm:GetDescendants()) do
                                if obj:IsA("ProximityPrompt") then
                                    local model = obj.Parent:FindFirstAncestorOfClass("Model")
                                    if not (hasExcludedVariant(model) or tostring(obj.Parent):find("Grow_Sign") or tostring(obj.Parent):find("Core_Part")) then
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
            if autoFarmEnabled then task.wait(0.1) end
        end
    end)
end

-- Auto Collect Functions
-- Auto Collect Functions
local fastClickEnabled = false
local fastClickThread
local CLICK_DELAY = 0.02
local MAX_DISTANCE = 10


local function hasExcludedVariant(model)
    for _, descendant in pairs(model:GetDescendants()) do
        if descendant:IsA("StringValue") and descendant.Name == "Variant" then
            if table.find(excludedVariants, descendant.Value) then
                return true
            end
        end
    end
    return false
end

local function isValidPrompt(prompt)
    local parent = prompt.Parent
    if not parent then return false end
    
    -- Skip if parent model has excluded variant
    local model = parent:FindFirstAncestorOfClass("Model")
    if model and hasExcludedVariant(model) then
        return false
    end
    
    local name = parent.Name:lower()
    return not (name:find("sign") or name:find("core"))
end

local function getNearbyPrompts()
    local nearby = {}
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nearby end
    
    for _, farm in pairs(workspace.Farm:GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == lp.Name then
            for _, obj in pairs(farm:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and isValidPrompt(obj) then
                    local part = obj.Parent
                    if part:IsA("BasePart") then
                        local dist = (hrp.Position - part.Position).Magnitude
                        if dist <= MAX_DISTANCE then
                            table.insert(nearby, obj)
                        end
                    end
                end
            end
        end
    end
    return nearby
end

local function fastClickFarm()
    if fastClickThread then task.cancel(fastClickThread) end
    fastClickThread = task.spawn(function()
        while fastClickEnabled do
            if isInventoryFull() then
                task.wait(1)
                continue
            end
            
            local prompts = getNearbyPrompts() -- Automatically filters excluded variants
            for _, prompt in pairs(prompts) do
                if not fastClickEnabled then return end
                if isInventoryFull() then break end
                fireproximityprompt(prompt, 1)
                task.wait(CLICK_DELAY)
            end
            task.wait(0.1)
        end
    end)
end
-- Auto Sell Functions
local autoSellEnabled = false
local autoSellThread

local function sellItems()
    local steven = workspace.NPCS:FindFirstChild("Steven")
    if not steven then return false end
    
    local char = lp.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local originalPosition = hrp.CFrame
    hrp.CFrame = steven.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3)
    task.wait(0.5)
    
    for _ = 1, 5 do
        pcall(function()
            ReplicatedStorage.GameEvents.Sell_Inventory:FireServer()
        end)
        task.wait(0.15)
    end
    
    while #lp.Backpack:GetChildren() >= sellThreshold do
        task.wait(0.5)
    end
    
    hrp.CFrame = originalPosition
    return true
end


-- Harvest Functions
local HarvestEnabled = false
local HarvestConnection = nil

local function FindGarden()
    local farm = workspace:FindFirstChild("Farm")
    if not farm then return nil end
    
    for _, plot in ipairs(farm:GetChildren()) do
        local data = plot:FindFirstChild("Important") and plot.Important:FindFirstChild("Data")
        local owner = data and data:FindFirstChild("Owner")
        if owner and owner.Value == lp.Name then
            return plot
        end
    end
    return nil
end

local function CanHarvest(part)
    local prompt = part:FindFirstChild("ProximityPrompt")
    return prompt and prompt.Enabled
end

local function Harvest()
    if not HarvestEnabled then return end
    if isInventoryFull() then return end

    local garden = FindGarden()
    if not garden then return end

    local plants = garden:FindFirstChild("Important") and garden.Important:FindFirstChild("Plants_Physical")
    if not plants then return end

    for _, plant in ipairs(plants:GetChildren()) do
        if not HarvestEnabled then break end
        local fruits = plant:FindFirstChild("Fruits")
        if fruits then
            for _, fruit in ipairs(fruits:GetChildren()) do
                if not HarvestEnabled then break end

                local shouldExclude = false
                for _, desc in ipairs(fruit:GetDescendants()) do
                    if desc:IsA("StringValue") and desc.Name == "Variant" then
                        if table.find(excludedVariants, desc.Value) then
                            shouldExclude = true
                            break
                        end
                    end
                end
                if shouldExclude then continue end

                for _, part in ipairs(fruit:GetChildren()) do
                    if not HarvestEnabled then break end
                    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                    if part:IsA("BasePart") and prompt and prompt.Enabled then
                        local pos = part.Position + Vector3.new(0, 4.5, 0)
                        if lp.Character and lp.Character.PrimaryPart then
                            lp.Character:SetPrimaryPartCFrame(CFrame.new(pos))
                            task.wait(0.1)
                            if not HarvestEnabled then break end
                            prompt:InputHoldBegin()
                            task.wait(0.1)
                            if not HarvestEnabled then break end
                            prompt:InputHoldEnd()
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
    end
end


local function ToggleHarvest(state)
    if HarvestConnection then
        HarvestConnection:Disconnect()
        HarvestConnection = nil
    end
    HarvestEnabled = state
    if state then
        HarvestConnection = RunService.Heartbeat:Connect(function()
            if HarvestEnabled then
                Harvest()
            else
                HarvestConnection:Disconnect()
                HarvestConnection = nil
            end
        end)
    end
end

-- Movement Functions
local flyEnabled = false
local flySpeed = 48
local bodyVelocity, bodyGyro
local flightConnection

local function Fly(state)
    flyEnabled = state
    if flyEnabled then
        local character = lp.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        bodyGyro = Instance.new("BodyGyro")
        bodyVelocity = Instance.new("BodyVelocity")
        bodyGyro.P = 9000
        bodyGyro.maxTorque = Vector3.new(8999999488, 8999999488, 8999999488)
        bodyGyro.cframe = character.HumanoidRootPart.CFrame
        bodyGyro.Parent = character.HumanoidRootPart
        
        bodyVelocity.velocity = Vector3.new(0, 0, 0)
        bodyVelocity.maxForce = Vector3.new(8999999488, 8999999488, 8999999488)
        bodyVelocity.Parent = character.HumanoidRootPart
        humanoid.PlatformStand = true
        
        flightConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not character:FindFirstChild("HumanoidRootPart") then
                if flightConnection then flightConnection:Disconnect() end
                return
            end
            
            local cam = workspace.CurrentCamera.CFrame
            local moveVec = Vector3.new()
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVec = moveVec + cam.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVec = moveVec - cam.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVec = moveVec - cam.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVec = moveVec + cam.RightVector
            end
            
            if moveVec.Magnitude > 0 then
                moveVec = moveVec.Unit * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveVec = moveVec + Vector3.new(0, flySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveVec = moveVec + Vector3.new(0, -flySpeed, 0)
            end
            
            bodyVelocity.velocity = moveVec
            bodyGyro.cframe = cam
        end)
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        
        local character = lp.Character
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

-- NoClip Functions
local noclip = false

RunService.Stepped:Connect(function()
    if noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

local function ToggleNoclip(state)
    noclip = state
end

-- Infinite Jump Functions
local infJump = false

UserInputService.JumpRequest:Connect(function()
    if infJump and char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function ToggleInfJump(state)
    infJump = state
end

-- Shop Functions
local function OpenShop()
    local shop = lp.PlayerGui.Seed_Shop
    shop.Enabled = not shop.Enabled
end

local function OpenGearShop()
    local gear = lp.PlayerGui.Gear_Shop
    gear.Enabled = not gear.Enabled
end

local function OpenEaster()
    print("success")
    local easter = lp.PlayerGui.Easter_Shop
    easter.Enabled = not easter.Enabled
end

local function OpenQuest()
    local quest = lp.PlayerGui.DailyQuests_UI
    quest.Enabled = not quest.Enabled
end

local function OpenTravelMer()
    local quest = lp.PlayerGui.TravellingMerchant_Shop
    quest.Enabled = not quest.Enabled
end

local function EggShop1()
    fireproximityprompt(workspace.NPCS["Pet Stand"].EggLocations["Common Egg"].ProximityPrompt)
end

local function EggShop2()
    fireproximityprompt(workspace.NPCS["Pet Stand"].EggLocations:GetChildren()[6].ProximityPrompt)
end

local function EggShop3()
    fireproximityprompt(workspace.NPCS["Pet Stand"].EggLocations:GetChildren()[5].ProximityPrompt)
end














-- Sell Functions
local function SellAll()
    local steven = workspace.NPCS:FindFirstChild("Steven")
    if steven then
        hrp.CFrame = steven.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        wait(0.2)
        ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
        
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
        ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Item"):FireServer()
        
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

-- Dupe Functions
local dupeLLPEnabled = false
local dupeLLPThread

local function DupeLLP()
    if dupeLLPThread then task.cancel(dupeLLPThread) end
    dupeLLPThread = task.spawn(function()
        while dupeLLPEnabled do
            local event = ReplicatedStorage.GameEvents.EasterShopService
            for i = 1, 5 do
                event:FireServer("PurchaseSeed", i)
                task.wait(0.1)
            end
            task.wait(20)
        end
    end)
end

local BananaDupe
local BAnanaDupeE = false

local function DupeBanana()
    if BananaDupe then task.cancel(BananaDupe) end
    BananaDupe = task.spawn(function()
        while BAnanaDupeE do
            ReplicatedStorage.GameEvents.BuySeedStock:FireServer("Banana")
            task.wait(20)
        end
    end)
end

-- Auto Collect V2 Functions
local spamE = false
local RANGE = 10
local promptTracker = {}
local collectionThread
local descendantConnection

local function modifyPrompt(prompt, show)
    pcall(function()
        prompt.RequiresLineOfSight = not show
        prompt.Exclusivity = show and Enum.ProximityPromptExclusivity.AlwaysShow or Enum.ProximityPromptExclusivity.One
    end)
end

local function isInsideFarm(part)
    for _, farm in pairs(farms) do
        if part:IsDescendantOf(farm) then
            return true
        end
    end
    return false
end

local function handleNewPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if not isInsideFarm(prompt) then return end
    
    if not promptTracker[prompt] then
        promptTracker[prompt] = {
            originalRequiresLOS = prompt.RequiresLineOfSight,
            originalExclusivity = prompt.Exclusivity
        }
    end
    
    modifyPrompt(prompt, spamE)
    prompt.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            promptTracker[prompt] = nil
        end
    end)
end

-- One Click Remove Functions
local enabled = false

local function OneClickRemove(state)
    enabled = state
    local confirmFrame = Players.LocalPlayer.PlayerGui:FindFirstChild("ShovelPrompt")
    if confirmFrame and confirmFrame:FindFirstChild("ConfirmFrame") then
        confirmFrame.ConfirmFrame.Visible = not state
    end
end

-- Anti-AFK Function
local function AntiAfk(state)
    if state then
        if not _G.AntiAfkConnection then
            _G.AntiAfkConnection = Players.LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    elseif _G.AntiAfkConnection then
        _G.AntiAfkConnection:Disconnect()
        _G.AntiAfkConnection = nil
    end
end

-- Destroy Sign Function
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

-- Auto Favorite Functions
local favoriteEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Favorite_Item")
local connection = nil

local favoriteEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Favorite_Item")
local connection = nil
local selectedMutations = {}
local autoFavoriteEnabled = false

-- Utility Functions
local function toolMatchesMutation(toolName)
    for _, mutation in ipairs(selectedMutations) do
        if string.find(toolName, mutation) then
            return true
        end
    end
    return false
end

local function isToolFavorited(tool)
    return tool:GetAttribute("Favorite") or (tool:FindFirstChild("Favorite") and tool.Favorite.Value)
end

local function favoriteToolIfMatches(tool)
    if toolMatchesMutation(tool.Name) and not isToolFavorited(tool) then
        favoriteEvent:FireServer(tool)
        task.wait(0.1)
    end
end

local function processBackpack()
    local backpack = lp:FindFirstChild("Backpack") or lp:WaitForChild("Backpack")
    for _, tool in ipairs(backpack:GetChildren()) do
        favoriteToolIfMatches(tool)
    end
end

-- Setup Listener
local function setupAutoFavorite()
    if connection then connection:Disconnect() end

    local backpack = lp:WaitForChild("Backpack")

    connection = backpack.ChildAdded:Connect(function(tool)
        task.wait(0.1)
        favoriteToolIfMatches(tool)
    end)

    processBackpack() -- Run once on toggle or mutation update
end



-- Auto Claim Premium Seeds Functions
local autoClaimToggle = false
local claimConnection = nil

local function claimPremiumSeed()
    ReplicatedStorage.GameEvents.SeedPackGiverEvent:FireServer("ClaimPremiumPack")
end

local function toggleAutoClaim(newState)
    autoClaimToggle = newState
    if claimConnection then
        claimConnection:Disconnect()
        claimConnection = nil
    end
    if autoClaimToggle then
        claimConnection = RunService.Heartbeat:Connect(function()
            claimPremiumSeed()
            task.wait()
        end)
    end
end

-- Auto Open Crate Functions
local autoSkipEnabled = false

local function toggleAutoSkip()
    autoSkipEnabled = not autoSkipEnabled
    if autoSkipEnabled then
        task.spawn(function()
            local character = lp.Character
            local backpack = lp:FindFirstChild("Backpack")
            local seedTool
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:find("Basic Seed Pack") then
                        seedTool = tool
                        break
                    end
                end
            end
            if seedTool and character then
                seedTool.Parent = character
            end
            
            while autoSkipEnabled do
                local PlayerGui = lp:FindFirstChild("PlayerGui")
                local RollCrate_UI = PlayerGui and PlayerGui:FindFirstChild("RollCrate_UI")
                local character = lp.Character
                local equippedTool = character and character:FindFirstChildOfClass("Tool")
                local holdingSeed = equippedTool and equippedTool.Name:find("Basic Seed Pack")
                
                if RollCrate_UI then
                    if RollCrate_UI.Enabled then
                        local Frame = RollCrate_UI:FindFirstChild("Frame")
                        local Button = Frame and Frame:FindFirstChild("Skip")
                        if Button and Button:IsA("ImageButton") and Button.Visible then
                            GuiService.SelectedObject = Button
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        end
                    elseif holdingSeed then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end

-- Auto Plant Functions
local plantRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Plant_RE")
local AutoPlanting = false
local CurrentlyPlanting = false
local SelectedSeeds = {}

local function getPlayerPosition()
    local char = lp.Character or lp.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    return root and root.Position or Vector3.zero
end

local function getCurrentSeedsInBackpack()
    local result = {}
    for _, tool in ipairs(lp.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local base = tool.Name:match("^(.-) Seed")
            if base and table.find(SelectedSeeds, base) then
                result[#result + 1] = {BaseName = base, Tool = tool}
            end
        end
    end
    return result
end

local function plantEquippedSeed(seedName)
    local pos = getPlayerPosition()
    plantRemote:FireServer(pos, seedName)
end

local function equipTool(tool)
    if not tool or not tool:IsDescendantOf(lp.Backpack) then return end
    
    pcall(function()
        lp.Character.Humanoid:UnequipTools()
        task.wait(0.1)
        tool.Parent = lp.Character
        while not lp.Character:FindFirstChild(tool.Name) do
            task.wait(0.1)
        end
    end)
end

local function startAutoPlanting()
    if CurrentlyPlanting then return end
    CurrentlyPlanting = true
    
    task.spawn(function()
        while AutoPlanting do
            local seeds = getCurrentSeedsInBackpack()
            for _, data in ipairs(seeds) do
                local tool = data.Tool
                local seedName = data.BaseName
                
                if not table.find(SelectedSeeds, seedName) then continue end
                
                if tool and tool:IsA("Tool") and tool:IsDescendantOf(lp.Backpack) then
                    equipTool(tool)
                    task.wait(0.5)
                    
                    while AutoPlanting and lp.Character:FindFirstChild(tool.Name) do
                        if not table.find(SelectedSeeds, seedName) then break end
                        plantEquippedSeed(seedName)
                        task.wait(0.2)
                    end
                end
            end
            task.wait(0.5)
        end
        CurrentlyPlanting = false
    end)
end

-- Destroy Others Farm Function
local function DestoryOthersFarm()
    local farms = workspace:FindFirstChild("Farm")
    if not farms then return end
    
    for _, farm in pairs(farms:GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value ~= lp.Name then
            local plants = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Plants_Physical")
            if plants then
                for _, obj in pairs(plants:GetChildren()) do
                    obj:Destroy()
                end
            end
        end
    end
end




-- Boost FPS
local function BoostFpsv1()
    local decalsyeeted = true
local g = game
local w = g.Workspace
local l = g.Lighting
local t = w.Terrain

pcall(function() sethiddenproperty(l, "Technology", 2) end)
pcall(function() sethiddenproperty(t, "Decoration", false) end)
pcall(function() t.WaterWaveSize = 0 end)
pcall(function() t.WaterWaveSpeed = 0 end)
pcall(function() t.WaterReflectance = 0 end)
pcall(function() t.WaterTransparency = 0 end)
pcall(function() l.GlobalShadows = false end)
pcall(function() l.FogEnd = 9e9 end)
pcall(function() l.Brightness = 0 end)
pcall(function() settings().Rendering.QualityLevel = "Level01" end)

for _, v in pairs(w:GetDescendants()) do
    pcall(function()
        if v:IsA("BasePart") and not v:IsA("MeshPart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        elseif (v:IsA("Decal") or v:IsA("Texture")) and decalsyeeted then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("MeshPart") and decalsyeeted then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.TextureID = "10385902758728957"
        elseif v:IsA("SpecialMesh") and decalsyeeted then
            v.TextureId = ""
        elseif v:IsA("ShirtGraphic") and decalsyeeted then
            v.Graphic = ""
        elseif (v:IsA("Shirt") or v:IsA("Pants")) and decalsyeeted then
            v[v.ClassName.."Template"] = ""
        end
    end)
 end

 for _, e in pairs(l:GetChildren()) do
    pcall(function()
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
            e.Enabled = false
        end
    end)
 end

 w.DescendantAdded:Connect(function(v)
    task.wait()
    pcall(function()
        if v:IsA("BasePart") and not v:IsA("MeshPart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        elseif (v:IsA("Decal") or v:IsA("Texture")) and decalsyeeted then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("MeshPart") and decalsyeeted then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.TextureID = "10385902758728957"
        elseif v:IsA("SpecialMesh") and decalsyeeted then
            v.TextureId = ""
        elseif v:IsA("ShirtGraphic") and decalsyeeted then
            v.Graphic = ""
        elseif (v:IsA("Shirt") or v:IsA("Pants")) and decalsyeeted then
            v[v.ClassName.."Template"] = ""
        end
    end)
 end)
end

-- Black Screen
local blackScreenGui = nil

local function BlackScreen(state)
    if state then
        if not blackScreenGui then
            blackScreenGui = Instance.new("ScreenGui")
            blackScreenGui.Name = "Blackout"
            blackScreenGui.IgnoreGuiInset = true
            blackScreenGui.ResetOnSpawn = false
            blackScreenGui.DisplayOrder = 9999999
            pcall(function() blackScreenGui.Parent = game:GetService("CoreGui") end)

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = Color3.new(0, 0, 0)
            frame.BorderSizePixel = 0
            frame.ZIndex = 9999999
            frame.Parent = blackScreenGui
        end
    else
        if blackScreenGui then
            blackScreenGui:Destroy()
            blackScreenGui = nil
        end
    end
end

-- Pet Freeze
local function PetFreeze()
    local petsFolder = workspace:FindFirstChild("PetsPhysical")
 if petsFolder then
    for _, part in ipairs(petsFolder:GetChildren()) do
        if part:IsA("BasePart") then
            for _, maybeModel in ipairs(part:GetChildren()) do
                if maybeModel:IsA("Model") then
                    local root = maybeModel:FindFirstChild("RootPart")
                    if root and root:IsA("BasePart") then
                        root.Anchored = true
                    end
                end
            end
        end
    end
 end
end


local function Feedback()
    local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1367191105539674153/XWFGMx8pyk4zJGZuzjS4lor4KVVZWDP5Y4VG_GUctj7opsV8cx9VLOffMgOnp72bhWxz"

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


-- New Auto Moonlit
local autoMoon = false

local function AutoGiveFruitMoon(State)
    autoMoon = State

    task.spawn(function()
        while autoMoon do
            local backpack = game:GetService("Players").LocalPlayer.Backpack

            for _, tool in pairs(backpack:GetChildren()) do
                if typeof(tool) == "Instance" and tool:IsA("Tool") and string.find(tool.Name, "%[Moonlit%]") then
                    tool.Parent = game:GetService("Players").LocalPlayer.Character
                    wait(0.5)

                    game:GetService("ReplicatedStorage").GameEvents.NightQuestRemoteEvent:FireServer("SubmitHeldPlant")
                    wait(0.5)
                end
            end

            wait(1)
        end
    end)
end

-- UI Creation
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()
local Window = Luna:CreateWindow({
    Name = "H4xScripts",
    Subtitle = "Grow a Garden",
    LogoID = "82795327169782",
    LoadingEnabled = true,
    LoadingTitle = "Grow A Garden Script",
    LoadingSubtitle = "by H4xScripts",
    ConfigSettings = {
        RootFolder = H4xScripts,
        ConfigFolder = "H4x-GAG"
    }
})
Window:CreateHomeTab({
	SupportedExecutors = {}, 
	DiscordInvite = "TZ93aSb6Ks", 
	Icon = 1, 
})
local Main = Window:CreateTab({Name = "Main", Icon = "view_in_ar", ImageSource = "Material", ShowTitle = false})
local Shop = Window:CreateTab({Name = "Main", Icon = "shopping_cart", ImageSource = "Material", ShowTitle = false})
local PlayerTab = Window:CreateTab({Name = "Players", Icon = "person", ImageSource = "Material", ShowTitle = false})
local Misc = Window:CreateTab({Name = "Miscellaneous", Icon = "list", ImageSource = "Material", ShowTitle = false})
local Visuals = Window:CreateTab({Name = "Visuals", Icon = "visibility", ImageSource = "Material", ShowTitle = false})
local Settings = Window:CreateTab({Name = "Settings", Icon = "settings", ImageSource = "Material", ShowTitle = false})

-- Main Tab
Main:CreateSection("Auto Farm")
Main:CreateLabel({Text = "V2 isFor low level executor But Good for ping High level executor can use it :D", Style = 2})

Main:CreateDropdown({
    Name = "Exclude Mutation",
    Description = "Select Mutation to exclude from farming",
    Options = {"Gold", "Rainbow"},
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(Options)
        excludedVariants = Options
        -- Force update if auto-farm is running
        if autoFarmEnabled then
            updateFarmData()
        end
    end
}, "VariantExclusionDropdown")
Main:CreateToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(state)
        autoFarmEnabled = state
        if autoFarmEnabled then
            instantFarm()
        elseif farmThread then
            task.cancel(farmThread)
            farmThread = nil
        end
    end
},"AutoFarm")

Main:CreateToggle({
    Name = "Auto Collect",
    Default = false,
    Callback = function(state)
        fastClickEnabled = state
        if fastClickEnabled then
            fastClickFarm()
        elseif fastClickThread then
            task.cancel(fastClickThread)
            fastClickThread = nil
        end
    end
},"AutoCollect")

Main:CreateToggle({
    Name = "Auto Farm v2",
    Description = "Make sure you look down! or might not collect sometimes.BAD FOR PACKED AREA!!",
    Default = false,
    Callback = ToggleHarvest
},"AutoFarmv2")


Main:CreateToggle({
    Name = "Auto Collect V2",
    Description = "Automatically collects Fruits near you",
    CurrentValue = false,
    Callback = function(Value)
        spamE = Value
        updateFarmData()
        
        for _, farm in pairs(farms) do
            for _, obj in ipairs(farm:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    handleNewPrompt(obj)
                end
            end
        end
        
        if spamE then
            collectionThread = task.spawn(function()
                while spamE and task.wait(0.1) do
                    if not isInventoryFull() then
                        local plr = game.Players.LocalPlayer
                        local char = plr and plr.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        
                        if root then
                            for prompt, _ in pairs(promptTracker) do
                                if prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt.KeyboardKeyCode == Enum.KeyCode.E then
                                    local targetPos
                                    local parent = prompt.Parent
                                    
                                    if parent:IsA("BasePart") then
                                        targetPos = parent.Position
                                    elseif parent:IsA("Model") and parent:FindFirstChild("HumanoidRootPart") then
                                        targetPos = parent.HumanoidRootPart.Position
                                    end
                                    
                                    -- Skip fruit based on selected mutation
                                    local fruitModel = prompt:FindFirstAncestorOfClass("Model")
                                    local exclude = false
                                    if fruitModel then
                                        for _, desc in ipairs(fruitModel:GetDescendants()) do
                                            if desc:IsA("StringValue") and desc.Name == "Variant" then
                                                if table.find(excludedVariants, desc.Value) then
                                                    exclude = true
                                                    break
                                                end
                                            end
                                        end
                                    end
                                    
                                    -- If fruit is excluded, skip the proximity fire
                                    if exclude then continue end

                                    if targetPos and (root.Position - targetPos).Magnitude <= RANGE then
                                        pcall(function()
                                            fireproximityprompt(prompt, 1, true)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            for prompt, data in pairs(promptTracker) do
                if prompt:IsA("ProximityPrompt") then
                    pcall(function()
                        prompt.RequiresLineOfSight = data.originalRequiresLOS
                        prompt.Exclusivity = data.originalExclusivity
                    end)
                end
            end
            
            if collectionThread then
                task.cancel(collectionThread)
                collectionThread = nil
            end
        end
    end
}, "AutoCollectV2")

descendantConnection = workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") and isInsideFarm(obj) then
        handleNewPrompt(obj)
    end
end)

for _, farm in pairs(farms) do
    for _, obj in ipairs(farm:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            handleNewPrompt(obj)
        end
    end
end

local function cleanup()
    if descendantConnection then
        descendantConnection:Disconnect()
    end
    if collectionThread then
        task.cancel(collectionThread)
    end
    for prompt, data in pairs(promptTracker) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                prompt.RequiresLineOfSight = data.originalRequiresLOS
                prompt.Exclusivity = data.originalExclusivity
            end)
        end
    end
end

Main:CreateSection("Auto Sell")

Main:CreateToggle({
    Name = "Auto Sell",
    Description = "",
    CurrentValue = false,
    Callback = function(Value)
        autoSellEnabled = Value
        if autoSellEnabled then
            autoSellThread = task.spawn(function()
                while autoSellEnabled and task.wait(1) do
                    if isInventoryFull() then
                        sellItems()
                    end
                end
            end)
        elseif autoSellThread then
            task.cancel(autoSellThread)
        end
    end
},"AutoSell")

Main:CreateButton({
    Name = "Sell All",
    Callback = SellAll
})
Main:CreateSlider({ 
    Name = "Sell Threshold", 
    Range = {0, 200},
    Increment = 5, 
    CurrentValue = 200,
    Callback = function(Value)
        sellThreshold = Value
    end
}, "SellAmmount")
Main:CreateSection("Others")

Main:CreateToggle({
    Name = "Anti-Afk",
    Description = "",
    CurrentValue = true,
    Callback = AntiAfk
},"AntiAfk")

Main:CreateToggle({
    Name = "One Click Plant Remove",
    Description = "Be Carefull | Hope u dont delete something you needed!",
    CurrentValue = false,
    Callback = OneClickRemove
},"OCPR")

Main:CreateButton({
    Name = "Stops Grow-ALL pop-up",
    Description = "",
    Callback = DestroySign
},"SGP")

-- Shop Tab
Shop:CreateSection("Auto Buy")
Shop:CreateDropdown({
    Name = "Select Seeds",
    Description = "Choose which seeds to auto buy",
    Options = seedItems,
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(Options)
        selectedSeeds = Options
    end
},"AutoBuySeds")

Shop:CreateDropdown({
    Name = "Select Gear",
    Description = "Choose which gear to auto buy",
    Options = gearItems,
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(Options)
        selectedGears = Options
    end
},"AUtoBuyGears")


local selectedEggs = {}
local autoBuyEnabled = false


local function isEggAvailable(eggName)
    local petStand = workspace.NPCS:FindFirstChild("Pet Stand")
    if not petStand then return false end
    local eggLocations = petStand:FindFirstChild("EggLocations")
    if not eggLocations then return false end
    
    return eggLocations:FindFirstChild(eggName) ~= nil
end

local function attemptBuyEggs()
    if not autoBuyEnabled then return end
    
    for _, eggName in ipairs(selectedEggs) do
        if isEggAvailable(eggName) then

            for slot = 1, 3 do
                game:GetService("ReplicatedStorage").GameEvents.BuyPetEgg:FireServer(slot)
                task.wait(0.5) 
            end
            break 
        end
    end
end

-- Create the dropdown for egg selection
local Dropdown = Shop:CreateDropdown({
    Name = "Select Egg ",
    Description = "Choose which egg to auto buy",
    Options = {
        "Common Egg",
        "Uncommon Egg", 
        "Rare Egg",
        "Legendary Egg",
        "Bug Egg"
    },
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(Options)
        selectedEggs = Options
        for i, egg in ipairs(selectedEggs) do
        end
    end
}, "EggDropdown")
Shop:CreateToggle({
    Name = "Auto Buy",
    DefaultValue = false,
    Callback = function(Value)
        autoBuyEnabled = Value
    end
},"AutoBuyShops")

-- Create the auto-buy toggle
local Toggle = Shop:CreateToggle({
    Name = "Auto-Buy Eggs",
    Description = "Um guys all in stock when selected is there",
    CurrentValue = false,
    Callback = function(Value)
        autoBuyEnabled = Value
        
        if autoBuyEnabled then
            coroutine.wrap(function()
                while autoBuyEnabled do
                    attemptBuyEggs()
                    task.wait(1) -- Check every second
                end
            end)()
        end
    end
}, "AutoBuyEggs")

Shop:CreateSection("InstaSell")
Shop:CreateButton({
    Name = "Insta Sell",
    Description = "",
    Callback = SellAll
})

Shop:CreateButton({
    Name = "Insta Sell Hand",
    Description = "",
    Callback = HSell
})

Shop:CreateSection("Menus")
Shop:CreateButton({
    Name = "Open Egg shop1",
    Description = "Click Again to close",
    Callback = EggShop1
})
Shop:CreateButton({
    Name = "Open Egg shop2",
    Description = "Click Again to close",
    Callback = EggShop2
})
Shop:CreateButton({
    Name = "Open Egg shop3",
    Description = "Click Again to close",
    Callback = EggShop3
})
Shop:CreateButton({
    Name = "Open Shop",
    Description = "Click Again to close",
    Callback = OpenShop
})

Shop:CreateButton({
    Name = "Open Gear",
    Description = "Click Again to close",
    Callback = OpenGearShop
})

Shop:CreateButton({
    Name = "Open Quest",
    Description = "Click Again to close",
    Callback = OpenQuest
})


-- Player Tab
PlayerTab:CreateSection("Movement")
PlayerTab:CreateToggle({
    Name = "Fly",
    DefaultValue = false,
    Callback = Fly
},"AutoFly")

PlayerTab:CreateToggle({
    Name = "No Clip",
    DefaultValue = false,
    Callback = ToggleNoclip
},"NoClip")

PlayerTab:CreateToggle({
    Name = "Inf Jump",
    DefaultValue = false,
    Callback = ToggleInfJump
},"INfJUMP")

PlayerTab:CreateSlider({
    Name = "Player Speed",
    Range = {0, 200},
    Increment = 4,
    CurrentValue = 16,
    Callback = function(value)
        local char = lp.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = value
        end
    end
},"PlrSPeed")

PlayerTab:CreateSlider({
    Name = "Jump Height",
    Range = {0, 200},
    Increment = 10,
    CurrentValue = 50,
    Callback = function(value)
        local char = lp.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").JumpPower = value
        end
    end
},"JumpHeigh")

-- Misc Tab
Misc:CreateSection("Extras")
Misc:CreateToggle({
    Name = "Buy Banana",
    Description = "It cost 850k!!!Wait For Stock Reset!",
    DefaultValue = false,
    Callback = function(state)
        BAnanaDupeE = state
        if state then
            DupeBanana()
        end
    end
},"BAnananana")
Misc:CreateToggle({
    Name = "One Click Plant Remove",
    Description = "Be Carefull | Hope u dont delete something you needed!",
    CurrentValue = false,
    Callback = OneClickRemove
},"OCPR")

Misc:CreateSection("Auto Fav")

Misc:CreateDropdown({
    Name = "Select Mutations",
    Options = mutationOptions,
    CurrentOption = selectedMutations,
    MultipleOptions = true,
    Callback = function(Options)
        selectedMutations = Options
        if autoFavoriteEnabled then
            processBackpack() -- Apply favorite when mutation changes
        end
    end
}, "MutationDropdown")

Misc:CreateToggle({
    Name = "Auto-Favorite",
    CurrentValue = false,
    Callback = function(Value)
        autoFavoriteEnabled = Value
        if Value then
            setupAutoFavorite()
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end
}, "AutoFavoriteToggle")


Misc:CreateSection("Events")

Misc:CreateToggle({
    Name = "Auto Summit Plant",
    Description = "Automatically claims premium seeds when avaiable",
    Default = false,
    Callback = AutoGiveFruitMoon
},"ACPS")

Misc:CreateToggle({
    Name = "Insta Open Crate ( Basic )",
    Description = "Auto opens and skips seeds",
    Default = false,
    Callback = toggleAutoSkip
},"IOC")

Misc:CreateSection("Plants")
Misc:CreateDropdown({
    Name = "Select Seeds to Plant",
    Description = "Seeds to plant",
    Options = seedNames,
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(opts)
        SelectedSeeds = opts
    end
}, "SSTP")

Misc:CreateToggle({
    Name = "Auto Plant",
    Description = "Fly and No clip recommended so you won't be glitched by growing crops",
    DefaultValue = false,
    Callback = function(state)
        AutoPlanting = state
        if state then
            startAutoPlanting()
        end
    end
}, "AutoPlant")

Misc:CreateButton({
    Name = "Feedback",
    Description = "You can use this to send feedback or request adding new features.",
    Callback = Feedback
})
Misc:CreateSection("Trading")
Misc:CreateSection("Will come back soon pls wait!:3")

-- Visuals Tab
Visuals:CreateSection("Visuals")
Visuals:CreateButton({
    Name = "Freeze Pet",
    Description = "Easy to feed",
    Callback = PetFreeze
})
Visuals:CreateButton({
    Name = "Remove Others Plants",
    Description = "Removes everyone plants excepts for yours",
    Callback = DestoryOthersFarm
})
Visuals:CreateButton({
    Name = "Boost Fps",
    Description = "idk",
    Callback = BoostFpsv1
})
Visuals:CreateToggle({
    Name = "Black Screen",
    Description = "",
    CurrentValue = false,
    Callback = BlackScreen
},"BlackScren")
Visuals:CreateInput({
    Name = "Fake Money",
    Description = nil,
    PlaceholderText = "Enter Amount",
    CurrentValue = "",
    Numeric = true,
    MaxCharacters = nil,
    Enter = false,
    Callback = function(value)
        local amount = tonumber(value)
        if not amount then return end
        
        if lp and lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Sheckles") then
            lp.leaderstats.Sheckles.Value = amount
        end
        
        local function formatCommas(n)
            local negative = n < 0
            n = tostring(math.abs(n))
            local left, num, right = string.match(n, "^([^%d]*%d)(%d*)(.-)$")
            local formatted = left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
            return (negative and "-" or "") .. formatted .. "¢"
        end
        
        local function shortenNumber(n)
            local scales = {
                {1000000000000000000, "Qi"},
                {999999986991104, "Qa"},
                {999999995904, "T"},
                {1000000000, "B"},
                {1000000, "M"},
                {1000, "K"}
            }
            local negative = n < 0
            n = math.abs(n)
            if n < 1000 then
                return (negative and "-" or "") .. tostring(math.floor(n))
            end
            
            for i = 1, #scales do
                local scale, label = scales[i][1], scales[i][2]
                if n >= scale then
                    local value = n / scale
                    if value % 1 == 0 then
                        return (negative and "-" or "") .. string.format("%.0f%s", value, label)
                    else
                        return (negative and "-" or "") .. string.format("%.2f%s", value, label)
                    end
                end
            end
            return (negative and "-" or "") .. tostring(n)
        end
        
        local formattedDealer = formatCommas(amount)
        local formattedBoard = shortenNumber(amount)
        
        local shecklesUI = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Sheckles_UI")
        if shecklesUI and shecklesUI:FindFirstChild("TextLabel") then
            shecklesUI.TextLabel.Text = formattedDealer
        end
        
        local dealerBoard = workspace:FindFirstChild("DealerBoard")
        if dealerBoard and dealerBoard:FindFirstChild("BillboardGui") and dealerBoard.BillboardGui:FindFirstChild("TextLabel") then
            dealerBoard.BillboardGui.TextLabel.Text = formattedBoard
        end
    end
})

-- Auto Buy Logic
local function getItemPrice(path, item)
    local container = path:FindFirstChild(item)
    if not container then return math.huge end
    
    local frame = container:FindFirstChild("Frame")
    if not frame then return math.huge end
    
    local buyBtn = frame:FindFirstChild("Sheckles_Buy")
    if not buyBtn then return math.huge end
    
    local inStock = buyBtn:FindFirstChild("In_Stock")
    if not inStock then return math.huge end
    
    local costText = inStock:FindFirstChild("Cost_Text")
    if not costText or not costText.Text then return math.huge end
    
    return parseMoney(costText.Text)
end

local function tryPurchase(path, remote, item)
    local itemPrice = getItemPrice(path, item)
    local playerMoney = getPlayerMoney()
    
    if playerMoney >= itemPrice then
        local container = path:FindFirstChild(item)
        if container and container:FindFirstChild("Frame") then
            local buyBtn = container.Frame:FindFirstChild("Sheckles_Buy")
            if buyBtn and buyBtn:FindFirstChild("In_Stock") and buyBtn.In_Stock.Visible then
                remote:FireServer(item)
                return true
            end
        end
    end
    return false
end

task.spawn(function()
    while task.wait(0.5) do
        if autoBuyEnabled then
            for _, seed in ipairs(selectedSeeds) do
                tryPurchase(seedPath, seedRemote, seed)
            end
            for _, gear in ipairs(selectedGears) do
                tryPurchase(gearPath, gearRemote, gear)
            end
        end
    end
end)

Window:CreateHomeTab({
	SupportedExecutors = {}, 
	DiscordInvite = "TZ93aSb6Ks", 
	Icon = 1, 
})
Settings:CreateLabel({
	Text = "Callback error? Join DC (Eeven if callback error it works)",
	Style = 3 -- Luna Labels Have 3 Styles : A Basic Label, A Green Information Label and A Red Warning Label. Look At The Following Image For More Details
})
Settings:CreateLabel({
	Text = "Dropdowns might not show selected but it works!",
	Style = 2 -- Luna Labels Have 3 Styles : A Basic Label, A Green Information Label and A Red Warning Label. Look At The Following Image For More Details
})

Settings:BuildConfigSection()
end

local function loadPastebinKeys()
    local req = (syn and syn.request) or http_request or request or (fluxus and fluxus.request)
    if req then
        local success, r = pcall(req, {Url = "https://pastebin.com/raw/HEjUie8h", Method = "GET"})
        if success and r and r.Body then
            local keys = {}
            for line in r.Body:gmatch("[^\r\n]+") do
                if line ~= "" then
                    table.insert(keys, line)
                end
            end
            return keys
        end
    end
    return {}
end

local function showWarningGui()
    local player = game:GetService("Players").LocalPlayer
    local guiParent = player:WaitForChild("PlayerGui")
    local old = guiParent:FindFirstChild("KeyBypassWarning")
    if old then old:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeyBypassWarning"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = guiParent
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.05
    frame.Parent = gui
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50))
    })
    gradient.Rotation = 45
    gradient.Parent = frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = frame
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = 0
    shadow.Parent = frame
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -30, 0.4, -20)
    text.Position = UDim2.new(0, 15, 0, 15)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 26
    text.TextWrapped = true
    text.Text = "⚠️ Unauthorized Access or Invalid Visit Type!\nPlease join our Discord for support."
    text.Parent = frame
    local discordContainer = Instance.new("Frame")
    discordContainer.Size = UDim2.new(1, -30, 0, 100)
    discordContainer.Position = UDim2.new(0, 15, 0.45, 0)
    discordContainer.BackgroundTransparency = 1
    discordContainer.Parent = frame
    local function AddDiscordInvite(Configs)
        local Title = Configs[1] or Configs.Name or Configs.Title or "Discord"
        local Desc = Configs.Desc or Configs.Description or ""
        local Logo = Configs[2] or Configs.Logo or "rbxassetid://10723408303"
        local Invite = Configs[3] or Configs.Invite or ""
        local InviteHolder = Instance.new("Frame")
        InviteHolder.Size = UDim2.new(1, 0, 0, 80)
        InviteHolder.Name = "Option"
        InviteHolder.BackgroundTransparency = 1
        InviteHolder.Position = UDim2.new(0, 0, 0, 0)
        InviteHolder.Parent = discordContainer
        local InviteLabel = Instance.new("TextLabel")
        InviteLabel.Size = UDim2.new(1, 0, 0, 15)
        InviteLabel.Position = UDim2.new(0, 5, 0, 0)
        InviteLabel.TextColor3 = Color3.fromRGB(88, 101, 242)
        InviteLabel.Font = Enum.Font.GothamBold
        InviteLabel.TextXAlignment = Enum.TextXAlignment.Left
        InviteLabel.BackgroundTransparency = 1
        InviteLabel.TextSize = 12
        InviteLabel.Text = Invite
        InviteLabel.Parent = InviteHolder
        local FrameHolder = Instance.new("Frame")
        FrameHolder.Size = UDim2.new(1, 0, 0, 65)
        FrameHolder.AnchorPoint = Vector2.new(0, 1)
        FrameHolder.Position = UDim2.new(0, 0, 1, 0)
        FrameHolder.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        FrameHolder.Parent = InviteHolder
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 10)
        buttonCorner.Parent = FrameHolder
        local ImageLabel = Instance.new("ImageLabel")
        ImageLabel.Size = UDim2.new(0, 36, 0, 36)
        ImageLabel.Position = UDim2.new(0, 10, 0, 10)
        ImageLabel.Image = Logo
        ImageLabel.BackgroundTransparency = 1
        ImageLabel.Parent = FrameHolder
        local imageCorner = Instance.new("UICorner")
        imageCorner.CornerRadius = UDim.new(0, 8)
        imageCorner.Parent = ImageLabel
        local LTitle = Instance.new("TextLabel")
        LTitle.Size = UDim2.new(1, -60, 0, 18)
        LTitle.Position = UDim2.new(0, 50, 0, 10)
        LTitle.Font = Enum.Font.GothamBold
        LTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        LTitle.TextXAlignment = Enum.TextXAlignment.Left
        LTitle.BackgroundTransparency = 1
        LTitle.TextSize = 14
        LTitle.Text = Title
        LTitle.Parent = FrameHolder
        local LDesc = Instance.new("TextLabel")
        LDesc.Size = UDim2.new(1, -60, 0, 0)
        LDesc.Position = UDim2.new(0, 50, 0, 28)
        LDesc.TextWrapped = true
        LDesc.AutomaticSize = Enum.AutomaticSize.Y
        LDesc.Font = Enum.Font.Gotham
        LDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
        LDesc.TextXAlignment = Enum.TextXAlignment.Left
        LDesc.BackgroundTransparency = 1
        LDesc.TextSize = 10
        LDesc.Text = Desc
        LDesc.Parent = FrameHolder
        local JoinButton = Instance.new("TextButton")
        JoinButton.Size = UDim2.new(0, 100, 0, 36)
        JoinButton.Position = UDim2.new(1, -10, 1, -10)
        JoinButton.Text = "Join"
        JoinButton.Font = Enum.Font.GothamBlack
        JoinButton.TextSize = 14
        JoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        JoinButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        JoinButton.AnchorPoint = Vector2.new(1, 1)
        JoinButton.Parent = FrameHolder
        local buttonCorner2 = Instance.new("UICorner")
        buttonCorner2.CornerRadius = UDim.new(0, 8)
        buttonCorner2.Parent = JoinButton
        local ClickDelay
        JoinButton.Activated:Connect(function()
            setclipboard(Invite)
            if ClickDelay then return end
            ClickDelay = true
            JoinButton.Text = "Copied!"
            JoinButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
            JoinButton.TextColor3 = Color3.fromRGB(180, 180, 180)
            task.wait(5)
            JoinButton.Text = "Join"
            JoinButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
            JoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ClickDelay = false
        end)
    end
    AddDiscordInvite({
        Title = "Join Our Discord",
        Desc = "For updates and support",
        Logo = "rbxassetid://10723408303",
        Invite = "https://discord.gg/AHKgTA7NEd"
    })
    local TweenService = game:GetService("TweenService")
    local openTween = TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 550, 0, 320)
    })
    openTween:Play()
    task.delay(7.5, function()
        local closeTween = TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        closeTween:Play()
        task.wait(0.6)
        gui:Destroy()
    end)
end

if key then
    local pastebinKeys = loadPastebinKeys()
    local isValidKey = false
    for _, validKey in ipairs(pastebinKeys) do
        if key == validKey then
            isValidKey = true
            break
        end
    end
    if isValidKey then
        _G.H4xScriptKeySystem = ""
        LoadScript()
    else
        local req = (syn and syn.request) or http_request or request or (fluxus and fluxus.request)
        if req then
            local success, r = pcall(req, {Url = "https://work.ink/_api/v2/token/isValid/" .. key, Method = "GET"})
            if success and r and r.Body then
                local decodeSuccess, data = pcall(HttpService.JSONDecode, HttpService, r.Body)
                if decodeSuccess and data and data.valid then
                    _G.H4xScriptKeySystem = ""
                    LoadScript()
                else
                    showWarningGui()
                end
            else
                showWarningGui()
            end
        else
            showWarningGui()
        end
    end
else
    showWarningGui()
end
