#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_perk_phd_flopper.gsh;

#namespace zm_perk_phd_flopper;

REGISTER_SYSTEM( "zm_perk_phd_flopper", &__init__, undefined )

function __init__()
{
	// register custom functions for hud/lua
	zm_perks::register_perk_clientfields( PERK_PHDFLOPPER, &phd_flopper_client_field_func, &phd_flopper_code_callback_func );
	zm_perks::register_perk_effects( PERK_PHDFLOPPER, PHD_FLOPPER_FX_MACHINE_LIGHT );
	zm_perks::register_perk_init_thread( PERK_PHDFLOPPER, &init_phd_flopper );
	visionset_mgr::register_visionset_info(PHD_FLOPPER_VISION, 9000, 5, PHD_FLOPPER_VISION, PHD_FLOPPER_VISION );
}


function init_phd_flopper()
{
	if( IS_TRUE(level.enable_magic) )
	{
		level._effect[PHD_FLOPPER_FX_MACHINE_LIGHT]	= PHD_FLOPPER_FX_FILE_MACHINE_LIGHT;
	}
}


function phd_flopper_client_field_func()
{
	clientfield::register( "clientuimodel", PERK_CLIENTFIELD_PHDFLOPPER, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT ); 
}

function phd_flopper_code_callback_func()
{
}