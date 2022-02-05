fx_version 'cerulean'
game 'gta5'

author 'JaredScar'
description 'PoliceEMSActivity'
version '2.0'
url 'https://github.com/JaredScar/PoliceEMSActivity'

client_scripts {
	'client.lua',
    'EmergencyBlips/cl_emergencyblips.lua',
}

server_scripts {
	'config.lua',
	"server.lua",
    'EmergencyBlips/sv_emergencyblips.lua',
}
