version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = 'Fa Mission 1 - Rework - Dhomie42',
    description = '<LOC X1CA_001_description>Fort Clarke, located on the planet Griffin IV, is the UEF\'s last stronghold. Seraphim and Order forces are attacking the fort with overwhelming force. If Fort Clarke falls, the UEF is finished. You will defeat the enemy commanders on Griffin IV and end the siege of Fort Clarke.',
	type = 'campaign_coop',
    starts = true,
	preview = '',
    size = {1024, 1024},
	-- Do not manually edit. Ever. Controlled by deployment script:
	map_version = 1,
    reclaim = {2969521, 17900},
    map = '/maps/X1CA_001/X1CA_001.scmap',
    save = '/maps/X1CA_001/X1CA_001_save.lua',
    script = '/maps/X1CA_001/X1CA_001_script.lua',
    norushradius = 0,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'Player1', 'Seraphim', 'Order', 'UEF', 'Civilians', 'Cybran', 'Aeon'}
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
