version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Cybran Mission 6 - Freedom, Dhomie42, version 6",
    description = "Having the Black Sun access codes secured, Cybran forces attempt a daring operation on Earth itself to take control of Black Sun, before the UEF could fire it, and before the Aeon could destroy it. There's no turning back now, it's do or die.",
    preview = '',
    map_version = 3,
    type = 'campaign_coop',
    starts = true,
    size = {1024, 1024},
    reclaim = {2617054, 82315.22},
    map = '/maps/scca_coop_r06.modified/SCCA_Coop_R06.scmap',
    save = '/maps/scca_coop_r06.modified/SCCA_Coop_R06_save.lua',
    script = '/maps/scca_coop_r06.modified/SCCA_Coop_R06_script.lua',
    norushradius = 40,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'Player1', 'Aeon', 'UEF', 'BlackSun', 'Cybran', 'Player2', 'Player3', 'Player4'}
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
