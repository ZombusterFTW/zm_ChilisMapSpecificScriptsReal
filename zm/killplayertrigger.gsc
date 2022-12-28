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
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_perk_electric_cherry;

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

//precache your custom image material

#define JUMP_SCARE_SHADER "jse_hh"
#precache("material", jump_scare);
//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	level.dog_rounds_allowed = false;
	zm_usermap::main();
	
	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );
	level.pathdist_type = PATHDIST_ORIGINAL;
	callback::on_spawned(&on_player_spawned);
}
function on_player_spawned()
{
	//do other on spawn stuff here...
	self thread jump_scare_listener();
}

function usermap_test_zone_init()
{
	level flag::init( "always_on" );
	level flag::set( "always_on" );
}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}


function fire_jump_scare() 
{
	level waittill("jse_activated");
	self.has_scared = true;
	//show the scary image
	jse = self display_jump_scare(JUMP_SCARE_SHADER);
	//plays sound and then fires a notify when its done
	self PlaySoundWithNotify("jump_scare_sound", "jse_done");
	//sit here and wait until the notify hits (the sound is currently playing)
	self waittill("jse_done");
	//self IPrintLnBold("done");
	//delete the hudelem after the sound plays
	jse Destroy();
}
function display_jump_scare(shader) 
{
	self.jse_image = newClientHudElem(self);
	self.jse_image.horzAlign = "fullscreen";
	self.jse_image.vertAlign = "fullscreen";
	self.jse_image.alignX = "left";
	self.jse_image.alignY = "top";
	self.jse_image.alpha = 1;
	self.jse_image setShader(shader, 640, 480);
	return self.jse_image;
}
//implementation of islookingat because that didnt work for me
function looking_at(gameEntity)
{
	entityPos = gameEntity.origin;
	playerPos = self getEye();

	entityPosAngles = vectorToAngles(entityPos - playerPos);
	entityPosForward = anglesToForward(entityPosAngles);

	playerPosAngles = self getPlayerAngles();
	playerPosForward = anglesToForward(playerPosAngles);

	newDot = vectorDot(entityPosForward, playerPosForward);

	//self IPrintLnBold(newdot);
	//adjust this to make it more accurate or lenient (1.0 is dead on)
	//fun fact - return (newDot < 0.90); doesnt work in GSC :)
	if (newDot < 0.90) {
		return false;
	}
	return true;
}

function jump_scare_listener() 
{
	//grab our entity that triggers the scare
	jse = getent("jump_scare", "targetname");

	//fail if it can't find the ent
	if (!isdefined(jse)) {
		//assert(isdefined(jse), "jump scare entity not found");
		return;
	}

	//init a field for the player to indicate if they've been spooked already
	self.has_scared = false;

	//start threading the function to fire the jump scare when it gets hit
	self thread fire_jump_scare();

	while (true) 
	{
		//make sure our current wep is a sniper, they're aiming in, they're looking at the jump scare entity and they havent been scared already
		wep = self GetCurrentWeapon();
		wep_arr = StrTok(wep.name, "_");
		if (self looking_at(jse) && !self.has_scared && wep_arr[0] == "sniper" && self PlayerAds() == 1) {
			level notify("jse_activated");
			break;
		}
		wait(3);
	}

}
