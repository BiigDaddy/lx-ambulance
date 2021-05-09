ESX = nil
local playersHealing = {}

TriggerEvent('esx:getShlxgaredObjlxgect', function(obj) ESX = obj end)

local bedsTaken = {}

AddEventHandler('playerDropped', function()
    if bedsTaken[source] ~= nil then
        beds[bedsTaken[source]].taken = false
    end
end)

RegisterNetEvent('hospital:server:icu')
AddEventHandler('hospital:server:icu', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' then
		for k, v in pairs(Config.ICU_Beds) do
			if not v.taken then
				v.taken = true
				bedsTaken[target] = k
				TriggerClientEvent('hospital:client:icu', target, k, v)
				return
			end
		end
	else
		print(('esx_ambulancejob: %s attempted to ICU (not ambulance)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('hospital:server:icu:update')
AddEventHandler('hospital:server:icu:update', function(id)
	id.taken = false
end)

RegisterServerEvent('esx_ambulancejob:relxgvive')
AddEventHandler('esx_ambulancejob:relxgvive', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

		xPlayer.addMoney(Config.ReviveReward)
		TriggerClientEvent('esx_ambulancejob:relxgvive', target)
		--TriggerClientEvent('baseevents:onPlayerKilled')
		--TriggerClientEvent('baseevents:onPlayerDied')
end)

RegisterServerEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(target, type)
	local xPlayer = ESX.GetPlayerFromId(source)

		TriggerClientEvent('esx_ambulancejob:heal', target, type)
		--TriggerClientEvent('baseevents:onPlayerKilled')
		--TriggerClientEvent('baseevents:onPlayerDied')
end)

RegisterServerEvent('esx_ambulancejob:putInVehicle')
AddEventHandler('esx_ambulancejob:putInVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' then
		TriggerClientEvent('esx_ambulancejob:putInVehicle', target)
	else
		print(('esx_ambulancejob: %s attempted to put in vehicle!'):format(xPlayer.identifier))
	end
end)

RegisterNetEvent('esx_ambulancejob:OutVehicle')
AddEventHandler('esx_ambulancejob:OutVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' then
		TriggerClientEvent('esx_ambulancejob:OutVehicle', target, source)
	else
		print(('esx_ambulancejob: %s attempted to drag out from vehicle (not ambulance)!'):format(xPlayer.identifier))
	end
end)

RegisterNetEvent('esx_ambulancejob:drag')
AddEventHandler('esx_ambulancejob:drag', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' then
		TriggerClientEvent('esx_ambulancejob:drag', target, source)
	else
		print(('esx_ambulancejob: %s attempted to drag (not ambulance)!'):format(xPlayer.identifier))
	end
end)


RegisterServerEvent('injured:dispatch')
AddEventHandler('injured:dispatch', function(customcoords, title, menu)
	for _, playerId in ipairs(GetPlayers()) do 
		local xPlayer = ESX.GetPlayerFromId(playerId)

		if xPlayer ~= nil then 
			if xPlayer.job.name == 'police' then 
				TriggerClientEvent('cd_dispatch:AddNotification', playerId, {
					job = 'police',
					coords = customcoords,
					title = title, 
					message = mess, 
					flash = 0, 
					blip = {
						sprite = 480,
						scale = 1.0, 
						colour = 1, 
						flashes = false,
						text = title, 
						time = (10*60*1000),
						sound = 3, 
					}
				})
			elseif xPlayer.job.name == 'police' then 
					TriggerClientEvent('cd_dispatch:AddNotification', playerId, {
						job = 'police',
						coords = customcoords,
						title = title, 
						message = mess, 
						flash = 0, 
						blip = {
							sprite = 480,
							scale = 1.0, 
							colour = 1, 
							flashes = false,
							text = title, 
							time = (10*60*1000),
							sound = 3, 
						}
					})
				end 
			end 
		end 
	end)
			



TriggerEvent('esx_phone:registerNumber', 'ambulance', _U('alert_ambulance'), true, true)

TriggerEvent('esx_society:registerSociety', 'ambulance', 'Ambulance', 'society_ambulance', 'society_ambulance', 'society_ambulance', {type = 'public'})

ESX.RegisterServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.RemoveCashAfterRPDeath then
		if xPlayer.getMoney() > 0 then
			xPlayer.removeMoney(xPlayer.getMoney())
		end

		if xPlayer.getAccount('black_money').money > 0 then
			xPlayer.setAccountMoney('black_money', 0)
		end
	end

	if Config.RemoveItemsAfterRPDeath then
		for i=1, #xPlayer.inventory, 1 do
			if xPlayer.inventory[i].count > 0 then
				xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
			end
		end
	end

	local playerLoadout = {}
	if Config.RemoveWeaponsAfterRPDeath then
		for i=1, #xPlayer.loadout, 1 do
			xPlayer.removeWeapon(xPlayer.loadout[i].name)
		end
	else -- save weapons & restore em' since spawnmanager removes them
		for i=1, #xPlayer.loadout, 1 do
			table.insert(playerLoadout, xPlayer.loadout[i])
		end

		-- give back wepaons after a couple of seconds
		Citizen.CreateThread(function()
			Citizen.Wait(5000)
			for i=1, #playerLoadout, 1 do
				if playerLoadout[i].label ~= nil then
					xPlayer.addWeapon(playerLoadout[i].name, playerLoadout[i].ammo)
				end
			end
		end)
	end

	cb()
end)

if Config.EarlyRespawnFine then
	ESX.RegisterServerCallback('esx_ambulancejob:checkBalance', function(source, cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		local bankBalance = xPlayer.getAccount('bank').money

		cb(bankBalance >= Config.EarlyRespawnFineAmount)
	end)

	RegisterServerEvent('esx_ambulancejob:payFine')
	AddEventHandler('esx_ambulancejob:payFine', function()
		local xPlayer = ESX.GetPlayerFromId(source)
		local fineAmount = Config.EarlyRespawnFineAmount

		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('respawn_bleedout_fine_msg', ESX.Math.GroupDigits(fineAmount)))
		xPlayer.removeAccountMoney('bank', fineAmount)
	end)
end

ESX.RegisterServerCallback('esx_ambulancejob:getItemAmount', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local quantity = xPlayer.getInventoryItem(item).count

	cb(quantity)
end)

ESX.RegisterServerCallback('esx_ambulancejob:buyJobVehicle', function(source, cb, vehicleProps, type)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = getPriceFromHash(vehicleProps.model, xPlayer.job.grade_name, type)

	-- vehicle model not found
	if price == 0 then
		print(('esx_ambulancejob: %s attempted to exploit the shop! (invalid vehicle model)'):format(xPlayer.identifier))
		cb(false)
	else
		if xPlayer.getMoney() >= price then
			xPlayer.removeMoney(price)
	
			MySQL.Async.execute('INSERT INTO owned_vehicles (owner, vehicle, plate, type, job, `stored`) VALUES (@owner, @vehicle, @plate, @type, @job, @stored)', {
				['@owner'] = xPlayer.identifier,
				['@vehicle'] = json.encode(vehicleProps),
				['@plate'] = vehicleProps.plate,
				['@type'] = type,
				['@job'] = xPlayer.job.name,
				['@stored'] = true
			}, function (rowsChanged)
				cb(true)
			end)
		else
			cb(false)
		end
	end
end)

ESX.RegisterServerCallback('esx_ambulancejob:storeNearbyVehicle', function(source, cb, nearbyVehicles)
	local xPlayer = ESX.GetPlayerFromId(source)
	local foundPlate, foundNum

	for k,v in ipairs(nearbyVehicles) do
		local result = MySQL.Sync.fetchAll('SELECT plate FROM owned_vehicles WHERE owner = @owner AND plate = @plate AND job = @job', {
			['@owner'] = xPlayer.identifier,
			['@plate'] = v.plate,
			['@job'] = xPlayer.job.name
		})

		if result[1] then
			foundPlate, foundNum = result[1].plate, k
			break
		end
	end

	if not foundPlate then
		cb(false)
	else
		MySQL.Async.execute('UPDATE owned_vehicles SET `stored` = true WHERE owner = @owner AND plate = @plate AND job = @job', {
			['@owner'] = xPlayer.identifier,
			['@plate'] = foundPlate,
			['@job'] = xPlayer.job.name
		}, function (rowsChanged)
			if rowsChanged == 0 then
				print(('esx_ambulancejob: %s has exploited the garage!'):format(xPlayer.identifier))
				cb(false)
			else
				cb(true, foundNum)
			end
		end)
	end

end)

function getPriceFromHash(hashKey, jobGrade, type)
	if type == 'helicopter' then
		local vehicles = Config.AuthorizedHelicopters[jobGrade]

		for k,v in ipairs(vehicles) do
			if GetHashKey(v.model) == hashKey then
				return v.price
			end
		end
	elseif type == 'car' then
		local vehicles = Config.AuthorizedVehicles[jobGrade]

		for k,v in ipairs(vehicles) do
			if GetHashKey(v.model) == hashKey then
				return v.price
			end
		end
	end

	return 0
end

RegisterServerEvent('esx_ambulancejob:removeItem')
AddEventHandler('esx_ambulancejob:removeItem', function(item)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem(item, 1)

	if item == 'bandage' then
		TriggerClientEvent('esx:showNotification', _source, _U('used_bandage'))
	elseif item == 'medikit' then
		TriggerClientEvent('esx:showNotification', _source, _U('used_medikit'))
	end
end)

RegisterServerEvent('esx_ambulancejob:giveItem')
AddEventHandler('esx_ambulancejob:giveItem', function(itemName)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name ~= 'ambulance' then
		print(('esx_ambulancejob: %s attempted to spawn in an item!'):format(xPlayer.identifier))
		return
	elseif (itemName ~= 'medikit' and itemName ~= 'bandage') then
		print(('esx_ambulancejob: %s attempted to spawn in an item!'):format(xPlayer.identifier))
		return
	end

	local xItem = xPlayer.getInventoryItem(itemName)
	local count = 1

	if xItem.limit ~= -1 then
		count = xItem.limit - xItem.count
	end

	if xItem.count < xItem.limit then
		xPlayer.addInventoryItem(itemName, count)
	else
		TriggerClientEvent('esx:showNotification', source, _U('max_item'))
	end
end)

TriggerEvent('es:addGroupCommand', 'revive', 'admin', function(source, args, user)
	if args[1] ~= nil then
		if GetPlayerName(tonumber(args[1])) ~= nil then
			print(('esx_ambulancejob: %s used admin revive'):format(GetPlayerIdentifiers(source)[1]))
			TriggerClientEvent('esx_ambulancejob:relxgvive', tonumber(args[1]))
		end
	else
		TriggerClientEvent('esx_ambulancejob:relxgvive', source)
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, { help = _U('revive_help'), params = {{ name = 'id' }} })

ESX.RegisterUsableItem('medikit', function(source)
	if not playersHealing[source] then
		local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.removeInventoryItem('medikit', 1)
	
		playersHealing[source] = true
		TriggerClientEvent('esx_ambulancejob:useItem', source, 'medikit')

		Citizen.Wait(10000)
		playersHealing[source] = nil
	end
end)

ESX.RegisterUsableItem('bandage', function(source)
	if not playersHealing[source] then
		local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.removeInventoryItem('bandage', 1)
	
		playersHealing[source] = true
		TriggerClientEvent('esx_ambulancejob:useItem', source, 'bandage')

		Citizen.Wait(10000)
		playersHealing[source] = nil
	end
end)

RegisterServerEvent('injured:dispatch')
AddEventHandler('injured:dispatch', function(customcoords, title, mess)
    for _, playerId in ipairs(GetPlayers()) do
		local xPlayer = ESX.GetPlayerFromId(playerId)

        if xPlayer ~= nil then
            if xPlayer.job.name == 'police' then
                TriggerClientEvent('cd_dispatch:AddNotification', playerId, {
                    job = 'ambulance', 
                    coords = customcoords,
                    title = title,
                    message = mess, 
                    flash = 0,
                    blip = {
                        sprite = 480,
                        scale = 1.0,
                        colour = 1,
                        flashes = false,
                        text = title,
                        time = (10*60*1000),
                        sound = 3,
                    }
                })
            elseif xPlayer.job.name == 'ambulance' then
                TriggerClientEvent('cd_dispatch:AddNotification', playerId, {
                    job = 'ambulance', 
                    coords = customcoords,
                    title = title,
                    message = mess, 
                    flash = 0,
                    blip = {
                        sprite = 480,
                        scale = 1.0,
                        colour = 1,
                        flashes = false,
                        text = title,
                        time = (10*60*1000),
                        sound = 3,
                    }
                })
            end
        end
    end
end)


ESX.RegisterServerCallback('esx_ambulancejob:getDeathStatus', function(source, cb)
	local identifier = GetPlayerIdentifiers(source)[1]

	MySQL.Async.fetchScalar('SELECT is_dead FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(number)
		if number == 1 then
			print(('esx_ambulancejob: %s attempted combat logging!'):format(identifier))
		end

		local isdead = false

		if(number == 1)then
			isdead = true
		else
			isdead = false
		end

		cb(isdead)
	end)
end)

RegisterServerEvent('esx_ambulancejob:setDeathStatus')
AddEventHandler('esx_ambulancejob:setDeathStatus', function(isDead)
	local identifier = GetPlayerIdentifiers(source)[1]

	if type(isDead) ~= 'boolean' then
		print(('esx_ambulancejob: %s attempted to parse something else than a boolean to setDeathStatus!'):format(identifier))
		return
	end
	
	local number = 0

	if(isDead)then
		number = 1
	else
		number = 0
	end

	MySQL.Sync.execute('UPDATE users SET is_dead = @number WHERE identifier = @identifier', {
		['@identifier'] = identifier,
		['@number'] = number
	})
end)

RegisterServerEvent('lx_ambulance:dispatch')
AddEventHandler('lx_ambulance:dispatch', function(data, customcoords)
	if customcoords ~= nil then
		data.coords = customcoords
	end

	TriggerClientEvent('cd_dispatch:AddNotification', -1, {
		job = 'ambulance',
		coords = data.coords,
		title = 'Injury Reported',
		message = 'A Citizen Requires Immediate Assistance Near '..data.street_1..', '..data.street_2,
		flash = 0,
		blip = {
			sprite = 280,
			scale = 1.2,
			colour = 3,
			flashes = true,
			text = '911 - Injury',
			time = (5*60*1000),
			sound = 1,
		}
	})
end)
