local L0_1, L1_1, L2_1, L3_1, L4_1
L0_1 = {}
L1_1 = {}
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = Config
  L1_2 = L1_2.DealershipLocations
  L1_2 = L1_2[A0_2]
  if not L1_2 then
    L2_2 = false
    return L2_2
  end
  L2_2 = L1_2.categories
  if L2_2 then
    L2_2 = L1_2.categories
    L2_2 = #L2_2
    if 0 ~= L2_2 then
      goto lbl_20
    end
  end
  L2_2 = L1_1
  L3_2 = {}
  L2_2[A0_2] = L3_2
  do return end
  ::lbl_20::
  L2_2 = MySQL
  L2_2 = L2_2.query
  L2_2 = L2_2.await
  L3_2 = "SELECT vehicle.*, stock.stock as stock, stock.price as price FROM dealership_vehicles vehicle INNER JOIN dealership_stock stock ON vehicle.spawn_code = stock.vehicle INNER JOIN dealership_data dealership ON stock.dealership = dealership.name WHERE vehicle.category IN (?) AND (dealership.name = ?) ORDER BY vehicle.spawn_code ASC;"
  L4_2 = {}
  L5_2 = L1_2.categories
  L6_2 = A0_2
  L4_2[1] = L5_2
  L4_2[2] = L6_2
  L2_2 = L2_2(L3_2, L4_2)
  L3_2 = L1_1
  L3_2[A0_2] = L2_2
end
UpdateDealershipShowroomCache = L2_1
function L2_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L0_2 = pairs
  L1_2 = Config
  L1_2 = L1_2.DealershipLocations
  L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
  for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
    L6_2 = UpdateDealershipShowroomCache
    L7_2 = L4_2
    L6_2(L7_2)
  end
end
UpdateAllDealershipsShowroomCache = L2_1
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-dealerships:server:enter-showroom"
function L4_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  L4_2 = Framework
  L4_2 = L4_2.Server
  L4_2 = L4_2.GetPlayerIdentifier
  L5_2 = A0_2
  L4_2 = L4_2(L5_2)
  if not L4_2 then
    L5_2 = DebugPrint
    L6_2 = "jg-dealerships:server:enter-showroom: no identifier found for player "
    L7_2 = A0_2
    L6_2 = L6_2 .. L7_2
    L7_2 = "warning"
    L5_2(L6_2, L7_2)
    L5_2 = false
    return L5_2
  end
  L5_2 = GetPlayerPed
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = A2_2.camera
  L6_2 = L6_2.coords
  L7_2 = 0
  L8_2 = Config
  L8_2 = L8_2.ReturnToPreviousRoutingBucket
  if L8_2 then
    L8_2 = GetPlayerRoutingBucket
    L9_2 = A0_2
    L8_2 = L8_2(L9_2)
    L7_2 = L8_2
  end
  L8_2 = L0_1
  L9_2 = {}
  L9_2.dealership = A1_2
  L9_2.originalBucket = L7_2
  L9_2.originalCoords = A3_2
  L8_2[L4_2] = L9_2
  L8_2 = math
  L8_2 = L8_2.random
  L9_2 = 100
  L10_2 = 999
  L8_2 = L8_2(L9_2, L10_2)
  L9_2 = SetPlayerRoutingBucket
  L10_2 = A0_2
  L11_2 = L8_2
  L9_2(L10_2, L11_2)
  L9_2 = SetEntityCoords
  L10_2 = L5_2
  L11_2 = L6_2.x
  L12_2 = L6_2.y
  L13_2 = L6_2.z
  L14_2 = false
  L15_2 = false
  L16_2 = false
  L17_2 = false
  L9_2(L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
  L9_2 = ClearPedTasksImmediately
  L10_2 = L5_2
  L9_2(L10_2)
  L9_2 = FreezeEntityPosition
  L10_2 = L5_2
  L11_2 = true
  L9_2(L10_2, L11_2)
  L9_2 = L1_1
  L9_2 = L9_2[A1_2]
  if not L9_2 then
    L9_2 = UpdateDealershipShowroomCache
    L10_2 = A1_2
    L9_2(L10_2)
  end
  L9_2 = MySQL
  L9_2 = L9_2.scalar
  L9_2 = L9_2.await
  L10_2 = "SELECT COUNT(*) as total FROM "
  L11_2 = Framework
  L11_2 = L11_2.VehiclesTable
  L12_2 = " WHERE financed = 1 AND "
  L13_2 = Framework
  L13_2 = L13_2.PlayerId
  L14_2 = " = ?"
  L10_2 = L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2
  L11_2 = {}
  L12_2 = L4_2
  L11_2[1] = L12_2
  L9_2 = L9_2(L10_2, L11_2)
  L10_2 = {}
  L11_2 = L1_1
  L11_2 = L11_2[A1_2]
  L10_2.vehicles = L11_2
  L11_2 = Config
  L11_2 = L11_2.MaxFinancedVehiclesPerPlayer
  if not L11_2 then
    L11_2 = 999999
  end
  L11_2 = L9_2 < L11_2
  L10_2.financeAllowed = L11_2
  return L10_2
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-dealerships:server:exit-showroom"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L2_2 = Framework
  L2_2 = L2_2.Server
  L2_2 = L2_2.GetPlayerIdentifier
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  if not L2_2 then
    L3_2 = DebugPrint
    L4_2 = "jg-dealerships:server:exit-showroom: no identifier found for player "
    L5_2 = A0_2
    L4_2 = L4_2 .. L5_2
    L5_2 = "warning"
    L3_2(L4_2, L5_2)
    L3_2 = false
    return L3_2
  end
  L3_2 = GetPlayerPed
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  L4_2 = L0_1
  L4_2 = L4_2[L2_2]
  if L4_2 then
    L5_2 = L4_2.originalCoords
    L6_2 = SetPlayerRoutingBucket
    L7_2 = A0_2
    L8_2 = L4_2.originalBucket
    L6_2(L7_2, L8_2)
    L6_2 = SetEntityCoords
    L7_2 = L3_2
    L8_2 = L5_2.x
    L9_2 = L5_2.y
    L10_2 = L5_2.z
    L11_2 = false
    L12_2 = false
    L13_2 = false
    L14_2 = false
    L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  elseif A1_2 then
    L5_2 = SetPlayerRoutingBucket
    L6_2 = A0_2
    L7_2 = 0
    L5_2(L6_2, L7_2)
    L5_2 = Config
    L5_2 = L5_2.DealershipLocations
    L5_2 = L5_2[A1_2]
    L6_2 = L5_2.openShowroom
    L6_2 = L6_2.coords
    L7_2 = SetEntityCoords
    L8_2 = L3_2
    L9_2 = L6_2.x
    L10_2 = L6_2.y
    L11_2 = L6_2.z
    L12_2 = false
    L13_2 = false
    L14_2 = false
    L15_2 = false
    L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
  end
  L5_2 = FreezeEntityPosition
  L6_2 = L3_2
  L7_2 = false
  L5_2(L6_2, L7_2)
  L5_2 = ClearPedTasksImmediately
  L6_2 = L3_2
  L5_2(L6_2)
  L5_2 = L0_1
  L5_2[L2_2] = nil
  L5_2 = true
  return L5_2
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-dealerships:server:get-showroom-vehicle-data"
function L4_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2
  L3_2 = MySQL
  L3_2 = L3_2.single
  L3_2 = L3_2.await
  L4_2 = "SELECT * FROM dealership_stock WHERE vehicle = ? AND dealership = ?"
  L5_2 = {}
  L6_2 = A2_2
  L7_2 = A1_2
  L5_2[1] = L6_2
  L5_2[2] = L7_2
  return L3_2(L4_2, L5_2)
end
L2_1(L3_1, L4_1)
