-- Create a ScreenGui for our minimize button
local MinimizeGui = Instance.new("ScreenGui")
MinimizeGui.Name = "MinimizeGui"
MinimizeGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
MinimizeGui.ResetOnSpawn = false

-- Create the minimize button with centered positioning
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = MinimizeGui
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeButton.BorderColor3 = Color3.fromRGB(50, 50, 50)
MinimizeButton.AnchorPoint = Vector2.new(0.5, 0.5)
MinimizeButton.Position = UDim2.new(0.5, 0, 0.5, 0)
MinimizeButton.Size = UDim2.new(0, 80, 0, 40)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "Close"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16.000

-- Add corner radius
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MinimizeButton

-- Create X button for removal
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = MinimizeButton
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -20, 0, 0)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16.000
CloseButton.ZIndex = 2

-- Close button functionality
CloseButton.MouseButton1Click:Connect(function()
    -- Destroy the MinimizeButton and CloseButton
    MinimizeButton:Destroy()
    CloseButton:Destroy()
    -- Optionally, destroy the entire GUI if needed
    MinimizeGui:Destroy()
end)



-- Make button draggable
local UserInputService = game:GetService("UserInputService")
local dragging
local dragStart
local startPos

MinimizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MinimizeButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MinimizeButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Add hover effects for main button
MinimizeButton.MouseEnter:Connect(function()
    game:GetService("TweenService"):Create(MinimizeButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    }):Play()
end)

MinimizeButton.MouseLeave:Connect(function()
    game:GetService("TweenService"):Create(MinimizeButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    }):Play()
end)

-- Add hover effects for close button
CloseButton.MouseEnter:Connect(function()
    game:GetService("TweenService"):Create(CloseButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(255, 100, 100)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    game:GetService("TweenService"):Create(CloseButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)

-- Add shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.Image = "rbxassetid://7912134082"
Shadow.Parent = MinimizeButton
Shadow.ZIndex = MinimizeButton.ZIndex - 1

-- Load Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create window with destroy callback
local Window = Fluent:CreateWindow({
    Title = "Bean Hub",
    SubTitle = "By Big Bean",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
    OnDestroy = function()
        local fadeOut = game:GetService("TweenService"):Create(MinimizeGui, TweenInfo.new(0.5), {
            Transparency = 1
        })
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            MinimizeGui:Destroy()
        end)
    end
})

-- Tabs
local Tabs = {
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    PlayerSettings = Window:AddTab({ Title = "Player Settings", Icon = "user" }),
    Keybinds = Window:AddTab({ Title = "Keybinds", Icon = "keyboard" }),
    AutoTrain = Window:AddTab({ Title = "Auto Train", Icon = "axe" }),
    AutoFight = Window:AddTab({ Title = "Auto Fight", Icon = "angry" }),
    Eggs = Window:AddTab({ Title = "Eggs", Icon = "egg" }),
    Christmas = Window:AddTab({ Title = "Christmas", Icon = "santa" }),
    Machines = Window:AddTab({ Title = "Machines", Icon = "star" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "shuffle" })
}

-- Initialize state
local isMinimized = false
Window:Minimize(false)

-- Regular minimize/maximize functionality
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Window:Minimize(isMinimized)

    local textTween = game:GetService("TweenService"):Create(MinimizeButton, TweenInfo.new(0.2), {
        TextTransparency = 1
    })
    
    textTween:Play()
    textTween.Completed:Connect(function()
        MinimizeButton.Text = isMinimized and "Close" or "Open"
        game:GetService("TweenService"):Create(MinimizeButton, TweenInfo.new(0.2), {
            TextTransparency = 0
        }):Play()
    end)
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "Script loaded! Click button to toggle UI, click X to close.",
    Duration = 8
})


local Section = Tabs.Christmas:AddSection("Auto Fight")
-- Retrieve NPC names from the specific path
local npcFolderPath = workspace.GameObjects.ArmWrestling.Frostlands.NPC
local modelNames = {}
local models = {}

for _, npc in pairs(npcFolderPath:GetChildren()) do
    if npc:IsA("Model") then
        table.insert(models, npc)
        table.insert(modelNames, npc.Name)
    end
end

-- Sort NPC names alphabetically
table.sort(modelNames)

-- Reordered UI Elements (Dropdown at top)
local modelDropdown = Tabs.Christmas:AddDropdown("ModelDropdown", {
    Title = "Select Boss",
    Values = modelNames,
    Multi = false,
    Default = modelNames[1],
})

-- Auto Fight in middle
local AutoFightToggle = Tabs.Christmas:AddToggle("AutoFight", {Title = "Auto Fight", Default = false })
AutoFightToggle:OnChanged(function()
    if AutoFightToggle.Value then
        while AutoFightToggle.Value do
            local selectedNPC = modelDropdown.Value
            if selectedNPC then
                local npcModel = npcFolderPath:FindFirstChild(selectedNPC)
                if npcModel and npcModel:FindFirstChild("Table") then
                    local npcTable = npcModel.Table

                    local args = {
                        [1] = selectedNPC,
                        [2] = npcTable,
                        [3] = "Frostlands" -- Fixed folder reference for consistency
                    }

                    game:GetService("ReplicatedStorage").Packages.Knit.Services.ArmWrestleService.RE.onEnterNPCTable:FireServer(unpack(args))
                end
            end
            wait(1) -- Changed to 2 seconds
        end
    end
end)

-- Auto Click at bottom
local AutoClickToggle = Tabs.Christmas:AddToggle("AutoClick", {Title = "Auto Click", Default = false })
AutoClickToggle:OnChanged(function()
    if AutoClickToggle.Value then
        while AutoClickToggle.Value do
            game:GetService("ReplicatedStorage").Packages.Knit.Services.ArmWrestleService.RE.onClickRequest:FireServer()
            wait(0.1) -- Changed to 0.1 seconds
        end
    end
end)

modelDropdown:OnChanged(function(Value) end)

local Section = Tabs.Christmas:AddSection("Auto NPC Farm")

-- Track state
local isAutoFarming = false
local isBossFighting = false
local snowstormPath = workspace.GameObjects.RngNPCs["Frostlands-Snowstorm"].Npc
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Function to hold E key for 2.5 seconds
local function holdE()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    wait(2.5) -- Hold for 2.5 seconds
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Auto Beat NPC Toggle
local AutoBeatNPCToggle = Tabs.Christmas:AddToggle("AutoBeatNPC", {
    Title = "Auto Beat NPC",
    Description = "Auto Fight the NPC's spawned in Snowstorms.",
    Default = false
})

AutoBeatNPCToggle:OnChanged(function()
    isAutoFarming = AutoBeatNPCToggle.Value
    
    if isAutoFarming then
        spawn(function()
            while isAutoFarming do
                local npcs = snowstormPath:GetChildren()
                if #npcs > 0 then
                    for _, npc in ipairs(npcs) do
                        if not isAutoFarming then break end
                        
                        if npc:IsA("Model") and npc:FindFirstChild("Table") and 
                           npc.Table:FindFirstChild("PlayerRoot") then
                            -- Teleport to NPC
                            local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if humanoid then
                                humanoid.CFrame = npc.Table.PlayerRoot.CFrame
                                wait(1.5) -- Wait 1 second after teleport
                                holdE() -- Hold E for 2.5 seconds
                            end
                        end
                    end
                elseif isBossFighting then
                    -- Fight selected boss if no NPCs present
                    local selectedNPC = modelDropdown.Value
                    if selectedNPC then
                        local npcModel = npcFolderPath:FindFirstChild(selectedNPC)
                        if npcModel and npcModel:FindFirstChild("Table") then
                            local args = {
                                [1] = selectedNPC,
                                [2] = npcModel.Table,
                                [3] = "Frostlands"
                            }
                            game:GetService("ReplicatedStorage").Packages.Knit.Services.ArmWrestleService.RE.onEnterNPCTable:FireServer(unpack(args))
                            wait(1)
                        end
                    end
                end
                wait(0.1)
            end
        end)
    end
end)

-- Auto Fight Boss Toggle
local AutoFightBossToggle = Tabs.Christmas:AddToggle("AutoFightBoss", {
    Title = "Auto Fight Boss",
    Description = "Fight selected boss when no NPCs are present",
    Default = false
})

AutoFightBossToggle:OnChanged(function()
    isBossFighting = AutoFightBossToggle.Value
end)


local Section = Tabs.Christmas:AddSection("Free Gift")

-- Auto Claim Santa Sleigh Gift toggle
local AutoClaimToggle = Tabs.Christmas:AddToggle("AutoClaimSantaSleigh", { 
    Title = "Auto Claim Santa Sleigh Gift", 
    Default = false 
})

AutoClaimToggle:OnChanged(function()
    if AutoClaimToggle.Value then
        while AutoClaimToggle.Value do
            local args = {
                [1] = "SantaSleigh"
            }
            game:GetService("ReplicatedStorage").Packages.Knit.Services.FreeGiftService.RF.Claim:InvokeServer(unpack(args))
            wait(30)
        end
    end
end)

-- Auto Claim Workshop Tree Gift toggle
local AutoClaimWorkshopToggle = Tabs.Christmas:AddToggle("AutoClaimWorkshop", { 
    Title = "Auto Claim Workshop Tree Gift", 
    Default = false 
})

AutoClaimWorkshopToggle:OnChanged(function()
    if AutoClaimWorkshopToggle.Value then
        while AutoClaimWorkshopToggle.Value do
            local args = {
                [1] = "WorkshopTree"
            }
            game:GetService("ReplicatedStorage").Packages.Knit.Services.FreeGiftService.RF.Claim:InvokeServer(unpack(args))
            wait(30)
        end
    end
end)

local TowerSection = Tabs.Christmas:AddSection("Ice Tower")

-- Auto Use Tower Key (1x) button
TowerSection:AddButton({
    Title = "Use Tower Key (1x)",
    Description = "Use the Tower Key once.",
    Callback = function()
        local args = {
            [1] = "IceTower",
            [2] = false
        }
        -- Use the Tower Key (1x)
        game:GetService("ReplicatedStorage").Packages.Knit.Services.TowerService.RF.EnterTower:InvokeServer(unpack(args))
        print("Used Tower Key (1x)") -- Debugging log
    end
})

-- Auto Use Tower Key (250x) button
TowerSection:AddButton({
    Title = "Use All Tower Keys (250x)",
    Description = "Use All Tower Keys (max 250 at a time).",
    Callback = function()
        local args = {
            [1] = "IceTower",
            [2] = true
        }
        -- Use the Tower Key (250x)
        game:GetService("ReplicatedStorage").Packages.Knit.Services.TowerService.RF.EnterTower:InvokeServer(unpack(args))
        print("Used Tower Key (250x)") -- Debugging log
    end
})

local WheelSection = Tabs.Christmas:AddSection("Ice Wheel")

-- Auto Spin Wheel toggle
local AutoSpinWheelToggle = Tabs.Christmas:AddToggle("AutoSpinWheel", {
    Title = "Auto Spin Wheel",
    Default = false
})

-- Add Spin Amount Dropdown
local SpinDropdown = Tabs.Christmas:AddDropdown("SpinAmountDropdown", {
    Title = "Select Spin Amount",
    Values = {"1x", "3x", "10x"},
    Multi = false,
    Default = "1x",
})

-- Handle Auto Spin Wheel Toggle
AutoSpinWheelToggle:OnChanged(function()
    if AutoSpinWheelToggle.Value then
        -- Start the Spin based on dropdown selection
        SpinDropdown:OnChanged(function(Value)
            if Value == "1x" then
                while AutoSpinWheelToggle.Value and SpinDropdown.Value == "1x" do
                    local args = {
                        [1] = "Icy Fortune"
                    }
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.SpinnerService.RF.Spin:InvokeServer(unpack(args))
                    print("Used Spin (1x)") -- Debugging log
                    wait(2) -- 2 seconds interval
                end
            elseif Value == "3x" then
                while AutoSpinWheelToggle.Value and SpinDropdown.Value == "3x" do
                    local args = {
                        [1] = "Icy Fortune",
                        [2] = "x10"
                    }
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.SpinnerService.RF.Spin:InvokeServer(unpack(args))
                    print("Used Spin (3x)") -- Debugging log
                    wait(0.5) -- Faster interval for 3x spins
                end
            elseif Value == "10x" then
                while AutoSpinWheelToggle.Value and SpinDropdown.Value == "10x" do
                    local args = {
                        [1] = "Icy Fortune",
                        [2] = "x25"
                    }
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.SpinnerService.RF.Spin:InvokeServer(unpack(args))
                    print("Used Spin (10x)") -- Debugging log
                    wait(0.3) -- Even faster interval for 10x spins
                end
            end
        end)
    end
end)


local modelNames = {}
local models = {}
local armWrestlingFolder = workspace.GameObjects.ArmWrestling

local function findModels(folder)
    for _, item in pairs(folder:GetChildren()) do
        if item:IsA("Folder") and item.Name ~= "PVP" then
            local npcFolder = item:FindFirstChild("NPC")
            if npcFolder then
                for _, npc in pairs(npcFolder:GetChildren()) do
                    if npc:IsA("Model") then
                        table.insert(models, npc)
                        table.insert(modelNames, npc.Name)
                    end
                end
            end
        end
    end
end

local function sortModels()
    table.sort(models, function(a, b)
        return a.Name < b.Name
    end)
    table.sort(modelNames)
end

findModels(armWrestlingFolder)
sortModels()

-- Reordered UI Elements (Dropdown at top)
local modelDropdown = Tabs.AutoFight:AddDropdown("ModelDropdown", {
    Title = "Select Boss",
    Values = modelNames,
    Multi = false,
    Default = modelNames[1],
})

local function getFolderNumber(bossName)
    for _, folder in pairs(armWrestlingFolder:GetChildren()) do
        if folder:IsA("Folder") and folder:FindFirstChild("NPC") then
            if folder.NPC:FindFirstChild(bossName) then
                return folder.Name
            end
        end
    end
    return nil
end

-- Auto Fight in middle
local AutoFightToggle = Tabs.AutoFight:AddToggle("AutoFight", {Title = "Auto Fight", Default = false })
AutoFightToggle:OnChanged(function()
    if AutoFightToggle.Value then
        while AutoFightToggle.Value do
            local selectedBoss = modelDropdown.Value
            if selectedBoss then
                local folderNumber = getFolderNumber(selectedBoss)
                if folderNumber then
                    local npcTable = workspace.GameObjects.ArmWrestling[folderNumber].NPC[selectedBoss].Table
                    
                    local args = {
                        [1] = selectedBoss,
                        [2] = npcTable,
                        [3] = folderNumber
                    }

                    game:GetService("ReplicatedStorage").Packages.Knit.Services.ArmWrestleService.RE.onEnterNPCTable:FireServer(unpack(args))
                end
            end
            wait(1) -- Changed to 2 seconds
        end
    end
end)

-- Auto Click at bottom
local AutoClickToggle = Tabs.AutoFight:AddToggle("AutoClick", {Title = "Auto Click", Default = false })
AutoClickToggle:OnChanged(function()
    if AutoClickToggle.Value then
        while AutoClickToggle.Value do
            game:GetService("ReplicatedStorage").Packages.Knit.Services.ArmWrestleService.RE.onClickRequest:FireServer()
            wait(0.1) -- Changed to 0.1 seconds
        end
    end
end)

modelDropdown:OnChanged(function(Value) end)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})
local Machines = Tabs.Machines
local Section = Tabs.Machines:AddSection("Mutations")


-- Services and Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetServiceRF = ReplicatedStorage.Packages.Knit.Services.PetService.RF:FindFirstChild("getOwned")
local PetCombineService = ReplicatedStorage.Packages.Knit.Services.PetCombineService.RF
local PetCureFn = PetCombineService:FindFirstChild("cure")
local PetMutateFn = PetCombineService:FindFirstChild("mutate")

local ownedPetData = {}  -- Store full pet data including locked status
local uniquePetNames = {}
local selectedPetName = nil
local selectedMutation = nil
local stopLoop = false
local hasReportedCompletion = false

-- Helpers
local function getMutation(tbl)
    if not tbl then return nil end
    for key, value in pairs(tbl) do
        if type(value) == "string" then
            if value:match("Rainbow") then return "Rainbow"
            elseif value:match("Glowing") then return "Glowing"
            elseif value:match("Ghost") then return "Ghost"
            end
        elseif type(value) == "table" then
            local result = getMutation(value)
            if result then return result end
        end
    end
    return nil
end

local function fetchOwnedPets()
    ownedPetData = {}
    uniquePetNames = {}

    if PetServiceRF and PetServiceRF:IsA("RemoteFunction") then
        local success, petData = pcall(function()
            return PetServiceRF:InvokeServer()
        end)

        if success and petData then
            for petId, petInfo in pairs(petData) do
                local displayName = petInfo.DisplayName or "Unknown"
                
                if not ownedPetData[displayName] then
                    ownedPetData[displayName] = {}
                end
                
                table.insert(ownedPetData[displayName], {
                    Id = petId,
                    Locked = petInfo.Locked,
                    Mutation = getMutation(petInfo) or "No Mutation"
                })
            end

            for petName, petInstances in pairs(ownedPetData) do
                for _, petInfo in ipairs(petInstances) do
                    if not petInfo.Locked then
                        if not table.find(uniquePetNames, petName) then
                            table.insert(uniquePetNames, petName)
                        end
                        break
                    end
                end
            end
            return true
        end
        return false
    end
    return false
end

-- Create Pet Dropdown
local PetDropdown = Tabs.Machines:AddDropdown("PetDropdown", {
    Title = "Select Pet",
    Description = "Choose a specific unlocked pet name to mutate.",
    Values = uniquePetNames,
    Multi = false,
})

-- Dropdown Refresh Function
local function refreshDropdown()
    if fetchOwnedPets() then
        PetDropdown:SetValues(uniquePetNames)
        
        if selectedPetName and not table.find(uniquePetNames, selectedPetName) then
            selectedPetName = nil
            PetDropdown:SetValue(nil)
        end
    end
end

-- Periodic Dropdown Refresh
local function startDropdownRefresh()
    spawn(function()
        while true do
            refreshDropdown()
            wait(5)
        end
    end)
end

-- Dropdown Selection Handler
PetDropdown:OnChanged(function(value)
    selectedPetName = value
    hasReportedCompletion = false
    
    if selectedPetName then
        local petInstances = ownedPetData[selectedPetName] or {}
        print("\nUnlocked Pet IDs for", selectedPetName .. ":")
        for _, petInfo in ipairs(petInstances) do
            if not petInfo.Locked then
                print(petInfo.Id)
            end
        end
    end
end)

local MutationDropdown = Tabs.Machines:AddDropdown("MutationDropdown", {
    Title = "Select Mutation",
    Description = "Choose a mutation to aim for.",
    Values = { "Glowing", "Rainbow", "Ghost" },
    Multi = false,
})

MutationDropdown:OnChanged(function(value)
    selectedMutation = value
    hasReportedCompletion = false
end)

-- Add Keep Ghost Toggle (before using it in functions)
local KeepGhostToggle = Tabs.Machines:AddToggle("KeepGhostToggle", {
    Title = "Keep Ghost Pets",
    Description = "Keep pets if they become Ghost mutation, even if Ghost isn't selected.",
    Default = false,
})

local function shouldProcessPet(pet)
    if KeepGhostToggle.Value and pet.Mutation == "Ghost" then
        return false
    end
    return pet.Mutation == "No Mutation" or pet.Mutation ~= selectedMutation
end

local function checkAllPetsMutated()
    if not selectedPetName or not selectedMutation then return false end
    
    local petsToProcess = {}
    for _, petInfo in pairs(ownedPetData[selectedPetName]) do
        if not petInfo.Locked then
            table.insert(petsToProcess, petInfo)
        end
    end
    
    for _, pet in pairs(petsToProcess) do
        if KeepGhostToggle.Value and pet.Mutation == "Ghost" then
            continue
        end
        
        if pet.Mutation ~= selectedMutation then
            return false
        end
    end
    
    return true
end

local function autoCureThenMutateLoop()
    stopLoop = false
    hasReportedCompletion = false
    while not stopLoop do
        if selectedPetName and selectedMutation then
            if checkAllPetsMutated() then
                if not hasReportedCompletion then
                    print("Finished mutating all selected pets!")
                    hasReportedCompletion = true
                end
                wait(2)
                continue
            end
            
            local petsToProcess = {}
            for _, petInfo in pairs(ownedPetData[selectedPetName]) do
                if not petInfo.Locked and shouldProcessPet(petInfo) then
                    table.insert(petsToProcess, petInfo)
                end
            end

            for _, pet in pairs(petsToProcess) do
                if stopLoop then break end

                if pet.Mutation ~= selectedMutation then
                    if pet.Mutation ~= "No Mutation" and 
                       not (KeepGhostToggle.Value and pet.Mutation == "Ghost") then
                        if PetCureFn then
                            local cureArgs = { [1] = pet.Id }
                            pcall(function()
                                return PetCureFn:InvokeServer(unpack(cureArgs))
                            end)
                        else
                            warn("Cure function not found!")
                        end
                    elseif pet.Mutation == "No Mutation" then
                        if PetMutateFn then
                            local mutateArgs = { [1] = pet.Id, [2] = {} }
                            pcall(function()
                                return PetMutateFn:InvokeServer(unpack(mutateArgs))
                            end)
                        else
                            warn("Mutate function not found!")
                        end
                    end
                    wait(1)
                    fetchOwnedPets()
                end
            end
        else
            warn("Please select a pet name and mutation before enabling Auto Mutate.")
        end
        wait(2)
    end
end

-- Add Auto Mutate Toggle
local AutoMutateToggle = Tabs.Machines:AddToggle("AutoMutateToggle", {
    Title = "Enable Auto Mutate Loop",
    Description = "Automatically handles curing and mutation loops.",
    Default = false,
})

AutoMutateToggle:OnChanged(function(state)
    if state then
        if not selectedPetName or not selectedMutation then
            warn("Please select a pet name and a mutation before enabling Auto Mutate.")
            AutoMutateToggle:Set(false)
            return
        end
        autoCureThenMutateLoop()
    else
        stopLoop = true
    end
end)

-- Add Random Mutation Button
Tabs.Machines:AddButton({
    Title = "Randomly Mutate Pets",
    Description = "Randomly mutate selected pet IDs without curing them.",
    Callback = function()
        if not selectedPetName then
            warn("Please select a pet name before using the mutation button.")
            return
        end

        local petsToMutate = {}
        for _, petInfo in ipairs(ownedPetData[selectedPetName] or {}) do
            if not petInfo.Locked then
                table.insert(petsToMutate, petInfo.Id)
            end
        end

        if #petsToMutate == 0 then
            warn("No unlocked pets available for mutation.")
            return
        end

        if PetMutateFn then
            for _, petId in ipairs(petsToMutate) do
                local mutateArgs = { [1] = petId, [2] = {} }
                pcall(function()
                    PetMutateFn:InvokeServer(unpack(mutateArgs))
                end)
            end
            print("Random mutation applied to selected pets:", petsToMutate)
            fetchOwnedPets() -- Refresh pet data after mutation
        else
            warn("Mutate function not found!")
        end
    end,
})

-- Initial fetch and start dropdown refresh
fetchOwnedPets()
startDropdownRefresh()


local Section = Tabs.Machines:AddSection("Goliath")



-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Configuration
local CONFIG = {
    SLOT_WAIT_TIME = 910,  -- Wait time per slot
    DROPDOWN_REFRESH_INTERVAL = 5,  -- Dropdown refresh interval
    PET_REFRESH_INTERVAL = 30,  -- Interval to refresh huge/unlocked pets
}


-- Services and Remote Function
local PetServiceRF = ReplicatedStorage.Packages.Knit.Services.PetService.RF:FindFirstChild("getOwned")
local PetGoliathService = ReplicatedStorage.Packages.Knit.Services.PetGoliathService.RE

-- Pet Data Management
local ownedPetData = {} -- Maps pet names to their IDs
local petNames = {}
local selectedPetName = nil  -- Track selected pet globally
local isAutoGoliathRunning = false  -- Flag to control the automation loop

-- Fetch Pet Data
local function fetchPetData()
    -- Reset existing data
    ownedPetData = {}
    petNames = {}

    if not PetServiceRF or not PetServiceRF:IsA("RemoteFunction") then
        warn("RemoteFunction 'getOwned' is invalid or unavailable.")
        return false
    end

    local success, petData = pcall(function()
        return PetServiceRF:InvokeServer()
    end)

    if not success or not petData then
        warn("Failed to fetch pets or no pets found.")
        return false
    end

    for petId, petInfo in pairs(petData) do
        -- Process only Huge and unlocked pets
        if petInfo.CraftType == "Huge" and petInfo.Locked == false then
            local displayName = petInfo.DisplayName
            if not ownedPetData[displayName] then
                ownedPetData[displayName] = {}
            end
            table.insert(ownedPetData[displayName], petId)

            if not table.find(petNames, displayName) then
                table.insert(petNames, displayName)
            end
        end
    end

    return true
end

-- Pet Dropdown
local PetDropdown = Tabs.Machines:AddDropdown("SelectPet", {
    Title = "Select Your Pet",
    Description = "Choose the name of the pets you want to goliath (The pet will only appear if its a huge and is unlocked).",
    Values = petNames,
    Multi = false,
})

-- Refresh Dropdown Periodically
local function startDropdownRefresh()
    spawn(function()
        while true do
            fetchPetData()
            PetDropdown:SetValues(petNames)
            wait(CONFIG.DROPDOWN_REFRESH_INTERVAL)
        end
    end)
end

-- Periodically Update Huge/Unlocked Pet IDs
local function periodicPetDataRefresh()
    spawn(function()
        while true do
            fetchPetData()
            wait(CONFIG.PET_REFRESH_INTERVAL)
        end
    end)
end

-- Dropdown Selection Handler
PetDropdown:OnChanged(function(selectedPet)
    selectedPetName = selectedPet  -- Store selected pet globally
    print("Selected Pet:", selectedPet)
    local ids = ownedPetData[selectedPet] or {}
    
    if #ids > 0 then
        print("IDs Found:")
        for _, id in ipairs(ids) do
            print(" -", id)
        end
    else
        print("No IDs found or the pet is invalid.")
    end
end)

-- Add paragraph for user instructions
Tabs.Machines:AddParagraph({
    Title = "Pet Info",
    Content = [[When selecting a pet, check the console to verify if the pet IDs are displayed correctly.  
If the IDs aren't showing, select a different pet and then switch back to refresh the IDs.

Note: This Goliath automation only works for unlocked pets.  
If you want specific huge pets to stay huge, make sure to lock them.]]
})

-- Auto Goliath Toggle
local AutoGoliathToggle = Tabs.Machines:AddToggle("Auto Goliath", {
    Title = "Enable Auto Goliath",
    Description = "Star Auto Goliathing your pets.",
    State = false
})

-- Auto Goliath Function
local function AutoGoliath(selectedIDs)
    if not selectedIDs or #selectedIDs == 0 then
        warn("No pets selected for Goliath.")
        return
    end

    local currentIndex = 1

    while isAutoGoliathRunning do
        local slotsToFill = math.min(3, #selectedIDs)

        for i = 1, slotsToFill do
            local petId = selectedIDs[((currentIndex + i - 2) % #selectedIDs) + 1]
            
            local purchaseArgs = {
                [1] = petId,
                [2] = "Slot" .. i
            }

            print("Purchasing pet ID:", petId, "into", purchaseArgs[2])
            PetGoliathService.onPurchase:FireServer(unpack(purchaseArgs))
        end

        task.wait(CONFIG.SLOT_WAIT_TIME)

        for i = 1, slotsToFill do
            local claimArgs = {
                [1] = "PlaceholderString",
                [2] = "Slot" .. i,
            }

            print("Claiming Slot:", i)
            PetGoliathService.onClaim:FireServer(unpack(claimArgs))
        end

        currentIndex = ((currentIndex + slotsToFill - 1) % #selectedIDs) + 1
    end
end

-- Auto Goliath Toggle Handler
AutoGoliathToggle:OnChanged(function(enabled)
    if enabled then
        print("Auto Goliath enabled.")
        
        if not selectedPetName then
            warn("Please select a pet to use for Goliath.")
            AutoGoliathToggle:Set(false)
            return
        end

        local selectedIDs = ownedPetData[selectedPetName]
        if not selectedIDs or #selectedIDs == 0 then
            warn("No pet IDs found.")
            AutoGoliathToggle:Set(false)
            return
        end

        isAutoGoliathRunning = true
        spawn(function()
            AutoGoliath(selectedIDs)
        end)
    else
        print("Auto Goliath disabled.")
        isAutoGoliathRunning = false
    end
end)

-- Initialize
fetchPetData()
startDropdownRefresh()
periodicPetDataRefresh()





local Misc = Tabs.Misc


-- Variable to control the auto roll aura loop
local autoRollAura = false

-- Function to start Auto Roll Aura
local function startAutoRollAura()
    spawn(function()
        while autoRollAura do
            -- Invoke the server function
            game:GetService("ReplicatedStorage").Packages.Knit.Services.AuraService.RF.Roll:InvokeServer()
            -- Wait for 0.0001 seconds before the next iteration
            task.wait(0.0001)
        end
    end)
end

-- Function to stop Auto Roll Aura
local function stopAutoRollAura()
    autoRollAura = false
end

-- Add the Auto Roll Aura toggle to the Misc tab
Misc:AddToggle("Auto Roll Aura", {
    Title = "Auto Roll Aura",
    Default = false,
    Callback = function(enabled)
        autoRollAura = enabled
        if enabled then
            startAutoRollAura()
        else
            stopAutoRollAura()
        end
    end
})




local PlayerSettings = Tabs.PlayerSettings


Tabs.PlayerSettings:AddButton({
    Title = "Respawn",   -- Button title
    Description = "",  -- Short description
    Callback = function()  -- The function that is executed when the button is clicked
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Health = 0 -- Set the health of the humanoid to 0, killing the player
            end
        end
    end
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Variable to store the input value
local healthInputValue = 100 -- Default health value

-- Function to continuously set the player's health
local function setHealthContinuously()
    while true do
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = healthInputValue
        end
        wait(0.001) -- Wait for 0.001 seconds
    end
end

-- Function to update the health input value
local function updateHealthValue(inputValue)
    local numberValue = tonumber(inputValue)
    if numberValue then
        healthInputValue = numberValue
    else
    end
end

-- Adding the input to the UI
Tabs.PlayerSettings:AddInput("Set Health", {
    Title = "Set Health",
    Default = tostring(healthInputValue),
    Callback = function(value)
        updateHealthValue(value)
    end
})

-- Start the continuous health setting
spawn(setHealthContinuously)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Get current WalkSpeed and JumpPower from the player's Humanoid
local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
local walkspeedValue = humanoid and humanoid.WalkSpeed or 16 -- Default walk speed
local jumpPowerValue = humanoid and humanoid.JumpPower or 50 -- Default jump power

-- Function to continuously update the WalkSpeed
local function updateWalkSpeed()
    while true do
        wait(0.0001) -- Update every 0.0001 seconds
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = walkspeedValue
        end
    end
end

-- Function to continuously update the JumpPower
local function updateJumpPower()
    while true do
        wait(0.0001) -- Update every 0.0001 seconds
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = jumpPowerValue
        end
    end
end

-- Function to start the update processes
local function startUpdatingStats()
    spawn(updateWalkSpeed)
    spawn(updateJumpPower)
end

-- Start updating stats when the player spawns
if player.Character then
    startUpdatingStats()
end

-- Walk Speed Slider
PlayerSettings:AddSlider("Walkspeed", {
    Title = "Walk Speed",
    Min = 16,
    Max = 150, -- Increased maximum value for faster speed
    Default = walkspeedValue, -- Set default to current WalkSpeed
    Rounding = 1,
    DisplayValue = function(value)
        return math.floor((value - 16) / 10) + 1
    end,
    Callback = function(value)
        walkspeedValue = value -- Update the value to be used in the loop
    end
})

-- Jump Power Slider
PlayerSettings:AddSlider("JumpPower", {
    Title = "Jump Power",
    Min = 50,
    Max = 150, -- Increased maximum value for higher jump power
    Default = jumpPowerValue, -- Set default to current JumpPower
    Rounding = 1,
    DisplayValue = function(value)
        return value
    end,
    Callback = function(value)
        jumpPowerValue = value -- Update the value to be used in the loop
    end
})


-- Make sure the stats are always updated on player respawn
player.CharacterAdded:Connect(function(character)
    -- Start updating the WalkSpeed and JumpPower when the character spawns
    character:WaitForChild("Humanoid") -- Wait for the Humanoid to load
    startUpdatingStats()
end)

-- Start updating stats immediately for the current character
if player.Character then
    startUpdatingStats()
end

-- FOV Slider
PlayerSettings:AddSlider("Adjust FOV", {
    Title = "Field of View (70 is normal)",
    Min = 1, -- Minimum FOV
    Max = 120, -- Maximum FOV
    Default = 70, -- Default FOV
    Rounding = 1,
    Callback = function(value)
        game.Workspace.CurrentCamera.FieldOfView = value
    end
})



local Players = game:GetService("Players")
local player = Players.LocalPlayer

local infiniteJumpEnabled = false

-- Function to allow or disallow jumping
local function setInfiniteJump(enabled)
    infiniteJumpEnabled = enabled
end

-- Toggle for infinite jump
Tabs.PlayerSettings:AddToggle("Infinite Jump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(enabled)
        setInfiniteJump(enabled)
    end
})

-- Infinite jump logic
local function applyInfiniteJumpLogic()
    while true do
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if infiniteJumpEnabled and humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
        wait(1) -- Check every 1 second to reapply logic if the player respawns
    end
end

-- Start the loop to continuously apply infinite jump logic
spawn(applyInfiniteJumpLogic)


local isFlying = false
local isHoldingSpace = false

PlayerSettings:AddToggle("Fly", {
    Title = "Fly",
    Default = false,
    Callback = function(enabled)
        local player = game.Players.LocalPlayer
        local character = player and player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if not humanoid or not hrp then return end

        if enabled then
            -- Enable flying
            isFlying = true
            humanoid.PlatformStand = true

            local BodyVelocity = Instance.new("BodyVelocity")
            local BodyGyro = Instance.new("BodyGyro")
            BodyVelocity.Parent = hrp
            BodyGyro.Parent = hrp
            BodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
            BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)

            -- Animation and sound settings
            local Hover = Instance.new("Animation")
            Hover.AnimationId = "rbxassetid://18591651576"
            local Fly = Instance.new("Animation")
            Fly.AnimationId = "rbxassetid://18591656031"
            local Sound1 = Instance.new("Sound", hrp)
            Sound1.SoundId = "rbxassetid://3308152153"
            Sound1.Name = "Sound1"
            Sound1.Volume = 0

            local v10 = humanoid.Animator:LoadAnimation(Hover)
            local v11 = humanoid.Animator:LoadAnimation(Fly)
            local Camera = game.Workspace.CurrentCamera
            local TweenService = game:GetService("TweenService")
            local UIS = game:GetService("UserInputService")
            local Flymoving = Instance.new("BoolValue", script)
            Flymoving.Name = "Flymoving"

            -- Movement control
            local function getMovementDirection()
                if humanoid.MoveDirection == Vector3.new(0, 0, 0) then
                    return humanoid.MoveDirection
                end
                local direction = (Camera.CFrame * CFrame.new((CFrame.new(Camera.CFrame.p, Camera.CFrame.p + Vector3.new(Camera.CFrame.lookVector.x, 0, Camera.CFrame.lookVector.z)):VectorToObjectSpace(humanoid.MoveDirection)))).p - Camera.CFrame.p
                return direction.unit
            end

            -- Update flying state
            game:GetService("RunService").RenderStepped:Connect(function()
                if isFlying then
                    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    BodyGyro.CFrame = Camera.CFrame
                    Flymoving.Value = getMovementDirection() ~= Vector3.new(0, 0, 0)
                    TweenService:Create(BodyVelocity, TweenInfo.new(0.3), {Velocity = getMovementDirection() * 1000}):Play()

                    -- Apply upward force if spacebar is held
                    if isHoldingSpace then
                        BodyVelocity.Velocity = Vector3.new(0, 50, 0) -- Adjust the upward speed as needed
                    else
                        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end)

            Flymoving.Changed:Connect(function(p1)
                if p1 then
                    TweenService:Create(Camera, TweenInfo.new(0.5), {FieldOfView = 100}):Play()
                    v10:Stop()
                    Sound1:Play()
                    v11:Play()
                else
                    TweenService:Create(Camera, TweenInfo.new(0.5), {FieldOfView = 70}):Play()
                    v11:Stop()
                    Sound1:Stop()
                    v10:Play()
                end
            end)

            UIS.InputBegan:Connect(function(key, gameProcessed)
                if gameProcessed then return end
                if key.KeyCode == Enum.KeyCode.E then
                    if isFlying then
                        isFlying = false
                        Flymoving.Value = false
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                        hrp.Running.Volume = 0.65
                        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        -- Clean up BodyGyro and BodyVelocity
                        for _, obj in ipairs(hrp:GetChildren()) do
                            if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then
                                obj:Destroy()
                            end
                        end
                        v10:Stop()
                        v11:Stop()

                        -- Reset player to standing position
                        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + Vector3.new(0, 0, 1))
                        end
                    else
                        isFlying = true
                        v10:Play(0.1, 1, 1)
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
                        hrp.Running.Volume = 0
                        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                        BodyVelocity.Parent = hrp
                        BodyGyro.Parent = hrp
                    end
                elseif key.KeyCode == Enum.KeyCode.Space then
                    isHoldingSpace = true
                end
            end)

            UIS.InputEnded:Connect(function(key)
                if key.KeyCode == Enum.KeyCode.Space then
                    isHoldingSpace = false
                end
            end)

        else
            -- Disable flying
            isFlying = false
            humanoid.PlatformStand = false
            -- Clean up BodyGyro and BodyVelocity
            for _, obj in ipairs(hrp:GetChildren()) do
                if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then
                    obj:Destroy()
                end
            end
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

            -- Reset player to standing position
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + Vector3.new(0, 0, 1))
            end
        end
    end
})

-- Update WalkSpeed every 0.01 seconds
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
    local player = game.Players.LocalPlayer
    local humanoid = player and player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = walkspeedValue
    end
end)

local Players = game:GetService("Players")
local highlight = Instance.new("Highlight")
highlight.Name = "Highlight"

local isESPEnabled = false -- Variable to track if ESP is enabled

-- Function to setup ESP for a given player
local function setupESPForPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if not player.Character.HumanoidRootPart:FindFirstChild("Highlight") then
            local highlightClone = highlight:Clone()
            highlightClone.Adornee = player.Character
            highlightClone.Parent = player.Character.HumanoidRootPart
            highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlightClone.Name = "Highlight"
        end
    end
end

-- Function to setup ESP for all players
local function setupESP()
    for _, player in pairs(Players:GetPlayers()) do
        setupESPForPlayer(player)
    end
end

-- Function to enable or disable ESP
local function toggleESP(value)
    isESPEnabled = value
    if isESPEnabled then
        spawn(function()
            -- Start the loop for continuous checking
            while isESPEnabled do
                setupESP() -- Setup ESP every loop iteration
                wait(0.0000001) -- Wait for the specified time before checking again
            end
        end)
    else
        -- Disable ESP: Clean up highlights
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local highlightToRemove = player.Character.HumanoidRootPart:FindFirstChild("Highlight")
                if highlightToRemove then
                    highlightToRemove:Destroy()
                end
            end
        end
    end
end

-- Adding the toggle to the UI
Tabs.PlayerSettings:AddToggle("Toggle ESP", {
    Title = "ESP (See Players Through Walls)", 
    Default = false,
    Callback = function(value)
        toggleESP(value)
    end
})

-- Player added event
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Wait for HumanoidRootPart to be present
        repeat wait() until character:FindFirstChild("HumanoidRootPart")

        -- Only setup highlight if ESP is enabled
        if isESPEnabled then
            setupESPForPlayer(player)
        end
    end)
end)

-- Player removing event
Players.PlayerRemoving:Connect(function(playerRemoved)
    if playerRemoved.Character and playerRemoved:FindFirstChild("HumanoidRootPart") then
        local highlightToRemove = playerRemoved.HumanoidRootPart:FindFirstChild("Highlight")
        if highlightToRemove then
            highlightToRemove:Destroy()
        end
    end
end)


local noClipEnabled = false 
local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Table to keep track of original CanCollide states
local originalCanCollideStates = {}

-- Function to enable or disable NoClip
local function NoClip(enable)
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            if enable then
                -- Store the original CanCollide state before disabling it
                if originalCanCollideStates[part] == nil then
                    originalCanCollideStates[part] = part.CanCollide
                end
                part.CanCollide = false
            else
                -- Reapply the original CanCollide state if it exists
                if originalCanCollideStates[part] ~= nil then
                    part.CanCollide = originalCanCollideStates[part]
                    -- Optionally clear the entry to avoid carrying old state
                end
            end
        end
    end
end

-- Create NoClip toggle using the specified format
PlayerSettings:AddToggle("NoClip", {
    Title = "NoClip",
    Default = false,
    Callback = function(enabled)
        noClipEnabled = enabled
        if noClipEnabled then

            NoClip(true) -- Enable NoClip
        else
            NoClip(false) -- Disable NoClip
            -- Clear the original states after disabling
            -- Uncomment if you want to clear original states after disabling. 
            -- originalCanCollideStates = {}
        end
    end
})

-- NoClip toggle handler
RunService.Stepped:Connect(function()
    if noClipEnabled and Character and HumanoidRootPart then
        NoClip(true) -- Continuously enable NoClip if enabled
    end
end)

-- Listen for character respawn to reset NoClip
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

    -- Reapply NoClip state on respawn
    NoClip(noClipEnabled)

    -- Clear previous stored CanCollide states since it's a new character
    originalCanCollideStates = {}
end)


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local aimbotEnabled = false
local aimingConnection
local originalTransparency = {} -- Store original transparency values

-- Function to look at players' heads
local function AimAtPlayers()
    aimingConnection = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled then
            aimingConnection:Disconnect() -- Disconnect the loop if aimbot is disabled
            return
        end

        -- Find the closest player
        local closestPlayer = nil
        local closestDistance = math.huge

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local headPosition = player.Character.Head.Position
                local playerDistance = (headPosition - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                
                if playerDistance < closestDistance then
                    closestDistance = playerDistance
                    closestPlayer = player
                end
            end
        end

        if closestPlayer then
            local camera = workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, closestPlayer.Character.Head.Position)
        end
    end)
end

-- Function to set player invisibility
local function SetInvisibility(enabled)
    if enabled then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                originalTransparency[part] = part.Transparency -- Save the original transparency
                part.Transparency = 0.9 -- Make almost invisible
            end
        end
    else
        for part, original in pairs(originalTransparency) do
            if part and part:IsA("BasePart") then
                part.Transparency = original -- Restore original transparency
            end
        end
        originalTransparency = {} -- Clear stored transparency
    end
end

-- Assuming PlayerSettings is a valid UI component for toggles
PlayerSettings:AddToggle("Aimbot", {
    Title = "Aimbot",
    Default = false,
    Callback = function(enabled)
        aimbotEnabled = enabled
        
        if aimbotEnabled then
            AimAtPlayers() -- Start aiming if enabled
            SetInvisibility(true) -- Set player to be almost invisible
        else
            if aimingConnection then
                aimingConnection:Disconnect() -- Disconnect if currently connected
                aimingConnection = nil
            end
            SetInvisibility(false) -- Restore player visibility
        end
    end
})

-- Handle when the character respawns to reset the aimbot status
LocalPlayer.CharacterAdded:Connect(function()
    if aimbotEnabled and aimingConnection then
        AimAtPlayers()
    end
end)


-- Function to teleport to a target player
local function teleportToPlayer(targetPlayer)
    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
        
        -- Ensure the player's character exists
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Teleport the player by setting the CFrame directly
            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        end
    end
end

-- Creating buttons for each player in the PlayerSettings tab
local function createTeleportButtons()
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player then -- Exclude self
            Tabs.PlayerSettings:AddButton({
                Title = targetPlayer.Name,  -- Button title (Player's username)
                Description = "Teleport to " .. targetPlayer.Name,  -- Short description 
                Callback = function()  -- Function executed when the button is clicked
                    teleportToPlayer(targetPlayer)  -- Teleport to the selected player
                end
            })
        end
    end
end

-- Call the function to create buttons when the game starts or when needed
createTeleportButtons()

-- Optional: Update buttons if players join/leave
Players.PlayerAdded:Connect(function(newPlayer)
    createTeleportButtons() -- Recreate buttons when a new player joins
end)

Players.PlayerRemoving:Connect(function(removedPlayer)
    createTeleportButtons() -- Recreate buttons when a player leaves
end)




-- Keybind Tab
local Keybinds = Tabs.Keybinds

Tabs.Keybinds:AddParagraph({
    Title = "Keybinds",
    Content = "Keybinds are optional and the toggles work the same way, but make sure you dont have the toggle on when you use the keybinds, or it might break."
})
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local infiniteJumpEnabled = false

-- Keybind for toggling Infinite Jump
local Keybind = Tabs.Keybinds:AddKeybind("Infinite Jump Keybind", {
    Title = "Infinite Jump Keybind",
    Mode = "Toggle", -- Mode can be Always, Toggle, or Hold
    Default = "", -- No default keybind set initially
    Callback = function(Value)
        -- Value is true/false when the keybind is clicked
        infiniteJumpEnabled = Value
    end,

    ChangedCallback = function(New)
    end
})

-- Logic to respond to keybind click
Keybind:OnClick(function()
end)

-- Logic to respond to keybind change
Keybind:OnChanged(function()
end)

-- Infinite jump logic
local function applyInfiniteJumpLogic()
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if infiniteJumpEnabled and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- Continuously check if the keybind is being held down
task.spawn(function()
    while true do
        wait(1)
        local state = Keybind:GetState()
        if state then
    
        end

        if Fluent.Unloaded then break end
    end
end)

-- Start the infinite jump logic
applyInfiniteJumpLogic()
local isFlying = false
local isHoldingSpace = false

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Keybind for toggling Fly
local FlyKeybind = Tabs.Keybinds:AddKeybind("Fly Keybind", {
    Title = "Fly Keybind",
    Mode = "Toggle", -- Mode can be Always, Toggle, or Hold
    Default = "", -- No default keybind set initially
    Callback = function(Value)
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if not humanoid or not hrp then return end

        if Value then
            -- Enable flying
            isFlying = true
            humanoid.PlatformStand = true

            local BodyVelocity = Instance.new("BodyVelocity")
            local BodyGyro = Instance.new("BodyGyro")
            BodyVelocity.Parent = hrp
            BodyGyro.Parent = hrp
            BodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
            BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)

            -- Movement control
            local function getMovementDirection()
                local Camera = game.Workspace.CurrentCamera
                local direction = humanoid.MoveDirection
                if direction == Vector3.new(0, 0, 0) then
                    return direction
                end
                direction = (Camera.CFrame * CFrame.new((CFrame.new(Camera.CFrame.p, Camera.CFrame.p + Vector3.new(Camera.CFrame.lookVector.x, 0, Camera.CFrame.lookVector.z)):VectorToObjectSpace(direction)))).p - Camera.CFrame.p
                return direction.unit
            end

            -- Update flying state
            local connection
            connection = game:GetService("RunService").RenderStepped:Connect(function()
                if not isFlying then
                    connection:Disconnect()
                    return
                end
                humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                BodyGyro.CFrame = game.Workspace.CurrentCamera.CFrame

                if isHoldingSpace then
                    BodyVelocity.Velocity = Vector3.new(0, 50, 0)
                else
                    BodyVelocity.Velocity = getMovementDirection() * 100
                end
            end)

        else
            -- Disable flying
            isFlying = false
            humanoid.PlatformStand = false

            -- Clean up BodyGyro and BodyVelocity
            for _, obj in ipairs(hrp:GetChildren()) do
                if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then
                    obj:Destroy()
                end
            end
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end,

    ChangedCallback = function(New)
    end
})

-- Handling spacebar for upward movement
local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.Space then
        isHoldingSpace = true
    end
end)

UIS.InputEnded:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.Space then
        isHoldingSpace = false
    end
end)


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local noClipEnabled = false 
-- Table to keep track of original CanCollide states
local originalCanCollideStates = {}

-- Function to enable or disable NoClip
local function NoClip(enable)
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            if enable then
                -- Store the original CanCollide state before disabling it
                if originalCanCollideStates[part] == nil then
                    originalCanCollideStates[part] = part.CanCollide
                end
                part.CanCollide = false
            else
                -- Reapply the original CanCollide state if it exists
                if originalCanCollideStates[part] ~= nil then
                    part.CanCollide = originalCanCollideStates[part]
                end
            end
        end
    end
end


-- Adding a keybind for NoClip
local NoClipKeybind = Tabs.Keybinds:AddKeybind("NoClip Keybind", {
    Title = "NoClip Keybind",
    Mode = "Toggle", -- Can be Always, Toggle, or Hold
    Default = "", -- No default keybind set initially
    Callback = function(value)
        noClipEnabled = value -- Set noClipEnabled to the value from the keybind
        if noClipEnabled then
            NoClip(true) -- Enable NoClip
        else
            NoClip(false) -- Disable NoClip
        end
    end,
})

-- NoClip toggle handler
RunService.Stepped:Connect(function()
    if noClipEnabled and Character and HumanoidRootPart then
        NoClip(true) -- Continuously enable NoClip if enabled
    end
end)

-- Listen for character respawn to reset NoClip
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

    -- Reapply NoClip state on respawn
    NoClip(noClipEnabled)

    -- Clear previous stored CanCollide states since it's a new character
    originalCanCollideStates = {}
end)


local Players = game:GetService("Players")
local highlight = Instance.new("Highlight")
highlight.Name = "Highlight"

local isESPEnabled = false -- Variable to track if ESP is enabled

-- Function to setup ESP for a given player
local function setupESPForPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if not player.Character.HumanoidRootPart:FindFirstChild("Highlight") then
            local highlightClone = highlight:Clone()
            highlightClone.Adornee = player.Character
            highlightClone.Parent = player.Character.HumanoidRootPart
            highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlightClone.Name = "Highlight"
        end
    end
end

-- Function to setup ESP for all players
local function setupESP()
    for _, player in pairs(Players:GetPlayers()) do
        setupESPForPlayer(player)
    end
end

-- Function to enable or disable ESP
local function toggleESP(value)
    isESPEnabled = value
    if isESPEnabled then
        spawn(function()
            -- Start the loop for continuous checking
            while isESPEnabled do
                setupESP() -- Setup ESP every loop iteration
                wait(0.0000001) -- Wait for the specified time before checking again
            end
        end)
    else
        -- Disable ESP: Clean up highlights
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local highlightToRemove = player.Character.HumanoidRootPart:FindFirstChild("Highlight")
                if highlightToRemove then
                    highlightToRemove:Destroy()
                end
            end
        end
    end
end

-- Adding a keybind to the UI
local ESPKeybind = Tabs.Keybinds:AddKeybind("ESP Keybind", {
    Title = "ESP Keybind",
    Mode = "Toggle", -- Mode can be Always, Toggle, or Hold
    Default = "", -- No default keybind set initially
    Callback = function(Value)
        -- Toggle ESP on or off when keybind is pressed
        toggleESP(Value)
    end,

    ChangedCallback = function(New)
    end
})

-- Player added event
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Wait for HumanoidRootPart to be present
        repeat wait() until character:FindFirstChild("HumanoidRootPart")

        -- Only setup highlight if ESP is enabled
        if isESPEnabled then
            setupESPForPlayer(player)
        end
    end)
end)

-- Player removing event
Players.PlayerRemoving:Connect(function(playerRemoved)
    if playerRemoved.Character and playerRemoved:FindFirstChild("HumanoidRootPart") then
        local highlightToRemove = playerRemoved.HumanoidRootPart:FindFirstChild("Highlight")
        if highlightToRemove then
            highlightToRemove:Destroy()
        end
    end
end)


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local aimbotEnabled = false
local aimingConnection
local originalTransparency = {} -- Store original transparency values

-- Function to look at players' heads
local function AimAtPlayers()
    aimingConnection = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled then
            aimingConnection:Disconnect() -- Disconnect the loop if aimbot is disabled
            return
        end

        -- Find the closest player
        local closestPlayer = nil
        local closestDistance = math.huge

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local headPosition = player.Character.Head.Position
                local playerDistance = (headPosition - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                
                if playerDistance < closestDistance then
                    closestDistance = playerDistance
                    closestPlayer = player
                end
            end
        end

        if closestPlayer then
            local camera = workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, closestPlayer.Character.Head.Position)
        end
    end)
end

-- Function to set player invisibility
local function SetInvisibility(enabled)
    if enabled then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                originalTransparency[part] = part.Transparency -- Save the original transparency
                part.Transparency = 0.9 -- Make almost invisible
            end
        end
    else
        for part, original in pairs(originalTransparency) do
            if part and part:IsA("BasePart") then
                part.Transparency = original -- Restore original transparency
            end
        end
        originalTransparency = {} -- Clear stored transparency
    end
end

-- Function to toggle the aimbot on and off
local function toggleAimbot(enabled)
    aimbotEnabled = enabled
    
    if aimbotEnabled then
        AimAtPlayers() -- Start aiming if enabled
        SetInvisibility(true) -- Set player to be almost invisible
    else
        if aimingConnection then
            aimingConnection:Disconnect() -- Disconnect if currently connected
            aimingConnection = nil
        end
        SetInvisibility(false) -- Restore player visibility
    end
end

-- Adding a keybind for the aimbot
local AimbotKeybind = Tabs.Keybinds:AddKeybind("Aimbot Keybind", {
    Title = "Aimbot Keybind",
    Mode = "Toggle", -- Can be Always, Toggle, or Hold
    Default = "", -- No default keybind set initially
    Callback = function(Value)
        toggleAimbot(Value) -- Toggles the aimbot when keybind is pressed
    end,
})

-- Handle when the character respawns to reset the aimbot status
LocalPlayer.CharacterAdded:Connect(function()
    if aimbotEnabled and aimingConnection then
        AimAtPlayers()
    end
end)






-- Default values
local availableEggs = {}
local selectedEgg = ""
local autoHatchEnabled = false
local eventEggAutoHatchEnabled = false
local hatchMultiplier = "1x"
local autoDeleteEnabled = false
local autoDeleteChance = 0
local petData = require(game:GetService("ReplicatedStorage").Data.EggData)

-- Fetch egg names from EggData
local function fetchAvailableEggs()
    availableEggs = {}
    local eggData = require(game:GetService("ReplicatedStorage").Data.EggData)

    for eggName, _ in pairs(eggData) do
        if not (eggName:match("Limited") or eggName:match("Event") or eggName:match("MusicalDragon") or eggName:match("100x") or eggName:match("Sour") or eggName:match("Gem") or eggName:match("Cyberpunk")) then
            if eggName:sub(-3) == "Egg" then
                eggName = eggName:sub(1, -4)
            end
            table.insert(availableEggs, eggName)
        end
    end

    -- Sort alphabetically
    table.sort(availableEggs)
end

-- Fetch available eggs initially
fetchAvailableEggs()

-- Function to send remote args
local function SendRemote(args)
    local eggService = game:GetService("ReplicatedStorage"):FindFirstChild("Packages")
        and game:GetService("ReplicatedStorage").Packages:FindFirstChild("Knit")
        and game:GetService("ReplicatedStorage").Packages.Knit.Services
        and game:GetService("ReplicatedStorage").Packages.Knit.Services.EggService
        and game:GetService("ReplicatedStorage").Packages.Knit.Services.EggService.RF
        and game:GetService("ReplicatedStorage").Packages.Knit.Services.EggService.RF.purchaseEgg

    if eggService then
        eggService:InvokeServer(unpack(args))
    end
end

-- Function to start auto-hatching for normal eggs
local function startAutoHatch()
    while autoHatchEnabled do
        local petSettings = {}

        -- Dynamically set all pets to true/false based on autoDeleteEnabled
        for eggName, data in pairs(petData) do
            if data.Chances then
                for petName, chance in pairs(data.Chances) do
                    petSettings[petName] = autoDeleteEnabled and chance >= autoDeleteChance or false
                end
            end
        end

        local args = {}
        if hatchMultiplier == "1x" then
            args = {selectedEgg, petSettings, false, true, false}
        elseif hatchMultiplier == "3x" then
            args = {selectedEgg, petSettings, true, false}
        elseif hatchMultiplier == "8x" then
            args = {selectedEgg, petSettings, false, true, true}
        elseif hatchMultiplier == "30x" then
            args = {selectedEgg, petSettings, false, false, nil, true}
        end

        SendRemote(args)
        wait(0.001)
    end
end

-- Toggle auto-hatching on/off
local function toggleAutoHatch(value)
    autoHatchEnabled = value
    if autoHatchEnabled then
        spawn(startAutoHatch)
    end
end

-- Function to start auto-hatching Event Eggs (always 8x)
local function startAutoHatchEventEgg()
    while eventEggAutoHatchEnabled do
        local args = {8} -- Always hatch 8x for event eggs

        local eventService = game:GetService("ReplicatedStorage"):FindFirstChild("Packages")
            and game:GetService("ReplicatedStorage").Packages:FindFirstChild("Knit")
            and game:GetService("ReplicatedStorage").Packages.Knit.Services
            and game:GetService("ReplicatedStorage").Packages.Knit.Services.EventService
            and game:GetService("ReplicatedStorage").Packages.Knit.Services.EventService.RF
            and game:GetService("ReplicatedStorage").Packages.Knit.Services.EventService.RF.ClaimEgg

        if eventService then
            eventService:InvokeServer(unpack(args))
        end

        wait(0.01) -- Adjust this delay as needed
    end
end

-- Toggle auto-hatching Event Eggs on/off
local function toggleEventEggAutoHatch(value)
    eventEggAutoHatchEnabled = value
    if eventEggAutoHatchEnabled then
        spawn(startAutoHatchEventEgg)
    end
end

-- Function to handle auto-deleting pets based on chance, restricted to selected egg
local function autoDeletePets()
    -- Only execute once when enabled
    local petsToDelete = {}

    -- Check only the selected egg's data
    if selectedEgg and petData[selectedEgg] and petData[selectedEgg].Chances then
        for petName, chance in pairs(petData[selectedEgg].Chances) do
            if chance >= autoDeleteChance then
                table.insert(petsToDelete, petName)
            end
        end
    end

    -- Delete pets
    for _, petName in ipairs(petsToDelete) do
        local args = {
            [1] = petName
        }
        game:GetService("ReplicatedStorage").Packages.Knit.Services.PetService.RF.SetAutoDelete:InvokeServer(unpack(args))
    end
end

-- Toggle auto-delete on/off
local function toggleAutoDelete(value)
    autoDeleteEnabled = value
    autoDeletePets() -- Call the deletion function when toggled on or off
end

-- Add dropdown to select eggs with search feature
Tabs.Eggs:AddDropdown("SelectEggDropdown", {
    Title = "Select Egg",
    Values = availableEggs,
    Default = selectedEgg,
    Search = true,
    Callback = function(selected)
        selectedEgg = selected
    end
})

-- Add dropdown to select hatch multiplier (1x, 3x, 8x)
Tabs.Eggs:AddDropdown("SelectHatchMultiplier", {
    Title = "Hatch Multiplier",
    Values = { "1x", "3x", "8x", "30x" },
    Default = hatchMultiplier,
    Callback = function(selected)
        hatchMultiplier = selected
    end
})

-- Add toggle to start/stop auto-hatching
Tabs.Eggs:AddToggle("AutoHatchToggle", {
    Title = "Auto Hatch",
    Default = false,
    Callback = function(value)
        toggleAutoHatch(value)
    end
})

-- Add heading for Event Eggs section
Tabs.Eggs:AddParagraph({
    Title = "Event Eggs",
    Content = "Enjoy this free 8x hatch for event eggs. You don't need to own the gamepass for this to work."
})

-- Add toggle for Event Eggs (always 8x)
Tabs.Eggs:AddToggle("EventEggAutoHatchToggle", {
    Title = "Auto Hatch Event Eggs (8x)",
    Default = false,
    Callback = function(value)
        toggleEventEggAutoHatch(value)
    end
})

-- Add heading for Auto Delete section
Tabs.Eggs:AddParagraph({
    Title = "Auto Delete",
    Content = "Automatically delete pets based on their chances. Pets with chances equal to or higher than the value set will be deleted. There is a bug with auto delete where it sometimes won't work, to fix this turn the toggle on and off. It won't show the pets being deleted but you won't gain them in your inventory."
})

-- Add toggle for auto-delete pets
Tabs.Eggs:AddToggle("AutoDeleteToggle", {
    Title = "Auto Delete Pets",
    Default = false,
    Callback = function(value)
        toggleAutoDelete(value)
    end
})

-- Add input for auto-delete chance
Tabs.Eggs:AddInput("AutoDeleteChanceInput", {
    Title = "Delete Chances Higher than:",
    Default = "0",
    Numeric = true,
    Callback = function(value)
        autoDeleteChance = tonumber(value) or 0
    end
})

-- Add a button to fetch and update available eggs
Tabs.Eggs:AddButton("Refresh Egg List", function()
    fetchAvailableEggs()
    Tabs.Eggs:UpdateDropdown("SelectEggDropdown", availableEggs)
end)




-- Load previously saved configurations
SaveManager:LoadAutoloadConfig()
