::SomeOtherName <- {};

p("=================");
p("GlobalTimers Test");
p("=================");
IncludeScript("complite/globaltimers.nut",::SomeOtherName);

p("Loaded Timers Library");


class ListenCB extends SomeOtherName.Timers.TimerCallback
{
	function OnTimerElapsed() { hitcallback = true; }
	function HasCallbackBeenHit() { return hitcallback; }
	function Reset() { hitcallback = false; }
	hitcallback = false;
};

function TestSecondsTimer()
{
	print("Testing GlobalSecondsTimer...");
	local myTimer = SomeOtherName.Timers.GlobalSecondsTimer();
	
	assert(myTimer.GetCurrentTime() == Time());
	
	local myCB = ListenCB();
	
	myTimer.AddTimer(0.1, myCB);
	
	assert(!myCB.HasCallbackBeenHit());
	myTimer.Update();
	assert(!myCB.HasCallbackBeenHit());
	IncrementTime(0.09);
	myTimer.Update();
	assert(!myCB.HasCallbackBeenHit());
	IncrementTime(0.01);
	myTimer.Update();
	assert(myCB.HasCallbackBeenHit());
	
	myCB.Reset();

	local myCB2 = ListenCB();

	myTimer.Update();
	assert(!myCB.HasCallbackBeenHit());
	myTimer.AddTimer(0.01, myCB);
	myTimer.AddTimer(0.005, myCB2);
	assert(!myCB.HasCallbackBeenHit());
	assert(!myCB2.HasCallbackBeenHit());
	myTimer.Update();
	assert(!myCB.HasCallbackBeenHit());
	assert(!myCB2.HasCallbackBeenHit());
	NextTick()
	myTimer.Update();
	assert(myCB.HasCallbackBeenHit());
	assert(myCB2.HasCallbackBeenHit());

	myTimer.Update();

	p("Passed.");
}

function TestFrameTimer()
{
	print("Testing GlobalFrameTimer...");
	local myTimer = SomeOtherName.Timers.GlobalFrameTimer();
	
	assert(myTimer.GetCurrentTime() == 0);
	
	local myCB = ListenCB();
	
	myTimer.AddTimer(2, myCB);
	
	assert(!myCB.HasCallbackBeenHit());
	myTimer.Update();
	assert(!myCB.HasCallbackBeenHit());
	myTimer.Update();
	assert(myCB.HasCallbackBeenHit());

	myCB.Reset();

	myTimer.AddTimer(1, myCB);
	
	assert(!myCB.HasCallbackBeenHit());
	myTimer.Update();
	assert(myCB.HasCallbackBeenHit());
	
	myCB.Reset();

	local myCB2 = ListenCB();

	myTimer.Update();
	assert(!myCB.HasCallbackBeenHit());
	myTimer.AddTimer(2, myCB);
	myTimer.AddTimer(1, myCB2);
	assert(!myCB.HasCallbackBeenHit());
	assert(!myCB2.HasCallbackBeenHit());
	myTimer.Update();
	assert(!myCB.HasCallbackBeenHit());
	assert(myCB2.HasCallbackBeenHit());
	myTimer.Update();
	assert(myCB.HasCallbackBeenHit());
	assert(myCB2.HasCallbackBeenHit());

	myTimer.Update();

	p("Passed.");
}


TestSecondsTimer();
TestFrameTimer();