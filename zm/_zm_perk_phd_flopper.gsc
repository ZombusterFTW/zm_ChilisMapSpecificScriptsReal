#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_perk_phd_flopper.gsh;

#precache( "fx", PHD_FLOPPER_FX_EXPLOSION );
#precache( "fx", PHD_FLOPPER_FX_MACHINE_LIGHT );
#precache( "fx", PHD_FLOPPER_FX_FILE_MACHINE_LIGHT );

#namespace zm_perk_phd_flopper;

REGISTER_SYSTEM( "zm_perk_phd_flopper", &__init__, undefined )

function __init__()
{
	zm_perks::register_perk_basic_info( PERK_PHDFLOPPER, PHD_FLOPPER_NAME, PHD_FLOPPER_PERK_COST, &"ZM_CUSTOM_PERK_DIVETONUKE", GetWeapon( PHD_FLOPPER_PERK_BOTTLE_WEAPON) );
	zm_perks::register_perk_precache_func( PERK_PHDFLOPPER, &phd_flopper_precache );
	zm_perks::register_perk_clientfields( PERK_PHDFLOPPER, &phd_flopper_register_clientfield, &phd_flopper_set_clientfield );
	zm_perks::register_perk_machine( PERK_PHDFLOPPER, &phd_flopper_perk_machine_setup );
	zm_perks::register_perk_host_migration_params( PERK_PHDFLOPPER, PHD_FLOPPER_RADIANT_MACHINE_NAME, PHD_FLOPPER_FX_MACHINE_LIGHT );
	zm_perks::register_perk_threads( PERK_PHDFLOPPER, &phd_flopper_perk_init, &phd_flopper_perk_lost );
	visionset_mgr::register_info("visionset", PHD_FLOPPER_VISION, 9000, 400, 5, 1 );
}

function phd_flopper_precache()
{
	if( isdefined(level.phd_flopper_precache_override_func) )
	{
		[[ level.phd_flopper_precache_override_func ]]();
		return;
	}
	
	level._effect[ PHD_FLOPPER_FX_MACHINE_LIGHT ]	= PHD_FLOPPER_FX_FILE_MACHINE_LIGHT;
		
	level.machine_assets[PERK_PHDFLOPPER] = SpawnStruct();
	level.machine_assets[PERK_PHDFLOPPER].weapon = GetWeapon( PHD_FLOPPER_PERK_BOTTLE_WEAPON );
	level.machine_assets[PERK_PHDFLOPPER].off_model = PHD_FLOPPER_MACHINE_DISABLED_MODEL;
	level.machine_assets[PERK_PHDFLOPPER].on_model = PHD_FLOPPER_MACHINE_ACTIVE_MODEL;
}

function phd_flopper_register_clientfield()
{
	clientfield::register( "clientuimodel", PERK_CLIENTFIELD_PHDFLOPPER, VERSION_SHIP, 2, "int" );
}

function phd_flopper_set_clientfield( state )
{
	self clientfield::set_player_uimodel( PERK_CLIENTFIELD_PHDFLOPPER, state );
}

function phd_flopper_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound	= "mus_perks_flopper_jingle";
	use_trigger.script_string	= "phd_flopper_perk";
	use_trigger.script_label	= "mus_perks_flopper_sting";
	use_trigger.target			= "vending_dive2nuke";
	perk_machine.script_string	= "phd_flopper_perk";
	perk_machine.targetname		= "vending_dive2nuke";
	
	if( isdefined( bump_trigger ) )
	{
		bump_trigger.script_string = "phd_flopper_perk";
	}
}

function phd_flopper_perk_init()
{
	self endon("death");
	self endon("disconnect");

	level.explosion_vision_time = undefined;

	zm_perks::register_perk_damage_override_func( &divetonuke_fall_damage_overide );

	// WW (08/23/2019): Added new visionset stuff, at top.

	if (self HasPerk( PERK_PHDFLOPPER ))
	{
		divetonuke_look_for_fall();
	}

	// precache the effect
	level._effect["divetonuke_groundhit"] = PHD_FLOPPER_FX_EXPLOSION;
	divetonuke_fall_damage_overide();
}

function divetonuke_fall_damage_overide( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	self endon("death");
	self endon("disconnect");

	if( sMeansOfDeath == "MOD_PROJECTILE" || sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_GRENADE" || sMeansOfDeath == "MOD_GRENADE_SPLASH" || sMeansOfDeath == "MOD_SUICIDE" )
	{
		// check for reduced damage from flak jacket perk
		if ( self HasPerk( PERK_PHDFLOPPER ) )
		{
			return 0;
		}
	}
}

function divetonuke_look_for_fall()
{
	self endon("death");
	self endon("disconnect");

	while ( 1 )
	{
		while ( self IsOnGround() )
			WAIT_SERVER_FRAME;
		
		start_z = self.origin[ 2 ];
		
		while ( !self IsOnGround() )
			WAIT_SERVER_FRAME;
		
		did_slide = 0;
		for ( i = 0; i < 2; i++ )
		{
			if ( self IsSliding() )
			{
				did_slide = 1;
				break;
			}
			WAIT_SERVER_FRAME;
		}
		
		if ( !did_slide && !IS_TRUE( self.ice_slamming ) )
			continue;
		
		z_difference = start_z - self.origin[ 2 ];
		
		if ( z_difference > 50 )
		divetonuke_explode();
	}
}

function divetonuke_explode()
{
	// radius damage
	RadiusDamage( self.origin, PHD_FLOPPER_RADIUS, PHD_FLOPPER_MAX_DAMAGE, PHD_FLOPPER_MIN_DAMAGE, self, "MOD_GRENADE_SPLASH" );


	self visionset_mgr::activate("visionset", PHD_FLOPPER_VISION, self);
	
	// play fx
	PlayFX( PHD_FLOPPER_FX_EXPLOSION, self.origin );

	// play sound
	self playsound(PHD_FLOPPER_EXPLOSION_SOUND);
	
	// WW (08/23/19): Addded visionset support
	// 
	WAIT_SERVER_FRAME;
	WAIT_SERVER_FRAME;
	self visionset_mgr::deactivate("visionset", PHD_FLOPPER_VISION, self);
}

//////////////////////////////////////////////////////////////
//Perk lost func
//////////////////////////////////////////////////////////////
function phd_flopper_perk_lost( b_pause, str_perk, str_result )
{
	self notify( PERK_PHDFLOPPER + "_stop" );
}