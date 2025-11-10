local L0_1, L1_1, L2_1
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-dealerships:server:get-locations-data"
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L1_2 = Framework
  L1_2 = L1_2.Server
  L1_2 = L1_2.GetPlayerIdentifier
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  L2_2 = MySQL
  L2_2 = L2_2.query
  L2_2 = L2_2.await
  L3_2 = "SELECT d.*, e.identifier, e.role FROM dealership_data d LEFT JOIN dealership_employees e ON d.name = e.dealership AND e.identifier = ?"
  L4_2 = {}
  L5_2 = L1_2
  L4_2[1] = L5_2
  L2_2 = L2_2(L3_2, L4_2)
  L3_2 = {}
  if L1_2 then
    L4_2 = DebugPrint
    L5_2 = "Getting dealership data for player "
    L6_2 = L1_2
    L5_2 = L5_2 .. L6_2
    L6_2 = "debug"
    L4_2(L5_2, L6_2)
  end
  L4_2 = pairs
  L5_2 = L2_2
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    L10_2 = Config
    L10_2 = L10_2.DealershipLocations
    L11_2 = L9_2.name
    L10_2 = L10_2[L11_2]
    L11_2 = "-"
    L12_2 = false
    if L10_2 then
      L13_2 = L10_2.type
      L12_2 = true
      L11_2 = L13_2
    end
    L13_2 = L9_2.label
    if "" == L13_2 then
      L13_2 = L9_2.name
      L9_2.label = L13_2
    end
    L13_2 = #L3_2
    L13_2 = L13_2 + 1
    L14_2 = {}
    L15_2 = L9_2.name
    L14_2.name = L15_2
    L14_2.type = L11_2
    L15_2 = L9_2.label
    L14_2.label = L15_2
    L15_2 = L9_2.balance
    L14_2.balance = L15_2
    L14_2.active = L12_2
    L15_2 = L9_2.owner_id
    L15_2 = L15_2 == L1_2
    L14_2.managementAccess = L15_2
    L14_2.config = L10_2
    L3_2[L13_2] = L14_2
  end
  return L3_2
end
L0_1(L1_1, L2_1)
