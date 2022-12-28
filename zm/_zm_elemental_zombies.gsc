#using scripts\codescripts\struct;
#using scripts\shared\_burnplayer;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\systems\debug;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai_shared;
#using scripts\shared\animation_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_devgui;

#namespace zm_elemental_zombie;

/*
	Name: __init__sytem__
	Namespace: zm_elemental_zombie
	Checksum: 0xD36D6B89
	Offset: 0x5B0
	Size: 0x33
	Parameters: 0
	Flags: AutoExec
*/
function autoexec __init__sytem__()
{
	system::register("zm_elemental_zombie", &__init__, undefined, undefined);
}

/*
	Name: __init__
	Namespace: zm_elemental_zombie
	Checksum: 0x2B98B691
	Offset: 0x5F0
	Size: 0x43
	Parameters: 0
	Flags: None
*/
function __init__()
{
	register_clientfields();
	/#
		execdevgui("Dev Block strings are not supported");
		thread function_f6901b6a();
	#/
}

/*
	Name: register_clientfields
	Namespace: zm_elemental_zombie
	Checksum: 0xA92D772F
	Offset: 0x640
	Size: 0x123
	Parameters: 0
	Flags: Private
*/
function private register_clientfields()
{
	clientfield::register("actor", "sparky_zombie_spark_fx", 1, 1, "int");
	clientfield::register("actor", "sparky_zombie_death_fx", 1, 1, "int");
	clientfield::register("actor", "napalm_zombie_death_fx", 1, 1, "int");
	clientfield::register("actor", "sparky_damaged_fx", 1, 1, "counter");
	clientfield::register("actor", "napalm_damaged_fx", 1, 1, "counter");
	clientfield::register("actor", "napalm_sfx", 11000, 1, "int");
}

/*
	Name: function_1b1bb1b
	Namespace: zm_elemental_zombie
	Checksum: 0x2E2C0504
	Offset: 0x770
	Size: 0x263
	Parameters: 0
	Flags: None
*/
function function_1b1bb1b()
{
	ai_zombie = self;
	if(!isalive(ai_zombie))
	{
		return;
	}
	var_199ecc3a = make_napalm_zombie("sparky");
	if(!isdefined(level.var_1ae26ca5) || var_199ecc3a < level.var_1ae26ca5)
	{
		if(!isdefined(ai_zombie.is_elemental_zombie) || ai_zombie.is_elemental_zombie == 0)
		{
			ai_zombie.is_elemental_zombie = 1;
			ai_zombie.elemental_zombie_type = "sparky";
			ai_zombie clientfield::set("sparky_zombie_spark_fx", 1);
			ai_zombie.health = Int(ai_zombie.health * 1.5);
			ai_zombie thread function_d9226011();
			ai_zombie thread function_2987b6dc();
			if(ai_zombie.isCrawler === 1)
			{
				var_f4a5c99 = Array("ai_zm_dlc1_zombie_crawl_turn_sparky_a", "ai_zm_dlc1_zombie_crawl_turn_sparky_b", "ai_zm_dlc1_zombie_crawl_turn_sparky_c", "ai_zm_dlc1_zombie_crawl_turn_sparky_d", "ai_zm_dlc1_zombie_crawl_turn_sparky_e");
			}
			else
			{
				var_f4a5c99 = Array("ai_zm_dlc1_zombie_turn_sparky_a", "ai_zm_dlc1_zombie_turn_sparky_b", "ai_zm_dlc1_zombie_turn_sparky_c", "ai_zm_dlc1_zombie_turn_sparky_d", "ai_zm_dlc1_zombie_turn_sparky_e");
			}
			if(isdefined(ai_zombie) && !isdefined(ai_zombie.traverseStartNode) && (!isdefined(self.var_bb98125f) && self.var_bb98125f))
			{
				ai_zombie animation::Play(Array::random(var_f4a5c99), ai_zombie, undefined, 1, 0.2, 0.2);
			}
		}
	}
}

/*
	Name: function_f4defbc2
	Namespace: zm_elemental_zombie
	Checksum: 0xD4F495CE
	Offset: 0x9E0
	Size: 0x173
	Parameters: 0
	Flags: None
*/
function function_f4defbc2()
{
	if(isdefined(self))
	{
		ai_zombie = self;
		var_ac4641b = make_napalm_zombie("napalm");
		if(!isdefined(level.var_bd64e31e) || var_ac4641b < level.var_bd64e31e)
		{
			if(!isdefined(ai_zombie.is_elemental_zombie) || ai_zombie.is_elemental_zombie == 0)
			{
				ai_zombie.is_elemental_zombie = 1;
				ai_zombie.elemental_zombie_type = "napalm";
				ai_zombie clientfield::set("arch_actor_fire_fx", 1);
				ai_zombie clientfield::set("napalm_sfx", 1);
				ai_zombie.health = Int(ai_zombie.health * 0.75);
				ai_zombie thread function_e94aef80();
				ai_zombie thread function_d070bfba();
				ai_zombie zombie_utility::set_zombie_run_cycle("sprint");
			}
		}
	}
}

/*
	Name: function_2987b6dc
	Namespace: zm_elemental_zombie
	Checksum: 0x51E9E8B7
	Offset: 0xB60
	Size: 0x77
	Parameters: 0
	Flags: None
*/
function function_2987b6dc()
{
	self endon("entityshutdown");
	self endon("death");
	while(1)
	{
		self waittill("damage");
		if(RandomInt(100) < 50)
		{
			self clientfield::increment("sparky_damaged_fx");
		}
		wait(0.05);
	}
}

/*
	Name: function_d070bfba
	Namespace: zm_elemental_zombie
	Checksum: 0x1160D905
	Offset: 0xBE0
	Size: 0x77
	Parameters: 0
	Flags: None
*/
function function_d070bfba()
{
	self endon("entityshutdown");
	self endon("death");
	while(1)
	{
		self waittill("damage");
		if(RandomInt(100) < 50)
		{
			self clientfield::increment("napalm_damaged_fx");
		}
		wait(0.05);
	}
}

/*
	Name: function_d9226011
	Namespace: zm_elemental_zombie
	Checksum: 0x156C1353
	Offset: 0xC60
	Size: 0xEB
	Parameters: 0
	Flags: None
*/
function function_d9226011()
{
	ai_zombie = self;
	ai_zombie waittill("death", attacker);
	if(!isdefined(ai_zombie) || ai_zombie.nuked === 1)
	{
		return;
	}
	ai_zombie clientfield::set("sparky_zombie_death_fx", 1);
	ai_zombie zombie_utility::gib_random_parts();
	GibServerUtils::Annihilate(ai_zombie);
	RadiusDamage(ai_zombie.origin + VectorScale((0, 0, 1), 35), 128, 70, 30, self, "MOD_EXPLOSIVE");
}

/*
	Name: function_e94aef80
	Namespace: zm_elemental_zombie
	Checksum: 0x9456FA2B
	Offset: 0xD58
	Size: 0x13B
	Parameters: 0
	Flags: None
*/
function function_e94aef80()
{
	ai_zombie = self;
	ai_zombie waittill("death", attacker);
	if(!isdefined(ai_zombie) || ai_zombie.nuked === 1)
	{
		return;
	}
	ai_zombie clientfield::set("napalm_zombie_death_fx", 1);
	ai_zombie zombie_utility::gib_random_parts();
	GibServerUtils::Annihilate(ai_zombie);
	if(isdefined(level.var_36b5dab) && level.var_36b5dab || (isdefined(ai_zombie.var_36b5dab) && ai_zombie.var_36b5dab))
	{
		ai_zombie.custom_player_shellshock = &function_e6cd7e78;
	}
	RadiusDamage(ai_zombie.origin + VectorScale((0, 0, 1), 35), 128, 70, 30, self, "MOD_EXPLOSIVE");
}

/*
	Name: function_e6cd7e78
	Namespace: zm_elemental_zombie
	Checksum: 0x6B29BAC1
	Offset: 0xEA0
	Size: 0x73
	Parameters: 5
	Flags: None
*/
function function_e6cd7e78(damage, attacker, direction_vec, point, mod)
{
	if(GetDvarString("blurpain") == "on")
	{
		self shellshock("pain_zm", 0.5);
	}
}

/*
	Name: function_d41418b8
	Namespace: zm_elemental_zombie
	Checksum: 0x9D448BB2
	Offset: 0xF20
	Size: 0x63
	Parameters: 0
	Flags: None
*/
function function_d41418b8()
{
	a_zombies = GetAIArchetypeArray("zombie");
	a_filtered_zombies = Array::filter(a_zombies, 0, &is_not_elemental_zombie);
	return a_filtered_zombies;
}

/*
	Name: function_c50e890f
	Namespace: zm_elemental_zombie
	Checksum: 0x54599B75
	Offset: 0xF90
	Size: 0x6B
	Parameters: 1
	Flags: None
*/
function function_c50e890f(type)
{
	a_zombies = GetAIArchetypeArray("zombie");
	a_filtered_zombies = Array::filter(a_zombies, 0, &function_361f6caa, type);
	return a_filtered_zombies;
}

/*
	Name: make_napalm_zombie
	Namespace: zm_elemental_zombie
	Checksum: 0x3C20E926
	Offset: 0x1008
	Size: 0x35
	Parameters: 1
	Flags: None
*/
function make_napalm_zombie(type)
{
	a_zombies = function_c50e890f(type);
	return a_zombies.size;
}

/*
	Name: function_361f6caa
	Namespace: zm_elemental_zombie
	Checksum: 0x96C8CE2A
	Offset: 0x1048
	Size: 0x27
	Parameters: 2
	Flags: None
*/
function function_361f6caa(ai_zombie, type)
{
	return ai_zombie.elemental_zombie_type === type;
}

/*
	Name: is_not_elemental_zombie
	Namespace: zm_elemental_zombie
	Checksum: 0x590ECFE
	Offset: 0x1078
	Size: 0x1F
	Parameters: 1
	Flags: None
*/
function is_not_elemental_zombie(ai_zombie)
{
	return ai_zombie.is_elemental_zombie !== 1;
}

/*
	Name: function_f6901b6a
	Namespace: zm_elemental_zombie
	Checksum: 0x96F67E6F
	Offset: 0x10A0
	Size: 0x43
	Parameters: 0
	Flags: None
*/
//function function_f6901b6a()
//{/
	///#
		//level flagsys::wait_till("Dev Block strings are not supported");
		//zm_devgui::function_4acecab5(&function_2d0e7f4);
	//#/
//}

/*
	Name: function_2d0e7f4
	Namespace: zm_elemental_zombie
	Checksum: 0xA227CFD7
	Offset: 0x10F0
	Size: 0x28D
	Parameters: 1
	Flags: None
*/
function function_2d0e7f4(cmd)
{
	/#
		switch(cmd)
		{
			case "Dev Block strings are not supported":
			{
				a_zombies = function_d41418b8();
				if(a_zombies.size > 0)
				{
					a_zombies = ArraySortClosest(a_zombies, level.players[0].origin);
					a_zombies[0] function_1b1bb1b();
				}
				break;
			}
			case "Dev Block strings are not supported":
			{
				a_zombies = function_d41418b8();
				if(a_zombies.size > 0)
				{
					a_zombies = ArraySortClosest(a_zombies, level.players[0].origin);
					a_zombies[0] function_f4defbc2();
				}
				break;
			}
			case "Dev Block strings are not supported":
			{
				a_zombies = function_d41418b8();
				if(a_zombies.size > 0)
				{
					foreach(zombie in a_zombies)
					{
						zombie function_1b1bb1b();
					}
				}
				break;
			}
			case "Dev Block strings are not supported":
			{
				a_zombies = function_d41418b8();
				if(a_zombies.size > 0)
				{
					foreach(zombie in a_zombies)
					{
						zombie function_f4defbc2();
					}
				}
				break;
			}
		}
	#/
}

