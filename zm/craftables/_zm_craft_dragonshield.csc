#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_weap_riotshield;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_powerup_shield_charge;
#using scripts\zm\_zm_utility;

#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\_zm_utility.gsh;

#define CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_PELVIS			"wpn_t7_zmb_dlc3_dragon_pelvis"
#define CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_HEAD			"wpn_t7_zmb_dlc3_dragon_head"
#define CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_WINDOW			"wpn_t7_zmb_dlc3_dragon_window"
#define DRAGONSHIELD_SHIELD										"craft_dragonshield_zm"
#define ZMUI_SHIELD_PART_PICKUP 								"ZMUI_SHIELD_PART_PICKUP"
#define ZMUI_SHIELD_CRAFTED										"ZMUI_SHIELD_CRAFTED"
	
#namespace zm_craft_dragonshield;

REGISTER_SYSTEM( "zm_craft_dragonshield", &__init__, undefined )

// RIOT SHIELD	
function __init__()
{
	zm_craftables::include_zombie_craftable( DRAGONSHIELD_SHIELD );
	zm_craftables::add_zombie_craftable( DRAGONSHIELD_SHIELD );
	
	RegisterClientField( "world", CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_PELVIS,	VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, false );
	RegisterClientField( "world", CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_HEAD, VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, false );
	RegisterClientField( "world", CLIENTFIELD_CRAFTABLE_PIECE_DRAGONSHIELD_WINDOW,	VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, false );
}

