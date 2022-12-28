#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
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

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;




#using scripts\shared\vehicles\_spider;
#using scripts\zm\_zm_ai_wasp;


#using scripts\zm\zm_cellbreaker;


#using scripts\shared\ai\mechz; 
#using scripts\zm\_electroball_grenade;
#using scripts\zm\mechz_spiki;

#using scripts\shared\ai\margwa; 

#using scripts\shared\ai\archetype_thrasher; 

#using scripts\zm\_zm_ai_raps; 

#using scripts\shared\ai\archetype_apothicon_fury; 
#using scripts\zm\zm_genesis_apothicon_fury; 

#using scripts\shared\ai\raz; 
#using scripts\shared\vehicles\_sentinel_drone;





function main()
{
	//callback::on_localplayer_spawned( &ent_count );


	zm_usermap::main();

	include_weapons();
	
	util::waitforclient( 0 );
}

function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}




function ent_count( n_local_client_num )
{
    
    while(1)
        {
            n_current_entity_count = 0;
            for ( i = 0; i < 24; i++ )
            {
                a_array = undefined;
                a_array = getEntArrayByType( n_local_client_num, i );
                if ( isDefined( a_array ) && isArray( a_array ) && a_array.size > 0 )
                    n_current_entity_count += a_array.size;
                    
            }
            iPrintLnBold( "CURRENT ENTITY COUNT : " + n_current_entity_count );
         wait 2;
        }
}