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

//#define USE_STINGERS 0 //spawn, death music

#define HELMET_HEALTH 300
#define BERSERK_TIME 10
#define GAS_DROP_INTERVAL 20				//secs to next drop
#define BARRICADE_BREAK_INTERVAL 10			//secs to next break
#define DROP_GAS_ANYWHERE 1					//0 to only drop on specific spots 
#define GAS_SPOT_ATTRACT_DISTANCE 1000		//also barricades

#define AUTOSPAWN 1
#define FIRST_SPAWN_ROUND 7					//not 1
#define SPAWN_ROUND_INTERVAL 2
#define HEALTH_PER_ROUND 1000
#define MAX_HEALTH 10000
#define DUAL_SPAWN_ROUND 10

//zm_barrier dev error only if no zm


#precache( "model", "c_zom_cellbreaker_helmet");
#precache( "fx", "custom/AI/cellbreaker_spawn");
#precache( "fx", "custom/AI/cellbreaker_death");


REGISTER_SYSTEM( "zm_cellbreaker", &init, undefined )
#namespace zm_cellbreaker;


function init()
{
//BT_REGISTER_API( "brutusTargetService", &brutusTargetService ); //not used
BT_REGISTER_API( "brutusBoardService", &brutusBoardService );
BT_REGISTER_API( "brutusTeargasService", &brutusTeargasService );


BT_REGISTER_API( "brutusshouldturnberserk", &brutusshouldturnberserk);
BT_REGISTER_API( "brutusplayedberserkintro", &brutusplayedberserkintro);

BT_REGISTER_API( "brutusshouldbreakboard", &brutusshouldbreakboard);
BT_REGISTER_API( "brutusboardsmash", &brutusboardsmash);

BT_REGISTER_API( "brutusshouldDoGasAttack", &brutusshouldDoGasAttack);
BT_REGISTER_API( "brutusplayedGasAttack", &brutusplayedGasAttack);

BT_REGISTER_API( "brutusshouldThrowGas", &brutusshouldThrowGas);
BT_REGISTER_API( "brutusplayedThrowGas", &brutusplayedThrowGas);



ASM_REGISTER_NOTETRACK_HANDLER( "fire", &melee_track );
ASM_REGISTER_NOTETRACK_HANDLER( "grenade_drop", &drop_teargas );
ASM_REGISTER_NOTETRACK_HANDLER( "yeet_nade", &throw_teargas );



spawner::add_archetype_spawn_function( "cellbreaker", &zombie_utility::zombieSpawnSetup );
spawner::add_archetype_spawn_function( "cellbreaker", &brutusSpawnSetup );


clientfield::register("actor", "brutus_helmet_destroy", VERSION_SHIP, 2, "int");
clientfield::register("actor", "brutus_lamp_fx", VERSION_SHIP, 2, "int");


aat::register_immunity( ZM_AAT_BLAST_FURNACE_NAME,"cellbreaker",1,1,1 );
aat::register_immunity( ZM_AAT_DEAD_WIRE_NAME,"cellbreaker",1,1,1 );
aat::register_immunity( ZM_AAT_FIRE_WORKS_NAME,"cellbreaker",1,1,1 );
aat::register_immunity( ZM_AAT_THUNDER_WALL_NAME,"cellbreaker",1,1,1 );
aat::register_immunity( ZM_AAT_TURNED_NAME,"cellbreaker",1,1,1 );


level.cellbreaker_dont_use_tear_gas = 0;
if(struct::get_array("cellbreaker_gas_spot", "targetname").size < 1 && !DROP_GAS_ANYWHERE)
	level.cellbreaker_dont_use_tear_gas = 1;

level waittill("initial_blackscreen_passed");

barricades = struct::get_array("exterior_goal", "targetname");
level.brutus_barricade_spots = array();

foreach(windows in barricades)
	{
	structs = struct::get_array(windows.target, "targetname");
	//IPrintLnBold("str "+ structs.size);
	ArrayInsert(level.brutus_barricade_spots, structs[0], 0);
	}

thread setup_autospawn();
}






function melee_track(entity)
{
if(self.archetype != "cellbreaker") //cuz witches
	return;

self Melee();
self PlaySound("vox_brutus_exert");
}




function brutusBoardService(entity)
{
if(struct::get_array("exterior_goal", "targetname").size < 1)
	return 0;

closest_board = ArrayGetClosest(entity.origin, level.brutus_barricade_spots);

//closest_exterior_goal = ArrayGetClosest(closest_board.origin,struct::get_array("exterior_goal", "targetname"));

zbarriers = array();
foreach(bar in GetZBarrierArray())
	if(bar IsZBarrier()) //u wot m9
		ArrayInsert(zbarriers, bar, 0);

if(zbarriers.size < 1)
	{
	//IPrintLnBold("no zbarriers");
	return 0;
	}

closest_zbarrier = ArrayGetClosest(closest_board.origin,zbarriers);
//IPrintLnBold("got zbarrier: "+isdefined(closest_zbarrier));
//IPrintLnBold(closest_zbarrier.origin);

window = closest_zbarrier; //is defined


//window = GetEntArray(closest_exterior_goal.target, "targetname")[0];
	//PlayFX(level._effect["powerup_on_solo"], window.origin);

//IPrintLnBold(isdefined(level.brutus_barricade_spots));
//IPrintLn(Distance(entity.origin,closest_board.origin));

if(GetTime() < entity.next_barricade_time)
	return 0;

if(Distance(closest_board.origin, entity.origin) > GAS_SPOT_ATTRACT_DISTANCE)
	return 0;

if(!closest_zbarrier IsZBarrier())
	return 0;

if(closest_zbarrier IsZBarrierOpen())
	{
	entity.v_zombie_custom_goal_pos = undefined;
	return 0;
	}


entity.barrier_to_break = closest_zbarrier;

entity.v_zombie_custom_goal_pos = closest_board.origin;

if(Distance(entity.origin,closest_board.origin) < 32)
	{
	//IPrintLnBold("at board");
	//entity OrientMode( "face angle", closest_board.angles[1] );
	//entity RotateYaw(closest_board.angles[1]+180, 0.05);
	//entity OrientMode( "face point", undefined, undefined, closest_zbarrier.origin );
	entity.go_break_barrier = 1;
	//IPrintLnBold(entity.go_break_barrier);
	}
//idk
}



function brutusTeargasService(entity)
{
if(level.cellbreaker_dont_use_tear_gas == 1)
	return 0;

if(GetTime() < entity.next_teargas_time)
	return 0;

if(entity.go_berserk == 1)
	return 0;

if(entity.throw_teargas == 1 || entity.drop_teargas == 1)
	return 0;

if(!isdefined(entity.enemy))
	return 0;


if(struct::get_array("cellbreaker_gas_spot", "targetname").size > 0)
	{
	closest_drop_spot = ArrayGetClosest(entity.origin, struct::get_array("cellbreaker_gas_spot", "targetname"));
	if(Distance(entity.origin,closest_drop_spot.origin) < GAS_SPOT_ATTRACT_DISTANCE)
		entity.v_zombie_custom_goal_pos = closest_drop_spot.origin;
	}
else
	closest_drop_spot = entity;



if(Distance(entity.origin, entity.enemy.origin) > 500 
	&& (Distance(closest_drop_spot.origin, entity.origin) > 500 || closest_drop_spot == entity)
	&& entity CanSee(entity.enemy) 
	&& !isdefined(entity.v_zombie_custom_goal_pos))
	{
	entity.throw_teargas = 1;
	}
else if(struct::get_array("cellbreaker_gas_spot", "targetname").size > 0 && Distance(entity.origin,closest_drop_spot.origin) < 32)
	{
	entity.drop_teargas = 1;
	//entity.v_zombie_custom_goal_pos = undefined;
	}
else if(struct::get_array("cellbreaker_gas_spot", "targetname").size < 1 && DROP_GAS_ANYWHERE)
	entity.drop_teargas = 1;

}




function brutusshouldturnberserk(entity)
{
//IPrintLnBold("Should berserk: "+entity.go_berserk);
if(entity.go_berserk == 1)
	return 1;
return 0;
}


function brutusplayedberserkintro(entity) //after anim
{
self endon("death");
entity.go_berserk = 0;
//IPrintLnBold("post berserk");
entity.next_teargas_time += BERSERK_TIME*1000;

entity thread berserk_timeout();
Blackboard::SetBlackBoardAttribute( entity, LOCOMOTION_SPEED_TYPE, LOCOMOTION_SPEED_SPRINT );
entity ASMSetAnimationRate(1.05);
}

function berserk_timeout()
{
self endon("death");
wait BERSERK_TIME;
Blackboard::SetBlackBoardAttribute( self, LOCOMOTION_SPEED_TYPE, LOCOMOTION_SPEED_RUN );
//IPrintLnBold("stop sprint");
self ASMSetAnimationRate(1);
}




function brutusshouldbreakboard(entity)
{
if(entity.go_break_barrier == 1)
	return 1;
return 0;	
}


function brutusboardsmash(entity)
{
//get nearest board and smash
//IPrintLnBold("smashing");
for( i=0; i < entity.barrier_to_break GetNumZBarrierPieces(); i++ )
	{
	if(entity.barrier_to_break GetZBarrierPieceState(i) == "closed")
		entity.barrier_to_break SetZBarrierPieceState( i, "opening" , 1);
	}


entity.go_break_barrier = 0;
//entity.barrier_to_break = undefined;
entity.v_zombie_custom_goal_pos = undefined;
entity.next_barricade_time = GetTime()+BARRICADE_BREAK_INTERVAL*1000;
entity OrientMode("face default");
}




function brutusshouldDoGasAttack(entity)
{
if(level.cellbreaker_dont_use_tear_gas == 1)
	return 0;

if(entity.drop_teargas == 0)
	return 0;

if(entity.throw_teargas == 1)
	return 0;

//IPrintLnBold("do gas attack");
return 1;
}


function brutusplayedGasAttack(entity)
{
entity endon("death");
entity.drop_teargas = 0;
entity.next_teargas_time = GetTime()+GAS_DROP_INTERVAL*1000;
entity.v_zombie_custom_goal_pos = undefined;

entity waittill("nades_dropped", pos);
entity thread do_teargas_damage(pos);
}


function do_teargas_damage(spot)
{
level endon("end_game");
wait 4; //for teargas to come in

stoptime = GetTime()+25000;
//IPrintLnBold("do checks");

while(GetTime() < stoptime)
	{
	foreach(player in GetPlayers())
		{
		if(Distance(player.origin, spot) < 75)
			{
			player DoDamage(15, spot, self);
			player SetBlur(10, 0.1);
			}
		else 
			player SetBlur(0, 1);
		}
	wait 0.25;
	}
//IPrintLnBold("stop damage");

}


function drop_teargas(entity)
{
nade_1 = self MagicGrenadeType(GetWeapon("cellbreaker_teargas_grenade"), self GetTagOrigin("tag_weapon_left"),(0,0,0));
nade_2 = self MagicGrenadeType(GetWeapon("cellbreaker_teargas_grenade"), self GetTagOrigin("tag_weapon_right"),(0,0,0));

nade_1 endon("explode"); //maybe
nade_1 waittill("grenade_bounce", pos, normal, ent, surface);
nade_1 Detonate();
nade_2 Detonate();
self notify("nades_dropped", pos);
}


function throw_teargas(entity)
{
if(entity.throw_teargas == 0) //cuz melee anim
	return 0;

target_pos = entity.enemy.origin;

dir = VectorToAngles( target_pos - entity.origin );
dir = AnglesToForward( dir );

dist = Distance( entity.origin, target_pos );

velocity = dir * dist;
velocity = velocity + (0,0,120);



nade_1 = self MagicGrenadeType(GetWeapon("cellbreaker_teargas_grenade"), self GetTagOrigin("j_mid_le_3"),velocity);
nade_1 endon("explode"); //maybe

//nade_1 waittill( "explode", position, surface );
nade_1 waittill("grenade_bounce", pos, normal, ent, surface);
//IPrintLnBold("blow");
nade_1 Detonate();
entity thread do_teargas_damage(pos);

}



function brutusshouldThrowGas(entity)
{
if(level.cellbreaker_dont_use_tear_gas == 1)
	return 0;

if(entity.drop_teargas == 1)
	return 0;

if(entity.throw_teargas == 0)
	return 0;
//IPrintLnBold("do gas attack");
return 1;

}


function brutusplayedThrowGas(entity)
{
entity.throw_teargas = 0;

entity.next_teargas_time = GetTime()+GAS_DROP_INTERVAL*1000;

}









function private brutusSpawnSetup()
{
	//IPrintLnBold("mechz spawnsetup");
	self DisableAimAssist();

	self.disableAmmoDrop = true;
	self.no_gib = true;
	self.ignore_nuke = true;
	self.ignore_enemy_count = true;
	self.ignore_round_robbin_death = true; 

	self.ignoreRunAndGunDist = true;
	
	self.is_boss = true;

	AiUtility::AddAIOverrideDamageCallback( self, &brutusDamageCallback );


	self PushActors( true );


	Blackboard::CreateBlackBoardForEntity(self);
	self AiUtility::RegisterUtilityBlackboardAttributes();
	ai::CreateInterfaceForEntity(self);
	BB_REGISTER_ATTRIBUTE( LOCOMOTION_SPEED_TYPE, LOCOMOTION_SPEED_RUN, undefined );
	Blackboard::SetBlackBoardAttribute( self, LOCOMOTION_SPEED_TYPE, LOCOMOTION_SPEED_RUN );

	self.team = level.zombie_team;
/*
	self PathMode( "move allowed" );
	self.ai_state = "zombie_think";
	self.script_string = "find_flesh";
	self.completed_emerging_into_playable_area = true;
	self ASMRequestSubstate( "move@cellbreaker" );
	self.keep_moving = 1;
*/
	self.helmet_health = HELMET_HEALTH;
	self.go_berserk = 0;
	self.drop_teargas = 0;
	self.throw_teargas = 0;
	self.go_break_barrier = 0;
	self.next_teargas_time = GetTime()+GAS_DROP_INTERVAL*1000;
	self.next_barricade_time = GetTime()+BARRICADE_BREAK_INTERVAL*1000;
	self.barrier_to_break = undefined;

	self.helmet = Spawn("script_model", self GetTagOrigin("j_head"));
	self.helmet.angles = self GetTagAngles("j_head");
	self.helmet SetModel("c_zom_cellbreaker_helmet");
	self.helmet EnableLinkTo();
	self.helmet LinkTo(self, "j_head");

	self clientfield::set( "brutus_lamp_fx", 1 );


	self thread brutusDeathEvent();
}



function brutusDamageCallback(inflictor, attacker, damage, dFlags, mod, weapon, point, dir, hitLoc, offsetTime, boneIndex, modelIndex)
{
IPrintLnBold("Health: " +(self.health-damage));
//IPrintLnBold(hitloc);
if( isDefined( attacker ) && IsPlayer( attacker ) && IsAlive( attacker ) && ( level.zombie_vars[attacker.team]["zombie_insta_kill"] || IS_TRUE( attacker.personal_instakill )) ) //instakill does normal damage
	{
	damage = damage*2; //make instakill usefull
	}

if ( hitLoc == "head" )
	{
	self track_helmet(damage);
	}

return damage;
}


function private track_helmet(damage)
{
	if(self.helmet_health <= 0)
		return;

	self.helmet_health -= damage;

	if( self.helmet_health <= 0 )
	{
		self.helmet Delete();
		self clientfield::set( "brutus_helmet_destroy", 1 );
		self.go_berserk = 1;
		self PlaySound("evt_brutus_helmet");
	}	

}


function brutusDeathEvent()
{
self waittill("death", attacker, damageType);
attacker zm_score::add_to_player_score(1000);

if(isdefined(self.helmet))
	self.helmet Delete();
//IPrintLnBold("nibba ded");
//self thread cleanup_brutus();
PlaySoundAtPosition("zmb_ai_cellbreaker_death", self.origin);
self PlaySound("zmb_ai_cellbreaker_vox_death");
self clientfield::set( "brutus_helmet_destroy", 1 );
self clientfield::set( "brutus_lamp_fx", 0 );

PlayFXOnTag("custom/AI/cellbreaker_death", self, "j_spineupper");

//PlayFX("custom/AI/cellbreaker_death", self.origin);
//csc
}



/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////



function spawn_brutus(health)
{

s_struct = choose_a_spawn("cellbreaker_spot");


if(!isDefined( s_struct ))
{
	IPrintLnBold( "NO VALID SPAWN POINTS FOUND" );
	return undefined;
}

spawner = GetEntArray("cellbreaker_spawner","targetname");
spawner = spawner[0];

if(!isdefined(spawner))
	{
	IPrintLnBold("no spawner");
	return;
	}

thread zm_utility::really_play_2D_sound("zmb_ai_brutus_spawn_2d");	
wait(RandomIntRange(3,5));

e_ai = zombie_utility::spawn_zombie( spawner, "cellbreaker");

	
if( !isDefined( e_ai ) )
	{
	IPrintLnBold("no e_ai");
	return;
	}
e_ai endon( "death" );


e_ai.health = 2000;
if(isdefined(health))
	e_ai.health = health;





ang = e_ai to_player_angles(s_struct);

e_ai ForceTeleport(s_struct.origin, ang, 0);
e_ai thread scene::play( "ai_zombie_cellbreaker_spawn", e_ai );
e_ai PlaySound("zmb_ai_cellbreaker_vox_spawn");
//PlayFX("custom/AI/cellbreaker_spawn", e_ai.origin, AnglesToForward(ang));
//csc
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






function setup_autospawn()
{
next_spawn_round = FIRST_SPAWN_ROUND;


while(AUTOSPAWN)
	{
	level waittill("between_round_over");
	if(level.round_number != next_spawn_round)
		continue;

	health = level.round_number*HEALTH_PER_ROUND;
	if(health > MAX_HEALTH)
		health = MAX_HEALTH;

	wait(RandomIntRange(10,20));
	spawn_brutus(health);
	
	if(level.round_number >= DUAL_SPAWN_ROUND)
		{
		wait(RandomIntRange(10,20));
		spawn_brutus(health);
		}


	next_spawn_round += SPAWN_ROUND_INTERVAL;
	}

}






