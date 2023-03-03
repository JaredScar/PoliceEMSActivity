Config = {
    Prefix = '^9[^5Badger-Blips^9] ^3',

    EnableInheritances = false,
    --This will be the inital message.
    CopsCommandMessage = "The active cops on are:",
    
    --[[    
    This is the format of each player onduty in the list. Available Placeholders;
    {ACTIVE_TAG} The player's active bliptag.
    {PLAYER_NAME} - The player's name.
    {PLAYER_ID} - The player's server ID.
    {RADIO_FREQ} - The player's current radio frequency. (Must be using pma-voice)
    {TIME_ONDUTY} - The time, in minutes, the player has been onduty.
    ]]
    CopsCommandPlayerMessage = "{ACTIVE_TAG} {PLAYER_NAME} (FREQ: {RADIO_FREQ}) - {TIME_ONDUTY}",

    RoleList = { 
        ["Owner"] = {
            {'👮 Sheriff | ', 17, 'https://discord.com/api/webhooks/1042272902000676874/tYHDKm68CujIerBsCKJmMXOdt_AsplNvluxulBcjOQdZkkdxddbd5mbN7ksSdCcnWoQL'},
            {'👮 LSPD | ', 2 , nil},
            {'👮 SAHP | ', 3, nil},
        },
    },

    Inheritances = { --MUST HAVE EnableInheritances SET TO TRUE TO WORK!
        ["ROLE-1-NAME-OR-ID-HERE"] = {"ROLE-TO-INHERITE-ID-OR-NAME-HERE", "ANOTHER-ROLE-TO-INHERITE-ID-OR-NAME-HERE",},
    },
    CLIENT_UPDATE_INTERVAL_SECONDS = 3, -- How frequently should the blips on the map update??
}