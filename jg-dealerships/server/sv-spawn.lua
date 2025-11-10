local L0_1, L1_1, L2_1, L3_1, L4_1
L0_1 = {}
L1_1 = 10.0
L2_1 = 3
function L3_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2)
  local L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2
  L7_2 = L0_1
  L7_2 = L7_2[A0_2]
  if L7_2 then
    L7_2 = L0_1
    L7_2 = L7_2[A0_2]
    L8_2 = L2_1
    if L7_2 == L8_2 then
      L7_2 = print
      L8_2 = "^3[WARNING] Vehicle props failed to set after trying several times. First check if the plate within the vehicle props JSON does not match the plate column. If they match, and you see this message regularly, try setting Config.SpawnVehiclesWithServerSetter = false"
      L7_2(L8_2)
      L7_2 = L0_1
      L7_2[A0_2] = 0
      L7_2 = false
      return L7_2
    end
  end
  L7_2 = L0_1
  L8_2 = L0_1
  L8_2 = L8_2[A0_2]
  if not L8_2 then
    L8_2 = 0
  end
  L8_2 = L8_2 + 1
  L7_2[A0_2] = L8_2
  L7_2 = CreateVehicleServerSetter
  L8_2 = A1_2
  L9_2 = A2_2
  L10_2 = A4_2.x
  L11_2 = A4_2.y
  L12_2 = A4_2.z
  L13_2 = A4_2.w
  L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
  L8_2 = lib
  L8_2 = L8_2.waitFor
  function L9_2()
    local L0_3, L1_3
    L0_3 = DoesEntityExist
    L1_3 = L7_2
    L0_3 = L0_3(L1_3)
    if not L0_3 then
      L0_3 = nil
    end
    return L0_3
  end
  L10_2 = "Timed out while trying to spawn in vehicle (server)"
  L11_2 = 10000
  L8_2(L9_2, L10_2, L11_2)
  L8_2 = lib
  L8_2 = L8_2.waitFor
  function L9_2()
    local L0_3, L1_3
    L0_3 = GetVehicleNumberPlateText
    L1_3 = L7_2
    L0_3 = L0_3(L1_3)
    L0_3 = "" ~= L0_3 or L0_3
    return L0_3
  end
  L10_2 = "Vehicle number plate text is nil"
  L11_2 = 5000
  L8_2(L9_2, L10_2, L11_2)
  L8_2 = SetEntityRoutingBucket
  L9_2 = L7_2
  L10_2 = GetPlayerRoutingBucket
  L11_2 = A0_2
  L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2 = L10_2(L11_2)
  L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2)
  L8_2 = SetEntityOrphanMode
  if L8_2 then
    L8_2 = SetEntityOrphanMode
    L9_2 = L7_2
    L10_2 = 2
    L8_2(L9_2, L10_2)
  end
  L8_2 = -1
  L9_2 = 6
  L10_2 = 1
  for L11_2 = L8_2, L9_2, L10_2 do
    L12_2 = GetPedInVehicleSeat
    L13_2 = L7_2
    L14_2 = L11_2
    L12_2 = L12_2(L13_2, L14_2)
    if 0 ~= L12_2 then
      L13_2 = DeleteEntity
      L14_2 = L12_2
      L13_2(L14_2)
    end
  end
  if A5_2 then
    L8_2 = GetPlayerPed
    L9_2 = A0_2
    L8_2 = L8_2(L9_2)
    L9_2 = pcall
    function L10_2()
      local L0_3, L1_3, L2_3, L3_3
      L0_3 = lib
      L0_3 = L0_3.waitFor
      function L1_3()
        local L0_4, L1_4, L2_4, L3_4
        L0_4 = GetPedInVehicleSeat
        L1_4 = L7_2
        L2_4 = -1
        L0_4 = L0_4(L1_4, L2_4)
        L1_4 = L8_2
        if L0_4 == L1_4 then
          L0_4 = true
          return L0_4
        end
        L0_4 = SetPedIntoVehicle
        L1_4 = L8_2
        L2_4 = L7_2
        L3_4 = -1
        L0_4(L1_4, L2_4, L3_4)
      end
      L2_3 = nil
      L3_3 = 1000
      L0_3(L1_3, L2_3, L3_3)
    end
    L9_2(L10_2)
  end
  L8_2 = lib
  L8_2 = L8_2.waitFor
  function L9_2()
    local L0_3, L1_3
    L0_3 = NetworkGetEntityOwner
    L1_3 = L7_2
    L0_3 = L0_3(L1_3)
    L0_3 = -1 ~= L0_3 or L0_3
    return L0_3
  end
  L10_2 = "Timed out waiting for server-setter entity to have an owner (owner is -1)"
  L11_2 = 5000
  L8_2(L9_2, L10_2, L11_2)
  L8_2 = Entity
  L9_2 = L7_2
  L8_2 = L8_2(L9_2)
  L8_2 = L8_2.state
  L9_2 = L8_2
  L8_2 = L8_2.set
  L10_2 = "vehInit"
  L11_2 = true
  L12_2 = true
  L8_2(L9_2, L10_2, L11_2, L12_2)
  if A6_2 then
    L8_2 = type
    L9_2 = A6_2
    L8_2 = L8_2(L9_2)
    if "table" == L8_2 then
      L8_2 = Entity
      L9_2 = L7_2
      L8_2 = L8_2(L9_2)
      L8_2 = L8_2.state
      L9_2 = L8_2
      L8_2 = L8_2.set
      L10_2 = "dealershipVehCreatedApplyProps"
      L11_2 = A6_2
      L12_2 = true
      L8_2(L9_2, L10_2, L11_2, L12_2)
    end
  end
  L8_2 = pcall
  function L9_2()
    local L0_3, L1_3, L2_3, L3_3
    L0_3 = lib
    L0_3 = L0_3.waitFor
    function L1_3()
      local L0_4, L1_4
      L0_4 = Entity
      L1_4 = L7_2
      L0_4 = L0_4(L1_4)
      L0_4 = L0_4.state
      L0_4 = L0_4.dealershipVehCreatedApplyProps
      if not L0_4 then
        L0_4 = A3_2
        if L0_4 then
          L0_4 = A3_2
          if "" ~= L0_4 then
            L0_4 = Framework
            L0_4 = L0_4.Server
            L0_4 = L0_4.GetPlate
            L1_4 = L7_2
            L0_4 = L0_4(L1_4)
            L1_4 = A3_2
            if L0_4 ~= L1_4 then
              goto lbl_24
            end
          end
        end
        L0_4 = true
        return L0_4
      end
      ::lbl_24::
    end
    L2_3 = nil
    L3_3 = 2000
    L0_3(L1_3, L2_3, L3_3)
  end
  L8_2 = L8_2(L9_2)
  if not L8_2 then
    L9_2 = DeleteEntity
    L10_2 = L7_2
    L9_2(L10_2)
    L9_2 = JGDeleteVehicle
    L10_2 = L7_2
    L9_2(L10_2)
    L9_2 = L3_1
    L10_2 = A0_2
    L11_2 = A1_2
    L12_2 = A2_2
    L13_2 = A3_2
    L14_2 = A4_2
    L15_2 = A5_2
    L16_2 = A6_2
    return L9_2(L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2)
  end
  L9_2 = L0_1
  L9_2[A0_2] = 0
  L9_2 = NetworkGetNetworkIdFromEntity
  L10_2 = L7_2
  L9_2 = L9_2(L10_2)
  L10_2 = L7_2
  return L9_2, L10_2
end
function L4_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2, A7_2)
  local L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2
  L8_2 = lib
  L8_2 = L8_2.callback
  L8_2 = L8_2.await
  L9_2 = "jg-dealerships:client:req-vehicle-and-get-spawn-details"
  L10_2 = A0_2
  L11_2 = A2_2
  L8_2, L9_2, L10_2 = L8_2(L9_2, L10_2, L11_2)
  if not L8_2 then
    L11_2 = false
    return L11_2
  end
  L11_2 = GetPlayerPed
  L12_2 = A0_2
  L11_2 = L11_2(L12_2)
  L12_2 = GetEntityCoords
  L13_2 = L11_2
  L12_2 = L12_2(L13_2)
  L13_2 = false
  L14_2 = A4_2.xyz
  L14_2 = L12_2 - L14_2
  L14_2 = #L14_2
  L15_2 = L1_1
  if L14_2 > L15_2 then
    L14_2 = SetEntityCoords
    L15_2 = L11_2
    L16_2 = A4_2.x
    L16_2 = L16_2 + 3.0
    L17_2 = A4_2.y
    L17_2 = L17_2 + 3.0
    L18_2 = A4_2.z
    L19_2 = false
    L20_2 = false
    L21_2 = false
    L22_2 = false
    L14_2(L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2)
    L13_2 = true
  end
  L14_2 = L3_1
  L15_2 = A0_2
  L16_2 = L8_2
  L17_2 = L9_2
  L18_2 = A3_2
  L19_2 = A4_2
  L20_2 = L10_2 or L20_2
  if L10_2 then
    L20_2 = A5_2
  end
  L21_2 = A6_2
  L14_2, L15_2 = L14_2(L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2)
  if not L15_2 or not L14_2 then
    L16_2 = false
    return L16_2
  end
  L16_2 = lib
  L16_2 = L16_2.callback
  L16_2 = L16_2.await
  L17_2 = "jg-dealerships:client:on-server-vehicle-created"
  L18_2 = A0_2
  L19_2 = L14_2
  L20_2 = L13_2 or L20_2
  if L13_2 then
    L20_2 = L12_2
  end
  L21_2 = L10_2 or L21_2
  if L10_2 then
    L21_2 = A5_2
  end
  L22_2 = L8_2
  L23_2 = A1_2
  L24_2 = A3_2
  L25_2 = A6_2
  L26_2 = A7_2
  L16_2 = L16_2(L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2)
  if not L16_2 then
    L17_2 = DoesEntityExist
    L18_2 = L15_2
    L17_2 = L17_2(L18_2)
    if L17_2 then
      L17_2 = DeleteEntity
      L18_2 = L15_2
      L17_2(L18_2)
      L17_2 = DebugPrint
      L18_2 = "Failed to create vehicle, deleted entity."
      L19_2 = "warning"
      L20_2 = L14_2
      L17_2(L18_2, L19_2, L20_2)
    end
    L17_2 = false
    return L17_2
  end
  L17_2 = L14_2
  L18_2 = L15_2
  return L17_2, L18_2
end
SpawnVehicleServer = L4_1
