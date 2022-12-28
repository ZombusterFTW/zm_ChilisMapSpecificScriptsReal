//
//BO4 STYLE CARPENTER v1.0: REPAIRS SHIELD ON GRAB
//CREATED BY FROST ICEFORGE
//ADDITIONAL CREDIT TO MADGAZ FOR CRUSADER ALE SCRIPTS WHICH I MODIFIED
//
#using scripts\zm\_zm;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\zm\_zm_weap_riotshield; 

function __init__() {}

#define SHIELD_CODENAME "spx_origins_shield" //Edit if your map uses a custom shield
#define SHIELD_UPGRADE_CODENAME "spx_origins_shield_upgraded" //Edit if your custom shield has an upgrade

//BO4 Carpenter
function carpenter_upgrade()
{
	while(1)
	{
		level waittill( "carpenter_started" );	
		foreach(player in GetPlayers())
		{
			primary_weapons = player getWeaponsList( 1 ); 
			foreach ( weap in primary_weapons )
			{
				if( weap.name == SHIELD_CODENAME )
				{
					player riotshield::player_damage_shield( -1500 );
					player giveMaxAmmo( SHIELD_CODENAME ); 
				}
				else if( weap.name == SHIELD_UPGRADE_CODENAME )
				{
					player riotshield::player_damage_shield( -1500 );
					player giveMaxAmmo( SHIELD_UPGRADE_CODENAME );
				} 
			}
		}
		
	}
}