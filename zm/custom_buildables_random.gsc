#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#precache("model", "p7_zm_der_pswitch_body");
#precache("model", "p7_zm_der_pswitch_handle");
#precache("model", "p7_zm_zod_fuse");
#precache("weapon", "zombie_builder");
#precache( "material", "power_panel_shader");
#precache( "material", "power_handle_shader");
#precache( "material", "power_fuse_shader");
#namespace custom_buildables_random;

  ///////////////////////////////////////
 //         ITITIALIZE FLAGS          //
///////////////////////////////////////
function init(){
	level flag::wait_till("all_players_connected");
	foreach(player in GetPlayers()){
		player.shader_var = [];
	}
	//wait(3);
	//FLAG COMMANDS: 
	//level flag::init("flagname", false); <-- false so flag is OFF by default, but registered for use in script
	//level flag::set("flagname"); <-- turns on "flagname"
	//level flag::clear("flagname"); <-- turns off "flagname"
	//level flag::get("flagname"); <-- returns true or false if "flagname" is on or off
	//Color codes
	//^1 - RED
	//^2 - GREEN
	//^3 - YELLOW
	//^4 - BLUE
	//^5 - CYAN
	//^6 - PINK
	//^7 - WHITE
	//^8 - DEFAULT MAP COLOR
	//^9 - GREY OR DEFAULT MAP COLOR
	//^0 - BLACK
	thread buildable_power();
	//thread buildable_e115();
}

  ///////////////////////////////////////
 //         BUIDABLE POWER            //
///////////////////////////////////////
function buildable_power(){
	finalflag = "power_crafted";
	level flag::init(finalflag, false);
	level flag::init("handle_flag", false);
	level flag::init("panel_flag", false);
	level flag::init("fuse_flag", false);
	//power_trig = GetEnt("use_elec_switch", "targetname");
	//power_trig SetCursorHint("HINT_NOICON");
	//power_trig TriggerEnable(false);
	//power_clip = GetEnt("power_clip", "targetname");
	//power_clip Hide();
	//power_panel = GetEnt("powerbuildarea", "script_noteworthy");
	//power_panel Hide();
	power_lever = GetEnt("elec_switch", "script_noteworthy");
	power_lever Hide();
	power_bench = GetEnt("craft_bench", "targetname");
	bench_fx_loc = GetEnt(power_bench.target, "targetname");
	power_bench.built = false;
	power_bench SetCursorHint("HINT_NOICON");
	power_bench SetHintString("Missing parts");
	fuses = GetEntArray("power_fuse", "script_noteworthy");
	handles = GetEntArray("power_handle", "script_noteworthy");
	panels = GetEntArray("power_panel", "script_noteworthy");
	thread random_spawn(handles, "handle_flag", "p7_zm_der_pswitch_handle", "high-voltage lever");
	thread random_spawn(panels, "panel_flag", "p7_zm_der_pswitch_body", "industrial housing");
	thread random_spawn(fuses, "fuse_flag", "p7_zm_zod_fuse", "electrical fuse");
	power_bench thread build_logic(bench_fx_loc, finalflag, "handle_flag", "panel_flag", "fuse_flag", "electrical panel");
	//This function can be copied, and renamed to easily
	//create new buildables. Just change the "craft_bench"
	//targetname on the bench trigger to "craft_bench_trig_name" etc
	//It threads all the stamped prefabs for specified parts
	//and deletes all but one. The prefab comes with the model, but you
	//first position the prefab wherever you want the part to spawn, then
	//you stamp the prefab.
	//Lastly -- Threads the random spawn function with the array's of
	//each part's possible spawn locations, and the flags to activate when picked up

	while(1){
		if(level flag::get("power_crafted") == true){
			//power_clip Show();
			//power_panel Show();
			//power_lever Show();
			//power_trig TriggerEnable(true);
			level notify("switchbuiltpower");
			break;
		}else
		wait(.1);
	}
}

  ///////////////////////////////////////
 //          BUILD LOGIC              //
///////////////////////////////////////
function build_logic(bench_fx_loc, final_flag, part1_flag, part2_flag, part3_flag, build_hint){
	while(1){
		if(level flag::get(part1_flag) && level flag::get(part2_flag) && level flag::get(part3_flag)){
			self SetHintString("Hold &&1 to build "+build_hint);
			self waittill("trigger", player);
			self SetHintString("");
			player PlaySound("build_loop");
			PlayFX(level._effect["building_dust"], bench_fx_loc);
			player thread crafting_hud(self, final_flag);
			player thread custom_craft_anim();
			player util::waittill_any("build_canceled", "build_complete");
			player StopSound("build_loop");
			player StopSounds();
			wait(0.1);
			if(self.built == true){
				player PlaySound("build_done");
				foreach(player in GetPlayers()){
					player.shader_var1 Destroy();
					player.shader_var2 Destroy();
					player.shader_var3 Destroy();
				}
				self Delete();
				break;
			}
		}else
		wait(1);
	}
}

  ///////////////////////////////////////
 //          RANDOM SPAWN             //
///////////////////////////////////////
function random_spawn(parts, flag, model, hint){
	r = RandomInt(parts.size);
	foreach(part in parts){
		part_model = GetEnt(part.target, "targetname");
		if(part == parts[r]){
			part thread part_pickup(flag, hint, part_model);
		}else{
			part_model Delete();
			part Delete();
		}
	}
	//Takes in the parts[] array, and flags, you send from your
	//buildable function. The parts array is an array of triggers
	//left behind from stamping a 'random spawn point' - prefab
	//The function then chooses a random trigger to save, and deletes 
	//the rest of the unused triggers and the script_models they're targeting
	//Part pick-up logic is threaded last, right before deleting all
	//the spawn locations of the random parts that weren't chosen to spawn
}

  ///////////////////////////////////////
 //        PART PICKUP LOGIC          //
///////////////////////////////////////
function part_pickup(flag, hint, part){
	self SetCursorHint("HINT_NOICON");
	self SetHintString("Press &&1 to pickup "+hint);
	self waittill("trigger", player);
	level flag::set(flag);
	player PlaySound("zmb_craftable_pickup");
	wait(0.1);
	PlayFX(level._effect["powerup_grabbed"], self.origin);
	foreach(player in GetPlayers()){
		switch(self.script_int){
			case 1:
			if(player IsSplitScreen())
				player thread part_shader_logic("power_fuse_shader", 1, 12, 30);
			else				
				player thread part_shader_logic("power_fuse_shader", 1, 24, 60);
			break;
			case 2:
			if(player IsSplitScreen())
				player thread part_shader_logic("power_panel_shader", 2, 15, 30);			
			else	
				player thread part_shader_logic("power_panel_shader", 2, 31, 60);
			break;			
			case 3:
			if(player IsSplitScreen())
				player thread part_shader_logic("power_handle_shader", 3, 18, 30);
			else	
				player thread part_shader_logic("power_handle_shader", 3, 35, 60);
			break;
		}
	part Delete();
	self Delete();
	}
}

  ///////////////////////////////////////
 //         PART SHADER LOGIC         //
///////////////////////////////////////
function part_shader_logic(shader, position, size_x, size_y){
	hud = position - 1;
	self.shader_var[hud] = NewClientHudElem(self); 
	self.shader_var[hud].alignX = "right"; 
	self.shader_var[hud].alignY = "top";
	self.shader_var[hud].horzAlign = "user_right";
	self.shader_var[hud].vertAlign = "user_top"; 
	if(self IsSplitScreen())
		self.shader_var[hud].y = ((size_y * position) + 10) - 25;
	else
		self.shader_var[hud].y = ((size_y * position) + 10);
	self.shader_var[hud].x = -5;
	self.shader_var[hud] setShader(shader, size_x, size_y);
	self waittill("power_crafted");	
	foreach(shader in self.shader_var){
		shader Destroy();
	}
}

  ///////////////////////////////////////
 //     CUSTOM CRAFTING ANIMATION     //
///////////////////////////////////////
function custom_craft_anim(){
	self endon("disconnect");
	self craft_anim_begin();
	self util::waittill_any("fake_death", "death", "player_downed", "weapon_change_complete", "build_canceled", "build_complete");
	self craft_anim_end();
}

  ///////////////////////////////////////
 //     CRAFTING ANIMATION BEGIN      //
///////////////////////////////////////
function craft_anim_begin(){
	self zm_utility::increment_is_drinking();
	self zm_utility::disable_player_move_states(true);
	primaries = self GetWeaponsListPrimaries();
	original_weapon = self GetCurrentWeapon();
	weapon = GetWeapon("zombie_builder");
	self GiveWeapon(weapon);
	self SwitchToWeapon(weapon);
}

  ///////////////////////////////////////
 //      CRAFTING ANIMATION END       //
///////////////////////////////////////
function craft_anim_end(){
	self zm_utility::enable_player_move_states();
	weapon = GetWeapon("zombie_builder");
	if(self laststand::player_is_in_laststand() || IS_TRUE(self.intermission)){
		self TakeWeapon(weapon);
		return;
	}
	self zm_utility::decrement_is_drinking();
	self TakeWeapon(weapon);
	primaries = self GetWeaponsListPrimaries();
	if(IS_DRINKING(self.is_drinking)){
		return;
	}else{
		self zm_weapons::switch_back_primary_weapon();
	}
}

  ///////////////////////////////////////
 //       CUSTOM CRAFTING HUD         //
///////////////////////////////////////
function crafting_hud(trig, flag){
	self.useBar = self hud::createPrimaryProgressBar();
	self.useBarText = self hud::createPrimaryProgressBarText();
	self.useBarText SetText("Crafting...");
	self thread crafting_hud_update(GetTime(), 3000, trig, flag);
}

  ///////////////////////////////////////
 //   CRAFTING HUD UPDATE FUNCTION    //
///////////////////////////////////////
function crafting_hud_update(start_time, craft_time, trig, flag){
	self endon("entering_last_stand");
	self endon("death");
	self endon("disconnect");
	self endon("build_canceled");
	
	while(1){
		progress = (GetTime() - start_time) / craft_time;
		dist = Distance(self.origin, trig.origin);
		if(dist > 100 || !self UseButtonPressed() && progress < 1){
			self.useBarText hud::destroyElem();
			self.useBar hud::destroyElem();
			self notify("build_canceled");
			break;
		}
		if(progress < 0){
			progress = 0;
		}
		if(progress > 1 || GetTime() - start_time > craft_time && self UseButtonPressed()){
			level flag::set(flag);
			foreach(player in GetPlayers()){
				player notify(flag);
			}
			trig.built = true;
			self notify("build_complete");
			self.useBarText hud::destroyElem();
			self.useBar hud::destroyElem();
			return trig;
			break;
		}
		if(!self UseButtonPressed() && progress < 1){
			self.useBarText hud::destroyElem();
			self.useBar hud::destroyElem();
			self notify("build_canceled");
			break;
		}
		self.useBar hud::UpdateBar(progress);
		WAIT_SERVER_FRAME;
	}
}