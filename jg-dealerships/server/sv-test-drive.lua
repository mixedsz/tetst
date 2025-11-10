local L0_1, L1_1, L2_1, L3_1
L0_1 = {}
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:start-test-drive"
function L3_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2, A7_2)
  local L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2
  L8_2 = A3_2 or nil
  if A3_2 then
    L8_2 = NetworkGetEntityFromNetworkId
    L9_2 = A3_2
    L8_2 = L8_2(L9_2)
  end
  L9_2 = GetPlayerPed
  L10_2 = A0_2
  L9_2 = L9_2(L10_2)
  L10_2 = Framework
  L10_2 = L10_2.Server
  L10_2 = L10_2.GetPlayerIdentifier
  L11_2 = A0_2
  L10_2 = L10_2(L11_2)
  if not L10_2 then
    L11_2 = false
    return L11_2
  end
  L11_2 = Config
  L11_2 = L11_2.SpawnVehiclesWithServerSetter
  if L11_2 then
    L11_2 = Config
    L11_2 = L11_2.DoNotSpawnInsideVehicle
    L11_2 = not L11_2
    L12_2 = {}
    L12_2.plate = A6_2
    L12_2.colour = A7_2
    L13_2 = SpawnVehicleServer
    L14_2 = A0_2
    L15_2 = 0
    L16_2 = A4_2
    L17_2 = A6_2
    L18_2 = A2_2
    L19_2 = L11_2
    L20_2 = L12_2
    L21_2 = "testDrive"
    L13_2, L14_2 = L13_2(L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2)
    L8_2 = L14_2
    A3_2 = L13_2
  end
  if not L8_2 or 0 == L8_2 or not A3_2 then
    L11_2 = Framework
    L11_2 = L11_2.Server
    L11_2 = L11_2.Notify
    L12_2 = A0_2
    L13_2 = "Could not spawn vehicle"
    L14_2 = "error"
    L11_2(L12_2, L13_2, L14_2)
    L11_2 = false
    return L11_2
  end
  L11_2 = 0
  L12_2 = Config
  L12_2 = L12_2.TestDriveNotInBucket
  L12_2 = not L12_2
  if L12_2 then
    L13_2 = Config
    L13_2 = L13_2.ReturnToPreviousRoutingBucket
    if L13_2 then
      L13_2 = GetPlayerRoutingBucket
      L14_2 = A0_2
      L13_2 = L13_2(L14_2)
      L11_2 = L13_2
    end
  end
  if L12_2 then
    L13_2 = math
    L13_2 = L13_2.random
    L14_2 = 100
    L15_2 = 999
    L13_2 = L13_2(L14_2, L15_2)
    L14_2 = SetPlayerRoutingBucket
    L15_2 = A0_2
    L16_2 = L13_2
    L14_2(L15_2, L16_2)
    L14_2 = SetEntityRoutingBucket
    L15_2 = L8_2
    L16_2 = L13_2
    L14_2(L15_2, L16_2)
  end
  L13_2 = L0_1
  L14_2 = {}
  L14_2.dealershipId = A1_2
  L14_2.originalBucket = L11_2
  L15_2 = GetEntityCoords
  L16_2 = L9_2
  L15_2 = L15_2(L16_2)
  L14_2.originalCoords = L15_2
  L14_2.vehicleNetId = A3_2
  L14_2.vehicleModel = A4_2
  L14_2.vehicleColour = A7_2
  L13_2[L10_2] = L14_2
  L13_2 = SendWebhook
  L14_2 = A0_2
  L15_2 = Webhooks
  L15_2 = L15_2.TestDrive
  L16_2 = "New Test Drive"
  L17_2 = "success"
  L18_2 = {}
  L19_2 = {}
  L19_2.key = "Vehicle"
  L19_2.value = A5_2
  L20_2 = {}
  L20_2.key = "Dealership"
  L20_2.value = A1_2
  L21_2 = {}
  L21_2.key = "Plate"
  L21_2.value = A6_2
  L18_2[1] = L19_2
  L18_2[2] = L20_2
  L18_2[3] = L21_2
  L13_2(L14_2, L15_2, L16_2, L17_2, L18_2)
  L13_2 = true
  L14_2 = A3_2
  return L13_2, L14_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-dealerships:server:finish-test-drive"
function L3_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L1_2 = Framework
  L1_2 = L1_2.Server
  L1_2 = L1_2.GetPlayerIdentifier
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  if not L1_2 then
    L2_2 = DebugPrint
    L3_2 = "jg-dealerships:server:finish-test-drive: no identifier found for player "
    L4_2 = A0_2
    L3_2 = L3_2 .. L4_2
    L4_2 = "warning"
    L2_2(L3_2, L4_2)
    L2_2 = false
    return L2_2
  end
  L2_2 = L0_1
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = DebugPrint
    L4_2 = "jg-dealerships:server:finish-test-drive: no test drive session found for player "
    L5_2 = A0_2
    L4_2 = L4_2 .. L5_2
    L5_2 = "warning"
    L3_2(L4_2, L5_2)
    L3_2 = false
    return L3_2
  end
  L3_2 = NetworkGetEntityFromNetworkId
  L4_2 = L2_2.vehicleNetId
  L3_2 = L3_2(L4_2)
  L4_2 = SetEntityVelocity
  L5_2 = L3_2
  L6_2 = 0
  L7_2 = 0
  L8_2 = 0
  L4_2(L5_2, L6_2, L7_2, L8_2)
  L4_2 = -1
  L5_2 = 5
  L6_2 = 1
  for L7_2 = L4_2, L5_2, L6_2 do
    L8_2 = GetPedInVehicleSeat
    L9_2 = L3_2
    L10_2 = L7_2
    L8_2 = L8_2(L9_2, L10_2)
    if L8_2 then
      L9_2 = TaskLeaveVehicle
      L10_2 = L8_2
      L11_2 = L3_2
      L12_2 = 0
      L9_2(L10_2, L11_2, L12_2)
    end
  end
  L4_2 = SetVehicleDoorsLocked
  L5_2 = L3_2
  L6_2 = 2
  L4_2(L5_2, L6_2)
  L4_2 = GetPlayerPed
  L5_2 = A0_2
  L4_2 = L4_2(L5_2)
  L5_2 = Config
  L5_2 = L5_2.DealershipLocations
  L6_2 = L2_2.dealershipId
  L5_2 = L5_2[L6_2]
  L6_2 = L5_2.openShowroom
  L6_2 = L6_2.coords
  L7_2 = JGDeleteVehicle
  L8_2 = L3_2
  L7_2(L8_2)
  L7_2 = SetEntityCoords
  L8_2 = L4_2
  L9_2 = L6_2.x
  L10_2 = L6_2.y
  L11_2 = L6_2.z
  L12_2 = false
  L13_2 = false
  L14_2 = false
  L15_2 = false
  L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
  L7_2 = Wait
  L8_2 = 500
  L7_2(L8_2)
  L7_2 = Config
  L7_2 = L7_2.TestDriveNotInBucket
  L7_2 = not L7_2
  if L7_2 then
    L8_2 = SetPlayerRoutingBucket
    L9_2 = A0_2
    L10_2 = L2_2.originalBucket
    L8_2(L9_2, L10_2)
  end
  L2_2[L1_2] = nil
  return L2_2
end
L1_1(L2_1, L3_1)
