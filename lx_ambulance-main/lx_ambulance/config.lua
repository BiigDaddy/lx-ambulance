Config                            = {}

Config.DrawDistance               = 5.0

Config.Marker                     = { type = 1, x = 1.5, y = 1.5, z = 1.0, r = 102, g = 0, b = 102, rotate = false }

Config.ReviveReward               = 220  -- revive reward, set to 0 if you don't want it enabled
Config.AntiCombatLog              = true -- enable anti-combat logging?
Config.LoadIpl                    = true -- disable if you're using fivem-ipl or other IPL loaders

Config.Locale                     = 'en'

local second = 1000
local minute = 60 * second

Config.EarlyRespawnTimer          = 5 * minute  -- Time til respawn is available
Config.BleedoutTimer              = 5 * minute -- Time til the player bleeds out

Config.EnablePlayerManagement     = true
Config.EnableSocietyOwnedVehicles = false

Config.RemoveWeaponsAfterRPDeath  = true
Config.RemoveCashAfterRPDeath     = true
Config.RemoveItemsAfterRPDeath    = true

-- Let the player pay for respawning early, only if he can afford it.
Config.EarlyRespawnFine           = true
Config.EarlyRespawnFineAmount     = 500

Config.ICU_Time = 300 --IN SECONDS

Config.ICU_Beds = { --IF the player is upside down change the h by 180 degrees, Maximum value is 360.
    {x = 1116.26, y = -1531.09, z = 34.43, h = 0.12, taken = false },
	{x = 1116.87, y = -1533.23, z = 34.43, h = 90.12, taken = false },
	{x = 1116.72, y = -1538.61, z = 34.43, h = 90.12, taken = false },
	{x = 1148.83, y = -1585.37, z = 34.92, h = 180.12, taken = false },
	{x = 1144.45, y = -1585.38, z = 34.92, h = 180.12, taken = false },
	{x = 1140.23, y = -1585.38, z = 34.92, h = 180.12, taken = false },
	{x = 1136.12, y = -1585.39, z = 34.92, h = 180.12, taken = false },
}

Config.RespawnPoint = { coords = vector3(1155.0434570313, -1527.4498291016, 34.843776702), heading = 312.13}

Config.Hospitals = {

	CentralLosSantos = {

		Blip = {
			coords = vector3(1145.4819335938, -1544.5002441406, 35.3808784484),
			sprite = 61,
			scale  = 1.2,
			color  = 2
		},

		AmbulanceActions = {
			vector3(1142.9710693359, -1550.9483642578, 35.3808708190)
		},

		Pharmacies = {
			vector3(1131.7618408203, -1573.4079589844, 35.3808708190)
		},

		Vehicles = {
			{
				Spawner = vector3(329.53, -573.73, -128.9),
				InsideShop = vector3(446.7, -1355.6, -143.5),
				Marker = { type = 36, x = 1.0, y = 1.0, z = 1.0, r = 100, g = 50, b = 200, a = 100, rotate = true },
				SpawnPoints = {
					{ coords = vector3(326.2, -565.86, -128.56), heading = 340.56, radius = 6.0 }
				}
			}
		},

		Helicopters = {
			{
				Spawner = vector3(347.14, -578.89, -174.17),
				InsideShop = vector3(305.6, -1419.7, -141.5),
				Marker = { type = 34, x = 1.5, y = 1.5, z = 1.5, r = 100, g = 150, b = 150, a = 100, rotate = true },
				SpawnPoints = {
					{ coords = vector3(351.42, -588.49, -174.17), heading = 142.7, radius = 10.0 }
				}
			}
		},

		FastTravels = {
		},

		FastTravelsPrompt = {
		}

	}
}

Config.AuthorizedVehicles = {

	ambulance = {
		{
			model = 'firerig',
			label = 'Ambulance Mercedes',
			price = 500
		},
		{
			model = 'policeb',
			label = 'Greek Ambulance Bike',
			price = 500
		},
		{
		    model = 'LGUARD',
		    label = 'Ford Expedition',
		    price = 500
     	}
	},

	doctor = {
		{
			model = 'firerig',
			label = 'Ambulance Volkswagen',
			price = 500
		},
		{
			model = 'sheriffx6',
			label = 'BMW X6',
			price = 500
		},		
		{
			model = 'policeb',
			label = 'Greek Ambulance Bike',
			price = 500
		},
		{
		    model = 'LGUARD',
		    label = 'Volkswagen Amarok',
		    price = 500
     	}
	},

	chief_doctor = {
		{
			model = 'firerig',
			label = 'Ambulance Volkswagen',
			price = 500
		},
		{
			model = 'sheriffx6',
			label = 'BMW X6',
			price = 500
		},		
		{
			model = 'policeb',
			label = 'Greek Ambulance Bike',
			price = 500
		},
		{
		    model = 'LGUARD',
		    label = 'Volkswagen Amarok',
		    price = 500
     	}
	},

	boss = {
		{
			model = 'firerig',
			label = 'Ambulance Volkswagen',
			price = 500
		},
		{
			model = 'sheriffx6',
			label = 'BMW X6',
			price = 500
		},		
		{
			model = 'policeb',
			label = 'Greek Ambulance Bike',
			price = 500
		},
		{
		    model = 'LGUARD',
		    label = 'Volkswagen Amarok',
		    price = 500
     	}
	}

}

Config.AuthorizedHelicopters = {

	ambulance = {},

	doctor = {
		{
			model = 'supervolito',
			label = 'Super Volito',
			price = 10000
		}
	},

	chief_doctor = {
		{
			model = 'supervolito',
			label = 'Super Volito',
			price = 10000
		}
	},

	boss = {
		{
			model = 'supervolito',
			label = 'Super Volito',
			price = 10000
		}
	}

}
