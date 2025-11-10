-- Register net event for selling vehicle to dealer
RegisterNetEvent("jg-dealerships:client:sell-vehicle", function(dealershipId)
    local currentVehicle = cache.vehicle
    
    -- Check if player is in a vehicle
    if not currentVehicle then
        return Framework.Client.Notify(Locale.notInVehicle, "error")
    end
    
    -- Get vehicle plate
    local vehiclePlate = Framework.Client.GetPlate(currentVehicle)
    if not vehiclePlate then
        return
    end
    
    -- Get vehicle model name
    local vehicleModel = GetEntityArchetypeName(currentVehicle)
    
    -- Debug logging
    DebugPrint("Trying to sell vehicle with plate: " .. vehiclePlate .. " and model: " .. vehicleModel, "debug")
    
    -- Get vehicle sell value from server
    local sellValue = lib.callback.await("jg-dealerships:server:sell-vehicle-get-value", false, dealershipId, vehiclePlate, vehicleModel)
    
    if not sellValue then
        return
    end
    
    -- Open NUI interface for vehicle selling
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        type = "sell-vehicle-to-dealer",
        dealershipId = dealershipId,
        plate = vehiclePlate,
        value = sellValue,
        config = Config,
        locale = Locale
    })
end)

-- Register NUI callback for when sell price is accepted
RegisterNUICallback("sell-vehicle-price-accepted", function(data, callback)
    local currentVehicle = cache.vehicle
    
    -- Verify player is still in vehicle
    if not currentVehicle then
        return callback(false)
    end
    
    local vehicle = currentVehicle
    local vehiclePlate = Framework.Client.GetPlate(vehicle)
    
    if not vehiclePlate then
        return callback(false)
    end
    
    local vehicleModel = GetEntityArchetypeName(vehicle)
    
    -- Process vehicle sale on server
    local saleSuccess = lib.callback.await("jg-dealerships:server:sell-vehicle", 2500, data.dealershipId, vehiclePlate, vehicleModel)
    
    if not saleSuccess then
        return callback(false)
    end
    
    -- Get dealership location for teleporting
    local dealershipLocation = Config.DealershipLocations[data.dealershipId]
    local showroomCoords = nil
    
    if dealershipLocation and dealershipLocation.openShowroom then
        showroomCoords = dealershipLocation.openShowroom.coords
    end
    
    -- Fade screen out for transition
    DoScreenFadeOut(500)
    Wait(500)
    
    -- Remove all passengers from vehicle (seats -1 to 5)
    for seatIndex = -1, 5, 1 do
        local pedestrianInSeat = GetPedInVehicleSeat(vehicle, seatIndex)
        
        if pedestrianInSeat then
            TaskLeaveVehicle(pedestrianInSeat, vehicle, 0)
            
            -- Teleport ped to showroom if coordinates available
            if showroomCoords then
                SetEntityCoords(pedestrianInSeat, showroomCoords.x, showroomCoords.y, showroomCoords.z, true, false, false, false)
            end
        end
    end
    
    -- Remove vehicle keys and lock vehicle
    Framework.Client.VehicleRemoveKeys(vehiclePlate, vehicle, "vehicleSale")
    SetVehicleDoorsLocked(vehicle, 2)
    
    Wait(1500)
    
    -- Trigger configuration event for vehicle sale
    TriggerEvent("jg-dealerships:client:sell-vehicle:config", vehicle, vehiclePlate)
    
    -- Fade screen back in
    DoScreenFadeIn(500)
    
    callback(true)
end)