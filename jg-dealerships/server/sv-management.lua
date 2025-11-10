local L0_1, L1_1, L2_1, L3_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = MySQL
  L1_2 = L1_2.update
  L1_2 = L1_2.await
  L2_2 = "UPDATE dealership_orders SET fulfilled = ? WHERE id = ?"
  L3_2 = {}
  L4_2 = 1
  L5_2 = A0_2.id
  L3_2[1] = L4_2
  L3_2[2] = L5_2
  L1_2(L2_2, L3_2)
  L1_2 = MySQL
  L1_2 = L1_2.update
  L1_2 = L1_2.await
  L2_2 = "UPDATE dealership_stock SET stock = stock + ? WHERE dealership = ? AND vehicle = ?"
  L3_2 = {}
  L4_2 = A0_2.quantity
  L5_2 = A0_2.dealership
  L6_2 = A0_2.vehicle
  L3_2[1] = L4_2
  L3_2[2] = L5_2
  L3_2[3] = L6_2
  L1_2(L2_2, L3_2)
  L1_2 = SetTimeout
  L2_2 = 1000
  function L3_2()
    local L0_3, L1_3
    L0_3 = UpdateDealershipShowroomCache
    L1_3 = A0_2.dealership
    L0_3(L1_3)
  end
  L1_2(L2_2, L3_2)
  L1_2 = DebugPrint
  L2_2 = "Order fulfilled: "
  L3_2 = A0_2.id
  L2_2 = L2_2 .. L3_2
  L3_2 = "debug"
  L4_2 = A0_2
  L1_2(L2_2, L3_2, L4_2)
end
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:get-dealership-data"
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L2_2 = IsEmployee
  L3_2 = A0_2
  L4_2 = A1_2
  L5_2 = {}
  L6_2 = "supervisor"
  L7_2 = "manager"
  L5_2[1] = L6_2
  L5_2[2] = L7_2
  L6_2 = true
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2)
  if not L2_2 then
    L3_2 = Framework
    L3_2 = L3_2.Server
    L3_2 = L3_2.Notify
    L4_2 = A0_2
    L5_2 = Locale
    L5_2 = L5_2.employeePermissionsError
    L6_2 = "error"
    L3_2(L4_2, L5_2, L6_2)
    L3_2 = {}
    L3_2.error = true
    return L3_2
  end
  L3_2 = MySQL
  L3_2 = L3_2.prepare
  L3_2 = L3_2.await
  L4_2 = "SELECT * FROM dealership_data WHERE name = ?"
  L5_2 = {}
  L6_2 = A1_2
  L5_2[1] = L6_2
  L3_2 = L3_2(L4_2, L5_2)
  if not L3_2 then
    L4_2 = DebugPrint
    L5_2 = "Failed to get dealership data for dealer: "
    L6_2 = A1_2
    L5_2 = L5_2 .. L6_2
    L6_2 = "warning"
    L4_2(L5_2, L6_2)
    L4_2 = false
    return L4_2
  end
  L4_2 = MySQL
  L4_2 = L4_2.prepare
  L4_2 = L4_2.await
  L5_2 = [[
    SELECT
      (SELECT COUNT(*) FROM dealership_stock WHERE dealership = ?) AS total_vehicle_count,
      (SELECT COUNT(*) FROM dealership_sales WHERE dealership = ?) AS total_sales_count,
      (SELECT COUNT(*) FROM dealership_dispveh WHERE dealership = ?) AS total_display_vehicles_count;
  ]]
  L6_2 = {}
  L7_2 = A1_2
  L8_2 = A1_2
  L9_2 = A1_2
  L6_2[1] = L7_2
  L6_2[2] = L8_2
  L6_2[3] = L9_2
  L4_2 = L4_2(L5_2, L6_2)
  if not L4_2 then
    L5_2 = false
    return L5_2
  end
  L5_2 = Framework
  L5_2 = L5_2.Server
  L5_2 = L5_2.GetPlayerInfo
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = L4_2.total_vehicle_count
  L7_2 = L4_2.total_sales_count
  L8_2 = L4_2.total_display_vehicles_count
  L9_2 = {}
  L10_2 = L3_2.label
  L9_2.name = L10_2
  L10_2 = L3_2.balance
  L9_2.balance = L10_2
  L10_2 = L3_2.owner_id
  L9_2.ownerId = L10_2
  if L5_2 then
    L10_2 = L5_2.name
    if L10_2 then
      goto lbl_81
    end
  end
  L10_2 = ""
  ::lbl_81::
  L9_2.playerName = L10_2
  L10_2 = L3_2.employee_commission
  L9_2.commission = L10_2
  L9_2.employeeRole = L2_2
  L10_2 = {}
  L10_2.vehiclesCount = L6_2
  L10_2.totalSales = L7_2
  L10_2.vehiclesOnDisplay = L8_2
  L9_2.stats = L10_2
  L10_2 = GetNearbyPlayers
  L11_2 = A0_2
  L12_2 = GetEntityCoords
  L13_2 = GetPlayerPed
  L14_2 = A0_2
  L13_2, L14_2 = L13_2(L14_2)
  L12_2 = L12_2(L13_2, L14_2)
  L13_2 = 10.0
  L14_2 = false
  L10_2 = L10_2(L11_2, L12_2, L13_2, L14_2)
  L9_2.nearbyPlayers = L10_2
  return L9_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:get-dealership-balance"
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L2_2 = IsEmployee
  L3_2 = A0_2
  L4_2 = A1_2
  L5_2 = {}
  L6_2 = "supervisor"
  L7_2 = "manager"
  L5_2[1] = L6_2
  L5_2[2] = L7_2
  L6_2 = true
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2)
  if not L2_2 then
    L2_2 = Framework
    L2_2 = L2_2.Server
    L2_2 = L2_2.Notify
    L3_2 = A0_2
    L4_2 = Locale
    L4_2 = L4_2.employeePermissionsError
    L5_2 = "error"
    L2_2(L3_2, L4_2, L5_2)
    L2_2 = {}
    L2_2.error = true
    return L2_2
  end
  L2_2 = MySQL
  L2_2 = L2_2.scalar
  L2_2 = L2_2.await
  L3_2 = "SELECT balance FROM dealership_data WHERE name = ?"
  L4_2 = {}
  L5_2 = A1_2
  L4_2[1] = L5_2
  L2_2 = L2_2(L3_2, L4_2)
  if not L2_2 then
    L3_2 = {}
    L3_2.error = true
    return L3_2
  end
  L3_2 = {}
  L3_2.balance = L2_2
  return L3_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:get-dealership-vehicles"
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L2_2 = A1_2.dealershipId
  L3_2 = IsEmployee
  L4_2 = A0_2
  L5_2 = L2_2
  L6_2 = {}
  L7_2 = "supervisor"
  L8_2 = "manager"
  L6_2[1] = L7_2
  L6_2[2] = L8_2
  L7_2 = true
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
  if not L3_2 then
    L3_2 = Framework
    L3_2 = L3_2.Server
    L3_2 = L3_2.Notify
    L4_2 = A0_2
    L5_2 = Locale
    L5_2 = L5_2.employeePermissionsError
    L6_2 = "error"
    L3_2(L4_2, L5_2, L6_2)
    L3_2 = {}
    L3_2.error = true
    return L3_2
  end
  L3_2 = MySQL
  L3_2 = L3_2.rawExecute
  L3_2 = L3_2.await
  L4_2 = "SELECT vehicle.*, stock.stock as stock, stock.price as list_price FROM dealership_vehicles vehicle INNER JOIN dealership_stock stock ON vehicle.spawn_code = stock.vehicle INNER JOIN dealership_data dealership ON stock.dealership = dealership.name WHERE dealership.name = ? ORDER BY vehicle.spawn_code ASC;"
  L5_2 = {}
  L6_2 = L2_2
  L5_2[1] = L6_2
  return L3_2(L4_2, L5_2)
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:get-dealership-display-vehicles"
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L2_2 = A1_2.dealershipId
  L3_2 = IsEmployee
  L4_2 = A0_2
  L5_2 = L2_2
  L6_2 = {}
  L7_2 = "supervisor"
  L8_2 = "manager"
  L6_2[1] = L7_2
  L6_2[2] = L8_2
  L7_2 = true
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
  if not L3_2 then
    L3_2 = Framework
    L3_2 = L3_2.Server
    L3_2 = L3_2.Notify
    L4_2 = A0_2
    L5_2 = Locale
    L5_2 = L5_2.employeePermissionsError
    L6_2 = "error"
    L3_2(L4_2, L5_2, L6_2)
    L3_2 = {}
    L3_2.error = true
    return L3_2
  end
  L3_2 = MySQL
  L3_2 = L3_2.query
  L3_2 = L3_2.await
  L4_2 = "SELECT dispveh.*, vehicle.brand, vehicle.model FROM dealership_dispveh dispveh INNER JOIN dealership_vehicles vehicle ON vehicle.spawn_code = dispveh.vehicle WHERE dispveh.dealership = ?;"
  L5_2 = {}
  L6_2 = L2_2
  L5_2[1] = L6_2
  return L3_2(L4_2, L5_2)
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:get-dealership-orders"
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L2_2 = A1_2.dealershipId
  L3_2 = IsEmployee
  L4_2 = A0_2
  L5_2 = L2_2
  L6_2 = {}
  L7_2 = "supervisor"
  L8_2 = "manager"
  L6_2[1] = L7_2
  L6_2[2] = L8_2
  L7_2 = true
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
  if not L3_2 then
    L3_2 = Framework
    L3_2 = L3_2.Server
    L3_2 = L3_2.Notify
    L4_2 = A0_2
    L5_2 = Locale
    L5_2 = L5_2.employeePermissionsError
    L6_2 = "error"
    L3_2(L4_2, L5_2, L6_2)
    L3_2 = {}
    L3_2.error = true
    return L3_2
  end
  L3_2 = MySQL
  L3_2 = L3_2.query
  L3_2 = L3_2.await
  L4_2 = "SELECT orders.*, vehicle.brand, vehicle.model FROM dealership_orders orders INNER JOIN dealership_vehicles vehicle ON orders.vehicle = vehicle.spawn_code WHERE orders.dealership = ? ORDER BY orders.order_created DESC;"
  L5_2 = {}
  L6_2 = L2_2
  L5_2[1] = L6_2
  L3_2 = L3_2(L4_2, L5_2)
  if not L3_2 then
    L4_2 = {}
    return L4_2
  end
  L4_2 = ipairs
  L5_2 = L3_2
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    L10_2 = L3_2[L8_2]
    L11_2 = L9_2.delivery_time
    L12_2 = os
    L12_2 = L12_2.time
    L12_2 = L12_2()
    L11_2 = L11_2 - L12_2
    L10_2.time_remaining = L11_2
  end
  return L3_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:get-dealership-sales"
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L2_2 = A1_2.dealershipId
  L3_2 = A1_2.pageIndex
  L4_2 = A1_2.pageSize
  L5_2 = IsEmployee
  L6_2 = A0_2
  L7_2 = L2_2
  L8_2 = {}
  L9_2 = "supervisor"
  L10_2 = "manager"
  L8_2[1] = L9_2
  L8_2[2] = L10_2
  L9_2 = true
  L5_2 = L5_2(L6_2, L7_2, L8_2, L9_2)
  if not L5_2 then
    L5_2 = Framework
    L5_2 = L5_2.Server
    L5_2 = L5_2.Notify
    L6_2 = A0_2
    L7_2 = Locale
    L7_2 = L7_2.employeePermissionsError
    L8_2 = "error"
    L5_2(L6_2, L7_2, L8_2)
    L5_2 = {}
    L5_2.error = true
    return L5_2
  end
  L5_2 = MySQL
  L5_2 = L5_2.query
  L5_2 = L5_2.await
  L6_2 = "SELECT sales.*, vehicle.brand, vehicle.model FROM dealership_sales sales INNER JOIN dealership_vehicles vehicle ON sales.vehicle = vehicle.spawn_code WHERE sales.dealership = ? ORDER BY sales.created_at DESC LIMIT ? OFFSET ?;"
  L7_2 = {}
  L8_2 = L2_2
  L9_2 = L4_2
  L10_2 = L3_2 * L4_2
  L7_2[1] = L8_2
  L7_2[2] = L9_2
  L7_2[3] = L10_2
  L5_2 = L5_2(L6_2, L7_2)
  L6_2 = ipairs
  L7_2 = L5_2
  L6_2, L7_2, L8_2, L9_2 = L6_2(L7_2)
  for L10_2, L11_2 in L6_2, L7_2, L8_2, L9_2 do
    L12_2 = L5_2[L10_2]
    L13_2 = Framework
    L13_2 = L13_2.Server
    L13_2 = L13_2.GetPlayerInfoFromIdentifier
    L14_2 = L11_2.player
    L13_2 = L13_2(L14_2)
    if L13_2 then
      L13_2 = L13_2.name
    end
    if not L13_2 then
      L13_2 = "-"
    end
    L12_2.player_name = L13_2
    L12_2 = L5_2[L10_2]
    L13_2 = Framework
    L13_2 = L13_2.Server
    L13_2 = L13_2.GetPlayerInfoFromIdentifier
    L14_2 = L11_2.seller
    L13_2 = L13_2(L14_2)
    if L13_2 then
      L13_2 = L13_2.name
    end
    if not L13_2 then
      L13_2 = "-"
    end
    L12_2.seller_name = L13_2
  end
  L6_2 = MySQL
  L6_2 = L6_2.scalar
  L6_2 = L6_2.await
  L7_2 = "SELECT COUNT(*) FROM dealership_sales WHERE dealership = ?"
  L8_2 = {}
  L9_2 = L2_2
  L8_2[1] = L9_2
  L6_2 = L6_2(L7_2, L8_2)
  L7_2 = math
  L7_2 = L7_2.ceil
  L8_2 = L6_2 / L4_2
  L7_2 = L7_2(L8_2)
  L8_2 = {}
  L8_2.sales = L5_2
  L8_2.pageCount = L7_2
  return L8_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:get-dealership-employees"
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L2_2 = A1_2.dealershipId
  L3_2 = Framework
  L3_2 = L3_2.Server
  L3_2 = L3_2.GetPlayerIdentifier
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  L4_2 = IsEmployee
  L5_2 = A0_2
  L6_2 = L2_2
  L7_2 = "manager"
  L8_2 = true
  L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2)
  if not L4_2 then
    L4_2 = Framework
    L4_2 = L4_2.Server
    L4_2 = L4_2.Notify
    L5_2 = A0_2
    L6_2 = Locale
    L6_2 = L6_2.employeePermissionsError
    L7_2 = "error"
    L4_2(L5_2, L6_2, L7_2)
    L4_2 = {}
    L4_2.error = true
    return L4_2
  end
  L4_2 = MySQL
  L4_2 = L4_2.query
  L4_2 = L4_2.await
  L5_2 = "SELECT * FROM dealership_employees WHERE dealership = ?"
  L6_2 = {}
  L7_2 = L2_2
  L6_2[1] = L7_2
  L4_2 = L4_2(L5_2, L6_2)
  L5_2 = ipairs
  L6_2 = L4_2
  L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2)
  for L9_2, L10_2 in L5_2, L6_2, L7_2, L8_2 do
    L11_2 = {}
    L12_2 = L10_2.player
    L11_2.id = L12_2
    L12_2 = L10_2.identifier
    L11_2.identifier = L12_2
    L12_2 = Framework
    L12_2 = L12_2.Server
    L12_2 = L12_2.GetPlayerInfoFromIdentifier
    L13_2 = L10_2.identifier
    L12_2 = L12_2(L13_2)
    if L12_2 then
      L12_2 = L12_2.name
    end
    if not L12_2 then
      L12_2 = "-"
    end
    L11_2.name = L12_2
    L12_2 = L10_2.role
    L11_2.role = L12_2
    L12_2 = L10_2.joined
    L11_2.joined = L12_2
    L12_2 = L10_2.identifier
    L12_2 = L3_2 == L12_2
    L11_2.me = L12_2
    L4_2[L9_2] = L11_2
  end
  return L4_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:order-vehicle"
function L3_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2
  L4_2 = IsEmployee
  L5_2 = A0_2
  L6_2 = A1_2
  L7_2 = {}
  L8_2 = "supervisor"
  L9_2 = "manager"
  L7_2[1] = L8_2
  L7_2[2] = L9_2
  L8_2 = true
  L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2)
  if not L4_2 then
    L4_2 = Framework
    L4_2 = L4_2.Server
    L4_2 = L4_2.Notify
    L5_2 = A0_2
    L6_2 = Locale
    L6_2 = L6_2.employeePermissionsError
    L7_2 = "error"
    L4_2(L5_2, L6_2, L7_2)
    L4_2 = {}
    L4_2.error = true
    return L4_2
  end
  L4_2 = MySQL
  L4_2 = L4_2.scalar
  L4_2 = L4_2.await
  L5_2 = "SELECT price FROM dealership_vehicles WHERE spawn_code = ?"
  L6_2 = {}
  L7_2 = A2_2
  L6_2[1] = L7_2
  L4_2 = L4_2(L5_2, L6_2)
  if not L4_2 then
    L5_2 = {}
    L5_2.error = true
    return L5_2
  end
  L5_2 = Config
  L5_2 = L5_2.DealerPurchasePrice
  L5_2 = L4_2 * L5_2
  L5_2 = L5_2 * A3_2
  L6_2 = os
  L6_2 = L6_2.time
  L6_2 = L6_2()
  L7_2 = Config
  L7_2 = L7_2.VehicleOrderTime
  L7_2 = L7_2 * 60
  L6_2 = L6_2 + L7_2
  L7_2 = MySQL
  L7_2 = L7_2.scalar
  L7_2 = L7_2.await
  L8_2 = "SELECT balance FROM dealership_data WHERE name = ?"
  L9_2 = {}
  L10_2 = A1_2
  L9_2[1] = L10_2
  L7_2 = L7_2(L8_2, L9_2)
  if L5_2 > L7_2 then
    L8_2 = Framework
    L8_2 = L8_2.Server
    L8_2 = L8_2.Notify
    L9_2 = A0_2
    L10_2 = Locale
    L10_2 = L10_2.dealershipNotEnoughFunds
    L11_2 = "error"
    L8_2(L9_2, L10_2, L11_2)
    L8_2 = {}
    L8_2.error = true
    return L8_2
  end
  L8_2 = MySQL
  L8_2 = L8_2.insert
  L8_2 = L8_2.await
  L9_2 = "INSERT INTO dealership_orders (vehicle, dealership, quantity, cost, delivery_time) VALUES(?, ?, ?, ?, ?)"
  L10_2 = {}
  L11_2 = A2_2
  L12_2 = A1_2
  L13_2 = A3_2
  L14_2 = L5_2
  L15_2 = L6_2
  L10_2[1] = L11_2
  L10_2[2] = L12_2
  L10_2[3] = L13_2
  L10_2[4] = L14_2
  L10_2[5] = L15_2
  L8_2 = L8_2(L9_2, L10_2)
  L9_2 = MySQL
  L9_2 = L9_2.query
  L9_2 = L9_2.await
  L10_2 = "UPDATE dealership_data SET balance = balance - ? WHERE name = ?"
  L11_2 = {}
  L12_2 = L5_2
  L13_2 = A1_2
  L11_2[1] = L12_2
  L11_2[2] = L13_2
  L9_2(L10_2, L11_2)
  L9_2 = Framework
  L9_2 = L9_2.Server
  L9_2 = L9_2.Notify
  L10_2 = A0_2
  L11_2 = Locale
  L11_2 = L11_2.dealershipVehiclesOrdered
  L12_2 = "success"
  L9_2(L10_2, L11_2, L12_2)
  L9_2 = SendWebhook
  L10_2 = A0_2
  L11_2 = Webhooks
  L11_2 = L11_2.Dealership
  L12_2 = "Dealership: Vehicle(s) Ordered"
  L13_2 = "success"
  L14_2 = {}
  L15_2 = {}
  L15_2.key = "Dealership"
  L15_2.value = A1_2
  L16_2 = {}
  L16_2.key = "Vehicle"
  L16_2.value = A2_2
  L17_2 = {}
  L17_2.key = "Quantity"
  L17_2.value = A3_2
  L18_2 = {}
  L18_2.key = "Total Price"
  L18_2.value = L5_2
  L14_2[1] = L15_2
  L14_2[2] = L16_2
  L14_2[3] = L17_2
  L14_2[4] = L18_2
  L9_2(L10_2, L11_2, L12_2, L13_2, L14_2)
  L9_2 = Config
  L9_2 = L9_2.VehicleOrderTime
  if 0 == L9_2 then
    L9_2 = L0_1
    L10_2 = {}
    L10_2.id = L8_2
    L10_2.quantity = A3_2
    L10_2.dealership = A1_2
    L10_2.vehicle = A2_2
    L9_2(L10_2)
  end
  L9_2 = MySQL
  L9_2 = L9_2.single
  L9_2 = L9_2.await
  L10_2 = "SELECT orders.*, vehicle.brand, vehicle.model FROM dealership_orders orders INNER JOIN dealership_vehicles vehicle ON orders.vehicle = vehicle.spawn_code WHERE orders.dealership = ? ORDER BY id DESC LIMIT 1"
  L11_2 = {}
  L12_2 = A1_2
  L11_2[1] = L12_2
  L9_2 = L9_2(L10_2, L11_2)
  return L9_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:cancel-vehicle-order"
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L2_2 = MySQL
  L2_2 = L2_2.single
  L2_2 = L2_2.await
  L3_2 = "SELECT * FROM dealership_orders WHERE id = ?"
  L4_2 = {}
  L5_2 = A1_2
  L4_2[1] = L5_2
  L2_2 = L2_2(L3_2, L4_2)
  if not L2_2 then
    L3_2 = {}
    L3_2.error = true
    return L3_2
  end
  L3_2 = IsEmployee
  L4_2 = A0_2
  L5_2 = L2_2.dealership
  L6_2 = {}
  L7_2 = "supervisor"
  L8_2 = "manager"
  L6_2[1] = L7_2
  L6_2[2] = L8_2
  L7_2 = true
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
  if not L3_2 then
    L3_2 = Framework
    L3_2 = L3_2.Server
    L3_2 = L3_2.Notify
    L4_2 = A0_2
    L5_2 = Locale
    L5_2 = L5_2.employeePermissionsError
    L6_2 = "error"
    L3_2(L4_2, L5_2, L6_2)
    L3_2 = {}
    L3_2.error = true
    return L3_2
  end
  L3_2 = MySQL
  L3_2 = L3_2.query
  L3_2 = L3_2.await
  L4_2 = "DELETE FROM dealership_orders WHERE id = ?"
  L5_2 = {}
  L6_2 = A1_2
  L5_2[1] = L6_2
  L3_2(L4_2, L5_2)
  L3_2 = MySQL
  L3_2 = L3_2.query
  L3_2 = L3_2.await
  L4_2 = "UPDATE dealership_data SET balance = balance + ? WHERE name = ?"
  L5_2 = {}
  L6_2 = L2_2.cost
  L7_2 = L2_2.dealership
  L5_2[1] = L6_2
  L5_2[2] = L7_2
  L3_2(L4_2, L5_2)
  L3_2 = Framework
  L3_2 = L3_2.Server
  L3_2 = L3_2.Notify
  L4_2 = A0_2
  L5_2 = Locale
  L5_2 = L5_2.dealershipOrderCancelled
  L6_2 = "success"
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = SendWebhook
  L4_2 = A0_2
  L5_2 = Webhooks
  L5_2 = L5_2.Dealership
  L6_2 = "Dealership: Order Cancelled"
  L7_2 = "danger"
  L8_2 = {}
  L9_2 = {}
  L9_2.key = "Dealership"
  L10_2 = L2_2.dealership
  L9_2.value = L10_2
  L10_2 = {}
  L10_2.key = "Vehicle"
  L11_2 = L2_2.vehicle
  L10_2.value = L11_2
  L11_2 = {}
  L11_2.key = "Quantity"
  L12_2 = L2_2.quantity
  L11_2.value = L12_2
  L12_2 = {}
  L12_2.key = "Amount Refunded"
  L13_2 = L2_2.cost
  L12_2.value = L13_2
  L8_2[1] = L9_2
  L8_2[2] = L10_2
  L8_2[3] = L11_2
  L8_2[4] = L12_2
  L3_2(L4_2, L5_2, L6_2, L7_2, L8_2)
  L3_2 = true
  return L3_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:dealership-deposit"
function L3_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L4_2 = IsEmployee
  L5_2 = A0_2
  L6_2 = A1_2
  L7_2 = "manager"
  L8_2 = true
  L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2)
  if not L4_2 then
    L4_2 = Framework
    L4_2 = L4_2.Server
    L4_2 = L4_2.Notify
    L5_2 = A0_2
    L6_2 = Locale
    L6_2 = L6_2.employeePermissionsError
    L7_2 = "error"
    L4_2(L5_2, L6_2, L7_2)
    L4_2 = {}
    L4_2.error = true
    return L4_2
  end
  if A3_2 < 0 then
    L4_2 = Framework
    L4_2 = L4_2.Server
    L4_2 = L4_2.Notify
    L5_2 = A0_2
    L6_2 = "Stop trying to exploit the script"
    L7_2 = "error"
    L4_2(L5_2, L6_2, L7_2)
    L4_2 = false
    return L4_2
  end
  L4_2 = Framework
  L4_2 = L4_2.Server
  L4_2 = L4_2.GetPlayerBalance
  L5_2 = A0_2
  L6_2 = A2_2
  L4_2 = L4_2(L5_2, L6_2)
  if A3_2 > L4_2 then
    L4_2 = Framework
    L4_2 = L4_2.Server
    L4_2 = L4_2.Notify
    L5_2 = A0_2
    L6_2 = Locale
    L6_2 = L6_2.errorNotEnoughMoney
    L7_2 = "error"
    L4_2(L5_2, L6_2, L7_2)
    L4_2 = {}
    L4_2.error = true
    return L4_2
  end
  L4_2 = Framework
  L4_2 = L4_2.Server
  L4_2 = L4_2.PlayerRemoveMoney
  L5_2 = A0_2
  L6_2 = A3_2
  L7_2 = A2_2
  L4_2(L5_2, L6_2, L7_2)
  L4_2 = MySQL
  L4_2 = L4_2.query
  L4_2 = L4_2.await
  L5_2 = "UPDATE dealership_data SET balance = balance + ? WHERE name = ?"
  L6_2 = {}
  L7_2 = A3_2
  L8_2 = A1_2
  L6_2[1] = L7_2
  L6_2[2] = L8_2
  L4_2(L5_2, L6_2)
  L4_2 = Framework
  L4_2 = L4_2.Server
  L4_2 = L4_2.Notify
  L5_2 = A0_2
  L6_2 = Locale
  L6_2 = L6_2.depositSuccess
  L7_2 = "success"
  L4_2(L5_2, L6_2, L7_2)
  L4_2 = SendWebhook
  L5_2 = A0_2
  L6_2 = Webhooks
  L6_2 = L6_2.Dealership
  L7_2 = "Dealership: Money Deposited"
  L8_2 = nil
  L9_2 = {}
  L10_2 = {}
  L10_2.key = "Dealership"
  L10_2.value = A1_2
  L11_2 = {}
  L11_2.key = "Amount"
  L11_2.value = A3_2
  L9_2[1] = L10_2
  L9_2[2] = L11_2
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
  L4_2 = true
  return L4_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:dealership-withdraw"
function L3_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L3_2 = IsEmployee
  L4_2 = A0_2
  L5_2 = A1_2
  L6_2 = "manager"
  L7_2 = true
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
  if not L3_2 then
    L3_2 = Framework
    L3_2 = L3_2.Server
    L3_2 = L3_2.Notify
    L4_2 = A0_2
    L5_2 = Locale
    L5_2 = L5_2.employeePermissionsError
    L6_2 = "error"
    L3_2(L4_2, L5_2, L6_2)
    L3_2 = {}
    L3_2.error = true
    return L3_2
  end
  if A2_2 < 0 then
    L3_2 = Framework
    L3_2 = L3_2.Server
    L3_2 = L3_2.Notify
    L4_2 = A0_2
    L5_2 = "Stop trying to exploit the script"
    L6_2 = "error"
    L3_2(L4_2, L5_2, L6_2)
    L3_2 = false
    return L3_2
  end
  L3_2 = MySQL
  L3_2 = L3_2.scalar
  L3_2 = L3_2.await
  L4_2 = "SELECT balance FROM dealership_data WHERE name = ?"
  L5_2 = {}
  L6_2 = A1_2
  L5_2[1] = L6_2
  L3_2 = L3_2(L4_2, L5_2)
  if A2_2 > L3_2 then
    L4_2 = Framework
    L4_2 = L4_2.Server
    L4_2 = L4_2.Notify
    L5_2 = A0_2
    L6_2 = Locale
    L6_2 = L6_2.dealershipNotEnoughFunds
    L7_2 = "error"
    L4_2(L5_2, L6_2, L7_2)
    L4_2 = {}
    L4_2.error = true
    return L4_2
  end
  L4_2 = Framework
  L4_2 = L4_2.Server
  L4_2 = L4_2.PlayerAddMoney
  L5_2 = A0_2
  L6_2 = A2_2
  L7_2 = "bank"
  L4_2(L5_2, L6_2, L7_2)
  L4_2 = MySQL
  L4_2 = L4_2.update
  L4_2 = L4_2.await
  L5_2 = "UPDATE dealership_data SET balance = balance - ? WHERE name = ?"
  L6_2 = {}
  L7_2 = A2_2
  L8_2 = A1_2
  L6_2[1] = L7_2
  L6_2[2] = L8_2
  L4_2(L5_2, L6_2)
  L4_2 = Framework
  L4_2 = L4_2.Server
  L4_2 = L4_2.Notify
  L5_2 = A0_2
  L6_2 = Locale
  L6_2 = L6_2.withdrawSuccess
  L7_2 = "success"
  L4_2(L5_2, L6_2, L7_2)
  L4_2 = SendWebhook
  L5_2 = A0_2
  L6_2 = Webhooks
  L6_2 = L6_2.Dealership
  L7_2 = "Dealership: Money Withdraw"
  L8_2 = nil
  L9_2 = {}
  L10_2 = {}
  L10_2.key = "Dealership"
  L10_2.value = A1_2
  L11_2 = {}
  L11_2.key = "Amount"
  L11_2.value = A2_2
  L9_2[1] = L10_2
  L9_2[2] = L11_2
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
  L4_2 = true
  return L4_2
end
L1_1(L2_1, L3_1)
L1_1 = RegisterNetEvent
L2_1 = "jg-dealerships:server:update-vehicle-price"
function L3_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L3_2 = source
  L4_2 = IsEmployee
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = Config
  L7_2 = L7_2.ManagerCanChangePriceOfVehicles
  if L7_2 then
    L7_2 = "manager"
  end
  L8_2 = true
  L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2)
  if not L4_2 then
    L4_2 = Framework
    L4_2 = L4_2.Server
    L4_2 = L4_2.Notify
    L5_2 = L3_2
    L6_2 = Locale
    L6_2 = L6_2.employeePermissionsError
    L7_2 = "error"
    L4_2(L5_2, L6_2, L7_2)
    return
  end
  L4_2 = MySQL
  L4_2 = L4_2.update
  L4_2 = L4_2.await
  L5_2 = "UPDATE dealership_stock SET price = ? WHERE vehicle = ? AND dealership = ?"
  L6_2 = {}
  L7_2 = A2_2
  L8_2 = A1_2
  L9_2 = A0_2
  L6_2[1] = L7_2
  L6_2[2] = L8_2
  L6_2[3] = L9_2
  L4_2(L5_2, L6_2)
  L4_2 = UpdateDealershipShowroomCache
  L5_2 = A0_2
  L4_2(L5_2)
  L4_2 = SendWebhook
  L5_2 = L3_2
  L6_2 = Webhooks
  L6_2 = L6_2.Dealership
  L7_2 = "Dealership: Vehicle Price Updated"
  L8_2 = nil
  L9_2 = {}
  L10_2 = {}
  L10_2.key = "Dealership"
  L10_2.value = A0_2
  L11_2 = {}
  L11_2.key = "Vehicle"
  L11_2.value = A1_2
  L12_2 = {}
  L12_2.key = "New Price"
  L12_2.value = A2_2
  L9_2[1] = L10_2
  L9_2[2] = L11_2
  L9_2[3] = L12_2
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
L1_1(L2_1, L3_1)
L1_1 = RegisterNetEvent
L2_1 = "jg-dealerships:server:update-dealership-settings"
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L2_2 = source
  L3_2 = IsEmployee
  L4_2 = L2_2
  L5_2 = A0_2
  L6_2 = "manager"
  L7_2 = true
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
  if not L3_2 then
    L3_2 = Framework
    L3_2 = L3_2.Server
    L3_2 = L3_2.Notify
    L4_2 = L2_2
    L5_2 = Locale
    L5_2 = L5_2.employeePermissionsError
    L6_2 = "error"
    L3_2(L4_2, L5_2, L6_2)
    return
  end
  L3_2 = MySQL
  L3_2 = L3_2.update
  L3_2 = L3_2.await
  L4_2 = "UPDATE dealership_data SET label = ?, employee_commission = ? WHERE name = ?"
  L5_2 = {}
  L6_2 = A1_2.name
  L7_2 = A1_2.commission
  L8_2 = A0_2
  L5_2[1] = L6_2
  L5_2[2] = L7_2
  L5_2[3] = L8_2
  L3_2(L4_2, L5_2)
  L3_2 = TriggerClientEvent
  L4_2 = "jg-dealerships:client:update-blips-text-uis"
  L5_2 = -1
  L3_2(L4_2, L5_2)
  L3_2 = Framework
  L3_2 = L3_2.Server
  L3_2 = L3_2.Notify
  L4_2 = L2_2
  L5_2 = "Changes saved"
  L6_2 = "success"
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = SendWebhook
  L4_2 = L2_2
  L5_2 = Webhooks
  L5_2 = L5_2.Dealership
  L6_2 = "Dealership: Name Updated"
  L7_2 = nil
  L8_2 = {}
  L9_2 = {}
  L9_2.key = "Dealership"
  L9_2.value = A0_2
  L10_2 = {}
  L10_2.key = "New name"
  L11_2 = A1_2.name
  L10_2.value = L11_2
  L8_2[1] = L9_2
  L8_2[2] = L10_2
  L3_2(L4_2, L5_2, L6_2, L7_2, L8_2)
end
L1_1(L2_1, L3_1)
function L1_1()
  local L0_2, L1_2
  L0_2 = CreateThread
  function L1_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3
    while true do
      L0_3 = MySQL
      L0_3 = L0_3.query
      L0_3 = L0_3.await
      L1_3 = "SELECT * FROM dealership_orders WHERE delivery_time < UNIX_TIMESTAMP() AND fulfilled = 0"
      L0_3 = L0_3(L1_3)
      L1_3 = ipairs
      L2_3 = L0_3
      L1_3, L2_3, L3_3, L4_3 = L1_3(L2_3)
      for L5_3, L6_3 in L1_3, L2_3, L3_3, L4_3 do
        L7_3 = L0_1
        L8_3 = L6_3
        L7_3(L8_3)
        L7_3 = Wait
        L8_3 = 250
        L7_3(L8_3)
      end
      L1_3 = Wait
      L2_3 = 60000
      L1_3(L2_3)
    end
  end
  L0_2(L1_2)
end
InitOrderProcessingThread = L1_1
