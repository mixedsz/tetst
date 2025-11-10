-- Get financed vehicles data and prepare for NUI display
local function getFinancedVehiclesData()
    -- Get financed vehicles from server
    local financedVehicles = lib.callback.await("jg-dealerships:server:get-financed-vehicles", false)
    
    -- Process each financed vehicle
    for vehicleIndex, vehicleData in pairs(financedVehicles) do
        if vehicleData.financed and vehicleData.finance_data then
            -- Get vehicle model information
            local vehicleModel = Framework.Client.GetModelColumn(vehicleData)
            local currentVehicle = financedVehicles[vehicleIndex]
            
            -- Set vehicle label
            local vehicleLabel = vehicleModel
            if vehicleModel then
                local labelFromFramework = Framework.Client.GetVehicleLabel(vehicleModel)
                if labelFromFramework then
                    vehicleLabel = labelFromFramework
                end
            end
            currentVehicle.vehicleLabel = vehicleLabel
            
            -- Parse finance data from JSON
            currentVehicle.finance_data = json.decode(vehicleData.finance_data)
        end
    end
    
    -- Return data structure for NUI
    return {
        type = "manageFinance",
        vehicles = financedVehicles,
        config = Config,
        locale = Locale
    }
end

-- Register command for opening finance management
local financeCommand = Config.MyFinanceCommand or "myfinance"

RegisterCommand(financeCommand, function()
    -- Open NUI interface
    SetNuiFocus(true, true)
    
    -- Send financed vehicles data to NUI
    local financeData = getFinancedVehiclesData()
    SendNUIMessage(financeData)
end, false)

-- Register NUI callback for making finance payments
RegisterNUICallback("finance-make-payment", function(data, callback)
    -- Make payment request to server
    local paymentResult = lib.callback.await("jg-dealerships:server:finance-make-payment", false, data.plate, data.type)
    
    -- If requested, refresh NUI with updated data
    if data.sendNUI then
        SetNuiFocus(true, true)
        
        local updatedFinanceData = getFinancedVehiclesData()
        SendNUIMessage(updatedFinanceData)
    end
    
    -- Return payment result to NUI
    callback(paymentResult)
end)