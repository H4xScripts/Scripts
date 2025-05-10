local HttpService = game:GetService("HttpService")
local key = _G.H4xScriptKeySystem
local function LoadScript()
    print("LOL")
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
            local r = req({Url = "https://work.ink/_api/v2/token/isValid/" .. key, Method = "GET"})
            if r and r.Body then
                local data = HttpService:JSONDecode(r.Body)
                if data and data.valid then
                    _G.H4xScriptKeySystem = ""
                    LoadScript()
                end
            end
        end
    end
else
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
