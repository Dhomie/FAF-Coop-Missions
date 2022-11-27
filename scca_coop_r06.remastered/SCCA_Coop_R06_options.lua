options = 
{
	{ 
		default = 1, 
		label = "Operation: Liberation Debug Mode", 
		help = "Enable/Disable debug mode.", 
		key = 'opt_Coop_Debug_Mode', 
		pref = 'opt_Coop_Debug_Mode', 
		values = { 
			{text = "Disabled",					help = "Disables debug/testing functions, the mission will play as normal.", key = 1, },
			{text = "Enabled",	help = "Enables debug/testing functions, particularly useful to observe AI behaviours. Your initial base will be given to an allied AI.", key = 2, },
		}, 
	},
	{ 
		default = 1, 
		label = "Initial Base", 
		help = "Choose your starting base's size.", 
		key = 'opt_Coop_Initial_Base', 
		pref = 'opt_Coop_Initial_Base', 
		values = { 
			{text = "Difficulty-determined",					help = "Starting base size will be according to the selected difficulty.", key = 4, },
			{text = "Small base",	help = "Starting base size used for Hard difficulty.", key = 3, },
			{text = "Medium base",	help = "Starting base size used for Normal difficulty.", key = 2, },
			{text = "Full base",	help = "Starting base size used for Easy difficulty.", key = 1, },
		}, 
	},
	{ 
		default = 1, 
		label = "Expansion Pack Units", 
		help = "Allow/Disallow Expansion Pack Units", 
		key = 'opt_Coop_Expansion_Pack_Units', 
		pref = 'opt_Coop_Expansion_Pack_Units', 
		values = { 
			{text = "Vanilla",					help = "Only units from the original Supreme Commander are allowed for players and AIs. The mission was balanced with this option in mind.", key = 1, },
			{text = "Forged Alliance",	help = "Forged Alliance units are allowed for players and AIs. The mission was balanced with Vanilla units in mind, choose this at your own risk.", key = 2, },
		}, 
	},
};
