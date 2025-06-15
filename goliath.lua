local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()


local Window = Library:Window{
    Title = "Arm Wrestling Simulator",
    SubTitle = "By Duckie",
    TabWidth = 160,
    Size =  UDim2.fromOffset(580, 460),
    Resize = false, 
    Acrylic = true,
    Theme = "Vynixu",
    MinimizeKey = Enum.KeyCode.LeftShift
}

-- Constants
local SEEDS = {
    "Pear Seeds",
    "Banana Seeds",
    "Starfruit Seeds",
    "Dragon Fruit Seeds"
}

local HARVEST_TIMES = {
    ["Pear Seeds"] = 755,
    ["Banana Seeds"] = 65,
    ["Dragon Fruit Seeds"] = 185,
    ["Starfruit Seeds"] = 245
}

local MERCHANT_ITEMS = {
    ["Banana Seeds"] = {id = 1, amount = 30},
    ["Pear Seeds"] = {id = 2, amount = 10},
    ["Raspberrys"] = {id = 3, amount = 5}
}

local UPGRADE_ITEMS = {
    ["Cookie"] = {name = "Cookie", tier = 1},
    ["Rotten Banana"] = {name = "Banana", tier = 1},
    ["Tasty Cookie"] = {name = "Cookie", tier = 2},
    ["Pink Donut"] = {name = "Donut", tier = 1},
    ["Rotten Starfruit"] = {name = "Starfruit", tier = 1},
    ["Raspberry"] = {name = "Raspberry", tier = 1},
    ["Rotten Dragon Fruit"] = {name = "Dragon Fruit", tier = 1},
    ["Vanilla Donut"] = {name = "Donut", tier = 2},
    ["Golden Pear"] = {name = "Golden Pear", tier = 2},
    ["Normal Starfruit"] = {name = "Starfruit", tier = 2},
    ["Fine Dragon Fruit"] = {name = "Dragon Fruit", tier = 2}
}




local Tabs = {
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    Event = Window:AddTab({ Title = "Event", Icon = "clock" }),
    AutoFight = Window:AddTab({ Title = "Auto Train/Fight", Icon = "crown" }),
    Eggs = Window:AddTab({ Title = "Eggs", Icon = "egg" }),
    Machines = Window:AddTab({ Title = "Machines", Icon = "star" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "rocket" }),
    Garden = Window:AddTab({ Title = "Garden", Icon = "flower" }),
    Main = Window:AddTab({ Title = "Misc", Icon = "shuffle" }),
}




-- Create SuperRB Section
local EventSection = Tabs.Event:AddSection("Rewind Event")

-- Add Load Script Button
EventSection:AddButton({
    Title = "Load Event Script",
    Description = "Loads my Duck/Rewind Event script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/bigbeanscripts/Prison-Event/refs/heads/main/event"))()
    end
})



-- Auto Train
local function GetHighestZone(player)
    local highestZone = -1
    for name, value in pairs(player:GetAttributes()) do
        if string.match(name, "^Zone%d+$") and value == true then
            local zoneNum = tonumber(string.match(name, "%d+"))
            if zoneNum and zoneNum > highestZone then
                highestZone = zoneNum
            end
        end
    end
    return tostring(highestZone)
end

local function GetBestQualifyingBag(player)
    local zone = GetHighestZone(player)
    local knuckleStrength = player:GetAttribute("KnuckleStrength") or 0
    
    if player:GetAttribute("VIP") then return zone, "VIP" end
    
    local punchBagData = require(game:GetService("ReplicatedStorage").Data.PunchBags)
    local zoneData = punchBagData[zone]
    local bestTier = "Tier1"
    local highestRequired = 0
    
    for tier, data in pairs(zoneData) do
        if data.StrengthRequired and 
           knuckleStrength >= data.StrengthRequired and 
           data.StrengthRequired > highestRequired then
            bestTier = tier
            highestRequired = data.StrengthRequired
        end
    end
    
    
    return zone, bestTier
end

local function FindEquipmentInZone(zoneNumber, equipmentType, player)
    local dataModule = {
        Dumbells = game:GetService("ReplicatedStorage").Data.Dumbells,
        Grips = game:GetService("ReplicatedStorage").Data.Grips,
        Barbells = game:GetService("ReplicatedStorage").Data.Barbells,
        ["Pull up bar"] = game:GetService("ReplicatedStorage").Data.PullupBars
    }

    local strengthAttributes = {
        Dumbells = "TotalBicepPower",
        Grips = "TotalHandStrength",
        Barbells = "TotalBicepPower",
        ["Pull up bar"] = "TotalHandStrength"
    }

    local module = dataModule[equipmentType]
    if not module then return nil end

    local data = require(module)
    local zoneKey = tostring(zoneNumber)
    local playerStrength = player:GetAttribute(strengthAttributes[equipmentType])

    if data[zoneKey] then
        local highestQualified = nil
        for itemKey, item in pairs(data[zoneKey]) do
            if item.StrengthRequired and playerStrength >= item.StrengthRequired then
                if not highestQualified or tonumber(itemKey:match("%d+")) > tonumber(highestQualified:match("%d+")) then
                    highestQualified = itemKey
                end
            end
        end
        return highestQualified
    end
    return nil
end

local function GetHighestEquipment(player, equipmentType)
    local attributes = player:GetAttributes()
    local zones = {}

    -- Get zones that the player has unlocked
    for attributeName, attributeValue in pairs(attributes) do
        if string.match(attributeName, "^Zone%d+$") and attributeValue == true then
            local zoneNumber = tonumber(string.match(attributeName, "%d+"))
            if zoneNumber then
                table.insert(zones, zoneNumber)
            end
        end
    end

    -- Sort zones in descending order (highest zone first)
    table.sort(zones, function(a, b) return a > b end)

    -- Loop through the zones until equipment is found
    for _, zoneNumber in ipairs(zones) do
        local equipment = FindEquipmentInZone(zoneNumber, equipmentType, player)
        if equipment then
            return zoneNumber, equipment
        end
    end

    return nil, nil
end

local function TeleportToPunchBag(player)
    local highestZone = GetHighestZone(player)
    local punchBagTier = GetBestQualifyingBag(player)

    local punchBag = workspace.Zones[highestZone].Interactables.Training.PunchBags[punchBagTier]
    if punchBag then
        local punchBagPosition = punchBag:GetPivot()
        local teleportPosition = punchBagPosition + punchBagPosition.LookVector * 0.5 -- Teleport in front by 0.5 units
        player.Character:PivotTo(teleportPosition)
    end
end

local function HandlePunchBag()
    local player = game.Players.LocalPlayer
    local zone, tier = GetBestQualifyingBag(player)
    
    -- Teleport
    local bag = workspace.Zones[zone].Interactables.Training.PunchBags[tier]
    if bag then
        local bagCFrame = bag:GetPivot()
        local teleportPos = bagCFrame * CFrame.new(0, 0, -5)
        player.Character:PivotTo(teleportPos)
        
        -- Send stats
        local args = {
            [1] = zone,
            [2] = tier
        }
        game:GetService("ReplicatedStorage").Packages.Knit.Services.PunchBagService.RE.onGiveStats:FireServer(unpack(args))
    end
end

local function HandlePullUps()
    local args = {
        [1] = CFrame.new(-10838.837890625, -123.75142669677734, 1179.05224609375)
    }
    game:GetService("ReplicatedStorage").Packages.Knit.Services.PullupBarService.RF.Place:InvokeServer(unpack(args))
    
    local statsArgs = {
        [1] = "17",
        [2] = "Tier4"
    }
    game:GetService("ReplicatedStorage").Packages.Knit.Services.PullupBarService.RE.onGiveStats:FireServer(unpack(statsArgs))
end



local TrainSection = Tabs.AutoFight:AddSection("Auto Train")

local TrainingDropdown = Tabs.AutoFight:AddDropdown("TrainingSelect", {
    Title = "Select Training Type",
    Values = {"Dumbells", "Grips", "Barbells", "PunchBags", "Pull up bar"},
    Multi = false,
    Default = "Dumbells"
})

local AutoTrainToggle = Tabs.AutoFight:AddToggle("AutoTrain", {
    Title = "Auto Train",
    Default = false
})
AutoTrainToggle:OnChanged(function()
    if AutoTrainToggle.Value then

        -- Simulated background click every 0.1s (excluding PunchBags and Pull up bar)
        spawn(function()
            while AutoTrainToggle.Value do
                local selection = TrainingDropdown.Value
                if selection ~= "PunchBags" and selection ~= "Pull up bar" then
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.ToolService.RE.onClick:FireServer()
                end
                task.wait(0.1)
            end
        end)

        -- Equipment/Position check every 10 seconds
        spawn(function()
            while AutoTrainToggle.Value do
                local selection = TrainingDropdown.Value
                
                if selection == "PunchBags" then
                    -- Handle PunchBag
                    HandlePunchBag()

                    -- Send stats every 0.25 seconds while toggle is on
                    while AutoTrainToggle.Value do  -- Check if the toggle is still on
                        local zone, tier = GetBestQualifyingBag(game.Players.LocalPlayer)
                        local args = {
                            [1] = zone,
                            [2] = tier
                        }
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.PunchBagService.RE.onGiveStats:FireServer(unpack(args))
                        wait(0.25)  -- Wait for 0.25 seconds before sending stats again
                    end
                elseif selection == "Pull up bar" then
                    HandlePullUps()
                else
                    local zone, equipment = GetHighestEquipment(game.Players.LocalPlayer, selection)
                    if zone and equipment then
                        local args = {
                            [1] = zone,
                            [2] = selection,
                            [3] = equipment
                        }
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.ToolService.RE.onGuiEquipRequest:FireServer(unpack(args))
                    end
                end
                
                wait(10)  -- Wait before checking again after 10 seconds
            end
        end)

        -- Reequip/Stats update every 10 seconds
        spawn(function()
            while AutoTrainToggle.Value do
                local selection = TrainingDropdown.Value
                if selection == "PunchBags" then
                    HandlePunchBag()
                elseif selection == "Pull up bar" then
                    HandlePullUps()
                elseif (selection == "Grips" or selection == "Dumbells" or selection == "Barbells") 
                    and _G.currentZone and _G.currentEquipment then
                    local args = {
                        [1] = tostring(_G.currentZone),
                        [2] = selection,
                        [3] = _G.currentEquipment
                    }
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.ToolService.RE.onGuiEquipRequest:FireServer(unpack(args))
                end
                wait(10)
            end
        end)

        -- Click/Stats every 1 second
        spawn(function()
            while AutoTrainToggle.Value do
                local selection = TrainingDropdown.Value
                if selection == "Pull up bar" then
                    local statsArgs = {
                        [1] = "17",
                        [2] = "Tier4"
                    }
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.PullupBarService.RE.onGiveStats:FireServer(unpack(statsArgs))
                elseif selection ~= "PunchBags" then
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.ToolService.RE.onClick:FireServer()
                end
                wait(1)
            end
        end)
    end
end)



local AutoTrainPullUpsToggle = Tabs.AutoFight:AddToggle("AutoTrainPullUps", {
    Title = "Auto Train (Selected) and Pull Ups",
    Default = false
})

AutoTrainPullUpsToggle:OnChanged(function()
    if AutoTrainPullUpsToggle.Value then
        spawn(function()
            while AutoTrainPullUpsToggle.Value do
                local selection = TrainingDropdown.Value
                
                if selection == "Grips" or selection == "Dumbells" or selection == "Barbells" then
                    local zone, equipment = GetHighestEquipment(game.Players.LocalPlayer, selection)
                    
                    if zone and equipment then
                        local args = {
                            [1] = tostring(zone),
                            [2] = selection,
                            [3] = equipment
                        }
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.ToolService.RE.onGuiEquipRequest:FireServer(unpack(args))
                    end
                end
                
                -- Regular training click
                game:GetService("ReplicatedStorage").Packages.Knit.Services.ToolService.RE.onClick:FireServer()
                
                -- Pull ups handling
                HandlePullUps()
                
                wait(0.1)
            end
        end)
    end
end)

-- UI section
local FightSection = Tabs.AutoFight:AddSection("Auto Fight")

local modelNames = {}
local npcLocations = {} -- Store model locations for reference
local armWrestlingFolder = workspace.GameObjects.ArmWrestling

-- Populate model names for dropdown
local function findModels(folder)
    for _, item in pairs(folder:GetChildren()) do
        if item:IsA("Folder") and item.Name ~= "PVP" and item.Name ~= "6_OLD" then
            local npcFolder = item:FindFirstChild("NPC")
            if npcFolder then
                for _, npc in pairs(npcFolder:GetChildren()) do
                    if npc:IsA("Model") then
                        table.insert(modelNames, npc.Name)
                        npcLocations[npc.Name] = {folder = item.Name, npc = npc}
                    end
                end
            end
        end
    end
end

-- Sort dropdown options alphabetically
local function sortModels()
    table.sort(modelNames)
end

findModels(armWrestlingFolder)
sortModels()

-- Dropdown for selecting boss
local modelDropdown = Tabs.AutoFight:AddDropdown("ModelDropdown", {
    Title = "Select Boss",
    Values = modelNames,
    Multi = false,
    Searchable = true,
    Default = modelNames[1] or "",
})

-- Auto Click toggle
local AutoClickToggle = Tabs.AutoFight:AddToggle("AutoClick", {
    Title = "Auto Click/Crit",
    Description = "Allows you to win fights over 5x as fast.",
    Default = false
})

-- Auto Fight toggle
local AutoFightToggle = Tabs.AutoFight:AddToggle("AutoFight", {
    Title = "Auto Fight",
    Description = "Automatically starts fights with the selected boss (to beat bosses much faster, enable the Auto Click/Crit toggle).",
    Default = false
})

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KnitServices = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services")
local ArmwrestleServiceRF = KnitServices:WaitForChild("ArmWrestleService"):WaitForChild("RF")

-- Variables
local autoClickThreads = {}
local autoFightLoop = nil
local lastFightEnded = true

-- Get NPC reference from name
local function getNPCReference(name)
    local ref = npcLocations[name]
    return ref and ref.npc
end

-- Auto Click toggle handler
AutoClickToggle:OnChanged(function()
    if AutoClickToggle.Value then
        for _, thread in pairs(autoClickThreads) do
            if typeof(thread) == "thread" then
                task.cancel(thread)
            elseif typeof(thread) == "table" then
                thread.active = false
            end
        end
        autoClickThreads = {}

        task.spawn(function()
            for i = 1, 150 do
                local threadData = { active = true }
                table.insert(autoClickThreads, threadData)

                task.spawn(function()
                    while threadData.active and AutoClickToggle.Value do
                        pcall(function()
                            ArmwrestleServiceRF:WaitForChild("RequestClick"):InvokeServer()
                            ArmwrestleServiceRF:WaitForChild("RequestCritHit"):InvokeServer()
                        end)
                        task.wait()
                    end
                end)

                task.wait()
            end
        end)
    else
        for _, thread in pairs(autoClickThreads) do
            if typeof(thread) == "thread" then
                task.cancel(thread)
            elseif typeof(thread) == "table" then
                thread.active = false
            end
        end
        autoClickThreads = {}
    end
end)

-- Auto Fight toggle handler 
AutoFightToggle:OnChanged(function()
    if AutoFightToggle.Value then
        if autoFightLoop then task.cancel(autoFightLoop) end
        autoFightLoop = task.spawn(function()
            while AutoFightToggle.Value do
                local selectedName = modelDropdown.Value
                if selectedName then
                    local npcModel = getNPCReference(selectedName)
                    if npcModel then
                        pcall(function()
                            ArmwrestleServiceRF:WaitForChild("RequestStartFight"):InvokeServer(npcModel)
                        end)
                    end
                end
                task.wait(0.1) -- 0.1 second interval
            end
        end)
    else
        if autoFightLoop then
            task.cancel(autoFightLoop)
            autoFightLoop = nil
        end
    end
end)





-- Default values
local availableEggs = {}
local selectedEgg = ""
local autoHatchEnabled = false
local eventEggAutoHatchEnabled = false
local hatchMultiplier = "1x"
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
    local args = {}

    -- Set the correct args based on hatchMultiplier
    if hatchMultiplier == "1x" then
        args = {selectedEgg, nil, false, true, false}
    elseif hatchMultiplier == "3x" then
        args = {selectedEgg, nil, true, false}
    elseif hatchMultiplier == "8x" then
        args = {selectedEgg, nil, false, true, true}
    elseif hatchMultiplier == "30x" then
        args = {selectedEgg, nil, nil, false, nil, true}
    elseif hatchMultiplier == "Max" then
        args = {selectedEgg, nil, nil, false, nil, true}
    end

    -- Loop and send remote arguments every 0.2 seconds
    spawn(function()
        while autoHatchEnabled do
            -- Send the remote arguments
            if #args > 0 then
                SendRemote(args)
            end
            wait(0.2)  -- Wait for 0.2 seconds before sending again
        end
    end)
end

-- Toggle auto-hatching on/off
local function toggleAutoHatch(value)
    autoHatchEnabled = value
    if autoHatchEnabled then
        spawn(startAutoHatch)
    end
end


-- Function to teleport the player to the selected egg's model world pivot
local function teleportToSelectedEgg()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local eggModel
    for _, zone in pairs(workspace.Zones:GetChildren()) do
        local eggsFolder = zone:FindFirstChild("Interactables") and zone.Interactables:FindFirstChild("Eggs")
        if eggsFolder then
            for _, model in pairs(eggsFolder:GetChildren()) do
                if model.Name:lower():find(selectedEgg:lower()) then
                    eggModel = model
                    break
                end
            end
            if eggModel then
                break
            end
        end
    end

    if eggModel then
        local originalCFrame = humanoidRootPart.CFrame
        local targetCFrame = eggModel:GetPivot()
        humanoidRootPart.CFrame = targetCFrame * CFrame.new(0, 0, -5) -- Slightly in front

        -- Teleport back after the specified delay
        wait(teleportDelay)
        humanoidRootPart.CFrame = originalCFrame
    else
        warn("Egg model not found in workspace: " .. selectedEgg)
    end
end

-- Add dropdown to select eggs with search feature
Tabs.Eggs:AddDropdown("SelectEggDropdown", {
    Title = "Select Egg",
    Values = availableEggs,
    Default = selectedEgg,
    Searchable = true,
    Callback = function(selected)
        selectedEgg = selected
    end
})

-- Add dropdown to select hatch multiplier (1x, 3x, 8x)
Tabs.Eggs:AddDropdown("SelectHatchMultiplier", {
    Title = "Hatch Multiplier",
    Values = { "1x", "3x", "8x", "30x", "Max" },
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



Tabs.Eggs:AddSection("Auto Delete -- Teleport")

-- Add input to set the delay between teleports
Tabs.Eggs:AddInput("TeleportDelayInput", {
    Title = "Teleport back from egg delay",
    Default = teleportDelay,
    Placeholder = "Enter teleport back delay",
    Numeric = true, -- Only allows numbers
    Finished = false, -- Only calls callback when you press enter
    Callback = function(value)
        teleportDelay = tonumber(value) or teleportDelay
    end
})

-- Add button to teleport to the selected egg's model world pivot
Tabs.Eggs:AddButton({
    Title = "Teleport to Selected Egg (and back)",
    Description = "Teleport to the selected egg -- If its still a model -- so you can auto delete pets. The teleport input is for how long you will stay at the egg, before teleporting back.",
    Callback = function()
        teleportToSelectedEgg()
    end
})




local ScriptsSection = Tabs.Machines:AddSection("Machine Loadstring")

-- Add loadstring button
ScriptsSection:AddButton({
    Title = "Load Machines Script",
    Description = "Run Machines Loadstring (Its a big script so it might take a while to load)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/bigbeanscripts/Mutate-/refs/heads/main/Cosmic"))()
    end
})



local Teleport = Tabs.Teleport

local TeleportSection = Tabs.Teleport:AddSection("Zones")

-- Function to teleport player using remote event
local function teleportTo(zoneName)
    local args = {
        [1] = workspace.Zones:FindFirstChild(zoneName).Interactables.Teleports.Locations.Spawn
    }
    game:GetService("ReplicatedStorage").Packages.Knit.Services.ZoneService.RE.teleport:FireServer(unpack(args))
end

-- Get all zones and store in a table for sorting (excluding "Frame")
local zones = {}
for _, zone in ipairs(workspace.Zones:GetChildren()) do
    if zone.Name ~= "Frame" then  -- Only add zones that aren't named exactly "Frame"
        table.insert(zones, zone)
    end
end

-- Custom sorting function
local function sortZones(a, b)
    -- Extract numbers from zone names if they exist
    local numA = tonumber(string.match(a.Name, "%d+"))
    local numB = tonumber(string.match(b.Name, "%d+"))
    
    if numA and numB then
        -- If both names contain numbers, sort numerically
        return numA < numB
    elseif numA then
        -- If only first name has number, it goes after
        return false
    elseif numB then
        -- If only second name has number, it goes after
        return true
    else
        -- If no numbers, sort alphabetically
        return a.Name:lower() < b.Name:lower()
    end
end

-- Sort the zones
table.sort(zones, sortZones)

-- Function to format zone name
local function formatZoneName(zoneName)
    local number = string.match(zoneName, "^(%d+)$")
    if number then
        return "World " .. number
    end
    return zoneName
end

-- Add buttons for each sorted zone
for _, zone in ipairs(zones) do
    TeleportSection:AddButton({
        Title = formatZoneName(zone.Name),
        Callback = function()
            teleportTo(zone.Name)
        end
    })
end



-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Player
local player = Players.LocalPlayer

-- Format merchant names helper (optional)
local function formatMerchantName(name)
    return name:gsub("(%u)", " %1"):gsub("^%s+", "")
end

-- Variables
local selectedMerchantItems = {}

-- Get all possible items from LimitedMerchant module
local function getAllItems()
    local LimitedMerchant = require(ReplicatedStorage.Data.LimitedMerchant)
    local allItems = {}

    for merchantName, merchantData in pairs(LimitedMerchant) do
        if merchantData.Items then
            for slotIndex, itemList in pairs(merchantData.Items) do
                for itemIndex, item in ipairs(itemList) do
                    local itemName = string.format("%s - %s (%.0f %s)",
                        item.Title or "Unknown",
                        merchantName,
                        item.Price or 0,
                        typeof(item.Currency) == "string" and item.Currency or (typeof(item.Currency) == "table" and item.Currency.Item or "Unknown Currency")
                    )
                    allItems[itemName] = {
                        merchant = merchantName,
                        slot = tonumber(slotIndex),
                        index = itemIndex,
                        raw = item
                    }
                end
            end
        end
    end

    return allItems
end

-- Get live replica data (used to check if item is currently in merchant and has stock)
local function getLiveStockData()
    local ReplicaController = require(ReplicatedStorage.ReplicaController)
    ReplicaController.RequestData()

    local startTime = tick()
    local replica
    repeat
        task.wait(0.1)
        local CustomReplicaController = Knit.GetController("CustomReplicaController")
        replica = CustomReplicaController and CustomReplicaController:GetReplica()
    until replica or tick() - startTime > 5

    local liveData = {}
    if replica and replica.Data and replica.Data.LimitedMerchant then
        for merchantName, merchantData in pairs(replica.Data.LimitedMerchant) do
            if merchantData.Items then
                for slotIndex, itemData in pairs(merchantData.Items) do
                    liveData[merchantName .. ":" .. slotIndex] = {
                        stock = itemData.Stock,
                        index = itemData.Index
                    }
                end
            end
        end
    end

    return liveData
end

-- UI Section
local MerchantSection = Tabs.Main:AddSection("Merchants")

-- Populate dropdown from all items
local allItemData = getAllItems()
local allItemNames = {}
for name in pairs(allItemData) do
    table.insert(allItemNames, name)
end
table.sort(allItemNames)

-- Dropdown UI (placed before toggle)
local MerchantDropdown = MerchantSection:AddDropdown("MerchantSelect", {
    Title = "Select Merchant Item(s)",
    Description = "Choose items to auto-buy from merchants. Occasionally, slot 1 or 2 won't be recognised."
    Values = allItemNames,
    Multi = true,
    Searchable = true,
    Default = {}
})

-- Variables to hold selected items
local selectedMerchantItems = {}

-- Toggle for Auto Buying (below dropdown)
local AutoBuyToggle = MerchantSection:AddToggle("AutoBuy", {
    Title = "Auto Buy Items",
    Default = false
})

-- Paragraph to show selected items BELOW the toggle
local SelectedItemsParagraph = MerchantSection:Paragraph("SelectedItemsDisplay", {
    Title = "Selected Items",
    Content = "None selected",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Left
})

-- Dropdown selection changed handler
MerchantDropdown:OnChanged(function(value)
    selectedMerchantItems = value

    local selectedList = {}
    for itemName, isSelected in pairs(value) do
        if isSelected then
            table.insert(selectedList, itemName)
        end
    end

    if #selectedList > 0 then
        SelectedItemsParagraph:SetValue(table.concat(selectedList, "\n"))
    else
        SelectedItemsParagraph:SetValue("None selected")
    end
end)

-- Auto Buy Loop
AutoBuyToggle:OnChanged(function(enabled)
    if enabled then
        task.spawn(function()
            while AutoBuyToggle.Value do
                local liveData = getLiveStockData()

                for itemName, isSelected in pairs(selectedMerchantItems) do
                    if isSelected then
                        local info = allItemData[itemName]
                        local liveInfo = liveData[info.merchant .. ":" .. tostring(info.slot)]

                        if liveInfo and liveInfo.index == info.index and liveInfo.stock and liveInfo.stock > 0 then
                            local success, err = pcall(function()
                                ReplicatedStorage.Packages.Knit.Services.LimitedMerchantService.RF.BuyItem:InvokeServer(info.merchant, info.slot)
                            end)

                            if not success then
                                -- silently ignore failure
                            end
                        end
                    end
                end

                task.wait(1.5)
            end
        end)
    end
end)




-- Merchant Section
local MerchantSection = Tabs.Garden:AddSection("Farmer Merchant")

local MerchantDropdown = MerchantSection:AddDropdown("MerchantItems", {
    Title = "Select Items",
    Description = "Choose items to auto-buy",
    Values = {"Banana Seeds", "Pear Seeds", "Raspberrys"},
    Multi = true,
    Default = {}
})

MerchantDropdown:OnChanged(function(Value)
    selectedMerchantItems = Value
end)

local MerchantToggle = MerchantSection:AddToggle("AutoBuy", {
    Title = "Auto Buy Merchant",
    Description = "Automatically buy selected items",
    Default = false
})

MerchantToggle:OnChanged(function(Value)
    autoBuyEnabled = Value
    if Value then
        spawn(function()
            while autoBuyEnabled do
                for itemName, isSelected in pairs(selectedMerchantItems) do
                    if not autoBuyEnabled then break end
                    if isSelected and MERCHANT_ITEMS[itemName] then
                        local itemConfig = MERCHANT_ITEMS[itemName]
                        for i = 1, itemConfig.amount do
                            if not autoBuyEnabled then break end
                            local args = {
                                [1] = "Farmer",
                                [2] = itemConfig.id
                            }
                            game:GetService("ReplicatedStorage").Packages.Knit.Services.MerchantService.RF.BuyItem:InvokeServer(unpack(args))
                            task.wait(0.1)
                        end
                    end
                end
                if autoBuyEnabled then
                    task.wait(60)
                end
            end
        end)
    end
end)

-- Upgrade Section
local UpgradeSection = Tabs.Garden:AddSection("Upgrade Items")

local UpgradeDropdown = UpgradeSection:AddDropdown("UpgradeItems", {
    Title = "Select Items",
    Description = "Choose items to auto-upgrade",
    Values = {"Cookie", "Rotten Banana", "Tasty Cookie", "Pink Donut", "Rotten Starfruit", 
              "Raspberry", "Rotten Dragon Fruit", "Vanilla Donut", "Golden Pear", 
              "Normal Starfruit", "Fine Dragon Fruit"},
    Multi = true,
    Default = {}
})

UpgradeDropdown:OnChanged(function(Value)
    selectedUpgradeItems = Value
end)

local UpgradeToggle = UpgradeSection:AddToggle("AutoUpgrade", {
    Title = "Upgrade Snacks (Selected)",
    Description = "Automatically upgrade selected snacks",
    Default = false
})

UpgradeToggle:OnChanged(function(Value)
    autoUpgradeEnabled = Value
    if Value then
        spawn(function()
            while autoUpgradeEnabled do
                for itemName, isSelected in pairs(selectedUpgradeItems) do
                    if not autoUpgradeEnabled then break end
                    if isSelected and UPGRADE_ITEMS[itemName] then
                        local itemConfig = UPGRADE_ITEMS[itemName]
                        local args = {
                            [1] = {
                                ["Item"] = itemConfig.name,
                                ["Tier"] = itemConfig.tier
                            }
                        }
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.ItemCraftingService.RF.UpgradeSnack:InvokeServer(unpack(args))
                    end
                end
                task.wait(0.05)
            end
        end)
    end
end)

local UpgradeAllToggle = UpgradeSection:AddToggle("AutoUpgradeAll", {
    Title = "Upgrade All Snacks",
    Description = "Automatically upgrade all available snacks",
    Default = false
})

UpgradeAllToggle:OnChanged(function(Value)
    autoUpgradeAllEnabled = Value
    if Value then
        spawn(function()
            while autoUpgradeAllEnabled do
                for _, itemConfig in pairs(UPGRADE_ITEMS) do
                    if not autoUpgradeAllEnabled then break end
                    local args = {
                        [1] = {
                            ["Item"] = itemConfig.name,
                            ["Tier"] = itemConfig.tier
                        }
                    }
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.ItemCraftingService.RF.UpgradeSnack:InvokeServer(unpack(args))
                end
                task.wait(0.05)
            end
        end)
    end
end)




-- Create Trial Section
local TrialSection = Tabs.Main:AddSection("Auto Trial")

-- Medieval Toggle
local MedievalToggle = TrialSection:AddToggle("MedievalTrial", {
    Title = "Auto Medieval",
    Description = "Don't fight NPC's OR Bosses while this toggle is on. This will cause it to break.",
    Default = false
})

MedievalToggle:OnChanged(function(value)
    if value then
        spawn(function()
            while MedievalToggle.Value do
                local args = {
                    [1] = "Medieval"
                }
                game:GetService("ReplicatedStorage").Packages.Knit.Services.ChampionshipService.RF.RequestJoin:InvokeServer(unpack(args))
                
                -- Wait for duration unless toggle turned off
                local timeWaited = 0
                while timeWaited < 1201 and MedievalToggle.Value do
                    wait(1)
                    timeWaited = timeWaited + 1
                end
                
                if not MedievalToggle.Value then break end
            end
        end)
    end
end)

-- Angelic Toggle
local AngelicToggle = TrialSection:AddToggle("AngelicTrial", {
    Title = "Auto Angelic",
    Description = "Don't fight NPC's OR Bosses while this toggle is on. This will cause it to break.",
    Default = false
})

AngelicToggle:OnChanged(function(value)
    if value then
        spawn(function()
            while AngelicToggle.Value do
                local args = {
                    [1] = "Angelic"
                }
                game:GetService("ReplicatedStorage").Packages.Knit.Services.ChampionshipService.RF.RequestJoin:InvokeServer(unpack(args))
                
                -- Wait for duration unless toggle turned off
                local timeWaited = 0
                while timeWaited < 600 and AngelicToggle.Value do
                    wait(1)
                    timeWaited = timeWaited + 1
                end
                
                if not AngelicToggle.Value then break end
            end
        end)
    end
end)



local OpenSection = Tabs.Main:AddSection("Auto Open")

-- Kingdom Chest Toggle
local KingdomChestToggle = OpenSection:AddToggle("KingdomChest", {
    Title = "Auto Open Kingdom Chest",
    Default = false
})

KingdomChestToggle:OnChanged(function(value)
    if value then
        spawn(function()
            while KingdomChestToggle.Value do
                if not KingdomChestToggle.Value then break end
                
                local args = {
                    [1] = "KingdomChest"
                }
                game:GetService("ReplicatedStorage").Packages.Knit.Services.ChestService.RF.Open:InvokeServer(unpack(args))
                wait(0.5)
            end
        end)
    end
end)

-- Orc Vault Toggle
local OrcVaultToggle = OpenSection:AddToggle("OrcVault", {
    Title = "Auto Open Orc Vault",
    Default = false
})

OrcVaultToggle:OnChanged(function(value)
    if value then
        spawn(function()
            while OrcVaultToggle.Value do
                if not OrcVaultToggle.Value then break end
                
                local args = {
                    [1] = "OrcVault"
                }
                game:GetService("ReplicatedStorage").Packages.Knit.Services.ChestService.RF.Open:InvokeServer(unpack(args))
                wait(0.5)
            end
        end)
    end
end)

local TowerSection = Tabs.Main:AddSection("Towers")

-- Prison Cave Buttons
TowerSection:AddButton({
    Title = "Use Beach Tower Key (1x)",
    Description = "Use the Beach Tower Key once.",
    Callback = function()
        local args = {
            [1] = "BeachTower",
            [2] = false
        }
        game:GetService("ReplicatedStorage").Packages.Knit.Services.TowerService.RF.EnterTower:InvokeServer(unpack(args))
    end
})

TowerSection:AddButton({
    Title = "Use All Beach Tower Keys (250x)",
    Description = "Use All Beach Tower Keys (max 250 at a time).",
    Callback = function()
        local args = {
            [1] = "BeachTower",
            [2] = true
        }
        game:GetService("ReplicatedStorage").Packages.Knit.Services.TowerService.RF.EnterTower:InvokeServer(unpack(args))
    end
})

-- Prison Cave Buttons
TowerSection:AddButton({
    Title = "Use Beach Tower Key (1x)",
    Description = "Use the RIft Cave Key once.",
    Callback = function()
        local args = {
            [1] = "RiftCave",
            [2] = false
        }
        game:GetService("ReplicatedStorage").Packages.Knit.Services.TowerService.RF.EnterTower:InvokeServer(unpack(args))
    end
})

TowerSection:AddButton({
    Title = "Use All Beach Tower Keys (250x)",
    Description = "Use All Rift Cave Keys (max 250 at a time).",
    Callback = function()
        local args = {
            [1] = "RiftCave",
            [2] = true
        }
        game:GetService("ReplicatedStorage").Packages.Knit.Services.TowerService.RF.EnterTower:InvokeServer(unpack(args))
    end
})

local WheelSection = Tabs.Main:AddSection("Auto Wheel")

-- Wheels dropdown
local WheelDropdown = WheelSection:AddDropdown("WheelSelect", {
    Title = "Select Wheel",
    Values = {"Cave Fortune", "Divine Fortune", "Sakura Fortune"},
    Multi = true,
    Default = {}
})

-- Spin amount dropdown with mapping
local spinAmounts = {
    ["1x"] = "",    -- No second argument for 1x
    ["3x"] = "x10", -- x10 for 3x spins
    ["10x"] = "x25" -- x25 for 10x spins
}

local SpinAmountDropdown = WheelSection:AddDropdown("SpinAmount", {
    Title = "Select Spin Amount",
    Values = {"1x", "3x", "10x"},
    Multi = false,
    Default = "1x"
})

-- Auto spin toggle
local AutoSpinToggle = WheelSection:AddToggle("AutoSpin", {
    Title = "Auto Spin",
    Default = false
})

AutoSpinToggle:OnChanged(function(value)
    if value then
        spawn(function()
            while AutoSpinToggle.Value do
                if not AutoSpinToggle.Value then break end
                
                for wheel, isSelected in pairs(WheelDropdown.Value) do
                    if not AutoSpinToggle.Value then break end
                    if isSelected then
                        local args = {
                            [1] = wheel
                        }
                        
                        -- Add second argument only if not 1x
                        local spinAmount = spinAmounts[SpinAmountDropdown.Value]
                        if spinAmount ~= "" then
                            args[2] = spinAmount
                        end
                        
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.SpinnerService.RF.Spin:InvokeServer(unpack(args))
                        wait(0.5)
                    end
                end
                
                wait(0.5)
            end
        end)
    end
end)

-- Create Auto Roll Trainers section
local TrainersSection = Tabs.Main:AddSection("Auto Roll Trainers")

-- Add toggle to automatically open all trainer crates
local AutoRollTrainersToggle = TrainersSection:AddToggle("AutoRollTrainers", {
    Title = "Auto Roll All Crates",
    Description = "Automatically begings to opens all trainer crates",
    Default = false
})

-- Variable to store the loop
local trainerCrateLoop = nil

AutoRollTrainersToggle:OnChanged(function(value)
    if value then
        -- Start auto opening crates
        trainerCrateLoop = spawn(function()
            local crates = {
                "Mythic Crate",
                "Gold Crate",
                "Starter Crate",
                "Premium Crate",
                "Prism Crate",
                "Galaxy Crate"
            }

            while AutoRollTrainersToggle.Value do
                for _, crate in ipairs(crates) do
                    local args = {
                        [1] = crate
                    }
                    pcall(function()
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.TrainerService.RF.OpenCrate:InvokeServer(unpack(args))
                    end)
                end
                
                -- Wait 1 second before next cycle
                task.wait(3)
            end
        end)
    else
        -- Stop the loop
        if trainerCrateLoop then
            trainerCrateLoop:Cancel()
            trainerCrateLoop = nil
        end
    end
end)


-- After Tabs declaration
local CircusSection = Tabs.Main:AddSection("Event Egg")

-- Add Auto Circus Egg toggle
local AutoCircusEggToggle = CircusSection:AddToggle("AutoCircusEgg", {
    Title = "Auto Claim the Event Egg",
    Description = "Automatically claims the Event Egg",
    Default = false
})

local autoCircusThread

AutoCircusEggToggle:OnChanged(function()
    if AutoCircusEggToggle.Value then
        -- Start auto-claiming in a new thread
        autoCircusThread = task.spawn(function()
            while AutoCircusEggToggle.Value do
                game:GetService("ReplicatedStorage").Packages.Knit.Services.EventEggService.RF.Claim:InvokeServer()

                task.wait(30) -- Wait 300 seconds (5 minutes) before claiming again
            end
        end)
    else
        -- Stop the thread properly
        if autoCircusThread then
            task.cancel(autoCircusThread)
        end
    end
end)


local PetSection = Tabs.Main:AddSection("Pet Stuff")


-- Equip Best Toggle
local EquipBestToggle = PetSection:AddToggle("EquipBest", {
    Title = "Equip Best",
    Default = false
})

EquipBestToggle:OnChanged(function(value)
    if value then
        spawn(function()
            while EquipBestToggle.Value do
                -- Unequip all
                local unequipArgs = {
                    [1] = game:GetService("Players").LocalPlayer
                }
                game:GetService("ReplicatedStorage").Packages.Knit.Services.PetService.RF.unequipAll:InvokeServer(unpack(unequipArgs))
                
                -- Equip best
                local equipArgs = {
                    [1] = game:GetService("Players").LocalPlayer
                }
                game:GetService("ReplicatedStorage").Packages.Knit.Services.PetService.RF.equipBest:InvokeServer(unpack(equipArgs))
                
                -- Wait loop with break check
                local timeWaited = 0
                while timeWaited < 15 and EquipBestToggle.Value do
                    wait(1)
                    timeWaited = timeWaited + 1
                end
                
                if not EquipBestToggle.Value then break end
            end
        end)
    end
end)


local AutoClickToggle = PetSection:AddToggle("AutoClick", {
    Title = "Craft All (Unlocked)",
    Default = false
})

AutoClickToggle:OnChanged(function(value)
    if value then
        spawn(function()
            while AutoClickToggle.Value do
                -- Get reference to CraftAll button
                local craftAllButton = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.Inventory.ExtraTools.Pets.BottomBar.CraftAll
                
                -- Simulate click if button exists
                if craftAllButton then
                    -- Fire click event
                    firesignal(craftAllButton.MouseButton1Click)
                end
                
                -- Wait with break check
                local timeWaited = 0
                while timeWaited < 3 and AutoClickToggle.Value do
                    wait(1)
                    timeWaited = timeWaited + 1
                end
                
                if not AutoClickToggle.Value then break end
            end
        end)
    end
end)


local AuraSection = Tabs.Main:AddSection("Auto Aura")

-- Variable to control the auto roll aura loop
local autoRollAura = false

-- Function to start Auto Roll Aura
local function startAutoRollAura()
    spawn(function()
        while autoRollAura do
            -- Invoke the server function
            game:GetService("ReplicatedStorage").Packages.Knit.Services.AuraService.RF.Roll:InvokeServer()
            -- Wait for 0.0001 seconds before the next iteration
            task.wait(0.25)
        end
    end)
end

-- Function to stop Auto Roll Aura
local function stopAutoRollAura()
    autoRollAura = false
end

-- Add the Auto Roll Aura toggle to the Misc tab
local AuraToggle = AuraSection:AddToggle("Auto Roll Aura", {
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


-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes{}

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab("Settings")

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
