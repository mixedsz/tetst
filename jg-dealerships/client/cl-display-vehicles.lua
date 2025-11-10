-- Storage for display vehicle interaction points and spawning status
local displayVehiclePoints = {}
local dealershipSpawning = {}
local showroomOpen = true
local displayVehicleBeingPlaced = false
local vehiclePlacementActive = false

-- Control keys for vehicle placement
local placementControls = {30, 31, 44, 22, 200} -- A, D, Q, Space, Enter

-- Check if vehicle placement would collide with other objects
local function checkVehicleCollision(vehicle)
    local vehicleCoords = GetEntityCoords(vehicle)
    local vehicleRotation = GetEntityRotation(vehicle, 2)
    local rotationRadians = math.rad(vehicleRotation.z)
    
    -- Get vehicle dimensions
    local minDimensions, maxDimensions = GetModelDimensions(GetEntityModel(vehicle))
    local vehicleWidth = maxDimensions.x - minDimensions.x
    local vehicleLength = maxDimensions.y - minDimensions.y
    local vehicleHeight = (maxDimensions.z - minDimensions.z) / 2
    
    -- Define corner points for collision detection
    local cornerOffsets = {
        {vehicleWidth / 2, 0},
        {0, vehicleLength / 2},
        {-vehicleWidth / 2, 0},
        {0, -vehicleLength / 2}
    }
    
    -- Check each corner for collisions
    for _, cornerOffset in ipairs(cornerOffsets) do
        -- Apply rotation to corner offsets
        local rotatedX = cornerOffset[1] * math.cos(rotationRadians) - cornerOffset[2] * math.sin(rotationRadians)
        local rotatedY = cornerOffset[1] * math.sin(rotationRadians) + cornerOffset[2] * math.cos(rotationRadians)
        
        -- Calculate world coordinates for corner points
        local startPoint = vector3(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + vehicleHeight)
        local endPoint = vector3(vehicleCoords.x + rotatedX, vehicleCoords.y + rotatedY, vehicleCoords.z + vehicleHeight)
        
        -- Perform raycast to detect collisions
        local raycastHandle = StartShapeTestRay(startPoint.x, startPoint.y, startPoint.z, endPoint.x, endPoint.y, endPoint.z, -1, vehicle, 0)
        local raycastResult, hit, hitCoords, surfaceNormal, hitEntity = GetShapeTestResult(raycastHandle)
        
        -- Draw debug lines if enabled
        if Config.Debug then
            DrawLine(startPoint.x, startPoint.y, startPoint.z, endPoint.x, endPoint.y, endPoint.z, 255, 0, 0, 255)
        end
        
        -- Check if raycast hit something other than the player
        if hit == 1 and hitEntity ~= cache.ped then
            return true -- Collision detected
        end
    end
    
    return false -- No collision
end

-- Rotate vehicle by specified angle
local function rotateVehicle(vehicle, angleChange)
    local currentRotation = GetEntityRotation(vehicle, 2)
    local newZRotation = currentRotation.z + angleChange
    SetEntityRotation(vehicle, currentRotation.x, currentRotation.y, newZRotation, 2, true)
end

-- Convert heading angle to direction vector
local function headingToDirection(heading)
    local headingRadians = math.rad(heading)
    return vector3(-math.sin(headingRadians), math.cos(headingRadians), 0)
end

-- Move vehicle in specified direction
local function moveVehicle(vehicle, direction, distance)
    local vehicleCoords = GetEntityCoords(vehicle)
    local playerCoords = GetEntityCoords(cache.ped)
    local vehicleHeading = GetEntityHeading(vehicle)
    local directionVector = headingToDirection(vehicleHeading)
    
    local newCoords = nil
    
    if direction == "forward" then
        newCoords = vehicleCoords + (directionVector * distance)
    elseif direction == "backward" then
        newCoords = vehicleCoords - (directionVector * distance)
    elseif direction == "left" then
        local leftVector = vector3(-directionVector.y, directionVector.x, 0)
        newCoords = vehicleCoords + (leftVector * distance)
    elseif direction == "right" then
        local rightVector = vector3(directionVector.y, -directionVector.x, 0)
        newCoords = vehicleCoords + (rightVector * distance)
    end
    
    -- Only move if player is within reasonable distance
    local distanceFromPlayer = #(playerCoords - newCoords)
    if distanceFromPlayer <= 10.0 then
        SetEntityCoordsNoOffset(vehicle, newCoords.x, newCoords.y, newCoords.z, false, false, false)
    end
end

-- Create interaction point for display vehicles
local function createInteractionPoint(coords, distance, onEnter, onExit, nearby)
    local point = lib.points.new({
        coords = coords,
        distance = distance
    })
    
    function point:onEnter()
        onEnter()
    end
    
    function point:onExit()
        onExit()
    end
    
    if nearby then
        function point:nearby()
            nearby()
        end
    end
    
    return point
end

-- Clean up display vehicles for a dealership
local function cleanupDisplayVehicles(dealershipId)
    -- Remove existing interaction points
    if displayVehiclePoints[dealershipId] and #displayVehiclePoints[dealershipId] > 0 then
        for _, point in ipairs(displayVehiclePoints[dealershipId]) do
            point:remove()
        end
    end
    
    -- Get display vehicles from player state and delete them
    local stateKey = string.format("displayVehicles:%s", dealershipId)
    local displayVehiclesJson = LocalPlayer.state[stateKey] or "{}"
    local displayVehicles = json.decode(displayVehiclesJson)
    
    if displayVehicles and #displayVehicles > 0 then
        for _, vehicleData in ipairs(displayVehicles) do
            DeleteEntity(vehicleData.entity)
        end
    end
end

-- Spawn display vehicles for a dealership
local function spawnDealershipDisplayVehicles(dealershipId)
    if dealershipSpawning[dealershipId] then
        return -- Already spawning
    end
    
    dealershipSpawning[dealershipId] = true
    
    CreateThread(function()
        -- Clean up existing vehicles first
        cleanupDisplayVehicles(dealershipId)
        
        -- Get display vehicles data from server
        local displayData = lib.callback.await("jg-dealerships:server:get-display-vehicles", false, dealershipId)
        
        if not displayData then
            dealershipSpawning[dealershipId] = false
            return
        end
        
        local spawnedVehicles = {}
        local isManager = displayData.isManager
        local vehicles = displayData.vehicles
        local dealershipConfig = Config.DealershipLocations[dealershipId]
        
        -- Process each vehicle
        for _, vehicleData in ipairs(vehicles) do
            local vehicleModel = vehicleData.vehicle
            local vehicleCoords = json.decode(vehicleData.coords)
            
            -- Convert model name to hash and request model
            local modelHash = ConvertModelToHash(vehicleModel)
            vehicleModel = modelHash
            lib.requestModel(vehicleModel, 60000)
            
            -- Create the display vehicle
            local displayVehicle = CreateVehicle(vehicleModel, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, vehicleCoords.w, false, false)
            
            -- Configure vehicle properties
            SetEntityHeading(displayVehicle, vehicleCoords.w)
            SetVehicleColour(displayVehicle, vehicleData.color)
            SetVehicleDoorsLocked(displayVehicle, 2)
            SetVehicleNumberPlateText(displayVehicle, Config.DisplayVehiclesPlate)
            SetEntityInvincible(displayVehicle, true)
            SetModelAsNoLongerNeeded(vehicleModel)
            
            -- Wait for vehicle to exist
            lib.waitFor(function()
                return DoesEntityExist(displayVehicle) and true or nil
            end, nil, 5000)
            
            -- Mark as display vehicle in entity state
            Entity(displayVehicle).state:set("isDisplayVehicle", true, false)
            
            -- Calculate interaction distance
            local minDim, maxDim = GetModelDimensions(GetEntityModel(displayVehicle))
            local interactionDistance = (0 - minDim.x) + maxDim.x + 1.0
            
            -- Prepare text UI prompt
            local promptText = Config.ViewInShowroomPrompt
            local textUIType = Config.DrawText
            
            if textUIType == "auto" then
                textUIType = GetResourceState("jg-textui") == "started" and "jg-textui" or Config.DrawText
            end
            
            -- Format text for jg-textui if needed
            if textUIType == "jg-textui" then
                local brandText = vehicleData.brand or ""
                local modelText = vehicleData.model or ""
                promptText = string.format("<h4 style='margin-bottom:5px'>%s %s</h4><p>%s</p>", brandText, modelText, Config.ViewInShowroomPrompt)
            end
            
            -- Create interaction point if purchase prompt is not hidden
            if not Config.DisplayVehiclesHidePurchasePrompt then
                local hasAccess = IsShowroomAccessAllowed(dealershipId) or (dealershipConfig.type == "owned" and isManager)
                
                if hasAccess and not showroomOpen then
                    local pointIndex = #displayVehiclePoints + 1
                    displayVehiclePoints[pointIndex] = createInteractionPoint(
                        vector4(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, vehicleCoords.w),
                        interactionDistance,
                        function()
                            Framework.Client.ShowTextUI(promptText)
                        end,
                        function()
                            Framework.Client.HideTextUI()
                        end,
                        function()
                            if IsControlJustPressed(0, Config.ViewInShowroomKeyBind) then
                                if not showroomOpen then
                                    TriggerEvent("jg-dealerships:client:open-showroom", dealershipId, vehicleData.vehicle, vehicleData.color)
                                end
                            end
                        end
                    )
                end
            end
            
            -- Add to spawned vehicles list
            local spawnedIndex = #spawnedVehicles + 1
            spawnedVehicles[spawnedIndex] = vehicleData
            spawnedVehicles[spawnedIndex].entity = displayVehicle
        end
        
        -- Update player state with spawned vehicles
        local stateKey = string.format("displayVehicles:%s", dealershipId)
        LocalPlayer.state:set(stateKey, json.encode(spawnedVehicles))
        
        displayVehiclePoints[dealershipId] = displayVehiclePoints[dealershipId] or {}
        dealershipSpawning[dealershipId] = false
    end)
end

-- Spawn display vehicles for all dealerships
function SpawnAllDealershipDisplayVehicles()
    for dealershipId in pairs(Config.DealershipLocations) do
        spawnDealershipDisplayVehicles(dealershipId)
    end
end

-- Register net event for spawning display vehicles
RegisterNetEvent("jg-dealerships:client:spawn-display-vehicles", function(dealershipId)
    spawnDealershipDisplayVehicles(dealershipId)
end)

-- Register NUI callback for creating display vehicles
RegisterNUICallback("create-display-vehicle", function(data, callback)
    if vehiclePlacementActive then
        return callback(false)
    end
    
    Framework.Client.HideTextUI()
    showroomOpen = true
    
    local dealershipId = data.dealershipId
    local vehicleColor = data.color
    local vehicleModel = data.spawnCode
    
    -- Control keys for vehicle placement
    local leftRotateKey = 44   -- Q
    local rightRotateKey = 38  -- E
    local moveForwardKey = 32  -- W
    local moveBackKey = 33     -- S
    local moveLeftKey = 34     -- A
    local moveRightKey = 35    -- D
    local cancelKey = 73       -- X
    local confirmKey = 201     -- Enter
    
    SetNuiFocus(false, false)
    
    -- Show placement HUD
    SendNUIMessage({
        type = "displayVehicleHud",
        vehiclePlaced = false,
        locale = Locale,
        config = Config
    })
    
    -- Wait for initial confirmation
    while true do
        if IsControlJustPressed(0, confirmKey) then
            break
        end
        Wait(0)
    end
    
    -- Update HUD to show placement mode
    SendNUIMessage({
        type = "displayVehicleHud",
        vehiclePlaced = true,
        locale = Locale,
        config = Config
    })
    
    vehiclePlacementActive = true
    
    -- Request vehicle model
    lib.requestModel(vehicleModel)
    
    -- Get player heading and spawn position
    local playerHeading = GetEntityHeading(cache.ped)
    local spawnCoords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 3.0, 0.0)
    
    -- Create preview vehicle
    local previewVehicle = CreateVehicle(vehicleModel, spawnCoords.x, spawnCoords.y, spawnCoords.z - 1.0, 0.0, false, false)
    
    -- Freeze player during placement
    FreezeEntityPosition(cache.ped, true)
    
    -- Configure preview vehicle
    SetEntityRotation(previewVehicle, 0.0, 0.0, playerHeading, 2, true)
    SetEntityAlpha(previewVehicle, 200, false)
    SetEntityCollision(previewVehicle, false, false)
    SetVehicleColour(previewVehicle, vehicleColor)
    SetEntityCanBeDamaged(previewVehicle, false)
    FreezeEntityPosition(previewVehicle, true)
    SetEntityInvincible(previewVehicle, true)
    SetVehicleGravity(previewVehicle, false)
    SetEntityDynamic(previewVehicle, false)
    DisableVehicleWorldCollision(previewVehicle)
    SetVehicleOnGroundProperly(previewVehicle)
    SetModelAsNoLongerNeeded(vehicleModel)
    
    -- Vehicle placement loop
    while vehiclePlacementActive do
        Wait(0)
        
        -- Check for collisions
        local hasCollision = false
        if showroomOpen then
            hasCollision = checkVehicleCollision(previewVehicle)
        end
        
        -- Disable controls during placement
        for _, controlId in ipairs(placementControls) do
            DisableControlAction(0, controlId, true)
        end
        
        -- Set outline color based on collision
        if hasCollision then
            SetEntityDrawOutlineColor(254, 77, 77, 255) -- Red
        else
            SetEntityDrawOutlineColor(106, 226, 119, 255) -- Green
        end
        
        -- Enable outline
        SetEntityDrawOutlineShader(1)
        SetEntityDrawOutline(previewVehicle, true)
        
        -- Handle rotation controls
        if IsDisabledControlPressed(0, leftRotateKey) then
            rotateVehicle(previewVehicle, -0.5)
        elseif IsControlPressed(0, rightRotateKey) then
            rotateVehicle(previewVehicle, 0.5)
        end
        
        -- Handle movement controls
        if IsControlPressed(0, moveForwardKey) then
            moveVehicle(previewVehicle, "forward", 0.025)
        elseif IsControlPressed(0, moveBackKey) then
            moveVehicle(previewVehicle, "backward", 0.025)
        elseif IsControlPressed(0, moveLeftKey) then
            moveVehicle(previewVehicle, "left", 0.025)
        elseif IsControlPressed(0, moveRightKey) then
            moveVehicle(previewVehicle, "right", 0.025)
        end
        
        -- Handle cancel
        if IsControlJustPressed(0, cancelKey) then
            DeleteEntity(previewVehicle)
            vehiclePlacementActive = false
            FreezeEntityPosition(cache.ped, false)
            SetEntityDrawOutline(previewVehicle, false)
            SendNUIMessage({type = "hide"})
            ClearPedTasks(cache.ped)
            TriggerEvent("jg-dealerships:client:open-management", dealershipId)
            return callback(true)
        end
        
        -- Handle placement confirmation
        if IsDisabledControlJustPressed(0, confirmKey) then
            if not checkVehicleCollision(previewVehicle) then
                -- Valid placement - save the vehicle
                local finalCoords = GetEntityCoords(previewVehicle)
                local finalHeading = GetEntityHeading(previewVehicle)
                local finalPosition = vector4(finalCoords.x, finalCoords.y, finalCoords.z, finalHeading)
                
                DeleteEntity(previewVehicle)
                vehiclePlacementActive = false
                FreezeEntityPosition(cache.ped, false)
                SetEntityDrawOutline(previewVehicle, false)
                SendNUIMessage({type = "hide"})
                ClearPedTasks(cache.ped)
                
                -- Create display vehicle on server
                lib.callback.await("jg-dealerships:server:create-display-vehicle", false, dealershipId, vehicleModel, vehicleColor, finalPosition)
                
                TriggerEvent("jg-dealerships:client:open-management", dealershipId)
                showroomOpen = false
                return callback(true)
            else
                -- Invalid placement - show error
                local errorMessage = Locale.errorPlacementCollision or "You can't place the vehicle here"
                Framework.Client.Notify(errorMessage, "error")
            end
        end
        
        -- Keep vehicle positioned correctly
        local currentCoords = GetEntityCoords(previewVehicle)
        SetEntityCoordsNoOffset(previewVehicle, currentCoords.x, currentCoords.y, currentCoords.z, false, false, false)
    end
end)

-- Register NUI callback for editing display vehicles
RegisterNUICallback("edit-display-vehicle", function(data, callback)
    local vehicleId = data.id
    local dealershipId = data.dealershipId
    local vehicleModel = data.spawnCode
    local vehicleColor = data.color
    
    lib.callback.await("jg-dealerships:server:edit-display-vehicle", false, dealershipId, vehicleId, vehicleModel, vehicleColor)
    callback(true)
end)

-- Register NUI callback for deleting display vehicles
RegisterNUICallback("delete-display-vehicle", function(data, callback)
    local vehicleId = data.id
    local dealershipId = data.dealershipId
    
    lib.callback.await("jg-dealerships:server:delete-display-vehicle", false, dealershipId, vehicleId)
    callback(true)
end)

-- Register NUI callback for resetting display vehicles
RegisterNUICallback("reset-display-vehicles", function(data, callback)
    local dealershipId = data.dealershipId
    spawnDealershipDisplayVehicles(dealershipId)
    callback(true)
end)

-- Thread to remove AI vehicles around dealerships
CreateThread(function()
    local removalRadius = Config.RemoveGeneratorsAroundDealership
    if removalRadius and removalRadius > 0 then
        while true do
            for dealershipId, dealershipConfig in pairs(Config.DealershipLocations) do
                local coords = dealershipConfig.openShowroom and dealershipConfig.openShowroom.coords or dealershipConfig.openShowroom
                local radius = removalRadius or 60.0
                
                RemoveVehiclesFromGeneratorsInArea(
                    coords.x - radius, coords.y - radius, coords.z - radius,
                    coords.x + radius, coords.y + radius, coords.z + radius
                )
            end
            Wait(5000)
        end
    end
end)

-- Handle player entering display vehicles (security system)
lib.onCache("vehicle", function(vehicle)
    if vehicle then
        local isDisplayVehicle = Entity(vehicle).state.isDisplayVehicle
        if isDisplayVehicle then
            Framework.Client.Notify("Vehicle security breach detected", "warning")
            FreezeEntityPosition(vehicle, true)
            SetVehicleAlarm(vehicle, true)
            StartVehicleAlarm(vehicle)
        end
    end
end)

-- Clean up on resource stop
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for dealershipId in pairs(Config.DealershipLocations) do
            cleanupDisplayVehicles(dealershipId)
        end
    end
end)