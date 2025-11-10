local L0_1, L1_1, L2_1
L0_1 = math
L0_1 = L0_1.randomseed
L1_1 = os
L1_1 = L1_1.time
L1_1, L2_1 = L1_1()
L0_1(L1_1, L2_1)
function L0_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  L1_2 = string
  L1_2 = L1_2.gsub
  L2_2 = L0_2
  L3_2 = "[xy]"
  function L4_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3
    if "x" == A0_3 then
      L1_3 = math
      L1_3 = L1_3.random
      L2_3 = 0
      L3_3 = 15
      L1_3 = L1_3(L2_3, L3_3)
      if L1_3 then
        goto lbl_15
      end
    end
    L1_3 = math
    L1_3 = L1_3.random
    L2_3 = 8
    L3_3 = 11
    L1_3 = L1_3(L2_3, L3_3)
    ::lbl_15::
    L2_3 = string
    L2_3 = L2_3.format
    L3_3 = "%x"
    L4_3 = L1_3
    return L2_3(L3_3, L4_3)
  end
  L1_2 = L1_2(L2_2, L3_2, L4_2)
  return L1_2
end
GenerateUuid = L0_1
function L0_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L4_2 = lib
  L4_2 = L4_2.getNearbyPlayers
  L5_2 = A1_2
  L6_2 = A2_2
  L4_2 = L4_2(L5_2, L6_2)
  L5_2 = {}
  L6_2 = ipairs
  L7_2 = L4_2
  L6_2, L7_2, L8_2, L9_2 = L6_2(L7_2)
  for L10_2, L11_2 in L6_2, L7_2, L8_2, L9_2 do
    if not A3_2 then
      L12_2 = L11_2.id
      if A0_2 == L12_2 then
        goto lbl_40
      end
    end
    L12_2 = #L5_2
    L12_2 = L12_2 + 1
    L13_2 = {}
    L14_2 = L11_2.id
    L13_2.id = L14_2
    L14_2 = Framework
    L14_2 = L14_2.Server
    L14_2 = L14_2.GetPlayerIdentifier
    L15_2 = L11_2.id
    L14_2 = L14_2(L15_2)
    L13_2.identifier = L14_2
    L14_2 = Framework
    L14_2 = L14_2.Server
    L14_2 = L14_2.GetPlayerInfo
    L15_2 = L11_2.id
    L14_2 = L14_2(L15_2)
    if L14_2 then
      L14_2 = L14_2.name
    end
    L13_2.name = L14_2
    L5_2[L12_2] = L13_2
    ::lbl_40::
  end
  L6_2 = DebugPrint
  L7_2 = "Found %s nearby players"
  L8_2 = L7_2
  L7_2 = L7_2.format
  L9_2 = #L5_2
  L7_2 = L7_2(L8_2, L9_2)
  L8_2 = "debug"
  L9_2 = L5_2
  L6_2(L7_2, L8_2, L9_2)
  return L5_2
end
GetNearbyPlayers = L0_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L1_2 = nil
  L2_2 = -1
  L3_2 = pairs
  L4_2 = Config
  L4_2 = L4_2.DealershipLocations
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = L8_2.openShowroom
    L9_2 = L9_2.coords
    L10_2 = vector3
    L11_2 = L9_2.x
    L12_2 = L9_2.y
    L13_2 = L9_2.z
    L10_2 = L10_2(L11_2, L12_2, L13_2)
    L10_2 = A0_2 - L10_2
    L10_2 = #L10_2
    if -1 == L2_2 or L2_2 > L10_2 then
      L1_2 = L7_2
      L2_2 = L10_2
    end
  end
  L3_2 = L1_2
  L4_2 = L2_2
  return L3_2, L4_2
end
GetCurrentDealershipLocation = L0_1
L0_1 = RegisterNetEvent
L1_1 = "jg-dealerships:server:exit-bucket"
function L2_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = source
  L1_2 = SetPlayerRoutingBucket
  L2_2 = L0_2
  L3_2 = 0
  L1_2(L2_2, L3_2)
  L1_2 = print
  L2_2 = "Restart: emegency player %s breakout to bucket 0"
  L3_2 = L2_2
  L2_2 = L2_2.format
  L4_2 = L0_2
  L2_2, L3_2, L4_2 = L2_2(L3_2, L4_2)
  L1_2(L2_2, L3_2, L4_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNetEvent
L1_1 = "jg-dealerships:server:notify-other-player"
function L2_1(A0_2, ...)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = TriggerClientEvent
  L2_2 = "jg-dealerships:client:notify"
  L3_2 = A0_2
  L4_2 = ...
  L1_2(L2_2, L3_2, L4_2)
end
L0_1(L1_1, L2_1)
L0_1 = AddEventHandler
L1_1 = "onResourceStart"
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L1_2 = GetCurrentResourceName
  L1_2 = L1_2()
  if L1_2 ~= A0_2 then
    return
  end
  L1_2 = InitSQL
  L1_2()
  L1_2 = pairs
  L2_2 = Config
  L2_2 = L2_2.DealershipLocations
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = MySQL
    L7_2 = L7_2.insert
    L7_2 = L7_2.await
    L8_2 = "INSERT IGNORE INTO dealership_data (name, balance) VALUES(?, 0)"
    L9_2 = {}
    L10_2 = L5_2
    L9_2[1] = L10_2
    L7_2(L8_2, L9_2)
  end
  L1_2 = MySQL
  L1_2 = L1_2.query
  L1_2 = L1_2.await
  L2_2 = "SHOW COLUMNS FROM dealership_vehicles LIKE 'hashkey'"
  L1_2 = L1_2(L2_2)
  L2_2 = #L1_2
  if 0 == L2_2 then
    L2_2 = MySQL
    L2_2 = L2_2.query
    L2_2 = L2_2.await
    L3_2 = "ALTER TABLE dealership_vehicles ADD hashkey VARCHAR(100)"
    L2_2(L3_2)
  end
  L2_2 = MySQL
  L2_2 = L2_2.query
  L2_2 = L2_2.await
  L3_2 = "SELECT spawn_code FROM dealership_vehicles WHERE hashkey IS NULL"
  L2_2 = L2_2(L3_2)
  L3_2 = pairs
  L4_2 = L2_2
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = MySQL
    L9_2 = L9_2.update
    L9_2 = L9_2.await
    L10_2 = "UPDATE dealership_vehicles SET hashkey = ? WHERE spawn_code = ?"
    L11_2 = {}
    L12_2 = GetHashKey
    L13_2 = L8_2.spawn_code
    L12_2 = L12_2(L13_2)
    L13_2 = L8_2.spawn_code
    L11_2[1] = L12_2
    L11_2[2] = L13_2
    L9_2(L10_2, L11_2)
  end
  L3_2 = InitFinanceThread
  L3_2()
  L3_2 = InitOrderProcessingThread
  L3_2()
end
L0_1(L1_1, L2_1)
