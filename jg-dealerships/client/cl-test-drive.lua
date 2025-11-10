-- ==============================
-- Test Drive Client Script
-- ==============================

-- Local variables for test drive state
local currentDealership = nil
local testDriveVehicle = nil

-- ==============================
-- Helper Functions
-- ==============================

-- NOTE: This function is missing from the provided code but is referenced
-- It should be defined elsewhere in the codebase or added here
local function FindVehicleSpawnCoords(spawnConfig)
    -- This function should return appropriate spawn coordinates
    -- based on the dealership's test drive spawn configuration
    -- Placeholder implementation:
    if spawnConfig and spawnConfig.coords then
        return spawnConfig.coords
    end
    
    -- Fallback to player position with offset
    local playerCoords = GetEntityCoords(cache.ped)
    return vector4(playerCoords.x + 5.0, playerCoords.y + 5.0, playerCoords.z, GetEntityHeading(cache.ped))
end

-- ==============================
-- End Test Drive
-- ==============================
local function FinishTestDrive()
    if not Globals.IsTestDriving or not testDriveVehicle or not currentDealership then
        return false
    end

    Globals.IsTestDriving = false

    -- Fade out screen for smooth transition
    DoScreenFadeOut(500)
    Wait(500)

    -- Remove vehicle keys
    local vehiclePlate = Framework.Client.GetPlate(testDriveVehicle)
    if vehiclePlate then
        Framework.Client.VehicleRemoveKeys(vehiclePlate, testDriveVehicle, "testDrive")
    end

    -- Clear test drive vehicle reference
    testDriveVehicle = nil

    -- Notify server that test drive is finished
    local finishResult = lib.callback.await("jg-dealerships:server:finish-test-drive", false)

    -- Return to showroom with original vehicle selection
    TriggerEvent(
        "jg-dealerships:client:open-showroom",
        finishResult.dealershipId,
        finishResult.vehicleModel,
        finishResult.vehicleColour
    )

    return true
end

-- ==============================
-- Restrict Player Controls During Test Drive
-- ==============================
local function DisableCombatDuringTestDrive()
    CreateThread(function()
        while Globals.IsTestDriving do
            -- End test drive if player exits vehicle
            if not cache.vehicle then
                FinishTestDrive()
                break
            end

            -- Disable combat and aggressive actions
            SetPlayerCanDoDriveBy(cache.ped, false)
            DisablePlayerFiring(cache.ped, true)
            DisableControlAction(0, 140, true) -- Disable melee attack
            
            Wait(0)
        end
    end)
end

-- ==============================
-- Start Test Drive
-- ==============================
local function StartTestDrive(dealershipId, vehicleModel, vehicleColour)
    local dealership = Config.DealershipLocations[dealershipId]
    currentDealership = dealership

    -- Check if test drive is enabled for this dealership
    if not dealership.enableTestDrive then
        return false
    end

    -- Get vehicle display name
    local vehicleLabel = Framework.Client.GetVehicleLabel(vehicleModel)

    -- Generate test drive plate
    local testDrivePlate = lib.callback.await(
        "jg-dealerships:server:vehicle-generate-plate",
        false,
        Config.TestDrivePlate,
        false
    )

    -- Find appropriate spawn coordinates
    local spawnCoords = FindVehicleSpawnCoords(dealership.testDriveSpawn)

    -- Close showroom before spawning vehicle
    ExitShowroom()

    local vehicleEntity = nil
    local networkId = nil
    local spawnSuccess = false

    -- Handle client-side spawning if server spawning is disabled
    if not Config.SpawnVehiclesWithServerSetter then
        local spawnOptions = {
            plate = testDrivePlate,
            colour = vehicleColour
        }

        vehicleEntity = SpawnVehicleClient(
            0, -- vehicle ID (0 for new spawn)
            vehicleModel,
            testDrivePlate,
            spawnCoords,
            true, -- warp player into vehicle
            spawnOptions,
            "testDrive" -- key type
        )

        if not vehicleEntity then
            return false
        end

        networkId = VehToNet(vehicleEntity)
    end

    -- Notify server about test drive start
    spawnSuccess, networkId = lib.callback.await(
        "jg-dealerships:server:start-test-drive",
        false,
        dealershipId,
        spawnCoords,
        networkId,
        vehicleModel,
        vehicleLabel,
        testDrivePlate,
        vehicleColour
    )

    -- Handle server-spawned vehicle
    if networkId then
        local serverSpawnedVehicle = NetToVeh(networkId)
        if serverSpawnedVehicle then
            vehicleEntity = serverSpawnedVehicle
        end
    end

    -- Check if spawn was successful
    if not spawnSuccess then
        if vehicleEntity then
            JGDeleteVehicle(vehicleEntity)
        end
        return false
    end

    -- Verify vehicle exists for server spawning
    if Config.SpawnVehiclesWithServerSetter and not vehicleEntity then
        print("^1[ERROR] There was a problem spawning in your vehicle")
        return false
    end

    -- Set test drive state
    testDriveVehicle = vehicleEntity
    Globals.IsTestDriving = true

    -- Remove NUI focus and show test drive HUD
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "testDriveHud",
        time = Config.TestDriveTimeSeconds or 60,
        locale = Locale,
        config = Config
    })

    -- Trigger configuration event for other scripts
    TriggerEvent(
        "jg-dealerships:client:start-test-drive:config",
        vehicleEntity,
        Framework.Client.GetPlate(vehicleEntity)
    )

    -- Fade screen back in
    DoScreenFadeIn(500)

    -- Start combat restriction after brief delay
    CreateThread(function()
        Wait(2500)
        DisableCombatDuringTestDrive()
    end)

    return true
end

-- ==============================
-- NUI Callbacks
-- ==============================

-- Handle test drive finish request from UI
RegisterNUICallback("finish-test-drive", function(data, callback)
    FinishTestDrive()
    callback(true)
end)

-- Handle test drive start request from UI
RegisterNUICallback("test-drive", function(data, callback)
    -- Fade screen out for smooth transition
    DoScreenFadeOut(500)
    Wait(500)

    -- Attempt to start test drive
    local startSuccess = StartTestDrive(data.dealershipId, data.vehicle, data.color)

    if not startSuccess then
        -- Immediately fade back in on failure
        DoScreenFadeIn(0)
        return callback({error = true})
    end

    callback(true)
end)

-- ==============================
-- Cleanup On Resource Stop
-- ==============================
AddEventHandler("onResourceStop", function(resourceName)
    -- Only handle our own resource stopping
    if GetCurrentResourceName() ~= resourceName then 
        return 
    end

    -- Clean up test drive state
    if Globals.IsTestDriving then
        -- Exit server bucket if in test drive
        TriggerServerEvent("jg-dealerships:server:exit-bucket")

        -- Delete test drive vehicle if player is in it
        if cache.vehicle then
            DeleteEntity(cache.vehicle)
        end
    end
end)