Config = {
    Prefix = '^9[^5Badger-Blips^9] ^3',

    EnableInheritances = false,

    RoleList = { 
        [887518674607562803] = {
            {'👮 Sheriff | ', 17, nil},
            {'👮 LSPD | ', 2 , nil},
            {'👮 SAHP | ', 3, nil},
        },
    },

    Inheritances = { --MUST HAVE EnableInheritances SET TO TRUE TO WORK!
        ["ROLE-1-NAME-OR-ID-HERE"] = {"ROLE-TO-INHERITE-ID-OR-NAME-HERE", "ANOTHER-ROLE-TO-INHERITE-ID-OR-NAME-HERE",},
    },
    CLIENT_UPDATE_INTERVAL_SECONDS = 3, -- How frequently should the blips on the map update??
}