StatisticsTweakData = StatisticsTweakData or class()
function StatisticsTweakData:init()
	self.session = {}
	self.killed = {
		civilian = {
			total = {count = 0, type = "normal"},
			head_shots = {count = 0, type = "normal"},
			session = {count = 0, type = "session"}
		},
		civilian = {count = 0, head_shots = 0},
		security = {count = 0, head_shots = 0},
		cop = {count = 0, head_shots = 0},
		swat = {count = 0, head_shots = 0},
		total = {count = 0, head_shots = 0}
	}
end
function StatisticsTweakData:statistics_table()
	local level_list = {
		"safehouse",
		"jewelry_store",
		"four_stores",
		"nightclub",
		"mallcrasher",
		"ukrainian_job",
		"branchbank",
		"framing_frame_1",
		"framing_frame_2",
		"framing_frame_3",
		"alex_1",
		"alex_2",
		"alex_3",
		"watchdogs_1",
		"watchdogs_2",
		"watchdogs_1_night",
		"watchdogs_2_day",
		"firestarter_1",
		"firestarter_2",
		"firestarter_3",
		"welcome_to_the_jungle_1",
		"welcome_to_the_jungle_1_night",
		"welcome_to_the_jungle_2",
		"escape_cafe_day",
		"escape_park_day",
		"escape_cafe",
		"escape_park",
		"escape_street",
		"escape_overpass",
		"escape_garage",
		"family",
		"arm_cro",
		"arm_und",
		"arm_hcm",
		"arm_par",
		"arm_fac",
		"arm_for",
		"roberts",
		"election_day_1",
		"election_day_2",
		"election_day_3_skip1",
		"election_day_3_skip2",
		"kosugi",
		"big",
		"mia_1",
		"mia_2",
		"hox_1",
		"hox_2",
		"mus",
		"gallery",
		"haunted",
		"pines",
		"crojob2",
		"crojob3",
		"crojob3_night",
		"rat",
		"cage",
		"hox_3"
	}
	local job_list = {
		"jewelry_store",
		"four_stores",
		"nightclub",
		"mallcrasher",
		"ukrainian_job_prof",
		"branchbank_deposit",
		"branchbank_cash",
		"branchbank_gold_prof",
		"branchbank_prof",
		"framing_frame",
		"framing_frame_prof",
		"alex",
		"alex_prof",
		"watchdogs",
		"watchdogs_prof",
		"watchdogs_night",
		"watchdogs_night_prof",
		"firestarter",
		"firestarter_prof",
		"welcome_to_the_jungle_prof",
		"welcome_to_the_jungle_night_prof",
		"family",
		"arm_fac",
		"arm_par",
		"arm_hcm",
		"arm_und",
		"arm_cro",
		"roberts",
		"election_day",
		"election_day_prof",
		"kosugi",
		"big",
		"mia",
		"mia_prof",
		"hox",
		"hox_prof",
		"mus",
		"gallery",
		"haunted",
		"pines",
		"crojob1",
		"crojob2",
		"crojob2_night",
		"rat",
		"arm_for",
		"cage",
		"hox_3"
	}
	local mask_list = {
		"character_locked",
		"alienware",
		"babyrhino",
		"biglips",
		"brainiack",
		"buha",
		"bullet",
		"clown_56",
		"clowncry",
		"dawn_of_the_dead",
		"day_of_the_dead",
		"demon",
		"demonictender",
		"dripper",
		"gagball",
		"greek_tragedy",
		"hockey",
		"hog",
		"jaw",
		"monkeybiss",
		"mr_sinister",
		"mummy",
		"oni",
		"outlandish_a",
		"outlandish_b",
		"outlandish_c",
		"scarecrow",
		"shogun",
		"shrunken",
		"skull",
		"stonekisses",
		"tounge",
		"troll",
		"vampire",
		"zipper",
		"zombie",
		"dallas",
		"wolf",
		"chains",
		"hoxton",
		"dallas_clean",
		"wolf_clean",
		"chains_clean",
		"hoxton_clean",
		"anonymous",
		"cthulhu",
		"dillinger_death_mask",
		"grin",
		"kawaii",
		"irondoom",
		"rubber_male",
		"rubber_female",
		"pumpkin_king",
		"witch",
		"venomorph",
		"frank",
		"baby_happy",
		"baby_angry",
		"baby_cry",
		"brazil_baby",
		"heat",
		"bear",
		"clinton",
		"bush",
		"obama",
		"nixon",
		"goat",
		"panda",
		"pitbull",
		"eagle",
		"santa_happy",
		"santa_mad",
		"santa_drunk",
		"santa_surprise",
		"aviator",
		"ghost",
		"welder",
		"plague",
		"smoker",
		"cloth_commander",
		"gage_blade",
		"gage_rambo",
		"gage_deltaforce",
		"robberfly",
		"spider",
		"mantis",
		"wasp",
		"skullhard",
		"skullveryhard",
		"skulloverkill",
		"skulloverkillplus",
		"samurai",
		"twitch_orc",
		"ancient",
		"franklin",
		"lincoln",
		"grant",
		"washington",
		"metalhead",
		"tcn",
		"surprise",
		"optimist_prime",
		"silverback",
		"mandril",
		"skullmonkey",
		"orangutang",
		"unicorn",
		"galax",
		"crowgoblin",
		"evil",
		"volt",
		"white_wolf",
		"owl",
		"rabbit",
		"pig",
		"panther",
		"rooster",
		"horse",
		"tiger",
		"combusto",
		"spackle",
		"stoneface",
		"wayfarer",
		"smiley",
		"gumbo",
		"crazy_lion",
		"old_hoxton",
		"the_one_below",
		"lycan",
		"churchill",
		"red_hurricane",
		"patton",
		"de_gaulle",
		"area51",
		"alien_helmet",
		"krampus",
		"mrs_claus",
		"strinch",
		"robo_santa",
		"almirs_beard",
		"msk_grizel",
		"grizel_clean",
		"medusa",
		"anubis",
		"pazuzu",
		"cursed_crown",
		"nun_town",
		"robo_arnold",
		"arch_nemesis",
		"champion_dallas",
		"dragan",
		"dragan_begins",
		"butcher",
		"doctor",
		"tech_lion",
		"lady_butcher",
		"carnotaurus",
		"triceratops",
		"pachy",
		"velociraptor",
		"the_overkill_mask",
		"dallas_glow",
		"wolf_glow",
		"hoxton_glow",
		"chains_glow",
		"jake",
		"richter",
		"biker",
		"alex",
		"corey",
		"tonys_revenge",
		"richard_returns",
		"richard_begins",
		"bonnie",
		"bonnie_begins",
		"simpson",
		"hothead",
		"falcon",
		"unic",
		"speedrunner",
		"hectors_helmet",
		"old_hoxton_begins",
		"firedemon",
		"gasmask",
		"firemask",
		"chef_hat",
		"bandit",
		"bullskull",
		"kangee",
		"lone"
	}
	local weapon_list = {
		"ak5",
		"ak74",
		"akm",
		"akmsu",
		"amcar",
		"aug",
		"b92fs",
		"colt_1911",
		"deagle",
		"g22c",
		"g36",
		"glock_17",
		"glock_18c",
		"huntsman",
		"m16",
		"mac10",
		"mp9",
		"new_m14",
		"new_m4",
		"new_mp5",
		"new_raging_bull",
		"olympic",
		"p90",
		"r870",
		"saiga",
		"saw",
		"serbu",
		"usp",
		"m45",
		"s552",
		"ppk",
		"mp7",
		"scar",
		"p226",
		"akm_gold",
		"hk21",
		"m249",
		"rpk",
		"m95",
		"msr",
		"r93",
		"fal",
		"benelli",
		"striker",
		"ksg",
		"judge",
		"gre_m79",
		"g3",
		"galil",
		"famas",
		"scorpion",
		"tec9",
		"uzi",
		"jowi",
		"x_1911",
		"x_b92fs",
		"x_deagle",
		"g26",
		"spas12",
		"mg42",
		"c96",
		"sterling",
		"mosin",
		"m1928",
		"l85a2",
		"vhs",
		"hs2000",
		"m134",
		"rpg7",
		"cobray",
		"b682",
		"flamethrower_mk2",
		"m32",
		"aa12",
		"peacemaker",
		"winchester1874",
		"plainsrider"
	}
	local melee_list = {
		"weapon",
		"fists",
		"kabar",
		"rambo",
		"gerber",
		"kampfmesser",
		"brass_knuckles",
		"tomahawk",
		"baton",
		"shovel",
		"becker",
		"moneybundle",
		"barbedwire",
		"x46",
		"dingdong",
		"bayonet",
		"bullseye",
		"baseballbat",
		"cleaver",
		"fireaxe",
		"machete",
		"briefcase",
		"kabartanto",
		"toothbrush",
		"chef",
		"fairbair",
		"freedom",
		"model24",
		"swagger",
		"alien_maul",
		"shillelagh",
		"boxing_gloves",
		"meat_cleaver",
		"hammer",
		"whiskey",
		"fork",
		"poker",
		"spatula",
		"tenderizer",
		"scalper",
		"mining_pick",
		"branding_iron",
		"bowie"
	}
	local grenade_list = {
		"frag",
		"molotov",
		"dynamite"
	}
	local enemy_list = {
		"civilian",
		"civilian_female",
		"cop",
		"fbi",
		"fbi_swat",
		"fbi_heavy_swat",
		"swat",
		"heavy_swat",
		"city_swat",
		"security",
		"gensec",
		"gangster",
		"biker_escape",
		"sniper",
		"shield",
		"spooc",
		"tank",
		"taser",
		"mobster",
		"mobster_boss",
		"tank_hw",
		"hector_boss",
		"hector_boss_no_armor"
	}
	local armor_list = {
		"level_1",
		"level_2",
		"level_3",
		"level_4",
		"level_5",
		"level_6",
		"level_7"
	}
	local character_list = {
		"russian",
		"german",
		"spanish",
		"american",
		"jowi",
		"old_hoxton",
		"female_1",
		"dragan",
		"jacket",
		"bonnie"
	}
	return level_list, job_list, mask_list, weapon_list, melee_list, grenade_list, enemy_list, armor_list, character_list
end
