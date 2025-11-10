-- Vehicle type classification function
function GetVehicleTypeFromModel(modelHash)
    local vehicleType = nil
    local vehicleClass = GetVehicleClassFromName(modelHash)
    
    if IsThisModelACar(modelHash) then
        vehicleType = "automobile"
    elseif IsThisModelABicycle(modelHash) then
        vehicleType = "bike"
    elseif IsThisModelABike(modelHash) then
        vehicleType = "bike"
    elseif IsThisModelABoat(modelHash) then
        vehicleType = "boat"
    elseif IsThisModelAHeli(modelHash) then
        vehicleType = "heli"
    elseif IsThisModelAPlane(modelHash) then
        vehicleType = "plane"
    elseif IsThisModelAQuadbike(modelHash) then
        vehicleType = "automobile"
    elseif IsThisModelATrain(modelHash) then
        vehicleType = "train"
    elseif vehicleClass == 5 then
        vehicleType = "automobile"
    elseif vehicleClass == 14 then
        vehicleType = "submarine"
    elseif vehicleClass == 16 then
        vehicleType = "heli"
    else
        vehicleType = "trailer"
    end
    
    return vehicleType
end

-- Apply vehicle properties and set fuel
function ApplyVehiclePropertiesAndFuel(vehicle, properties)
    if properties then
        if type(properties) == "table" then
            -- Fix: Use SetVehicleColours (plural) with proper parameters
            if properties.colour then
                if type(properties.colour) == "table" then
                    -- If colour is a table with primary/secondary
                    SetVehicleColours(vehicle, properties.colour.primary or properties.colour[1] or 0, properties.colour.secondary or properties.colour[2] or 0)
                else
                    -- If colour is a single value, use it for both primary and secondary
                    SetVehicleColours(vehicle, properties.colour, properties.colour)
                end
            end
            
            if properties.plate then
                SetVehicleNumberPlateText(vehicle, properties.plate)
            end
        end
    end
    
    Framework.Client.VehicleSetFuel(vehicle, 100.0)
    
    local isNotNetworked = not NetworkGetEntityIsNetworked(vehicle)
    return isNotNetworked
end

-- Validate vehicle model and plate
function ValidateVehicleModelAndPlate(modelName, plateText)
    local modelHash = ConvertModelToHash(modelName)
    local vehicleType = GetVehicleTypeFromModel(modelHash)
    local modelExists = IsModelInCdimage(modelHash)
    
    if not modelExists then
        Framework.Client.Notify("Vehicle model does not exist - contact an admin", "error")
        print(string.format("^1Vehicle model %s does not exist", modelName))
        return false
    end
    
    local hasSeats = GetVehicleModelNumberOfSeats(modelHash) > 0
    
    if plateText and plateText ~= "" then
        local isValidPlate = IsValidGTAPlate(plateText)
        if not isValidPlate then
            Framework.Client.Notify("This vehicle's plate is invalid (hit F8 for more details)", "error")
            print(string.format("^1This vehicle is trying to spawn with the plate '%s' which is invalid for a GTA vehicle plate", plateText:upper()))
            print("^1Vehicle plates must be 8 characters long maximum, and can contain ONLY numbers, letters and spaces")
            return false
        end
    end
    
    lib.requestModel(modelHash, 60000)
    
    if IsPedRagdoll(cache.ped) then
        Framework.Client.Notify("You are currently in a ragdoll state", "error")
        SetModelAsNoLongerNeeded(modelHash)
        return false
    end
    
    return modelHash, vehicleType, hasSeats
end

-- Finalize vehicle spawn (set properties, keys, etc.)
function FinalizeVehicleSpawn(vehicle, vehicleId, modelHash, shouldWarpInto, plateText, properties, giveKeys)
    if not vehicle or vehicle == 0 then
        Framework.Client.Notify("Could not spawn vehicle - hit F8 for details", "error")
        print("^1Vehicle does not exist (vehicle = 0)")
        return false
    end
    
    if IsPedRagdoll(cache.ped) then
        Framework.Client.Notify("You are currently in a ragdoll state", "error")
        SetModelAsNoLongerNeeded(modelHash)
        return false
    end
    
    if shouldWarpInto then
        ClearPedTasks(cache.ped)
        local warpSuccess = pcall(function()
            lib.waitFor(function()
                local driverPed = GetPedInVehicleSeat(vehicle, -1)
                if driverPed == cache.ped then
                    return true
                end
                TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
            end, nil, 5000)
        end)
        
        if not warpSuccess then
            print("^1[ERROR] Could not warp you into the vehicle^0")
            return false
        end
    end
    
    if plateText and plateText ~= "" then
        SetVehicleNumberPlateText(vehicle, plateText)
    end
    
    if properties then
        if type(properties) == "table" then
            ApplyVehiclePropertiesAndFuel(vehicle, properties)
        end
    end
    
    -- Handle fake plates if resource is available
    local fakePlateResourceState = GetResourceState("brazzers-fakeplates")
    if fakePlateResourceState == "started" then
        local fakePlate = lib.callback.await("jg-dealerships:server:brazzers-get-fakeplate-from-plate", false, plateText)
        if fakePlate then
            plateText = fakePlate
            SetVehicleNumberPlateText(vehicle, fakePlate)
        end
    end
    
    -- Ensure we have a plate
    if not plateText or plateText == "" then
        plateText = Framework.Client.GetPlate(vehicle)
    end
    
    if not plateText or plateText == "" then
        print("^1[ERROR] The game thinks the vehicle has no plate - absolutely no idea how you've managed this")
        return false
    end
    
    -- Set vehicle ID in entity state
    local entityState = Entity(vehicle).state
    entityState:set("vehicleid", vehicleId, true)
    
    -- Give keys to player
    Framework.Client.VehicleGiveKeys(plateText, vehicle, giveKeys)
    
    return true
end

-- Handle server-created vehicle (network spawning)
function HandleServerCreatedVehicle(networkId, teleportCoords, shouldWarpInto, modelHash, vehicleId, plateText, properties, giveKeys)
    SetModelAsNoLongerNeeded(modelHash)
    
    if not networkId then
        Framework.Client.Notify("Could not spawn vehicle - hit F8 for details", "error")
        print("^1Server returned false for netId")
        return false
    end
    
    -- Wait for network ID to exist
    lib.waitFor(function()
        if NetworkDoesNetworkIdExist(networkId) then
            if NetworkDoesEntityExistWithNetworkId(networkId) then
                return true
            end
        end
        return nil
    end, "Timed out while waiting for a server-setter netId to exist on client", 10000)
    
    local vehicle = NetToVeh(networkId)
    
    -- Wait for vehicle entity to exist
    lib.waitFor(function()
        if not DoesEntityExist(vehicle) then
            return nil
        end
        return true
    end, "Timed out while waiting for a server-setter vehicle to exist on client", 10000)
    
    -- Teleport player if coordinates provided
    if teleportCoords then
        SetEntityCoords(cache.ped, teleportCoords.x, teleportCoords.y, teleportCoords.z, false, false, false, false)
    end
    
    -- Finalize the vehicle spawn
    local success = FinalizeVehicleSpawn(vehicle, vehicleId, modelHash, shouldWarpInto, plateText, properties, giveKeys)
    
    if not success then
        DeleteEntity(vehicle)
        return false
    end
    
    return true
end

-- Create vehicle locally (client-side spawning)
function CreateVehicleLocally(modelHash, coords, plateText, isNetworked)
    lib.requestModel(modelHash, 60000)
    
    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, coords.w, 
        isNetworked or false, isNetworked or false)
    
    -- Wait for vehicle to exist
    lib.waitFor(function()
        if not DoesEntityExist(vehicle) then
            return nil
        end
        return true
    end, "Timed out while trying to spawn in vehicle (client)", 10000)
    
    SetModelAsNoLongerNeeded(modelHash)
    
    if plateText and plateText ~= "" then
        SetVehicleNumberPlateText(vehicle, plateText)
    end
    
    return vehicle
end

-- Main client-side vehicle spawning function
function SpawnVehicleClient(vehicleId, modelName, plateText, coords, shouldWarpInto, properties, giveKeys)
    if Config.SpawnVehiclesWithServerSetter then
        print("^1This function is disabled as client spawning is enabled")
        return false
    end
    
    local modelHash, vehicleType, hasSeats = ValidateVehicleModelAndPlate(modelName, plateText)
    if not modelHash then
        return false
    end
    
    local vehicle = CreateVehicleLocally(modelHash, coords, plateText, true)
    if not vehicle then
        return false
    end
    
    local success = FinalizeVehicleSpawn(vehicle, vehicleId, modelHash, 
        hasSeats and shouldWarpInto or false, plateText, properties, giveKeys)
    
    if not success then
        DeleteEntity(vehicle)
        return false
    end
    
    return vehicle
end

-- State bag handler for vehicle initialization
AddStateBagChangeHandler("vehInit", "", function(bagName, key, value)
    if not value then
        return
    end
    
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 then
        return
    end
    
    -- Wait for world collision to finish
    lib.waitFor(function()
        return not IsEntityWaitingForWorldCollision(entity)
    end)
    
    local entityOwner = NetworkGetEntityOwner(entity)
    if entityOwner ~= cache.playerId then
        return
    end
    
    local entityState = Entity(entity).state
    
    -- Set vehicle on ground properly
    SetVehicleOnGroundProperly(entity)
    
    -- Clear the state after processing
    SetTimeout(0, function()
        entityState:set("vehInit", nil, true)
    end)
end)

-- State bag handler for dealership vehicle property application
AddStateBagChangeHandler("dealershipVehCreatedApplyProps", "", function(bagName, key, value)
    if not value then
        return
    end
    
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 then
        return
    end
    
    SetTimeout(0, function()
        local entityState = Entity(entity).state
        local attempts = 0
        
        while attempts < 10 do
            local entityOwner = NetworkGetEntityOwner(entity)
            if entityOwner == cache.playerId then
                local success = ApplyVehiclePropertiesAndFuel(entity, value)
                if success then
                    entityState:set("dealershipVehCreatedApplyProps", nil, true)
                    break
                end
            end
            attempts = attempts + 1
            Wait(100)
        end
    end)
end)

-- Register client callbacks
lib.callback.register("jg-dealerships:client:req-vehicle-and-get-spawn-details", ValidateVehicleModelAndPlate)
lib.callback.register("jg-dealerships:client:on-server-vehicle-created", HandleServerCreatedVehicle)