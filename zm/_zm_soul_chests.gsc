/*#===================================================================###
###                                                                   ###
###                                                                   ###
###              Harry Bo21s Black Ops 3 Soul Chests v2.0.0	          ###
###                                                                   ###
###                                                                   ###
###===================================================================#*/
/*=======================================================================

								CREDITS

=========================================================================
Harry Bo21
Lilrifa
Yen466
Madgaz
Yen
Easyskanka
ProRevenge
DTZxPorter
Zeroy
StevieWonder87
BluntStuffy
RedSpace200
thezombieproject
Smasher248
JiffyNoodles
MZSlayer
AndyWhelen
HitmanVere
ProGamerzFTW
Scobalula
GerardS0406
PCModder
IperBreach
TomBMX
Treyarch and Activision
AllModz
=======================================================================*/
#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_harrybo21_utility;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_soul_chests.gsh;

#precache( "model", SOULCHEST_MODEL );

#precache( "xanim", SOULCHEST_OPEN );
#precache( "xanim", SOULCHEST_CLOSE );
#precache( "xanim", PYRAMID_OPEN );

#precache( "fx", SOULCHEST_TRAIL_FX );
#precache( "fx", SOULCHEST_FIRE_FX );
#precache( "fx", SOULCHEST_COLLECT_FX );
#precache( "fx", PYRAMID_COMPLETE_FX );

#using_animtree( "soul_box" );

#namespace zm_soul_chest;

REGISTER_SYSTEM( "zm_soul_chest", &__init__, undefined )

/* 
INITIALIZE 
Description : This function calls our main functionality to start
Notes : If soul chests can be found in the map, the script will abort  
*/
function __init__()
{
	soul_chest_init();
	thread mpd_init();
}

function mpd_init()
{
	mpds = getEntArray( "harrybo21_mpd", "script_noteworthy" );
	
	if ( !isDefined( mpds ) || mpds.size < 1 )
		return;
	
	for ( i = 0; i < mpds.size; i++ )
		mpds[ i ] mpd_setup();
	
}

function mpd_setup()
{
	self thread mpd_main_thread();
	
	tubes = getEntArray( self.targetname, "target" );
	for ( i = 0; i < tubes.size; i++ )
		tubes[ i ] thread mpd_cannister_logic( self );
	
}

function mpd_main_thread()
{
	self setHintstring( "The M.P.D must be charged..." );
	tubes = getEntArray( self.targetname, "target" );
	for ( i = 0; i < tubes.size; i++ )
		self waittill( "soul_tube_done" );

	self setHintstring( "Press & hold ^3&&1^7 to activate M.P.D" );
	self waittill( "trigger", player );
	self setHintstring( "" );
	
	model = getEnt( self.target, "targetname" );
	model useAnimTree( #animtree );
	model.animname = "soul_box";
	model animScripted( PYRAMID_OPEN, model.origin, model.angles, PYRAMID_OPEN );
	playFxOnTag( PYRAMID_COMPLETE_FX, model, "tag_origin" );
	self delete();
}

function mpd_cannister_logic( main_trigger )
{
	fraction = 40 / PYRAMID_LIMIT;

	trigger = zm_harrybo21_utility::harrybo21_spawn_trigger_radius_use( self.origin + ( 0, 0, 40 ), self.angles, 1, 256, 128 );
	trigger.script_noteworthy = "harrybo21_soul_chest";
	
	trigger.souls_required = PYRAMID_LIMIT;
	trigger.kills = 0;
	trigger.timer = 0;
	trigger.marked_kills = 0;
	trigger.active = 0;
	trigger.linked_model = self;
	trigger SetCursorHint( "HINT_NOICON" );
	
	origin = self.origin;
	trigger.complete_function = &nullifi;
	trigger.custom_fx_function = &nullifi;
	
	while ( 1 )
	{
		if ( trigger.kills >= trigger.souls_required )
			break;
		
		trigger waittill( "soul_collected" );
		
		self moveTo( origin + ( 0, 0, trigger.kills * fraction ), .5  );
	}
	trigger delete();
	main_trigger notify( "soul_tube_done" );
}

function nullifi()
{
	
}

function mpd_logic_old()
{
	while ( 1 )
	{
		self waittill( "trigger", player );
		
		tubes = getEntArray( self.targetname, "target" );
		
		for ( i = 0; i < tubes.size; i++ )
			tubes[ i ] moveZ( 40, 10 );
		
		break;
	}
	self setHintstring( "" );
}

/* 
INITIALIZE 
Description : This function starts the script and will setup everything required
Notes : If soul chests can be found in the map, the script will abort  
*/
function soul_chest_init()
{
	structs = soul_chest_get_structs();
	
	// if ( !isDefined( structs ) || structs.size < 1 )
	// 	return;
	
	zm_harrybo21_utility::harrybo21_cache_script( "zm_soul_chest", 1 );
	soul_chest_variable_setup();
		
	for ( i = 0; i < structs.size; i++ )
		soul_chest_spawn_chest( structs[ i ] );
	
	zm_spawner::add_custom_zombie_spawn_logic( &soul_chest_zombie_watch_death );
}

/* 
SETS UP THE REQUIRED VARIABLES AND THREADS FOR THE SOUL CHESTS
Description : This function will set up the required variables and anything else required by the Soul Chests in order to work correctly
Notes : None  
*/
function soul_chest_variable_setup()
{
	zombie_utility::set_zombie_var( "soulchest_initial_limit", 		SOULCHEST_INITIAL_LIMIT );
	zombie_utility::set_zombie_var( "soulchest_limit_multiplier", 	SOULCHEST_LIMIT_MULTIPLIER );
	zombie_utility::set_zombie_var( "soulchest_timeout", 			SOULCHEST_TIMEOUT );
}

/* 
SPAWN A SOUL CHEST AT STRUCT PASSED TO IT 
Description : This function will spawn a soul chest at the struct that was passed to it
Notes : None  
*/
function soul_chest_spawn_chest( struct )
{
	struct.spawned = 1;
	
	trigger = zm_harrybo21_utility::harrybo21_spawn_trigger_radius_use( struct.origin, struct.angles, 1, 256, 128 );
	trigger.script_noteworthy = "harrybo21_soul_chest";
	
	trigger.kills = 0;
	trigger.timer = 0;
	trigger.marked_kills = 0;
	trigger.active = 0;
	trigger.sight_check = 1;
	
	trigger.linked_struct = struct;
	
	trigger.linked_model = spawn( "script_model", struct.origin );
	trigger.linked_model.angles = struct.angles;
	trigger.linked_model setModel( SOULCHEST_MODEL );
	trigger.linked_model useAnimTree( #animtree );
	trigger.linked_model.animname = "soul_box";
	
	trigger.collision = spawn( "script_model", struct.origin, 1 );
	trigger.collision.angles = struct.angles;
	trigger.collision setModel( "zm_collision_perks1" );
	trigger.collision disconnectPaths();
}

/* 
PROPERLY DELETES A CHEST AND ITS CHILDREN
Description : This function will completely delete a soul chest. It will remove the clip that was spawned there, reconnect the pathing to it, delete the chest and then delete the trigger
Notes : None  
*/
function soul_chest_delete_chest()
{
	self.collision connectPaths();
	self.collision delete();
	self.linked_model delete();
	self delete();
}

/* 
THIS IS A THREAD THAT WILL BE LOOPING ON A ZOMBIE WATCHING FOR HIM TO BE KILLED
Description : This function will detect when a zombie is killed, and check if he was in range of a soul chest. If he was, the soul chests kill counter incrases and the timeout counter resets
Notes : None  
*/
function soul_chest_zombie_watch_death()
{
	self endon( "delete" );
	
	self waittill( "death" );
	
	if ( !isDefined( self.attacker ) || !isPlayer( self.attacker ) )
		return;
	
	// if ( self harrybo21_soul_chest_is_touching_excluder() )
	// 	return;
	
	soul_chest_triggers = soul_chest_get_triggers();
	soul_chest_triggers = util::get_array_of_closest( self.origin, soul_chest_triggers, undefined, undefined, undefined );
	
	if ( !isDefined( soul_chest_triggers ) || soul_chest_triggers.size < 1 )
		return;
	
	for ( i = 0; i < soul_chest_triggers.size; i++ )
	{
		if ( !soul_chest_in_range( self, soul_chest_triggers[ i ] ) )
			continue;
		
		soul_chest_triggers[ i ] soul_chest_take_zombie_soul( self );
		break;		
	}
}

/* 
FUNCTION TO CHECK IF A ZOMBIE IS IN RANGE OF, AND MEETS ANY CRITERIA REQUIRED OF SOUL CHESTS 
Description : This function check if the zombie in question is in range of the trigger that was passed
Notes : None  
*/
function soul_chest_in_range( zombie, trigger )
{
	if ( !zombie isTouching( trigger ) )
		return 0;
	
	if ( IS_TRUE( trigger.sight_check ) && !sightTracePassed( zombie.origin, trigger.origin, 0, zombie ) )
		return 0;
	
	return 1;
}

/* 
FUNCTION TO OPEN A SOUL CHEST, WILL ANIMATE IT, SET UP THE SOUNDS ABD TRIGGER THE FX 
Description : This function will activate a soul chest
Notes : None  
*/
function soul_chest_open()
{
	self.active = 1;
	self.kills = 0;
	self.timer = 0;
	self.marked_kills = 0;
	
	self.soul_chest_fire = zm_harrybo21_utility::harrybo21_spawn_blank_script_model( self.linked_model.origin, self.linked_model.angles + ( 0, 90, 0 ) );
	
	self.soul_chest_fire playLoopSound( "zmb_footprintbox_fire", .1 );
	
	if ( isDefined( self.custom_fx_function ) )
		[[ self.custom_fx_function ]]();
	else 
		playFxOnTag( SOULCHEST_FIRE_FX, self.soul_chest_fire, "tag_origin" );
	
	self soul_chest_play_anim( SOULCHEST_OPEN );
	self thread soul_chest_watch_for_timeout();
}

/* 
FUNCTION TO CLOSE A SOUL CHEST, WILL ANIMATE IT, KILL THE SOUNDS AND KILL THE FX 
Description : This function will deactivate a soul chest
Notes : None  
*/
function soul_chest_close()
{
	self.soul_chest_fire stopLoopSound( .1 );
	self.soul_chest_fire delete();
	
	self soul_chest_play_anim( SOULCHEST_CLOSE );	
	
	self.active = 0;
	self.kills = 0;
	self.timer = 0;
	self.marked_kills = 0;
}

/* 
FUNCTION TO WATCH FOR A SOUL BOX TIMING OUT
Description : There is the option to set a count down timer, if used, this function keeps check if a box should "timeout". This feature can be disables
Notes : None  
*/
function soul_chest_watch_for_timeout()
{
	self endon( "delete" );
	self notify( "zm_soul_chest_timeout" );
	self endon( "disconnect" );
	self endon( "zm_soul_chest_timeout" );
	
	self.timer = 0;
	while ( self.timer < level.zombie_vars[ "soulchest_timeout" ] )
	{
		self.timer++;
		wait 1;
	}
	self notify( "zm_soul_chest_timeout" );
}

/* 
THIS IS EXTRA LOGIC FOR PLAYING ANIMATIONS ON THE SOUL BOXES, BOTH FOR OPTIMIZATION AND BETTER MANAGEMENT
Description : This function will play a animation on a soul chest, and will not allow other calls to this function to run "until" this one has finished - meaning another script trying to play a anim on this, will be paused until this is completed
Notes : None  
*/
function soul_chest_play_anim( animation )
{
	while ( IS_TRUE( self.soul_chest_animating ) )
		wait .05;
	
	self.soul_chest_animating = 1;
	
	model = self.linked_model;
	
	model soul_chest_clear_anims();
	model animScripted( animation, model.origin, model.angles, animation );
	
	wait getAnimLength( animation );
	
	self.soul_chest_animating = undefined;
}

/* 
THIS IS EXTRA LOGIC FOR COMPLETELY CLEARING THE ANIMATIONS OFF A MODEL AND CALLING A END TO ANIMSCRIPTED STUFF
Description : This function will basically just completely stop and revert any animations this object is playing, or if it was in a "different position" - it will be returned to its "idle" pose
Notes : None  
*/
function soul_chest_clear_anims()
{
	self clearAnim( SOULCHEST_OPEN, 0 );
	self clearAnim( SOULCHEST_CLOSE, 0 );
}

/* 
THIS IS THE LOGIC THAT HANDLES A SOUL BEING PASSED TO A CHEST
Description : This function handles when a zombie dies, and his soul is taken by the chest. If the chest was "closed", it will open, if it was already open then ( if you use it ) the timer countdown is reset
Notes : None  
*/
function soul_chest_take_zombie_soul( zombie )
{
	if ( IS_TRUE( self.soul_chest_completed ) )
		return;
	
	// if ( self.kills + self.marked_kills >= level.zombie_vars[ "soulchest_initial_limit" ] )
	// 	return;
		
	if ( !IS_TRUE( self.active ) )
		self thread soul_chest_open();
	
	self soul_chest_soul_move_to_chest( zombie );
	
	if ( isDefined( self.souls_required ) && self.kills + self.marked_kills >= self.souls_required )
		self soul_chest_completed_location();
	else if ( !isDefined( self.souls_required ) && self.kills + self.marked_kills >= level.zombie_vars[ "soulchest_initial_limit" ] )
		self soul_chest_completed_location();
	
}

/* 
THIS FUNCTION CONTROLS SHOWING THE FX, SOUND AND LOGIC RAN TO SHOW SOUULS GETTING "ABSORBED"
Description : This function is just to control the soul getting from the zombie to the chest
Notes : None  
*/
function soul_chest_soul_move_to_chest( zombie )
{
	self.timer = 0;
	self.marked_kills++;
	
	ent = spawn( "script_model", zombie getTagOrigin( "j_spineupper" ) );
	ent setModel( "tag_origin" );
	
	playFxOnTag( SOULCHEST_TRAIL_FX, ent, "tag_origin" );
	ent moveTo( self.linked_model.origin + ( 0, 0, 50 ), 1.25, .5, .25 );
	
	wait 1;
	
	playFx( SOULCHEST_COLLECT_FX, ent.origin );
	playSoundAtPosition( "zmb_footprintbox_pulse", ent.origin );
	ent delete();
	
	self.kills++;
	self.marked_kills--;
	self notify( "soul_collected" );
}

/* 
THIS FUNCTION INCREASES THE CURRENT "GLOBAL" REQUIREMENT OF KILLS TO COMPLETE A CHEST
Description : This function increases the next chests requirement of kills upon completing another. If you want to have a set number for "every" box, then set SOULCHEST_START_ADD_AMOUNT to "0" in the gsh
Notes : None  
*/
function soul_chest_increase_global_count()
{
	level.zombie_vars[ "soulchest_initial_limit" ] += level.zombie_vars[ "soulchest_limit_multiplier" ];
}

/* 
THIS FUNCTION IS CALLED WHEN A SOUL CHEST IS COMPLETED
Description : This function handles the logic for a chest being completed. You can safely ignore this, as there are two fuunctions further down you can use to edit rewards and other such things
Notes : None  
*/
function soul_chest_completed_location()
{
	if ( IS_TRUE( self.soul_chest_completed ) )
		return;
	
	self.soul_chest_completed = 1;
	
	if ( isDefined( self.complete_function ) )
		return self [[ self.complete_function ]]();
	
	soul_chest_increase_global_count();
	
	self soul_chest_close();
	
	model = self.linked_model;
	
	model soul_chest_clear_anims();
	
	origin = model.origin;
	
	fake_model = spawn( "script_model", origin );
	fake_model setModel( SOULCHEST_MODEL );
	fake_model.angles = model.angles;
	wait .05;
	model hide();
	
	wait 1;
	fake_model moveZ( 30, 1, 1 );
	wait .5;
	n_rotations = randomIntRange( 5, 7 );
	v_start_angles = fake_model.angles;
	i = 0;
	while ( i < n_rotations )
	{
		v_rotate_angles = v_start_angles + ( randomFloatRange( -10, 10 ), randomFloatRange( -10, 10 ), randomFloatRange( -10, 10 ) );
		n_rotate_time = randomFloatRange( .2, .4 );
		fake_model rotateTo( v_rotate_angles, n_rotate_time );
		fake_model waittill( "rotatedone" );
		i++;
	}
	
	fake_model rotateTo( v_start_angles, .3 );
	fake_model moveZ( -60, .5, .5 );
	fake_model waittill( "rotatedone" );
	
	playFX( level._effect[ "poltergeist" ], origin );
	
	playFx( SOULCHEST_COLLECT_FX, origin );
	
	playSoundAtPosition( "zmb_footprintbox_disappear", origin );
	
	fake_model waittill( "movedone" );
	fake_model delete();
	self soul_chest_delete_chest();
	
	soul_chest_complete_logic( origin );
}

/* 
THIS FUNCTION IS CALLED WHEN A INDUVIDUAL SOUL CHEST IS COMPLETED
Description : This function will run if a single chest is completed, if the completed chest is the "last" one, then this function is ignored, and @soul_chest_all_complete_logic will run "instead"
Notes : "origin" - is the origin on the chest that was just completed  
*/
function soul_chest_complete_logic( origin )
{
	level notify( "soul_chest_complete", origin );
	
	chests = soul_chest_get_triggers();
	if ( !isDefined( chests ) || chests.size < 1 )
		return soul_chest_all_complete_logic( origin );
		
	// ============================================== //
	// This is where you will script the response to a induvidual chest being filled
	// origin = the origin of the chest that was just completed. This will be floor level
	// You can manually change the kills required here by changing the following :
	// level.current_count = amount;
	// I chose top spawn a powerup and reward the players some points as a example
	// ============================================== //
	
	// zm_powerups::special_powerup_drop( origin );
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
		players[ i ] zm_score::add_to_player_score( 500 );
	
}

/* 
THIS FUNCTION IS CALLED WHEN THE "FINAL" SOUL CHEST IS COMPLETED
Description : This function will run when the last soul chest is complete
Notes : "origin" - is the origin on the chest that was just completed  
Notes : Be aware that the "induvidual" chest reward function above will "not" run if the below function is. So if there was something from your old reward that this "also" requires, you will also need to add it here
*/
function soul_chest_all_complete_logic( origin )
{
	// ============================================== //
	// This is where you will script the response to all the chests being filled
	// origin = the origin of the chest that was just completed. This will be floor level
	// I chose top spawn a powerup and reward the players some points as a example
	// ============================================== //
	
	level notify( "soul_chests_complete", origin );
	// zm_powerups::special_powerup_drop( origin );
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
		players[ i ] zm_score::add_to_player_score( 1000 );
	
	spawn_dg4();
}

/* 
THIS IS A SIMPLE UTILITY FUNCTION TO LOCATE THE STRUCTS THAT ARE USED TO PLACE THE SOUL CHESTS ( THEY ARE REDUNDANT AFTER THIS, THEY ARE "ONLY" REQUIRED TO GET STUFF "STARTED" )
Description : Returns a array of the script_structs used to decide the locations and parameters of the soul chests
Notes : None
*/
function soul_chest_get_structs()
{
	return struct::get_array( "harrybo21_soul_chest", "script_noteworthy" );
}

/* 
THIS IS A SIMPLE UTILITY FUNCTION TO LOCATE THE TRIGGERS FOR THE SOUL CHESTS ( THE "MODEL" AND THE "CLIP" ARE BOTH STORED ON THIS ENTITY AS "CHILDREN" OR "PROTPERTIES" YOU CAN REFERENCE WITH trigger.collision AND trigger.linked_model )
Description : Returns a array of the script_structs used to decide the locations and parameters of the soul chests
Notes : None
*/
function soul_chest_get_triggers()
{
	return getEntArray( "harrybo21_soul_chest", "script_noteworthy" );
}

/* 
THIS FUNCTION CHECKS IF A DYING ZOMBIE HAS TRIGGERED A SOUL BOX, BUT MAY BE IN A AREA YOUVE DECIDED / THEY SHOULDNT BE ABLE TO EFFECT THE SOUL CHEST FROM
Description : Checks if a zombie is touching a volume placed in radiant that will "on purpose" stop him from being able to effect soul chests.
Notes : None
*/
function harrybo21_soul_chest_is_touching_excluder()
{
	excluders = getEntArray( "harrybo21_chest_ignore_area", "targetname" );
	
	if ( !isDefined( excluders ) || excluders.size < 1 )
		return 0;
	
	for ( i = 0; i < excluders.size; i++ )
	{
		if ( self isTouching( excluders[ i ] ) )
			return 1;
			
	}
	
	return 0;
}




function spawn_dg4()
{
	location = struct::get( "dg4_spawn", "targetname" );
	
	model = spawn( "script_model", location.origin );
	model setModel( getWeaponWorldModel( getWeapon( "hero_gravityspikes_melee" ) ) );
	model thread zm_powerups::powerup_wobble();
	
	trigger = spawn( "trigger_radius_use", location.origin + ( 0, 0, 30 ), 0, 80, 80 );
		
	trigger TriggerIgnoreTeam();
	trigger SetVisibleToAll();
	trigger SetTeamForTrigger( "none" );
	trigger UseTriggerRequireLookAt();
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( "Press & hold ^3&&1^7 for Ragnarok DG4" );
	trigger thread dg4_logic();
}

function dg4_logic()
{
	while( 1 )
	{
		self waittill( "trigger", player );
		if ( player hasWeapon( getWeapon( "hero_gravityspikes_melee" ) ) )
			continue;
		
		player zm_weapons::weapon_give( getWeapon( "hero_gravityspikes_melee" ), 0, 0, 1, 0 );
	}
}