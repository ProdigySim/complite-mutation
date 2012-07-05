// vim: set ts=4
// CompLite.nut (Confogl Mutation)
// Copyright (C) 2012 ProdigySim
// All rights reserved.
// =============================================================================


if(getroottable().rawin("CompLite"))
{
	::CompLite.Globals.iRoundCount++;
	Msg("CompLite starting round "+::CompLite.Utils.GetCurrentRound()+"\n");
	::CompLite.Globals.GSM.Reset();
	::CompLite.Globals.MapInfo.IdentifyMap(Entities);
	Msg("Map is intro? "+::CompLite.Globals.MapInfo.isIntro+"\n");
	
	DirectorOptions <- ::CompLite.ChallengeScript.DirectorOptions;
	Update <- CompLite.ChallengeScript.Update;
	return;
}

Msg("Activating Mutation CompLite\n");

::CompLite <- {
	Globals = {
		iRoundCount = 0
	}
	ChallengeScript = {
		DirectorOptions = {
			ActiveChallenge = 1

			cm_ProhibitBosses = 0
			cm_AllowPillConversion = 0
			
			function AllowWeaponSpawn( classname ) 
			{ 
				return ::CompLite.Globals.GSM.OnAllowWeaponSpawn(classname);
			}
			function ConvertWeaponSpawn( classname ) 
			{ 
				return ::CompLite.Globals.GSM.OnConvertWeaponSpawn(classname);
			}
			function GetDefaultItem( idx ) 
			{
				return ::CompLite.Globals.GSM.OnGetDefaultItem(idx);
			}
			function ConvertZombieClass( id ) 
			{ 
				return ::CompLite.Globals.GSM.OnConvertZombieClass(id);
			}
		}

		function Update()
		{
			::CompLite.Globals.Timer.Update();
			::CompLite.Globals.FrameTimer.Update();
			::CompLite.Globals.GSM.DoFrameUpdate();
		}
	}
}

DirectorOptions <- ::CompLite.ChallengeScript.DirectorOptions;
Update <- CompLite.ChallengeScript.Update;



IncludeScript("complite/gamestate_model.nut", ::CompLite);
IncludeScript("complite/globaltimers.nut", ::CompLite);
IncludeScript("complite/utils.nut", ::CompLite);
IncludeScript("complite/modules.nut", ::CompLite);

g_Timer <- ::CompLite.Globals.Timer <- CompLite.Timers.GlobalSecondsTimer()
g_FrameTimer <- ::CompLite.Globals.FrameTimer <- CompLite.Timers.GlobalFrameTimer()
g_MapInfo <- ::CompLite.Globals.MapInfo <- CompLite.Utils.MapInfo()
g_GSC <- ::CompLite.Globals.GSC <- CompLite.GameState.GameStateController()
g_GSM <- ::CompLite.Globals.GSM <- CompLite.GameState.GameStateModel(g_GSC, Director)


g_MobResetti <- ::CompLite.Globals.MobResetti <- CompLite.Utils.ZeroMobReset(Director, DirectorOptions, g_FrameTimer);

Modules <- ::CompLite.Modules;

g_MapInfo.IdentifyMap(Entities);

g_GSC.AddListener(Modules.MsgGSL());
g_GSC.AddListener(Modules.SpitterControl(Director, DirectorOptions));
g_GSC.AddListener(Modules.MobControl(g_MobResetti));


// Give out hunting rifles on non-intro maps.
// But limit them to 1 of each.
g_GSC.AddListener(Modules.HRControl(Entities, g_FrameTimer));


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
			weapon_pain_pills_spawn = 3
			weapon_melee_spawn = 4
			witch = 1
			func_playerinfected_clip = 0
			weapon_molotov_spawn = 1
			weapon_pipe_bomb_spawn = 2
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
