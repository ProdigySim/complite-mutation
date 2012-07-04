// vim: set ts=4
// L4D2 GameState Model for Mutation VScripts
// Copyright (C) 2012 ProdigySim
// All rights reserved.
// =============================================================================

// double include protection
if(this.rawin("__INCLUDE_GAMESTATE_MODEL_NUT__")) return;
__INCLUDE_GAMESTATE_MODEL_NUT__ <- true;

class GameStateModel
{
	constructor(controller)
	{
		m_controller = controller;
	}

	function DoFrameUpdate()
	{
		if(m_bLastUpdateTankInPlay)
		{
			if(!Director.IsTankInPlay())
			{
				m_bLastUpdateTankInPlay = false;
				m_controller.TriggerTankLeavesPlay();
			}
		}
		else if(Director.IsTankInPlay())
		{
			m_bLastUpdateTankInPlay = true;
			m_controller.TriggerTankEntersPlay();
		}
		if(!m_bLastUpdateSafeAreaOpened && Director.HasAnySurvivorLeftSafeArea())
		{
			m_bLastUpdateSafeAreaOpened = true;
			m_controller.TriggerSafeAreaOpen();
		}
		if(!m_bRoundStarted && m_bHeardAWS && m_bHeardCWS && m_bHeardGDI && m_iRoundStartTime < Time()-1)
		{
			m_bRoundStarted = true;
			m_controller.TriggerRoundStart();
		}
	}

	function OnAllowWeaponSpawn()
	{
		m_bHeardAWS = true;
		m_iRoundStartTime = Time();
	}
	function OnConvertWeaponSpawn()
	{
		m_bHeardCWS = true;
		m_iRoundStartTime = Time();
	}
	function OnGetDefaultItem()
	{
		m_bHeardGDI = true;
		m_iRoundStartTime = Time();
	}


	// Check for various round-start events before triggering OnRoundStart()
	m_bRoundStarted = false;
	m_bHeardAWS = false;
	m_bHeardCWS = false;
	m_bHeardGDI = false;
	m_iRoundStartTime = 0;

	m_bLastUpdateTankInPlay = false;
	m_bLastUpdateSafeAreaOpened = false;
	m_bNewRoundStart = false;
	m_iRoundStartTime = 0;
	m_controller = null;
}

class GameStateListener
{
	// Called on round start. There may be multiples of these triggered, unfortunately
	function OnRoundStart() {}
	// Called when a player leaves saferoom or the saferoom timer counts down
	function OnSafeAreaOpened() {}
	// Called when tank spawns
	function OnTankEntersPlay() {}
	// Called when tank dies/leaves play
	function OnTankLeavesPlay() {}
	// Called when a player-controlled zombie is going to be spawned via ConvertZombieClass
	// id: SIClass id of the PCZ to be spawned
	// return another SIClass value to convert the PCZ spawn.
	function OnSpawnPCZ(id) { return id; }
	// Called when a player-controlled zombie is going to be spawned via ConvertZombieClass
	// After conversions from OnSpawnPCZ have taken place
	// id: actual SIClass id to be spawned
	function OnSpawnedPCZ(id) {}
}

class GameStateController
{
	function AddListener(listener)
	{
		m_listeners.push(listener)
	}

	function TriggerRoundStart()
	{
		foreach(listener in m_listeners)
			listener.OnRoundStart();
	}
	function TriggerSafeAreaOpen()
	{
		foreach(listener in m_listeners)
			listener.OnSafeAreaOpened();
	}
	function TriggerTankEntersPlay()
	{
		foreach(listener in m_listeners)
			listener.OnTankEntersPlay();
	}
	function TriggerTankLeavesPlay()
	{
		foreach(listener in m_listeners)
			listener.OnTankLeavesPlay();
	}
	function TriggerPCZSpawn(id)
	{
		local retval = id;
		foreach(listener in m_listeners)
		{
			// Allow each listener to try to convert.
			// Not pretty in the long run but I'm okay with it.
			local ret = listener.OnSpawnPCZ(retval);
			if(ret != null) retval = ret;
		}

		// Simply notify everyone of the final value
		foreach(listener in m_listeners)
			listener.OnSpawnedPCZ(retval)
		return retval;
	}
	m_listeners = []
}