local L0_1, L1_1, L2_1, L3_1
function L0_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2
  L4_2 = Config
  L4_2 = L4_2.DealershipLocations
  L4_2 = L4_2[A1_2]
  L5_2 = L4_2.enableSellVehicle
  if not L5_2 then
    L5_2 = false
    return L5_2
  end
  L5_2 = Config
  L5_2 = L5_2.DealershipLocations
  L5_2 = L5_2[A1_2]
  L6_2 = Framework
  L6_2 = L6_2.Server
  L6_2 = L6_2.GetPlayerIdentifier
  L7_2 = A0_2
  L6_2 = L6_2(L7_2)
  L7_2 = MySQL
  L7_2 = L7_2.single
  L7_2 = L7_2.await
  L8_2 = "SELECT * FROM "
  L9_2 = Framework
  L9_2 = L9_2.VehiclesTable
  L10_2 = " WHERE plate = ? AND "
  L11_2 = Framework
  L11_2 = L11_2.PlayerId
  L12_2 = " = ?"
  L8_2 = L8_2 .. L9_2 .. L10_2 .. L11_2 .. L12_2
  L9_2 = {}
  L10_2 = A2_2
  L11_2 = L6_2
  L9_2[1] = L10_2
  L9_2[2] = L11_2
  L7_2 = L7_2(L8_2, L9_2)
  if not L7_2 then
    L8_2 = DebugPrint
    L9_2 = "The vehicle "
    L10_2 = A2_2
    L11_2 = " is not owned by player: "
    L12_2 = L6_2
    L13_2 = " ("
    L14_2 = A0_2
    L15_2 = ")"
    L9_2 = L9_2 .. L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2 .. L15_2
    L10_2 = "warning"
    L8_2(L9_2, L10_2)
    L8_2 = Framework
    L8_2 = L8_2.Server
    L8_2 = L8_2.Notify
    L9_2 = A0_2
    L10_2 = Locale
    L10_2 = L10_2.notYourVehicleError
    L11_2 = "error"
    L8_2(L9_2, L10_2, L11_2)
    L8_2 = false
    return L8_2
  end
  L8_2 = Framework
  L8_2 = L8_2.Server
  L8_2 = L8_2.GetModelColumn
  L9_2 = L7_2
  L8_2 = L8_2(L9_2)
  L9_2 = type
  L10_2 = L8_2
  L9_2 = L9_2(L10_2)
  if "string" == L9_2 then
    L10_2 = L8_2
    L9_2 = L8_2.lower
    L9_2 = L9_2(L10_2)
    L8_2 = L9_2
  end
  L10_2 = A3_2
  L9_2 = A3_2.lower
  L9_2 = L9_2(L10_2)
  A3_2 = L9_2
  if L8_2 ~= A3_2 then
    L9_2 = joaat
    L10_2 = A3_2
    L9_2 = L9_2(L10_2)
    if L8_2 ~= L9_2 then
      L9_2 = DebugPrint
      L10_2 = "[sell-vehicle]: model does not match db: "
      L11_2 = L8_2
      L12_2 = " doesn't match "
      L13_2 = A3_2
      L14_2 = " or "
      L15_2 = joaat
      L16_2 = A3_2
      L15_2 = L15_2(L16_2)
      L10_2 = L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2 .. L15_2
      L11_2 = "warning"
      L9_2(L10_2, L11_2)
      L9_2 = Framework
      L9_2 = L9_2.Server
      L9_2 = L9_2.Notify
      L10_2 = A0_2
      L11_2 = "MODEL_DOES_NOT_MATCH_DB"
      L12_2 = "error"
      L9_2(L10_2, L11_2, L12_2)
      L9_2 = false
      return L9_2
    end
  end
  L9_2 = L7_2.financed
  if L9_2 then
    L9_2 = Framework
    L9_2 = L9_2.Server
    L9_2 = L9_2.Notify
    L10_2 = A0_2
    L11_2 = Locale
    L11_2 = L11_2.vehicleFinancedError
    L12_2 = "error"
    L9_2(L10_2, L11_2, L12_2)
    L9_2 = false
    return L9_2
  end
  L9_2 = MySQL
  L9_2 = L9_2.single
  L9_2 = L9_2.await
  L10_2 = "SELECT *, stock.price as stock_price FROM dealership_stock stock INNER JOIN dealership_vehicles vehicle ON vehicle.spawn_code = stock.vehicle WHERE stock.dealership = ? AND vehicle.spawn_code = ?"
  L11_2 = {}
  L12_2 = A1_2
  L13_2 = A3_2
  L11_2[1] = L12_2
  L11_2[2] = L13_2
  L9_2 = L9_2(L10_2, L11_2)
  if not L9_2 then
    L10_2 = Framework
    L10_2 = L10_2.Server
    L10_2 = L10_2.Notify
    L11_2 = A0_2
    L12_2 = Locale
    L12_2 = L12_2.dealershipDoesntSellVehicle
    L13_2 = "error"
    L10_2(L11_2, L12_2, L13_2)
    L10_2 = false
    return L10_2
  end
  L10_2 = Round
  L11_2 = L9_2.stock_price
  L12_2 = L4_2.sellVehiclePercent
  if not L12_2 then
    L12_2 = 0.6
  end
  L11_2 = L11_2 * L12_2
  L10_2 = L10_2(L11_2)
  L11_2 = L5_2
  L12_2 = L9_2
  return L10_2, L11_2, L12_2
end
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:sell-vehicle-get-value"
function L3_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L4_2 = L0_1
  L5_2 = A0_2
  L6_2 = A1_2
  L7_2 = A2_2
  L8_2 = A3_2
  L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2)
  if not L4_2 then
    L5_2 = false
    return L5_2
  end
  L5_2 = SellVehiclePreCheck
  L6_2 = A1_2
  L7_2 = A2_2
  L8_2 = A3_2
  L9_2 = L4_2
  L5_2 = L5_2(L6_2, L7_2, L8_2, L9_2)
  if not L5_2 then
    L5_2 = false
    return L5_2
  end
  return L4_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:sell-vehicle"
function L3_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L4_2 = L0_1
  L5_2 = A0_2
  L6_2 = A1_2
  L7_2 = A2_2
  L8_2 = A3_2
  L4_2, L5_2, L6_2 = L4_2(L5_2, L6_2, L7_2, L8_2)
  if not (L4_2 and L5_2) or not L6_2 then
    L7_2 = false
    return L7_2
  end
  L7_2 = L5_2.type
  if "owned" == L7_2 then
    L7_2 = MySQL
    L7_2 = L7_2.scalar
    L7_2 = L7_2.await
    L8_2 = "SELECT balance FROM dealership_data WHERE name = ?"
    L9_2 = {}
    L10_2 = A1_2
    L9_2[1] = L10_2
    L7_2 = L7_2(L8_2, L9_2)
    L8_2 = L7_2 - L4_2
    if L8_2 < 0 then
      L8_2 = Framework
      L8_2 = L8_2.Server
      L8_2 = L8_2.Notify
      L9_2 = A0_2
      L10_2 = Locale
      L10_2 = L10_2.dealershipDoesntSellVehicle
      L11_2 = "error"
      L8_2(L9_2, L10_2, L11_2)
      L8_2 = false
      return L8_2
    end
    L8_2 = MySQL
    L8_2 = L8_2.update
    L8_2 = L8_2.await
    L9_2 = "UPDATE dealership_data SET balance = balance - ? WHERE name = ?"
    L10_2 = {}
    L11_2 = L4_2
    L12_2 = A1_2
    L10_2[1] = L11_2
    L10_2[2] = L12_2
    L8_2(L9_2, L10_2)
    L8_2 = MySQL
    L8_2 = L8_2.update
    L8_2 = L8_2.await
    L9_2 = "UPDATE dealership_stock SET stock = stock + 1 WHERE dealership = ? AND vehicle = ?"
    L10_2 = {}
    L11_2 = A1_2
    L12_2 = L6_2.spawn_code
    L10_2[1] = L11_2
    L10_2[2] = L12_2
    L8_2(L9_2, L10_2)
    L8_2 = UpdateDealershipShowroomCache
    L9_2 = A1_2
    L8_2(L9_2)
  end
  L7_2 = MySQL
  L7_2 = L7_2.query
  L7_2 = L7_2.await
  L8_2 = "DELETE FROM %s WHERE plate = ?"
  L9_2 = L8_2
  L8_2 = L8_2.format
  L10_2 = Framework
  L10_2 = L10_2.VehiclesTable
  L8_2 = L8_2(L9_2, L10_2)
  L9_2 = {}
  L10_2 = A2_2
  L9_2[1] = L10_2
  L7_2(L8_2, L9_2)
  L7_2 = Framework
  L7_2 = L7_2.Server
  L7_2 = L7_2.PlayerAddMoney
  L8_2 = A0_2
  L9_2 = L4_2
  L10_2 = "bank"
  L7_2(L8_2, L9_2, L10_2)
  L7_2 = true
  return L7_2
end
L1_1(L2_1, L3_1)
