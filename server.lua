-- VARS --
roleList = Config.RoleList;
inheritances = Config.Inheritances
pmapresent = false

-- CODE --
Citizen.CreateThread(function()
	print(GetResourceState("pma-voice"))
	if (GetResourceState("pma-voice") ~= "missing" and GetResourceState("pma-voice") ~= "unknown") then
		pmapresent = true
	end
	--checks to see if players are online on resource start. if so it registers them.
	if GetNumPlayerIndices() ~= 0 then
		for _, ID in pairs(GetPlayers()) do
			--Register User then wait to avoid rate limiting.
			RegisterUser(ID)
		
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do 
		-- We wait a second and add it to their timeTracker 
		Wait(1000); -- Wait a second
		for k, v in pairs(timeTracker) do 
			timeTracker[k] = timeTracker[k] + 1;
		end 
	end 
end)

timeTracker = {}
hasPerms = {}
permTracker = {}
activeBlip = {}
onDuty = {}
prefix = Config.Prefix;

AddEventHandler("playerDropped", function()
	if onDuty[source] ~= nil then 
		local tag = activeBlip[source][1];
		local webHook = activeBlip[source][3];
		if webHook ~= nil then 
			local time = timeTracker[source];
			local now = os.time();
			local startPlusNow = now + time;
			local minutesActive = os.difftime(now, startPlusNow) / 60;
			minutesActive = math.floor(math.abs(minutesActive))
			sendToDisc('Player ' .. GetPlayerName(source) .. ' is now off duty', 'Player ' .. GetPlayerName(source) .. ' has gone off duty as ' .. tag, 
			'Duration: ' .. minutesActive .. ' minutes',
				webHook, 16711680)
		end 
	end
	timeTracker[source] = nil;
	onDuty[source] = nil;
	permTracker[source] = nil;
	hasPerms[source] = nil;
	activeBlip[source] = nil;
	-- Remove them from Blips:
	TriggerEvent('eblips:remove', source)
end)
function sendToDisc(title, message, footer, webhookURL, color)
	local embed = {}
	embed = {
		{
			["color"] = color, -- GREEN = 65280 --- RED = 16711680
			["title"] = "**".. title .."**",
			["description"] = "** " .. message ..  " **",
			["footer"] = {
				["text"] = footer,
			},
		}
	}
	-- Start
	-- TODO Input Webhook
	PerformHttpRequest(webhookURL, 
	function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  -- END
end
RegisterCommand('duty', function(source, args, rawCommand)
	-- The /blip command to toggle on and off the cop blip  
	if hasPerms[source] ~= nil then 
		if onDuty[source] == nil then 
			local colorr = activeBlip[source][2];
			local tag = activeBlip[source][1];
			local webHook = activeBlip[source][3];
			if webHook ~= nil then
				sendToDisc('Player ' .. GetPlayerName(source) .. ' is now on duty', 'Player ' .. GetPlayerName(source) .. ' has gone on duty as ' .. tag, '',
					webHook, 65280)
			end
			TriggerEvent('eblips:add', {name = tag .. GetPlayerName(source), src = source, color = colorr}); 
			sendMsg(source, 'You have toggled your emergency blip ^2ON ^3and your Blip-Tag is: ' .. tag)
			onDuty[source] = true;
			timeTracker[source] = 0;
			TriggerClientEvent('PoliceEMSActivity:GiveWeapons', source);
		else 
			onDuty[source] = nil;
			local tag = activeBlip[source][1];
			local webHook = activeBlip[source][3];
			if webHook ~= nil then
				local time = timeTracker[source];
				local now = os.time();
				local startPlusNow = now + time;
				local minutesActive = os.difftime(now, startPlusNow) / 60;
				minutesActive = math.floor(math.abs(minutesActive))
				sendToDisc('Player ' .. GetPlayerName(source) .. ' is now off duty', 'Player ' .. GetPlayerName(source) .. ' has gone off duty as ' .. tag, 
				'Duration: ' .. minutesActive .. ' minutes',
				webHook, 16711680)
			end
			TriggerClientEvent('PoliceEMSActivity:TakeWeapons', source);
			timeTracker[source] = nil;
			sendMsg(source, 'You have toggled your emergency blip ^1OFF')
			TriggerEvent('eblips:remove', source)
		end
	else 
		-- You are not a cop, you must be a cop in our discord to use it 
		sendMsg(source, '^1ERROR: You must be an LEO on our discord to use this...')
	end
end)
RegisterCommand('cops', function(source, args, rawCommand) 
	-- Prints the active cops online with a /blip that is on 

	sendMsg(source, Config.CopsCommandMessage)

	for id, _ in pairs(onDuty) do
		local message = Config.CopsCommandPlayerMessage
		message = message:gsub('{PLAYER_NAME}', GetPlayerName(tonumber(id)))
		message = message:gsub('{PLAYER_ID}', tonumber(id))
		local tag = activeBlip[tonumber(id)][1]
		if ColorTable[activeBlip[tonumber(id)][2]] ~= nil then
			tag = ColorTable[activeBlip[tonumber(id)][2]] .. tag .. "^0"
		end
		message = message:gsub('{ACTIVE_TAG}', tag)

		if message:find("{TIME_ONDUTY}") then
			local time = timeTracker[tonumber(id)];
			local now = os.time();
			local startPlusNow = now + time;
			local minutesActive = os.difftime(now, startPlusNow) / 60;
			minutesActive = math.floor(math.abs(minutesActive))

			message = message:gsub("{TIME_ONDUTY}", minutesActive .. " minute(s)")
		end

		if pmapresent then
			local freq = exports['pma-voice']:radioChannel(tonumber(id))

			if freq == 0 or freq == "0" then
				freq = "UNK"
			else
				freq = freq .. " MHZ"
			end

			message = message:gsub('{RADIO_FREQ}', freq)
		end

		TriggerClientEvent('chatMessage', source, message);
	end
end)
function sendMsg(src, msg) 
	TriggerClientEvent('chatMessage', src, prefix .. msg);
end
RegisterCommand('bliptag', function(source, args, rawCommand)
	-- The /blipTag command to toggle on and off the cop blip 
	if hasPerms[source] ~= nil then 
		if #args == 0 then 
			-- List out which ones they have access to 
			sendMsg(source, 'You have access to the following Blip-Tags:');
			for i = 1, #permTracker[source] do 
				-- List 
				TriggerClientEvent('chatMessage', source, '^9[^4' .. i .. '^9] ^0' .. permTracker[source][i][1]);
			end
		else 
			-- Choose their bliptag 
			local selection = args[1];
			if tonumber(selection) ~= nil then 
				local sel = tonumber(selection);
				local theirBlips = permTracker[source];
				if sel <= #theirBlips then
					-- Set up their tag
					local tag = activeBlip[source][1];
					local newBlip = permTracker[source][sel]
					local webHook = activeBlip[source][3];

					if onDuty[source] ~= nil then 
						local time = timeTracker[source];
						local now = os.time();
						local startPlusNow = now + time;
						local minutesActive = os.difftime(now, startPlusNow) / (60);
						

						minutesActive = math.floor(math.abs(minutesActive))

						sendToDisc('Player ' .. GetPlayerName(source) .. ' is now off duty', 'Player ' .. GetPlayerName(source) 
							.. ' has gone off duty as ' .. tag, 'Duration: ' .. minutesActive .. " minute(s)",
							webHook, 16711680)

						timeTracker[source] = 0;

						if newBlip[3] ~= nil then
							sendToDisc('Player ' .. GetPlayerName(source) .. ' is now on duty', 'Player ' .. GetPlayerName(source) .. ' has gone on duty as ' .. newBlip[1], '',
								webHook, 65280)
						end
					end

					activeBlip[source] = permTracker[source][sel];

					sendMsg(source, 'You have set your Blip-Tag to ^1' .. permTracker[source][sel][1]);

					if onDuty[source] ~= nil then 
						tag = newBlip[1];
						webHook = activeBlip[source][3];

						if webHook ~= nil then
							sendToDisc('Player ' .. GetPlayerName(source) .. ' is now on duty', 'Player ' .. GetPlayerName(source) .. ' has gone on duty as ' .. tag, '',
								webHook, 65280)
						end 

						local colorr = activeBlip[source][2]

						TriggerEvent('eblips:remove', source)
						TriggerEvent('eblips:add', {name = tag .. GetPlayerName(source), src = source, color = colorr});
					end
				else 
					-- That is not a valid selection 
					sendMsg(source, '^1ERROR: That is not a valid selection...')
				end
			else 
				-- Not a number 
				sendMsg(source, '^1ERROR: That is not a number...')
			end
		end
	else 
		-- You are not a cop, you must be a cop in our discord to use this 
		sendMsg(source, '^1ERROR: You must be an LEO on our discord to use this...')
	end 
end)


RegisterNetEvent('PoliceEMSActivity:RegisterUser')
AddEventHandler('PoliceEMSActivity:RegisterUser', function()
	RegisterUser(source)
end)

-- EXPORT FUNCTIONS
function IsPlayerOnDuty(player)
	if onDuty[tonumber(player)] ~= nil then
		return true
	else
		return false
	end
end

function GetPlayerBlipTag(player)
	return activeBlip[player][1]
end
-- END EXPORT FUNCTIONS

function RegisterUser(user)
	local src = tonumber(user)
	local identifierDiscord = nil

	for k, v in ipairs(GetPlayerIdentifiers(src)) do
		if string.sub(v, 1, string.len("discord:")) == "discord:" then
			identifierDiscord = v
		end
	end

	local perms = {}

	if identifierDiscord then
		local roleIDs = exports.Badger_Discord_API:GetDiscordRoles(src)
		if not (roleIDs == false) then
			
			for j = 1, #roleIDs do
				for k, v in pairs(roleList) do
					if exports.Badger_Discord_API:CheckEqual(k, roleIDs[j]) then

						for _, t in pairs(v) do
							table.insert(perms, t);
							activeBlip[src] = t;
							hasPerms[src] = true;
							print("[PEA] Gave " .. GetPlayerName(src) .. " Perms Sucessfully")
						end
					end
				end
				
				if Config.EnableInheritances then
					for role, t in pairs(inheritances) do
						if exports.Badger_Discord_API:CheckEqual(role, roleIDs[j]) then
							for i = 1, #t do
								if roleList[t[i]] == nil then
									print("[PEA] Error! Inheritances are not set up correctly for '" .. role .. "'!")
								end

								for _, blip in pairs(roleList[t[i]]) do

									if activeBlip[src] == nil then
										activeBlip[src] = blip
									end
									
									table.insert(perms, blip);
									hasPerms[src] = true;
								end
							end

							print("[PEA] Gave " .. GetPlayerName(src) .. " Perms Sucessfully via Inheritance.")
						end
					end
				end
			end

			permTracker[src] = perms;
		else
			print("[PoliceEMSActivity] " .. GetPlayerName(src) .. " has not gotten their permissions cause roleIDs == false")
		end
	else
		print("[PoliceEMSActivity] " .. GetPlayerName(src) .. " has not gotten their permissions cause discord was not detected...")
	end

	permTracker[src] = perms; 
end

--A table of chat colors for the blip colors.
ColorTable = {
	[1] = '^1',
	[49] = '^1',
	[59] = '^1',
	[75] = '^1',
	[2] = '^2',
	[11] = '^2',
	[24] = '^2',
	[25] = '^2',
	[43] = '^2',
	[69] = '^2',
	[82] = '^2',
	[5] = '^3',
	[28] = '^3',
	[36] = '^3',
	[46] = '^3',
	[60] = '^3',
	[66] = '^3',
	[70] = '^3',
	[71] = '^3',
	[73] = '^3',
	[3] = '^5',
	[12] = '^5',
	[18] = '^5',
	[26] = '^5',
	[32] = '^5',
	[42] = '^5',
	[53] = '^5',
	[57] = '^5',
	[67] = '^5',
	[68] = '^5',
	[74] = '^5',
	[77] = '^5',
	[80] = '^5',
	[84] = '^5',
	[7] = '^6',
	[29] = '^4',
	[38] = '^4',
	[78] = '^4',
	[63] = '^4',
	[6] = '^8',
	[76] = '^8',
	[61] = '^9',
}