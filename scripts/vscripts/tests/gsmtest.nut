p("=================");
p("GSM Test");
p("=================");


::ArbitraryName <- {};

IncludeScript("complite/gamestate_model.nut",::ArbitraryName);

p("Loaded GameState Library");

class BasicListen extends ::ArbitraryName.GameState.GameStateListener
{
	function OnRoundStart(roundNumber) { heardRS=true; rnum=roundNumber; }
	function OnSafeAreaOpened() { heardSAO=true; }
	function OnTankEntersPlay() { heardTEP=true; }
	function OnTankLeavesPlay() { heardTLP=true; }
	function OnSpawnPCZ(id) { heardSPCZ=true; SPCZid = id; heardSPCZBeforeSPCZ2 = !heardSPCZ2; }
	function OnSpawnedPCZ(id) { heardSPCZ2=true; SPCZ2id = id; }
	function OnGetDefaultItem(idx) { heardGDI= true; GDIid=idx; }
	function OnAllowWeaponSpawn(classname) { heardAWS=true; AWSclass=classname; }
	function OnConvertWeaponSpawn(classname) { heardCWS=true; CWSclass=classname; }
	
	function Reset()
	{
		heardRS=false;
		rnum=null;
		heardSAO=false;
		heardTEP=false;
		heardTLP=false;
		heardSPCZ=false;
		SPCZid=null;
		heardSPCZ2=false;
		SPCZ2id=null;
		heardSPCZBeforeSPCZ2=false;
		heardGDI=false;
		GDIid=null;
		heardAWS=false;
		AWSclass=null;
		heardCWS=false;
		CWSclass=null;
	}
	heardRS=false;
	rnum=null;
	heardSAO=false;
	heardTEP=false;
	heardTLP=false;
	heardSPCZ=false;
	SPCZid=null;
	heardSPCZ2=false;
	SPCZ2id=null;
	heardSPCZBeforeSPCZ2=false;
	heardGDI=false;
	GDIid=null;
	heardAWS=false;
	AWSclass=null;
	heardCWS=false;
	CWSclass=null;
};


//local myGSM = ::ArbitraryName.GameState.GameStateModel(myGSC, Director);

function TestGSC()
{
	local myGSC = ::ArbitraryName.GameState.GameStateController();
	local lstnr = BasicListen();
	print("Testing GSC with Basic listener...");
	myGSC.AddListener(lstnr);

	myGSC.TriggerRoundStart(1);
	assert(lstnr.heardRS);
	myGSC.TriggerSafeAreaOpen();
	assert(lstnr.heardSAO);
	myGSC.TriggerTankEntersPlay();
	assert(lstnr.heardTEP);
	myGSC.TriggerTankLeavesPlay();
	assert(lstnr.heardTLP);
	assert(myGSC.TriggerPCZSpawn(4) == 4);
	assert(lstnr.heardSPCZ);
	assert(lstnr.heardSPCZ2);
	assert(lstnr.heardSPCZBeforeSPCZ2);
	assert(lstnr.SPCZid == 4);
	assert(lstnr.SPCZ2id == 4);
	
	assert(myGSC.TriggerAllowWeaponSpawn("weapon_rifle_m60") == true);
	assert(lstnr.heardAWS);
	assert(lstnr.AWSclass == "weapon_rifle_m60");
	assert(myGSC.TriggerConvertWeaponSpawn("weapon_smg") == 0);
	assert(lstnr.heardCWS);
	assert(lstnr.CWSclass == "weapon_smg");
	assert(myGSC.TriggerGetDefaultItem(0) == 0);
	assert(lstnr.heardGDI);
	assert(lstnr.GDIid == 0);
	p("Passed.");
}

TestGSC();
