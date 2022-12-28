#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
#using scripts\zm\_zm_trap_electric;
#using scripts\zm\zm_usermap;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_score;
#using scripts\shared\ai\zombie_shared;
#using scripts\zm\zm_giant_cleanup_mgr;
#using scripts\zm\_zm_equipment;


#using scripts\shared\vehicles\_spider;
#using scripts\zm\_zm_ai_wasp;

#using scripts\zm\zm_buried_ghost;

#using scripts\zm\zm_cellbreaker;
//#using scripts\zm\zm_dry_bowser;


#using scripts\shared\ai\mechz; 
#using scripts\zm\_electroball_grenade;
#using scripts\zm\mechz_spiki;


#using scripts\shared\ai\margwa; 
#using scripts\zm\_zm_ai_margwa; 

#using scripts\shared\ai\archetype_thrasher; 
#using scripts\shared\ai\archetype_thrasher_interface; 

#using scripts\zm\_zm_ai_raps; 

#using scripts\shared\ai\archetype_apothicon_fury; 
#using scripts\zm\zm_genesis_apothicon_fury; 

#using scripts\shared\ai\raz; 
#using scripts\shared\vehicles\_sentinel_drone;




//#using scripts\zm\zm_panzermorder;


#using_animtree("generic");
//*****************************************************************************
// MAIN
//*****************************************************************************


function choose_a_spawn(noteworthy)  ////REQUIRES ATLEAST 2 ZONES or no
{
	structs = struct::get_array( noteworthy, "targetname" );

	if(!isdefined(structs) || structs.size < 1)
		{
		IPrintLnBold("noteworthy_position");
		structs = struct::get_array( noteworthy, "script_noteworthy" );
		}

	players = getplayers(); 
	players = array::randomize( players ); 
	player = players[0]; 

	while(1)
		{
		spot = ArrayGetClosest(player.origin,structs);
		zone = zm_zonemgr::get_zone_from_position(spot.origin, 1);

			
		if(level.newzones.size < 2)
			{
			return spot;	
			}

		if(zm_zonemgr::zone_is_enabled(zone))
			{
			//IPrintLnBold("success");			
			return spot;
			}
		else
			{
			ArrayRemoveValue(structs,spot);	
			}

		if(structs.size < 1)
			break;
		}		
	IPrintLnBold( "failed "+ noteworthy +" spawn" ); 
}






function to_player_angles(s_struct) //self = slender
{
target = ArrayGetClosest(self.origin,GetPlayers());

v_to_enemy = FLAT_ORIGIN( (target.origin - s_struct.origin) );
v_to_enemy = VectorNormalize( v_to_enemy );
goalAngles = VectortoAngles( v_to_enemy );

return goalAngles; 
}









///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
AI SPAWN FUNCTIONS
*/



#define FX_MECHZ_SPAWN "dlc4/genesis/fx_mech_spawn"
#precache( "fx", FX_MECHZ_SPAWN);

function mechz_spawn(s_struct, tomb, health)
{

if(!isDefined( s_struct ))
	s_struct = choose_a_spawn("mechz_spot");

if(!isDefined( s_struct ))
{
	IPrintLnBold( "NO VALID SPAWN POINTS FOUND" );
	return undefined;
}


spawner = GetEntArray("mechz_genesis_spawner","targetname");
if(isdefined(tomb) && tomb == 1)
	spawner = GetEntArray("mechz_tomb_spawner","targetname");


spawner = spawner[0];

if(!isdefined(spawner))
	{
	IPrintLnBold("no spawner");
	return;
	}
	

if(isdefined(tomb) && tomb == 1)
	e_ai = zombie_utility::spawn_zombie( spawner, "mechz_tomb", s_struct.origin);
else
	e_ai = zombie_utility::spawn_zombie( spawner, "mechz", s_struct.origin);



if( !isDefined( e_ai ) )
	return;
e_ai endon( "death" );
	

e_ai.no_eye_glow = 1;
//e_ai zm_spawner::zombie_spawn_init( undefined );


e_ai.is_boss = true; 
e_ai.b_ignore_cleanup = 1;


e_ai.goalradius = 32;
e_ai mechz_spiki::function_3d5df242();

e_ai PushActors( true );

e_ai.health = 1500;
if(isdefined(health))
	e_ai.health = health;


level.mechz_health = e_ai.health; //for bow


ang = e_ai to_player_angles(s_struct);


e_ai.b_flyin_done = 0;
if(isdefined(s_struct.script_string) && s_struct.script_string == "flyin")
	{
	e_ai ForceTeleport(s_struct.origin, ang, 0);
	e_ai scene::play("ai_zm_dlc1_soldat_arrive_2", e_ai );
	}
else
	{
	PlayFX(FX_MECHZ_SPAWN, s_struct.origin);
	PlaySoundAtPosition("panzer_prespawn", s_struct.origin);
	wait 0.5;
	e_ai ForceTeleport(s_struct.origin, ang, 0);
	}

e_ai.b_flyin_done = 1;

e_ai thread mechz_death();


}


function mechz_death()
{
self waittill("death");
self.attacker zm_score::player_add_points("death_mechz", 1500);

self waittill("self_explode");

self clientfield::set("mechz_fx", 1);

zm_powerups::specific_powerup_drop("full_ammo", self.origin);
}






















