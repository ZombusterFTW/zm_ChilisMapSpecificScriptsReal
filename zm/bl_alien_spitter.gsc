#using scripts\codescripts\struct;

#using scripts\shared\aat_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\ai_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\weapons\grapple.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
//#using scripts\zm\zm_zod_idgun_quest;

#using scripts\shared\ai\zombie_utility;

#insert scripts\shared\archetype_shared\archetype_shared.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\aat_zm.gsh;
#insert scripts\shared\version.gsh;


#insert scripts\shared\ai\systems\animation_state_machine.gsh;
#insert scripts\shared\ai\systems\behavior.gsh;
#insert scripts\shared\ai\systems\behavior_tree.gsh;
#insert scripts\shared\ai\systems\blackboard.gsh;

#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\systems\debug;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\archetype_mocomps_utility;
#using scripts\shared\ai\systems\ai_interface;
#using scripts\shared\scene_shared;


#using scripts\zm\_zm_score;
#using scripts\zm\_zm_zonemgr;





#precache( "model", "c_zom_cellbreaker_helmet");
#precache( "fx", "custom/AI/cellbreaker_spawn");
#precache( "fx", "custom/AI/cellbreaker_death");


REGISTER_SYSTEM( "bl_alien_spitter", &init, undefined )
#namespace bl_alien_spitter;


function init()
{
BT_REGISTER_API( "SpitterSpitService", &SpitterSpitService );


BT_REGISTER_API( "Spittershouldturnberserk", &Spittershouldturnberserk);
BT_REGISTER_API( "Spitterplayedberserkintro", &Spitterplayedberserkintro);

BT_REGISTER_API( "SpittershouldSpit", &SpittershouldSpit);

BT_REGISTER_API( "SpittershoulddoGasAttack", &SpittershoulddoGasAttack);
BT_REGISTER_API( "SpitterplayedGasAttack", &SpitterplayedGasAttack);



ASM_REGISTER_NOTETRACK_HANDLER( "spit", &fire_spit );


//spawner::add_archetype_spawn_function( "cellbreaker", &zombie_utility::zombieSpawnSetup );
//spawner::add_archetype_spawn_function( "cellbreaker", &brutusSpawnSetup );


//clientfield::register("actor", "brutus_helmet_destroy", VERSION_SHIP, 2, "int");
//clientfield::register("actor", "brutus_lamp_fx", VERSION_SHIP, 2, "int");

/*
aat::register_immunity( ZM_AAT_BLAST_FURNACE_NAME,"cellbreaker",1,1,1 );
aat::register_immunity( ZM_AAT_DEAD_WIRE_NAME,"cellbreaker",1,1,1 );
aat::register_immunity( ZM_AAT_FIRE_WORKS_NAME,"cellbreaker",1,1,1 );
aat::register_immunity( ZM_AAT_THUNDER_WALL_NAME,"cellbreaker",1,1,1 );
aat::register_immunity( ZM_AAT_TURNED_NAME,"cellbreaker",1,1,1 );
*/



}


function fire_spit(entity)
{
if(!entity.do_gas_attack)
	{
	entity Shoot();
	IPrintLnBold("shoot");
	self PlaySound("spitter_fire");
	return;
	}

IPrintLnBold("gas attack");
//beam?
}


function SpitterSpitService(entity)
{

}




function Spittershouldturnberserk()
{
return 0;


}

function Spitterplayedberserkintro()
{
return 0;

	
}


function SpittershouldSpit()
{
return 0;

	
}




function SpittershoulddoGasAttack()
{
return 0;

	
}


function SpitterplayedGasAttack()
{
return 0;

	
}










function private SpitterSpawnSetup()
{
	self DisableAimAssist();

	self.disableAmmoDrop = true;
	self.no_gib = true;
	self.ignore_nuke = true;
	self.ignore_enemy_count = true;
	self.ignore_round_robbin_death = true; 

	self.ignoreRunAndGunDist = true;
	
	self.is_boss = true;

	AiUtility::AddAIOverrideDamageCallback( self, &SpitterDamageCallback );


	self PushActors( true );


	Blackboard::CreateBlackBoardForEntity(self);
	self AiUtility::RegisterUtilityBlackboardAttributes();
	ai::CreateInterfaceForEntity(self);
	BB_REGISTER_ATTRIBUTE( LOCOMOTION_SPEED_TYPE, LOCOMOTION_SPEED_RUN, undefined );
	Blackboard::SetBlackBoardAttribute( self, LOCOMOTION_SPEED_TYPE, LOCOMOTION_SPEED_RUN );

	self.team = level.zombie_team;

	self.go_berserk = 0;




	self thread SpitterDeathEvent();
}



function SpitterDamageCallback(inflictor, attacker, damage, dFlags, mod, weapon, point, dir, hitLoc, offsetTime, boneIndex, modelIndex)
{
IPrintLnBold("Health: " +(self.health-damage));
//IPrintLnBold(hitloc);
if( isDefined( attacker ) && IsPlayer( attacker ) && IsAlive( attacker ) && ( level.zombie_vars[attacker.team]["zombie_insta_kill"] || IS_TRUE( attacker.personal_instakill )) ) //instakill does normal damage
	{
	damage = damage*2; //make instakill usefull
	}

if ( hitLoc == "head" )
	{
	//self track_helmet(damage);
	}

if(damage > 50 && RandomInt(100) <= 100)
	self PlaySound("spitter_pain");
return damage;
}




function SpitterDeathEvent()
{
self waittill("death", attacker, damageType);
attacker zm_score::add_to_player_score(1000);
self PlaySound("spitter_death");
}





/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////



function spawn_spitter(health)
{

s_struct = choose_a_spawn("alien_spitter_spot");


if(!isDefined( s_struct ))
{
	IPrintLnBold( "NO VALID SPAWN POINTS FOUND" );
	return undefined;
}

spawner = GetEntArray("alien_spitter_spawner","targetname");
spawner = spawner[0];

if(!isdefined(spawner))
	{
	IPrintLnBold("no spawner");
	return;
	}

e_ai = zombie_utility::spawn_zombie( spawner, "alien_spitter");

	
if( !isDefined( e_ai ) )
	{
	IPrintLnBold("no e_ai");
	return;
	}
e_ai endon( "death" );


e_ai.health = 2000;
if(isdefined(health))
	e_ai.health = health;

self thread SpitterSpawnSetup();//temp

ang = e_ai to_player_angles(s_struct);
e_ai ForceTeleport(s_struct.origin, ang, 0);
return e_ai;
}


function choose_a_spawn(noteworthy)  ////REQUIRES ATLEAST 2 ZONES or no
{
	structs = struct::get_array( noteworthy, "targetname" );

	if(!isdefined(structs) || structs.size < 1)
		{
		IPrintLnBold("noteworthy_position");
		structs = struct::get_array( noteworthy, "script_noteworthy" );
		}

	players = getplayers(); 
	players = array::randomize( players ); 
	player = players[0]; 

	while(1)
		{
		spot = ArrayGetClosest(player.origin,structs);
		zone = zm_zonemgr::get_zone_from_position(spot.origin, 1);

			
		if(level.newzones.size < 2)
			{
			return spot;	
			}

		if(zm_zonemgr::zone_is_enabled(zone))
			{
			//IPrintLnBold("success");			
			return spot;
			}
		else
			{
			ArrayRemoveValue(structs,spot);	
			}
		}		
	IPrintLnBold( "failed "+ noteworthy +" spawn" ); 
}


function to_player_angles(s_struct) //self = slender
{
target = ArrayGetClosest(self.origin,GetPlayers());

v_to_enemy = FLAT_ORIGIN( (target.origin - s_struct.origin) );
v_to_enemy = VectorNormalize( v_to_enemy );
goalAngles = VectortoAngles( v_to_enemy );

return goalAngles; 
}


