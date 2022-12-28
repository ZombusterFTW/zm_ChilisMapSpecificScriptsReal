#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\archetype_shared\archetype_shared.gsh;

#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_util;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_weap_riotshield;

#insert scripts\zm\_zm_buildables.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_weap_dragonshield.gsh;

#precache( "fx", DRAGONSHIELD_ZOMBIE_FIRE );
#precache( "fx", DRAGONSHIELD_UPGRADED_ZOMBIE_FIRE );
#precache( "model", DRAGONSHIELD_MODEL );
#precache( "model", "p7_zm_zod_magic_circle_ritual_256_paint" );
#precache( "model", "p7_zm_zod_magic_circle_ritual_256_emissive" );
#precache( "model", "p7_zm_zod_beast_basin" );
#precache( "model", "p7_fxanim_zm_zod_summoning_key_mod" );

#namespace zm_weap_dragonshield;

REGISTER_SYSTEM_EX( "zm_weap_dragonshield", &__init__, &__main__, undefined )

function __init__()
{	
	callback::on_connect( &on_player_connect);
	callback::on_spawned( &on_player_spawned );
	
	zm_equipment::register( DRAGONSHIELD_WEAPON, &"ZOMBIE_EQUIP_RIOTSHIELD_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_RIOTSHIELD_HOWTO", undefined, "riotshield" ); //, &zm_equip_riotshield::riotshield_activation_watcher_thread, undefined, undefined, undefined ); //, &placeShield );
	level.weaponRiotshieldUpgraded = GetWeapon( DRAGONSHIELD_WEAPON_UPGRADED );
	zm_equipment::register( DRAGONSHIELD_WEAPON_UPGRADED, &"ZOMBIE_EQUIP_RIOTSHIELD_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_RIOTSHIELD_HOWTO", undefined, "riotshield" ); 
	
	zm_spawner::register_zombie_damage_callback( &dragon_shield_flame_zombie );
	zm_spawner::register_zombie_death_event_callback( &dragon_shield_flame_zombie );
	
	triggers = struct::get_array( "harrybo21_dragon_shield_upgrade_trigger", "script_noteworthy" );
	
	if ( !isDefined( triggers ) || triggers.size < 1 )
		return;
	
	for ( i = 0; i < triggers.size; i++ )
		triggers[ i ] thread upgrade_trigger();
	
}

function __main__()
{
	zm_equipment::register_for_level( DRAGONSHIELD_WEAPON );
	zm_equipment::include( DRAGONSHIELD_WEAPON );
	zm_equipment::set_ammo_driven( DRAGONSHIELD_WEAPON, GetWeapon( DRAGONSHIELD_WEAPON ).startAmmo, DRAGONSHIELD_REFILL_ON_MAX_AMMO );
	
	zm_equipment::register_for_level( DRAGONSHIELD_WEAPON_UPGRADED );
	zm_equipment::include( DRAGONSHIELD_WEAPON_UPGRADED );
	zm_equipment::set_ammo_driven( DRAGONSHIELD_WEAPON_UPGRADED, GetWeapon( DRAGONSHIELD_WEAPON_UPGRADED ).startAmmo, DRAGONSHIELD_REFILL_ON_MAX_AMMO );
}

function on_player_connect()
{
	self thread watchFirstUse();
}

#define DRAGON_SHIELD_HINT_TEXT ""
#define DRAGON_SHIELD_HINT_TIMER 5

// this is rocket shield specific and shoud be moved to a different script
function watchFirstUse()
{
	self endon( "disconnect" );
	while ( isDefined( self ) )
	{
		self waittill ( "weapon_change", newWeapon );
		if ( newWeapon.isriotshield )
			break;
	}
	self.dragon_shield_hint_shown=1;
	zm_equipment::show_hint_text( DRAGON_SHIELD_HINT_TEXT, DRAGON_SHIELD_HINT_TIMER );
	
}

function on_player_spawned()
{
	// self.player_shield_apply_damage = &player_damage_dragonshield;
	self thread dragon_shield_fire_watcher();
	self thread player_watch_shield_fired();
	self thread player_watch_ammo_change();
	self thread player_watch_max_ammo();
	self thread player_watch_upgraded_pickup_from_table();
}

function dragon_shield_fire_watcher() // self == player
{
	self notify( "player_watch_shield_juke" );
	self endon( "player_watch_shield_juke" );
	
	for ( ;; )
	{
		self waittill( "weapon_melee_power", weapon );
		
		if ( weapon.name != DRAGONSHIELD_WEAPON && weapon.name != DRAGONSHIELD_WEAPON_UPGRADED )
			continue;
		
		v_player_angles = vectorToAngles( self getWeaponForwardDir() );
		
		v_shot_start = self getWeaponMuzzlePoint();
		v_shot_end = v_shot_start + ( anglesToForward( v_player_angles ) * 1000 );
		
		if ( weapon.name == DRAGONSHIELD_WEAPON )
			e_proj = magicBullet( getWeapon( DRAGONSHIELD_WEAPON_PROJECTILE ) , v_shot_start, v_shot_end, self );
		else if ( weapon.name == DRAGONSHIELD_WEAPON_UPGRADED )
			e_proj = magicBullet( getWeapon( DRAGONSHIELD_WEAPON_UPGRADED_PROJECTILE ) , v_shot_start, v_shot_end, self );
		
	}
}

function player_watch_ammo_change()
{
	self notify( "player_watch_ammo_change_dragon_shield" );
	self endon( "player_watch_ammo_change_dragon_shield" );
	
	for ( ;; )
	{
		self waittill( "equipment_ammo_changed", equipment );
		if ( isString( equipment ) )
			equipment = getWeapon( equipment );
		if ( equipment == getWeapon( DRAGONSHIELD_WEAPON ) || equipment == getWeapon( DRAGONSHIELD_WEAPON_UPGRADED ) )
			self thread check_weapon_ammo( equipment );
		
	}
}

function player_watch_max_ammo()
{
	self notify( "player_watch_max_ammo" );
	self endon( "player_watch_max_ammo" );
	
	for ( ;; )
	{
		self waittill( "zmb_max_ammo" );
		
		WAIT_SERVER_FRAME;
		
		if ( IS_TRUE( self.hasRiotShield )  )
			self thread check_weapon_ammo( self.weaponRiotshield ); 
		
	}
}

function check_weapon_ammo( weapon )
{
	WAIT_SERVER_FRAME;
	
	if ( IsDefined(self) )
	{
		ammo = self getWeaponAmmoClip( weapon );
		self clientfield::set( "rs_ammo", ammo ); 
	}
}

// if the player has gotten the upgraded shield from the side EE, give it to them whenever they pick up the shield from the crafting table
function player_watch_upgraded_pickup_from_table()
{
	self notify( "player_watch_upgraded_pickup_from_table" );
	self endon( "player_watch_upgraded_pickup_from_table" );
	
	// get the notify string for when the player picks up the shield
	str_wpn_name = DRAGONSHIELD_WEAPON;
	str_notify = str_wpn_name + "_pickup_from_table";
	
	for ( ;; )
	{
		self waittill( str_notify );
		if ( IS_TRUE( self.b_has_upgraded_shield ) )
			self zm_equipment::buy( DRAGONSHIELD_WEAPON_UPGRADED );
		
	}
}

//*****************************************************************************
// JUKE
//*****************************************************************************

function player_watch_shield_fired() // self == player
{
	self endon( "death" );
	for ( ;; )
	{
		self waittill( "missile_fire", e_projectile, str_weapon );
		
		if ( str_weapon.name != DRAGONSHIELD_WEAPON_PROJECTILE && str_weapon.name != DRAGONSHIELD_WEAPON_UPGRADED_PROJECTILE )
			continue;
		
		e_projectile thread dragon_shield_impact( self, str_weapon );

	}
}

function dragon_shield_impact( player, weapon )
{
	// origin = self grenade_waittill_still_or_bounce();
	
	self waittill( "death" );
	origin = self.origin;
	
	if ( weapon.name == DRAGONSHIELD_WEAPON_UPGRADED_PROJECTILE )
	{
		radius = DRAGONSHIELD_UPGRADED_RADIUS;
		damage = DRAGONSHIELD_UPGRADED_DAMAGE;
	}
	else if ( weapon.name == DRAGONSHIELD_WEAPON_PROJECTILE )
	{
		radius = DRAGONSHIELD_RADIUS;
		damage = DRAGONSHIELD_DAMAGE;
	}
	ai = getAiSpeciesArray( "axis", "all" );
	ai = util::get_array_of_closest( origin, ai, undefined, undefined, radius );
	for ( i = 0; i < ai.size; i++ )
	{
		if ( ai[ i ].health <= damage )
			ai[ i ] thread dragon_shield_explode_fling( origin, self );
		else
			self doDamage( damage, self.origin, player, player, 0, "MOD_RIFLE_BULLET", -1, weapon );
		
	}
	self delete();
}

function dragon_shield_explode_fling( origin, player, weapon )
{
	wait randomFloatRange( 0, .15 );
	angle = vectorToAngles( origin - self.origin );
	angle = anglesToForward( angle - ( 0, 180, 0 ) ) + anglesToUp( angle );
	self startRagdoll();
	fling_vec = vectorScale( angle, 100 );
	self launchRagdoll( fling_vec );
	self doDamage( self.maxHealth + 666, self.origin, player, player, 0, "MOD_RIFLE_BULLET", -1, weapon );
}

function grenade_waittill_still_or_bounce()
{
	prev_origin = self.origin;
	while( 1 )
	{
		wait .05;
		if ( prev_origin == self.origin )
			break;
		
		prev_origin = self.origin;
	}
	return prev_origin;
}

function dragon_shield_flame_zombie()
{
	if ( self.damageweapon.name == DRAGONSHIELD_WEAPON_PROJECTILE )
		self thread dragon_shield_flame_death_fx( DRAGONSHIELD_ZOMBIE_FIRE );
	else if ( self.damageweapon.name == DRAGONSHIELD_WEAPON_UPGRADED_PROJECTILE )
		self thread dragon_shield_flame_death_fx( DRAGONSHIELD_UPGRADED_ZOMBIE_FIRE );
	
	return 0;
}

function dragon_shield_on_fire_timeout()
{
	self endon ( "delete" );
	
	wait 12;

	if ( isDefined( self ) && isAlive( self ) )
	{
		self.is_on_fire = 0;
		self notify( "stop_flame_damage" );
	}
	
}

function dragon_shield_flame_death_fx( fx )
{
	self endon( "delete" );

	if ( IS_TRUE( self.is_on_fire ) )
		return;
	
	self.is_on_fire = 1;
	
	self thread dragon_shield_on_fire_timeout();

	fire_tag = "j_spinelower";
	
	if ( !isDefined( self getTagOrigin( fire_tag ) ) )  //allows effect to play on parasite and insanity elementals
		fire_tag = "tag_origin";
	
	if ( !isDefined( self.isdog ) || !self.isdog )
		playFxOnTag( fx, self, fire_tag );

	if ( self.archetype !== "parasite" && self.archetype !== "raps" )
	{
		for ( i = 0; i < 15; i++ )
		{	
			tagArray = []; 
			tagArray[ 0 ] = "j_elbow_le"; 
			tagArray[ 1 ] = "j_elbow_ri"; 
			tagArray[ 2 ] = "j_knee_ri"; 
			tagArray[ 3 ] = "j_knee_le"; 
			tagArray = array::randomize( tagArray ); 
	
			playFxOnTag( fx, self, tagArray[ 0 ] ); 

			tagArray[ 0 ] = "j_wrist_ri"; 
			tagArray[ 1 ] = "j_wrist_le"; 
			if ( !IS_TRUE( self.missinglegs ) )
			{
				tagArray[ 2 ] = "j_ankle_ri"; 
				tagArray[ 3 ] = "j_ankle_le"; 
			}
			tagArray = array::randomize( tagArray ); 
	
			playFxOnTag( fx, self, tagArray[ 0 ] ); 
			playFxOnTag( fx, self, tagArray[ 1 ] );
			wait randomFloatRange( .05, .15 );
		}
	}
}

function upgrade_trigger()
{
	trigger = spawn( "trigger_radius_use", self.origin + ( 0, 0, 48 ), 0, 40, 80 );
	trigger.script_noteworthy = "harrybo21_dragon_shield_upgrade_trigger";
	
	trigger triggerIgnoreTeam();
	trigger setVisibleToAll();
	trigger setTeamForTrigger( "none" );
	trigger useTriggerRequireLookAt();
	trigger setCursorHint( "HINT_NOICON" );
	trigger setHintString( "Press & hold ^3&&1^7 to upgrade Dragon Shield" );
	
	while ( 1 )
	{
		trigger waittill( "trigger", player );
		
		if ( player laststand::player_is_in_laststand() || IS_TRUE( player.intermission ) || !player hasWeapon( getWeapon( DRAGONSHIELD_WEAPON ) ) )
			continue;
		
		trigger setHintString( "" );
		player zm_weapons::weapon_take( getWeapon( DRAGONSHIELD_WEAPON ) );
		
		model = spawn( "script_model", trigger.origin );
		model setModel( DRAGONSHIELD_MODEL );
		model.angles = self.angles;
		
		wait 1;
		
		model moveTo( model.origin - ( 0, 0, 100 ), 3 );
		wait 5;
		model moveTo( model.origin + ( 0, 0, 100 ), 3 );
		wait 5;
		
		player playLocalSound( "zmb_dragon_shield_upgrade" );
		
		player notify( "dragon_shield_pickup_from_table" );
		player.b_has_upgraded_shield = 1;
		
		player zm_weapons::weapon_give( getWeapon( DRAGONSHIELD_WEAPON_UPGRADED ), 0, 0, 1, 1 );
		
		trigger setHintString( "Press & hold ^3&&1^7 to upgrade Dragon Shield" );
		model delete();
	}
}