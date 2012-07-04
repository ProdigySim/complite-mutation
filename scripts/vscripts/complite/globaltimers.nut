// vim: set ts=4
// Global Timers for L4D2 VScript Mutations
// Copyright (C) 2012 ProdigySim
// All rights reserved.
// =============================================================================


/* Usage:
	Create an instance of one of these timers, e.g.
	g_Timer = GlobalTimer()
	and/or
	g_FrameTimer = GlobalFrameTimer()
	
	Then run the timer's Update() function in your global "update" function.
	e.g. 
	function Update()
	{
		g_Timer.Update();
		g_FrameTimer.Update();
	}
	
	To add a timer, extend TimerCallback to create a callback.
	e.g.
	class MyCallback extends TimerCallback
	{
		function OnTimerElapsed()
		{
			Msg("My Timer has elapsed!!!\n");
		}
	}
	
	Then register it to the global timer of your choice,
	
 */

// double include protection
if(this.rawin("__INCLUDE_GLOBALTIMERS_NUT__")) return;
__INCLUDE_GLOBALTIMERS_NUT__ <- true;

class TimerCallback
{
	/* OnTimerElapsed()
	Executed once the timer is elapsed in a GlobalTimer
	 */
	function OnTimerElapsed() {}
}

class ::GlobalTimer
{
	// Returns the current time in some format that supports arithmetic operations
	// Overload this in your final class
	function GetCurrentTime() { assert(null) }
	/* Update()
	Checks to see which timers have elapsed.
	Please run on global frame Update() function
	 */
	function Update()
	{
		while(m_cbtimes.len() && m_cbtimes[0] < GetCurrentTime())
		{
			m_callbacks[0].OnTimerElapsed();
			m_callbacks.remove(0);
			m_cbtimes.remove(0);
		}
	}
	
	/* AddTimer(time,timer)
	Register a new timed callback.
	time: Time in seconds to wait before executing the timer callback.
	timer: TimerCallback to execute once the timer has elapsed.
	 */
	function AddTimer(time, timer)
	{
		local cbtime = GetCurrentTime() + time;
		// Insert sorted Ascending by end timestamp (cbtime) into callbacks list
		local i = 0;
		// TODO: Binary search
		while(i < m_callbacks.len() && m_cbtimes[i] < cbtime) i++;
		if(i == m_callbacks.len())
		{
			m_callbacks.push(timer);
			m_cbtimes.push(cbtime);
		}
		else
		{
			m_callbacks.insert(i,timer);
			m_cbtimes.insert(i,cbtime);
		}
	}

	m_callbacks = [];
	m_cbtimes = [];
}

class GlobalSecondsTimer extends GlobalTimer
{
	// Returns the current time in seconds (internal use)
	function GetCurrentTime() { return Time(); }
}

class GlobalFrameTimer extends GlobalTimer
{
	// Returns the current time in frames (internal use)
	function GetCurrentTime()
	{
		return m_curFrame;
	}
	/* Update()
	Checks to see which timers have elapsed and executes callbacks.
	Please run on global frame Update() function
	 */
	function Update()
	{
		// TODO: Integer overflow after 180+ hours on the round?
		m_curFrame++;
		::GlobalTimer.Update();
	}
	m_curFrame = 0;
}
