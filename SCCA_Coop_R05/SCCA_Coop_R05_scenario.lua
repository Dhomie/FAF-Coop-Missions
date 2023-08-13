version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Cybran Mission 5 - Unlock - Remastered - Alpha",
    description = "Commander, you will free Hex5's comrades and get the Black Sun's access codes. We are running out of time, my boy. Out of time. The UEF will fall to the Aeon within 14 days. If that happens, there is a high probabillity the UEF will unleash Option Zero and destroy all life on Earth. We face our darkest hour. You must succeed. Your brothers and sisters are counting on you. Be safe.",
    preview = '',
    map_version = 3,
    type = 'campaign_coop',
    starts = true,
    size = {1024, 1024},
    reclaim = {714538.4, 63121.55},
    map = '/maps/SCCA_Coop_R05/SCCA_Coop_R05.scmap',
    save = '/maps/SCCA_Coop_R05/SCCA_Coop_R05_save.lua',
    script = '/maps/SCCA_Coop_R05/SCCA_Coop_R05_script.lua',
    norushradius = 0,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'Player1', 'UEF', 'Hex5', 'FauxUEF', 'Player2', 'Player3', 'Player4'}
                },
            },
            customprops = {
            },
            factions = {
                {'cybran'},
                {'cybran'},
                {'cybran'},
                {'cybran'}
            },
        },
    },
}
