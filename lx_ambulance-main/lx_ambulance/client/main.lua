Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local FirstSpawn, PlayerLoaded = true, false

IsDead = false
ESX = nil

inBed = false
local inMythicBed = false

CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getShlxgaredObjlxgect', function(obj) ESX = obj end)
		Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Wait(100)
	end

	PlayerLoaded = true
	ESX.PlayerData = ESX.GetPlayerData()

	if (ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance') then
		exports['rp-radio'].GivePlayerAccessToFrequencies('idkwhatshitisthat', '1')
	else
		exports['rp-radio'].RemovePlayerAccessToFrequencies('idkwhatshitisthat', '1')
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	PlayerLoaded = true

	if (ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance') then
		exports['rp-radio'].GivePlayerAccessToFrequencies('idkwhatshitisthat', '1')
	else
		exports['rp-radio'].RemovePlayerAccessToFrequencies('idkwhatshitisthat', '1')
	end
end)

function SendDistressSignal()

	local coords = GetEntityCoords(PlayerPedId())
	
	local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, coords.x,coords.y,coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
	local street1 = GetStreetNameFromHashKey{s1}
	local street2 = GetStreetNameFromHashKey{s2}

	local streetLabel = street1 
	if street2 ~= nil and street2 ~= "" then 
		streetLabel = streetLabel .. " " .. street2 
	end 

	ESX.ShowNotification(_U{'distress_sent'})

	TriggerServerEvent('lx_ambulance:dispatch', exports['cd_dispatch']:GetPlayerInfo())
end 


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job

	if (ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance') then
		exports['rp-radio'].GivePlayerAccessToFrequencies('idkwhatshitisthat', '1')
	else
		exports['rp-radio'].RemovePlayerAccessToFrequencies('idkwhatshitisthat', '1')
	end
end)

AddEventHandler('esx:playerLoaded', function()
	IsDead = false

	if FirstSpawn then
		exports.spawnmanager:setAutoSpawn(false) -- disable respawn
		FirstSpawn = false

		ESX.TriggerServerCallback('esx_ambulancejob:getDeathStatus', function(isDead)
			if isDead and Config.AntiCombatLog then
				DoScreenFadeOut(500)
				while not PlayerLoaded do
					Wait(1000)
				end

				Wait(5000)
				SetEntityHealth(PlayerPedId(), 0)
				DoScreenFadeIn(500)
			else
				TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
			end
		end)
	end
end)

-- Create blips
CreateThread(function()
	for k,v in pairs(Config.Hospitals) do
		local blip = AddBlipForCoord(v.Blip.coords)

		SetBlipSprite(blip, v.Blip.sprite)
		SetBlipScale(blip, 0.8)
		SetBlipColour(blip, 4)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(_U('hospital'))
		EndTextCommandSetBlipName(blip)
	end
end)

-- Disable most inputs when dead
CreateThread(function()
	while true do
		Wait(0)

		if IsDead then
		--	DisableAllControlActions(0)
			EnableControlAction(0, Keys['G'], true)
			EnableControlAction(0, Keys['N'], true)
			EnableControlAction(0, Keys['T'], true)
			EnableControlAction(0, Keys['E'], true)
		else
			Wait(500)
		end
	end
end)

local deadAnimDict = "dead"
local deadAnim = "dead_a"
local deadCarAnimDict = "veh@low@front_ps@idle_duck"
local deadCarAnim = "sit"

function loadAnimDict(dict)
	while(not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Wait(1)
	end
end

function OnPlayerDeath()
	TriggerEvent('mythic_hospital:client:RemoveBleed')
	IsDead = true
	local first = true
	local ped = PlayerPedId()
	local pos = GetEntityCoords(ped)
	local heading = GetEntityHeading(ped)
	--NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z + 0.5, heading, true, false)
    ESX.UI.Menu.CloseAll()
    TriggerServerEvent('esx_ambulancejob:setDeathStatus', true)
    StartDeathTimer()
    StartDistressSignal()

	--[[Wait(1000)
	while IsPedRagdoll(ped) do
		IsDead = true
		Wait(100)
	end

	while IsDead do
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			IsDead = true
			loadAnimDict("veh@low@front_ps@idle_duck")
			TaskPlayAnim(player, "veh@low@front_ps@idle_duck", "sit", 1.0, 1.0, -1, 1, 0, 0, 0, 0)
			SetEntityHealth(ped, 101)
			SetEntityInvincible(ped,true)
		else
			IsDead = true
			ClearPedTasks(ped)
			SetEntityHealth(ped, 101)
			SetEntityInvincible(ped,true)
			loadAnimDict(deadAnimDict)
			TaskPlayAnim(ped, deadAnimDict, deadAnim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
		end
		if(first)then
			Wait(2000)
			first = false
		end
		TriggerEvent("hospital:death:checker")
   		Wait(20000)
	end--]]
	while IsDead do
		Wait(20000)
		ClearPedTasks(PlayerPedId())
	end

	--NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z + 0.5, heading, true, false)
end


--[[RegisterNetEvent('hospital:death:checker')
AddEventHandler('hospital:death:checker', function()
	local firstDeath = true
	while firstDeath do
		Wait(100)
		if(GetEntityHealth(PlayerPedId()) <= 102)then
			IsDead = true
		else
			SetEntityInvincible(PlayerPedId(),false)
			IsDead = false
			firstDeath = false
			TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
		end
	end
end)--]]

RegisterNetEvent('esx_ambulancejob:useItem')
AddEventHandler('esx_ambulancejob:useItem', function(itemName)
	ESX.UI.Menu.CloseAll()

	if itemName == 'medikit' then
		local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
		local playerPed = PlayerPedId()


		TriggerEvent('mythic_hospital:client:RemoveBleed')

		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

			Wait(500)
			while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
				Wait(0)
				DisableAllControlActions(0)
			end
	
			TriggerEvent('esx_ambulancejob:heal', 'big', true)
			TriggerEvent('mythic_hospital:client:RemoveBleed')
			TriggerEvent('mythic_hospital:client:ResetLimbs')
			ESX.ShowNotification(_U('used_medikit'))
		end)

	elseif itemName == 'bandage' then
		local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
		local playerPed = PlayerPedId()

		exports['mythic_progbar']:Progress({
			name = "firstaid_action",
			duration = 10000,
			label = "Using Bandage",
			useWhileDead = false,
			canCancel = true,
			controlDisables = {
				disableMovement = false,
				disableCarMovement = false,
				disableMouse = false,
				disableCombat = true,
			},
			animation = {
				animDict = "missheistdockssetup1clipboard@idle_a",
				anim = "idle_a",
				flags = 49,
			},
			prop = {
				model = "prop_cs_pills",
			}
		}, function(status)
			if not status then
				local maxHealth = GetEntityMaxHealth(PlayerPedId())
				local health = GetEntityHealth(PlayerPedId())
				local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 16))
				SetEntityHealth(PlayerPedId(), newHealth)
				TriggerEvent('mythic_hospital:client:RemoveBleed')
			end
		end)

		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

			Wait(500)
			while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
				Wait(0)
				DisableAllControlActions(0)
			end

			TriggerEvent('esx_ambulancejob:heal', 'small', true)
			ESX.ShowNotification(_U('used_bandage'))
			TriggerEvent('mythic_hospital:client:RemoveBleed')

		


		end)
	end
end)

function StartDistressSignal()
	CreateThread(function()
		local timer = Config.BleedoutTimer

		while (timer > 0 and IsDead and (not inBed) and (not inMythicBed)) do
			Wait(2)
			timer = timer - 30
			
			SetTextFont(4)
			SetTextScale(0.45, 0.45)
			SetTextColour(185, 185, 185, 255)
			SetTextDropshadow(0, 0, 0, 0, 255)
			SetTextEdge(1, 0, 0, 0, 255)
			SetTextDropShadow()
			SetTextOutline()
			DrawText(0.5, 0.89)
			BeginTextCommandDisplayText('STRING')
			AddTextComponentSubstringPlayerName(_U('distress_send'))
			EndTextCommandDisplayText(0.438, 0.92)

			if IsControlPressed(0, Keys['G']) then
				SendDistressSignal()

				CreateThread(function()
					Wait(1000 * 60 * 5)
					if (IsDead) then
						StartDistressSignal()
					end
				end)

				break
			end
		end
	end)
end

function SendDistressSignal()
	local coords = GetEntityCoords(PlayerPedId())

    local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)

	local streetLabel = street1
    if street2 ~= nil and street2 ~= "" then 
        streetLabel = streetLabel .. " " .. street2
    end

	ESX.ShowNotification(_U('distress_sent'))

    TriggerServerEvent('lx_ambulance:dispatch', exports['cd_dispatch']:GetPlayerInfo())

    --[[
		local playerPed = PlayerPedId()
		PedPosition		= GetEntityCoords(playerPed)
	
		local PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z }
	
		TriggerServerEvent('esx_addons_gcphone:startCall', 'ambulance', _U('distress_message'), PlayerCoords, {

		PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z },
	})-]]
end

function DrawGenericTextThisFrame()
	SetTextFont(4)
	SetTextScale(0.0, 0.5)
	SetTextColour(185, 185, 185, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)
end

function secondsToClock(seconds)
	local seconds, hours, mins, secs = tonumber(seconds), 0, 0, 0

	if seconds <= 0 then
		return 0, 0
	else
		local hours = string.format("%02.f", math.floor(seconds / 3600))
		local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
		local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))

		return mins, secs
	end
end

function StartDeathTimer()
	local canPayFine = false

	if Config.EarlyRespawnFine then
		ESX.TriggerServerCallback('esx_ambulancejob:checkBalance', function(canPay)
			canPayFine = canPay
		end)
	end

	local earlySpawnTimer = ESX.Math.Round(Config.EarlyRespawnTimer / 1000)
	--local earlySpawnTimer = ESX.Math.Round(5000 / 1000)

	CreateThread(function()
		-- early respawn timer
		while earlySpawnTimer > 0 and IsDead and (not inBed) and (not inMythicBed) do
			Wait(1000)

			if earlySpawnTimer > 0 then
				earlySpawnTimer = earlySpawnTimer - 1
			end
		end
	end)

	CreateThread(function()
		local text, timeHeld

		-- early respawn timer
		while (earlySpawnTimer > 0 and IsDead and (not inBed) and (not inMythicBed)) do
			Wait(0)
			text = _U('respawn_available_in', secondsToClock(earlySpawnTimer))

			DrawGenericTextThisFrame()

			SetTextEntry("STRING")
			AddTextComponentString(text)
			DrawText(0.5, 0.942)
		end

		-- bleedout timer
		while IsDead and (not inBed) and (not inMythicBed) do
			Wait(0)
			text = ''

			if not Config.EarlyRespawnFine then
				text = text .. _U('respawn_bleedout_prompt')

				if IsControlPressed(0, Keys['E']) then
					RemoveItemsAfterRPDeath()
					break
				end
			elseif Config.EarlyRespawnFine and canPayFine then
				text = text .. _U('respawn_bleedout_fine', ESX.Math.GroupDigits(Config.EarlyRespawnFineAmount))

				if IsControlPressed(0, Keys['E']) and timeHeld > 60 then
					TriggerServerEvent('esx_ambulancejob:payFine')
					RemoveItemsAfterRPDeath()
					break
				end
			end

			if IsControlPressed(0, Keys['E']) then
				timeHeld = timeHeld + 1
			else
				timeHeld = 0
			end

			DrawGenericTextThisFrame()

			SetTextEntry("STRING")
			AddTextComponentString(text)
			DrawText(0.5, 0.942)
		end
			
		if IsDead and (not inBed) and (not inMythicBed) then
			RemoveItemsAfterRPDeath()
		end
	end)
end

function DrawText3Ds(x,y,z, text)
  local onScreen,_x,_y=World3dToScreen2d(x,y,z)
  local px,py,pz=table.unpack(GetGameplayCamCoords())

  SetTextScale(0.35, 0.35)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 215)
  SetTextEntry("STRING")
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(_x,_y)
  local factor = (string.len(text)) / 370
  DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end


CreateThread(function()
	Wait(3000)

    TriggerEvent('esx:getShlxgaredObjlxgect', function(obj) ESX = obj end)
    PlayerData = ESX.GetPlayerData()
end)

CreateThread(function()
	local waitTime

    while true do
		waitTime = 100
		
		if (#(vector3(1146.6387939453, -1542.7037353516, 35.3829154968) - GetEntityCoords(PlayerPedId())) < 10.0) then
			waitTime = 0


		end

		Wait(waitTime)
	end
end)

function RemoveItemsAfterRPDeath()
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
	TriggerEvent('mythic_hospital:client:RemoveBleed')
	TriggerEvent('mythic_hospital:client:ResetLimbs')

	CreateThread(function()
		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Wait(10)
		end

		ESX.TriggerServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function()
			local formattedCoords = {
				x = Config.RespawnPoint.coords.x,
				y = Config.RespawnPoint.coords.y,
				z = Config.RespawnPoint.coords.z
			}

			ESX.SetPlayerData('lastPosition', formattedCoords)
			ESX.SetPlayerData('loadout', {})

			TriggerServerEvent('esx:updateLastPosition', formattedCoords)
			RespawnPed(PlayerPedId(), formattedCoords, Config.RespawnPoint.heading)

			--StopScreenEffect('DeathFailOut')
			DoScreenFadeIn(800)
		end)
	end)
end

function RespawnPed(ped, coords, heading)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	IsDead = false
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
	ClearPedBloodDamage(ped)
	TriggerEvent('mythic_hospital:client:RemoveBleed')
	TriggerEvent('mythic_hospital:client:ResetLimbs')

	ESX.UI.Menu.CloseAll()
end

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	local specialContact = {
		name       = 'Ambulance',
		number     = 'ambulance',
		base64Icon = 'data:image/png;base64,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'
	}

	TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	OnPlayerDeath()
end)

RegisterNetEvent('mythic_hospital:playerInHospitalBed')
AddEventHandler('mythic_hospital:playerInHospitalBed', function(isInBed)
	inMythicBed = isInBed
end)

RegisterNetEvent('esx_ambulancejob:relxgvive')
AddEventHandler('esx_ambulancejob:relxgvive', function()
	IsDead = false
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	TriggerEvent('mythic_hospital:client:RemoveBleed')
	TriggerEvent('mythic_hospital:client:ResetLimbs')
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
	ClearPedTasks(PlayerPedId())

	CreateThread(function()
		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Wait(50)
		end

		local formattedCoords = {
			x = ESX.Math.Round(coords.x, 1),
			y = ESX.Math.Round(coords.y, 1),
			z = ESX.Math.Round(coords.z, 1)
		}

		ESX.SetPlayerData('lastPosition', formattedCoords)

		TriggerServerEvent('esx:updateLastPosition', formattedCoords)

		RespawnPed(playerPed, formattedCoords, 0.0)

		Wait(100)

		RespawnPed(playerPed, formattedCoords, 0.0)

		Wait(100)

		RespawnPed(playerPed, formattedCoords, 0.0)

		Wait(800)

		SetEntityHealth(PlayerPedId(), 200)

		--StopScreenEffect('DeathFailOut')
		DoScreenFadeIn(800)
	end)
end)

-- Load unloaded IPLs
if Config.LoadIpl then
	CreateThread(function()
		RequestIpl('Coroner_Int_on') -- Morgue
	end)
end
