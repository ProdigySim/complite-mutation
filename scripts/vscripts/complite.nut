//-----------------------------------------------------
Msg("Activating Mutation CompLite\n");

DirectorOptions <-
{
	ActiveChallenge = 1
	
	cm_ProhibitBosses = 0
	cm_AllowPillConversion = 0
	
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
	}	

	function AllowWeaponSpawn( classname )
	{
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



