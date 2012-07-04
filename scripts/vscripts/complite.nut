// vim: set ts=4
// CompLite.nut (Confogl Mutation)
// Copyright (C) 2012 ProdigySim
// All rights reserved.
// =============================================================================

Msg("Activating Mutation CompLite\n");

DoIncludeScript("gamestate_model.nut", this);
DoIncludeScript("globaltimers.nut", this);

class MsgGSL extends GameStateListener
{
	function OnRoundStart() { Msg("MsgGSL: OnRoundStart()\n"); }
	function OnSafeAreaOpened() { Msg("MsgGSL: OnSafeAreaOpened()\n"); }
	function OnTankEntersPlay() { Msg("MsgGSL: OnTankEntersPlay()\n"); }
	function OnTankLeavesPlay() { Msg("MsgGSL: OnTankLeavesPlay()\n"); }
	function OnSpawnPCZ(id) { Msg("MsgGSL: OnSpawnPCZ("+id+")\n"); }
	function OnSpawnedPCZ(id) { Msg("MsgGSL: OnSpawnedPCZ("+id+")\n"); }
}

class MapInfo {
	function IdentifyMap(EntList)
	{
		isIntro = EntList.FindByName(null, "fade_intro") != null
			|| EntList.FindByName(null, "lcs_intro") != null;
		Msg("Indentified map as intro? "+isIntro+".\n");
	}
	isIntro = false
	isFinale = false
	mapname = null
	chapter = 0
}

enum SIClass {
	Smoker = 1,
	Boomer = 2,
	Hunter = 3,
	Spitter = 4,
	Jockey = 5,
	Charger = 6,
	Witch = 7,
	Tank = 8
}

DirectorOptions <-
{
	ActiveChallenge = 1

	cm_ProhibitBosses = 0
	cm_AllowPillConversion = 0

	MobSpawnMinTime = 100
	MobSpawnMaxTime = 100
	MobSpawnSize = 25
	SpitterLimit = 1

//  cached_tank_state = 0
	new_round_start = false
	round_start_time = 0

	model = null
	controller = null
	mapinfo = null

	// Register a GameStateController to be used
	function RegisterGSC(cntrl)
	{
		controller = cntrl;
	}
	function RegisterGSM(mdl)
	{
		model = mdl;
	}
	function RegisterMapInfo(minfo)
	{
		mapinfo = minfo;
	}

	weaponsToConvert =
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
	}

	function ConvertWeaponSpawn( classname )
	{
		model.OnConvertWeaponSpawn();
		if ( classname in weaponsToConvert )
		{
			//Msg("Converting"+classname+" to "+weaponsToConvert[classname]+"\n")
			return weaponsToConvert[classname];
		}
		return 0;
	}

	// 0: Always remove
	// >0: Keep the first n instances, delete others
	// <-1: Delete the first n instances, keep others.
	weaponsToRemove =
	{
		weapon_defibrillator = 0
		weapon_grenade_launcher = 0
		weapon_upgradepack_incendiary = 0
		weapon_upgradepack_explosive = 0
		weapon_chainsaw = 0
		weapon_molotov = 1
		weapon_pipe_bomb = 2
		weapon_vomitjar = 1
		weapon_propanetank = 0
		weapon_oxygentank = 0
		weapon_rifle_m60 = 0
		weapon_first_aid_kit = -5
		upgrade_item = 0
	}

	function AllowWeaponSpawn( classname )
	{
		model.OnAllowWeaponSpawn();

		if ( classname in weaponsToRemove )
		{
			if(classname == "weapon_hunting_rifle")
			{
				Msg("Found a HR! Voting no!\n");
			}
			if(weaponsToRemove[classname] > 0)
			{
				//Msg("Found a "+classname+" to keep, "+weaponsToRemove[classname]+" remain.\n");
				weaponsToRemove[classname]--
			}
			else if (weaponsToRemove[classname] < -1)
			{
				//Msg("Killing just one "+classname+"\n");
				weaponsToRemove[classname]++
				return false;
			}
			else if (weaponsToRemove[classname] == 0)
			{
				//Msg("Removed "+classname+"\n")
				return false;
			}
		}

		return true;
	}		

	DefaultItems =
	[
		"weapon_pain_pills",
		"weapon_pistol",
	]

	function GetDefaultItem( idx )
	{
		model.OnGetDefaultItem();

		if ( idx < DefaultItems.len() )
		{
			return DefaultItems[idx];
		} else if(!mapinfo.isIntro && idx == DefaultItems.len())
		{
			return "weapon_hunting_rifle"; // give out the hunny rifle
		}
		return 0;
	}

	function ConvertZombieClass(id)
	{
		if(controller != null)
			return controller.TriggerPCZSpawn(id);
		return id;
	}

}

if(Director.IsPlayingOnConsole()) DirectorOptions.MobSpawnSize = 18;

class SpitterControl extends GameStateListener
{
	constructor(director_opts)
	{
		m_dopts = director_opts
	}
	function OnTankEntersPlay()
	{
		m_spitlimit = m_dopts.SpitterLimit;
		m_dopts.SpitterLimit = 0;
	}
	function OnTankLeavesPlay()
	{
		m_dopts.SpitterLimit = m_spitlimit;
	}
	function OnSpawnPCZ(id)
	{
		local newClass = id;

		// If a spitter is going to be spawned during tank,
		if(id == SIClass.Spitter && Director.IsTankInPlay())
		{
			// Calculate the least recently used SI class
			local min_idx = SIClass.Smoker;
			local min = SpawnLastUsed[SIClass.Smoker];
			for(local idx = SIClass.Boomer; idx <= SIClass.Charger; idx++)
			{
				if(idx == SIClass.Spitter) continue;
				if(SpawnLastUsed[idx] < min)
				{
					min = SpawnLastUsed[idx];
					min_idx = idx;
				}
			}
			// We will spawn this instead
			Msg("Converting SI Class "+id+" to class "+min_idx+".\n");
			newClass = min_idx;
		}

		// Mark that this SI to be spawned is most recently spawned now.
		SpawnLastUsed[newClass] = Time();
		Msg("Spawning SI Class "+newClass+".\n");
		return newClass;
	}
	// List of last spawned time for each SI class
	SpawnLastUsed = array(10,0)
	// reference to director options
	m_dopts = null
	// Last spitter limit
	m_spitlimit = 0;
}


class ZeroMobReset extends TimerCallback
{
	constructor(director, dopts, timer)
	{
		m_director = director;
		m_dopts = dopts;
		m_timer = timer;
	}
	function ZeroMobReset()
	{
		if(m_bResetInProgress) return;
		Msg("ZeroMobReset()\n");
		m_oldSize = m_dopts.MobSpawnSize;
		m_dopts.MobSpawnSize = 0
		m_director.ResetMobTimer();
		m_timer.AddTimer(1, this)
		m_bResetInProgress = true;
	}
	function OnTimerElapsed()
	{
		m_dopts.MobSpawnSize = m_oldSize;
		m_bResetInProgress = false;
	}
	m_bResetInProgress = false;
	m_oldSize = 0;
	m_director = null;
	m_dopts = null;
	m_timer = null;
}

class MobControl extends GameStateListener
{
	constructor(director_opts, mobresetti)
	{
		m_dopts = director_opts;
		m_resetti = mobresetti;
	}
	function OnSafeAreaOpened() 
	{
		m_resetti.ZeroMobReset();
	}
	function OnTankEntersPlay()
	{
		m_oldMinTime = m_dopts.MobSpawnMinTime;
		m_oldMaxTime = m_dopts.MobSpawnMaxTime;

		m_dopts.MobSpawnMinTime = 99999;
		m_dopts.MobSpawnMaxTime = 99999;

		m_resetti.ZeroMobReset();
	}
	function OnTankLeavesPlay()
	{
		m_dopts.MobSpawnMinTime = m_oldMinTime;
		m_dopts.MobSpawnMaxTime = m_oldMaxTime;

		m_resetti.ZeroMobReset();
	}
	m_oldMinTime = 0;
	m_oldMaxTime = 0;
	m_dopts = null;
	m_resetti = null;
}


class ItemControl extends GameStateListener
{
	constructor(entlist)
	{
		m_entlist = entlist;
	}
	function OnRoundStart()
	{
		Msg("Complite OnRoundStart()\n");
		// This will run multiple times per round in certain cases...
		// Notably, on natural map switch (transition) e.g. chapter 1 ends, start chapter 2.
		// Just make sure you don't screw up anything...

		local ent = m_entlist.First();
		local classname = "";
		while(ent != null)
		{
			classname = ent.GetClassname()
			if(classname == "func_playerinfected_clip")
			{
				//Msg("Killing...\n");
				DoEntFire("!activator", "kill", "", 0, ent, null);
			} else if (classname in weaponsToRemove)
			{
				ent.__KeyValueFromInt("count", 1);
				if(weaponsToRemove[classname] > 0)
				{
					//Msg("Found a "+classname+" to keep, "+(weaponsToRemove[classname]-1)+" remain.\n");
					weaponsToRemove[classname]--
				}
				else if(weaponsToRemove[classname] == 0)
				{
					//Msg("Removed "+classname+"\n")
					DoEntFire("!activator", "kill", "", 0, ent, null);
				}
			}
			ent=m_entlist.Next(ent);
		}
	}
	// We do a roundstart remove of these items to keep the removals from being too greedy. Health items are odd.
	// Melee weapons work better here, too. Plus we get the chance to set their count!
	// 0+: Limit to value
	// <0: Set Count only
	weaponsToRemove = {
		weapon_adrenaline_spawn = 3
		weapon_pain_pills_spawn = 6
		weapon_melee_spawn = 4
		weapon_molotov_spawn = -1
		weapon_vomitjar_spawn = -1
		weapon_pipebomb_spawn = -1
		weapon_hunting_rifle = 1
		witch = 1
	}
	// pointer to global Entity List
	m_entlist = null;
}

g_Timer <- GlobalTimer();
g_FrameTimer <- GlobalFrameTimer();

g_MapInfo <- MapInfo();
g_MapInfo.IdentifyMap(Entities);
DirectorOptions.RegisterMapInfo(g_MapInfo);

g_MobResetti <- ZeroMobReset(Director, DirectorOptions, g_FrameTimer);

g_gsc <- GameStateController();
g_gsm <- GameStateModel(g_gsc);
DirectorOptions.RegisterGSC(g_gsc);
DirectorOptions.RegisterGSM(g_gsm);
g_gsc.AddListener(MsgGSL());
g_gsc.AddListener(SpitterControl(DirectorOptions));
g_gsc.AddListener(MobControl(DirectorOptions, g_MobResetti));
g_gsc.AddListener(ItemControl(Entities));
Msg("GSC/M/L Script run.\n");

function Update()
{
	g_Timer.Update();
	g_FrameTimer.Update();
	g_gsm.DoFrameUpdate();
}
