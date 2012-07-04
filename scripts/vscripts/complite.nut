// vim: set ts=4
// CompLite.nut (Confogl Mutation)
// Copyright (C) 2012 ProdigySim
// All rights reserved.
// =============================================================================

Msg("Activating Mutation CompLite\n");

if(!getroottable().rawin("m_roundCount"))
{
	Msg("Complite detected new map round!\n");
	::m_roundCount <- 0;
	return;
}

::m_roundCount++;
Msg("Complite starting round "+::m_roundCount+"\n");

DoIncludeScript("complite/gamestate_model.nut", this);
DoIncludeScript("complite/globaltimers.nut", this);
DoIncludeScript("complite/utils.nut", this);

class MsgGSL extends GameStateListener
{
	function OnRoundStart() { Msg("MsgGSL: OnRoundStart()\n"); }
	function OnSafeAreaOpened() { Msg("MsgGSL: OnSafeAreaOpened()\n"); }
	function OnTankEntersPlay() { Msg("MsgGSL: OnTankEntersPlay()\n"); }
	function OnTankLeavesPlay() { Msg("MsgGSL: OnTankLeavesPlay()\n"); }
	function OnSpawnPCZ(id) { Msg("MsgGSL: OnSpawnPCZ("+id+")\n"); }
	function OnSpawnedPCZ(id) { Msg("MsgGSL: OnSpawnedPCZ("+id+")\n"); }
	function OnGetDefaultItem(idx)
	{ 
		if(idx == 0) 
		{
			Msg("MsgGSL: OnGetDefaultItem(0) #"+m_defaultItemCnt+"\n");
			m_defaultItemCnt++;
		}
	}
	// Too much spam for these
	/*
	function OnAllowWeaponSpawn(classname) {}
	function OnConvertWeaponSpawn(classname) {}
	*/
	m_defaultItemCnt = 0;
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

function KillEntity(ent)
{
	DoEntFire("!activator", "kill", "", 0, ent, null);
}
::KillEntity <- KillEntity;

DirectorOptions <-
{
	ActiveChallenge = 1

	cm_ProhibitBosses = 0
	cm_AllowPillConversion = 0
	
	m_model = null
	
	function RegisterModel(mdl) { m_model = mdl; }
	function AllowWeaponSpawn( classname )
	{
		return m_model.OnAllowWeaponSpawn(classname);
	}
	function ConvertWeaponSpawn( classname ) 
	{ 
		return m_model.OnConvertWeaponSpawn(classname);
	}
	function GetDefaultItem( idx ) 
	{
		return m_model.OnGetDefaultItem(idx);
	}
	function ConvertZombieClass( id ) 
	{ 
		return m_model.OnConvertZombieClass(id);
	}
}

class SpitterControl extends GameStateListener
{
	constructor(director, director_opts)
	{
		m_pDirector = director;
		m_pSpitterLimit = ::KeyReset(director_opts, "SpitterLimit");
	}
	function OnTankEntersPlay()
	{
		m_pSpitterLimit.set(0);
	}
	function OnTankLeavesPlay()
	{
		m_pSpitterLimit.unset();
	}
	function OnSpawnPCZ(id)
	{
		local newClass = id;

		// If a spitter is going to be spawned during tank,
		if(id == SIClass.Spitter && m_pDirector.IsTankInPlay())
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
	SpawnLastUsed = array(10,0);
	// reference to director options
	m_pSpitterLimit = null;
	m_pDirector = null;
}


class MobControl extends GameStateListener
{
	constructor(mobresetti)
	{
		//m_dopts = director_opts;
		m_resetti = mobresetti;
	}
	function OnSafeAreaOpened() 
	{
		m_resetti.ZeroMobReset();
	}
	// These functions created major problems....
	/*
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
	m_dopts = null; */
	m_resetti = null;
}

class BasicItemSystems extends GameStateListener
{
	constructor(removalTable, convertTable, defaultItemList)
	{
		m_removalTable = removalTable;
		m_convertTable = convertTable;
		m_defaultItemList = defaultItemList
	}
	function OnAllowWeaponSpawn(classname)
	{
		if ( classname in m_removalTable )
		{
			if(m_removalTable[classname] > 0)
			{
				//Msg("Found a "+classname+" to keep, "+m_removalTable[classname]+" remain.\n");
				m_removalTable[classname]--
			}
			else if (m_removalTable[classname] < -1)
			{
				//Msg("Killing just one "+classname+"\n");
				m_removalTable[classname]++
				return false;
			}
			else if (m_removalTable[classname] == 0)
			{
				//Msg("Removed "+classname+"\n")
				return false;
			}
		}
		return true;
	}
	function OnConvertWeaponSpawn(classname)
	{
		if ( classname in m_convertTable )
		{
			//Msg("Converting"+classname+" to "+convertTable[classname]+"\n")
			return m_convertTable[classname];
		}
		return 0;
	}
	function OnGetDefaultItem(idx)
	{
		if ( idx < m_defaultItemList.len())
		{
			return m_defaultItemList[idx];
		}
		return 0;
	}
	m_removalTable = null;
	m_convertTable = null;
	m_defaultItemList = null;
}

class ItemControl extends GameStateListener
{
	constructor(entlist, removalTable, setCountTable)
	{
		m_entlist = entlist;
		m_removalTable = removalTable;
		m_setCountTable = setCountTable;
	}
	function OnRoundStart()
	{
		Msg("ItemControl OnRoundStart()\n");
		// This will run multiple times per round in certain cases...
		// Notably, on natural map switch (transition) e.g. chapter 1 ends, start chapter 2.
		// Just make sure you don't screw up anything...

		local ent = m_entlist.First();
		local classname = "";
		local tItemEnts = {};

		// Create an empty array for each item in our list.
		foreach(key,val in m_removalTable)
		{
			tItemEnts[key] <- [];
		}

		while(ent != null)
		{
			classname = ent.GetClassname()
			if(classname in m_setCountTable)
			{
				ent.__KeyValueFromInt("count", 1);
			}
			if(classname in m_removalTable)
			{
				tItemEnts[classname].push(ent);
			}
			ent=m_entlist.Next(ent);
		}

		foreach(classname,instances in tItemEnts)
		{
			local cnt = m_removalTable[classname].tointeger();

			// Less instances of this entity class than we want to remove to.
			if(instances.len() <= cnt) continue;

			// We need to choose certain items to save
			if(cnt > 0)
			{
				local curIdx = 0;
				local saved = 0;
				local saveratio = (instances.len() / cnt) - 1;
				
				// Reverse list (inplace) so we bias towards keeping later items
				instances.reverse();
				// Until we have saved enough items
				while( saved < cnt )
				{
					// Remove this entity from the kill list
					instances.remove(curIdx);
					// Leave the next saveratio items in the kill list
					curIdx += saveratio;
					// Count that we have saved another entity
					saved++;
				}
			}
			Msg("Killing "+instances.len()+" "+classname+" out of "+(instances.len()+cnt)+" on the map.\n");
			foreach(inst in instances)
			{
				::KillEntity(inst);
			}

		}
	}
	// pointer to global Entity List
	m_entlist = null;
	// Table of entity classname, limit value pairs
	// We do a roundstart remove of these items to keep the removals from being too greedy. Health items are odd.
	// Melee weapons work better here, too. Plus we get the chance to set their count!
	// 0+: Limit to value
	// <0: Set Count only
	m_removalTable = null;
	m_setCountTable = null;
}

class HRControl extends GameStateListener //, extends TimerCallback (no MI support)
{
	constructor(entlist, gtimer)
	{
		m_pEntities = entlist;
		m_pTimer = gtimer;
	}
	function OnGetDefaultItem(idx)
	{
		if(!m_bTriggeredOnce)
		{
			// Process HRs next frame after they're handed out.
			m_pTimer.AddTimer(2,this);	
			m_bTriggeredOnce = true;
		}
	}

	// Not actually inherited but it doesn't need to be.
	function OnTimerElapsed()
	{
		local ent = null;
		local hrList = [];
		while((ent = m_pEntities.FindByClassname(ent, "weapon_hunting_rifle")) != null)
		{
			hrList.push(ent);
		}
		Msg("Found "+hrList.len()+" HRs this check\n");
		if(hrList.len() <= 1) return;
		
		// Save 1 HR at random
		hrList.remove(RandomInt(0,hrList.len()-1));

		// Delete the rest
		foreach(hr in hrList)
		{
			::KillEntity(hr);
		}
	}
	m_pEntities = null;
	m_pTimer = null;
	m_bTriggeredOnce = false;
}

g_Timer <- GlobalSecondsTimer();
g_FrameTimer <- GlobalFrameTimer();

g_MapInfo <- MapInfo();
g_MapInfo.IdentifyMap(Entities);

g_MobResetti <- ZeroMobReset(Director, DirectorOptions, g_FrameTimer);

g_gsc <- GameStateController();
g_gsm <- GameStateModel(g_gsc, Director);
DirectorOptions.RegisterModel(g_gsm);
g_gsc.AddListener(MsgGSL());
g_gsc.AddListener(SpitterControl(Director, DirectorOptions));
g_gsc.AddListener(MobControl(g_MobResetti));

myDefaultItems <-
[
	"weapon_pain_pills",
	"weapon_pistol",
];
// Give out hunting rifles on non-intro maps.
// But limit them to 1 of each.
if(!g_MapInfo.isIntro)
{
	myDefaultItems.push("weapon_hunting_rifle");
	g_gsc.AddListener(HRControl(Entities, g_FrameTimer));
}


g_gsc.AddListener(
	BasicItemSystems(
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
		myDefaultItems
	)
);

g_gsc.AddListener(
	ItemControl(Entities, 
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

function Update()
{
	g_Timer.Update();
	g_FrameTimer.Update();
	g_gsm.DoFrameUpdate();
}
