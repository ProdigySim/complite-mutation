//-----------------------------------------------------
Msg("Activating Mutation CompLite\n");

DirectorOptions <-
{
	ActiveChallenge = 1
	
	cm_ProhibitBosses = 0
	cm_AllowPillConversion = 0
	
//	cached_tank_state = 0
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
        weapon_hunting_rifle    = "weapon_shotgun_chrome_spawn"
		weapon_sniper_military	= "weapon_hunting_rifle_spawn"
		weapon_sniper_awp 		= "weapon_hunting_rifle_spawn"
		weapon_sniper_scout     = "weapon_shotgun_chrome_spawn"
        weapon_first_aid_kit    = "weapon_pain_pills_spawn"
	}

	function ConvertWeaponSpawn( classname )
	{
        if ( classname in weaponsToConvert )
		{
            //Msg("Converting"+classname+" to "+weaponsToConvert[classname]+"\n")
			return weaponsToConvert[classname];
		}
		return 0;
	}

    // 0: Always remove
    // >0: Keep the first n instances, delete others
    // <-1: Delete the first n instances, keep others.
	weaponsToRemove =
	{
		weapon_defibrillator = 0
		weapon_grenade_launcher = 0
		weapon_upgradepack_incendiary = 0
		weapon_upgradepack_explosive = 0
		weapon_chainsaw = 0
        weapon_molotov = 1
        weapon_pipe_bomb = 1
        weapon_vomitjar = 1
        weapon_propanetank = 0
        weapon_oxygentank = 0
		weapon_rifle_m60 = 0
        weapon_first_aid_kit = -5
		upgrade_item = 0
	}	

	function AllowWeaponSpawn( classname )
	{
		new_round_start = 1
		round_start_time = Time()

		if ( classname in weaponsToRemove )
		{
            if(weaponsToRemove[classname] > 0)
            {
                //Msg("Found a "+classname+" to keep, "+weaponsToRemove[classname]+" remain.\n");
                weaponsToRemove[classname]--
            }
            else if (weaponsToRemove[classname] < -1)
            {
               // Msg("Killing just one "+classname+"\n");
                weaponsToRemove[classname]++
                return false;
            }
            else if (weaponsToRemove[classname] == 0)
			{
                //Msg("Removed "+classname+"\n")
                return false;
            }
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
        Msg("Complite OnRoundStart()\n");
        
        
        // We do a roundstart remove of these items to keep the removals from being too greedy. Health items are odd.
        // Melee weapons work better here, too. Plus we get the chance to set their count!
        weaponsToRemove <- {
            weapon_adrenaline_spawn = 3
            weapon_pain_pills_spawn = 6
            weapon_melee_spawn = 4
        }
        ent <- Entities.First();
        entcnt<-1;
        classname <- ""
        while(ent != null)
        {
                classname = ent.GetClassname()
                //Msg(entcnt+". "+classname+"\n");
                if(classname == "func_playerinfected_clip")
                {
                    //Msg("Killing...\n");
                    DoEntFire("!activator", "kill", "", 0, ent, null);
                } else if (classname in weaponsToRemove)
                {
                    if(weaponsToRemove[classname] > 0)
                    {
                        //Msg("Found a "+classname+" to keep, "+(weaponsToRemove[classname]-1)+" remain.\n");
                        weaponsToRemove[classname]--
                        if(classname == "weapon_melee_spawn")
                        {
                            ent.__KeyValueFromInt("count", 1);
                        }
                    }
                    else
                    {
                        //Msg("Removed "+classname+"\n")
                        DoEntFire("!activator", "kill", "", 0, ent, null);
                    }
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
    /* This was fun, but wasn't useful */
	/*
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
    */
}
