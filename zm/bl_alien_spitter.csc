
#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\postfx_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_ai_wasp.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_utility;

#namespace bl_alien_spitter;


#precache( "client_fx", "custom/AI/cellbreaker_helmet" );
#precache( "client_fx", "custom/AI/cellbreaker_lamp" );

#precache( "client_model", "c_zom_cellbreaker_helmet" );

REGISTER_SYSTEM( "bl_alien_spitter", &__init__, undefined )
	
function __init__()
{
//clientfield::register( "actor", "brutus_helmet_destroy", VERSION_SHIP, 2, "int", &brutus_helmet_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );	
//clientfield::register( "actor", "brutus_lamp_fx", VERSION_SHIP, 2, "int", &brutus_lamp_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );	


}

