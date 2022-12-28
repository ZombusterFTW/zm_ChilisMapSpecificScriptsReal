#using scripts\codescripts\struct;
#using scripts\shared\_burnplayer;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\mechz;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\scoreevents_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_devgui;
//#using scripts\zm\_zm_elemental_zombies;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_audio;
#using scripts\shared\laststand_shared;
#using scripts\zm\_zm_weap_riotshield;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai_shared;



#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace mechz_spiki;


#precache( "model", "c_t7_zm_dlchd_origins_mech_claw_lod0");
#precache( "model", "p7_chemistry_kit_large_bottle");
#precache( "xanim", "ai_zombie_mech_ft_burn_player");

#using_animtree("mechz_tomb");


REGISTER_SYSTEM( "zm_ai_mechz", &__init__, undefined )




function __init__()
{
	BehaviorTreeNetworkUtility::RegisterBehaviorTreeScriptAPI("mechzShouldShootClaw", &mechzShouldShootClaw);
	BehaviorTreeNetworkUtility::RegisterBehaviorTreeAction("zmMechzShootClawAction", &zmMechzShootClawActionStart, &zmMechzShootClawActionUpdate, &zmMechzShootClawActionEnd);
	BehaviorTreeNetworkUtility::RegisterBehaviorTreeScriptAPI("zmMechzShootClaw", &zmMechzShootClaw);
	BehaviorTreeNetworkUtility::RegisterBehaviorTreeScriptAPI("zmMechzUpdateClaw", &zmMechzUpdateClaw);
	BehaviorTreeNetworkUtility::RegisterBehaviorTreeScriptAPI("zmMechzStopClaw", &zmMechzStopClaw);
	AnimationStateNetwork::RegisterNotetrackHandlerFunction("muzzleflash", &muzzleflash);
	AnimationStateNetwork::RegisterNotetrackHandlerFunction("start_ft", &start_ft);
	AnimationStateNetwork::RegisterNotetrackHandlerFunction("stop_ft", &stop_ft);

	BehaviorTreeNetworkUtility::RegisterBehaviorTreeScriptAPI("castleMechzTrapService", &castleMechzTrapService);
	BehaviorTreeNetworkUtility::RegisterBehaviorTreeScriptAPI("genesisVortexService", &genesisVortexService);
	BehaviorTreeNetworkUtility::RegisterBehaviorTreeScriptAPI("genesisMechzOctobombService", &genesisMechzOctobombService);
	BehaviorTreeNetworkUtility::RegisterBehaviorTreeScriptAPI("castleMechzShouldMoveToTrap", &castleMechzShouldMoveToTrap);
	BehaviorTreeNetworkUtility::RegisterBehaviorTreeScriptAPI("castleMechzIsAtTrap", &castleMechzIsAtTrap);
	BehaviorTreeNetworkUtility::RegisterBehaviorTreeScriptAPI("castleMechzShouldAttackTrap", &castleMechzShouldAttackTrap);
	BehaviorTreeNetworkUtility::RegisterBehaviorTreeScriptAPI("genesisMechzShouldOctobombAttack", &genesisMechzShouldOctobombAttack);
	BehaviorTreeNetworkUtility::RegisterBehaviorTreeScriptAPI("casteMechzTrapMoveTerminate", &casteMechzTrapMoveTerminate);
	BehaviorTreeNetworkUtility::RegisterBehaviorTreeScriptAPI("casteMechzTrapAttackTerminate", &casteMechzTrapAttackTerminate);
	BehaviorTreeNetworkUtility::RegisterBehaviorTreeScriptAPI("genesisMechzDestoryOctobomb", &genesisMechzDestoryOctobomb);
	AnimationStateNetwork::RegisterAnimationMocomp("mocomp_trap_attack@mechz", &mechz_attack_trap_start, undefined, &mechz_attack_trap_end);
	AnimationStateNetwork::RegisterAnimationMocomp("mocomp_teleport_traversal@mechz", &mechz_teleport_Start, undefined, undefined);



	spawner::add_archetype_spawn_function("mechz", &tomb_spawn_function);
	level.mechz_claw_cooldown_time = 7000;
	level.mechz_left_arm_damage_callback = &function_671deda5;
	level.mechz_explosive_damage_reaction_callback = &function_6028875a;
	level.mechz_powercap_destroyed_callback = &function_d6f31ed2;
	level flag::init("mechz_launching_claw");
	level flag::init("mechz_claw_move_complete");
	
	clientfield::register("actor", "mechz_fx", VERSION_DLC5, 1, "int");
	clientfield::register("scriptmover", "mechz_claw", VERSION_DLC5, 1, "int");
	clientfield::register("actor", "mechz_wpn_source", VERSION_DLC5, 1, "int");
	clientfield::register("toplayer", "mechz_grab", VERSION_DLC5, 1, "int");
	clientfield::register("actor", "death_ray_shock_fx", 15000, 1, "int");	
	clientfield::register("actor", "mechz_fx_spawn", 15000, 1, "counter");

/*
	clientfield::register("actor", "sparky_zombie_spark_fx", 1, 1, "int");
	clientfield::register("actor", "sparky_zombie_death_fx", 1, 1, "int");
	clientfield::register("actor", "napalm_zombie_death_fx", 1, 1, "int");
	clientfield::register("actor", "sparky_damaged_fx", 1, 1, "counter");
	clientfield::register("actor", "napalm_damaged_fx", 1, 1, "counter");
	clientfield::register("actor", "napalm_sfx", 11000, 1, "int");
*/

}



function autoexec mechz_bow_damage_cuz_it_dont_work_by_default()
{
//im not dealing with this shit fuck off
level.var_76df55d3 = 1;
level.var_28066209 = 0;
level.var_f4dc2834 = 3062.5;
level.var_c1f907b2 = 1750;
level.var_42fd61f0 = 3500;

callback::on_connect(&function_c45ac6ae);

}



function function_c45ac6ae(var_6ab83514 = "elemental_bow", var_8f9bdf29 = "elemental_bow4", var_332bb697)
{
	if(!isdefined(var_332bb697))
	{
		var_332bb697 = undefined;
	}
	self endon("death");

	while(1)
	{
		self waittill("projectile_impact", weapon, v_position, radius, e_projectile, normal);
		//IPrintLnBold("damage");
		var_48369d98 = function_1796e73(weapon.name);
		if(var_48369d98 == var_6ab83514 || var_48369d98 == var_8f9bdf29)
		{

		self thread function_d2e32ed2(var_48369d98, v_position);

		}
	}
}




function function_d2e32ed2(var_48369d98, v_position)
{
	if(var_48369d98 === "elemental_bow_wolf_howl4")
	{
		return;
	}
	array::thread_all(GetAIArchetypeArray("mechz"), &function_b78fcfc7, self, var_48369d98, v_position);
}





function function_b78fcfc7(e_player, var_48369d98, v_position)
{
	var_2017780d = 0;
	var_c36342f3 = 0;
	var_377b9896 = 0;
	if(!IsSubStr(var_48369d98, "4"))
	{
		var_377b9896 = 1;
		var_3fa1565a = 9216;
		var_6594cbc3 = 96;
		var_f419b406 = 0.25;
	}
	else if(var_48369d98 == "elemental_bow4")
	{
		var_377b9896 = 1;
		var_3fa1565a = 20736;
		var_6594cbc3 = 144;
		var_f419b406 = 0.1;
	}
	var_7486069a = distancesquared(v_position, self.origin);
	var_7d984cf2 = distancesquared(v_position, self gettagorigin("j_neck"));
	if(var_7486069a < 1600 || var_7d984cf2 < 2304)
	{
		var_2017780d = 1;
		var_c36342f3 = 1;
	}
	else if(var_377b9896 && (var_7486069a < var_3fa1565a || var_7d984cf2 < var_3fa1565a))
	{
		var_2017780d = 1;
		var_c36342f3 = 1 - var_f419b406;
		if(var_7486069a < var_7d984cf2)
		{
		}
		else
		{
		}
		var_c36342f3 = var_7486069a * sqrt(var_7d984cf2) / var_6594cbc3;
		var_c36342f3 = 1 - var_c36342f3;
	}
	if(var_2017780d)
	{
		var_3bb42832 = level.mechz_health;
		if(isdefined(level.var_f4dc2834))
		{
			var_3bb42832 = math::clamp(var_3bb42832, 0, level.var_f4dc2834);
		}
		if(var_48369d98 == "elemental_bow")
		{
			var_26680fd5 = function_dc4f8831(0.15, 0.03);
		}
		else if(var_48369d98 == "elemental_bow4")
		{
			var_26680fd5 = function_dc4f8831(0.25, 0.12);
		}
		else if(!IsSubStr(var_48369d98, "4"))
		{
			var_26680fd5 = 0.1;
		}
		else
		{
			var_26680fd5 = 0.35;
		}
		var_40955aed = var_3bb42832 * var_26680fd5 / 0.2;
		var_40955aed = var_40955aed * var_c36342f3;
		self DoDamage(var_40955aed, self.origin, e_player, e_player, undefined, "MOD_PROJECTILE_SPLASH", 0, level.var_be94cdb);
	}
}



function function_dc4f8831(var_eaae98a2, var_c01c8d5c)
{
	if(level.mechz_health < level.var_c1f907b2)
	{
		var_26680fd5 = var_eaae98a2;
	}
	else if(level.mechz_health > level.var_42fd61f0)
	{
		var_26680fd5 = var_c01c8d5c;
	}
	else
	{
		var_d82dde4a = level.mechz_health - level.var_c1f907b2;
		var_caabb734 = var_d82dde4a / level.var_42ee1b54;
		var_26680fd5 = var_eaae98a2 - var_eaae98a2 - var_c01c8d5c * var_caabb734;
	}
	return var_26680fd5;
}



function function_1796e73(str_weapon_name)
{
	var_48369d98 = str_weapon_name;
	/*if(IsSubStr(var_48369d98, "ricochet"))
	{
		var_ae485cc2 = function_4d1b4da2(var_48369d98, "_ricochet");
		var_48369d98 = var_ae485cc2[0];
	}*/
	if(IsSubStr(var_48369d98, "2"))
	{
		var_48369d98 = strtok(var_48369d98, "2")[0];
	}
	if(IsSubStr(var_48369d98, "3"))
	{
		var_48369d98 = strtok(var_48369d98, "3")[0];
	}
	return var_48369d98;
}




function function_48cabef5()
{
	if(isdefined(self.customTraverseEndNode) && isdefined(self.customTraverseStartNode))
	{
		return self.customTraverseEndNode.script_noteworthy === "custom_traversal" && self.customTraverseStartNode.script_noteworthy === "custom_traversal";
	}
	return 0;
}

/*
	Name: function_3d5df242
	Namespace: zm_ai_mechz
	Checksum: 0xC8A7FC5D
	Offset: 0xD70
	Size: 0xE3
	Parameters: 0
	Flags: Private
*/
function private function_3d5df242()
{
	self.b_ignore_cleanup = 1;
	self.is_mechz = 1;
	self.var_7884b12d = self.health;
	self.team = level.zombie_team;
	self.zombie_lift_override = &function_817c85eb;
	self.thundergun_fling_func = &function_9bac2f00;
	self.thundergun_knockdown_func = &function_19b9b682;
	self.var_23340a5d = &function_9bac2f00;
	self.var_e1dbd63 = &function_19b9b682;
	self.var_48cabef5 = &function_48cabef5;
	level thread zm_spawner::zombie_death_event(self);
}

/*
	Name: function_ed70c868
	Namespace: zm_ai_mechz
	Checksum: 0x138FD51F
	Offset: 0xE60
	Size: 0x91
	Parameters: 10
	Flags: Private
*/
function private function_ed70c868(einflictor, eattacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, shitloc, psOffsetTime)
{
	if(isdefined(eattacker) && eattacker.archetype === "mechz" && sMeansOfDeath === "MOD_MELEE")
	{
		return 150;
	}
	return -1;
}

/*
	Name: function_58655f2a
	Namespace: zm_ai_mechz
	Checksum: 0x1CBB4EE6
	Offset: 0xF00
	Size: 0x31
	Parameters: 0
	Flags: None
*/
function function_58655f2a()
{
	if(!isdefined(self.stun) && self.stun && self.stumble_stun_cooldown_time < GetTime())
	{
		return 1;
	}
	return 0;
}

/*
	Name: function_9bac2f00
	Namespace: zm_ai_mechz
	Checksum: 0x7F52E823
	Offset: 0xF40
	Size: 0x67
	Parameters: 2
	Flags: None
*/
function function_9bac2f00(e_player, gib)
{
	self endon("death");
	self function_b8e0ce15(e_player);
	if(!isdefined(self.stun) && self.stun && self.stumble_stun_cooldown_time < GetTime())
	{
		self.stun = 1;
	}
}

/*
	Name: function_19b9b682
	Namespace: zm_ai_mechz
	Checksum: 0xF8494751
	Offset: 0xFB0
	Size: 0x67
	Parameters: 2
	Flags: None
*/
function function_19b9b682(e_player, gib)
{
	self endon("death");
	self function_b8e0ce15(e_player);
	if(!isdefined(self.stun) && self.stun && self.stumble_stun_cooldown_time < GetTime())
	{
		self.stun = 1;
	}
}

/*
	Name: function_b8e0ce15
	Namespace: zm_ai_mechz
	Checksum: 0x17BF523A
	Offset: 0x1020
	Size: 0xCB
	Parameters: 1
	Flags: None
*/
function function_b8e0ce15(e_player)
{
	var_3bb42832 = level.mechz_health;
	if(isdefined(level.var_f4dc2834))
	{
		var_3bb42832 = math::clamp(var_3bb42832, 0, level.var_f4dc2834);
	}
	n_damage = var_3bb42832 * 0.25 / 0.2;
	self DoDamage(n_damage, self GetCentroid(), e_player, e_player, undefined, "MOD_PROJECTILE_SPLASH", 0, GetWeapon("thundergun"));
}

/*
	Name: spawn_mechz
	Namespace: zm_ai_mechz
	Checksum: 0x9A47B505
	Offset: 0x10F8
	Size: 0x50F
	Parameters: 2
	Flags: None
*/
function spawn_mechz(s_location, flyin)
{
	if(!isdefined(flyin))
	{
		flyin = 0;
	}
	if(isdefined(level.mechz_spawners[0]))
	{
		if(isdefined(level.var_7f2a926d))
		{
			[[level.var_7f2a926d]]();
		}
		level.mechz_spawners[0].script_forcespawn = 1;
		ai = zombie_utility::spawn_zombie(level.mechz_spawners[0], "mechz", s_location);
		if(isdefined(ai))
		{
			ai DisableAimAssist();
			ai thread function_ef1ba7e5();
			ai thread function_949a3fdf();
			/#
				ai thread function_75a79bb5();
			#/
			ai.actor_damage_func = &MechzServerUtils::mechzDamageCallback;
			ai.damage_scoring_function = &function_b03abc02;
			ai.mechz_melee_knockdown_function = &function_55483494;
			ai.health = level.mechz_health;
			ai.faceplate_health = level.MECHZ_FACEPLATE_HEALTH;
			ai.powercap_cover_health = level.MECHZ_POWERCAP_COVER_HEALTH;
			ai.powercap_health = level.MECHZ_POWERCAP_HEALTH;
			ai.left_knee_armor_health = level.var_2cbc5b59;
			ai.right_knee_armor_health = level.var_2cbc5b59;
			ai.left_shoulder_armor_health = level.var_2cbc5b59;
			ai.right_shoulder_armor_health = level.var_2cbc5b59;
			ai.heroweapon_kill_power = 10;
			e_player = zm_utility::get_closest_player(s_location.origin);
			v_dir = e_player.origin - s_location.origin;
			v_dir = vectornormalize(v_dir);
			v_angles = VectorToAngles(v_dir);
			var_89f898ad = zm_utility::flat_angle(v_angles);
			var_6ea4ef96 = s_location;
			queryResult = PositionQuery_Source_Navigation(var_6ea4ef96.origin, 0, 32, 20, 4);
			if(queryResult.data.size)
			{
				v_ground_position = array::random(queryResult.data).origin;
			}
			if(!isdefined(v_ground_position))
			{
				trace = bullettrace(var_6ea4ef96.origin, var_6ea4ef96.origin + VectorScale((0, 0, -1), 256), 0, s_location);
				v_ground_position = trace["position"];
			}
			var_1750e965 = v_ground_position;
			if(isdefined(level.var_e1e49cc1))
			{
				ai thread [[level.var_e1e49cc1]]();
			}
			ai ForceTeleport(var_1750e965, var_89f898ad);
			if(flyin === 1)
			{
				ai thread function_d07fd448();
				ai thread scene::play("cin_zm_castle_mechz_entrance", ai);
				ai thread function_c441eaba(var_1750e965);
				ai thread function_bbdc1f34(var_1750e965);
			}
			else if(isdefined(level.var_7d2a391d))
			{
				ai thread [[level.var_7d2a391d]]();
			}
			ai.b_flyin_done = 1;
			ai thread function_bb048b27();
			ai.ignore_round_robbin_death = 1;
			/#
				ai.ignore_devgui_death = 1;
			#/
			return ai;
		}
	}
	return undefined;
}

/*
	Name: function_d07fd448
	Namespace: zm_ai_mechz
	Checksum: 0xD4416EA0
	Offset: 0x1610
	Size: 0x63
	Parameters: 0
	Flags: None
*/
function function_d07fd448()
{
	self endon("death");
	self.b_flyin_done = 0;
	self.bgbIgnoreFearInHeadlights = 1;
	self util::waittill_any("mechz_flyin_done", "scene_done");
	self.b_flyin_done = 1;
	self.bgbIgnoreFearInHeadlights = 0;
}

/*
	Name: function_c441eaba
	Namespace: zm_ai_mechz
	Checksum: 0x7E37640
	Offset: 0x1680
	Size: 0x34B
	Parameters: 1
	Flags: None
*/
function function_c441eaba(var_678a2319)
{
	self endon("death");
	var_b54110bd = 2304;
	var_f0dad551 = 9216;
	var_44615973 = 2250000;
	self waittill("hash_f93797a6");
	a_zombies = GetAIArchetypeArray("zombie");
	foreach(e_zombie in a_zombies)
	{
		dist_sq = distancesquared(e_zombie.origin, var_678a2319);
		if(dist_sq <= var_b54110bd)
		{
			e_zombie kill();
		}
	}
	a_players = GetPlayers();
	foreach(player in a_players)
	{
		dist_sq = distancesquared(player.origin, var_678a2319);
		if(dist_sq <= var_b54110bd)
		{
			player DoDamage(100, var_678a2319, self, self);
		}
		scale = var_44615973 - dist_sq / var_44615973;
		if(scale <= 0 || scale >= 1)
		{
			return;
		}
		earthquake_scale = scale * 0.15;
		earthquake(earthquake_scale, 0.1, var_678a2319, 1500);
		if(scale >= 0.66)
		{
			player PlayRumbleOnEntity("shotgun_fire");
			continue;
		}
		if(scale >= 0.33)
		{
			player PlayRumbleOnEntity("damage_heavy");
			continue;
		}
		player PlayRumbleOnEntity("reload_small");
	}
	if(isdefined(self.var_1411e129))
	{
		self.var_1411e129 delete();
	}
}

/*
	Name: function_bbdc1f34
	Namespace: zm_ai_mechz
	Checksum: 0xE3ED89A7
	Offset: 0x19D8
	Size: 0x27F
	Parameters: 1
	Flags: None
*/
function function_bbdc1f34(var_678a2319)
{
	self endon("death");
	self endon("hash_f93797a6");
	self waittill("hash_3d18ed4f");
	var_f0dad551 = 9216;
	while(1)
	{
		a_players = GetPlayers();
		foreach(player in a_players)
		{
			dist_sq = distancesquared(player.origin, var_678a2319);
			if(dist_sq <= var_f0dad551)
			{
				if(!isdefined(player.is_burning) && player.is_burning && zombie_utility::is_player_valid(player, 0))
				{
					player function_3389e2f3(self);
				}
			}
		}
		a_zombies = array::filter( getAIArchetypeArray( "zombie" ), 0, &function_b804eb62 );
		foreach(e_zombie in a_zombies)
		{
			dist_sq = distancesquared(e_zombie.origin, var_678a2319);
			if(dist_sq <= var_f0dad551 && self.var_e05d0be2 !== 1)
			{
				self function_3efae612(e_zombie);
				e_zombie make_napalm_zombie();
			}
		}
		wait(0.1);
	}
}

function function_b804eb62(ai_zombie)
{
	return ai_zombie.is_elemental_zombie !== 1;
}


/*
	Name: function_3389e2f3
	Namespace: zm_ai_mechz
	Checksum: 0xE270D828
	Offset: 0x1C60
	Size: 0xDF
	Parameters: 1
	Flags: None
*/
function function_3389e2f3(mechz)
{
	if(!isdefined(self.is_burning) && self.is_burning && zombie_utility::is_player_valid(self, 1))
	{
		self.is_burning = 1;
		if(!self hasPerk("specialty_armorvest"))
		{
			self burnplayer::SetPlayerBurning(1.5, 0.5, 30, mechz, undefined);
		}
		else
		{
			self burnplayer::SetPlayerBurning(1.5, 0.5, 20, mechz, undefined);
		}
		wait(1.5);
		self.is_burning = 0;
	}
}

/*
	Name: function_817c85eb
	Namespace: zm_ai_mechz
	Checksum: 0xDAA3C3AB
	Offset: 0x1D48
	Size: 0x2C7
	Parameters: 6
	Flags: None
*/
function function_817c85eb(e_player, v_attack_source, n_push_away, n_lift_height, v_lift_offset, n_lift_speed)
{
	self endon("death");
	if(isdefined(self.in_gravity_trap) && self.in_gravity_trap && e_player.gravityspikes_state === 3)
	{
		if(isdefined(self.var_1f5fe943) && self.var_1f5fe943)
		{
			return;
		}
		self.var_bcecff1d = 1;
		self.var_1f5fe943 = 1;
		self DoDamage(10, self.origin);
		self.var_ab0efcf6 = self.origin;
		self thread scene::play("cin_zm_dlc1_mechz_dth_deathray_01", self);
		self clientfield::set("sparky_beam_fx", 1);
		self clientfield::set("death_ray_shock_fx", 1);
		self playsound("zmb_talon_electrocute");
		n_start_time = GetTime();
		for(n_total_time = 0; 10 > n_total_time && e_player.gravityspikes_state === 3;  n_total_time++)
		{
			util::wait_network_frame();
		}
		self scene::stop("cin_zm_dlc1_mechz_dth_deathray_01");
		self thread function_bb84a54(self);
		self clientfield::set("sparky_beam_fx", 0);
		self clientfield::set("death_ray_shock_fx", 0);
		self.var_bcecff1d = undefined;
		while(e_player.gravityspikes_state === 3)
		{
			util::wait_network_frame();
		}
		self.var_1f5fe943 = undefined;
		self.in_gravity_trap = undefined;
	}
	else
	{
		self DoDamage(10, self.origin);
		if(!(isdefined(self.stun) && self.stun))
		{
			self.stun = 1;
		}
	}
}

/*
	Name: function_bb84a54
	Namespace: zm_ai_mechz
	Checksum: 0x6CFD4C09
	Offset: 0x2018
	Size: 0x1A3
	Parameters: 1
	Flags: None
*/
function function_bb84a54(mechz)
{
	mechz endon("death");
	if(isdefined(mechz))
	{
		mechz scene::play("cin_zm_dlc1_mechz_dth_deathray_02", mechz);
	}
	if(isdefined(mechz) && isalive(mechz) && isdefined(mechz.var_ab0efcf6))
	{
		v_eye_pos = mechz gettagorigin("tag_eye");
		/#
			recordLine(mechz.origin, v_eye_pos, VectorScale((0, 1, 0), 255), "Dev Block strings are not supported", mechz);
		#/
		trace = bullettrace(v_eye_pos, mechz.origin, 0, mechz);
		if(trace["position"] !== mechz.origin)
		{
			point = GetClosestPointOnNavMesh(trace["position"], 64, 30);
			if(!isdefined(point))
			{
				point = mechz.var_ab0efcf6;
			}
			mechz ForceTeleport(point);
		}
	}
}

/*
	Name: function_1add8026
	Namespace: zm_ai_mechz
	Checksum: 0x42984563
	Offset: 0x21C8
	Size: 0x101
	Parameters: 1
	Flags: None
*/
function function_1add8026(mechz)
{
	flameTrigger = mechz.flameTrigger;
	a_zombies = array::filter( getAIArchetypeArray( "zombie" ), 0, &function_b804eb62 );
	foreach(zombie in a_zombies)
	{
		if(zombie istouching(flameTrigger) && zombie.var_e05d0be2 !== 1)
		{
			zombie make_napalm_zombie();
		}
	}
}


function make_napalm_zombie()
{
	if(isdefined(self))
	{
		ai_zombie = self;
		var_ac4641b = function_4aeed0a5("napalm");
		if(!isdefined(level.var_bd64e31e) || var_ac4641b < level.var_bd64e31e)
		{
			if(!isdefined(ai_zombie.is_elemental_zombie) || ai_zombie.is_elemental_zombie == 0)
			{
				ai_zombie.is_elemental_zombie = 1;
				ai_zombie.var_9a02a614 = "napalm";
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
	Name: function_e6cd7e78
	Namespace: namespace_57695b4d
	Checksum: 0x93CF4833
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


function function_c50e890f(type)
{
	a_zombies = GetAIArchetypeArray("zombie");
	a_filtered_zombies = Array::filter(a_zombies, 0, &function_361f6caa, type);
	return a_filtered_zombies;
}


function function_4aeed0a5(type)
{
	a_zombies = function_c50e890f(type);
	return a_zombies.size;
}


function function_361f6caa(ai_zombie, type)
{
	return ai_zombie.var_9a02a614 === type;
}



/*
	Name: function_ef1ba7e5
	Namespace: zm_ai_mechz
	Checksum: 0x6ECF0982
	Offset: 0x22D8
	Size: 0x9F
	Parameters: 0
	Flags: None
*/
function function_ef1ba7e5()
{
	self waittill("death");
	if(isplayer(self.attacker))
	{
		event = "death_mechz";
		if(!(isdefined(self.deathpoints_already_given) && self.deathpoints_already_given))
		{
			self.attacker zm_score::player_add_points(event, 1500);
		}
		if(isdefined(level.hero_power_update))
		{
			[[level.hero_power_update]](self.attacker, self);
		}
	}
}

/*
	Name: function_949a3fdf
	Namespace: zm_ai_mechz
	Checksum: 0xC9753F16
	Offset: 0x2380
	Size: 0x171
	Parameters: 0
	Flags: None
*/
function function_949a3fdf()
{
	self waittill("hash_46c1e51d");
	v_origin = self.origin;
	a_ai = GetAISpeciesArray(level.zombie_team);
	a_ai_kill_zombies = ArraySortClosest(a_ai, v_origin, 18, 0, 200);
	foreach(ai_enemy in a_ai_kill_zombies)
	{
		if(isdefined(ai_enemy))
		{
			if(ai_enemy.archetype === "mechz")
			{
				ai_enemy DoDamage(level.mechz_health * 0.25, v_origin);
			}
			else
			{
				ai_enemy DoDamage(ai_enemy.health + 100, v_origin);
			}
		}
		wait(0.05);
	}
}

/*
	Name: function_b03abc02
	Namespace: zm_ai_mechz
	Checksum: 0xD98EAD1A
	Offset: 0x2500
	Size: 0x10B
	Parameters: 12
	Flags: None
*/
function function_b03abc02(inflictor, attacker, damage, dFlags, mod, weapon, point, dir, hitloc, offsetTime, boneIndex, modelIndex)
{
	if(isdefined(attacker) && isplayer(attacker))
	{
		if(zm_spawner::player_using_hi_score_weapon(attacker))
		{
			damage_type = "damage";
		}
		else
		{
			damage_type = "damage_light";
		}
		if(!(isdefined(self.no_damage_points) && self.no_damage_points))
		{
			attacker zm_score::player_add_points(damage_type, mod, hitloc, self.isdog, self.team, weapon);
		}
	}
}

/*
	Name: function_3efae612
	Namespace: zm_ai_mechz
	Checksum: 0x6D1727E3
	Offset: 0x2618
	Size: 0x2A3
	Parameters: 1
	Flags: None
*/
function function_3efae612(zombie)
{
	zombie.knockdown = 1;
	zombie.knockdown_type = "knockdown_shoved";
	zombie_to_mechz = self.origin - zombie.origin;
	zombie_to_mechz_2d = vectornormalize((zombie_to_mechz[0], zombie_to_mechz[1], 0));
	zombie_forward = AnglesToForward(zombie.angles);
	zombie_forward_2d = vectornormalize((zombie_forward[0], zombie_forward[1], 0));
	zombie_right = AnglesToRight(zombie.angles);
	zombie_right_2d = vectornormalize((zombie_right[0], zombie_right[1], 0));
	dot = VectorDot(zombie_to_mechz_2d, zombie_forward_2d);
	if(dot >= 0.5)
	{
		zombie.knockdown_direction = "front";
		zombie.getup_direction = "getup_back";
	}
	else if(dot < 0.5 && dot > -0.5)
	{
		dot = VectorDot(zombie_to_mechz_2d, zombie_right_2d);
		if(dot > 0)
		{
			zombie.knockdown_direction = "right";
			if(math::cointoss())
			{
				zombie.getup_direction = "getup_back";
			}
			else
			{
				zombie.getup_direction = "getup_belly";
			}
		}
		else
		{
			zombie.knockdown_direction = "left";
			zombie.getup_direction = "getup_belly";
		}
	}
	else
	{
		zombie.knockdown_direction = "back";
		zombie.getup_direction = "getup_belly";
	}
}

/*
	Name: function_55483494
	Namespace: zm_ai_mechz
	Checksum: 0x8DDC6FC8
	Offset: 0x28C8
	Size: 0x109
	Parameters: 0
	Flags: None
*/
function function_55483494()
{
	a_zombies = GetAIArchetypeArray("zombie");
	foreach(zombie in a_zombies)
	{
		dist_sq = distancesquared(self.origin, zombie.origin);
		if(zombie function_10d36217(self) && dist_sq <= 12544)
		{
			self function_3efae612(zombie);
		}
	}
}

/*
	Name: function_10d36217
	Namespace: zm_ai_mechz
	Checksum: 0x97014B61
	Offset: 0x29E0
	Size: 0x183
	Parameters: 1
	Flags: None
*/
function function_10d36217(mechz)
{
	origin = self.origin;
	facing_vec = AnglesToForward(mechz.angles);
	enemy_vec = origin - mechz.origin;
	enemy_yaw_vec = (enemy_vec[0], enemy_vec[1], 0);
	facing_yaw_vec = (facing_vec[0], facing_vec[1], 0);
	enemy_yaw_vec = vectornormalize(enemy_yaw_vec);
	facing_yaw_vec = vectornormalize(facing_yaw_vec);
	enemy_dot = VectorDot(facing_yaw_vec, enemy_yaw_vec);
	if(enemy_dot < 0.7)
	{
		return 0;
	}
	enemy_angles = VectorToAngles(enemy_vec);
	if(Abs(AngleClamp180(enemy_angles[0])) > 45)
	{
		return 0;
	}
	return 1;
}

/*
	Name: function_bb048b27
	Namespace: zm_ai_mechz
	Checksum: 0x433026DB
	Offset: 0x2B70
	Size: 0x57
	Parameters: 0
	Flags: None
*/
function function_bb048b27()
{
	self endon("death");
	while(1)
	{
		wait(randomintrange(9, 14));
		self playsound("zmb_ai_mechz_vox_ambient");
	}
}

/*
	Name: function_75a79bb5
	Namespace: zm_ai_mechz
	Checksum: 0xEEE038CF
	Offset: 0x2BD0
	Size: 0x97
	Parameters: 0
	Flags: None
*/
function function_75a79bb5()
{
	self endon("death");
	/#
		while(1)
		{
			if(isdefined(level.var_70068a8) && level.var_70068a8)
			{
				if(self.health > 0)
				{
					print3d(self.origin + VectorScale((0, 0, 1), 72), self.health, (0, 0.8, 0.6), 3);
				}
			}
			wait(0.05);
		}
	#/
}

/*
	Name: function_fbad70fd
	Namespace: zm_ai_mechz
	Checksum: 0xF8F6CEC
	Offset: 0x2C70
	Size: 0x43
	Parameters: 0
	Flags: Private
*/
function private function_fbad70fd()
{
	/#
		level flagsys::wait_till("Dev Block strings are not supported");
		//zm_devgui::function_4acecab5(&function_94a24a91);
	#/
}

/*
	Name: function_94a24a91
	Namespace: zm_ai_mechz
	Checksum: 0xA825197A
	Offset: 0x2CC0
	Size: 0x40D
	Parameters: 1
	Flags: Private
*/
function private function_94a24a91(cmd)
{
	/#
		players = GetPlayers();
		var_6aad1b23 = getentarray("Dev Block strings are not supported", "Dev Block strings are not supported");
		mechz = ArrayGetClosest(GetPlayers()[0].origin, var_6aad1b23);
		switch(cmd)
		{
			case "Dev Block strings are not supported":
			{
				queryResult = PositionQuery_Source_Navigation(players[0].origin, 128, 256, 128, 20);
				spot = spawnstruct();
				spot.origin = players[0].origin;
				if(isdefined(queryResult) && queryResult.data.size > 0)
				{
					spot.origin = queryResult.data[0].origin;
				}
				mechz = spawn_mechz(spot);
				break;
			}
			case "Dev Block strings are not supported":
			{
				if(!isdefined(level.zm_loc_types["Dev Block strings are not supported"]) || level.zm_loc_types["Dev Block strings are not supported"].size == 0)
				{
					iprintln("Dev Block strings are not supported");
				}
				spot = ArrayGetClosest(GetPlayers()[0].origin, level.zm_loc_types["Dev Block strings are not supported"]);
				if(isdefined(spot))
				{
					mechz = spawn_mechz(spot, 1);
				}
				else
				{
					iprintln("Dev Block strings are not supported");
				}
				break;
			}
			case "Dev Block strings are not supported":
			{
				if(isdefined(mechz))
				{
					mechz kill();
				}
				break;
			}
			case "Dev Block strings are not supported":
			{
				if(isdefined(mechz))
				{
					if(isdefined(mechz.shoot_grenade))
					{
						mechz.shoot_grenade = !mechz.shoot_grenade;
					}
					else
					{
						mechz.shoot_grenade = 1;
					}
				}
				break;
			}
			case "Dev Block strings are not supported":
			{
				if(isdefined(mechz))
				{
					if(isdefined(mechz.shoot_flame))
					{
						mechz.shoot_flame = !mechz.shoot_flame;
					}
					else
					{
						mechz.shoot_flame = 1;
					}
				}
				break;
			}
			case "Dev Block strings are not supported":
			{
				if(isdefined(mechz))
				{
					mechz.berserk = 1;
				}
				break;
			}
			case "Dev Block strings are not supported":
			{
				if(!(isdefined(level.var_70068a8) && level.var_70068a8))
				{
					level.var_70068a8 = 1;
				}
				else
				{
					level.var_70068a8 = 0;
				}
				break;
			}
			case "Dev Block strings are not supported":
			{
				if(!(isdefined(level.b_mechz_true_ignore) && level.b_mechz_true_ignore))
				{
					level.b_mechz_true_ignore = 1;
				}
				else
				{
					level.b_mechz_true_ignore = 0;
				}
				break;
			}
		}
	#/
}




function private mechzShouldShootClaw(entity)
{
	if(!isdefined(entity.favoriteenemy))
	{
		return 0;
	}
	if(!(isdefined(entity.has_powercap) && entity.has_powercap))
	{
		return 0;
	}
	if(isdefined(entity.last_claw_time) && GetTime() - self.last_claw_time < level.mechz_claw_cooldown_time)
	{
		return 0;
	}
	if(isdefined(entity.Berserk) && entity.Berserk)
	{
		return 0;
	}
	if(!entity MechzServerUtils::mechzCheckInArc())
	{
		return 0;
	}
	dist_sq = DistanceSquared(entity.origin, entity.favoriteenemy.origin);
	if(dist_sq < 40000 || dist_sq > 1000000)
	{
		return 0;
	}
	if(!entity.favoriteenemy player_can_be_grabbed())
	{
		return 0;
	}
	curr_zone = zm_zonemgr::get_zone_from_position(self.origin + VectorScale((0, 0, 1), 36));
	if(isdefined(curr_zone) && "ug_bottom_zone" == curr_zone)
	{
		return 0;
	}
	clip_mask = 1 | 8;
	claw_origin = entity.origin + VectorScale((0, 0, 1), 65);
	trace = PhysicsTrace(claw_origin, entity.favoriteenemy.origin + VectorScale((0, 0, 1), 30), (-15, -15, -20), (15, 15, 40), entity, clip_mask);
	b_cansee = trace["fraction"] == 1 || (isdefined(trace["entity"]) && trace["entity"] == entity.favoriteenemy);
	if(!b_cansee)
	{
		return 0;
	}
}



function private player_can_be_grabbed()
{
	if(self GetStance() == "prone")
	{
		return 0;
	}
	if(!zm_utility::is_player_valid(self))
	{
		return 0;
	}
	return 1;
}

function private zmMechzShootClawActionStart(entity, asmStateName)
{
	AnimationStateNetworkUtility::RequestState(entity, asmStateName);
	zmMechzShootClaw(entity);
	return 5;
}


function private zmMechzShootClawActionUpdate(entity, asmStateName)
{
	if(!(isdefined(entity.var_7bee990f) && entity.var_7bee990f))
	{
		return 4;
	}
	return 5;
}


function private zmMechzShootClawActionEnd(entity, asmStateName)
{
	return 4;
}


function private zmMechzShootClaw(entity)
{
	self thread function_31c4b972();
	level flag::set("mechz_launching_claw");
}


function private zmMechzUpdateClaw(entity)
{
}


function private zmMechzStopClaw(entity)
{
}


function private muzzleflash(entity)
{
	self.var_7bee990f = 1;
	self.last_claw_time = GetTime();
	entity function_672f9804();
	entity function_90832db7();
	self.last_claw_time = GetTime();
}

/*
	Name: function_48c03479
	Namespace: namespace_19d9d56d
	Checksum: 0x4E70C510
	Offset: 0x10C0
	Size: 0x63
	Parameters: 1
	Flags: Private
*/
function private start_ft(entity)
{
	entity notify("hash_8225d137");
	entity clientfield::set("mechz_ft", 1);
	entity.isShootingFlame = 1;
	entity thread function_fa513ca0();
}

/*
	Name: function_fa513ca0
	Namespace: namespace_19d9d56d
	Checksum: 0xC2AC5BEF
	Offset: 0x1130
	Size: 0x117
	Parameters: 0
	Flags: Private
*/
function private function_fa513ca0()
{
	self endon("death");
	self endon("hash_8225d137");
	while(1)
	{
		players = GetPlayers();
		foreach(player in players)
		{
			if(!(isdefined(player.is_burning) && player.is_burning))
			{
				if(player istouching(self.flameTrigger))
				{
					player thread MechzBehavior::playerFlameDamage(self);
				}
			}
		}
		wait(0.05);
	}
}


function private stop_ft(entity)
{
	entity notify("hash_8225d137");
	entity clientfield::set("mechz_ft", 0);
	entity.isShootingFlame = 0;
	entity.nextFlameTime = GetTime() + 7500;
	entity.stopShootingFlameTime = undefined;
}

/*
	Name: function_1aacf7d4
	Namespace: namespace_19d9d56d
	Checksum: 0xD1A9ED74
	Offset: 0x12D0
	Size: 0x2EB
	Parameters: 0
	Flags: Private
*/
function private tomb_spawn_function()
{
wait 0.2;

if(self.targetname != "mechz_tomb")
	return;

	if(isdefined(self.m_claw))
	{
		self.m_claw delete();
		self.m_claw = undefined;
	}
	self.fx_field = 0;
	org = self GetTagOrigin("tag_claw");
	ang = self GetTagAngles("tag_claw");
	self.m_claw = spawn("script_model", org);
	self.m_claw SetModel("c_t7_zm_dlchd_origins_mech_claw_lod0");
	self.m_claw.angles = ang;
	self.m_claw LinkTo(self, "tag_claw");
	self.m_claw useanimtree(-1);
	if(isdefined(self.m_claw_damage_trigger))
	{
		self.m_claw_damage_trigger Unlink();
		self.m_claw_damage_trigger delete();
		self.m_claw_damage_trigger = undefined;
	}
	trigger_spawnflags = 0;
	trigger_radius = 3;
	trigger_height = 15;
	self.m_claw_damage_trigger = spawn("script_model", org);
	self.m_claw_damage_trigger SetModel("p7_chemistry_kit_large_bottle");
	ang = combineangles(VectorScale((-1, 0, 0), 90), ang);
	self.m_claw_damage_trigger.angles = ang;
	self.m_claw_damage_trigger Hide();
	self.m_claw_damage_trigger SetCanDamage(1);
	self.m_claw_damage_trigger.health = 10000;
	self.m_claw_damage_trigger EnableLinkTo();
	self.m_claw_damage_trigger LinkTo(self, "tag_claw");
	self thread function_5dfc412a();
	self HidePart("tag_claw");
}

/*
	Name: function_5dfc412a
	Namespace: namespace_19d9d56d
	Checksum: 0x34E549BA
	Offset: 0x15C8
	Size: 0x165
	Parameters: 0
	Flags: Private
*/
function private function_5dfc412a()
{
	self endon("death");
	self.m_claw_damage_trigger endon("death");
	while(1)
	{
		self.m_claw_damage_trigger waittill("damage", amount, inflictor, direction, point, type, tagName, modelName, partName, weaponName, iDFlags);
		self.m_claw_damage_trigger.health = 10000;
		if(self.m_claw islinkedto(self))
		{
			continue;
		}
		if(zm_utility::is_player_valid(inflictor))
		{
			self DoDamage(1, inflictor.origin, inflictor, inflictor, "left_hand", type);
			self.m_claw SetCanDamage(0);
			self notify("claw_damaged");
		}
	}
}

/*
	Name: function_31c4b972
	Namespace: namespace_19d9d56d
	Checksum: 0x4AB73000
	Offset: 0x1738
	Size: 0x4B
	Parameters: 0
	Flags: Private
*/
function private function_31c4b972()
{
	self endon("claw_complete");
	self util::waittill_either("death", "kill_claw");
	self function_90832db7();
}

/*
	Name: function_90832db7
	Namespace: namespace_19d9d56d
	Checksum: 0x3488FB5D
	Offset: 0x1790
	Size: 0x3C3
	Parameters: 0
	Flags: Private
*/
function private function_90832db7()
{
		self.fx_field = self.fx_field & 256;
	self.fx_field = self.fx_field & 64;
	//self clientfield::set("mechz_fx", self.fx_field);
	self function_9bfd96c8();
	if(isdefined(self.m_claw))
	{
		self.m_claw ClearAnim(%root, 0.2);
		if(isdefined(self.m_claw.fx_ent))
		{
			self.m_claw.fx_ent delete();
			self.m_claw.fx_ent = undefined;
		}
		if(!(isdefined(self.has_powercap) && self.has_powercap))
		{
			self function_4208b4ec();
			level flag::clear("mechz_launching_claw");
		}
		else if(!self.m_claw islinkedto(self))
		{
			v_claw_origin = self GetTagOrigin("tag_claw");
			v_claw_angles = self GetTagAngles("tag_claw");
			n_dist = Distance(self.m_claw.origin, v_claw_origin);
			n_time = n_dist / 1000;
			self.m_claw moveto(v_claw_origin, max(0.05, n_time));
			self.m_claw PlayLoopSound("zmb_ai_mechz_claw_loop_in", 0.1);
			self.m_claw waittill("movedone");
			v_claw_origin = self GetTagOrigin("tag_claw");
			v_claw_angles = self GetTagAngles("tag_claw");
			self.m_claw playsound("zmb_ai_mechz_claw_back");
			self.m_claw StopLoopSound(1);
			self.m_claw.origin = v_claw_origin;
			self.m_claw.angles = v_claw_angles;
			self.m_claw ClearAnim(%root, 0.2);
			self.m_claw LinkTo(self, "tag_claw", (0, 0, 0));
		}
		self.m_claw SetAnim(%ai_zombie_mech_grapple_arm_closed_idle, 1, 0.2, 1);
	}
	self notify("claw_complete");
	self.var_7bee990f = 0;
}

/*
	Name: function_4208b4ec
	Namespace: namespace_19d9d56d
	Checksum: 0xC95B0CC8
	Offset: 0x1B60
	Size: 0x135
	Parameters: 0
	Flags: Private
*/
function private function_4208b4ec()
{
	if(isdefined(self.m_claw))
	{
		self.m_claw SetAnim(%ai_zombie_mech_grapple_arm_open_idle, 1, 0.2, 1);
		if(isdefined(self.m_claw.fx_ent))
		{
			self.m_claw.fx_ent delete();
		}
		self.m_claw Unlink();
		self.m_claw PhysicsLaunch(self.m_claw.origin, (0, 0, -1));
		self.m_claw thread function_36db86b();
		self.m_claw = undefined;
	}
	if(isdefined(self.m_claw_damage_trigger))
	{
		self.m_claw_damage_trigger Unlink();
		self.m_claw_damage_trigger delete();
		self.m_claw_damage_trigger = undefined;
	}
}

/*
	Name: function_36db86b
	Namespace: namespace_19d9d56d
	Checksum: 0x170A4A0C
	Offset: 0x1CA0
	Size: 0x1B
	Parameters: 0
	Flags: Private
*/
function private function_36db86b()
{
	wait(30);
	self delete();
}

/*
	Name: function_9bfd96c8
	Namespace: namespace_19d9d56d
	Checksum: 0x3726CB94
	Offset: 0x1CC8
	Size: 0x1DB
	Parameters: 1
	Flags: Private
*/
function private function_9bfd96c8(bopenclaw)
{
	self.explosive_dmg_taken_on_grab_start = undefined;
	if(isdefined(self.e_grabbed))
	{
		if(isPlayer(self.e_grabbed))
		{
			self.e_grabbed clientfield::set_to_player("mechz_grab", 0);
			self.e_grabbed AllowCrouch(1);
			self.e_grabbed AllowProne(1);
		}
		if(!isdefined(self.e_grabbed._fall_down_anchor))
		{
			trace_start = self.e_grabbed.origin + VectorScale((0, 0, 1), 70);
			trace_end = self.e_grabbed.origin + VectorScale((0, 0, -1), 500);
			drop_trace = playerphysicstrace(trace_start, trace_end) + VectorScale((0, 0, 1), 24);
			self.e_grabbed Unlink();
			self.e_grabbed SetOrigin(drop_trace);
		}
		self.e_grabbed = undefined;
		if(isdefined(bopenclaw) && bopenclaw)
		{
			self.m_claw SetAnim(%ai_zombie_mech_grapple_arm_open_idle, 1, 0.2, 1);
		}
	}
}

/*
	Name: function_7c33f4fb
	Namespace: namespace_19d9d56d
	Checksum: 0x821DF5F5
	Offset: 0x1EB0
	Size: 0x2B
	Parameters: 0
	Flags: Private
*/
function private function_7c33f4fb()
{
	if(!isdefined(self.explosive_dmg_taken))
	{
		self.explosive_dmg_taken = 0;
	}
	self.explosive_dmg_taken_on_grab_start = self.explosive_dmg_taken;
}

/*
	Name: function_d6f31ed2
	Namespace: namespace_19d9d56d
	Checksum: 0x941D14BB
	Offset: 0x1EE8
	Size: 0x3B
	Parameters: 0
	Flags: Private
*/
function private function_d6f31ed2()
{
	self MechzServerUtils::hide_part("tag_claw");
	self.m_claw Hide();
}

/*
	Name: function_5f5eaf3a
	Namespace: namespace_19d9d56d
	Checksum: 0xA7799255
	Offset: 0x1F30
	Size: 0xAB
	Parameters: 1
	Flags: Private
*/
function private function_5f5eaf3a(ai_mechz)
{
	self endon("disconnect");
	self zm_audio::create_and_play_dialog("general", "mech_grab");
	while(isdefined(self) && (isdefined(self.isSpeaking) && self.isSpeaking))
	{
		wait(0.1);
	}
	wait(1);
	if(isalive(ai_mechz) && isdefined(ai_mechz.e_grabbed))
	{
		ai_mechz thread play_shoot_arm_hint_vo();
	}
}

/*
	Name: play_shoot_arm_hint_vo
	Namespace: namespace_19d9d56d
	Checksum: 0xBA759057
	Offset: 0x1FE8
	Size: 0x187
	Parameters: 0
	Flags: Private
*/
function private play_shoot_arm_hint_vo()
{
	self endon("death");
	while(1)
	{
		if(!isdefined(self.e_grabbed))
		{
			return;
		}
		a_players = GetPlayers();
		foreach(player in a_players)
		{
			if(player == self.e_grabbed)
			{
				continue;
			}
			if(DistanceSquared(self.origin, player.origin) < 1000000)
			{
				if(player util::is_player_looking_at(self.origin + VectorScale((0, 0, 1), 60), 0.75))
				{
					if(!(isdefined(player.dontspeak) && player.dontspeak))
					{
						player zm_audio::create_and_play_dialog("general", "shoot_mech_arm");
						return;
					}
				}
			}
		}
		wait(0.1);
	}
}

/*
	Name: function_671deda5
	Namespace: namespace_19d9d56d
	Checksum: 0x75701F2F
	Offset: 0x2178
	Size: 0x2B
	Parameters: 0
	Flags: Private
*/
function private function_671deda5()
{
	if(isdefined(self.e_grabbed))
	{
		self thread function_9bfd96c8(1);
	}
}

/*
	Name: function_6028875a
	Namespace: namespace_19d9d56d
	Checksum: 0x34B66BA7
	Offset: 0x21B0
	Size: 0x5B
	Parameters: 0
	Flags: Private
*/
function private function_6028875a()
{
	if(isdefined(self.explosive_dmg_taken_on_grab_start))
	{
		if(isdefined(self.e_grabbed) && self.explosive_dmg_taken - self.explosive_dmg_taken_on_grab_start > self.mechz_explosive_dmg_to_cancel_claw)
		{
			self.show_pain_from_explosive_dmg = 1;
			self thread function_9bfd96c8();
		}
	}
}

/*
	Name: function_8b0a73b5
	Namespace: namespace_19d9d56d
	Checksum: 0x169F6E1E
	Offset: 0x2218
	Size: 0x93
	Parameters: 1
	Flags: Private
*/
function private function_8b0a73b5(mechz)
{
	self endon("death");
	self endon("disconnect");
	mechz endon("death");
	mechz endon("claw_complete");
	mechz endon("kill_claw");
	while(1)
	{
		if(isdefined(self) && self laststand::player_is_in_laststand())
		{
			mechz thread function_9bfd96c8();
			return;
		}
		wait(0.05);
	}
}

/*
	Name: function_bed84b4
	Namespace: namespace_19d9d56d
	Checksum: 0xE32C1EFF
	Offset: 0x22B8
	Size: 0x91
	Parameters: 1
	Flags: Private
*/
function private function_bed84b4(mechz)
{
	self endon("death");
	self endon("disconnect");
	mechz endon("death");
	mechz endon("claw_complete");
	mechz endon("kill_claw");
	while(1)
	{
		self waittill("hash_10c37787");
		if(isdefined(self) && self.bgb === "zm_bgb_anywhere_but_here")
		{
			mechz thread function_9bfd96c8();
			return;
		}
	}
}

/*
	Name: function_38d105a4
	Namespace: namespace_19d9d56d
	Checksum: 0xF69E84FF
	Offset: 0x2358
	Size: 0x79
	Parameters: 1
	Flags: Private
*/
function private function_38d105a4(mechz)
{
	self endon("death");
	self endon("disconnect");
	mechz endon("death");
	mechz endon("claw_complete");
	mechz endon("kill_claw");
	while(1)
	{
		self waittill("hash_e2be4752");
		mechz thread function_9bfd96c8();
		return;
	}
}

/*
	Name: function_672f9804
	Namespace: namespace_19d9d56d
	Checksum: 0xF302A04C
	Offset: 0x23E0
	Size: 0xE4B
	Parameters: 0
	Flags: Private
*/
function private function_672f9804()
{
	self endon("death");
	self endon("kill_claw");
	if(!isdefined(self.favoriteenemy))
	{
		return;
	}
	v_claw_origin = self GetTagOrigin("tag_claw");
	v_claw_angles = VectorToAngles(self.origin - self.favoriteenemy.origin);
	self.fx_field = self.fx_field | 256;
	//self clientfield::set("mechz_fx", self.fx_field);
	self.m_claw SetAnim(%ai_zombie_mech_grapple_arm_open_idle, 1, 0, 1);
	self.m_claw Unlink();
	self.m_claw.fx_ent = spawn("script_model", self.m_claw GetTagOrigin("tag_claw"));
	self.m_claw.fx_ent.angles = self.m_claw GetTagAngles("tag_claw");
	self.m_claw.fx_ent SetModel("tag_origin");
	self.m_claw.fx_ent LinkTo(self.m_claw, "tag_claw");
	self.m_claw.fx_ent clientfield::set("mechz_claw", 1);
	self clientfield::set("mechz_wpn_source", 1);
	v_enemy_origin = self.favoriteenemy.origin + VectorScale((0, 0, 1), 36);
	n_dist = Distance(v_claw_origin, v_enemy_origin);
	n_time = n_dist / 1200;
	self playsound("zmb_ai_mechz_claw_fire");
	self.m_claw moveto(v_enemy_origin, n_time);
	self.m_claw thread function_2998f2a1();
	self.m_claw PlayLoopSound("zmb_ai_mechz_claw_loop_out", 0.1);
	self.e_grabbed = undefined;
	do
	{
		a_players = GetPlayers();
		foreach(player in a_players)
		{
			if(!zm_utility::is_player_valid(player, 1, 1) || !player player_can_be_grabbed())
			{
				continue;
			}
			n_dist_sq = DistanceSquared(player.origin + VectorScale((0, 0, 1), 36), self.m_claw.origin);
			if(n_dist_sq < 2304)
			{
				clip_mask = 1 | 8;
				var_7d76644b = self.origin + VectorScale((0, 0, 1), 65);
				trace = PhysicsTrace(var_7d76644b, player.origin + VectorScale((0, 0, 1), 30), (-15, -15, -20), (15, 15, 40), self, clip_mask);
				b_cansee = trace["fraction"] == 1 || (isdefined(trace["entity"]) && trace["entity"] == player);
				if(!b_cansee)
				{
					continue;
				}
				if(isdefined(player.hasRiotShield) && player.hasRiotShield && (isdefined(player.hasRiotShieldEquipped) && player.hasRiotShieldEquipped))
				{
					shield_dmg = level.zombie_vars["riotshield_hit_points"];
					player riotshield::player_damage_shield(shield_dmg - 1, 1);
					wait(1);
					player riotshield::player_damage_shield(1, 1);
				}
				else
				{
					self.e_grabbed = player;
					self.e_grabbed clientfield::set_to_player("mechz_grab", 1);
					self.e_grabbed PlayerLinkToDelta(self.m_claw, "tag_attach_player");
					self.e_grabbed SetPlayerAngles(VectorToAngles(self.origin - self.e_grabbed.origin));
					self.e_grabbed playsound("zmb_ai_mechz_claw_grab");
					self.e_grabbed SetStance("stand");
					self.e_grabbed AllowCrouch(0);
					self.e_grabbed AllowProne(0);
					self.e_grabbed thread function_5f5eaf3a(self);
					self.e_grabbed thread function_bed84b4(self);
					self.e_grabbed thread function_38d105a4(self);
					if(!level flag::get("mechz_claw_move_complete"))
					{
						self.m_claw moveto(self.m_claw.origin, 0.05);
					}
				}
				break;
			}
		}
		wait(0.05);
	}
	while(!level flag::get("mechz_claw_move_complete") && (!isdefined(self.e_grabbed)));

	if(!isdefined(self.e_grabbed))
	{
		a_ai_zombies = zombie_utility::get_round_enemy_array();
		foreach(ai_zombie in a_ai_zombies)
		{
			if(!isalive(ai_zombie) || (isdefined(ai_zombie.is_giant_robot) && ai_zombie.is_giant_robot) || (isdefined(ai_zombie.is_mechz) && ai_zombie.is_mechz))
			{
				continue;
			}
			n_dist_sq = DistanceSquared(ai_zombie.origin + VectorScale((0, 0, 1), 36), self.m_claw.origin);
			if(n_dist_sq < 2304)
			{
				self.e_grabbed = ai_zombie;
				self.e_grabbed LinkTo(self.m_claw, "tag_attach_player", (0, 0, 0));
				self.e_grabbed.mechz_grabbed_by = self;
				break;
			}
		}
	}
	self.m_claw ClearAnim(%root, 0.2);
	self.m_claw SetAnim(%ai_zombie_mech_grapple_arm_closed_idle, 1, 0.2, 1);
	wait(0.5);
	if(isdefined(self.e_grabbed))
	{
		n_time = n_dist / 200;
	}
	else
	{
		n_time = n_dist / 1000;
	}
	self function_7c33f4fb();
	v_claw_origin = self GetTagOrigin("tag_claw");
	v_claw_angles = self GetTagAngles("tag_claw");
	self.m_claw moveto(v_claw_origin, max(0.05, n_time));
	self.m_claw PlayLoopSound("zmb_ai_mechz_claw_loop_in", 0.1);
	self.m_claw waittill("movedone");
	v_claw_origin = self GetTagOrigin("tag_claw");
	v_claw_angles = self GetTagAngles("tag_claw");
	self.m_claw playsound("zmb_ai_mechz_claw_back");
	self.m_claw StopLoopSound(1);
	if(zm_audio::sndIsNetworkSafe())
	{
		self playsound("zmb_ai_mechz_vox_angry");
	}
	self.m_claw.origin = v_claw_origin;
	self.m_claw.angles = v_claw_angles;
	self.m_claw ClearAnim(%root, 0.2);
	self.m_claw LinkTo(self, "tag_claw", (0, 0, 0));
	self.m_claw SetAnim(%ai_zombie_mech_grapple_arm_closed_idle, 1, 0.2, 1);
	self.m_claw.fx_ent delete();
	self.m_claw.fx_ent = undefined;
	self.fx_field = self.fx_field & 256;
	//self clientfield::set("mechz_fx", self.fx_field);
	self clientfield::set("mechz_wpn_source", 0);
	level flag::clear("mechz_launching_claw");

	if(isdefined(self.e_grabbed))
	{
		if(isPlayer(self.e_grabbed) && zm_utility::is_player_valid(self.e_grabbed))
		{
			self.e_grabbed thread function_8b0a73b5(self);
		}
		else if(isai(self.e_grabbed))
		{
			self.e_grabbed thread function_860f0461(self);
		}
		self thread function_eb9df173(self.e_grabbed);
		self AnimScripted("flamethrower_anim", self.origin, self.angles, "ai_zombie_mech_ft_burn_player", "normal", "ai_zombie_mech_ft_burn_player", 1,0.1);
		self zombie_shared::DoNoteTracks("flamethrower_anim");
	}
	level flag::clear("mechz_claw_move_complete");
}
/*
	Name: function_eb9df173
	Namespace: namespace_19d9d56d
	Checksum: 0x96078390
	Offset: 0x3238
	Size: 0x1A9
	Parameters: 1
	Flags: Private
*/
function private function_eb9df173(player)
{
	player endon("death");
	player endon("disconnect");
	self endon("death");
	self endon("claw_complete");
	self endon("kill_claw");
	self thread function_7792d05e(player);
	player thread function_d0e280a0(self);
	self.m_claw SetCanDamage(1);
	while(isdefined(self.e_grabbed))
	{
		self.m_claw waittill("damage", amount, inflictor, direction, point, type, tagName, modelName, partName, weaponName, iDFlags);
		if(zm_utility::is_player_valid(inflictor))
		{
			self DoDamage(1, inflictor.origin, inflictor, inflictor, "left_hand", type);
			self.m_claw SetCanDamage(0);
			self notify("claw_damaged");
			break;
		}
	}
}

/*
	Name: function_7792d05e
	Namespace: namespace_19d9d56d
	Checksum: 0xD27C5750
	Offset: 0x33F0
	Size: 0x8B
	Parameters: 1
	Flags: Private
*/
function private function_7792d05e(player)
{
	self endon("claw_damaged");
	player endon("death");
	player endon("disconnect");
	self util::waittill_any("death", "claw_complete", "kill_claw");
	if(isdefined(self) && isdefined(self.m_claw))
	{
		self.m_claw SetCanDamage(0);
	}
}

/*
	Name: function_d0e280a0
	Namespace: namespace_19d9d56d
	Checksum: 0xBB4AC903
	Offset: 0x3488
	Size: 0xA3
	Parameters: 1
	Flags: Private
*/
function private function_d0e280a0(mechz)
{
	mechz endon("claw_damaged");
	mechz endon("death");
	mechz endon("claw_complete");
	mechz endon("kill_claw");
	self util::waittill_any("death", "disconnect");
	if(isdefined(mechz) && isdefined(mechz.m_claw))
	{
		mechz.m_claw SetCanDamage(0);
	}
}

/*
	Name: function_2998f2a1
	Namespace: namespace_19d9d56d
	Checksum: 0x7FDF7C4B
	Offset: 0x3538
	Size: 0x33
	Parameters: 0
	Flags: Private
*/
function private function_2998f2a1()
{
	self waittill("movedone");
	wait(0.05);
	level flag::set("mechz_claw_move_complete");
}

/*
	Name: function_860f0461
	Namespace: namespace_19d9d56d
	Checksum: 0xB7441423
	Offset: 0x3578
	Size: 0x93
	Parameters: 1
	Flags: Private
*/
function private function_860f0461(mechz)
{
	mechz waittillmatch("flamethrower_anim");
	if(isalive(self))
	{
		self DoDamage(self.health, self.origin, self);
		self zombie_utility::gib_random_parts();
		GibServerUtils::Annihilate(self);
	}
}






function private function_76e7495b()
{
	wait(0.5);
	var_85129cef = getentarray("zombie_trap", "targetname");
	foreach(e_trap in var_85129cef)
	{
		if(e_trap.script_noteworthy == "electric")
		{
			level.electric_trap = e_trap;
		}
	}
}




/*
	Name: function_604404
	Namespace: namespace_8f77dbcb
	Checksum: 0x72B858C2
	Offset: 0xC88
	Size: 0x9D
	Parameters: 1
	Flags: Private
*/
function private function_604404(entity)
{
	if(isdefined(self.react))
	{
		foreach(react in self.react)
		{
			if(react == entity)
			{
				return 1;
			}
		}
	}
	return 0;
}

/*
	Name: function_e92d3bb1
	Namespace: namespace_8f77dbcb
	Checksum: 0x200C993B
	Offset: 0xD30
	Size: 0x39
	Parameters: 1
	Flags: Private
*/
function private function_e92d3bb1(entity)
{
	if(!isdefined(self.react))
	{
		self.react = [];
	}
	self.react[self.react.size] = entity;
}

/*
	Name: function_8746ceea
	Namespace: namespace_8f77dbcb
	Checksum: 0x6C7E79B4
	Offset: 0xD78
	Size: 0x1C1
	Parameters: 1
	Flags: Private
*/
function private genesisVortexService(entity)
{
	if(!entity function_58655f2a())
	{
		return 0;
	}
	if(isdefined(level.vortex_manager) && isdefined(level.vortex_manager.a_active_vorticies))
	{
		foreach(vortex in level.vortex_manager.a_active_vorticies)
		{
			if(!vortex function_604404(entity))
			{
				dist_sq = distancesquared(vortex.origin, self.origin);
				if(dist_sq < 9216)
				{
					entity.stun = 1;
					entity.vortex = vortex;
					//if(isdefined(vortex.weapon) && idgun::function_9b7ac6a9(vortex.weapon))
					//{
					//	blackboard::SetBlackBoardAttribute(entity, "_zombie_damageweapon_type", "packed");
					//}
					vortex function_e92d3bb1(entity);
					return 1;
				}
			}
		}
	}
	return 0;
}

/*
	Name: function_2ffb7337
	Namespace: namespace_8f77dbcb
	Checksum: 0xCF00231A
	Offset: 0xF48
	Size: 0x159
	Parameters: 1
	Flags: Private
*/
function private genesisMechzOctobombService(entity)
{
	if(isdefined(entity.destroy_octobomb))
	{
		entity SetGoal(entity.destroy_octobomb.origin);
		return 1;
	}
	if(isdefined(level.octobombs))
	{
		foreach(octobomb in level.octobombs)
		{
			if(isdefined(octobomb))
			{
				dist_sq = distancesquared(octobomb.origin, self.origin);
				if(dist_sq < 360000)
				{
					entity.destroy_octobomb = octobomb;
					entity SetGoal(octobomb.origin);
					return 1;
				}
			}
		}
	}
	return 0;
}




function private castleMechzTrapService(entity)
{
	if(isdefined(entity.var_d77404f7) && entity.var_d77404f7 || (isdefined(entity.var_72308ff2) && entity.var_72308ff2))
	{
		return 1;
	}

	traps_are_gay = GetEntArray("zombie_trap", "targetname");
	if(traps_are_gay.size < 1)
		return 0;

	traps = ArraySortClosest(traps_are_gay, entity.origin);

	foreach(trap in traps)
		if(isdefined(trap._trap_in_use) && trap._trap_in_use && !(isdefined(trap._trap_cooling_down) && trap._trap_cooling_down))
			if(entity function_d8f5da34("elec_trap_switch", trap))
				return 1;

	return 0;
}



function private function_d8f5da34(var_2dba2212, trig)
{
box = ArrayGetClosest(self.origin, trig._trap_use_trigs);

spot = GetClosestPointOnNavMesh(box.origin);




if(self CanPath(self.origin, spot))
	{
	self.trap_to_kill = trig;
	self.var_d77404f7 = 1;
	self.ignoreall = 1;
	self SetGoal(spot);
	self thread function_957c9419();
	return 1;
	}


return 0;

	traps = struct::get_array(var_2dba2212, "script_noteworthy");
	self.var_fdce40e2 = undefined;
	n_closest_dist_sq = 57600;
	foreach(var_fdce40e2 in traps)
	{
		n_dist_sq = distancesquared(var_fdce40e2.origin, self.origin);
		if(n_dist_sq < n_closest_dist_sq)
		{
			n_closest_dist_sq = n_dist_sq;
			self.var_fdce40e2 = var_fdce40e2;
		}
	}
	if(isdefined(self.var_fdce40e2))
	{
		self.var_d77404f7 = 1;
		self.ignoreall = 1;
		self SetGoal(self.var_fdce40e2.origin);
		self thread function_957c9419();
		return 1;
	}
	return 0;
}

/*
	Name: function_957c9419
	Namespace: namespace_8f77dbcb
	Checksum: 0x56378946
	Offset: 0x1240
	Size: 0x93
	Parameters: 0
	Flags: None
*/
function function_957c9419()
{
	self endon("death");
	wait(60);
	if(isdefined(self.var_d77404f7) && self.var_d77404f7 || (isdefined(self.var_72308ff2) && self.var_72308ff2) || (isdefined(self.ignoreall) && self.ignoreall))
	{
		self.var_d77404f7 = 0;
		self.var_72308ff2 = 0;
		self.ignoreall = 0;
		self.trap_to_kill = undefined;
		MechzBehavior::mechzTargetService(self);
	}
}

/*
	Name: function_beb13c4b
	Namespace: namespace_8f77dbcb
	Checksum: 0x62EB8DCB
	Offset: 0x12E0
	Size: 0x39
	Parameters: 1
	Flags: None
*/
function castleMechzShouldMoveToTrap(entity)
{
	if(isdefined(entity.var_d77404f7) && entity.var_d77404f7)
	{
		return 1;
	}
	return 0;
}

/*
	Name: function_fc277828
	Namespace: namespace_8f77dbcb
	Checksum: 0x4CF7A31
	Offset: 0x1328
	Size: 0x2D
	Parameters: 1
	Flags: None
*/
function castleMechzIsAtTrap(entity)
{
	if(entity IsAtGoal())
	{
		return 1;
	}
	return 0;
}

/*
	Name: function_d1cb5cbc
	Namespace: namespace_8f77dbcb
	Checksum: 0xF00A1DB5
	Offset: 0x1360
	Size: 0x39
	Parameters: 1
	Flags: None
*/
function castleMechzShouldAttackTrap(entity)
{
	if(isdefined(entity.var_72308ff2) && entity.var_72308ff2)
	{
		return 1;
	}
	return 0;
}

/*
	Name: function_4e06a982
	Namespace: namespace_8f77dbcb
	Checksum: 0x8D6FDF20
	Offset: 0x13A8
	Size: 0xBD
	Parameters: 1
	Flags: Private
*/
function private genesisMechzShouldOctobombAttack(entity)
{
	if(!isdefined(entity.destroy_octobomb))
	{
		return 0;
	}
	if(distancesquared(entity.origin, entity.destroy_octobomb.origin) > 16384)
	{
		return 0;
	}
	yaw = Abs(zombie_utility::GetYawToSpot(entity.destroy_octobomb.origin));
	if(yaw > 45)
	{
		return 0;
	}
	return 1;
}

/*
	Name: function_4210ca29
	Namespace: namespace_8f77dbcb
	Checksum: 0x2FDF1357
	Offset: 0x1470
	Size: 0x2F
	Parameters: 1
	Flags: None
*/
function casteMechzTrapMoveTerminate(entity)
{
	entity.var_d77404f7 = 0;
	entity.var_72308ff2 = 1;
}

/*
	Name: function_910e57ee
	Namespace: namespace_8f77dbcb
	Checksum: 0xB370CE16
	Offset: 0x14A8
	Size: 0xB3
	Parameters: 1
	Flags: None
*/
function casteMechzTrapAttackTerminate(entity)
{
	entity.var_72308ff2 = 0;
	entity.ignoreall = 0;
	entity.trap_to_kill notify("trap_deactivate");
	entity.trap_to_kill = undefined;
	MechzBehavior::mechzTargetService(entity);
}

/*
	Name: function_78198ba2
	Namespace: namespace_8f77dbcb
	Checksum: 0x17184BF0
	Offset: 0x1568
	Size: 0x63
	Parameters: 1
	Flags: None
*/
function genesisMechzDestoryOctobomb(entity)
{
	if(isdefined(entity.destroy_octobomb))
	{
		entity.destroy_octobomb detonate();
		entity.destroy_octobomb = undefined;
	}
	MechzBehavior::mechzStopFlame(entity);
}

/*
	Name: function_45f397ee
	Namespace: namespace_8f77dbcb
	Checksum: 0x8AF26E9A
	Offset: 0x15D8
	Size: 0x83
	Parameters: 5
	Flags: None
*/
function mechz_attack_trap_start(entity, mocompanim, mocompAnimBlendOutTime, mocompAnimFlag, mocompDuration)
{
	entity OrientMode("face angle", entity.var_fdce40e2.angles[1]);
	entity animMode("normal");
}

/*
	Name: function_9da58a6f
	Namespace: namespace_8f77dbcb
	Checksum: 0xC8867E8E
	Offset: 0x1668
	Size: 0x4B
	Parameters: 5
	Flags: None
*/
function mechz_attack_trap_end(entity, mocompanim, mocompAnimBlendOutTime, mocompAnimFlag, mocompDuration)
{
	entity OrientMode("face default");
}

/*
	Name: mechz_health_increases
	Namespace: namespace_8f77dbcb
	Checksum: 0x6D4ACC3F
	Offset: 0x16C0
	Size: 0x2EB
	Parameters: 0
	Flags: None
*/
function mechz_health_increases()
{
	if(!isdefined(level.mechz_last_spawn_round) || level.round_number > level.mechz_last_spawn_round)
	{
		a_players = GetPlayers();
		n_player_modifier = 1;
		switch(a_players.size)
		{
			case 0:
			case 1:
			{
				n_player_modifier = 1;
				break;
			}
			case 2:
			{
				n_player_modifier = 1.33;
				break;
			}
			case 3:
			{
				n_player_modifier = 1.66;
				break;
			}
			case 4:
			{
				n_player_modifier = 2;
				break;
			}
		}
		var_485a2c2c = level.zombie_health / level.zombie_vars["zombie_health_start"];
		level.mechz_health = int(n_player_modifier * level.mechz_base_health + level.mechz_health_increase * var_485a2c2c);
		level.MECHZ_FACEPLATE_HEALTH = int(n_player_modifier * level.var_fa14536d + level.var_1a5bb9d8 * var_485a2c2c);
		level.MECHZ_POWERCAP_COVER_HEALTH = int(n_player_modifier * level.MECHZ_POWERCAP_COVER_HEALTH + level.var_a1943286 * var_485a2c2c);
		level.MECHZ_POWERCAP_HEALTH = int(n_player_modifier * level.MECHZ_POWERCAP_HEALTH + level.var_9684c99e * var_485a2c2c);
		level.var_2cbc5b59 = int(n_player_modifier * level.var_3f1bf221 + level.var_158234c * var_485a2c2c);
		level.mechz_health = function_26beb37e(level.mechz_health, 17500, n_player_modifier);
		level.MECHZ_FACEPLATE_HEALTH = function_26beb37e(level.MECHZ_FACEPLATE_HEALTH, 16000, n_player_modifier);
		level.MECHZ_POWERCAP_COVER_HEALTH = function_26beb37e(level.MECHZ_POWERCAP_COVER_HEALTH, 7500, n_player_modifier);
		level.MECHZ_POWERCAP_HEALTH = function_26beb37e(level.MECHZ_POWERCAP_HEALTH, 5000, n_player_modifier);
		level.var_2cbc5b59 = function_26beb37e(level.var_2cbc5b59, 3500, n_player_modifier);
		level.mechz_last_spawn_round = level.round_number;
	}
}

/*
	Name: function_26beb37e
	Namespace: namespace_8f77dbcb
	Checksum: 0xD8F5E84C
	Offset: 0x19B8
	Size: 0x53
	Parameters: 3
	Flags: None
*/
function function_26beb37e(n_value, var_9cc1b75, n_player_modifier)
{
	if(n_value >= var_9cc1b75 * n_player_modifier)
	{
		n_value = int(var_9cc1b75 * n_player_modifier);
	}
	return n_value;
}

/*
	Name: function_d8d01032
	Namespace: namespace_8f77dbcb
	Checksum: 0x3FA40FB3
	Offset: 0x1A18
	Size: 0xF9
	Parameters: 0
	Flags: None
*/
function function_d8d01032()
{
	self.idgun_damage_cb = &function_5f2149bb;
	self.var_c732138b = &function_1df1ec14;
	self.traversalSpeedBoost = &function_40ef38f8;
	self thread function_a2a11991();
	self thread function_b2a1b297();
	//self thread function_2a26e636();
	self thread zm::update_zone_name();
	self waittill("death");
	//self thread function_2a2bfc25();
	if(isdefined(self.var_9b31a70d) && self.var_9b31a70d)
	{
		level.var_638dde56--;
	}
	level notify("hash_8f65ad3d");
}

/*
	Name: function_3fdbda1e
	Namespace: namespace_8f77dbcb
	Checksum: 0x395BF9F3
	Offset: 0x1B20
	Size: 0x63
	Parameters: 0
	Flags: None
*/
function function_3fdbda1e()
{
	self function_1faf1646();
	util::wait_network_frame();
	self clientfield::increment("mechz_fx_spawn");
	wait(1);
	self function_ee090a93();
}

/*
	Name: function_b7e11612
	Namespace: namespace_8f77dbcb
	Checksum: 0x2363B45C
	Offset: 0x1B90
	Size: 0x2B
	Parameters: 0
	Flags: None
*/
function function_b7e11612()
{
	self waittill("death");
	//self namespace_c149ef1::function_f7879c72(self.attacker);
}

/*
	Name: function_b2a1b297
	Namespace: namespace_8f77dbcb
	Checksum: 0xF4DCA2D
	Offset: 0x1BC8
	Size: 0x43
	Parameters: 0
	Flags: None
*/
function function_b2a1b297()
{
	self waittill("actor_corpse", mechz);
	wait(60);
	if(isdefined(mechz))
	{
		mechz delete();
	}
}

/*
	Name: function_2a26e636
	Namespace: namespace_8f77dbcb
	Checksum: 0x89EA333C
	Offset: 0x1C18
	Size: 0x243
	Parameters: 0
	Flags: None
*/
function function_2a26e636()
{
	self endon("death");
	while(1)
	{
		if(!isdefined(self.zone_name))
		{
			wait(0.1);
			continue;
		}
		var_225b5e15 = 1;
		var_e01c8f74 = 1;
		players = GetPlayers();
		foreach(player in players)
		{
			if(isdefined(player.var_5aef0317) && player.var_5aef0317 || (isdefined(player.var_a393601c) && player.var_a393601c))
			{
				var_225b5e15 = 0;
				var_e01c8f74 = 0;
				break;
				continue;
			}
			if(isdefined(player.am_i_valid) && player.am_i_valid)
			{
				if(!isdefined(player.zone_name))
				{
					var_225b5e15 = 0;
					var_e01c8f74 = 0;
					break;
				}
				if(isdefined(player.zone_name))
				{
					if(player.zone_name == "apothicon_interior_zone")
					{
						var_e01c8f74 = 0;
						continue;
					}
					var_225b5e15 = 0;
				}
			}
		}
		var_9626d5b6 = 0;
		if(self.zone_name == "apothicon_interior_zone")
		{
			var_9626d5b6 = 1;
		}
		if(var_225b5e15 && !var_9626d5b6 || (var_e01c8f74 && var_9626d5b6))
		{
			break;
		}
		wait(0.5);
	}
	self thread function_17da3db2();
}

/*
	Name: function_17da3db2
	Namespace: namespace_8f77dbcb
	Checksum: 0x7B4EFA08
	Offset: 0x1E68
	Size: 0x53
	Parameters: 0
	Flags: None
*/
function function_17da3db2()
{
	wait(0.05);
	if(isdefined(self))
	{
		self delete();
	}
	wait(1.1);
	//level thread namespace_6929903c::spawn_boss("mechz");
}

/*
	Name: function_a2a11991
	Namespace: namespace_8f77dbcb
	Checksum: 0xDFD65FD3
	Offset: 0x1EC8
	Size: 0x3B
	Parameters: 0
	Flags: None
*/
function function_a2a11991()
{
	self endon("death");
	while(!isdefined(self.zombie_lift_override))
	{
		wait(0.05);
	}
	self.zombie_lift_override = &function_2d571578;
}

/*
	Name: function_2a2bfc25
	Namespace: namespace_8f77dbcb
	Checksum: 0x7668C947
	Offset: 0x1F10
	Size: 0xC3
	Parameters: 0
	Flags: None
*/
function function_2a2bfc25()
{
	self waittill("hash_46c1e51d");
	if(level flag::get("zombie_drop_powerups") && (!isdefined(self.no_powerups) && self.no_powerups))
	{
		var_d54b1ec = array("double_points", "insta_kill", "full_ammo", "nuke");
		str_type = array::random(var_d54b1ec);
		zm_powerups::specific_powerup_drop(str_type, self.origin);
	}
}

/*
	Name: function_f517cdd6
	Namespace: namespace_8f77dbcb
	Checksum: 0x127817F3
	Offset: 0x1FE0
	Size: 0x63
	Parameters: 12
	Flags: None
*/
function function_f517cdd6(inflictor, attacker, damage, dFlags, mod, weapon, point, dir, hitloc, offsetTime, boneIndex, modelIndex)
{
}

/*
	Name: function_5683b5d5
	Namespace: namespace_8f77dbcb
	Checksum: 0x55D305A2
	Offset: 0x2050
	Size: 0xDB
	Parameters: 5
	Flags: None
*/
function mechz_teleport_Start(entity, mocompanim, mocompAnimBlendOutTime, mocompAnimFlag, mocompDuration)
{
	entity.is_teleporting = 1;
	entity OrientMode("face angle", entity.angles[1]);
	entity animMode("normal");


	thread function_eb1242c8(entity);
}


function function_eb1242c8(entity)
{
	//IPrintLnBold("teleporting");
	entity endon("death");
	

	entity.teleportStart = entity.origin;
	entity.teleportPos = entity.traverseEndNode.origin;

	entity.b_teleporting = 1;
	entity PathMode("dont move");
	PlayFX(level._effect["portal_3p"], entity.origin);
	PlaySoundAtPosition("zmb_teleporter_teleport_out", entity.origin);
	entity NotSolid();
	entity Hide();
	util::wait_network_frame();
	/*image_room = struct::get("teleport_room_zombies", "targetname");
	if(IsActor(entity))
	{
		entity ForceTeleport(image_room.origin, image_room.angles);
	}
	else
	{
		entity.origin = image_room.origin;
		entity.angles = image_room.angles;
	}*/
	wait(5);



	entity ForceTeleport(entity.teleportPos, entity.angles);
	playsoundatposition("zmb_teleporter_teleport_in", entity.teleportPos);
	PlayFX(level._effect["portal_3p"], entity.traverseEndNode.origin);
	entity Solid();
	entity Show();
	wait(1);
	entity PathMode("move allowed");
	entity.b_teleporting = 0;
	entity.is_teleporting = 0;

}


/*
	Name: function_2d571578
	Namespace: namespace_8f77dbcb
	Checksum: 0xF5B7B7A4
	Offset: 0x2138
	Size: 0x2C7
	Parameters: 6
	Flags: None
*/
function function_2d571578(e_player, v_attack_source, n_push_away, n_lift_height, v_lift_offset, n_lift_speed)
{
	self endon("death");
	if(isdefined(self.in_gravity_trap) && self.in_gravity_trap && e_player.gravityspikes_state === 3)
	{
		if(isdefined(self.var_1f5fe943) && self.var_1f5fe943)
		{
			return;
		}
		self.var_bcecff1d = 1;
		self.var_1f5fe943 = 1;
		self DoDamage(10, self.origin);
		self.var_ab0efcf6 = self.origin;
		self thread scene::play("cin_zm_dlc1_mechz_dth_deathray_01", self);
		self clientfield::set("sparky_beam_fx", 1);
		self clientfield::set("death_ray_shock_fx", 1);
		self playsound("zmb_talon_electrocute");
		n_start_time = GetTime();
		for(n_total_time = 0; 10 > n_total_time && e_player.gravityspikes_state === 3;  n_total_time++)
		{
			util::wait_network_frame();
		}
		self scene::stop("cin_zm_dlc1_mechz_dth_deathray_01");
		self thread function_a0b6d6b9(self);
		self clientfield::set("sparky_beam_fx", 0);
		self clientfield::set("death_ray_shock_fx", 0);
		self.var_bcecff1d = undefined;
		while(e_player.gravityspikes_state === 3)
		{
			util::wait_network_frame();
		}
		self.var_1f5fe943 = undefined;
		self.in_gravity_trap = undefined;
	}
	else
	{
		self DoDamage(10, self.origin);
		if(!(isdefined(self.stun) && self.stun))
		{
			self.stun = 1;
		}
	}
}

/*
	Name: function_a0b6d6b9
	Namespace: namespace_8f77dbcb
	Checksum: 0xCDD8F98B
	Offset: 0x2408
	Size: 0x1A3
	Parameters: 1
	Flags: None
*/
function function_a0b6d6b9(mechz)
{
	mechz endon("death");
	if(isdefined(mechz))
	{
		mechz scene::play("cin_zm_dlc1_mechz_dth_deathray_02", mechz);
	}
	if(isdefined(mechz) && isalive(mechz) && isdefined(mechz.var_ab0efcf6))
	{
		v_eye_pos = mechz gettagorigin("tag_eye");
		/#
			recordLine(mechz.origin, v_eye_pos, VectorScale((0, 1, 0), 255), "Dev Block strings are not supported", mechz);
		#/
		trace = bullettrace(v_eye_pos, mechz.origin, 0, mechz);
		if(trace["position"] !== mechz.origin)
		{
			point = GetClosestPointOnNavMesh(trace["position"], 64, 30);
			if(!isdefined(point))
			{
				point = mechz.var_ab0efcf6;
			}
			mechz ForceTeleport(point);
		}
	}
}

/*
	Name: function_5f2149bb
	Namespace: namespace_8f77dbcb
	Checksum: 0xBE06B1AA
	Offset: 0x25B8
	Size: 0xA3
	Parameters: 2
	Flags: None
*/
function function_5f2149bb(inflictor, attacker)
{
	var_3bb42832 = level.mechz_health;
	n_damage = var_3bb42832 * 0.25 / 0.2;
	self DoDamage(n_damage, self GetCentroid(), inflictor, attacker, undefined, "MOD_PROJECTILE_SPLASH", 0, GetWeapon("none"));
}

/*
	Name: function_1df1ec14
	Namespace: namespace_8f77dbcb
	Checksum: 0xF9FD1480
	Offset: 0x2668
	Size: 0x33
	Parameters: 0
	Flags: Private
*/
function private function_1df1ec14()
{
	if(self function_58655f2a())
	{
		self.stun = 1;
		return 1;
	}
	return 0;
}

/*
	Name: function_40ef38f8
	Namespace: namespace_8f77dbcb
	Checksum: 0x868B0E29
	Offset: 0x26A8
	Size: 0xAD
	Parameters: 0
	Flags: Private
*/
function private function_40ef38f8()
{
	traversal = self.traversal;
	speedBoost = 0;
	if(traversal.absLengthToEnd > 200)
	{
		speedBoost = 48;
	}
	else if(traversal.absLengthToEnd > 120)
	{
		speedBoost = 24;
	}
	else if(traversal.absLengthToEnd > 80 || traversal.absHeightToEnd > 80)
	{
		speedBoost = 12;
	}
	return speedBoost;
}

/*
	Name: mechz_damage_override
	Namespace: namespace_8f77dbcb
	Checksum: 0xDCC4E48E
	Offset: 0x2760
	Size: 0x45
	Parameters: 2
	Flags: None
*/
function mechz_damage_override(attacker, damage)
{
	if(isdefined(attacker.var_bbd3efb8))
	{
		damage = damage * attacker.var_bbd3efb8;
	}
	return damage;
}

/*
	Name: function_1faf1646
	Namespace: namespace_8f77dbcb
	Checksum: 0xEBF31B1C
	Offset: 0x27B0
	Size: 0x6B
	Parameters: 0
	Flags: Private
*/
function private function_1faf1646()
{
	self.canDamage = 0;
	self.isFrozen = 1;
	self ghost();
	self notsolid();
	self PathMode("dont move");
}

/*
	Name: function_ee090a93
	Namespace: namespace_8f77dbcb
	Checksum: 0x6950A9C0
	Offset: 0x2828
	Size: 0x6F
	Parameters: 0
	Flags: Private
*/
function private function_ee090a93()
{
	self.isFrozen = 0;
	self show();
	self solid();
	wait(0.5);
	self PathMode("move allowed");
	self.canDamage = 1;
}

/*
	Name: function_78e44cda
	Namespace: namespace_8f77dbcb
	Checksum: 0xB373F219
	Offset: 0x28A0
	Size: 0xB7
	Parameters: 0
	Flags: None
*/
function function_78e44cda()
{
	/#
		wait(0.05);
		level waittill("start_zombie_round_logic");
		wait(0.05);
		SetDvar("Dev Block strings are not supported", 0);
		AddDebugCommand("Dev Block strings are not supported");
		while(1)
		{
			if(GetDvarInt("Dev Block strings are not supported"))
			{
				SetDvar("Dev Block strings are not supported", 0);
				level thread function_eac1444a();
			}
			wait(0.5);
		}
	#/
}

/*
	Name: function_eac1444a
	Namespace: namespace_8f77dbcb
	Checksum: 0x5DA0BFA5
	Offset: 0x2960
	Size: 0x281
	Parameters: 0
	Flags: None
*/
function function_eac1444a()
{
	/#
		var_10b176f0 = GetAIArchetypeArray("Dev Block strings are not supported");
		foreach(ai_mechz in var_10b176f0)
		{
			var_efe3c52f = level.activePlayers[0] gettagorigin("Dev Block strings are not supported") + VectorScale((0, 0, 1), 20);
			var_7ddc55f4 = level.activePlayers[0] gettagorigin("Dev Block strings are not supported") + (5, 0, 20);
			var_a3ded05d = level.activePlayers[0] gettagorigin("Dev Block strings are not supported") + (-5, 0, 20);
			var_31d76122 = level.activePlayers[0] gettagorigin("Dev Block strings are not supported") + VectorScale((0, 0, 1), 15);
			MagicBullet(level.var_e106fba5, var_efe3c52f, ai_mechz GetCentroid(), level.activePlayers[0]);
			MagicBullet(level.var_791ba87b, var_7ddc55f4, ai_mechz GetCentroid(), level.activePlayers[0]);
			MagicBullet(level.var_5d4538da, var_a3ded05d, ai_mechz GetCentroid(), level.activePlayers[0]);
			MagicBullet(level.var_30611368, var_31d76122, ai_mechz GetCentroid(), level.activePlayers[0]);
		}
	#/
}

/*
	Name: function_22cf3e9f
	Namespace: namespace_8f77dbcb
	Checksum: 0xDAD1DE02
	Offset: 0x2BF0
	Size: 0x5B
	Parameters: 3
	Flags: None
*/
function function_22cf3e9f(str_weapon_name, v_source, ai_mechz)
{
	/#
		MagicBullet(level.var_791ba87b, v_source, ai_mechz GetCentroid(), level.activePlayers[0]);
	#/
}

