-- by: minipunch
-- for: Initially made for USA Realism RP (https://usarrp.net)
-- purpose: Provide public servant with blips for all other active emergency personnel

local ACTIVE = false
local ACTIVE_EMERGENCY_PERSONNEL = {}

------------
-- events --
------------
AddEventHandler('playerSpawned', function() 
	-- The player has spawned, we gotta set their perms up
	TriggerServerEvent('PoliceEMSActivity:RegisterUser'); 
end)
function giveWeapon(hash)
    GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(hash), 999, false, false)
end
RegisterNetEvent('PoliceEMSActivity:GiveWeapons')
AddEventHandler('PoliceEMSActivity:GiveWeapons', function()
	giveWeapon("weapon_nightstick")
    giveWeapon("weapon_stungun")
    giveWeapon("weapon_flashlight")
    giveWeapon("weapon_combatpistol")
    GiveWeaponComponentToPed(GetPlayerPed(-1), 1593441988, 0x359B7AAE)
    giveWeapon("weapon_carbinerifle")
    GiveWeaponComponentToPed(GetPlayerPed(-1), -2084633992, 0x7BC4CDDC)
    GiveWeaponComponentToPed(GetPlayerPed(-1), -2084633992, 0xC164F53)
    GiveWeaponComponentToPed(GetPlayerPed(-1), -2084633992, 0xA0D89C42)
    giveWeapon("weapon_pumpshotgun")
    GiveWeaponComponentToPed(GetPlayerPed(-1), 487013001, 0x7BC4CDDC)
    SetPedArmour(GetPlayerPed(-1), 100)
end)
RegisterNetEvent('PoliceEMSActivity:TakeWeapons')
AddEventHandler('PoliceEMSActivity:TakeWeapons', function()
	-- Remove weapons and armor
	SetPedArmour(GetPlayerPed(-1), 0)
	RemoveAllPedWeapons(GetPlayerPed(-1), true);
end)
RegisterNetEvent("eblips:toggle")
AddEventHandler("eblips:toggle", function(on)
	-- toggle blip display --
	ACTIVE = on
	-- remove all blips if turned off --
	if not ACTIVE then
		RemoveAnyExistingEmergencyBlips()
	end
end)

RegisterNetEvent("eblips:updateAll")
AddEventHandler("eblips:updateAll", function(personnel)
	ACTIVE_EMERGENCY_PERSONNEL = personnel
end)

RegisterNetEvent("eblips:update")
AddEventHandler("eblips:update", function(person)
	ACTIVE_EMERGENCY_PERSONNEL[person.src] = person
end)

RegisterNetEvent("eblips:remove")
AddEventHandler("eblips:remove", function(src)
	RemoveAnyExistingEmergencyBlipsById(src)
end)


---------------
-- functions --
---------------
function RemoveAnyExistingEmergencyBlips()
	for src, info in pairs(ACTIVE_EMERGENCY_PERSONNEL) do
		local possible_blip = GetBlipFromEntity(GetPlayerPed(GetPlayerFromServerId(src)))
		if possible_blip ~= 0 then
			RemoveBlip(possible_blip)
			ACTIVE_EMERGENCY_PERSONNEL[src] = nil
		end
	end
end

function RemoveAnyExistingEmergencyBlipsById(id)
		local possible_blip = GetBlipFromEntity(GetPlayerPed(GetPlayerFromServerId(id)))
		if possible_blip ~= 0 then
			RemoveBlip(possible_blip)
			ACTIVE_EMERGENCY_PERSONNEL[id] = nil
		end
end

-----------------------------------------------------
-- Watch for emergency personnel to show blips for --
-----------------------------------------------------
Citizen.CreateThread(function()
	while true do
		if ACTIVE then
			for src, info in pairs(ACTIVE_EMERGENCY_PERSONNEL) do
				local player = GetPlayerFromServerId(src)
				local ped = GetPlayerPed(player)
				if GetPlayerPed(-1) ~= ped then
					if GetBlipFromEntity(ped) == 0 then
						local blip = AddBlipForEntity(ped)
						SetBlipSprite(blip, 1)
						SetBlipColour(blip, info.color)
						SetBlipAsShortRange(blip, true)
						SetBlipDisplay(blip, 4)
						SetBlipShowCone(blip, true)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString(info.name)
						EndTextCommandSetBlipName(blip)
					end
				end
			end
		end
		Wait(1)
	end
end)
