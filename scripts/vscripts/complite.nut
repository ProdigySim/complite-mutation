//-----------------------------------------------------
Msg("Activating Mutation CompLite\n");

DirectorOptions <-
{
	ActiveChallenge = 1
	
	cm_ProhibitBosses = 0
	cm_AllowPillConversion = 0
	
	cp_thar_be_weapons_to_convert = 0
	cp_get_default_item_cnt = 0
	cp_weapon_sighted_time = 0
	
	weaponsToConvert =
	{
		weapon_autoshotgun 		= "weapon_pumpshotgun_spawn"
		weapon_shotgun_spas 	= "weapon_shotgun_chrome_spawn"
		weapon_rifle			= "weapon_smg_spawn"
		weapon_rifle_desert		= "weapon_smg_spawn"
		weapon_rifle_sg552		= "weapon_smg_mp5_spawn"
		weapon_rifle_ak47		= "weapon_smg_silenced_spawn"
		weapon_sniper_military	= "weapon_hunting_rifle_spawn"
		weapon_sniper_awp 		= "weapon_sniper_scout_spawn"
	}

	function ConvertWeaponSpawn( classname )
	{
//		Msg("Found an instance of "+classname+"\n");
		if ( classname in weaponsToConvert )
		{
//			Msg("Converting to "+weaponsToConvert[classname]+"\n");
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
		if ( classname in weaponsToConvert )
		{
			Msg("Despised "+classname+" is about to spawn at "+Time()+"!\n");
			cp_thar_be_weapons_to_convert = 1
			cp_weapon_sighted_time = Time()
		}
		return true;
	}		

	DefaultItems =
	[
		"weapon_pain_pills",
		"weapon_pistol",
	]
	DefaultMainWeapon = 
	[
		"weapon_smg",
		"weapon_smg",
		"weapon_smg_silenced",
		"weapon_shotgun_chrome",
	]

	
	function GetDefaultItem( idx )
	{
		//Msg("GetDefaultItem called with idx "+idx+"\n");
		if ( idx < DefaultItems.len() )
		{
			return DefaultItems[idx];
		} else if (idx == 2)
		{
			return DefaultMainWeapon[cp_get_default_item_cnt++ % 4];
		}
		return 0;
	}

}


function OnRoundStart()
{
	Msg("Complite OnRoundStart()");
	ent <- Entities.First();
	entcnt<-1;
	while(ent != null)
	{
		classname<-ent.GetClassname();
		if ( classname == "weapon_spawn" )
		{
			Msg(entcnt+". "+classname+" to junk\n");
			//EntFire(ent, "kill");
			//ent.__KeyValueFromString("model", "mymodel");
			//ent.__KeyValueFromString("classname", 
		}
		ent=Entities.Next(ent);
		entcnt++;
	}
}
function Update()
{
	if ( DirectorOptions.cp_thar_be_weapons_to_convert == 1 && DirectorOptions.cp_weapon_sighted_time < Time()-1 )
	{
		DirectorOptions.cp_thar_be_weapons_to_convert = 0;
		Msg("Going to remove weapons at "+Time()+"\n");
		OnRoundStart()
	}
}
