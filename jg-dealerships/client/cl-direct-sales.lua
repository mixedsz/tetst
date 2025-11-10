-- Register net event for opening direct sale interface
RegisterNetEvent("jg-dealerships:client:direct-sale", function()
    -- Get nearest dealership that employee has access to
    local nearestDealership = lib.callback.await("jg-dealerships:server:employee-nearest-dealership", false)
    
    if nearestDealership and nearestDealership.error then
        return -- Exit if there's an error (no access or too far)
    end
    
    -- Get dealership configuration
    local dealershipConfig = Config.DealershipLocations[nearestDealership]
    local dealershipCategories = dealershipConfig.categories
    
    -- Get direct sale data from server
    local directSaleData = lib.callback.await("jg-dealerships:server:get-direct-sale-data", false, nearestDealership)
    
    -- Play tablet animation
    PlayTabletAnim()
    
    -- Set NUI focus for direct sale interface
    SetNuiFocus(true, true)
    
    -- Send direct sale data to NUI
    SendNUIMessage({
        type = "showDSSellVehicle",
        vehicles = directSaleData.vehicles,
        nearbyPlayers = directSaleData.nearbyPlayers,
        categories = dealershipCategories,
        commission = directSaleData.commission,
        enableFinance = dealershipConfig.enableFinance,
        config = Config,
        locale = Locale
    })
end)

-- Register net event for showing direct sale request to customer
RegisterNetEvent("jg-dealerships:client:show-direct-sale-request", function(saleRequestData)
    -- Check if customer is currently in showroom
    if Globals.CurrentDealership then
        TriggerServerEvent("jg-dealerships:server:notify-other-player", 
            saleRequestData.dealerPlayerId, 
            "Customer is in the showroom! Wait for them to come back, and try again", 
            "error")
        return
    end
    
    -- Set NUI focus for sale request dialog
    SetNuiFocus(true, true)
    
    -- Build vehicle label
    local vehicleBrand = saleRequestData.vehicle.brand or ""
    local vehicleModel = saleRequestData.vehicle.model or ""
    local vehicleLabel = vehicleBrand .. " " .. vehicleModel
    
    -- Get player balances for the dealership
    local playerBalances = GetPlayerBalances(saleRequestData.dealershipId)
    
    -- Send sale request data to NUI
    SendNUIMessage({
        type = "show-direct-sale-request",
        uuid = saleRequestData.uuid,
        dealerPlayerId = saleRequestData.dealerPlayerId,
        dealerName = saleRequestData.dealerName,
        dealershipId = saleRequestData.dealershipId,
        dealershipLabel = saleRequestData.dealershipLabel,
        playerBalances = playerBalances,
        vehicleLabel = vehicleLabel,
        vehicleSpawnCode = saleRequestData.vehicle.spawn_code,
        vehiclePrice = saleRequestData.vehicle.price,
        color = saleRequestData.colour,
        financed = saleRequestData.financed,
        downPayment = saleRequestData.downPayment,
        noOfPayments = saleRequestData.noOfPayments,
        config = Config,
        locale = Locale
    })
end)

-- Register NUI callback for sending direct sale requests
RegisterNUICallback("send-direct-sale-request", function(requestData, callback)
    -- Verify employee has access to nearest dealership
    local nearestDealership = lib.callback.await("jg-dealerships:server:employee-nearest-dealership", false)
    
    if nearestDealership and nearestDealership.error then
        return callback({error = true})
    end
    
    -- Send direct sale request to server
    local requestSent = lib.callback.await("jg-dealerships:server:send-direct-sale-request", false, nearestDealership, requestData)
    
    if not requestSent then
        return callback({error = true})
    end
    
    callback(true)
end)

-- Register NUI callback for accepting direct sale requests
RegisterNUICallback("accept-direct-sale-request", function(requestData, callback)
    -- Close NUI interface
    SetNuiFocus(false, false)
    
    -- Process sale acceptance on server
    local acceptanceResult = lib.callback.await("jg-dealerships:server:direct-sale-request-accepted", false, requestData)
    
    if not acceptanceResult then
        return callback({error = true})
    end
    
    callback(true)
end)

-- Register NUI callback for denying direct sale requests
RegisterNUICallback("deny-direct-sale-request", function(requestData, callback)
    -- Close NUI interface
    SetNuiFocus(false, false)
    
    -- Process sale denial on server
    local denialResult = lib.callback.await("jg-dealerships:server:direct-sale-request-denied", false, requestData)
    
    if not denialResult then
        return callback({error = true})
    end
    
    callback(true)
end)

-- Register command for opening direct sale interface
local directSaleCommand = Config.DirectSaleCommand or "directsale"

RegisterCommand(directSaleCommand, function()
    TriggerEvent("jg-dealerships:client:direct-sale")
end, false)