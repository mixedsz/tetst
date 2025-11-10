-- Admin UI client handlers for jg-dealerships
-- Fully patched: all NUI callbacks always return JSON-safe objects

-- Register event to open the admin UI
RegisterNetEvent("jg-dealerships:client:open-admin", function()
    local adminData = lib.callback.await("jg-dealerships:server:get-admin-data", false)

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "vehiclesAdmin",
        dealers = adminData.dealerships,
        vehicles = adminData.vehicles,
        nearbyPlayers = adminData.nearbyPlayers,
        config = Config,
        locale = Locale
    })
end)

-- NUI callback: trigger the open-admin event
RegisterNUICallback("open-admin", function(_, cb)
    TriggerEvent("jg-dealerships:client:open-admin")
    cb({ success = true })
end)

-- NUI callback: Add a vehicle
RegisterNUICallback("add-vehicle", function(data, cb)
    lib.callback.await(
        "jg-dealerships:server:add-vehicle",
        false,
        data.spawn_code,
        data.brand,
        data.model,
        data.category,
        data.price,
        data.dealerships
    )
    cb({ success = true })
end)

-- NUI callback: Update a vehicle
RegisterNUICallback("update-vehicle", function(data, cb)
    local updateDealerPrices = data.updateDealerPrices or false

    lib.callback.await(
        "jg-dealerships:server:update-vehicle",
        false,
        data.spawn_code,
        data.brand,
        data.model,
        data.category,
        data.price,
        data.dealerships,
        updateDealerPrices
    )
    cb({ success = true })
end)

-- NUI callback: Delete a vehicle
RegisterNUICallback("delete-vehicle", function(data, cb)
    lib.callback.await("jg-dealerships:server:delete-vehicle", false, data.spawn_code)
    cb({ success = true })
end)

-- NUI callback: Delete dealership data
RegisterNUICallback("delete-dealership-data", function(data, cb)
    local serverResponse = lib.callback.await("jg-dealerships:server:delete-dealership-data", false, data.dealershipId)
    TriggerEvent("jg-dealerships:client:open-admin")
    cb({ success = true, response = serverResponse })
end)

-- NUI callback: Set dealership owner
RegisterNUICallback("set-dealership-owner", function(data, cb)
    local serverResponse = lib.callback.await(
        "jg-dealerships:server:set-dealership-owner",
        false,
        data.dealershipId,
        data.player
    )
    TriggerEvent("jg-dealerships:client:open-admin")
    cb({ success = true, response = serverResponse })
end)

-- NUI callback: Import vehicles data
RegisterNUICallback("import-vehicles-data", function(data, cb)
    local serverResponse = lib.callback.await(
        "jg-dealerships:server:import-vehicles-data",
        false,
        data.location,
        data.behaviour
    )
    TriggerEvent("jg-dealerships:client:open-admin")
    cb({ success = true, response = serverResponse })
end)

-- NUI callback: Verify spawn code
RegisterNUICallback("verify-spawn-code", function(data, cb)
    if not data.spawnCode then
        return cb({ success = false, valid = false, message = "Missing spawnCode" })
    end
    local modelHash = GetHashKey(data.spawnCode)
    local isValid = IsModelValid(modelHash) and true or false
    cb({ success = true, valid = isValid })
end)

-- NUI callback: Close admin UI
RegisterNUICallback("close-admin", function(_, cb)
    SetNuiFocus(false, false)
    cb({ success = true })
end)
