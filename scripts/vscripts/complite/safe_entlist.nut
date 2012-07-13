// vim: set ts=4
// Kill-safe Entity List for L4D2 VScript Mutations
// Copyright (C) 2012 ProdigySim
// All rights reserved.
// =============================================================================

if("SafeEntList_module" in this) return;
SafeEntList_module <- 0;
IncludeScript("complite/globaltimers.nut", this);

// "Extends" CEntities and TimerCallback
class SafeEntList extends Timers.TimerCallback
{
	constructor(EntList, FrameTimer)
	{
		m_pEntities = EntList;
		m_killList = [];
		m_pTimer = FrameTimer;
	}

	function KillEntity(ent)
	{
		if(m_killList.len() == 0)
		{
			m_pTimer.AddTimer(1, this);
		}
		m_killList.push(ent);
		DoEntFire("!activator", "kill", "", 0, ent, null);
	}
	function IsEntityBeingKilled(ent)
	{
		foreach(dyingEnt in m_killList)
			if(dyingEnt == ent)
				return true;
		return false;
	}

	function OnTimerElapsed()
	{
		local i = 0;
		while(i < m_killList.len())
		{
			if(!m_killList[i].IsValid()) 
			{
				m_killList.remove(i);
			}
			else 
			{
				Msg("Ent still alive!\n");
				i++;
			}
		}
		if(m_killList.len() > 0)
		{
			// Recheck to see if ent is dead by next frame.
			m_pTimer.AddTimer(1, this);
		}
	}

	function First()
	{
		return Next(null);
	}
	function Next(prev)
	{
		local ent = prev;
		do
		{
			ent = m_pEntities.Next(ent);
		} while(IsEntityBeingKilled(ent));
		return ent;
	}
	function FindByClassname(prev, classname)
	{
		local ent = prev;
		do
		{
			ent = m_pEntities.FindByClassname(ent, classname);
		} while(IsEntityBeingKilled(ent));
		return ent;
	}
	function FindByName(prev, name)
	{
		local ent = prev;
		do
		{
			ent = m_pEntities.FindByName(ent, name);
		} while(IsEntityBeingKilled(ent));
		return ent;
	}
	function FindInSphere(prev, point, radius)
	{
		local ent = prev;
		do
		{
			ent = m_pEntities.FindInSphere(ent, point, radius);
		} while(IsEntityBeingKilled(ent));
		return ent;
	}
	function FindByTarget(prev, target)
	{
		local ent = prev;
		do
		{
			ent = m_pEntities.FindByTarget(ent, target);
		} while(IsEntityBeingKilled(ent));
		return ent;
	}
	function FindByModel(prev, model)
	{
		local ent = prev;
		do
		{
			ent = m_pEntities.FindByModel(ent, model);
		} while(IsEntityBeingKilled(ent));
		return ent;
	}
	// We could reimplement this ourselves or use FindByNameWithin...
	// But let's wait until it's needed.
	/*
	function FindByNameNearest(name, point, radius)
	{
		return m_pEntities.FindByNameNearest(name, point, radius);
	}*/
	function FindByNameWithin(prev, name, point, radius)
	{
		local ent = prev;
		do
		{
			ent = m_pEntities.FindByNameWithin(ent, name, point, radius)
		} while(IsEntityBeingKilled(ent));
		return ent;
	}
	// We could reimplement this ourselves or use FindByNameWithin...
	// But let's wait until it's needed.
	/*
	function FindByClassnameNearest(classname, point, radius)
	{
		return m_pEntities.FindByClassnameNearest(classname, point, radius);
	}*/
	function FindByClassnameWithin(prev, classname, point, radius)
	{
		local ent = prev;
		do
		{
			ent = m_pEntities.FindByClassnameWithin(ent, classname, point, radius)
		} while(IsEntityBeingKilled(ent));
		return ent;
	}
	
	m_pEntities = null;
	m_killList = [];
	m_pTimer = null;
}