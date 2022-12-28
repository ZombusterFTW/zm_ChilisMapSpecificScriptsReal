#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\animation_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
#insert scripts\shared\shared.gsh;
#insert scripts\zm\symbo_zns_transports.gsh;

#using_animtree("generic");

#precache( "vehicle", "veh_default_zipline");
#precache( "xmodel", "p7_fxanim_zm_island_zipline_gate_mod");
#precache( "fx", SEWER_CURRENT_FX);
#precache( "xmodel", "p7_zm_isl_control_panel_cage");
#precache( "xmodel", "p7_zm_isl_control_panel_cage_off");

#namespace symbo_zns_transports;

function autoexec init()
{
	clientfield::register("vehicle", "sewer_current_fx", 9000, 1, "int");
	clientfield::register("toplayer", "tp_water_sheeting", 9000, 1, "int");
	clientfield::register("toplayer", "wind_blur", 9000, 1, "int");

	level._effect["current_effect"] = SEWER_CURRENT_FX;

	level flag::wait_till("all_players_connected");
	Array::thread_all(struct::get_array("transport_zip_line", "targetname"), &setup_unitrigger);
	Array::thread_all(struct::get_array("transport_sewer", "targetname"), &setup_unitrigger);
}

function setup_unitrigger()
{
	if(isdefined(self.script_special) && self.script_special != "")
		self.thirdperson = self.script_special;

	else 
		self.thirdperson = THIRD_PERSON;

	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = self.origin;
	unitrigger_stub.angles = self.angles;
	unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	unitrigger_stub.radius = 64;
	unitrigger_stub.require_look_at = 0;
	unitrigger_stub.e_parent = self;
	if(self.targetname == "transport_zip_line")
	{
		if(isdefined(self.zombie_cost) && self.zombie_cost != "")
			self.cost = self.zombie_cost;

		else 
			self.cost = ZIPLINE_COST;

		if(isdefined(self.speed) && self.speed != "")
			self.speed = self.speed;

		else 
			self.speed = ZIPLINE_SPEED;

		unitrigger_stub init_ziplines();
		unitrigger_stub.prompt_and_visibility_func = &zipline_trig_visibility;
		zm_unitrigger::register_static_unitrigger(unitrigger_stub, &ziplines_trigger);
	}
	else
	{
		if(isdefined(self.zombie_cost) && self.zombie_cost != "")
			self.cost = self.zombie_cost;

		else 
			self.cost = SEWER_COST;

		if(isdefined(self.speed) && self.speed != "")
			self.speed = self.speed;

		else 
			self.speed = SEWER_SPEED;

		unitrigger_stub init_sewers();
		unitrigger_stub.prompt_and_visibility_func = &sewer_trig_visibility;
		zm_unitrigger::register_static_unitrigger(unitrigger_stub, &sewers_trigger);
	}
}

function ziplines_trigger()
{
	struct_zipline = ArrayGetClosest(self.origin, struct::get_array("transport_zip_line", "targetname"));
	struct_zipline.first_use = true;
	struct_zipline.gate SetIgnorePauseWorld(1);
	while(1)
	{
		self waittill("trigger", e_who);
		if(struct_zipline flag::get("flag_zipline_in_use"))
			continue;

		if(isdefined(struct_zipline.arrival) && struct_zipline.arrival flag::get("flag_zipline_in_use"))
			continue;

		if(IS_TRUE(WAIT_FOR_POWER) && !level flag::get("power_on"))
			continue;

		if(!e_who zm_score::can_player_purchase(struct_zipline.cost))
			e_who zm_audio::create_and_play_dialog("general", "outofmoney");
		
		else
		{
			struct_zipline flag::set("flag_zipline_in_use");

			if(isdefined(struct_zipline.arrival))
				struct_zipline.arrival flag::set("flag_zipline_in_use");
			
			if(isdefined(struct_zipline.gate))
				struct_zipline thread open_gate_logic(e_who, "p7_fxanim_zm_island_zipline_gate_open_bundle", "p7_fxanim_zm_island_zipline_gate_close_bundle");

			if(IS_TRUE(struct_zipline.first_use) && isdefined(struct_zipline.script_flag))
				{
					struct_zipline.first_use = false;
					level flag::set(struct_zipline.script_flag);
				}

			e_who zm_score::minus_to_player_score(struct_zipline.cost);
			e_who thread vehicle_start(struct_zipline, 0);
		}	
	}
}

function sewers_trigger()
{
	struct_sewer = ArrayGetClosest(self.origin, struct::get_array("transport_sewer", "targetname"));
	struct_sewer.first_use = true;
	struct_sewer.gate SetIgnorePauseWorld(1);
	while(1)
	{
		self waittill("trigger", e_who);
		if(struct_sewer flag::get("flag_sewer_in_use"))
			continue;

		if(isdefined(struct_sewer.arrival) && struct_sewer.arrival flag::get("flag_sewer_in_use"))
			continue;

		if(IS_TRUE(WAIT_FOR_POWER) && !level flag::get("power_on"))
			continue;

		if(!e_who zm_score::can_player_purchase(struct_sewer.cost))
			e_who zm_audio::create_and_play_dialog("general", "outofmoney");
		
		else
		{
			struct_sewer flag::set("flag_sewer_in_use");

			if(isdefined(struct_sewer.arrival))
				struct_sewer.arrival flag::set("flag_sewer_in_use");
			
			if(isdefined(struct_sewer.gate))
				struct_sewer thread open_gate_logic(e_who, "p7_fxanim_zm_island_pipe_hatch_open_bundle", "p7_fxanim_zm_island_pipe_hatch_close_bundle");

			if(IS_TRUE(struct_sewer.first_use) && isdefined(struct_sewer.script_flag))
				{
					struct_sewer.first_use = false;
					level flag::set(struct_sewer.script_flag);
				}

			e_who zm_score::minus_to_player_score(struct_sewer.cost);
			e_who thread vehicle_start(struct_sewer, 1);
		}	
	}
}

function init_ziplines()
{
	self.e_parent.gate = GetEnt(self.e_parent.target, "targetname");

	node = GetVehicleNode(self.e_parent.target,"targetname");
	vehicle = SpawnVehicle("veh_default_zipline",node.origin,node.angles);
	vehicle SetSpeedImmediate(200);
	vehicle vehicle::get_on_path(node);
	vehicle vehicle::go_path();

	self.e_parent.arrival = ArrayGetClosest(vehicle.origin, struct::get_array("transport_zip_line", "targetname"));

	if(Distance(vehicle.origin, self.e_parent.arrival.origin) > ZIPLINE_LAST_NODE_RADIUS)
		self.e_parent.arrival = undefined;
	
	vehicle Delete();

	if(isdefined(self.e_parent.arrival))
		self.e_parent.gate_arrival = GetEnt(self.e_parent.arrival.target,"targetname");

	self.e_parent flag::init("flag_zipline_in_use");

	if(isdefined(self.e_parent.model) && self.e_parent.model != "")
		{
			self.e_parent.pannel = util::spawn_model(self.e_parent.model, self.e_parent.origin, self.e_parent.angles);
			self.e_parent thread pannel_on_and_off(self.e_parent.model, "p7_zm_isl_control_panel_cage", "flag_zipline_in_use");
		}
}

function init_sewers()
{
	self.e_parent.gate = GetEnt(self.e_parent.target, "targetname");

	node = GetVehicleNode(self.e_parent.target,"targetname");
	vehicle = SpawnVehicle("veh_default_zipline",node.origin,node.angles);
	vehicle SetSpeedImmediate(200);
	vehicle vehicle::get_on_path(node);
	vehicle vehicle::go_path();

	self.e_parent.arrival = ArrayGetClosest(vehicle.origin, struct::get_array("transport_sewer", "targetname"));

	if(Distance(vehicle.origin, self.e_parent.arrival.origin) > SEWER_LAST_NODE_RADIUS)
		self.e_parent.arrival = undefined;
	
	vehicle Delete();
	
	if(isdefined(self.e_parent.arrival))
		self.e_parent.gate_arrival = GetEnt(self.e_parent.arrival.target,"targetname");

	self.e_parent flag::init("flag_sewer_in_use");

	if(isdefined(self.e_parent.model) && self.e_parent.model != "")
		{
			self.e_parent.pannel = util::spawn_model(self.e_parent.model, self.e_parent.origin, self.e_parent.angles);
			self.e_parent thread pannel_on_and_off(self.e_parent.model, "p7_zm_isl_control_panel_cage", "flag_sewer_in_use");
		}
}

function pannel_on_and_off(off_model, on_model, flag)
{
	if(IS_TRUE(WAIT_FOR_POWER))
		level flag::wait_till("power_on");

	while(1)
		{
			self.pannel SetModel(on_model);
			if(isdefined(self.arrival.pannel))
				self.arrival.pannel SetModel(on_model);
			self flag::wait_till(flag);
			self.pannel SetModel(off_model);
			if(isdefined(self.arrival.pannel))
				self.arrival.pannel SetModel(off_model);
			self flag::wait_till_clear(flag);
		}
}

function open_gate_logic(player, anim_open, anim_close)
{
	self.gate thread scene::play(anim_open, self.gate);

	while(Distance(player.origin,self.gate.origin) < 150)
		wait .05;

	self.gate thread scene::play(anim_close, self.gate);

	if(!isdefined(self.gate_arrival))
		return;

	while(Distance(player.origin,self.gate_arrival.origin) > 220)
		wait .05;

	self.gate_arrival thread scene::play(anim_open, self.gate_arrival);

	player waittill("vehicle_over");

	self.gate_arrival thread scene::play(anim_close, self.gate_arrival);	
}

function vehicle_start(struct, variable)
{
	nd_path_start = GetVehicleNode(struct.target, "targetname");
	self.vehicle = SpawnVehicle("veh_default_zipline",(0,0,0),(0,0,0));

	self.vehicle SetIgnorePauseWorld(1);
	self HideViewModel();
	self util::magic_bullet_shield();
	self FreezeControls(1);
	self AllowSprint(0);
	self AllowJump(0);
	self DisableWeapons();

	wait(0.35);

	if(IS_TRUE(struct.thirdperson))
		self SetClientThirdPerson( 1 );

	self SetPlayerAngles(nd_path_start.angles);
	self.vehicle.origin = nd_path_start.origin;
	self.vehicle.angles = nd_path_start.angles;
	if(variable)
		self SetOrigin(self.vehicle.origin);

	else 
		self SetOrigin(self.vehicle GetTagOrigin("tag_zipline"));

	self.vehicle.e_parent = self;
	self.vehicle SetSpeed(struct.speed,1000);
	self.vehicle vehicle::get_on_path(nd_path_start);

	wait .05;

	if(variable)
		self PlayerLinkToDelta(self.vehicle, undefined, 1, 70, 70, 15, 60);

	else
		self PlayerLinkToDelta(self.vehicle, "tag_zipline", 1, 70, 70, 15, 60);
	
	
	if(variable)
		self thread animation::Play("cp_mi_sing_blackstation_water_flail");
	
	else
		self thread animation::Play("pb_zipline_loop_island");

	self thread vehicle_handle(variable,struct);
}

function vehicle_handle(variable,struct)
{
	self endon("disconnect");
	self endon("hash_f9ee8f48");
	if(variable)
	{
		self.vehicle thread sewer_veh_clientfield();
		self clientfield::set_to_player("tp_water_sheeting", 1);
	}
	else
	{
		self notify("hash_912d72b1");
		self clientfield::set_to_player("wind_blur", 1);
		self playsound("evt_zipline_attach");
		self PlayLoopSound("evt_zipline_move", 0.3);
		if(!level flag::get("solo_game"))
		{
			self.no_revive_trigger = 1;
		}
	}
	self.model_linked unlink();
	self.model_linked Delete();
	self ShowViewModel();
	self.vehicle vehicle::go_path();
	self.vehicle notify("finish_path");
	if(!variable)
	{
		self StopLoopSound(0.4);
	}
	self Unlink();
	self animation::stop();
	self notify("vehicle_over");
	if(variable)
	{
		if(isdefined(struct.script_int) && struct.script_int != "")
			self SetVelocity(AnglesToForward(self.angles) * struct.script_int );

		self zm_utility::clear_streamer_hint();
		self clientfield::set_to_player("tp_water_sheeting", 0);
	}
	else
	{
		self playsound("evt_zipline_detach");
		self clientfield::set_to_player("wind_blur", 0);
	}
	if(IS_TRUE(struct.thirdperson))
		self SetClientThirdPerson( 0 );

	self util::stop_magic_bullet_shield();
	self FreezeControls(0);
	self AllowSprint(1);
	self AllowJump(1);
	self enableWeapons();
	wait 2;
	self.vehicle delete();
	self.no_revive_trigger = 0;
	if(variable)
	{
		struct flag::clear("flag_sewer_in_use");
		struct.arrival flag::clear("flag_sewer_in_use");
	}
	else
	{
		struct flag::clear("flag_zipline_in_use");
		struct.arrival flag::clear("flag_zipline_in_use");
	}
}

function sewer_veh_clientfield()
{
	self clientfield::set("sewer_current_fx", 1);
	self waittill("finish_path");
	self clientfield::set("sewer_current_fx", 0);
}

function sewer_trig_visibility(player)
{
	if(isdefined(self.stub.e_parent.script_string) && self.stub.e_parent.script_string == "not_activate")
		{
			self setHintString("");
			return 0;
		}

	if(IS_TRUE(WAIT_FOR_POWER) && !level flag::get("power_on"))
		self setHintString("You must turn on the power first!");
	
	else if( self.stub.e_parent flag::get("flag_sewer_in_use"))
		self setHintString("Sewer in use");
	
	else if(isdefined(self.stub.e_parent.arrival) && self.stub.e_parent.arrival flag::get("flag_sewer_in_use"))
		self setHintString("Sewer in use");

	else
		self setHintString("Hold [{+activate}] to use the Sewer [Cost: " + self.stub.e_parent.cost + "]");

	return 1;
}

function zipline_trig_visibility(player)
{
	if(isdefined(self.stub.e_parent.script_string) && self.stub.e_parent.script_string == "not_activate")
		{
			self setHintString("");
			return 0;
		}

	if(IS_TRUE(WAIT_FOR_POWER) && !level flag::get("power_on"))
		self setHintString("You must turn on the power first!");
	
	else if(self.stub.e_parent flag::get("flag_zipline_in_use"))
		self setHintString("Zipline in use");
	
	else if(isdefined(self.stub.e_parent.arrival) && self.stub.e_parent.arrival flag::get("flag_zipline_in_use"))
		self setHintString("Zipline in use");

	else
		self setHintString("Hold [{+activate}] to use Zipline [Cost: " + self.stub.e_parent.cost + "]");

	return 1;
}