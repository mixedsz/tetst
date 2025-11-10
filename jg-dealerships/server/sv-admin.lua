-- sv-admin.lua
-- Server-side admin handlers for jg-dealerships
-- De-obfuscated and rewritten for clarity.
-- All original logic preserved.

local dealerAdminCommand = Config.DealerAdminCommand or "dealeradmin"

-- Add admin command to open the admin UI (server -> client trigger)
lib.addCommand(dealerAdminCommand, false, function(source)
    -- Check admin permission using framework server helper
    if not Framework.Server.IsAdmin(source) then
        Framework.Server.Notify(source, "INSUFFICIENT_PERMISSIONS", "error")
        DebugPrint("Player " .. tostring(source) .. " tried to access the dealer admin panel without permission", "warning")
        return
    end

    -- Trigger client open admin UI
    TriggerClientEvent("jg-dealerships:client:open-admin", source)
end)

-- Callback: get admin data (vehicles, dealerships, nearby players)
lib.callback.register("jg-dealerships:server:get-admin-data", function(source)
    -- Permission check
    if not Framework.Server.IsAdmin(source) then
        Framework.Server.Notify(source, "INSUFFICIENT_PERMISSIONS", "error")
        DebugPrint("Player " .. tostring(source) .. " tried to get admin data without permission", "warning")
        return { success = false, error = true }
    end

    -- Fetch dealership data from DB
    local dealershipsRaw = MySQL.query.await("SELECT * FROM dealership_data")
    local dealerships = {}

    for _, row in pairs(dealershipsRaw) do
        local configEntry = Config.DealershipLocations[row.name]
        local dType = "-"
        local active = false
        if configEntry then
            dType = configEntry.type
            active = true
        end

        table.insert(dealerships, {
            name = row.name,
            type = dType,
            label = row.label,
            balance = row.balance,
            active = active,
            owner_id = row.owner_id,
            owner_name = row.owner_name,
            config = configEntry
        })
    end

    -- Fetch vehicles with associated dealerships (grouped)
    local vehiclesRaw = MySQL.query.await([[
        SELECT vehicle.spawn_code,
               MAX(vehicle.brand) AS brand,
               MAX(vehicle.model) AS model,
               MAX(vehicle.category) AS category,
               MAX(vehicle.price) AS price,
               MAX(vehicle.created_at) AS created_at,
               IFNULL(CONCAT('[', GROUP_CONCAT(CONCAT('\"', dealer.name, '\"')), ']'), '[]') as dealers
        FROM dealership_vehicles vehicle
        LEFT JOIN dealership_stock stock ON vehicle.spawn_code = stock.vehicle
        LEFT JOIN dealership_data dealer ON dealer.name = stock.dealership
        GROUP BY vehicle.spawn_code
        ORDER BY MAX(vehicle.created_at) DESC;
    ]])

    local vehicles = {}
    for _, v in pairs(vehiclesRaw) do
        table.insert(vehicles, {
            spawn_code = v.spawn_code,
            brand = v.brand,
            model = v.model,
            category = v.category,
            price = v.price,
            dealerships = json.decode(v.dealers),
            created_at = v.created_at
        })
    end

    -- Get nearby players (uses helper GetNearbyPlayers)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local nearbyPlayers = GetNearbyPlayers(source, playerCoords, 10.0, true)

    return {
        vehicles = vehicles,
        dealerships = dealerships,
        nearbyPlayers = nearbyPlayers
    }
end)

-- Callback: add vehicle
lib.callback.register("jg-dealerships:server:add-vehicle", function(source, spawn_code, brand, model, category, price, dealerships)
    if not Framework.Server.IsAdmin(source) then
        Framework.Server.Notify(source, "INSUFFICIENT_PERMISSIONS", "error")
        DebugPrint("Player " .. tostring(source) .. " tried to add a vehicle without permission", "warning")
        return { success = false, error = true }
    end

    DebugPrint("Adding vehicle with spawn code: " .. tostring(spawn_code) .. ", trimmed: " .. Trim(spawn_code), "debug")
    spawn_code = Trim(spawn_code)

    -- Insert vehicle
    MySQL.query.await(
        "INSERT INTO dealership_vehicles (spawn_code, hashkey, brand, model, category, price) VALUES(?, ?, ?, ?, ?, ?)",
        { spawn_code, joaat(spawn_code), brand, model, category, price }
    )

    -- Insert stock rows for each dealership
    for _, dealerName in ipairs(dealerships) do
        MySQL.query.await(
            "INSERT IGNORE INTO dealership_stock (vehicle, dealership, price) VALUES (?, ?, ?)",
            { spawn_code, dealerName, price }
        )
    end

    -- Send webhook and update caches
    SendWebhook(source, Webhooks.Admin, "Admin: Add Vehicle", "success", {
        { key = "Vehicle", value = spawn_code },
        { key = "Name", value = tostring(brand) .. " " .. tostring(model) },
        { key = "Category", value = category },
        { key = "Price", value = price },
        { key = "Dealerships", value = #dealerships .. " dealership(s)" }
    })

    UpdateAllDealershipsShowroomCache()
    return { success = true }
end)

-- Callback: update vehicle
lib.callback.register("jg-dealerships:server:update-vehicle", function(source, spawn_code, brand, model, category, price, dealerships, updateDealerPrices)
    if not Framework.Server.IsAdmin(source) then
        Framework.Server.Notify(source, "INSUFFICIENT_PERMISSIONS", "error")
        DebugPrint("Player " .. tostring(source) .. " tried to update a vehicle without permission", "warning")
        return { success = false, error = true }
    end

    DebugPrint("Updating vehicle with spawn code: " .. tostring(spawn_code) .. ", trimmed: " .. Trim(spawn_code), "debug")
    spawn_code = Trim(spawn_code)

    -- Update vehicle row
    MySQL.query.await(
        "UPDATE dealership_vehicles SET brand = ?, model = ?, category = ?, price = ? WHERE spawn_code = ?",
        { brand, model, category, price, spawn_code }
    )

    -- Remove stock entries not in the provided dealerships list
    if #dealerships > 0 then
        MySQL.query.await(
            "DELETE FROM dealership_stock WHERE vehicle = ? AND dealership NOT IN (?)",
            { spawn_code, dealerships }
        )
    else
        MySQL.query.await("DELETE FROM dealership_stock WHERE vehicle = ?", { spawn_code })
    end

    -- Re-insert stock rows for provided dealerships
    for _, dealerName in ipairs(dealerships) do
        MySQL.query.await(
            "INSERT IGNORE INTO dealership_stock (vehicle, dealership, price) VALUES (?, ?, ?)",
            { spawn_code, dealerName, price }
        )
    end

    -- Optionally update all stock prices for this vehicle
    if updateDealerPrices then
        MySQL.query.await("UPDATE dealership_stock SET price = ? WHERE vehicle = ?", { price, spawn_code })
    end

    -- Send webhook and update caches
    SendWebhook(source, Webhooks.Admin, "Admin: Vehicle Updated", nil, {
        { key = "Vehicle", value = spawn_code },
        { key = "Name", value = tostring(brand) .. " " .. tostring(model) },
        { key = "Category", value = category },
        { key = "Price", value = price },
        { key = "Dealerships", value = #dealerships .. " dealership(s)" }
    })

    UpdateAllDealershipsShowroomCache()
    return { success = true }
end)

-- Callback: delete vehicle
lib.callback.register("jg-dealerships:server:delete-vehicle", function(source, spawn_code)
    if not Framework.Server.IsAdmin(source) then
        Framework.Server.Notify(source, "INSUFFICIENT_PERMISSIONS", "error")
        DebugPrint("Player " .. tostring(source) .. " tried to delete a vehicle without permission", "warning")
        return { success = false, error = true }
    end

    -- Remove all references to the vehicle
    MySQL.query.await("DELETE FROM dealership_stock WHERE vehicle = ?", { spawn_code })
    MySQL.query.await("DELETE FROM dealership_sales WHERE vehicle = ?", { spawn_code })
    MySQL.query.await("DELETE FROM dealership_orders WHERE vehicle = ?", { spawn_code })
    MySQL.query.await("DELETE FROM dealership_dispveh WHERE vehicle = ?", { spawn_code })
    MySQL.query.await("DELETE FROM dealership_vehicles WHERE spawn_code = ?", { spawn_code })

    SendWebhook(source, Webhooks.Admin, "Admin: Vehicle Deleted", "danger", {
        { key = "Vehicle", value = spawn_code }
    })

    UpdateAllDealershipsShowroomCache()
    return { success = true }
end)

-- Callback: delete dealership data
lib.callback.register("jg-dealerships:server:delete-dealership-data", function(source, dealershipName)
    if not Framework.Server.IsAdmin(source) then
        Framework.Server.Notify(source, "INSUFFICIENT_PERMISSIONS", "error")
        DebugPrint("Player " .. tostring(source) .. " tried to delete a dealership without permission", "warning")
        return { success = false, error = true }
    end

    MySQL.query.await("DELETE FROM dealership_stock WHERE dealership = ?", { dealershipName })
    MySQL.query.await("DELETE FROM dealership_sales WHERE dealership = ?", { dealershipName })
    MySQL.query.await("DELETE FROM dealership_orders WHERE dealership = ?", { dealershipName })
    MySQL.query.await("DELETE FROM dealership_dispveh WHERE dealership = ?", { dealershipName })
    MySQL.query.await("DELETE FROM dealership_data WHERE name = ?", { dealershipName })

    SendWebhook(source, Webhooks.Admin, "Admin: Dealership Data Deleted", "danger", {
        { key = "Dealership", value = dealershipName }
    })

    UpdateAllDealershipsShowroomCache()
    return { success = true }
end)

-- Callback: set dealership owner
lib.callback.register("jg-dealerships:server:set-dealership-owner", function(source, dealershipName, playerId)
    if not Framework.Server.IsAdmin(source) then
        Framework.Server.Notify(source, "INSUFFICIENT_PERMISSIONS", "error")
        DebugPrint("Player " .. tostring(source) .. " tried to set a dealership owner without permission", "warning")
        return { success = false, error = true }
    end

    -- Resolve identifier and player info
    local identifier = Framework.Server.GetPlayerIdentifier(tonumber(playerId) or 0)
    local playerInfo = Framework.Server.GetPlayerInfo(tonumber(playerId) or 0)

    if not playerInfo or not identifier then
        Framework.Server.Notify(source, "PLAYER_NOT_ONLINE", "error")
        return { success = false, error = true }
    end

    DebugPrint("Setting dealership owner for " .. tostring(dealershipName) .. " to " .. tostring(identifier), "debug")

    MySQL.update.await("UPDATE dealership_data SET owner_id = ?, owner_name = ? WHERE name = ?", { identifier, playerInfo.name, dealershipName })

    TriggerClientEvent("jg-dealerships:client:update-blips-text-uis", -1)

    SendWebhook(source, Webhooks.Admin, "Admin: Dealership Owner Updated", nil, {
        { key = "Dealership", value = dealershipName },
        { key = "Owner", value = playerInfo.name }
    })

    return { success = true }
end)

-- Helper: wipe dealership tables (used by import overwrite)
local function wipeDealershipTables()
    MySQL.query.await("DELETE FROM dealership_dispveh")
    MySQL.query.await("DELETE FROM dealership_orders")
    MySQL.query.await("DELETE FROM dealership_sales")
    MySQL.query.await("DELETE FROM dealership_stock")
    MySQL.query.await("DELETE FROM dealership_vehicles")
end

-- Callback: import vehicles from different frameworks/sources
lib.callback.register("jg-dealerships:server:import-vehicles-data", function(source, importSource, behaviour)
    -- QBCore Shared import
    if Config.Framework == "QBCore" and importSource == "qbshared" then
        local qbVehicles = QBCore.Shared.Vehicles

        if behaviour == "Overwrite" then
            wipeDealershipTables()
        end

        for spawnCode, vehicleData in pairs(qbVehicles) do
            MySQL.query.await(
                "INSERT IGNORE INTO dealership_vehicles (spawn_code, hashkey, brand, model, category, price) VALUES(?, ?, ?, ?, ?, ?)",
                { Trim(spawnCode), joaat(spawnCode), vehicleData.brand, vehicleData.name, vehicleData.category, vehicleData.price }
            )

            local shops = {}
            if type(vehicleData.shop) == "string" then
                shops = { vehicleData.shop }
            elseif type(vehicleData.shop) == "table" then
                shops = vehicleData.shop
            end

            for _, shopName in ipairs(shops) do
                if Config.DealershipLocations[shopName] then
                    MySQL.query.await(
                        "INSERT IGNORE INTO dealership_stock (vehicle, dealership, stock, price) VALUES(?, ?, ?, ?)",
                        { Trim(spawnCode), shopName, 0, vehicleData.price }
                    )
                end
            end
        end

        local count = MySQL.scalar.await("SELECT COUNT(*) as count FROM dealership_vehicles")
        Framework.Server.Notify(source, "Import successful! Vehicle count: " .. tostring(count), "success")
        SendWebhook(source, Webhooks.Admin, "Admin: Vehicles Imported", "success", {
            { key = "Method", value = "QBCore Shared" },
            { key = "Rows Imported", value = count }
        })
        UpdateAllDealershipsShowroomCache()
        return { success = true }
    end

    -- Qbox import
    if Config.Framework == "Qbox" and importSource == "qbx_shared" then
        local qboxVehicles = exports.qbx_core.GetVehiclesByHash()

        if behaviour == "Overwrite" then
            wipeDealershipTables()
        end

        for hash, vehicleData in pairs(qboxVehicles) do
            MySQL.query.await(
                "INSERT IGNORE INTO dealership_vehicles (spawn_code, hashkey, brand, model, category, price) VALUES(?, ?, ?, ?, ?, ?)",
                { Trim(vehicleData.model), hash, vehicleData.brand, vehicleData.name, vehicleData.category, vehicleData.price }
            )

            local shops = {}
            if vehicleData.shop then
                if type(vehicleData.shop) == "string" then
                    shops = { vehicleData.shop }
                elseif type(vehicleData.shop) == "table" then
                    shops = vehicleData.shop
                end

                for _, shopName in ipairs(shops) do
                    if Config.DealershipLocations[shopName] then
                        MySQL.query.await(
                            "INSERT IGNORE INTO dealership_stock (vehicle, dealership, stock, price) VALUES(?, ?, ?, ?)",
                            { Trim(vehicleData.model), shopName, 0, vehicleData.price }
                        )
                    end
                end
            else
                -- If no explicit shop list, distribute by category membership
                for locName, locData in pairs(Config.DealershipLocations) do
                    if IsItemInList(locData.categories, vehicleData.category) then
                        MySQL.query.await(
                            "INSERT IGNORE INTO dealership_stock (vehicle, dealership, stock, price) VALUES(?, ?, ?, ?)",
                            { Trim(vehicleData.model), locName, 0, vehicleData.price }
                        )
                    end
                end
            end
        end

        local count = MySQL.scalar.await("SELECT COUNT(*) as count FROM dealership_vehicles")
        Framework.Server.Notify(source, "Import successful! Vehicle count: " .. tostring(count), "success")
        SendWebhook(source, Webhooks.Admin, "Admin: Vehicles Imported", "success", {
            { key = "Method", value = "QBox Shared" },
            { key = "Rows Imported", value = count }
        })
        UpdateAllDealershipsShowroomCache()
        return { success = true }
    end

    -- ESX import (esxdb)
    if Config.Framework == "ESX" and importSource == "esxdb" then
        if behaviour == "Overwrite" then
            wipeDealershipTables()
        end

        local esxVehicles = MySQL.query.await("SELECT * FROM vehicles ORDER BY name DESC")
        for _, v in pairs(esxVehicles) do
            MySQL.query.await(
                "INSERT IGNORE INTO dealership_vehicles (spawn_code, hashkey, brand, model, category, price) VALUES(?, ?, ?, ?, ?, ?)",
                { Trim(v.model), joaat(v.model), nil, v.name, v.category, v.price }
            )

            for locName, locData in pairs(Config.DealershipLocations) do
                if IsItemInList(locData.categories, v.category) then
                    MySQL.query.await(
                        "INSERT IGNORE INTO dealership_stock (vehicle, dealership, stock, price) VALUES(?, ?, ?, ?)",
                        { Trim(v.model), locName, 0, v.price }
                    )
                end
            end
        end

        local count = MySQL.scalar.await("SELECT COUNT(*) as count FROM dealership_vehicles")
        Framework.Server.Notify(source, "Import successful! Vehicle count: " .. tostring(count), "success")
        SendWebhook(source, Webhooks.Admin, "Admin: Vehicles Imported", "success", {
            { key = "Method", value = "ESX" },
            { key = "Rows Imported", value = count }
        })
        UpdateAllDealershipsShowroomCache()
        return { success = true }
    end

    -- Unsupported source
    return { success = false, error = "UNSUPPORTED_SOURCE" }
end)
