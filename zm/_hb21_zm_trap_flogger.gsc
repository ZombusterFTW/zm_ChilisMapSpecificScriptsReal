#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_traps;
#using scripts\zm\_zm_utility;
#using scripts\shared\ai\zombie_death;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_traps.gsh;
#insert scripts\zm\_hb21_zm_trap_flogger.gsh;

#precache( "model", FLOGGER_TRAP_BELT_OFF_MODEL );
#precache( "model", FLOGGER_TRAP_BELT_ON_MODEL );

#namespace hb21_zm_trap_flogger;

REGISTER_SYSTEM( "hb21_zm_trap_flogger", &__init__, undefined )
	
function __init__()
{
	zm_traps::register_trap_basic_info( FLOGGER_TRAP_SCRIPT_NOTEWORTHY, &flogger_trap_activate, undefined );
}

function flogger_trap_activate()
{	
	self._trap_duration = FLOGGER_TRAP_DURATION;
	self._trap_cooldown_time = FLOGGER_TRAP_COOLDOWN;

	self enableLinkTo();
	self linkTo( self._trap_movers[ 0 ] );
	
	a_targets = getEntArray( self.target, "targetname" );
	for ( i = 0; i < a_targets.size; i++ )
		if ( a_targets[ i ].script_noteworthy == "belt" )
		{
			a_targets[ i ] setModel( FLOGGER_TRAP_BELT_ON_MODEL );
			playSoundAtPosition( "evt_motor_start", a_targets[ i ].origin );
			a_targets[ i ] playLoopSound( "evt_motor_loop", .5 );
		}
		else if ( a_targets[ i ].script_noteworthy == "mover" )
			a_targets[ i ] playLoopSound( "evt_cent_lowend_loop", .5 );
	
	self thread flogger_trap_damage_loop();
	
	for ( i = 0; i < self._trap_movers.size; i++ )
		self._trap_movers[ i ] RotatePitch( int( self._trap_duration * 360 ), self._trap_duration, 6, 6 );
	
	self util::waittill_notify_or_timeout( "trap_deactivate", self._trap_duration );
	
	self unLink();
	for ( i = 0; i < a_targets.size; i++ )
		if ( a_targets[ i ].script_noteworthy == "belt" )
		{
			a_targets[ i ] setModel( FLOGGER_TRAP_BELT_OFF_MODEL );
			playSoundAtPosition( "evt_motor_stop", a_targets[ i ].origin );
			a_targets[ i ] stopLoopSound( .5 );
		}
		else if ( a_targets[ i ].script_noteworthy == "mover" )
			a_targets[ i ] stopLoopSound( .5 );
		
	self notify( "trap_done" );
}

function flogger_trap_damage_loop()
{	
	self endon( "trap_done" );

	while ( 1 )
	{
		self waittill( "trigger", e_ent );
		
		if ( !isDefined( e_ent ) || ( isDefined( e_ent.sessionstate ) && IS_TRUE( e_ent.sessionstate == "spectator" ) ) || IS_TRUE( e_ent.marked_for_death ) || IS_TRUE( e_ent.b_immune_to_flogger_trap ) )
			continue;
		
		if ( isPlayer( e_ent ) )
		{
			if ( e_ent getStance() == "stand" )
			{
				e_ent doDamage( 50, e_ent.origin + ( 0, 0, 20 ) );
				e_ent setStance( "crouch" );
			}
		}
		else
			e_ent thread flogger_trap_kill_zombie( self );

	}
}

function flogger_trap_kill_zombie( e_trap )
{
	playSoundAtPosition ( "wpn_thundergun_proj_impact", self.origin );
	
	if ( isDefined( self.ptr_flogger_trap_reaction_func ) )
	{
		self [ [ self.ptr_flogger_trap_reaction_func ] ]( e_trap );
		return;
	}
	else if ( isDefined( self.trap_reaction_func ) )
	{
		self [ [ self.trap_reaction_func ] ]( e_trap );
		return;
	}
	
	self.marked_for_death = 1;

	v_ang = vectorToAngles( e_trap.origin - self.origin );
	
	v_direction_vec = vectorScale( anglesToForward( v_ang + ( 0, 180, 0 ) ), 200 );

	level notify( "trap_kill", self, e_trap );
	
	self thread zombie_utility::gib_random_parts();
	
	self startRagdoll();
	self launchRagdoll( v_direction_vec );
	util::wait_network_frame();

	self doDamage( self.health, self.origin, e_trap );

	if ( isDefined( e_trap.activated_by_player ) && isPlayer( e_trap.activated_by_player ) )
		e_trap.activated_by_player zm_stats::increment_challenge_stat( "ZOMBIE_HUNTER_KILL_TRAP" );
	
}