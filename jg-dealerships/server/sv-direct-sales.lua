local L0_1, L1_1, L2_1, L3_1, L4_1
L0_1 = {}
PendingDirectSales = L0_1
function L0_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2, A7_2, A8_2)
  local L9_2, L10_2, L11_2, L12_2
  L9_2 = GenerateUuid
  L9_2 = L9_2()
  L10_2 = 0
  while true do
    L11_2 = PendingDirectSales
    L11_2 = L11_2[L9_2]
    if not (L11_2 and L10_2 < 10) then
      break
    end
    L10_2 = L10_2 + 1
    L11_2 = GenerateUuid
    L11_2 = L11_2()
    L9_2 = L11_2
  end
  L11_2 = PendingDirectSales
  L12_2 = {}
  L12_2.dealershipId = A0_2
  L12_2.dealerPlayerId = A1_2
  L12_2.playerId = A2_2
  L12_2.model = A3_2
  L12_2.colour = A4_2
  L12_2.price = A5_2
  L12_2.finance = A6_2
  L12_2.noOfPayments = A7_2
  L12_2.downPayment = A8_2
  L11_2[L9_2] = L12_2
  return L9_2
end
function L1_1(A0_2)
  local L1_2
  L1_2 = PendingDirectSales
  L1_2 = L1_2[A0_2]
  if not L1_2 then
    return
  end
  L1_2 = PendingDirectSales
  L1_2[A0_2] = nil
end
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-dealerships:server:get-direct-sale-data"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L2_2 = IsEmployee
  L3_2 = A0_2
  L4_2 = A1_2
  L5_2 = {}
  L6_2 = "supervisor"
  L7_2 = "manager"
  L8_2 = "sales"
  L5_2[1] = L6_2
  L5_2[2] = L7_2
  L5_2[3] = L8_2
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
  L2_2 = Config
  L2_2 = L2_2.DealershipLocations
  L2_2 = L2_2[A1_2]
  L2_2 = L2_2.categories
  L3_2 = MySQL
  L3_2 = L3_2.query
  L3_2 = L3_2.await
  L4_2 = "SELECT * FROM dealership_data WHERE name = ?"
  L5_2 = {}
  L6_2 = A1_2
  L5_2[1] = L6_2
  L3_2 = L3_2(L4_2, L5_2)
  L4_2 = MySQL
  L4_2 = L4_2.query
  L4_2 = L4_2.await
  L5_2 = "SELECT vehicle.*, stock.stock as stock, stock.price as price FROM dealership_vehicles vehicle INNER JOIN dealership_stock stock ON vehicle.spawn_code = stock.vehicle INNER JOIN dealership_data dealership ON stock.dealership = dealership.name WHERE vehicle.category IN (?) AND (dealership.name = ?) ORDER BY vehicle.spawn_code ASC;"
  L6_2 = {}
  L7_2 = L2_2
  L8_2 = A1_2
  L6_2[1] = L7_2
  L6_2[2] = L8_2
  L4_2 = L4_2(L5_2, L6_2)
  L5_2 = {}
  L5_2.vehicles = L4_2
  L6_2 = L3_2[1]
  L6_2 = L6_2.employee_commission
  if not L6_2 then
    L6_2 = 10
  end
  L6_2 = L6_2 / 100
  L5_2.commission = L6_2
  L6_2 = GetNearbyPlayers
  L7_2 = A0_2
  L8_2 = GetEntityCoords
  L9_2 = GetPlayerPed
  L10_2 = A0_2
  L9_2, L10_2 = L9_2(L10_2)
  L8_2 = L8_2(L9_2, L10_2)
  L9_2 = 10.0
  L10_2 = false
  L6_2 = L6_2(L7_2, L8_2, L9_2, L10_2)
  L5_2.nearbyPlayers = L6_2
  return L5_2
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-dealerships:server:send-direct-sale-request"
function L4_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2
  L3_2 = IsEmployee
  L4_2 = A0_2
  L5_2 = A1_2
  L6_2 = {}
  L7_2 = "supervisor"
  L8_2 = "manager"
  L9_2 = "sales"
  L6_2[1] = L7_2
  L6_2[2] = L8_2
  L6_2[3] = L9_2
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
    L3_2 = false
    return L3_2
  end
  L3_2 = Framework
  L3_2 = L3_2.Server
  L3_2 = L3_2.GetPlayerInfo
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  if L3_2 then
    L3_2 = L3_2.name
  end
  L4_2 = A2_2.playerId
  L5_2 = Framework
  L5_2 = L5_2.Server
  L5_2 = L5_2.GetPlayerIdentifier
  L6_2 = L4_2
  L5_2 = L5_2(L6_2)
  L6_2 = A2_2.model
  L7_2 = A2_2.colour
  L8_2 = A2_2.finance
  L9_2 = A2_2.financePayments
  L10_2 = A2_2.financeDownPayment
  if L8_2 then
    L11_2 = MySQL
    L11_2 = L11_2.query
    L11_2 = L11_2.await
    L12_2 = "SELECT COUNT(*) as total FROM "
    L13_2 = Framework
    L13_2 = L13_2.VehiclesTable
    L14_2 = " WHERE financed = 1 AND "
    L15_2 = Framework
    L15_2 = L15_2.PlayerId
    L16_2 = " = ?"
    L12_2 = L12_2 .. L13_2 .. L14_2 .. L15_2 .. L16_2
    L13_2 = {}
    L14_2 = L5_2
    L13_2[1] = L14_2
    L11_2 = L11_2(L12_2, L13_2)
    L12_2 = L11_2[1]
    L12_2 = L12_2.total
    L13_2 = Config
    L13_2 = L13_2.MaxFinancedVehiclesPerPlayer
    if not L13_2 then
      L13_2 = 999999
    end
    if L12_2 >= L13_2 then
      L12_2 = Framework
      L12_2 = L12_2.Server
      L12_2 = L12_2.Notify
      L13_2 = A0_2
      L14_2 = Locale
      L14_2 = L14_2.playerTooManyFinancedVehicles
      L15_2 = "error"
      L12_2(L13_2, L14_2, L15_2)
      L12_2 = false
      return L12_2
    end
  end
  L11_2 = MySQL
  L11_2 = L11_2.scalar
  L11_2 = L11_2.await
  L12_2 = "SELECT label FROM dealership_data WHERE name = ?"
  L13_2 = {}
  L14_2 = A1_2
  L13_2[1] = L14_2
  L11_2 = L11_2(L12_2, L13_2)
  if not L11_2 or "" == L11_2 then
    L11_2 = A1_2
  end
  L12_2 = MySQL
  L12_2 = L12_2.single
  L12_2 = L12_2.await
  L13_2 = "SELECT vehicle.*, stock.stock as stock, stock.price as price FROM dealership_vehicles vehicle INNER JOIN dealership_stock stock ON vehicle.spawn_code = stock.vehicle INNER JOIN dealership_data dealership ON stock.dealership = dealership.name WHERE vehicle.spawn_code = ? AND dealership.name = ?"
  L14_2 = {}
  L15_2 = L6_2
  L16_2 = A1_2
  L14_2[1] = L15_2
  L14_2[2] = L16_2
  L12_2 = L12_2(L13_2, L14_2)
  if not L12_2 then
    L13_2 = false
    return L13_2
  end
  L13_2 = L0_1
  L14_2 = A1_2
  L15_2 = A0_2
  L16_2 = L4_2
  L17_2 = L6_2
  L18_2 = L7_2
  L19_2 = L12_2.price
  L20_2 = L8_2
  L21_2 = L9_2
  L22_2 = L10_2
  L13_2 = L13_2(L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2)
  L14_2 = TriggerClientEvent
  L15_2 = "jg-dealerships:client:show-direct-sale-request"
  L16_2 = L4_2
  L17_2 = {}
  L17_2.uuid = L13_2
  L17_2.dealerPlayerId = A0_2
  L17_2.dealerName = L3_2
  L17_2.dealershipId = A1_2
  L17_2.dealershipLabel = L11_2
  L17_2.vehicle = L12_2
  L17_2.colour = L7_2
  L17_2.financed = L8_2
  L17_2.downPayment = L10_2
  L17_2.noOfPayments = L9_2
  L14_2(L15_2, L16_2, L17_2)
  L14_2 = true
  return L14_2
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-dealerships:server:direct-sale-request-accepted"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L2_2 = PendingDirectSales
  L2_2 = L2_2[A1_2]
  if not L2_2 then
    L3_2 = false
    return L3_2
  end
  L3_2 = L2_2.playerId
  if A0_2 ~= L3_2 then
    L3_2 = false
    return L3_2
  end
  L3_2 = L2_2.finance
  if L3_2 then
    L3_2 = L2_2.price
    L4_2 = Config
    L4_2 = L4_2.FinanceInterest
    L4_2 = 1 + L4_2
    L3_2 = L3_2 * L4_2
    if L3_2 then
      goto lbl_25
    end
  end
  L3_2 = L2_2.price
  ::lbl_25::
  L4_2 = L2_2.dealershipId
  L5_2 = L2_2.dealerPlayerId
  L6_2 = MySQL
  L6_2 = L6_2.query
  L6_2 = L6_2.await
  L7_2 = "SELECT * FROM dealership_data WHERE name = ?"
  L8_2 = {}
  L9_2 = L4_2
  L8_2[1] = L9_2
  L6_2 = L6_2(L7_2, L8_2)
  L7_2 = Round
  L8_2 = L6_2[1]
  L8_2 = L8_2.employee_commission
  if not L8_2 then
    L8_2 = 10
  end
  L8_2 = L8_2 / 100
  L8_2 = L3_2 * L8_2
  L7_2 = L7_2(L8_2)
  L8_2 = MySQL
  L8_2 = L8_2.update
  L8_2 = L8_2.await
  L9_2 = "UPDATE dealership_data SET balance = balance - ? WHERE name = ?"
  L10_2 = {}
  L11_2 = L7_2
  L12_2 = L4_2
  L10_2[1] = L11_2
  L10_2[2] = L12_2
  L8_2(L9_2, L10_2)
  L8_2 = Framework
  L8_2 = L8_2.Server
  L8_2 = L8_2.PlayerAddMoney
  L9_2 = L5_2
  L10_2 = L7_2
  L11_2 = "bank"
  L8_2(L9_2, L10_2, L11_2)
  L8_2 = Framework
  L8_2 = L8_2.Server
  L8_2 = L8_2.Notify
  L9_2 = L5_2
  L10_2 = Locale
  L10_2 = L10_2.directSaleAccepted
  L11_2 = "success"
  L8_2(L9_2, L10_2, L11_2)
  L8_2 = true
  return L8_2
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-dealerships:server:direct-sale-request-denied"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = PendingDirectSales
  L2_2 = L2_2[A1_2]
  if not L2_2 then
    L3_2 = false
    return L3_2
  end
  L3_2 = L2_2.playerId
  if A0_2 ~= L3_2 then
    L3_2 = false
    return L3_2
  end
  L3_2 = L1_1
  L4_2 = A1_2
  L3_2(L4_2)
  L3_2 = Framework
  L3_2 = L3_2.Server
  L3_2 = L3_2.Notify
  L4_2 = L2_2.dealerPlayerId
  L5_2 = Locale
  L5_2 = L5_2.directSaleRejected
  L6_2 = "error"
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = true
  return L3_2
end
L2_1(L3_1, L4_1)
