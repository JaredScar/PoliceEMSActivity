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
