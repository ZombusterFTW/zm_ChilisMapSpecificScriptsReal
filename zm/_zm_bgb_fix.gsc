#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#insert scripts\zm\_zm_utility.gsh;

#insert scripts\zm\_zm_bgb_fix.gsh;

#namespace zm_bgb_fix;


REGISTER_SYSTEM_EX( "zm_bgb_fix", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "zbarrier", "bgb_set_state", VERSION_SHIP, 4, "int" );
	clientfield::register( "zbarrier", "bgb_set_limit_type", VERSION_SHIP, 4, "int" );
	clientfield::register( "zbarrier", "bgb_set_rarity", VERSION_SHIP, 4, "int" );
}

function __main__()
{
	if( !IsDefined( level.bgb_zbarrier_state_func ) )
	{
		level.bgb_zbarrier_state_func = &process_bgb_zbarrier_state;
	}
	
	wait(0.05);  // Wait for initialization stage to end so we can toggle client fields
	
	bgb_setup_gums();
	
	// Set up the BGB machines
	level.bgb_machines_fix = struct::get_array( "bgb_machine_use", "targetname" );
	bgb_machine_init();
	
	level.delayed_round_num = level.round_number;
	thread bgb_delayed_round_count();
	thread bgb_fire_sale_listener();
	
	// Set defaults for various BGB machine options
	// Number of active BGB machines (-1 means all machines, and they won't move)
	if ( !IsDefined(level.num_active_bgb_machines) )
	{
		level.num_active_bgb_machines = -1;
	}
	else if ( level.num_active_bgb_machines >= level.bgb_machines_fix.size || level.num_active_bgb_machines < 0 )
	{
		level.num_active_bgb_machines = -1;
	}
	
	// Disable movement of BGB machines
	if ( !IsDefined(level.disable_bgb_machines_moving) )
		level.disable_bgb_machines_moving = false;
	
	// Remove BGBs that only function in coop if solo
	if ( !IsDefined(level.remove_coop_bgbs_in_solo) )
		level.remove_coop_bgbs_in_solo = true;
	
	// Use player's BGB pack
	if ( !IsDefined(level.use_players_bgb_pack) )
		level.use_players_bgb_pack = false;
		
	if ( zm_utility::is_Classic() && level.enable_magic )
	{
		// Activate the BGB machines after small delay
		level flag::wait_till( "initial_blackscreen_passed" );
		wait(0.25);
		
		level.active_bgb_machines = [];
		initial_machines = [];
		
		if (level.num_active_bgb_machines == -1)
		{
			// Enable every BGB machine
			initial_machines = level.bgb_machines_fix;
		}
		else
		{
			// Randomly select BGB machines to be active initially
			// BGB prefabs with the initial kvp set to true have priority in initial spawns
			noninitial_machines = [];
			
			foreach(machine in array::randomize(level.bgb_machines_fix) )
			{
				if ( IsDefined(machine.script_string) && initial_machines.size < level.num_active_bgb_machines )
				{
					array::add(initial_machines, machine);
				}
				else
				{
					array::add(noninitial_machines, machine);
				}
			}
			// Add machines without initial kvp to initial set if current active < desired active
			i = 0;
			while (initial_machines.size < level.num_active_bgb_machines)
			{
				machine = noninitial_machines[i];
				array::add(initial_machines, machine);
				i++;
			}
		}
		
		// Activate machines in inital array
		foreach(machine in initial_machines)
		{
			array::add(level.active_bgb_machines, machine);
			machine.zbarrier set_bgb_zbarrier_state("arriving");
			machine.active = true;
		}
	}
}

function bgb_machine_init()
{
	for ( i = 0; i < level.bgb_machines_fix.size; i++ )
	{
		level.bgb_machines_fix[i].orig_origin = level.bgb_machines_fix[i].origin;
		level.bgb_machines_fix[i] thread get_machine_pieces();
		
		level.bgb_machines_fix[i].use_count = 0;
		level.bgb_machines_fix[i].active = false;
		level.bgb_machines_fix[i].fire_sale = false;
	}
	
	array::thread_all( level.bgb_machines_fix, &bgb_machine_think );
}

function get_machine_pieces()
{
	min_distance = undefined;
	closest_zbarrier = undefined;
	
	zbarrier_noteworthy = self.script_noteworthy + "_zbarrier";
	zbarriers = GetEntArray( zbarrier_noteworthy, "script_noteworthy" );
	
	foreach(zbarrier in zbarriers)
	{
		distance = distance2DSquared(self.origin, zbarrier.origin);
		if ( !IsDefined(min_distance) )
		{
			closest_zbarrier = zbarrier;
			min_distance = distance;
		}
		else if (distance < min_distance)
		{
			closest_zbarrier = zbarrier;
			min_distance = distance;
		}
	}
	
	self.zbarrier = closest_zbarrier;
	
	self.unitrigger_stub = SpawnStruct();
	self.unitrigger_stub.origin = self.origin;
	self.unitrigger_stub.angles = self.angles;
	self.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	self.unitrigger_stub.script_width = 45;
	self.unitrigger_stub.script_height = 72;
	self.unitrigger_stub.script_length = 45;
	self.unitrigger_stub.trigger_target = self;
	
	zm_unitrigger::unitrigger_force_per_player_triggers(self.unitrigger_stub, true);
	self.unitrigger_stub.prompt_and_visibility_func = &machinetrigger_update_prompt;
	
	self.zbarrier.owner = self;
	
	self.zbarrier set_bgb_zbarrier_state("away");
}

function machinetrigger_update_prompt( player )
{
	can_use = self machinestub_update_prompt( player );
	if( IsDefined(self.hint_string) )
	{
		if ( IsDefined(self.hint_parm1) )
			self SetHintString( self.hint_string, self.hint_parm1 );
		else
			self SetHintString( self.hint_string );
	}
	return can_use;
}

function machinestub_update_prompt( player )
{
	if (!self trigger_visible_to_player( player ))
		return false;
	
	cost = self.stub.trigger_target bgb_determine_cost(player);
	
	if (self.stub.trigger_target.bgb_string == "take")
	{
		self SetCursorHint( "HINT_BGB", self.stub.trigger_target.bgb_chosen.stat_index );
		self.hint_string = &"ZOMBIE_BGB_MACHINE_OFFERING";
	}
	else if (cost === false)
	{
		self setCursorHint( "HINT_NOICON" );
		self.hint_string = &"ZOMBIE_BGB_MACHINE_COMEBACK";
	}
	else
	{
		self setCursorHint( "HINT_NOICON" );
		self.hint_parm1 = cost;
		self.hint_string = &"ZOMBIE_BGB_MACHINE_AVAILABLE";
	}
	
	return true;
}

function trigger_visible_to_player(player)
{
	self SetInvisibleToPlayer(player);

	visible = true;	
	
	if( !zm_perks::vending_trigger_can_player_use(player) )
	{
		visible = false;
	}
	else if ( IsDefined(self.stub.trigger_target.bgb_user) )
	{
		bgb_user = self.stub.trigger_target.bgb_user;
		if( player != bgb_user || zm_utility::is_placeable_mine( bgb_user GetCurrentWeapon() ) || bgb_user zm_equipment::hacker_active())
		{
			visible = false;
		}
	}
	
	if( !visible )
	{
		return false;
	}
	
	self SetVisibleToPlayer(player);
	return true;
}

function bgb_unitrigger_think()
{
	self endon("kill_trigger");

	while (true)
	{
		self waittill( "trigger", player );
		self.stub.trigger_target notify("trigger", player);
	}
}

function bgb_setup_gums()
{
	index = 1;
	table = "gamedata/weapons/zm/zm_levelcommon_bgb.csv";
	
	row = TableLookupRow( table, index );
	while ( IsDefined( row ) )
	{
		name			= zm_weapons::checkStringValid( row[ BGB_TABLE_COL_NAME ] );
		stat_index 		= int( row[ BGB_TABLE_COL_STAT_INDEX ] );
		camo_index		= int( row[ BGB_TABLE_COL_CAMO_INDEX ] );
		limit_type		= int( row[ BGB_TABLE_COL_LIMIT_TYPE ] );
		rarity			= int( row[ BGB_TABLE_COL_RARITY ] );
		coop_only		= ( ToLower( row[ BGB_TABLE_COL_COOP_ONLY ] ) == "true" );
		
		add_zombie_bgb(name, stat_index, camo_index, limit_type, rarity, coop_only);
		
		index++;
		row = TableLookupRow( table, index );
	}
	
	//iprintlnbold("Loaded "+(index-1)+" BGBs");
}

function add_zombie_bgb(name, stat_index, camo_index, limit_type, rarity, coop_only)
{
	struct = SpawnStruct();
	
	if ( !IsDefined( level.zombie_bgbs ) )
	{
		level.zombie_bgbs = [];
		level.zombie_bgbs_solo = [];
	}
	
	struct.name = name;
	struct.stat_index = stat_index;
	struct.camo_index = camo_index;
	struct.limit_type = limit_type;
	struct.rarity = rarity;
	struct.coop_only = coop_only;
	
	level.zombie_bgbs[name] = struct;
	if (!coop_only)
	{
		level.zombie_bgbs_solo[name] = struct;
	}
}

function bgb_machine_think()
{
	player = undefined;
	self.bgb_user = undefined;
	self.bgb_string = "buy";
	
	while (true) {
		// BGB machine idle
		self waittill( "trigger", player );
		if (player == level)
			continue;
		
		// Player interacts with machine
		cost = self bgb_determine_cost(player);
		if (cost === false)
			continue;
		
		if( !player zm_score::can_player_purchase( cost ) )
		{
			self playsound("evt_perk_deny");
			player zm_audio::create_and_play_dialog( "general", "outofmoney" );
			continue;
		}
		
		// Player has bought a BGB
		self.bgb_user = player;
		thread zm_unitrigger::unregister_unitrigger(self.unitrigger_stub);
		self.use_count++;
		
		player.bgb_use_count++;
		player.bgb_use_round = level.delayed_round_num;
		
		player zm_score::minus_to_player_score( cost );
		
		// Decide the BGB to give
		self.bgb_chosen = bgb_determine_gum(player);
		
		// Begin dispensing
		self.zbarrier set_bgb_zbarrier_state("dispense");
		
		self.zbarrier waittill("dispensed");
		
		// BGB ready to be taken
		self.bgb_string = "take";
		thread zm_unitrigger::register_static_unitrigger(self.unitrigger_stub, &bgb_unitrigger_think);
		
		reason = self util::waittill_any_timeout( 5.5, "trigger" );
		if (reason == "trigger") {
			// The BGB was taken by the player
			self.zbarrier set_bgb_zbarrier_state("gum_taken");
			thread bgb_eat_gumball_sequence(player, self.bgb_chosen);
		}
		
		// Wait until dispense related animations are complete
		thread zm_unitrigger::unregister_unitrigger(self.unitrigger_stub);
		self.zbarrier waittill("dispense_complete");
		
		// Don't count as a use for this machine during fire sale
		if (self.fire_sale)
			self.use_count--;
		
		// Reset variables
		player = undefined;
		self.bgb_user = undefined;
		self.bgb_string = "buy";
		
		if (!level.zombie_vars["zombie_powerup_fire_sale_on"])
		{
			self.fire_sale = false;
		}
		
		// Determine if BGB machine should move
		if (!self.active && !level.zombie_vars["zombie_powerup_fire_sale_on"])
		{
			self.zbarrier set_bgb_zbarrier_state("leaving");
			self.use_count = 0;
		}
		else if ( self bgb_machine_should_move() )
		{
			self thread bgb_machine_move();
		}
		else
		{
			wait(0.5);
			thread zm_unitrigger::register_static_unitrigger(self.unitrigger_stub, &bgb_unitrigger_think);
		}
	}
}

function bgb_determine_cost(player)
{
	// Treyarch's original cost function
	if ( !IsDefined(player.bgb_use_round) || player.bgb_use_round != level.delayed_round_num )
	{
		// New round, reset player's uses
		player.bgb_use_round = level.delayed_round_num;
		player.bgb_use_count = 0;
	}
	
	round_bracket = Int(Floor(level.delayed_round_num / 10.0));
	round_bracket = Min(round_bracket, 10);
	
	if (level.zombie_vars["zombie_powerup_fire_sale_on"])
		base_cost = 10;
	else
		base_cost = 500;
	
	switch(player.bgb_use_count)
	{
		case 0:
			cost = base_cost;
			break;
		case 1:
			cost = Int( base_cost + 1000 * pow(2, round_bracket) );
			break;
		case 2:
			cost = Int( 500 + base_cost + 1000 * pow(2, round_bracket+1) );
			break;
		default:
			cost = false;
			break;
	}
	
	return cost;
}

// Listen for delayed end of round and update variable
function bgb_delayed_round_count()
{
	while (true)
	{
		level.delayed_round_num = level.round_number;
		level waittill( "between_round_over" );
	}
}

function bgb_determine_gum(player)
{
	if (level.use_players_bgb_pack)
	{
		// Treyarch's 5 gumball cycle using player's pack
		if ( !IsDefined(player.bgb_pack) )
		{
			player.bgb_pack = player GetBubbleGumPack();
			player.bgb_pack = array::randomize( player.bgb_pack );
		}
		
		key = array::pop(player.bgb_pack, 0, false);
		
		if (player.bgb_pack.size == 0)
		{
			player.bgb_pack = undefined;
		}	
	}
	else
	{
		// Random gumball from pool
		players = GetPlayers();
		if (players.size == 1 && level.remove_coop_bgbs_in_solo)
			random_keys = array::randomize( GetArrayKeys( level.zombie_bgbs_solo ) );
		else
			random_keys = array::randomize( GetArrayKeys( level.zombie_bgbs ) );
		
		key = random_keys[0];
	}
	return level.zombie_bgbs[key];
}

function bgb_machine_should_move()
{
	if (level.num_active_bgb_machines == -1)
	{
		// Don't move if all BGB machines are active
		return false;
	}
	else if ( level.disable_bgb_machines_moving )
	{
		// Don't move if moving has been intentionally disabled
		return false;
	}
	// Move if used 3 (or more) times
	return self.use_count >= 3;
}

function bgb_machine_move()
{
	self.zbarrier set_bgb_zbarrier_state("leaving");
	self.use_count = 0;
	
	wait(10.0);
	
	potential_spots = [];
	foreach(machine in level.bgb_machines_fix)
	{
		if (!array::contains(level.active_bgb_machines, machine))
		{
			array::add(potential_spots, machine);
		}
	}
	
	potential_spots = array::randomize(potential_spots);
	newly_active = potential_spots[0];
	
	level.active_bgb_machines = array::exclude(level.active_bgb_machines, self);
	array::add(level.active_bgb_machines, newly_active);
	if (newly_active.zbarrier.state == "away")  // Fix for fire sale causing state to possibly be not away
		newly_active.zbarrier set_bgb_zbarrier_state("arriving");
	self.active = false;
	newly_active.active = true;
}

// Listen for fire sale
function bgb_fire_sale_listener()
{
	while (true)
	{
		level waittill( "fire_sale_on" );
		foreach(machine in level.bgb_machines_fix)
		{
			machine thread apply_fire_sale_to_machine();
			
		}
		level waittill( "fire_sale_off" );
		foreach(machine in level.bgb_machines_fix)
		{
			machine thread remove_fire_sale_from_machine();
		}
	}
}

function apply_fire_sale_to_machine()
{
	self.fire_sale = true;
	
	if (self.zbarrier.state == "away" || self.zbarrier.state == "leaving") {
		if (self.zbarrier.state == "leaving")
		{
			self.zbarrier waittill("away");
		}
		if (!level.zombie_vars["zombie_powerup_fire_sale_on"])  // Check fire sale still running
			return;
		
		self.zbarrier set_bgb_zbarrier_state("arriving");
	}
}

function remove_fire_sale_from_machine()
{
	// Machines that are currently in use will take care of themselves
	if (self.zbarrier.state == "idle")
	{
		self.fire_sale = false;
		if (!self.active)
		{
			thread zm_unitrigger::unregister_unitrigger(self.unitrigger_stub);
			self.zbarrier set_bgb_zbarrier_state("leaving");
		}
	}
}

// Play the eat gumball sequence
function bgb_eat_gumball_sequence(player, gum) {
	weapon = player bgb_give_gumball_begin( gum );
	evt = player util::waittill_any_return( "fake_death", "death", "player_downed", "weapon_change_complete", "perk_abort_drinking", "disconnect" );
	
	if ( player laststand::player_is_in_laststand() || IS_TRUE( player.intermission ) )
	{
		return;
	}
	
	// Stop flavor hexed replacing taken gum
	player notify("bgbs_consumed_hexed_users_override");
	
	if ( player bgb::is_enabled( "zm_bgb_ephemeral_enhancement" ) )
	{
		// Fix for Ephermeral Enhancement leaving player with no weapon if swapped while active
		player bgb_give_gumball_end( weapon, gum );
		player bgb::give( gum.name );
	}
	else
	{
		player bgb::give( gum.name );
		player bgb_give_gumball_end( weapon, gum );
	}
}

// Give the gumball weapon to the player
function bgb_give_gumball_begin( gum )
{
	self zm_utility::increment_is_drinking();
	
	self zm_utility::disable_player_move_states(true);

	original_weapon = self GetCurrentWeapon();
	
	bgb_weapon = GetWeapon("zombie_bgb_grab");
	bgb_weapon = self GetBuildKitWeapon(bgb_weapon, false);
	weapon_options = self GetBuildKitWeaponOptions(bgb_weapon, gum.camo_index);
	acvi = self GetBuildKitAttachmentCosmeticVariantIndexes( bgb_weapon, false );
	
	self GiveWeapon( bgb_weapon, weapon_options, acvi );
	self SwitchToWeapon( bgb_weapon );

	return original_weapon;
}

// Remove the gumball weapon from the player
function bgb_give_gumball_end( original_weapon, gum )
{
	self endon( "perk_abort_drinking" );

	Assert( !original_weapon.isPerkBottle );
	Assert( original_weapon != level.weaponReviveTool );

	self zm_utility::enable_player_move_states();
	
	weapon = "zombie_bgb_grab";
	
	if ( self laststand::player_is_in_laststand() || IS_TRUE( self.intermission ) )
	{
		self TakeWeapon(weapon);
		return;
	}

	self TakeWeapon(weapon);

	if( self zm_utility::is_multiple_drinking() )
	{
		self zm_utility::decrement_is_drinking();
		return;
	}
	else if( original_weapon != level.weaponNone && !zm_utility::is_placeable_mine( original_weapon ) && !zm_equipment::is_equipment_that_blocks_purchase( original_weapon ) )
	{
		self zm_weapons::switch_back_primary_weapon( original_weapon );
		
		if( zm_utility::is_melee_weapon( original_weapon ) )
		{
			self zm_utility::decrement_is_drinking();
			return;
		}
	}
	else 
	{
		self zm_weapons::switch_back_primary_weapon();
	}

	self waittill( "weapon_change_complete" );

	if ( !self laststand::player_is_in_laststand() && !IS_TRUE( self.intermission ) )
	{
		self zm_utility::decrement_is_drinking();
	}
}

function set_bgb_zbarrier_state(state)
{
	for (i = 0; i < self GetNumZBarrierPieces(); i++)
	{
		self HideZBarrierPiece(i);
	}
	self notify("zbarrier_state_change");
	
	self [[level.bgb_zbarrier_state_func]](state);
}

function process_bgb_zbarrier_state(state)
{
	self notify(state);
	self.state = state;
	switch(state)
	{
		case "away":
			self ShowZBarrierPiece(1);
			self thread bgb_away();
			break;
		case "arriving":
			self ShowZBarrierPiece(1);
			self ShowZBarrierPiece(3);
			self thread bgb_fill_machine();
			break;
		case "idle":
			self ShowZBarrierPiece(0);
			self ShowZBarrierPiece(3);
			self ShowZBarrierPiece(5);
			self thread bgb_idle();
			break;
		case "dispense":
			self ShowZBarrierPiece(2);
			self ShowZBarrierPiece(3);
			self ShowZBarrierPiece(4);
			self ShowZBarrierPiece(5);
			self thread bgb_dispense();
			break;
		case "gum_taken":
			self ShowZBarrierPiece(2);
			self ShowZBarrierPiece(3);
			self ShowZBarrierPiece(5);
			self thread bgb_gum_taken();
			break;
		case "leaving":
			self ShowZBarrierPiece(1);
			self ShowZBarrierPiece(3);
			self thread bgb_empty_machine();
			break;
		default:
			break;
	}
}

// Machine is disabled, idle
function bgb_away()
{
	self clientfield::set( "bgb_set_state", ZM_BGB_MACHINE_FX_STATE_CF_AWAY );
}

// Machine is moving here (shaking, filling up)
function bgb_fill_machine()
{
	self SetZBarrierPieceState(1, "opening");
	self clientfield::set( "bgb_set_state", ZM_BGB_MACHINE_FX_STATE_CF_ARRIVING );
	while(self GetZBarrierPieceState(1) == "opening")
	{
		wait (0.1);
	}
	self SetZBarrierPieceState(1, "closing");
	self SetZBarrierPieceState(3, "opening");
	while(self GetZBarrierPieceState(3) == "opening")
	{
		wait (0.1);
	}
	self set_bgb_zbarrier_state("idle");
	thread zm_unitrigger::register_static_unitrigger(self.owner.unitrigger_stub, &bgb_unitrigger_think);
}

// Machine is active, idle
function bgb_idle()
{
	self SetZBarrierPieceState(3, "open");
	self clientfield::set( "bgb_set_state", ZM_BGB_MACHINE_FX_STATE_CF_IDLE );
}

// Gumball is dispensed and waits for user to take it
// Swallows gumball if not taken (this is part of the opening animation of the lion head)
function bgb_dispense()
{
	self endon("gum_taken");
	
	self clientfield::set( "bgb_set_limit_type", self.owner.bgb_chosen.limit_type );
	self clientfield::set( "bgb_set_rarity", self.owner.bgb_chosen.rarity );
	self SetZBarrierPieceState(4, "opening");
	self SetZBarrierPieceState(3, "open");
	self SetZBarrierPieceState(5, "open");
	self clientfield::set( "bgb_set_state", ZM_BGB_MACHINE_FX_STATE_CF_DISPENSING );
	wait(2.0);
	self SetZBarrierPieceState(2, "opening");
	self HideZBarrierPiece(4);
	wait(1.0);
	self clientfield::set( "bgb_set_state", ZM_BGB_MACHINE_FX_STATE_CF_READY );
	self notify("dispensed");
	wait(5.5);
	self clientfield::set( "bgb_set_state", ZM_BGB_MACHINE_FX_STATE_CF_IDLE );
	wait(4.0);
	
	self notify("dispense_complete");
}

// Gumball was taken by user
function bgb_gum_taken()
{
	self SetZBarrierPieceState(2, "closing");
	self SetZBarrierPieceState(3, "open");
	self SetZBarrierPieceState(5, "open");
	self clientfield::set( "bgb_set_state", ZM_BGB_MACHINE_FX_STATE_CF_IDLE );
	wait (3.0);
	
	self notify("dispense_complete");
}

// Machine is leaving here (shaking, emptying)
function bgb_empty_machine()
{
	self SetZBarrierPieceState(1, "opening");
	self clientfield::set( "bgb_set_state", ZM_BGB_MACHINE_FX_STATE_CF_LEAVING );
	while(self GetZBarrierPieceState(1) == "opening")
	{
		wait (0.1);
	}
	self SetZBarrierPieceState(1, "closing");
	self SetZBarrierPieceState(3, "closing");
	while(self GetZBarrierPieceState(3) == "closing")
	{
		wait (0.1);
	}
	self set_bgb_zbarrier_state("away");
}