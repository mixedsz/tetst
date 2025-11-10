-- Register net event for opening dealership management interface
RegisterNetEvent("jg-dealerships:client:open-management", function(dealershipId, fromAdmin)
    local dealershipConfig = Config.DealershipLocations[dealershipId]
    
    -- Get dealership data from server
    local dealershipData = lib.callback.await("jg-dealerships:server:get-dealership-data", false, dealershipId)
    
    -- Set NUI focus for management interface
    SetNuiFocus(true, true)
    
    -- Send management data to NUI
    SendNUIMessage({
        type = "showAdmin",
        shopType = dealershipConfig.type,
        dealershipId = dealershipId,
        ownerId = dealershipData.ownerId,
        name = dealershipData.name,
        balance = dealershipData.balance or 0,
        commission = dealershipData.commission or 10,
        playerName = dealershipData.playerName,
        employeeRole = dealershipData.employeeRole,
        stats = dealershipData.stats,
        fromAdmin = fromAdmin or false,
        nearbyPlayers = dealershipData.nearbyPlayers,
        playerBalance = {
            bank = Framework.Client.GetBalance("bank"),
            cash = Framework.Client.GetBalance("cash")
        },
        roles = {"CEO", "Owner", "Employee"},
        locale = Locale,
        config = Config
    })
end)

-- Register NUI callback for opening dealership management from UI
RegisterNUICallback("open-dealership-management", function(data, callback)
    TriggerEvent("jg-dealerships:client:open-management", data.id, data.fromAdmin)
    callback(true)
end)

-- Register NUI callback for getting dealership balance
RegisterNUICallback("get-dealership-balance", function(data, callback)
    local result = lib.callback.await("jg-dealerships:server:get-dealership-balance", false, data.dealership)
    callback(result)
end)

-- Register NUI callback for getting dealership vehicles
RegisterNUICallback("get-dealership-vehicles", function(data, callback)
    local result = lib.callback.await("jg-dealerships:server:get-dealership-vehicles", false, data)
    callback(result)
end)

-- Register NUI callback for getting dealership display vehicles
RegisterNUICallback("get-dealership-display-vehicles", function(data, callback)
    local result = lib.callback.await("jg-dealerships:server:get-dealership-display-vehicles", false, data)
    callback(result)
end)

-- Register NUI callback for getting dealership orders
RegisterNUICallback("get-dealership-orders", function(data, callback)
    local result = lib.callback.await("jg-dealerships:server:get-dealership-orders", false, data)
    callback(result)
end)

-- Register NUI callback for getting dealership sales
RegisterNUICallback("get-dealership-sales", function(data, callback)
    local result = lib.callback.await("jg-dealerships:server:get-dealership-sales", false, data)
    callback(result)
end)

-- Register NUI callback for getting dealership employees
RegisterNUICallback("get-dealership-employees", function(data, callback)
    local result = lib.callback.await("jg-dealerships:server:get-dealership-employees", false, data)
    callback(result)
end)

-- Register NUI callback for ordering vehicles
RegisterNUICallback("order-vehicle", function(data, callback)
    local result = lib.callback.await("jg-dealerships:server:order-vehicle", false, data.dealership, data.spawnCode, data.quantity)
    callback(result)
end)

-- Register NUI callback for canceling vehicle orders
RegisterNUICallback("cancel-vehicle-order", function(data, callback)
    local result = lib.callback.await("jg-dealerships:server:cancel-vehicle-order", false, data.orderId)
    callback(result)
end)

-- Register NUI callback for updating dealership balance (deposit/withdraw)
RegisterNUICallback("update-dealership-balance", function(data, callback)
    local action = data.action
    
    if action == "deposit" then
        local result = lib.callback.await("jg-dealerships:server:dealership-deposit", false, data.dealership, data.source, data.amount)
        return callback(result)
    elseif action == "withdraw" then
        local result = lib.callback.await("jg-dealerships:server:dealership-withdraw", false, data.dealership, data.amount)
        return callback(result)
    end
    
    -- Return error if action is not recognized
    return callback({error = true})
end)

-- Register NUI callback for updating vehicle price
RegisterNUICallback("update-vehicle-price", function(data, callback)
    local vehicleId = data.vehicle
    local dealershipId = data.dealership
    local newPrice = data.newPrice
    
    TriggerServerEvent("jg-dealerships:server:update-vehicle-price", dealershipId, vehicleId, newPrice)
    callback(true)
end)

-- Register NUI callback for updating dealership settings
RegisterNUICallback("update-dealership-settings", function(data, callback)
    local dealershipId = data.dealership
    
    TriggerServerEvent("jg-dealerships:server:update-dealership-settings", dealershipId, data)
    callback(true)
end)