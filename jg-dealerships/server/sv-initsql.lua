local L0_1, L1_1
function L0_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L2_2 = {}
  L3_2 = string
  L3_2 = L3_2.gmatch
  L4_2 = A0_2
  L5_2 = "([^"
  L6_2 = A1_2
  L7_2 = "]+)"
  L5_2 = L5_2 .. L6_2 .. L7_2
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2, L5_2)
  for L7_2 in L3_2, L4_2, L5_2, L6_2 do
    L8_2 = string
    L8_2 = L8_2.gsub
    L9_2 = L7_2
    L10_2 = "^%s*(.-)%s*$"
    L11_2 = "%1"
    L8_2 = L8_2(L9_2, L10_2, L11_2)
    L9_2 = table
    L9_2 = L9_2.insert
    L10_2 = L2_2
    L11_2 = L8_2
    L9_2(L10_2, L11_2)
  end
  return L2_2
end
function L1_1()
  local L0_2, L1_2
  L0_2 = Config
  L0_2 = L0_2.AutoRunSQL
  if L0_2 then
    L0_2 = pcall
    function L1_2()
      local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3
      L0_3 = Config
      L0_3 = L0_3.Framework
      if "QBCore" ~= L0_3 then
        L0_3 = Config
        L0_3 = L0_3.Framework
        if "Qbox" ~= L0_3 then
          goto lbl_12
        end
      end
      L0_3 = "run-qb.sql"
      ::lbl_12::
      if not L0_3 then
        L0_3 = "run-esx.sql"
      end
      L1_3 = assert
      L2_3 = io
      L2_3 = L2_3.open
      L3_3 = GetResourcePath
      L4_3 = GetCurrentResourceName
      L4_3, L5_3 = L4_3()
      L3_3 = L3_3(L4_3, L5_3)
      L4_3 = "/install/"
      L5_3 = L0_3
      L3_3 = L3_3 .. L4_3 .. L5_3
      L4_3 = "rb"
      L2_3, L3_3, L4_3, L5_3 = L2_3(L3_3, L4_3)
      L1_3 = L1_3(L2_3, L3_3, L4_3, L5_3)
      L3_3 = L1_3
      L2_3 = L1_3.read
      L4_3 = "*all"
      L2_3 = L2_3(L3_3, L4_3)
      L4_3 = L1_3
      L3_3 = L1_3.close
      L3_3(L4_3)
      L3_3 = L0_1
      L4_3 = L2_3
      L5_3 = ";"
      L3_3 = L3_3(L4_3, L5_3)
      L4_3 = MySQL
      L4_3 = L4_3.transaction
      L4_3 = L4_3.await
      L5_3 = L3_3
      L4_3(L5_3)
    end
    L0_2 = L0_2(L1_2)
    if not L0_2 then
      L0_2 = print
      L1_2 = "^1[SQL ERROR] There was an error while automatically running the required SQL. Don't worry, you just need to run the SQL file for your framework, found in the 'install' folder manually. If you've already ran the SQL code previously, and this error is annoying you, set Config.AutoRunSQL = false^0"
      L0_2(L1_2)
    end
  end
end
InitSQL = L1_1
