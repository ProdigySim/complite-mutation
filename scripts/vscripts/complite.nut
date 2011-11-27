//-----------------------------------------------------
Msg("Activating Mutation CompLite\n");

DirectorOptions <-
{
	ActiveChallenge = 1
	
	cm_ProhibitBosses = 0
	cm_AllowPillConversion = 0
	
	cached_tank_state = 0
	new_round_start = 0
	round_start_time = 0

	weaponsToConvert =
	{
		weapon_autoshotgun 		= "weapon_pumpshotgun_spawn"
		weapon_shotgun_spas 	= "weapon_shotgun_chrome_spawn"
		weapon_rifle			= "weapon_smg_spawn"
		weapon_rifle_desert		= "weapon_smg_spawn"
		weapon_rifle_sg552		= "weapon_smg_mp5_spawn"
		weapon_rifle_ak47		= "weapon_smg_silenced_spawn"
		weapon_sniper_military	= "weapon_hunting_rifle_spawn"
		weapon_sniper_awp 		= "weapon_hunting_rifle_spawn"
		weapon_sniper_scout     = "weapon_hunting_rifle_spawn"
	}

	function ConvertWeaponSpawn( classname )
	{
		if ( classname in weaponsToConvert )
		{
			return weaponsToConvert[classname];
		}
		return 0;
	}

	weaponsToRemove =
	{
		weapon_defibrillator = 0
		weapon_grenade_launcher = 0
		weapon_upgradepack_incendiary = 0
		weapon_upgradepack_explosive = 0
		weapon_chainsaw = 0
		weapon_first_aid_kit = 0
		weapon_rifle_m60 = 0
		upgrade_item = 0
	}	

	function AllowWeaponSpawn( classname )
	{
		new_round_start = 1
		round_start_time = Time()

		if ( classname in weaponsToRemove )
		{
			return false;
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
		if ( idx < DefaultItems.len() )
		{
			return DefaultItems[idx];
		}
		return 0;
	}

}

function OnRoundStart()
{
        Msg("Complite OnRoundStart()");
        
        DirectorOptions.SpitterLimit = 1
        
        ent <- Entities.First();
        entcnt<-1;
        while(ent != null)
        {
                Msg(entcnt+". "+ent.GetClassname()+"\n");
                if(ent.GetClassname() == "func_playerinfected_clip")
                {
                    Msg("Killing...\n");
                    DoEntFire("!activator", "kill", "", 0, ent, null);
                }
                ent=Entities.Next(ent);
                entcnt++;
        }
}


function Update()
{
	if(DirectorOptions.new_round_start == 1 && DirectorOptions.round_start_time < Time()-1)
	{
		DirectorOptions.new_round_start = 0
		OnRoundStart()		
	}
	if(Director.IsTankInPlay() && DirectorOptions.cached_tank_state == 0)
	{
        Msg("Tank Spawned\n");
		DirectorOptions.cached_tank_state = 1
	}
	else if(!Director.IsTankInPlay() && DirectorOptions.cached_tank_state == 1)
	{
        Msg("Tank Left Play\n");
		DirectorOptions.cached_tank_state = 0
	}
}
