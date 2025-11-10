local currentCamera = nil
local currentVehicle = nil
local vehicleHeading = 120.0
local cameraPosition = 1
local isVehicleLoading = false

Globals.CurrentDealership = nil

local nuiHasFocus = false

-- Override SetNuiFocus calls so we can track state
local function SafeSetNuiFocus(hasFocus, hasCursor)
    nuiHasFocus = hasFocus
    SetNuiFocus(hasFocus, hasCursor)
end

-- Function to safely clear NUI focus
local function SafeClearNUIFocus()
    CreateThread(function()
        SafeSetNuiFocus(false, false)
        Wait(100)
        if nuiHasFocus then
            DebugPrint("NUI focus still active (tracked), forcing clear", "warning")
            SafeSetNuiFocus(false, false)
        end
    end)
end


-- Function to check if player has access to showroom
function IsShowroomAccessAllowed(dealershipId)
    local dealershipConfig = Config.DealershipLocations[dealershipId]
    if not dealershipConfig then
        return false
    end

    local showroomJobWhitelist = dealershipConfig.showroomJobWhitelist
    local showroomGangWhitelist = dealershipConfig.showroomGangWhitelist
    
    -- Check if any whitelists are configured
    local hasJobWhitelist = showroomJobWhitelist and next(showroomJobWhitelist)
    local hasGangWhitelist = showroomGangWhitelist and next(showroomGangWhitelist)
    
    -- If no whitelists are configured, allow access
    if not hasJobWhitelist and not hasGangWhitelist then
        return true
    end

    -- Check job whitelist
    if hasJobWhitelist then
        local playerJob = Framework.Client.GetPlayerJob()
        if not playerJob then
            DebugPrint("Framework.Client.GetPlayerJob() returned nil", "warning")
            return false
        end

        DebugPrint("Got player job information", "debug", playerJob)
        local jobGrades = dealershipConfig.showroomJobWhitelist[playerJob.name]
        if jobGrades then
            local playerGrade = tonumber(playerJob.grade) or 0
            if IsItemInList(jobGrades, playerGrade) then
                return true
            end
        end
    end

    -- Check gang whitelist for QBCore/Qbox frameworks
    if (Config.Framework == "QBCore" or Config.Framework == "Qbox") and hasGangWhitelist then
        local playerGang = Framework.Client.GetPlayerGang()
        if not playerGang then
            DebugPrint("Framework.Client.GetPlayerGang() returned nil", "warning")
            return false
        end

        DebugPrint("Got player gang information", "debug", playerGang)
        local gangGrades = dealershipConfig.showroomGangWhitelist[playerGang.name]
        if gangGrades then
            local playerGrade = tonumber(playerGang.grade) or 0
            if IsItemInList(gangGrades, playerGrade) then
                return true
            end
        end
    end

    return false
end

-- Function to get available societies for purchasing
local function GetAvailableSocieties(dealershipId)
    local societies = {}
    local dealershipConfig = Config.DealershipLocations[dealershipId]

    -- Check job societies
    if dealershipConfig.societyPurchaseJobWhitelist then
        local playerJob = Framework.Client.GetPlayerJob()
        if not playerJob then
            DebugPrint("Framework.Client.GetPlayerJob() returned nil", "warning")
            return societies
        end

        DebugPrint("Got player job information", "debug", playerJob)
        local jobGrades = dealershipConfig.societyPurchaseJobWhitelist[playerJob.name]
        if jobGrades then
            local playerGrade = tonumber(playerJob.grade) or 0
            if IsItemInList(jobGrades, playerGrade) then
                local societyBalance = Framework.Client.GetSocietyBalance(playerJob.name, "job")
                table.insert(societies, {
                    name = playerJob.name,
                    label = playerJob.label,
                    balance = societyBalance,
                    type = "job"
                })
            end
        end
    end

    -- Check gang societies for QBCore/Qbox frameworks
    if Config.Framework == "QBCore" or Config.Framework == "Qbox" then
        if dealershipConfig.societyPurchaseGangWhitelist then
            local playerGang = Framework.Client.GetPlayerGang()
            if not playerGang then
                DebugPrint("Framework.Client.GetPlayerGang() returned nil", "warning")
                return societies
            end

            DebugPrint("Got player gang information", "debug", playerGang)
            local gangGrades = dealershipConfig.societyPurchaseGangWhitelist[playerGang.name]
            if gangGrades then
                local playerGrade = tonumber(playerGang.grade) or 0
                if IsItemInList(gangGrades, playerGrade) then
                    local societyBalance = Framework.Client.GetSocietyBalance(playerGang.name, "gang")
                    table.insert(societies, {
                        name = playerGang.name,
                        label = playerGang.label,
                        balance = societyBalance,
                        type = "gang"
                    })
                end
            end
        end
    end

    return societies
end

-- Register event to open showroom
RegisterNetEvent("jg-dealerships:client:open-showroom", function(dealershipId, defaultVehicle, defaultColor)
    -- Check if already in showroom or test driving
    if Globals.CurrentDealership or Globals.IsTestDriving then
        return
    end

    Globals.CurrentDealership = dealershipId
    local playerPed = cache.ped
    local playerCoords = GetEntityCoords(playerPed)

    -- Check if player is in a vehicle
    if IsPedInAnyVehicle(playerPed, true) then
        Globals.CurrentDealership = nil
        return Framework.Client.Notify(Locale.errorExitVehicle, "error")
    end

    -- Perform pre-checks
    if not ShowroomPreCheck(dealershipId) then
        DebugPrint("jg-dealerships:client:showroom-pre-check failed", "debug")
        Globals.CurrentDealership = nil
        return
    end

    local dealershipConfig = Config.DealershipLocations[dealershipId]

    -- Validate camera configuration
    if not dealershipConfig.camera or not dealershipConfig.camera.coords or dealershipConfig.camera.coords == "" then
        Globals.CurrentDealership = nil
        DebugPrint("You are missing camera coords in your config.lua for " .. dealershipId, "warning")
        Framework.Client.Notify("You are missing camera coords in your config.lua for " .. dealershipId, "error")
        return
    end

    CreateThread(function()
        -- Fade out screen
        DoScreenFadeOut(500)
        Wait(500)

        -- Enter showroom on server
        local showroomData = lib.callback.await("jg-dealerships:server:enter-showroom", false, dealershipId, dealershipConfig, playerCoords)
        if not showroomData then
            Globals.CurrentDealership = nil
            DoScreenFadeIn(0)
            return
        end

        -- Process vehicle data
        local vehicles = {}
        for _, vehicleData in ipairs(showroomData.vehicles) do
            table.insert(vehicles, {
                id = vehicleData.id,
                spawn_code = vehicleData.spawn_code,
                brand = vehicleData.brand,
                model = vehicleData.model,
                price = vehicleData.price,
                stock = vehicleData.stock,
                category = vehicleData.category
            })
        end

        local cameraCoords = dealershipConfig.camera.coords
        local cameraPositions = dealershipConfig.camera.positions
        local availableSocieties = GetAvailableSocieties(dealershipId)

        -- Wait for entity collision
        lib.waitFor(function()
            if not IsEntityWaitingForWorldCollision(playerPed) and HasCollisionLoadedAroundEntity(playerPed) then
                return true
            end
            return nil
        end, nil, 5000)

        -- Calculate camera position
        local cameraRadians = math.rad(cameraCoords.w)
        local cameraOffset1 = cameraPositions[1]
        local offsetX = cameraOffset1 * math.sin(cameraRadians)
        local offsetY = cameraOffset1 * math.cos(cameraRadians)
        local newHeading = cameraCoords.w + 215.0
        vehicleHeading = newHeading

        -- Create camera
        currentCamera = CreateCamWithParams(
            "DEFAULT_SCRIPTED_CAMERA",
            cameraCoords.x + offsetX,
            cameraCoords.y - offsetY,
            cameraCoords.z + 1.5,
            0.0, 0.0, cameraCoords.w,
            0.0, false, 0
        )

        SetCamActive(currentCamera, true)
        SetCamFov(currentCamera, 60.0)
        RenderScriptCams(true, true, 1, true, true)

        -- Hide player
        SetEntityVisible(playerPed, false, false)
        Framework.Client.ToggleHud(false)

        -- Fade in screen
        DoScreenFadeIn(500)

        -- Set NUI focus and send data
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "showShowroom",
            shopType = dealershipConfig.type,
            vehicles = vehicles,
            defaultVehicle = defaultVehicle,
            defaultColor = defaultColor,
            categories = dealershipConfig.categories,
            dealershipId = dealershipId,
            playerBalances = GetPlayerBalances and GetPlayerBalances(dealershipId) or {},
            societies = availableSocieties,
            jgGaragesRunning = GetResourceState("jg-advancedgarages") == "started",
            enablePurchase = not dealershipConfig.disableShowroomPurchase,
            enableTestDrive = dealershipConfig.enableTestDrive,
            financeEnabled = dealershipConfig.enableFinance and showroomData.financeAllowed,
            locale = Locale,
            config = Config,
            vehicleColors = Config.VehicleColourOptions or {} -- Send color options to NUI
        })
    end)
end)

-- Function to exit showroom with proper cleanup
function ExitShowroom()
    if not Globals.CurrentDealership then
        return
    end

    DebugPrint("Exiting showroom, clearing NUI focus", "debug")
    
    -- Clear NUI focus FIRST to prevent cursor issues
    SafeClearNUIFocus()

    local exitResult = lib.callback.await("jg-dealerships:server:exit-showroom", false, Globals.CurrentDealership)
    if not exitResult then
        DebugPrint("jg-dealerships:server:exit-showroom failed", "warning")
        -- Still continue with cleanup even if server callback fails
    end

    -- Show player
    SetEntityVisible(cache.ped, true, false)
    Framework.Client.ToggleHud(true)

    -- Clean up vehicle
    if currentVehicle then
        DeleteEntity(currentVehicle)
        currentVehicle = nil
    end

    -- Clean up camera
    if currentCamera then
        if IsCamActive(currentCamera) then
            RenderScriptCams(false, false, 0, true, false)
            DestroyCam(currentCamera, true)
        end
    end

    -- Reset variables
    currentCamera = nil
    vehicleHeading = 120.0
    cameraPosition = 1
    Globals.CurrentDealership = nil
    
    DebugPrint("Showroom cleanup completed", "debug")
end

-- Emergency function to force exit showroom in case of errors
local function ForceExitShowroom()
    DebugPrint("Force exiting showroom due to error", "warning")
    
    -- Force clear NUI focus
    SafeClearNUIFocus()
    
    -- Restore player visibility
    if cache.ped then
        SetEntityVisible(cache.ped, true, false)
        Framework.Client.ToggleHud(true)
    end
    
    -- Clean up entities
    if currentVehicle then
        DeleteEntity(currentVehicle)
        currentVehicle = nil
    end
    
    if currentCamera then
        if IsCamActive(currentCamera) then
            RenderScriptCams(false, false, 0, true, false)
            DestroyCam(currentCamera, true)
        end
        currentCamera = nil
    end
    
    -- Reset all variables
    vehicleHeading = 120.0
    cameraPosition = 1
    isVehicleLoading = false
    Globals.CurrentDealership = nil
end
-- Function to apply vehicle color based on config settings
local function ApplyVehicleColor(vehicle, colorData)
    if not vehicle or not DoesEntityExist(vehicle) then return false end

    if Config.UseRGBColors and colorData.hex then
        -- Convert hex to RGB
        local hex = colorData.hex:gsub("#", "")
        local r = tonumber(hex:sub(1, 2), 16) or 0
        local g = tonumber(hex:sub(3, 4), 16) or 0
        local b = tonumber(hex:sub(5, 6), 16) or 0

        -- Apply RGB directly
        SetVehicleCustomPrimaryColour(vehicle, r, g, b)
        SetVehicleCustomSecondaryColour(vehicle, r, g, b)

        DebugPrint(("Applied RGB color [%s] (%d,%d,%d)"):format(colorData.label or "Unknown", r, g, b), "debug")
    elseif colorData.index then
        -- Apply GTA’s built-in index colors
        SetVehicleColours(vehicle, colorData.index, colorData.index)
        DebugPrint("Applied color using GTA index: " .. tostring(colorData.index), "debug")
    else
        -- Default white
        SetVehicleColours(vehicle, 111, 111)
        DebugPrint("Applied default white color", "warning")
    end

    return true
end

-- NUI Callback: Change vehicle color
RegisterNUICallback("change-color", function(data, callback)
    CreateThread(function()
        local success, errorMsg = pcall(function()
            if not currentVehicle then
                return callback({error = true, message = "No vehicle to change color"})
            end

            local optionIndex = tonumber(data.color)
            if not optionIndex then
                return callback({error = true, message = "No color option provided"})
            end

            local colorData = Config.VehicleColourOptions[optionIndex]
            if not colorData then
                return callback({error = true, message = "Invalid color selection"})
            end

            -- Apply selected color
            local applied = ApplyVehicleColor(currentVehicle, colorData)
            if not applied then
                return callback({error = true, message = "Failed to apply vehicle color"})
            end

            DebugPrint("Successfully changed vehicle color to: " .. (colorData.label or "Unknown"), "debug")
        end)

        if not success then
            DebugPrint("Error in change-color callback: " .. tostring(errorMsg), "error")
            callback({error = true, message = "Failed to change vehicle color"})
        else
            callback(true)
        end
    end)
end)


-- Function to get color data by index from config
local function GetColorDataByIndex(colorIndex)
    if not Config.VehicleColourOptions then
        DebugPrint("Config.VehicleColourOptions not found", "error")
        return nil
    end
    
    for _, colorOption in ipairs(Config.VehicleColourOptions) do
        if colorOption.index == colorIndex then
            return colorOption
        end
    end
    
    DebugPrint("Color index " .. tostring(colorIndex) .. " not found in config", "warning")
    return nil
end

-- NUI Callback: Change vehicle color with proper config integration
RegisterNUICallback("change-color", function(data, callback)
    CreateThread(function()
        local success, errorMsg = pcall(function()
            if not currentVehicle then
                return callback({error = true, message = "No vehicle to change color"})
            end
            
            local colorIndex = data.color
            if not colorIndex then
                return callback({error = true, message = "No color index provided"})
            end
            
            -- Get color data from config
            local colorData = GetColorDataByIndex(colorIndex)
            if not colorData then
                -- Fallback to using the index directly if not found in config
                colorData = {index = colorIndex, label = "Unknown"}
                DebugPrint("Using fallback color data for index: " .. tostring(colorIndex), "warning")
            end
            
            -- Apply the color to the vehicle
            local colorApplied = ApplyVehicleColor(currentVehicle, colorData)
            if not colorApplied then
                return callback({error = true, message = "Failed to apply vehicle color"})
            end
            
            -- Update camera position tracker (if used elsewhere)
            cameraPosition = colorIndex
            
            DebugPrint("Successfully changed vehicle color to: " .. (colorData.label or "Unknown"), "debug")
        end)
        
        if not success then
            DebugPrint("Error in change-color callback: " .. tostring(errorMsg), "error")
            callback({error = true, message = "Failed to change vehicle color"})
        else
            callback(true)
        end
    end)
end)

-- NUI Callback: Switch vehicle in showroom with enhanced error handling
RegisterNUICallback("switch-vehicle", function(data, callback)
    if not Globals.CurrentDealership or not currentCamera then
        DebugPrint("switch-vehicle called but showroom not active", "warning")
        return callback({error = true, message = "Showroom not active"})
    end

    if isVehicleLoading then
        DebugPrint("Vehicle already loading, ignoring switch request", "debug")
        return callback({error = true, message = "Vehicle loading in progress"})
    end

    local dealershipConfig = Config.DealershipLocations[Globals.CurrentDealership]

    CreateThread(function()
        local success, errorMsg = pcall(function()
            isVehicleLoading = true
            local cameraCoords = dealershipConfig.camera.coords
            local spawnCode = data.spawnCode

            -- Delete existing vehicle
            if currentVehicle then
                DeleteEntity(currentVehicle)
            end

            -- Validate and load model
            local modelHash = ConvertModelToHash and ConvertModelToHash(spawnCode) or GetHashKey(spawnCode)
            spawnCode = modelHash

            if not IsModelValid(spawnCode) then
                DebugPrint("Vehicle does not exist. Please contact an admin! Vehicle: " .. spawnCode .. " returned false with IsModelValid", "warning")
                Framework.Client.Notify("Vehicle does not exist. Please contact an admin!", "error")
                isVehicleLoading = false
                return callback({error = true, message = "Invalid vehicle model"})
            end

            lib.requestModel(spawnCode, 60000)

            -- Create new vehicle
            currentVehicle = CreateVehicle(
                spawnCode,
                cameraCoords.x, cameraCoords.y, cameraCoords.z,
                vehicleHeading,
                false, false
            )

            SetModelAsNoLongerNeeded(spawnCode)
            SetEntityHeading(currentVehicle, vehicleHeading)
            FreezeEntityPosition(currentVehicle, true)
            SetEntityCollision(currentVehicle, false, true)
            
            -- Apply default color or previously selected color
            local defaultColorData = GetColorDataByIndex(cameraPosition) or {index = 111, label = "White"} -- Default to white
            ApplyVehicleColor(currentVehicle, defaultColorData)

            -- Point camera at vehicle
            local vehicleCoords = GetEntityCoords(currentVehicle)
            PointCamAtCoord(currentCamera, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z)
            RenderScriptCams(true, true, 1, true, true)

            isVehicleLoading = false
        end)
        
        if not success then
            DebugPrint("Error in switch-vehicle callback: " .. tostring(errorMsg), "error")
            isVehicleLoading = false
            callback({error = true, message = "Failed to switch vehicle"})
        else
            callback(true)
        end
    end)
end)

-- NUI Callback: Exit showroom with proper error handling
RegisterNUICallback("exit-showroom", function(data, callback)
    CreateThread(function()
        local success, errorMsg = pcall(function()
            DoScreenFadeOut(500)
            Wait(500)
            ExitShowroom()
            DoScreenFadeIn(500)
        end)
        
        if not success then
            DebugPrint("Error in exit-showroom callback: " .. tostring(errorMsg), "error")
            -- Force exit on error
            ForceExitShowroom()
            DoScreenFadeIn(500)
            callback({error = true, message = "Forced showroom exit due to error"})
        else
            callback(true)
        end
    end)
end)

-- NUI Callback: Rotate vehicle left with error handling
RegisterNUICallback("veh-left", function(data, callback)
    CreateThread(function()
        local success, errorMsg = pcall(function()
            if not currentVehicle then
                return callback({error = true, message = "No vehicle to rotate"})
            end

            local currentHeading = GetEntityHeading(currentVehicle)
            vehicleHeading = currentHeading - 10
            SetEntityHeading(currentVehicle, vehicleHeading)
        end)
        
        if not success then
            DebugPrint("Error in veh-left callback: " .. tostring(errorMsg), "error")
            callback({error = true, message = "Failed to rotate vehicle"})
        else
            callback(true)
        end
    end)
end)

-- NUI Callback: Rotate vehicle right with error handling
RegisterNUICallback("veh-right", function(data, callback)
    CreateThread(function()
        local success, errorMsg = pcall(function()
            if not currentVehicle then
                return callback({error = true, message = "No vehicle to rotate"})
            end

            local currentHeading = GetEntityHeading(currentVehicle)
            vehicleHeading = currentHeading + 10
            SetEntityHeading(currentVehicle, vehicleHeading)
        end)
        
        if not success then
            DebugPrint("Error in veh-right callback: " .. tostring(errorMsg), "error")
            callback({error = true, message = "Failed to rotate vehicle"})
        else
            callback(true)
        end
    end)
end)

-- NUI Callback: Change camera view with error handling
RegisterNUICallback("change-cam-view", function(data, callback)
    CreateThread(function()
        local success, errorMsg = pcall(function()
            if not Globals.CurrentDealership or not currentCamera then
                return callback({error = true, message = "Showroom not active"})
            end

            local dealershipConfig = Config.DealershipLocations[Globals.CurrentDealership]
            local cameraPositions = dealershipConfig.camera.positions
            local cameraCoords = dealershipConfig.camera.coords

            -- Cycle through camera positions
            cameraPosition = cameraPosition + 1
            if cameraPosition > 4 then
                cameraPosition = 1
            end

            local positionDistance = cameraPositions[cameraPosition]
            local cameraRadians = math.rad(cameraCoords.w)
            local offsetX = math.sin(cameraRadians) * positionDistance
            local offsetY = math.cos(cameraRadians) * positionDistance

            SetCamCoord(
                currentCamera,
                cameraCoords.x + offsetX,
                cameraCoords.y - offsetY,
                cameraCoords.z + (positionDistance / 10) + 1
            )
        end)
        
        if not success then
            DebugPrint("Error in change-cam-view callback: " .. tostring(errorMsg), "error")
            callback({error = true, message = "Failed to change camera view"})
        else
            callback(true)
        end
    end)
end)

-- NUI Callback: Get vehicle model stats with error handling
RegisterNUICallback("get-model-stats", function(data, callback)
    CreateThread(function()
        local success, errorMsg = pcall(function()
            if Config.HideVehicleStats then
                return callback({})
            end

            if Framework.Client.GetVehicleStats then
                callback(Framework.Client.GetVehicleStats(data.vehicle))
            else
                callback({})
            end
        end)
        
        if not success then
            DebugPrint("Error in get-model-stats callback: " .. tostring(errorMsg), "error")
            callback({error = true, message = "Failed to get vehicle stats"})
        end
    end)
end)

-- ESC key handler for emergency exit
CreateThread(function()
    while true do
        Wait(0)
        
        if Globals.CurrentDealership then
            -- Check for ESC key press to emergency exit showroom
            if IsControlJustPressed(0, 322) then -- ESC key
                DebugPrint("ESC pressed in showroom, performing emergency exit", "debug")
                ForceExitShowroom()
                DoScreenFadeIn(500)
            end
        else
            Wait(1000) -- Reduce thread load when not in showroom
        end
    end
end)

-- Clean up on resource stop with comprehensive cleanup
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DebugPrint("Resource stopping, performing cleanup", "debug")
        
        if Globals.CurrentDealership then
            local dealershipConfig = Config.DealershipLocations[Globals.CurrentDealership]

            -- Clear NUI focus immediately
            SafeClearNUIFocus()
            
            -- Exit bucket and restore player
            TriggerServerEvent("jg-dealerships:server:exit-bucket")
            
            if cache.ped then
                SetEntityVisible(cache.ped, true, false)
                
                if dealershipConfig and dealershipConfig.openShowroom and dealershipConfig.openShowroom.coords then
                    SetEntityCoords(
                        cache.ped,
                        dealershipConfig.openShowroom.coords.x,
                        dealershipConfig.openShowroom.coords.y,
                        dealershipConfig.openShowroom.coords.z,
                        false, false, false, false
                    )
                end
                
                FreezeEntityPosition(cache.ped, false)
            end

            -- Clean up vehicle
            if currentVehicle then
                DeleteEntity(currentVehicle)
                currentVehicle = nil
            end

            -- Clean up camera
            if currentCamera then
                if IsCamActive(currentCamera) then
                    RenderScriptCams(false, false, 0, true, false)
                    DestroyCam(currentCamera, true)
                end
                currentCamera = nil
            end

            -- Restore HUD
            Framework.Client.ToggleHud(true)
            
            -- Reset all variables
            vehicleHeading = 120.0
            cameraPosition = 1
            isVehicleLoading = false
            Globals.CurrentDealership = nil
        end
        
        DebugPrint("Resource cleanup completed", "debug")
    end
end)