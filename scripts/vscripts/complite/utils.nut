// vim: set ts=4
// Utilities for L4D2 Vscript Mutations
// Copyright (C) 2012 ProdigySim
// All rights reserved.
// =============================================================================


if("Utils" in this) return;
Utils <- {
	SIClass = {
		Smoker = 1
		Boomer = 2
		Hunter = 3
		Spitter = 4
		Jockey = 5
		Charger = 6
		Witch = 7
		Tank = 8
	}
};
IncludeScript("complite/globaltimers.nut", this);

/* KeyReset
	Create a KeyReset to track the state of a key before you change its value, and
	reset it to the original value/state when you want to revert it.
	Can detect whether a key existed or not and will delete the key afterwards if it doesn't exists.
	
	e.g.
	myKeyReset = KeyReset(DirectorOptions, "JockeyLimit")
	
	then on some event...
	myKeyReset.set(0); // Set DirectorOptions.JockeyLimit to 0, storing the previous value/state
	
	and later...
	myKeyReset.unset(); // Reset DirectorOptions.JockeyLimit to whatever value it was before, or delete
	

 */

// Class that will detect the existence and old value of a key and store
// it for "identical" resetting at a later time.
// Assumes that while between Set() and Unset() calls no other entity will modify the
// value of this key.
class Utils.KeyReset
{
	constructor(owner, key)
	{
		m_owner = owner;
		m_key = key;
	}
	function set(val)
	{
		if(!m_bSet)
		{
			m_bExists = m_owner.rawin(m_key);
			if(m_bExists)
			{
				m_oldVal = m_owner.rawget(m_key);
			}
			m_bSet = true;
		}
		m_owner.rawset(m_key,val);
	}
	function unset()
	{
		if(!m_bSet) return;
		
		if(m_bExists)
		{
			m_owner.rawset(m_key,m_oldVal);
		}
		else
		{
			m_owner.rawdelete(m_key);
		}
		m_bSet = false;
	}
	m_owner = null;
	m_key = null;
	m_oldVal = null;
	m_bExists = false;
	m_bSet = false;
};


/* ZeroMobReset
	Class which handles resetting the mob timer without spawning CI.
	
	e.g.
	g_MobTimerCntl = ZeroMobReset(Director, DirectorOptions, g_FrameTimer);
	
	then later on some event
	g_MobTimerCntl.ZeroMobReset();
	

 */
// Can reset the mob spawn timer at any point without
// triggering an CI to spawn. Should not demolish any other state settings.
class Utils.ZeroMobReset extends Timers.TimerCallback
{
	// Initialize with Director, DirectorOptions, and a GlobalFrameTimer
	constructor(director, dopts, timer)
	{
		m_director = director;
		m_timer = timer;
		m_mobsizesetting = KeyReset(dopts, "MobSpawnSize");
	}
	/* ZeroMobReset()
	Resets the director's mob timer.
	Will trigger incoming horde music, but will not spawn any commons.
	 */
	function ZeroMobReset()
	{
		if(m_bResetInProgress) return;
		
		// set DirectorOptions.MobSpawnSize to 0 so the triggered
		// horde won't spawn CI
		m_mobsizesetting.set(0);
		m_director.ResetMobTimer();
		m_timer.AddTimer(1, this)
		m_bResetInProgress = true;
	}
	// Internal use only,
	// resets the mob size setting after the mob timer has been set
	function OnTimerElapsed()
	{
		m_mobsizesetting.unset();
		m_bResetInProgress = false;
	}
	m_bResetInProgress = false;
	m_director = null;
	m_timer = null;
	m_mobsizesetting = null;
	static KeyReset = Utils.KeyReset;
};

class Utils.Sphere {
	constructor(center, radius)
	{
		m_vecOrigin = center;
		m_flRadius = radius;
	}
	function GetOrigin()
	{
		return m_vecOrigin();
	}
	function GetRadius()
	{
		return m_flRadius;
	}
	// point: vector
	function ContainsPoint(point)
	{
		return (m_vecOrigin - point).Length() <= m_flRadius;
	}
	function ContainsEntity(entity)
	{
		return ContainsPoint(entity.GetOrigin());
	}
	m_vecOrigin = null;
	m_flRadius = null;
};

class Utils.MapInfo {
	function IdentifyMap(EntList)
	{
		isIntro = EntList.FindByName(null, "fade_intro") != null
			|| EntList.FindByName(null, "lcs_intro") != null;

		// also will become true in scavenge gamemode!
		hasScavengeEvent = EntList.FindByClassname(null, "point_prop_use_target") != null;

		saferoomPoints = [];

		if(isIntro)
		{
			local ent = EntList.FindByName(null, "survivorPos_intro_01");
			if(ent != null) saferoomPoints.push(ent.GetOrigin());
		}

		local ent = null;
		while((ent = EntList.FindByClassname(ent, "prop_door_rotating_checkpoint")) != null)
		{
			saferoomPoints.push(ent.GetOrigin());
		}

		if(IsMapC1M2(EntList)) mapname = "c1m2_streets";
		else mapname = "unknown";
	}
	function IsPointNearAnySaferoom(point, distance=2000.0)
	{
		// We actually check if any saferoom is near the point...
		local sphere = Sphere(point, distance);
		foreach(pt in saferoomPoints)
		{
			if(sphere.ContainsPoint(pt)) return true;
		}
		return false;
	}
	function IsEntityNearAnySaferoom(entity, distance=2000.0)
	{
		return IsPointNearAnySaferoom(entity.GetOrigin(), distance);
	}
	function IsMapC1M2(EntList)
	{
		// Identified by a entity with a given model at a given point
		local ent = EntList.FindByModel(null, "models/destruction_tanker/c1m2_cables_far.mdl");
		if(ent != null 
			&& (ent.GetOrigin() - Vector(-6856.0,-896.0,384.664)).Length() < 1.0) return true;
		return false;
	}
	isIntro = false
	isFinale = false
	hasScavengeEvent = false;

	saferoomPoints = null;
	mapname = null
	chapter = 0
	Sphere = Utils.Sphere;
};

Utils.KillEntity <- function (ent)
{
	::CompLite.Globals.SafeEntList.KillEntity(ent);
}

Utils.ArrayToTable <- function (arr)
{
	local tab = {};
	foreach(str in arr) tab[str] <- 0;
	return tab;
}

// TODO move/refactor...
Utils.GetCurrentRound <- function () 
{ 
	return ::CompLite.Globals.GetCurrentRound();
}