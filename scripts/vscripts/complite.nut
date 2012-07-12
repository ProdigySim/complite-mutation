// vim: set ts=4
// CompLite.nut (Confogl Mutation)
// Copyright (C) 2012 ProdigySim
// All rights reserved.
// =============================================================================

IncludeScript("complite/globals.nut", this);

CompLite = InitializeCompLite();

// Don't need to do anything else if we're not first load
if(CompLite.Globals.GetCurrentRound() > 0)
{
	Msg("CompLite Starting Round "+CompLite.Globals.GetCurrentRound()+" on ");
	if(CompLite.Globals.MapInfo.isIntro) Msg("an intro map.\n");
	else Msg("a non-intro map.\n");
	return;
}

Msg("Activating Mutation CompLite v3.0\n");

DirectorOptions.ActiveChallenge <- 1
DirectorOptions.cm_ProhibitBosses <- 0
DirectorOptions.cm_AllowPillConversion <- 0

// Name shortening references
local g_Timer = CompLite.Globals.Timer;
local g_FrameTimer = CompLite.Globals.FrameTimer;
local g_MapInfo = CompLite.Globals.MapInfo;
local g_GSC = CompLite.Globals.GSC;
local g_GSM = CompLite.Globals.GSM;
local g_MobResetti = CompLite.Globals.MobResetti;
local Modules = CompLite.Modules;

// Uncomment to add a debug event listener
//g_GSC.AddListener(Modules.MsgGSL());

g_GSC.AddListener(Modules.SpitterControl(Director, DirectorOptions));
g_GSC.AddListener(Modules.MobControl(g_MobResetti));


// Give out hunting rifles on non-intro maps.
// But limit them to 1 of each.
g_GSC.AddListener(Modules.HRControl(Entities, CompLite.Globals));


g_GSC.AddListener(
	Modules.BasicItemSystems(
		// AllowWeaponSpawn Limits
		// 0: Always remove
		// >0: Keep the first n instances, delete others
		// <-1: Delete the first n instances, keep others.
		{
			weapon_defibrillator = 0
			weapon_grenade_launcher = 0
			weapon_upgradepack_incendiary = 0
			weapon_upgradepack_explosive = 0
			weapon_chainsaw = 0
			//weapon_molotov = 1
			//weapon_pipe_bomb = 2
			//weapon_vomitjar = 1
			weapon_propanetank = 0
			weapon_oxygentank = 0
			weapon_rifle_m60 = 0
			weapon_first_aid_kit = -5
			upgrade_item = 0
		},
		// Conversion Rules
		{
		weapon_autoshotgun	  = "weapon_pumpshotgun_spawn"
		weapon_shotgun_spas	 = "weapon_shotgun_chrome_spawn"
		weapon_rifle			= "weapon_smg_spawn"
		weapon_rifle_desert	 = "weapon_smg_spawn"
		weapon_rifle_sg552	  = "weapon_smg_mp5_spawn"
		weapon_rifle_ak47	   = "weapon_smg_silenced_spawn"
		weapon_hunting_rifle	= "weapon_smg_silenced_spawn"
		weapon_sniper_military  = "weapon_shotgun_chrome_spawn"
		weapon_sniper_awp	   = "weapon_shotgun_chrome_spawn"
		weapon_sniper_scout	 = "weapon_pumpshotgun_spawn"
		weapon_first_aid_kit	= "weapon_pain_pills_spawn"
		weapon_molotov = "weapon_molotov_spawn"
		weapon_pipe_bomb = "weapon_pipe_bomb_spawn"
		weapon_vomitjar = "weapon_vomitjar_spawn"
		},
		// Default item list
		[
			"weapon_pain_pills",
			"weapon_pistol",
			"weapon_hunting_rifle"
		]
	)
);

g_GSC.AddListener(
	Modules.ItemControl(Entities, 
	// Roundstart Weapon removal list
	// Limit to value
		{
			weapon_adrenaline_spawn = 1
			weapon_pain_pills_spawn = 4
			weapon_melee_spawn = 4
			witch = 1
			func_playerinfected_clip = 0
			weapon_molotov_spawn = 1
			weapon_pipe_bomb_spawn = 1
			weapon_vomitjar_spawn = 1
		},
	// Set count to 1 on these
		[
			"weapon_adrenaline_spawn",
			"weapon_pain_pills_spawn",
			"weapon_melee_spawn",
			"weapon_molotov_spawn",
			"weapon_vomitjar_spawn",
			"weapon_pipebomb_spawn"
		]
	)
);



Msg("GSC/M/L Script run.\n");
