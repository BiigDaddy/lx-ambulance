
local beds = {
	{x = 1116.87, y = -1533.23, z = 34.43, h = 90.12, taken = false },
	{x = 1116.72, y = -1538.61, z = 34.43, h = 90.12, taken = false },
	{x = 1116.26, y = -1531.09, z = 34.43, h = 0.12, taken = false },
	{x = 1130.34, y = -1548.54, z = 34.91, h = 180.12, taken = false },
}


local bedsTaken = {}

AddEventHandler('playerDropped', function()
    if bedsTaken[source] ~= nil then
        beds[bedsTaken[source]].taken = false
    end
end)

RegisterServerEvent('mythic_hospital:server:RequestBed')
AddEventHandler('mythic_hospital:server:RequestBed', function()
    for k, v in pairs(beds) do
        if not v.taken then
            v.taken = true
            bedsTaken[source] = k
            TriggerClientEvent('mythic_hospital:client:SendToBed', source, k, v)
            return
        end
    end

    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'No Beds Available' })
end)

RegisterServerEvent('mythic_hospital:server:RPRequestBed')
AddEventHandler('mythic_hospital:server:RPRequestBed', function(plyCoords)
    local foundbed = false
    for k, v in pairs(beds) do
        local distance = #(vector3(v.x, v.y, v.z) - plyCoords)
        if distance < 3.0 then
            if not v.taken then
                v.taken = true
                foundbed = true
                TriggerClientEvent('mythic_hospital:client:RPSendToBed', source, k, v)
                return
            else
                TriggerEvent('chatMessage', '', { 0, 0, 0 }, 'NThat Bed Is Taken')
            end
        end
    end

    if not foundbed then
        TriggerEvent('chatMessage', '', { 0, 0, 0 }, 'Not Near A Hospital Bed')
    end
end)

RegisterServerEvent('mythic_hospital:server:EnteredBed')
AddEventHandler('mythic_hospital:server:EnteredBed', function()
    local src = source
    local totalBill = CalculateBill(GetCharsInjuries(src), Config.InjuryBase)

    
    if BillPlayer(src, totalBill) then
        --TriggerClientEvent('mythic_notify:client:SendAlert', src, { text = 'You\'ve Been Treated & Billed', type = 'inform', style = { ['background-color'] = '#575eb8' }})
        TriggerClientEvent('mythic_hospital:client:FinishServices', src, false, true)
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', src, { text = 'You were revived, but did not have the funds to cover further medical services', type = 'inform'})
        TriggerClientEvent('mythic_hospital:client:FinishServices', src, false, false)
    end
end)

RegisterServerEvent('mythic_hospital:server:LeaveBed')
AddEventHandler('mythic_hospital:server:LeaveBed', function(id)
    beds[id].taken = false
end)