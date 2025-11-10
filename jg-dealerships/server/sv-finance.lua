local L0_1, L1_1, L2_1
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-dealerships:server:get-financed-vehicles"
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L1_2 = Framework
  L1_2 = L1_2.Server
  L1_2 = L1_2.GetPlayerIdentifier
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  L2_2 = DebugPrint
  L3_2 = "Getting financed vehicles for player "
  L4_2 = L1_2
  L3_2 = L3_2 .. L4_2
  L4_2 = "debug"
  L2_2(L3_2, L4_2)
  L2_2 = MySQL
  L2_2 = L2_2.query
  L2_2 = L2_2.await
  L3_2 = "SELECT * FROM "
  L4_2 = Framework
  L4_2 = L4_2.VehiclesTable
  L5_2 = " WHERE "
  L6_2 = Framework
  L6_2 = L6_2.PlayerId
  L7_2 = " = ? AND financed = ?"
  L3_2 = L3_2 .. L4_2 .. L5_2 .. L6_2 .. L7_2
  L4_2 = {}
  L5_2 = L1_2
  L6_2 = 1
  L4_2[1] = L5_2
  L4_2[2] = L6_2
  L2_2 = L2_2(L3_2, L4_2)
  L3_2 = DebugPrint
  L4_2 = "Got "
  L5_2 = #L2_2
  L6_2 = " financed vehicles for player "
  L7_2 = L1_2
  L4_2 = L4_2 .. L5_2 .. L6_2 .. L7_2
  L5_2 = "debug"
  L3_2(L4_2, L5_2)
  return L2_2
end
L0_1(L1_1, L2_1)
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-dealerships:server:finance-make-payment"
function L2_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2
  L3_2 = Framework
  L3_2 = L3_2.Server
  L3_2 = L3_2.GetPlayerIdentifier
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  L4_2 = MySQL
  L4_2 = L4_2.single
  L4_2 = L4_2.await
  L5_2 = "SELECT * FROM "
  L6_2 = Framework
  L6_2 = L6_2.VehiclesTable
  L7_2 = " WHERE "
  L8_2 = Framework
  L8_2 = L8_2.PlayerId
  L9_2 = " = ? AND plate = ? AND financed = ?"
  L5_2 = L5_2 .. L6_2 .. L7_2 .. L8_2 .. L9_2
  L6_2 = {}
  L7_2 = L3_2
  L8_2 = A1_2
  L9_2 = 1
  L6_2[1] = L7_2
  L6_2[2] = L8_2
  L6_2[3] = L9_2
  L4_2 = L4_2(L5_2, L6_2)
  if L4_2 then
    L5_2 = L4_2.finance_data
    if L5_2 then
      goto lbl_44
    end
  end
  L5_2 = DebugPrint
  L6_2 = "Player "
  L7_2 = L3_2
  L8_2 = " ("
  L9_2 = A0_2
  L10_2 = ") tried to make a payment on a vehicle "
  L11_2 = A1_2
  L12_2 = " that doesn't exist or isn't financed"
  L6_2 = L6_2 .. L7_2 .. L8_2 .. L9_2 .. L10_2 .. L11_2 .. L12_2
  L7_2 = "debug"
  L5_2(L6_2, L7_2)
  L5_2 = {}
  L5_2.error = true
  do return L5_2 end
  ::lbl_44::
  L5_2 = L4_2.financed
  L6_2 = json
  L6_2 = L6_2.decode
  L7_2 = L4_2.finance_data
  L6_2 = L6_2(L7_2)
  if "payment" == A2_2 then
    L7_2 = L6_2.recurring_payment
    L8_2 = Framework
    L8_2 = L8_2.Server
    L8_2 = L8_2.GetPlayerBalance
    L9_2 = A0_2
    L10_2 = "bank"
    L8_2 = L8_2(L9_2, L10_2)
    if L7_2 > L8_2 then
      L7_2 = Framework
      L7_2 = L7_2.Server
      L7_2 = L7_2.Notify
      L8_2 = A0_2
      L9_2 = Locale
      L9_2 = L9_2.errorNotEnoughMoney
      L10_2 = "error"
      L7_2(L8_2, L9_2, L10_2)
      L7_2 = DebugPrint
      L8_2 = "Player "
      L9_2 = A0_2
      L10_2 = " tried to make a payment but didn't have enough money. Bank account: "
      L11_2 = Framework
      L11_2 = L11_2.Server
      L11_2 = L11_2.GetPlayerBalance
      L12_2 = A0_2
      L13_2 = "bank"
      L11_2 = L11_2(L12_2, L13_2)
      L12_2 = " required: "
      L13_2 = L6_2.recurring_payment
      L8_2 = L8_2 .. L9_2 .. L10_2 .. L11_2 .. L12_2 .. L13_2
      L9_2 = "debug"
      L7_2(L8_2, L9_2)
      L7_2 = {}
      L7_2.error = true
      return L7_2
    else
      L7_2 = Framework
      L7_2 = L7_2.Server
      L7_2 = L7_2.PlayerRemoveMoney
      L8_2 = A0_2
      L9_2 = L6_2.recurring_payment
      L10_2 = "bank"
      L7_2(L8_2, L9_2, L10_2)
      L7_2 = MySQL
      L7_2 = L7_2.update
      L7_2 = L7_2.await
      L8_2 = "UPDATE dealership_data SET balance = balance + ? WHERE name = ?"
      L9_2 = {}
      L10_2 = L6_2.recurring_payment
      L11_2 = L6_2.dealership_id
      L9_2[1] = L10_2
      L9_2[2] = L11_2
      L7_2(L8_2, L9_2)
      L7_2 = DebugPrint
      L8_2 = "Player "
      L9_2 = A0_2
      L10_2 = " made a payment of "
      L11_2 = L6_2.recurring_payment
      L12_2 = " for vehicle "
      L13_2 = L4_2.plate
      L14_2 = ". Completed payments: "
      L15_2 = L6_2.payments_complete
      L15_2 = L15_2 + 1
      L8_2 = L8_2 .. L9_2 .. L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2 .. L15_2
      L9_2 = "debug"
      L7_2(L8_2, L9_2)
      L7_2 = L6_2.paid
      L8_2 = L6_2.recurring_payment
      L7_2 = L7_2 + L8_2
      L6_2.paid = L7_2
      L6_2.payment_failed = false
      L7_2 = L6_2.payments_complete
      L7_2 = L7_2 + 1
      L6_2.payments_complete = L7_2
      L7_2 = L6_2.payment_interval
      L7_2 = 3600 * L7_2
      L6_2.seconds_to_next_payment = L7_2
      L7_2 = MySQL
      L7_2 = L7_2.update
      L7_2 = L7_2.await
      L8_2 = "UPDATE dealership_sales SET paid = ?, owed = ? WHERE plate = ?"
      L9_2 = {}
      L10_2 = L6_2.paid
      L11_2 = Round
      L12_2 = L6_2.total
      L13_2 = L6_2.paid
      L12_2 = L12_2 - L13_2
      L11_2 = L11_2(L12_2)
      L12_2 = L4_2.plate
      L9_2[1] = L10_2
      L9_2[2] = L11_2
      L9_2[3] = L12_2
      L7_2(L8_2, L9_2)
      L7_2 = Framework
      L7_2 = L7_2.Server
      L7_2 = L7_2.Notify
      L8_2 = A0_2
      L9_2 = string
      L9_2 = L9_2.gsub
      L10_2 = Locale
      L10_2 = L10_2.vehicleFinancePaymentMade
      L11_2 = "%%{value}"
      L12_2 = L4_2.plate
      L9_2 = L9_2(L10_2, L11_2, L12_2)
      L10_2 = "success"
      L7_2(L8_2, L9_2, L10_2)
      L7_2 = SendWebhook
      L8_2 = A0_2
      L9_2 = Webhooks
      L9_2 = L9_2.Finance
      L10_2 = "Finance: Payment Success"
      L11_2 = "success"
      L12_2 = {}
      L13_2 = {}
      L13_2.key = "Plate"
      L14_2 = L4_2.plate
      L13_2.value = L14_2
      L14_2 = {}
      L14_2.key = "Payment amount"
      L15_2 = L6_2.recurring_payment
      L14_2.value = L15_2
      L12_2[1] = L13_2
      L12_2[2] = L14_2
      L7_2(L8_2, L9_2, L10_2, L11_2, L12_2)
      L7_2 = L6_2.payments_complete
      L8_2 = L6_2.total_payments
      if L7_2 == L8_2 then
        L5_2 = false
        L6_2 = nil
        L7_2 = DebugPrint
        L8_2 = "Player "
        L9_2 = A0_2
        L10_2 = " paid off their vehicle "
        L11_2 = L4_2.plate
        L8_2 = L8_2 .. L9_2 .. L10_2 .. L11_2
        L9_2 = "debug"
        L7_2(L8_2, L9_2)
        L7_2 = Framework
        L7_2 = L7_2.Server
        L7_2 = L7_2.Notify
        L8_2 = A0_2
        L9_2 = string
        L9_2 = L9_2.gsub
        L10_2 = Locale
        L10_2 = L10_2.vehicleFinancePaidOff
        L11_2 = "%%{value}"
        L12_2 = L4_2.plate
        L9_2 = L9_2(L10_2, L11_2, L12_2)
        L10_2 = "success"
        L7_2(L8_2, L9_2, L10_2)
        L7_2 = SendWebhook
        L8_2 = A0_2
        L9_2 = Webhooks
        L9_2 = L9_2.Finance
        L10_2 = "Finance: Vehicle paid off"
        L11_2 = "success"
        L12_2 = {}
        L13_2 = {}
        L13_2.key = "Plate"
        L14_2 = L4_2.plate
        L13_2.value = L14_2
        L12_2[1] = L13_2
        L7_2(L8_2, L9_2, L10_2, L11_2, L12_2)
      end
    end
    if L6_2 then
      L7_2 = json
      L7_2 = L7_2.encode
      L8_2 = L6_2
      L7_2 = L7_2(L8_2)
      L6_2 = L7_2
    end
    L7_2 = MySQL
    L7_2 = L7_2.update
    L7_2 = L7_2.await
    L8_2 = "UPDATE "
    L9_2 = Framework
    L9_2 = L9_2.VehiclesTable
    L10_2 = " SET financed = ?, finance_data = ? WHERE plate = ?"
    L8_2 = L8_2 .. L9_2 .. L10_2
    L9_2 = {}
    L10_2 = L5_2
    L11_2 = L6_2
    L12_2 = L4_2.plate
    L9_2[1] = L10_2
    L9_2[2] = L11_2
    L9_2[3] = L12_2
    L7_2(L8_2, L9_2)
  end
  if "pay-in-full" == A2_2 then
    L7_2 = L6_2.total
    L8_2 = L6_2.paid
    L7_2 = L7_2 - L8_2
    L8_2 = Framework
    L8_2 = L8_2.Server
    L8_2 = L8_2.GetPlayerBalance
    L9_2 = A0_2
    L10_2 = "bank"
    L8_2 = L8_2(L9_2, L10_2)
    if L7_2 > L8_2 then
      L8_2 = DebugPrint
      L9_2 = "Player "
      L10_2 = A0_2
      L11_2 = " tried to pay off their vehicle "
      L12_2 = L4_2.plate
      L13_2 = " but didn't have enough money. Bank account: "
      L14_2 = Framework
      L14_2 = L14_2.Server
      L14_2 = L14_2.GetPlayerBalance
      L15_2 = A0_2
      L16_2 = "bank"
      L14_2 = L14_2(L15_2, L16_2)
      L15_2 = " required: "
      L16_2 = L7_2
      L9_2 = L9_2 .. L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2 .. L15_2 .. L16_2
      L10_2 = "debug"
      L8_2(L9_2, L10_2)
      L8_2 = Framework
      L8_2 = L8_2.Server
      L8_2 = L8_2.Notify
      L9_2 = A0_2
      L10_2 = Locale
      L10_2 = L10_2.errorNotEnoughMoney
      L11_2 = "error"
      L8_2(L9_2, L10_2, L11_2)
      L8_2 = {}
      L8_2.error = true
      return L8_2
    else
      L8_2 = DebugPrint
      L9_2 = "Player "
      L10_2 = A0_2
      L11_2 = " paid off their vehicle "
      L12_2 = L4_2.plate
      L13_2 = " in full. Amount: "
      L14_2 = L7_2
      L9_2 = L9_2 .. L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2
      L10_2 = "debug"
      L8_2(L9_2, L10_2)
      L8_2 = Framework
      L8_2 = L8_2.Server
      L8_2 = L8_2.PlayerRemoveMoney
      L9_2 = A0_2
      L10_2 = L7_2
      L11_2 = "bank"
      L8_2(L9_2, L10_2, L11_2)
      L8_2 = MySQL
      L8_2 = L8_2.update
      L8_2 = L8_2.await
      L9_2 = "UPDATE dealership_data SET balance = balance + ? WHERE name = ?"
      L10_2 = {}
      L11_2 = L7_2
      L12_2 = L6_2.dealership_id
      L10_2[1] = L11_2
      L10_2[2] = L12_2
      L8_2(L9_2, L10_2)
      L8_2 = MySQL
      L8_2 = L8_2.update
      L8_2 = L8_2.await
      L9_2 = "UPDATE "
      L10_2 = Framework
      L10_2 = L10_2.VehiclesTable
      L11_2 = " SET financed = ?, finance_data = ? WHERE plate = ?"
      L9_2 = L9_2 .. L10_2 .. L11_2
      L10_2 = {}
      L11_2 = 0
      L12_2 = nil
      L13_2 = L4_2.plate
      L10_2[1] = L11_2
      L10_2[2] = L12_2
      L10_2[3] = L13_2
      L8_2(L9_2, L10_2)
      L8_2 = MySQL
      L8_2 = L8_2.update
      L8_2 = L8_2.await
      L9_2 = "UPDATE dealership_sales SET paid = ?, owed = ? WHERE plate = ?"
      L10_2 = {}
      L11_2 = L6_2.total
      L12_2 = 0
      L13_2 = L4_2.plate
      L10_2[1] = L11_2
      L10_2[2] = L12_2
      L10_2[3] = L13_2
      L8_2(L9_2, L10_2)
      L8_2 = Framework
      L8_2 = L8_2.Server
      L8_2 = L8_2.Notify
      L9_2 = A0_2
      L10_2 = string
      L10_2 = L10_2.gsub
      L11_2 = Locale
      L11_2 = L11_2.vehicleFinancePaidOff
      L12_2 = "%%{value}"
      L13_2 = L4_2.plate
      L10_2 = L10_2(L11_2, L12_2, L13_2)
      L11_2 = "success"
      L8_2(L9_2, L10_2, L11_2)
      L8_2 = SendWebhook
      L9_2 = A0_2
      L10_2 = Webhooks
      L10_2 = L10_2.Finance
      L11_2 = "Finance: Vehicle paid off"
      L12_2 = "success"
      L13_2 = {}
      L14_2 = {}
      L14_2.key = "Plate"
      L15_2 = L4_2.plate
      L14_2.value = L15_2
      L13_2[1] = L14_2
      L8_2(L9_2, L10_2, L11_2, L12_2, L13_2)
    end
  end
  L7_2 = true
  return L7_2
end
L0_1(L1_1, L2_1)
function L0_1()
  local L0_2, L1_2
  L0_2 = CreateThread
  function L1_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3
    L0_3 = 0
    while true do
      L1_3 = pairs
      L2_3 = Framework
      L2_3 = L2_3.Server
      L2_3 = L2_3.GetPlayers
      L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3 = L2_3()
      L1_3, L2_3, L3_3, L4_3 = L1_3(L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3)
      for L5_3, L6_3 in L1_3, L2_3, L3_3, L4_3 do
        L7_3 = L6_3.player_id
        L8_3 = Framework
        L8_3 = L8_3.Server
        L8_3 = L8_3.GetPlayerIdentifier
        L9_3 = L7_3
        L8_3 = L8_3(L9_3)
        if not L8_3 then
        else
          L9_3 = MySQL
          L9_3 = L9_3.query
          L9_3 = L9_3.await
          L10_3 = "SELECT * FROM "
          L11_3 = Framework
          L11_3 = L11_3.VehiclesTable
          L12_3 = " WHERE "
          L13_3 = Framework
          L13_3 = L13_3.PlayerId
          L14_3 = " = ? AND financed = ?"
          L10_3 = L10_3 .. L11_3 .. L12_3 .. L13_3 .. L14_3
          L11_3 = {}
          L12_3 = L8_3
          L13_3 = 1
          L11_3[1] = L12_3
          L11_3[2] = L13_3
          L9_3 = L9_3(L10_3, L11_3)
          L10_3 = #L9_3
          if 0 == L10_3 then
          else
            L10_3 = DebugPrint
            L11_3 = "Got "
            L12_3 = #L9_3
            L13_3 = " financed vehicles for player "
            L14_3 = L8_3
            L15_3 = " which needs payment"
            L11_3 = L11_3 .. L12_3 .. L13_3 .. L14_3 .. L15_3
            L12_3 = "debug"
            L10_3(L11_3, L12_3)
            L10_3 = ipairs
            L11_3 = L9_3
            L10_3, L11_3, L12_3, L13_3 = L10_3(L11_3)
            for L14_3, L15_3 in L10_3, L11_3, L12_3, L13_3 do
              L16_3 = L15_3.financed
              if L16_3 then
                L16_3 = L15_3.finance_data
                if L16_3 then
                  L16_3 = L15_3.financed
                  L17_3 = json
                  L17_3 = L17_3.decode
                  L18_3 = L15_3.finance_data
                  L17_3 = L17_3(L18_3)
                  L18_3 = L17_3.payment_failed
                  if L18_3 then
                    L18_3 = DebugPrint
                    L19_3 = "Finance payment failed for vehicle "
                    L20_3 = L15_3.plate
                    L21_3 = ". Seconds until repo: "
                    L22_3 = L17_3.seconds_to_repo
                    L19_3 = L19_3 .. L20_3 .. L21_3 .. L22_3
                    L20_3 = "debug"
                    L18_3(L19_3, L20_3)
                    L18_3 = L17_3.seconds_to_repo
                    L19_3 = L0_3 / 1000
                    L18_3 = L18_3 - L19_3
                    L17_3.seconds_to_repo = L18_3
                    L18_3 = Framework
                    L18_3 = L18_3.Server
                    L18_3 = L18_3.Notify
                    L19_3 = L7_3
                    L20_3 = string
                    L20_3 = L20_3.gsub
                    L21_3 = Locale
                    L21_3 = L21_3.vehicleFinanceRepossessedSoon
                    L22_3 = "%%{value}"
                    L23_3 = L15_3.plate
                    L20_3 = L20_3(L21_3, L22_3, L23_3)
                    L21_3 = "error"
                    L18_3(L19_3, L20_3, L21_3)
                    L18_3 = L17_3.seconds_to_repo
                    if L18_3 <= 0 then
                      L18_3 = DebugPrint
                      L19_3 = "Repossessing vehicle "
                      L20_3 = L15_3.plate
                      L21_3 = " due to payment failure"
                      L19_3 = L19_3 .. L20_3 .. L21_3
                      L20_3 = "debug"
                      L18_3(L19_3, L20_3)
                      L18_3 = MySQL
                      L18_3 = L18_3.query
                      L18_3 = L18_3.await
                      L19_3 = "DELETE FROM "
                      L20_3 = Framework
                      L20_3 = L20_3.VehiclesTable
                      L21_3 = " WHERE plate = ?"
                      L19_3 = L19_3 .. L20_3 .. L21_3
                      L20_3 = {}
                      L21_3 = L15_3.plate
                      L20_3[1] = L21_3
                      L18_3(L19_3, L20_3)
                      L18_3 = MySQL
                      L18_3 = L18_3.update
                      L18_3 = L18_3.await
                      L19_3 = "UPDATE dealership_stock SET stock = stock + 1 WHERE vehicle = ? AND dealership = ?"
                      L20_3 = {}
                      L21_3 = L17_3.vehicle
                      L22_3 = L17_3.dealership_id
                      L20_3[1] = L21_3
                      L20_3[2] = L22_3
                      L18_3(L19_3, L20_3)
                      L18_3 = UpdateDealershipShowroomCache
                      L19_3 = L17_3.dealership_id
                      L18_3(L19_3)
                      L18_3 = GetResourceState
                      L19_3 = "jg-advancedgarages"
                      L18_3 = L18_3(L19_3)
                      if "started" == L18_3 then
                        L18_3 = TriggerEvent
                        L19_3 = "jg-advancedgarages:server:DeleteOutsideVehicle"
                        L20_3 = L15_3.plate
                        L18_3(L19_3, L20_3)
                      end
                      L18_3 = Framework
                      L18_3 = L18_3.Server
                      L18_3 = L18_3.Notify
                      L19_3 = L7_3
                      L20_3 = string
                      L20_3 = L20_3.gsub
                      L21_3 = Locale
                      L21_3 = L21_3.vehicleFinanceRepossessed
                      L22_3 = "%%{value}"
                      L23_3 = L15_3.plate
                      L20_3 = L20_3(L21_3, L22_3, L23_3)
                      L21_3 = "error"
                      L18_3(L19_3, L20_3, L21_3)
                      L18_3 = SendWebhook
                      L19_3 = L7_3
                      L20_3 = Webhooks
                      L20_3 = L20_3.Finance
                      L21_3 = "Finance: Vehicle Repossessed!"
                      L22_3 = "danger"
                      L23_3 = {}
                      L24_3 = {}
                      L24_3.key = "Plate"
                      L25_3 = L15_3.plate
                      L24_3.value = L25_3
                      L25_3 = {}
                      L25_3.key = "Balance owed"
                      L26_3 = L17_3.owed
                      L25_3.value = L26_3
                      L23_3[1] = L24_3
                      L23_3[2] = L25_3
                      L18_3(L19_3, L20_3, L21_3, L22_3, L23_3)
                      L18_3 = TriggerEvent
                      L19_3 = "jg-dealerships:server:vehicle-finance-defaulted"
                      L20_3 = L7_3
                      L21_3 = L15_3.plate
                      L22_3 = L17_3.owed
                      L18_3(L19_3, L20_3, L21_3, L22_3)
                    end
                  else
                    L18_3 = L17_3.seconds_to_next_payment
                    L19_3 = L0_3 / 1000
                    L18_3 = L18_3 - L19_3
                    L17_3.seconds_to_next_payment = L18_3
                    L18_3 = L17_3.seconds_to_next_payment
                    if L18_3 <= 0 then
                      L18_3 = L17_3.recurring_payment
                      L19_3 = Framework
                      L19_3 = L19_3.Server
                      L19_3 = L19_3.GetPlayerBalance
                      L20_3 = L7_3
                      L21_3 = "bank"
                      L19_3 = L19_3(L20_3, L21_3)
                      if L18_3 > L19_3 then
                        L18_3 = DebugPrint
                        L19_3 = "Finance payment failed for vehicle "
                        L20_3 = L15_3.plate
                        L21_3 = ". Player "
                        L22_3 = L7_3
                        L23_3 = " didn't have enough money. Bank account: "
                        L24_3 = Framework
                        L24_3 = L24_3.Server
                        L24_3 = L24_3.GetPlayerBalance
                        L25_3 = L7_3
                        L26_3 = "bank"
                        L24_3 = L24_3(L25_3, L26_3)
                        L25_3 = " required: "
                        L26_3 = L17_3.recurring_payment
                        L19_3 = L19_3 .. L20_3 .. L21_3 .. L22_3 .. L23_3 .. L24_3 .. L25_3 .. L26_3
                        L20_3 = "debug"
                        L18_3(L19_3, L20_3)
                        L17_3.payment_failed = true
                        L18_3 = Config
                        L18_3 = L18_3.FinancePaymentFailedHoursUntilRepo
                        L18_3 = 3600 * L18_3
                        L17_3.seconds_to_repo = L18_3
                        L18_3 = Framework
                        L18_3 = L18_3.Server
                        L18_3 = L18_3.Notify
                        L19_3 = L7_3
                        L20_3 = string
                        L20_3 = L20_3.gsub
                        L21_3 = Locale
                        L21_3 = L21_3.vehicleFinancePaymentFailed
                        L22_3 = "%%{value}"
                        L23_3 = L15_3.plate
                        L20_3 = L20_3(L21_3, L22_3, L23_3)
                        L21_3 = "error"
                        L18_3(L19_3, L20_3, L21_3)
                        L18_3 = SendWebhook
                        L19_3 = L7_3
                        L20_3 = Webhooks
                        L20_3 = L20_3.Finance
                        L21_3 = "Finance: Payment Failed"
                        L22_3 = "danger"
                        L23_3 = {}
                        L24_3 = {}
                        L24_3.key = "Plate"
                        L25_3 = L15_3.plate
                        L24_3.value = L25_3
                        L25_3 = {}
                        L25_3.key = "Payment amount"
                        L26_3 = L17_3.recurring_payment
                        L25_3.value = L26_3
                        L23_3[1] = L24_3
                        L23_3[2] = L25_3
                        L18_3(L19_3, L20_3, L21_3, L22_3, L23_3)
                      else
                        L18_3 = Framework
                        L18_3 = L18_3.Server
                        L18_3 = L18_3.PlayerRemoveMoney
                        L19_3 = L7_3
                        L20_3 = L17_3.recurring_payment
                        L21_3 = "bank"
                        L18_3(L19_3, L20_3, L21_3)
                        L18_3 = DebugPrint
                        L19_3 = "Player "
                        L20_3 = L7_3
                        L21_3 = " made a payment of "
                        L22_3 = L17_3.recurring_payment
                        L23_3 = " for vehicle "
                        L24_3 = L15_3.plate
                        L25_3 = ". Completed payments: "
                        L26_3 = L17_3.payments_complete
                        L26_3 = L26_3 + 1
                        L19_3 = L19_3 .. L20_3 .. L21_3 .. L22_3 .. L23_3 .. L24_3 .. L25_3 .. L26_3
                        L20_3 = "debug"
                        L18_3(L19_3, L20_3)
                        L18_3 = MySQL
                        L18_3 = L18_3.update
                        L18_3 = L18_3.await
                        L19_3 = "UPDATE dealership_data SET balance = balance + ? WHERE name = ?"
                        L20_3 = {}
                        L21_3 = L17_3.recurring_payment
                        L22_3 = L17_3.dealership_id
                        L20_3[1] = L21_3
                        L20_3[2] = L22_3
                        L18_3(L19_3, L20_3)
                        L18_3 = L17_3.paid
                        L19_3 = L17_3.recurring_payment
                        L18_3 = L18_3 + L19_3
                        L17_3.paid = L18_3
                        L18_3 = L17_3.payments_complete
                        L18_3 = L18_3 + 1
                        L17_3.payments_complete = L18_3
                        L18_3 = L17_3.payment_interval
                        L18_3 = 3600 * L18_3
                        L17_3.seconds_to_next_payment = L18_3
                        L18_3 = MySQL
                        L18_3 = L18_3.update
                        L18_3 = L18_3.await
                        L19_3 = "UPDATE dealership_sales SET paid = ?, owed = ? WHERE plate = ?"
                        L20_3 = {}
                        L21_3 = L17_3.paid
                        L22_3 = Round
                        L23_3 = L17_3.total
                        L24_3 = L17_3.paid
                        L23_3 = L23_3 - L24_3
                        L22_3 = L22_3(L23_3)
                        L23_3 = L15_3.plate
                        L20_3[1] = L21_3
                        L20_3[2] = L22_3
                        L20_3[3] = L23_3
                        L18_3(L19_3, L20_3)
                        L18_3 = Framework
                        L18_3 = L18_3.Server
                        L18_3 = L18_3.Notify
                        L19_3 = L7_3
                        L20_3 = string
                        L20_3 = L20_3.gsub
                        L21_3 = Locale
                        L21_3 = L21_3.vehicleFinancePaymentMade
                        L22_3 = "%%{value}"
                        L23_3 = L15_3.plate
                        L20_3 = L20_3(L21_3, L22_3, L23_3)
                        L21_3 = "success"
                        L18_3(L19_3, L20_3, L21_3)
                        L18_3 = SendWebhook
                        L19_3 = L7_3
                        L20_3 = Webhooks
                        L20_3 = L20_3.Finance
                        L21_3 = "Finance: Payment Success"
                        L22_3 = "success"
                        L23_3 = {}
                        L24_3 = {}
                        L24_3.key = "Plate"
                        L25_3 = L15_3.plate
                        L24_3.value = L25_3
                        L25_3 = {}
                        L25_3.key = "Payment amount"
                        L26_3 = L17_3.recurring_payment
                        L25_3.value = L26_3
                        L23_3[1] = L24_3
                        L23_3[2] = L25_3
                        L18_3(L19_3, L20_3, L21_3, L22_3, L23_3)
                        L18_3 = L17_3.payments_complete
                        L19_3 = L17_3.total_payments
                        if L18_3 == L19_3 then
                          L18_3 = DebugPrint
                          L19_3 = "Player "
                          L20_3 = L7_3
                          L21_3 = " paid off their vehicle "
                          L22_3 = L15_3.plate
                          L19_3 = L19_3 .. L20_3 .. L21_3 .. L22_3
                          L20_3 = "debug"
                          L18_3(L19_3, L20_3)
                          L16_3 = 0
                          L17_3 = nil
                          L18_3 = Framework
                          L18_3 = L18_3.Server
                          L18_3 = L18_3.Notify
                          L19_3 = L7_3
                          L20_3 = string
                          L20_3 = L20_3.gsub
                          L21_3 = Locale
                          L21_3 = L21_3.vehicleFinancePaidOff
                          L22_3 = "%%{value}"
                          L23_3 = L15_3.plate
                          L20_3 = L20_3(L21_3, L22_3, L23_3)
                          L21_3 = "success"
                          L18_3(L19_3, L20_3, L21_3)
                          L18_3 = SendWebhook
                          L19_3 = L7_3
                          L20_3 = Webhooks
                          L20_3 = L20_3.Finance
                          L21_3 = "Finance: Vehicle paid off"
                          L22_3 = "success"
                          L23_3 = {}
                          L24_3 = {}
                          L24_3.key = "Plate"
                          L25_3 = L15_3.plate
                          L24_3.value = L25_3
                          L23_3[1] = L24_3
                          L18_3(L19_3, L20_3, L21_3, L22_3, L23_3)
                          L18_3 = TriggerEvent
                          L19_3 = "jg-dealerships:server:vehicle-finance-complete"
                          L20_3 = L7_3
                          L21_3 = L15_3.plate
                          L18_3(L19_3, L20_3, L21_3)
                        end
                      end
                    end
                  end
                  if L17_3 then
                    L18_3 = json
                    L18_3 = L18_3.encode
                    L19_3 = L17_3
                    L18_3 = L18_3(L19_3)
                    L17_3 = L18_3
                  end
                  L18_3 = DebugPrint
                  L19_3 = "Updating finance data for vehicle "
                  L20_3 = L15_3.plate
                  L19_3 = L19_3 .. L20_3
                  L20_3 = "debug"
                  L21_3 = L17_3 or L21_3
                  if not L17_3 then
                    L21_3 = ""
                  end
                  L18_3(L19_3, L20_3, L21_3)
                  L18_3 = MySQL
                  L18_3 = L18_3.update
                  L18_3 = L18_3.await
                  L19_3 = "UPDATE "
                  L20_3 = Framework
                  L20_3 = L20_3.VehiclesTable
                  L21_3 = " SET financed = ?, finance_data = ? WHERE plate = ?"
                  L19_3 = L19_3 .. L20_3 .. L21_3
                  L20_3 = {}
                  L21_3 = L16_3
                  L22_3 = L17_3
                  L23_3 = L15_3.plate
                  L20_3[1] = L21_3
                  L20_3[2] = L22_3
                  L20_3[3] = L23_3
                  L18_3(L19_3, L20_3)
                end
              end
              L16_3 = Wait
              L17_3 = 500
              L16_3(L17_3)
            end
          end
        end
      end
      L0_3 = 600000
      L1_3 = Wait
      L2_3 = L0_3
      L1_3(L2_3)
    end
  end
  L0_2(L1_2)
end
InitFinanceThread = L0_1
