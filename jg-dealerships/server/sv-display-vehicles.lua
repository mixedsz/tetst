local L0_1, L1_1, L2_1
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-dealerships:server:get-display-vehicles"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L2_2 = Framework
  L2_2 = L2_2.Server
  L2_2 = L2_2.GetPlayerIdentifier
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  L3_2 = MySQL
  L3_2 = L3_2.single
  L3_2 = L3_2.await
  L4_2 = "SELECT d.*, e.identifier, e.role FROM dealership_data d LEFT JOIN dealership_employees e ON d.name = e.dealership AND e.identifier = ? WHERE d.name = ?"
  L5_2 = {}
  L6_2 = L2_2
  L7_2 = A1_2
  L5_2[1] = L6_2
  L5_2[2] = L7_2
  L3_2 = L3_2(L4_2, L5_2)
  if not L3_2 then
    L4_2 = false
    return L4_2
  end
  L4_2 = L3_2.owner_id
  L4_2 = L4_2 == L2_2
  L5_2 = MySQL
  L5_2 = L5_2.query
  L5_2 = L5_2.await
  L6_2 = "SELECT dispveh.*, vehicle.model, vehicle.brand FROM dealership_dispveh dispveh INNER JOIN dealership_vehicles vehicle ON dispveh.vehicle = vehicle.spawn_code WHERE dealership = ?"
  L7_2 = {}
  L8_2 = A1_2
  L7_2[1] = L8_2
  L5_2 = L5_2(L6_2, L7_2)
  L6_2 = {}
  L6_2.isManager = L4_2
  L6_2.vehicles = L5_2
  return L6_2
end
L0_1(L1_1, L2_1)
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-dealerships:server:create-display-vehicle"
function L2_1(A0_2, A1_2, A2_2, A3_2, A4_2)
  local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L5_2 = MySQL
  L5_2 = L5_2.query
  L5_2 = L5_2.await
  L6_2 = "INSERT INTO dealership_dispveh (dealership,vehicle,color,coords) VALUES(?,?,?,?)"
  L7_2 = {}
  L8_2 = A1_2
  L9_2 = A2_2
  L10_2 = A3_2
  L11_2 = json
  L11_2 = L11_2.encode
  L12_2 = A4_2
  L11_2, L12_2 = L11_2(L12_2)
  L7_2[1] = L8_2
  L7_2[2] = L9_2
  L7_2[3] = L10_2
  L7_2[4] = L11_2
  L7_2[5] = L12_2
  L5_2(L6_2, L7_2)
  L5_2 = TriggerClientEvent
  L6_2 = "jg-dealerships:client:spawn-display-vehicles"
  L7_2 = -1
  L8_2 = A1_2
  L5_2(L6_2, L7_2, L8_2)
  L5_2 = true
  return L5_2
end
L0_1(L1_1, L2_1)
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-dealerships:server:edit-display-vehicle"
function L2_1(A0_2, A1_2, A2_2, A3_2, A4_2)
  local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L5_2 = MySQL
  L5_2 = L5_2.query
  L5_2 = L5_2.await
  L6_2 = "UPDATE dealership_dispveh SET vehicle = ?, color = ? WHERE id = ?"
  L7_2 = {}
  L8_2 = A3_2
  L9_2 = A4_2
  L10_2 = A2_2
  L7_2[1] = L8_2
  L7_2[2] = L9_2
  L7_2[3] = L10_2
  L5_2(L6_2, L7_2)
  L5_2 = TriggerClientEvent
  L6_2 = "jg-dealerships:client:spawn-display-vehicles"
  L7_2 = -1
  L8_2 = A1_2
  L5_2(L6_2, L7_2, L8_2)
  L5_2 = true
  return L5_2
end
L0_1(L1_1, L2_1)
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-dealerships:server:delete-display-vehicle"
function L2_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2
  L3_2 = MySQL
  L3_2 = L3_2.query
  L3_2 = L3_2.await
  L4_2 = "DELETE FROM dealership_dispveh WHERE id = ?"
  L5_2 = {}
  L6_2 = A2_2
  L5_2[1] = L6_2
  L3_2(L4_2, L5_2)
  L3_2 = TriggerClientEvent
  L4_2 = "jg-dealerships:client:spawn-display-vehicles"
  L5_2 = -1
  L6_2 = A1_2
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = true
  return L3_2
end
L0_1(L1_1, L2_1)
