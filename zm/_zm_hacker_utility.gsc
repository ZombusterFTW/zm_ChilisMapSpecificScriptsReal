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


#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_pers_upgrades_functions;

// MOON HACKER
#using scripts\zm\_zm_equip_hacker;
#using scripts\zm\_zm_hackables_boards;
#using scripts\zm\_zm_hackables_box;
#using scripts\zm\_zm_hackables_doors;
#using scripts\zm\_zm_hackables_packapunch;
#using scripts\zm\_zm_hackables_perks;
#using scripts\zm\_zm_hackables_powerups;
#using scripts\zm\_zm_hackables_wallbuys;
#using scripts\zm\_zm_hacker_tool;
#using scripts\shared\hackable;

function __init__()
{
	level thread hacker_location_random_init();
	level._hack_perks_override = &zm_perks_override_func;
	level.hacker_tool = GetWeapon("equip_hacker");

	level thread zm_hackables_wallbuys::hack_wallbuys();
	level thread zm_hackables_perks::hack_perks();
	level thread zm_hackables_packapunch::hack_packapunch();
	level thread zm_hackables_boards::hack_boards();
	level thread zm_hackables_doors::hack_doors("default_buy_door", &moon_door_opened);
	level thread zm_hackables_doors::hack_doors();
	level thread zm_hackables_powerups::hack_powerups();
	level thread zm_hackables_box::box_hacks();
	level thread packapunch_hack_think();
	level thread pack_gate_poi_init();
	level._hack_perks_override = &function_9f47ebff;
}

function hacker_location_random_init()
{
	hacker_tool_array = [];
	hacker_pos = undefined;
	level.hacker_tool_positions = [];
	hacker = GetEntArray("zombie_equipment_upgrade", "targetname");
	for(i = 0; i < hacker.size; i++)
	{
		if(isdefined(hacker[i].zombie_equipment_upgrade) && hacker[i].zombie_equipment_upgrade == "equip_hacker")
		{
			if(!isdefined(hacker_tool_array))
			{
				hacker_tool_array = [];
			}
			else if(!IsArray(hacker_tool_array))
			{
				hacker_tool_array = Array(hacker_tool_array);
			}
			hacker_tool_array[hacker_tool_array.size] = hacker[i];
			struct = spawnstruct();
			struct.trigger_org = hacker[i].origin;
			struct.model_org = GetEnt(hacker[i].target, "targetname").origin;
			struct.model_ang = GetEnt(hacker[i].target, "targetname").angles;
			level.hacker_tool_positions[level.hacker_tool_positions.size] = struct;
		}
	}
	if(hacker_tool_array.size > 1)
	{
		hacker_pos = hacker_tool_array[RandomInt(hacker_tool_array.size)];
		ArrayRemoveValue(hacker_tool_array, hacker_pos);
		Array::thread_all(hacker_tool_array, &hacker_position_cleanup);
	}
}

function hacker_position_cleanup()
{
	model = GetEnt(self.target, "targetname");
	if(isdefined(model))
	{
		model delete();
	}
	if(isdefined(self))
	{
		self delete();
	}
}

function init_zombie_airlocks()
{
	airlock_buys = GetEntArray("zombie_airlock_buy", "targetname");
	for(i = 0; i < airlock_buys.size; i++)
	{
		airlock_buys[i] thread airlock_buy_init();
	}
	level thread zm_hackables_doors::hack_doors("zombie_airlock_hackable", &moon_door_opened);
	airlock_hacks = GetEntArray("zombie_airlock_hackable", "targetname");
	for(i = 0; i < airlock_hacks.size; i++)
	{
		airlock_hacks[i] thread airlock_hack_init();
	}
	airlock_doors = GetEntArray("zombie_door_airlock", "script_noteworthy");
	for(i = 0; i < airlock_doors.size; i++)
	{
		airlock_doors[i] thread airlock_init();
	}
}

function airlock_hack_init()
{
	self.type = undefined;
	if(isdefined(self.script_flag) && !isdefined(level.flag[self.script_flag]))
	{
		if(isdefined(self.script_flag))
		{
			tokens = StrTok(self.script_flag, ",");
			for(i = 0; i < tokens.size; i++)
			{
				level flag::init(self.script_flag);
			}
		}
	}
	self.trigs = [];
	targets = GetEntArray(self.target, "targetname");
	for(i = 0; i < targets.size; i++)
	{
		if(!isdefined(self.trigs))
		{
			self.trigs = [];
		}
		else if(!IsArray(self.trigs))
		{
			self.trigs = Array(self.trigs);
		}
		self.trigs[self.trigs.size] = targets[i];
		if(isdefined(targets[i].classname) && targets[i].classname == "trigger_multiple")
		{
			targets[i] TriggerEnable(0);
		}
	}
	self setcursorhint("HINT_NOICON");
	self.script_noteworthy = "default";
	self setHintString(&"ZOMBIE_EQUIP_HACKER");
}

function zm_perks_override_func()
{
	if(self.perk.script_noteworthy == "specialty_rof")
	{
		self.no_bullet_trace = 1;
	}
	return self;
}

function packapunch_hack_think()
{
	level flag::init("packapunch_hacked");
	time = 30;
	pack_gates = GetEntArray("zombieland_gate", "targetname");
	for(i = 0; i < pack_gates.size; i++)
	{
		pack_gates[i].startPos = pack_gates[i].origin;
	}
	while(1)
	{
		level waittill("packapunch_hacked");
		level flag::clear("packapunch_hacked");
		Array::thread_all(pack_gates);
		level thread pack_gate_poi_activate(time);
		wait(time);
		level flag::set("packapunch_hacked");
		zm_equip_hacker::register_pooled_hackable_struct(level._pack_hack_struct, &zm_hackables_packapunch::packapunch_hack);
	}
}

function pack_gate_poi_init()
{
	pack_zombieland_poi = GetEntArray("zombieland_poi", "targetname");
	for(i = 0; i < pack_zombieland_poi.size; i++)
	{
		pack_zombieland_poi[i] zm_utility::create_zombie_point_of_interest(undefined, 30, 0, 0);
		pack_zombieland_poi[i] thread zm_utility::create_zombie_point_of_interest_attractor_positions(4, 45);
	}
}

function pack_gate_poi_activate(time)
{
	pack_enclosure = GetEnt("pack_enclosure", "targetname");
	pack_zombieland_poi = GetEntArray("zombieland_poi", "targetname");
	players = GetPlayers();
	num_players_inside = 0;
	for(i = 0; i < players.size; i++)
	{
		if(players[i] istouching(pack_enclosure))
		{
			num_players_inside++;
		}
	}
	if(num_players_inside != players.size)
	{
		return;
	}
	level thread activate_zombieland_poi_positions(time);
	level thread watch_for_exit(pack_zombieland_poi);
	while(!level flag::get("packapunch_hacked"))
	{
		zombies = GetAIArray();
		for(i = 0; i < zombies.size; i++)
		{
			if(zombies[i] istouching(pack_enclosure))
			{
				zombies[i].in_pack_enclosure = 1;
				zombies[i] thread moon_zombieland_ignore_poi();
				continue;
			}
			if(!(isdefined(zombies[i]._poi_pack_set) && zombies[i]._poi_pack_set))
			{
				zombies[i] thread switch_between_zland_poi();
				//zombies[i] thread moon_nml_bhb_present();
				zombies[i]._poi_pack_set = 1;
			}
		}
		wait(1);
	}
	level flag::wait_till("packapunch_hacked");
	level notify("stop_pack_poi");
	zombies = GetAIArray();
	for(i = 0; i < zombies.size; i++)
	{
		zombies[i]._poi_pack_set = 0;
	}
	for(i = 0; i < pack_zombieland_poi.size; i++)
	{
		pack_zombieland_poi[i] function_47f0ea80();
	}
}

function players_in_zombieland()
{
	pack_enclosure = GetEnt("pack_enclosure", "targetname");
	players = GetPlayers();
	num_players_inside = 0;
	for(i = 0; i < players.size; i++)
	{
		if(players[i] istouching(pack_enclosure))
		{
			num_players_inside++;
		}
	}
	if(num_players_inside != players.size)
	{
		return 0;
	}
	return 1;
}


function switch_between_zland_poi()
{
	self endon("death");
	level endon("packapunch_hacked");
	self endon("nml_bhb");
	poi_array = GetEntArray("zombieland_poi", "targetname");
	for(x = 0; x < poi_array.size; x++)
	{
		if(isdefined(poi_array[x].poi_active) && poi_array[x].poi_active)
		{
			self zm_utility::add_poi_to_ignore_list(poi_array[x]);
		}
	}
	poi_array = Array::randomize(poi_array);
	while(!level flag::get("packapunch_hacked"))
	{
		for(i = 0; i < poi_array.size; i++)
		{
			self zm_utility::remove_poi_from_ignore_list(poi_array[i]);
			self util::waittill_any_ex(randomIntRange(2, 5), "goal", "bad_path", "death", "nml_bhb", level, "packapunch_hacked");
			self zm_utility::add_poi_to_ignore_list(poi_array[i]);
		}
		poi_array = Array::randomize(poi_array);
		self zm_utility::remove_poi_from_ignore_list(poi_array[0]);
		wait(0.05);
	}
}

function activate_zombieland_poi_positions(time)
{
	level endon("stop_pack_poi");
	pack_zombieland_poi = GetEntArray("zombieland_poi", "targetname");
	for(i = 0; i < pack_zombieland_poi.size; i++)
	{
		POI = pack_zombieland_poi[i];
		POI zm_utility::activate_zombie_point_of_interest();
	}
}

function watch_for_exit(poi_array)
{
	while(players_in_zombieland() && !level flag::get("packapunch_hacked"))
	{
		wait(0.1);
	}
	level notify("stop_pack_poi");
	for(i = 0; i < poi_array.size; i++)
	{
		poi_array[i] function_47f0ea80();
	}
}

function moon_zombieland_ignore_poi()
{
	self endon("death");
	nml_poi_array = GetEntArray("zombieland_poi", "targetname");
	if(isdefined(self._zmbl_ignore) && self._zmbl_ignore)
	{
		return;
	}
	self._zmbl_ignore = 1;
	for(i = 0; i < nml_poi_array.size; i++)
	{
		self zm_utility::add_poi_to_ignore_list(nml_poi_array[i]);
	}
	while(!level flag::get("packapunch_hacked"))
	{
		wait(0.1);
	}
	for(x = 0; x < nml_poi_array.size; x++)
	{
		self zm_utility::remove_poi_from_ignore_list(nml_poi_array[x]);
	}
}


function moon_door_opened()
{
	self notify("door_opened");
	if(isdefined(self.script_flag))
	{
		tokens = StrTok(self.script_flag, ",");
		for(i = 0; i < tokens.size; i++)
		{
			level flag::set(tokens[i]);
		}
	}
	for(i = 0; i < self.trigs.size; i++)
	{
		self.trigs[i] TriggerEnable(1);
		self.trigs[i] thread change_door_models();
	}
	zm_utility::play_sound_at_pos("purchase", self.origin);
	all_trigs = GetEntArray(self.target, "target");
	for(i = 0; i < all_trigs.size; i++)
	{
		all_trigs[i] TriggerEnable(0);
	}
}

function function_47f0ea80()
{
	if(self.script_noteworthy != "zombie_poi")
	{
		return;
	}
	for(i = 0; i < self.attractor_array.size; i++)
	{
		self.attractor_array[i] notify("kill_poi");
	}
	self.attractor_array = [];
	self.claimed_attractor_positions = [];
	self.poi_active = 0;
}

function airlock_buy_init()
{
	self.type = undefined;
	if(isdefined(self.script_flag) && !isdefined(level.flag[self.script_flag]))
	{
		if(isdefined(self.script_flag))
		{
			tokens = StrTok(self.script_flag, ",");
			for(i = 0; i < tokens.size; i++)
			{
				level flag::init(self.script_flag);
			}
		}
	}
	self.trigs = [];
	targets = GetEntArray(self.target, "targetname");
	for(i = 0; i < targets.size; i++)
	{
		if(!isdefined(self.trigs))
		{
			self.trigs = [];
		}
		else if(!IsArray(self.trigs))
		{
			self.trigs = Array(self.trigs);
		}
		self.trigs[self.trigs.size] = targets[i];
		if(isdefined(targets[i].classname) && targets[i].classname == "trigger_multiple")
		{
			targets[i] TriggerEnable(0);
		}
	}
	self setcursorhint("HINT_NOICON");
	if(isdefined(self.script_noteworthy) && (self.script_noteworthy == "electric_door" || self.script_noteworthy == "electric_buyable_door"))
	{
		self setHintString(&"ZOMBIE_NEED_POWER");
	}
	else
	{
		self.script_noteworthy = "default";
	}
	self thread airlock_buy_think();
}

function airlock_buy_think()
{
	self endon("kill_door_think");
	cost = 1000;
	if(isdefined(self.zombie_cost))
	{
		cost = self.zombie_cost;
	}
	while(1)
	{
		switch(self.script_noteworthy)
		{
			case "electric_door":
			{
				level flag::wait_till("power_on");
				break;
			}
			case "electric_buyable_door":
			{
				level flag::wait_till("power_on");
				self zm_utility::set_hint_string(self, "default_buy_door", cost);
				if(!self airlock_buy())
				{
					continue;
				}
				break;
			}
		}
	}
}

function airlock_init()
{
	self.type = undefined;
	self._door_open = 0;
	targets = GetEntArray(self.target, "targetname");
	self.doors = [];
	for(i = 0; i < targets.size; i++)
	{
		targets[i] zm_blockers::door_classify(self);
		targets[i].startPos = targets[i].origin;
	}
	self thread airlock_think();
}

function airlock_think()
{
	while(1)
	{
		self waittill("trigger", who);
		if(isdefined(self.doors[0].startPos) && self.doors[0].startPos != self.doors[0].origin)
		{
			continue;
		}
		for(i = 0; i < self.doors.size; i++)
		{
			self.doors[i] thread airlock_activate(0.25, 1);
		}
		self._door_open = 1;
		while(self moon_airlock_occupied() || (isdefined(self.doors[0].door_moving) && self.doors[0].door_moving == 1))
		{
			wait(0.1);
		}
		self thread door_clean_up_corpses();
		for(i = 0; i < self.doors.size; i++)
		{
			self.doors[i] thread airlock_activate(0.25, 0);
		}
		self._door_open = 0;
	}
}

function airlock_activate(time, open)
{
	if(!isdefined(time))
	{
		time = 1;
	}
	if(!isdefined(open))
	{
		open = 1;
	}
	if(isdefined(self.door_moving))
	{
		return;
	}
	self.door_moving = 1;
	self notsolid();
	if(self.classname == "script_brushmodel")
	{
		if(open)
		{
			self connectpaths();
		}
	}
	if(isdefined(self.script_sound))
	{
		if(open)
		{
			self playsound("zmb_airlock_open");
		}
		else
		{
			self playsound("zmb_airlock_close");
		}
	}
	scale = 1;
	if(!open)
	{
		scale = -1;
	}
	switch(self.script_string)
	{
		case "slide_apart":
		{
			if(isdefined(self.script_vector))
			{
				vector = VectorScale(self.script_vector, scale);
				if(open)
				{
					if(isdefined(self.startPos))
					{
						self moveto(self.startPos + vector, time);
					}
					else
					{
						self moveto(self.origin + vector, time);
					}
					self._door_open = 1;
				}
				else if(isdefined(self.startPos))
				{
					self moveto(self.startPos, time);
				}
				else
				{
					self moveto(self.origin - vector, time);
				}
				self._door_open = 0;
				self thread zm_blockers::door_solid_thread();
			}
			break;
		}
	}
}

function moon_airlock_occupied()
{
	is_occupied = 0;
	zombies = GetAIArray();
	for(i = 0; i < zombies.size; i++)
	{
		if(zombies[i] istouching(self))
		{
			is_occupied++;
		}
	}
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		if(players[i] istouching(self))
		{
			is_occupied++;
		}
	}
	if(is_occupied > 0)
	{
		if(isdefined(self.doors[0].startPos) && self.doors[0].startPos == self.doors[0].origin)
		{
			for(i = 0; i < self.doors.size; i++)
			{
				self.doors[i] thread airlock_activate(0.25, 1);
			}
			self._door_open = 1;
		}
		return 1;
	}
	else
	{
		return 0;
	}
}

function door_clean_up_corpses()
{
	corpses = GetCorpseArray();
	if(isdefined(corpses))
	{
		for(i = 0; i < corpses.size; i++)
		{
			if(corpses[i] istouching(self))
			{
				corpses[i] thread door_remove_corpses();
			}
		}
	}
}
function door_remove_corpses()
{
	if(isdefined(level._effect["dog_gib"]))
	{
		playFX(level._effect["dog_gib"], self.origin);
	}
	self delete();
}

function change_door_models()
{
	doors = GetEntArray(self.target, "targetname");
	for(i = 0; i < doors.size; i++)
	{
		if(isdefined(doors[i].model) && doors[i].model == "p7_zm_moo_door_airlock_heavy_lt_locked")
		{
			doors[i] SetModel("p7_zm_moo_door_airlock_heavy_lt");
		}
		else if(isdefined(doors[i].model) && doors[i].model == "p7_zm_moo_door_airlock_heavy_rt_locked")
		{
			doors[i] SetModel("p7_zm_moo_door_airlock_heavy_rt");
		}
		else if(isdefined(doors[i].model) && doors[i].model == "p7_zm_moo_door_airlock_heavy_single_locked")
		{
			doors[i] SetModel("p7_zm_moo_door_airlock_heavy_single");
		}
		doors[i] thread airlock_connect_paths();
	}
}

function airlock_connect_paths()
{
	if(self.classname == "script_brushmodel")
	{
		self notsolid();
		self connectpaths();
		if(!isdefined(self._door_open) || self._door_open == 0)
		{
			self solid();
		}
	}
}

function airlock_buy()
{
	self waittill("trigger", who, force);
	if(GetDvarInt("zombie_unlock_all") > 0 || (isdefined(force) && force))
	{
		return 1;
	}
	if(!who useButtonPressed())
	{
		return 0;
	}
	if(who zm_utility::in_revive_trigger())
	{
		return 0;
	}
	if(who.IS_DRINKING > 0)
	{
		return 0;
	}
	cost = 0;
	upgraded = 0;
	if(zm_utility::is_player_valid(who))
	{
		cost = self.zombie_cost;
		if(who zm_pers_upgrades_functions::is_pers_double_points_active())
		{
			cost = who zm_pers_upgrades_functions::pers_upgrade_double_points_cost(cost);
			upgraded = 1;
		}
		if(who zm_score::can_player_purchase(cost))
		{
			who zm_score::minus_to_player_score(cost);
			//scoreevents::processScoreEvent("open_door", who);
			//demo::bookmark("zm_player_door", GetTime(), who);
			who zm_stats::increment_client_stat("doors_purchased");
			who zm_stats::increment_player_stat("doors_purchased");
			who zm_stats::increment_challenge_stat("SURVIVALIST_BUY_DOOR");
			self.purchaser = who;
			who RecordMapEvent(5, GetTime(), who.origin, level.round_number, cost);
			//bb::function_91f32a58(who, self, cost, self.target, upgraded, "_door", "_purchase");
			who zm_stats::increment_challenge_stat("ZM_DAILY_PURCHASE_DOORS");
		}
		else
		{
			zm_utility::play_sound_at_pos("no_purchase", self.origin);
			who zm_audio::create_and_play_dialog("general", "outofmoney");
			return 0;
		}
	}
	return 1;
}

function function_9f47ebff()
{
	if(self.perk.script_noteworthy == "specialty_rof")
	{
		self.no_bullet_trace = 1;
	}
	return self;
}