#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_traps;
#using scripts\zm\_zm_utility;
#using scripts\shared\vehicles\_auto_turret;
#using scripts\shared\vehicle_shared;
#using scripts\shared\vehicle_ai_shared;
#using scripts\shared\ai\zombie_death;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_traps.gsh;
#insert scripts\zm\_hb21_sym_zm_trap_turret.gsh;

#namespace hb21_sym_zm_trap_turret;

REGISTER_SYSTEM( "hb21_sym_zm_trap_turret", &__init__, undefined )
	
function __init__()
{
	zm_spawner::register_zombie_death_event_callback( &turret_trap_death_event );
	zm::register_vehicle_damage_callback( &turret_trap_damage_event_vehicle );
	zm::register_actor_damage_callback( &turret_trap_damage_event );
	
	vehicle::add_main_callback( "veh_bo3_turret_zmtrap", &auto_turret::turret_initialze );
	zm_traps::register_trap_basic_info( TURRET_TRAP_SCRIPT_NOTEWORTHY, &turret_trap_activate, undefined );
}

function turret_trap_activate()
{	
	a_targets = getEntArray( self.target, "targetname" );
	for ( i = 0; i < a_targets.size; i++ )
		if ( isVehicle( a_targets[ i ] ) )
		{
			a_targets[ i ] vehicle_ai::TurnOn();
			playSoundAtPosition( "amb_turret_start", a_targets[ i ].origin );
			a_targets[ i ] playLoopSound( "amb_turret_loop", .5 );
		}
		
	self._trap_duration = TURRET_TRAP_DURATION;
	self._trap_cooldown_time = TURRET_TRAP_COOLDOWN;

	self notify( "trap_activate" );
	level notify( "trap_activate", self );
	       	
	self util::waittill_notify_or_timeout( "trap_deactivate", self._trap_duration );

	for ( i = 0; i < a_targets.size; i++ )
		if ( isVehicle( a_targets[ i ] ) )
		{
			a_targets[ i ] vehicle_ai::TurnOff();
			playSoundAtPosition( "amb_turret_end", a_targets[ i ].origin );
			a_targets[ i ] stopLoopSound( .5 );
		}
	
	self notify( "trap_done" );
}

function turret_trap_damage_event_vehicle( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type )
{
	if ( isDefined( w_weapon ) && w_weapon.name == "auto_turret_weapon" )
	{
		if ( IS_TRUE( self.b_immune_to_turret_trap ) )
			return 0;
		
	}
	return -1;
}

function turret_trap_damage_event( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_offset_time, n_bone_index, str_surface_type )
{
	if ( isDefined( w_weapon ) && w_weapon.name == "auto_turret_weapon" )
	{
		if ( IS_TRUE( self.b_immune_to_turret_trap ) )
			return 0;
		
	}
	return -1;
}

function turret_trap_death_event( e_attacker )
{
	if ( isDefined( e_attacker ) && isDefined( e_attacker.vehicletype ) && e_attacker.vehicletype == "veh_bo3_turret_zmtrap" )
	{
		e_trap = getEnt( e_attacker.targetname, "target" );
		level notify( "trap_kill", self, e_trap );
	}
}