-- Auto Block V6 - Converted to WindUI
-- Original script from discord.gg/25ms
-- Converted to use WindUI library (https://footagesus.github.io/WindUI-Docs)

-- Load WindUI library (latest version)
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create main window
local Window = WindUI:CreateWindow({
    Title = "Auto Block ThanhDuyHub V1",
    Subtitle = "by ThanhDuy",
    Logo = "rbxassetid://4483362458",
    Theme = "Default",
    Size = UDim2.new(0, 550, 0, 400),
    MinimizeKey = Enum.KeyCode.K
})

-- Notify
WindUI:Notify({
    Title = "Hello",
    Description = "Welcome To Auto Block V6",
    Duration = 1.5,
    Icon = "rbxassetid://4483362458"
})

local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local ipairs = ipairs
local animationsList = {
    "10468665991", "10466974800", "10471336737", "12510170988", "12272894215",
    "12296882427", "12307656616", "101588604872680", "105442749844047",
    "109617620932970", "131820095363270", "135289891173395", "125955606488863",
    "12534735382", "12502664044", "12509505723", "12618271998", "12684390285",
    "13376869471", "13294790250", "13376962659", "13501296372", "13556985475",
    "145162735010", "14046756619", "14299135500", "14351441234", "15290930205",
    "15145462680", "15295895753", "15295336270", "16139108718", "16515850153",
    "16431491215", "16597322398", "16597912086", "17799224866", "17838006839",
    "17857788598", "18179181663", "113166426814229", "116753755471636",
    "116153572280464", "114095570398448", "77509627104305", "113166426814229",
    "116153572280464", "77509627104305", "71852503410610", "91353107056596"
}

local skillAnimations = {}
for _, id in ipairs(animationsList) do
    skillAnimations[id] = true
end

local dashAnimations = {
    ["10469493270"] = true, ["10469630950"] = true, ["10469639222"] = true,
    ["10469643643"] = true, ["13532562418"] = true, ["13532600125"] = true,
    ["13532604085"] = true, ["13294471966"] = true, ["13491635433"] = true,
    ["13296577783"] = true, ["13295919399"] = true, ["13295936866"] = true,
    ["13370310513"] = true, ["13390230973"] = true, ["13378751717"] = true,
    ["13378708199"] = true, ["14004222985"] = true, ["13997092940"] = true,
    ["14001963401"] = true, ["14136436157"] = true, ["15271263467"] = true,
    ["15240216931"] = true, ["15240176873"] = true, ["15162694192"] = true,
    ["16515503507"] = true, ["16515520431"] = true, ["16515448089"] = true,
    ["16552234590"] = true, ["17889458563"] = true, ["17889461810"] = true,
    ["17889471098"] = true, ["17889290569"] = true, ["123005629431309"] = true,
    ["100059874351664"] = true, ["104895379416342"] = true, ["134775406437626"] = true,
    ["15259161390"] = true
}

local m1Animations = {
    ["10479335397"] = true, ["13380255751"] = true
}

local isAutoBlockEnabled = false
local isM1AfterBlock = false
local m1Range = 15
local dashRange = 25
local skillRange = 30
local blockedPlayers = {}
local blockConnection = nil

-- Helper functions
local function isFacingTarget(targetPos)
    local character = player.Character
    if not (character and character:FindFirstChild("HumanoidRootPart")) then
        return false
    end
    local rootPart = character.HumanoidRootPart
    local direction = (targetPos - rootPart.Position).Unit
    return rootPart.CFrame.LookVector:Dot(direction) > 0
end

local function pressF(delayTime)
    local communicate = player.Character:WaitForChild("Communicate")
    communicate:FireServer(unpack({{Goal = "KeyPress", Key = Enum.KeyCode.F}}))
    task.wait(delayTime)
    communicate:FireServer(unpack({{Goal = "KeyRelease", Key = Enum.KeyCode.F}}))
    
    if isM1AfterBlock and delayTime <= 0.15 then
        communicate:FireServer(unpack({{Goal = "LeftClick", Mobile = true}}))
        task.wait(0.3)
        communicate:FireServer(unpack({{Goal = "LeftClickRelease", Mobile = true}}))
    end
end

local function releaseKeys()
    for _ = 1, 5 do
        player.Character.Communicate:FireServer({{Goal = "KeyRelease", Key = Enum.KeyCode.F}})
        player.Character.Communicate:FireServer({{Goal = "LeftClickRelease", Mobile = true}})
        task.wait(0.1)
    end
end

-- Main block function
local function startAutoBlock()
    if blockConnection then blockConnection:Disconnect() end
    
    blockConnection = runService.Heartbeat:Connect(function()
        local character = player.Character
        if not (character and character:FindFirstChild("HumanoidRootPart")) then
            return
        end
        
        local playerPos = character.HumanoidRootPart.Position
        local live = workspace:FindFirstChild("Live")
        if not live then return end
        
        for _, model in ipairs(live:GetChildren()) do
            if model:IsA("Model") and model ~= character then
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                local rootPart = model:FindFirstChild("HumanoidRootPart")
                
                if humanoid and rootPart and humanoid:FindFirstChild("Animator") then
                    local distance = (rootPart.Position - playerPos).Magnitude
                    
                    if isFacingTarget(rootPart.Position) then
                        local animator = humanoid.Animator
                        local playingTracks = animator:GetPlayingAnimationTracks()
                        local isBlocked = false
                        
                        for _, track in ipairs(playingTracks) do
                            local animId = track.Animation.AnimationId:match("%d+")
                            if animId then
                                if dashAnimations[animId] and distance <= dashRange then
                                    pressF(0.37)
                                    isBlocked = true
                                    break
                                elseif m1Animations[animId] and distance <= m1Range then
                                    pressF(0.15)
                                    isBlocked = true
                                    break
                                elseif skillAnimations[animId] and distance <= skillRange then
                                    pressF(1.1)
                                    isBlocked = true
                                    break
                                end
                            end
                        end
                        
                        if not isBlocked and blockedPlayers[model] then
                            releaseKeys()
                            blockedPlayers[model] = nil
                        elseif isBlocked then
                            blockedPlayers[model] = true
                        end
                    end
                end
            end
        end
    end)
end

local function stopAutoBlock()
    if blockConnection then
        blockConnection:Disconnect()
        blockConnection = nil
    end
end

-- Create tabs
local autoBlockTab = Window:CreateTab({Title = "Auto Block", Icon = "rbxassetid://4483362458"})

-- Toggle for Auto Block
autoBlockTab:CreateToggle({
    Title = "Auto Block",
    Description = "Automatically block enemy attacks",
    Default = false,
    Callback = function(state)
        isAutoBlockEnabled = state
        if isAutoBlockEnabled then
            startAutoBlock()
        else
            stopAutoBlock()
        end
    end
})

-- Toggle for M1 After Block
autoBlockTab:CreateToggle({
    Title = "M1 After Block",
    Description = "Perform M1 attack after blocking",
    Default = false,
    Callback = function(state)
        isM1AfterBlock = state
    end
})

-- Input for M1 Range
autoBlockTab:CreateSlider({
    Title = "M1 Attack Range",
    Description = "Range to block M1 attacks",
    Min = 5,
    Max = 30,
    Default = m1Range,
    Suffix = "studs",
    Callback = function(value)
        m1Range = value
    end
})

-- Input for Dash Range
autoBlockTab:CreateSlider({
    Title = "Dash Attack Range",
    Description = "Range to block dash attacks",
    Min = 10,
    Max = 40,
    Default = dashRange,
    Suffix = "studs",
    Callback = function(value)
        dashRange = value
    end
})

-- Input for Skill Range
autoBlockTab:CreateSlider({
    Title = "Skill Range",
    Description = "Range to block skill attacks",
    Min = 10,
    Max = 50,
    Default = skillRange,
    Suffix = "studs",
    Callback = function(value)
        skillRange = value
    end
})

-- Reset Button
autoBlockTab:CreateButton({
    Title = "Reset Ranges to Default",
    Description = "Reset all range values to default",
    Callback = function()
        skillRange = 30
        dashRange = 25
        m1Range = 15
        WindUI:Notify({
            Title = "Reset Complete",
            Description = "Ranges reset to M1=15, Dash=25, Skill=30",
            Duration = 2
        })
    end
})

-- Camlock tab
local camlockTab = Window:CreateTab({Title = "Camlock", Icon = "rbxassetid://4483362458"})

local camlockEnabled = false
local currentTarget = nil
local camlockRange = 1000
local camera = workspace.CurrentCamera

-- Create draggable UI for camlock toggle
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "CamlockGui"
local camlockButton = Instance.new("TextButton", screenGui)
camlockButton.Size = UDim2.new(0, 140, 0, 45)
camlockButton.Position = UDim2.new(0.02, 0, 0.1, 0)
camlockButton.Text = "Camlock OFF"
camlockButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
camlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
camlockButton.Font = Enum.Font.GothamBold
camlockButton.TextSize = 18
camlockButton.Active = true
camlockButton.Draggable = true
camlockButton.AutoButtonColor = false
camlockButton.BorderSizePixel = 0
Instance.new("UICorner", camlockButton).CornerRadius = UDim.new(0, 10)

local function updateButtonStyle(isHovered)
    if isHovered then
        camlockButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    elseif camlockEnabled then
        camlockButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        camlockButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    end
end

camlockButton.MouseEnter:Connect(function() updateButtonStyle(true) end)
camlockButton.MouseLeave:Connect(function() updateButtonStyle(false) end)

local function findBestTarget()
    local character = player.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local lookVector = camera.CFrame.LookVector
    local closestDistance = math.huge
    local bestByAngle = nil
    local bestByDistance = nil
    local bestAngle = -1
    
    local targets = {}
    
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Parent.Name == "Live" then
            table.insert(targets, plr.Character)
        end
    end
    
    for _, model in ipairs(workspace.Live:GetChildren()) do
        if model:IsA("Model") and model.Name == "Weakest Dummy" and model:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, model)
        end
    end
    
    for _, target in ipairs(targets) do
        local targetRoot = target.HumanoidRootPart
        local distance = (rootPart.Position - targetRoot.Position).Magnitude
        if distance <= camlockRange then
            local direction = (targetRoot.Position - camera.CFrame.Position).Unit
            local dot = direction:Dot(lookVector)
            if dot > 0.5 then
                if dot > bestAngle then
                    bestByAngle = target
                    bestAngle = dot
                end
            end
            if distance < closestDistance then
                bestByDistance = target
                closestDistance = distance
            end
        end
    end
    
    return bestByAngle or bestByDistance
end

runService.Heartbeat:Connect(function()
    if camlockEnabled then
        if not (currentTarget and currentTarget.Parent and currentTarget:FindFirstChild("HumanoidRootPart")) then
            currentTarget = findBestTarget()
        end
        if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
            local targetRoot = currentTarget.HumanoidRootPart
            local targetPos = targetRoot.Position + targetRoot.Velocity * 0.05
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
        end
    end
end)

camlockTab:CreateToggle({
    Title = "Show Camlock Button",
    Description = "Show/Hide the camlock toggle button",
    Default = false,
    Callback = function(state)
        screenGui.Enabled = state
    end
})

camlockButton.MouseButton1Click:Connect(function()
    camlockEnabled = not camlockEnabled
    camlockButton.Text = camlockEnabled and "Camlock ON" or "Camlock OFF"
    if camlockEnabled then
        camlockButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        camlockButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        currentTarget = nil
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            camera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
        end
    end
end)

-- Camlock + Silent Aim
local silentAimEnabled = false
local silentTarget = nil
local silentRange = 1000
local silentGui = Instance.new("ScreenGui")
silentGui.Name = "SilentAimGui"
silentGui.Parent = game.CoreGui
silentGui.Enabled = false

local silentButton = Instance.new("TextButton", silentGui)
silentButton.Size = UDim2.new(0, 150, 0, 40)
silentButton.Position = UDim2.new(0.4, 0, 0.85, 0)
silentButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
silentButton.TextColor3 = Color3.new(1, 1, 1)
silentButton.Text = "Cam + Silent OFF"
silentButton.Font = Enum.Font.GothamBold
silentButton.Active = true
silentButton.Draggable = true
silentButton.TextSize = 18
silentButton.TextScaled = true
Instance.new("UICorner", silentButton).CornerRadius = UDim.new(0, 12)

local function findNearestTarget()
    local character = player.Character
    if not (character and character:FindFirstChild("HumanoidRootPart")) then
        return nil
    end
    local rootPart = character.HumanoidRootPart
    local nearest = nil
    local nearestDist = silentRange
    
    local live = workspace:FindFirstChild("Live")
    if not live then return nil end
    
    for _, model in ipairs(live:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model ~= character then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and (model.Name == "Weakest Dummy" or game.Players:GetPlayerFromCharacter(model)) then
                local dist = (model.HumanoidRootPart.Position - rootPart.Position).Magnitude
                if dist < nearestDist then
                    nearest = model
                    nearestDist = dist
                end
            end
        end
    end
    return nearest
end

silentButton.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    if silentAimEnabled then
        silentButton.Text = "Cam + Silent ON"
        silentButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    else
        silentButton.Text = "Cam + Silent OFF"
        silentButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        silentTarget = nil
    end
end)

runService.RenderStepped:Connect(function()
    if silentAimEnabled then
        if not (silentTarget and silentTarget:FindFirstChild("HumanoidRootPart")) then
            silentTarget = findNearestTarget()
        end
        if silentTarget and silentTarget:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and not character:FindFirstChild("Ragdoll") then
                local rootPart = character.HumanoidRootPart
                local targetPos = silentTarget.HumanoidRootPart.Position
                camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
                local lookPos = Vector3.new(targetPos.X, rootPart.Position.Y, targetPos.Z)
                rootPart.CFrame = CFrame.new(rootPart.Position, lookPos)
            end
        end
    end
end)

camlockTab:CreateToggle({
    Title = "Camlock + Silent Aim",
    Description = "Enables camlock with silent aim",
    Default = false,
    Callback = function(state)
        silentGui.Enabled = state
        if not state then
            silentAimEnabled = false
            silentTarget = nil
            silentButton.Text = "Cam + Silent OFF"
            silentButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        end
    end
})

-- Misc tab
local miscTab = Window:CreateTab({Title = "Misc", Icon = "rbxassetid://4483362458"})

-- No Dash Cooldown
miscTab:CreateToggle({
    Title = "No Dash Cooldown",
    Description = "Remove dash cooldown (VIP Server feature)",
    Default = false,
    Callback = function(state)
        if state then
            workspace:SetAttribute("VIPServer", tostring(player.UserId))
            workspace:SetAttribute("VIPServerOwner", player.Name)
            workspace:SetAttribute("NoDashCooldown", true)
        else
            workspace:SetAttribute("NoDashCooldown", false)
        end
    end
})

-- Death Counter Indicator
local deathIndicatorEnabled = false
local alertGui = Instance.new("ScreenGui", game.CoreGui)
alertGui.Name = "AlertNotify"
local alertLabel = Instance.new("TextLabel", alertGui)
alertLabel.Size = UDim2.new(0.4, 0, 0.08, 0)
alertLabel.Position = UDim2.new(0.5, 0, 0.03, 0)
alertLabel.AnchorPoint = Vector2.new(0.5, 0)
alertLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
alertLabel.BackgroundTransparency = 0.2
alertLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
alertLabel.Font = Enum.Font.Gotham
alertLabel.TextSize = 20
alertLabel.Text = ""
alertLabel.Visible = false
alertLabel.BorderSizePixel = 0
alertLabel.TextWrapped = true

local deathTracked = {}
local live = workspace:WaitForChild("Live")

local function showNotification(msg, color)
    if not deathIndicatorEnabled then return end
    alertLabel.Text = msg
    alertLabel.TextColor3 = color or Color3.new(1, 1, 1)
    alertLabel.Visible = true
    task.delay(2.5, function()
        alertLabel.Visible = false
    end)
end

local function addHighlight(model, colorType)
    if not deathIndicatorEnabled then return end
    local existing = model:FindFirstChild("AlertHighlight")
    if existing then existing:Destroy() end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "AlertHighlight"
    highlight.FillTransparency = 0.25
    highlight.OutlineTransparency = 0
    highlight.Adornee = model
    
    if colorType == "blue" then
        highlight.FillColor = Color3.fromRGB(0, 200, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    elseif colorType == "red" then
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
    end
    
    highlight.Parent = model
    
    if colorType == "red" then
        task.delay(11, function()
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
        end)
    end
end

local function setupDeathDetection(model)
    if not deathIndicatorEnabled or deathTracked[model] then return end
    deathTracked[model] = true
    
    local plr = game.Players:GetPlayerFromCharacter(model)
    local backpack = plr and plr:FindFirstChild("Backpack")
    
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Death Counter" then
                addHighlight(model, "blue")
            end
        end
        
        backpack.ChildAdded:Connect(function(child)
            if deathIndicatorEnabled and child:IsA("Tool") and child.Name == "Death Counter" then
                addHighlight(model, "blue")
                if plr then
                    showNotification(plr.Name .. " Using Ultimate", Color3.fromRGB(0, 200, 255))
                end
            end
        end)
    end
    
    model.ChildAdded:Connect(function(child)
        if deathIndicatorEnabled and child:IsA("Tool") and child.Name == "Death Counter" then
            task.defer(function()
                addHighlight(model, "red")
                local name = plr and plr.Name or model.Name
                showNotification(name .. " Death Counter Activated", Color3.fromRGB(255, 80, 80))
            end)
        end
    end)
    
    if model:FindFirstChild("Death Counter") and model.DeathCounter:IsA("Tool") then
        addHighlight(model, "red")
        local name = plr and plr.Name or model.Name
        showNotification(name .. " Death Counter Activated", Color3.fromRGB(255, 80, 80))
    end
end

local function toggleDeathIndicator(state)
    deathIndicatorEnabled = state
    deathTracked = {}
    
    if deathIndicatorEnabled then
        for _, model in ipairs(live:GetChildren()) do
            setupDeathDetection(model)
        end
        live.ChildAdded:Connect(function(model)
            if deathIndicatorEnabled then
                task.delay(0.1, function()
                    setupDeathDetection(model)
                end)
            end
        end)
    else
        for _, model in ipairs(live:GetChildren()) do
            local highlight = model:FindFirstChild("AlertHighlight")
            if highlight then highlight:Destroy() end
        end
    end
end

miscTab:CreateToggle({
    Title = "Death Counter Indicator",
    Description = "Highlight players using or activating Death Counter",
    Default = false,
    Callback = function(state)
        toggleDeathIndicator(state)
    end
})

-- No Collision
local function setCollision(character, enabled)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = enabled
        end
    end
end

miscTab:CreateToggle({
    Title = "No Collision",
    Description = "Disable collision for your character",
    Default = false,
    Callback = function(state)
        if state then
            if player.Character then
                setCollision(player.Character, false)
            end
            player.CharacterAdded:Connect(function(char)
                char:WaitForChild("HumanoidRootPart")
                setCollision(char, false)
            end)
        else
            if player.Character then
                setCollision(player.Character, true)
            end
            player.CharacterAdded:Connect(function(char)
                char:WaitForChild("HumanoidRootPart")
                setCollision(char, true)
            end)
        end
    end
})

-- ESP Tab
local espTab = Window:CreateTab({Title = "Esp", Icon = "rbxassetid://4483362458"})

local espEnabled = false
local espBillboards = {}

local function createESP(playerObj)
    if not espEnabled or playerObj == player then return end
    if not playerObj.Character then return end
    
    local head = playerObj.Character:FindFirstChild("Head") or playerObj.Character:FindFirstChild("HumanoidRootPart")
    if not head then return end
    
    if espBillboards[playerObj] then
        espBillboards[playerObj]:Destroy()
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.AlwaysOnTop = true
    billboard.Adornee = head
    
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromHSV(math.random(), 0.7, 1)
    label.TextStrokeTransparency = 0.3
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.Text = playerObj.DisplayName or playerObj.Name
    
    billboard.Parent = head
    espBillboards[playerObj] = billboard
end

local function removeESP(playerObj)
    if espBillboards[playerObj] then
        espBillboards[playerObj]:Destroy()
        espBillboards[playerObj] = nil
    end
end

local function setupESP(playerObj)
    createESP(playerObj)
    playerObj.CharacterAdded:Connect(function()
        task.wait(1)
        createESP(playerObj)
    end)
end

espTab:CreateToggle({
    Title = "ESP Players",
    Description = "Show player name tags",
    Default = false,
    Callback = function(state)
        espEnabled = state
        if espEnabled then
            for _, plr in ipairs(game.Players:GetPlayers()) do
                setupESP(plr)
            end
            game.Players.PlayerAdded:Connect(setupESP)
            game.Players.PlayerRemoving:Connect(removeESP)
        else
            for plr, billboard in pairs(espBillboards) do
                if billboard then billboard:Destroy() end
            end
            espBillboards = {}
        end
    end
})

-- Set window visibility
Window:SetVisible(true)