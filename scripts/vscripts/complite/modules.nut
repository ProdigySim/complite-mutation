// vim: set ts=4
// CompLite Mutation Modules
// Copyright (C) 2012 ProdigySim
// All rights reserved.
// =============================================================================

if("Modules" in this) return;
Modules <- {};
IncludeScript("complite/gamestate_model.nut", this);
IncludeScript("complite/utils.nut", this);


class Modules.MsgGSL extends GameState.GameStateListener
{
	function OnRoundStart(roundNumber) { Msg("MsgGSL: OnRoundStart("+roundNumber+")\n"); }
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
};

class Modules.SpitterControl extends GameState.GameStateListener
{
	constructor(director, director_opts)
	{
		m_pDirector = director;
		m_pSpitterLimit = KeyReset(director_opts, "SpitterLimit");
		SpawnLastUsed = array(5,0);
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
			// Convert spitter to least recently used SI class
			newClass = SpawnLastUsed[0];
		}
		// Msg("Spawning SI Class "+newClass+".\n");
		return newClass;
	}
	function OnSpawnedPCZ(id)
	{
		// Mark that this SI to be spawned is most recently spawned now.
		if(id != SIClass.Spitter)
		{
			// Low index = least recent
			// High index = most recent
			SpawnLastUsed.push(id);
			SpawnLastUsed.remove(0);
		}
	}
	// List of last spawned time for each SI class
	SpawnLastUsed = null;
	// reference to director options
	m_pSpitterLimit = null;
	m_pDirector = null;
	static KeyReset = Utils.KeyReset;
	static SIClass = Utils.SIClass;
};


class Modules.MobControl extends GameState.GameStateListener
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
};

class Modules.BasicItemSystems extends GameState.GameStateListener
{
	constructor(removalTable, convertTable, defaultItemList)
	{
		m_removalTable = removalTable;
		m_convertTable = convertTable;
		m_defaultItemList = defaultItemList;
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
};

class Modules.ItemControl extends GameState.GameStateListener
{
	constructor(entlist, removalTable, setCountList, saferoomRemoveList, mapinfo)
	{
		m_entlist = entlist;
		m_removalTable = removalTable;
		m_setCountList = ArrayToTable(setCountList);
		m_saferoomRemoveList = ArrayToTable(saferoomRemoveList);
		m_pMapInfo = mapinfo;
	}
	function OnFirstRound()
	{
		local ent = m_entlist.First();
		local classname = "";
		local tItemEnts = {};
		local saferoomEnts = [];

		// Create an empty array for each item in our list.
		foreach(key,val in m_removalTable)
		{
			tItemEnts[key] <- [];
		}

		while(ent != null)
		{
			classname = ent.GetClassname()
			if(classname in m_setCountList)
			{
				ent.__KeyValueFromInt("count", 1);
			}
			if(classname in m_saferoomRemoveList && m_pMapInfo.IsEntityNearAnySaferoom(ent, 2000.0))
			{
				// Make a list of items which are in saferooms that need to be removed
				// and don't track these entities for other removal.
				saferoomEnts.push(ent);
			}
			else if(classname in m_removalTable)
			{
				tItemEnts[classname].push(ent);
			}
			ent=m_entlist.Next(ent);
		}
		
		// Remove all targeted saferoom items before doing roundstart removals
		foreach(entity in saferoomEnts) KillEntity(entity);

		m_firstRoundEnts = {}
		foreach(classname,instances in tItemEnts)
		{
			local cnt = m_removalTable[classname].tointeger();
			local saved_ents = m_firstRoundEnts[classname] <- [];
			// We need to choose certain items to save
			while( instances.len() > 0 && saved_ents.len() < cnt )
			{
				local saveIdx = RandomInt(0,instances.len()-1);
				// Track this entity's info for future rounds.
				saved_ents.push(ItemInfo(instances[saveIdx]));
				// Remove this entity from the kill list
				instances.remove(saveIdx);
			}
			Msg("Killing "+instances.len()+" "+classname+", leaving "+saved_ents.len()+" on the map.\n");
			foreach(inst in instances)
			{
				KillEntity(inst);
			}
		}
	}
	function OnLaterRounds()
	{
		local ent = m_entlist.First();
		local classname = "";
		local tItemEnts = {};

		foreach(key,val in m_removalTable)
		{
			tItemEnts[key] <- [];
		}
		while(ent != null)
		{
			classname = ent.GetClassname()
			if(classname in m_setCountList)
			{
				ent.__KeyValueFromInt("count", 1);
			}
			if(classname in m_removalTable)
			{
				tItemEnts[classname].push(ent);
			}
			ent=m_entlist.Next(ent);
		}

		foreach(classname,entList in tItemEnts)
		{
			local firstItems = m_firstRoundEnts[classname];
			// count to keep alive
			local cnt = firstItems.len();
			if(cnt > entList.len())
			{
				Msg("Warning! Not enough "+classname+" spawned this round to match R1! ("+entList.len()+" < "+cnt+")\n");
				cnt = entList.len();
			}

			for(local i = cnt; i < entList.len(); i++)
			{
				KillEntity(entList[i]);
			}

			for(local i = 0; i < cnt; i++)
			{
				entList[i].SetOrigin(firstItems[i].m_vecOrigin);
				entList[i].SetForwardVector(firstItems[i].m_vecForward);
			}
			Msg("Restored "+cnt+" "+classname+", out of "+entList.len()+" on the map.\n");
		}
	}
	function OnRoundStart(roundNumber)
	{
		Msg("ItemControl OnRoundStart()\n");
		// This will run multiple times per round in certain cases...
		// Notably, on natural map switch (transition) e.g. chapter 1 ends, start chapter 2.
		// Just make sure you don't screw up anything...
		if(roundNumber == 1)
		{
			OnFirstRound();
		}
		else
		{
			OnLaterRounds();
		}

		
	}
	// pointer to global Entity List
	m_entlist = null;
	// point to global mapinfo
	m_pMapInfo = null;
	// Table of entity classname, limit value pairs
	// We do a roundstart remove of these items to keep the removals from being too greedy. Health items are odd.
	// Melee weapons work better here, too. Plus we get the chance to set their count!
	m_removalTable = null;
	m_setCountList = null;
	m_saferoomRemoveList = null;

	m_firstRoundEnts = null;
	static ArrayToTable = Utils.ArrayToTable;
	static ItemInfo = class	{
		constructor(ent)
		{
			m_vecOrigin = ent.GetOrigin();
			m_vecForward = ent.GetForwardVector();
		}
		m_vecOrigin = null;
		m_vecForward = null;
	};
	static KillEntity = Utils.KillEntity;
};

class Modules.HRControl extends GameState.GameStateListener //, extends TimerCallback (no MI support)
{
	constructor(entlist, globals, director)
	{
		m_pEntities = entlist;
		m_pGlobals = globals;
		m_pDirector = director;
	}
	function QueueCheck(time)
	{
		if(!m_bChecking)
		{
			m_pGlobals.Timer.AddTimer(time, this);
			m_bChecking = true;
		}
	}
	function OnRoundStart(roundNumber)
	{
		QueueCheck(1.0);
	}
	function OnTimerElapsed()
	{
		m_bChecking=false;
		if(!m_pDirector.HasAnySurvivorLeftSafeArea()) QueueCheck(5.0);
		
		local ent = null;
		local hrList = [];
		while((ent = m_pEntities.FindByClassname(ent, "weapon_hunting_rifle")) != null)
		{
			hrList.push(ent);
		}

		if(hrList.len() <= 1) return;

		if(!m_pGlobals.MapInfo.isIntro)
		{
			hrList.remove(RandomInt(0,hrList.len()-1));
		}

		// Delete the rest
		foreach(hr in hrList)
		{
			KillEntity(hr);
		}
	}
	m_pEntities = null;
	m_pTimer = null;
	m_pGlobals = null;
	m_pDirector = null;
	m_bChecking = false;
	static KillEntity = Utils.KillEntity;
};

