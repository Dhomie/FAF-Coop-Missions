version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = 'FA Mission 2 - Rework - Dhomie42',
    description = '<LOC X1CA_002_description>Aeon Loyalists, led by Crusader Rhiza, were captured while conducting sabotage and intelligence missions against Order and QAI positions. You must rescue the Loyalists being held by QAI and defeat all enemy commanders operating on the planet.',
    preview = '',
    map_version = 1,
    type = 'campaign_coop',
    starts = true,
    size = {1024, 1024},
    reclaim = {2714116, 83508.84},
    map = '/maps/X1CA_002/X1CA_002.scmap',
    save = '/maps/X1CA_002/X1CA_002_save.lua',
    script = '/maps/X1CA_002/X1CA_002_script.lua',
    norushradius = 40,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'Player1', 'Order', 'QAI', 'Loyalist', 'OrderNeutral', 'Cybran', 'UEF'}
                },
            },
            customprops = {
            },
            factions = {
                {'uef', 'aeon', 'cybran'}
            },
        },
    },
}
