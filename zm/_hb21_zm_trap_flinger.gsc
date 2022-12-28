#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_playerhealth;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_traps;
#using scripts\zm\_zm_utility;
#using scripts\shared\ai\zombie_death;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_traps.gsh;
#insert scripts\zm\_hb21_zm_trap_flinger.gsh;

#using_animtree( "generic" );

#namespace hb21_zm_trap_flinger;

REGISTER_SYSTEM( "hb21_zm_trap_flinger", &__init__, undefined )
	
function __init__()
{
	zm_traps::register_trap_basic_info( FLINGER_TRAP_SCRIPT_NOTEWORTHY, &flinger_trap_activate, undefined );
}

function flinger_trap_activate()
{	
	self._trap_duration = FLINGER_TRAP_DURATION;
	self._trap_cooldown_time = FLINGER_TRAP_COOLDOWN;

	self thread flinger_trap_damage_loop();
	
	self util::waittill_notify_or_timeout( "trap_deactivate", self._trap_duration );
		
	self notify ( "trap_done" );
}

function flinger_trap_damage_loop()
{	
	self endon( "trap_done" );

	while ( isDefined( self ) )
	{
		self waittill( "trigger", e_ent );
		
		if ( !isDefined( e_ent ) || ( isDefined( e_ent.sessionstate ) && IS_TRUE( e_ent.sessionstate == "spectator" ) ) || isDefined( e_ent.marked_for_death ) || IS_TRUE( e_ent.b_immune_to_flinger_trap ) )
			continue;
		
		self._trap_movers[ 0 ] useAnimTree( #animtree );
		
		self._trap_movers[ 0 ] animScripted( "p7_fxanim_zm_stal_flinger_trap_anim", self._trap_movers[ 0 ].origin, self._trap_movers[ 0 ].angles, %p7_fxanim_zm_stal_flinger_trap_anim );
		
		self flinger_trap_fling( self );
		wait getAnimLength( "p7_fxanim_zm_stal_flinger_trap_anim" );
	}
}

function flinger_trap_kill_zombie( v_origin, v_angle )
{
	if ( isAlive( self ) || ( isDefined( self.health ) && self.health > 0 ) )
		v_launch = ( v_angle * 300 ) + ( 0, 0, randomIntRange( 100, 300 ) );
	
	if ( !self isRagdoll() )
		self startRagDoll();
	
	self launchRagdoll( v_launch );
	self zombie_utility::gib_random_parts();
	self doDamage( self.health + 666, self.origin );
}

function flinger_trap_fling( e_trap )
{	
	level thread flinger_trap_launch_players( self, self._trap_movers[ 0 ] );	
	
	a_zombies = zombie_utility::get_round_enemy_array();
	for ( i = 0; i < a_zombies.size; i++ )
	{
		if ( a_zombies[ i ] isTouching( self ) )
		{
			if ( !IS_TRUE( a_zombies[ i ].b_immune_to_flinger_trap ) )
			{
				playSoundAtPosition( "wpn_thundergun_proj_impact", a_zombies[ i ].origin );
				a_zombies[ i ] thread flinger_trap_kill_zombie( self._trap_movers[ 0 ].origin, anglesToRight( self._trap_movers[ 0 ].angles + ( 0, 180, 0 ) ) );
				
				level notify( "trap_kill", a_zombies[ i ], e_trap );
				
				if ( isDefined( e_trap.activated_by_player ) && isPlayer( e_trap.activated_by_player ) )
					e_trap.activated_by_player zm_stats::increment_challenge_stat( "ZOMBIE_HUNTER_KILL_TRAP" );
	
			}
		}		
	}
}
	
function flinger_trap_launch_players( e_trap, e_gate )
{
	a_launch_spots = struct::get_array( e_trap.target, "targetname" );

	a_players = getPlayers();
	for ( i = 0; i < a_players.size; i++ )
	{
		if ( IS_TRUE( a_players[ i ]._being_flung ) || IS_TRUE( a_players[ i ].sessionstate == "spectator" ) )
			continue;
				
		if ( a_players[ i ] isTouching( e_trap ) )
		{	
			a_players[ i ] thread flinger_trap_launch_player( a_launch_spots[ i ], int( e_trap.script_parameters ) );
			playSoundAtPosition( "wpn_thundergun_proj_impact", a_players[ i ].origin );
		}
	}
}

function flinger_trap_launch_player( s_launch_spot, v_forward_velocity )
{
	self endon( "death_or_disconnect" );

	self zm_playerhealth::player_health_visionset();
	
	WAIT_SERVER_FRAME;		
			
	self setOrigin( s_launch_spot.origin );
	self setVelocity( ( anglesToForward( s_launch_spot.angles ) * v_forward_velocity ) + ( anglesToUp( s_launch_spot.angles ) * 800 ) );
}