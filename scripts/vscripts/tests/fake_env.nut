

function p(s) { ::print(s+"\n"); }
function Msg(s) { ::print(s); }
function IncludeScript(path, env)
{
	(loadfile(path,true).bindenv(env))();
}

class ::CDirector
{
	// Wipe Director Options
	function Clear()
	{

	}

	// Get the distance between the lead and trailing survivors, smoothed over time
	function GetAveragedSurvivorSpan()
	{
		return 200.0;
	}

	// Get the rate at which the lead survivor is moving along the flow, smoothed over time
	function GetAveragedSurvivorSpeed()
	{
		return 220.0
	}

	// GetCommonInfectedCount (no longer is there a need to count another way)
	function GetCommonInfectedCount()
	{
		return 24;
	}

	// Get the maximum distance along the flow that the survivors have reached
	function GetFurthestSurvivorFlow()
	{
		return 400.0;
	}

	// Get the current game mode "versus", "coop", etc.
	function GetGameMode()
	{
		return "versus";
	}

	// Returns the number of infected waiting to spawn
	function GetPendingMobCount()
	{
		return 25;
	}

	// True when one or more survivors have left the starting safe area
	function HasAnySurvivorLeftSafeArea()
	{
		return false;
	}

	// Returns true if any survivor recently dealt or took damage
	function IsAnySurvivorInCombat()
	{
		return false;
	}

	// Returns true if player is running the client on a console like Xbox 360
	function IsPlayingOnConsole()
	{
		return false;
	}

	// Return true if game is in single player
	function IsSinglePlayerGame()
	{
		return false;
	}

	// Returns true if any tanks are aggro on survivors
	function IsTankInPlay()
	{
		return false;
	}

	// ?!?!?!?!?!?!
    function IsValid()
    {
    	return false;
    }

	// This makes l4d1 survivors give an item
	function L4D1SurvivorGiveItem()
	{

	}

	// Plays a horde scream sound and asks survivors to speak 'incoming horde' lines
	function PlayMegaMobWarningSounds()
	{

	}

	// Trigger a mob as soon as possible when in BUILD_UP (refer to director_debug 1)
	function ResetMobTimer()
	{

	}

	// Generic "user defined script event" hook that can be fired from Squirrel
	// and fires outputs on the director entity in the map, OnUserDefinedScriptEvent1-4. 
    function UserDefinedEvent1() {}
    function UserDefinedEvent2() {}
    function UserDefinedEvent3() {}
    function UserDefinedEvent4() {}
};

::Director <- ::CDirector();


class FakeTime
{
	function GetCurrentTime() { return m_time; }
	function SetCurrentTime(t) { m_time = t; }
	function IncrementTime(dt) { m_time += dt; }
	function NextTick() { IncrementTime( 1.0 / 30.0 ); }
	m_time = 0.0;
};

::g_Time <- FakeTime();

function Time() { return g_Time.GetCurrentTime(); }
function NextTick() { g_Time.NextTick(); }
function IncrementTime(dt) { g_Time.IncrementTime(dt); }
