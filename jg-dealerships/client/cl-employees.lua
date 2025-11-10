-- Register net event for showing employment confirmation dialog
RegisterNetEvent("jg-dealerships:client:show-confirm-employment", function(employmentData)
    -- Set NUI focus for employment confirmation interface
    SetNuiFocus(true, true)
    
    -- Send employment confirmation data to NUI
    SendNUIMessage({
        type = "showConfirmEmployment",
        data = employmentData,
        config = Config,
        locale = Locale
    })
end)

-- Register NUI callback for accepting hire requests
RegisterNUICallback("accept-hire-request", function(data, callback)
    -- Trigger server event to hire the employee
    TriggerServerEvent("jg-dealerships:server:hire-employee", data)
    
    -- Return success to NUI
    callback(true)
end)

-- Register NUI callback for denying hire requests
RegisterNUICallback("deny-hire-request", function(data, callback)
    -- Trigger server event to reject the hire request
    TriggerServerEvent("jg-dealerships:server:employee-hire-rejected", data.requesterId)
    
    -- Return success to NUI
    callback(true)
end)

-- Register NUI callback for requesting to hire an employee
RegisterNUICallback("request-hire-employee", function(data, callback)
    -- Trigger server event to request hiring an employee
    TriggerServerEvent("jg-dealerships:server:request-hire-employee", data)
    
    -- Return success to NUI
    callback(true)
end)

-- Register NUI callback for firing employees
RegisterNUICallback("fire-employee", function(data, callback)
    local employeeIdentifier = data.identifier
    local dealershipId = data.dealershipId
    
    -- Trigger server event to fire the employee
    TriggerServerEvent("jg-dealerships:server:fire-employee", employeeIdentifier, dealershipId)
    
    -- Return success to NUI
    callback(true)
end)

-- Register NUI callback for updating employee roles
RegisterNUICallback("update-employee-role", function(data, callback)
    local employeeIdentifier = data.identifier
    local dealershipId = data.dealershipId
    local newRole = data.newRole
    
    -- Trigger server event to update employee role
    TriggerServerEvent("jg-dealerships:server:update-employee-role", employeeIdentifier, dealershipId, newRole)
    
    -- Return success to NUI
    callback(true)
end)