//CODE NUMBER PAD SCRIPT v1.0 BY FROST ICEFORGE

#using scripts\zm\_zm;
#using scripts\zm\_zm_utility;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\zm\_zm_audio;
#using scripts\_NSZ\amonguselevatormaintenance;

//Set to false when you're ready to publish your map
#define DEBUG false
//Change to your preference
#define REQUIRE_POWER true
#define USE_SOUND_EFFECTS true
#define DOOR_OPEN_ANGLE_DEGREES 150
#define DOOR_OPEN_SPEED_SECS 3
#define GARAGE_DOOR_OPEN_HEIGHT 90
#define DELETE_DOOR_MODELS_WHEN_OPEN false


function __init__() {}

function unhideclipboards()
{
	foreach(hint in level.codenum_1_hints)
	{
		level waittill("unhidehint1amog");
		PlayFX(level._effect["powerup_grabbed"], hint.origin);
		hint show();
	}

	foreach(hint in level.codenum_2_hints)
	{
		level waittill("unhidehint2amog");
		PlayFX(level._effect["powerup_grabbed"], hint.origin);
		hint show();
	}

	foreach(hint in level.codenum_3_hints)
	{
		level waittill("unhidehint3amog");
		PlayFX(level._effect["powerup_grabbed"], hint.origin);
		hint show();
	}
}


function codenumcleanup(mod1, mod2, mod3, mod4)
{
	level waittill("codenumcleanup");
	mod1 Delete();
	mod2 Delete();
	mod3 Delete();
	mod4 Delete();
}

function codenum_init()
{
	//Get entities
	codenum_1_trig = GetEnt("codenum_1_trig", "targetname");
	codenum_2_trig = GetEnt("codenum_2_trig", "targetname");
	codenum_3_trig = GetEnt("codenum_3_trig", "targetname");
	codenum_1_trig UseTriggerRequireLookAt();
	codenum_2_trig UseTriggerRequireLookAt();
	codenum_3_trig UseTriggerRequireLookAt();

	codenum_1_digit = GetEnt("codenum_1_digit", "targetname");
	codenum_2_digit = GetEnt("codenum_2_digit", "targetname");
	codenum_3_digit = GetEnt("codenum_3_digit", "targetname");

	codenum_1_light = GetEnt("codenum_1_light", "targetname");
	codenum_2_light = GetEnt("codenum_2_light", "targetname");
	codenum_3_light = GetEnt("codenum_3_light", "targetname");

	level.codenum_1_hints = GetEntArray("codenum_1_hint", "targetname");
	level.codenum_2_hints = GetEntArray("codenum_2_hint", "targetname");
	level.codenum_3_hints = GetEntArray("codenum_3_hint", "targetname");

	codenum_industrial_door_models = GetEntArray("codenum_industrial_door_model", "targetname");
	level.oilsafedoor = GetEnt("oilsafedoor", "targetname");

	///level thread codenumcleanup(codenum_1_trig, codenum_2_trig, codenum_3_trig, level.oilsafedoor);
	codenum_door_clips = GetEntArray("codenum_door_clip", "targetname");
	codenum_double_security_door_right_models = GetEntArray("codenum_double_security_door_model_right", "targetname");
	codenum_double_security_door_left_models = GetEntArray("codenum_double_security_door_model_left", "targetname");
	codenum_garage_doors = GetEntArray("codenum_garage_door", "targetname");

	//Generate answer
	level.codenum_1 = RandomInt(10);
	level.codenum_2 = RandomInt(10);
	level.codenum_3 = RandomInt(10);
	//Prevent instant solve from 000 case
	if(level.codenum_1 == 0 && level.codenum_2 == 0 && level.codenum_3 == 0)
	{
		level.codenum_1 = RandomInt(9) + 1;
		level.codenum_2 = RandomInt(9) + 1;
		level.codenum_3 = RandomInt(9) + 1;
	}
	level thread amonguselevatormaintenance::announceoilsafecode(level.codenum_1, level.codenum_2, level.codenum_3);
	level thread unhideclipboards();
	//Select random hint from array of hints to show for each number
	foreach(hint in level.codenum_1_hints)
	{
		hint SetInvisibleToAll();
		codenum_set_hint_model(hint, level.codenum_1);
		hint hide();
	}
	level.codenum_1_hints[RandomInt(level.codenum_1_hints.size)] SetVisibleToAll();

	foreach(hint in level.codenum_2_hints)
	{
		hint SetInvisibleToAll();
		codenum_set_hint_model(hint, level.codenum_2);
		hint hide();
	}
	level.codenum_2_hints[RandomInt(level.codenum_2_hints.size)] SetVisibleToAll();

	foreach(hint in level.codenum_3_hints)
	{
		hint SetInvisibleToAll();
		codenum_set_hint_model(hint, level.codenum_3);
		hint hide();
	}
	level.codenum_3_hints[RandomInt(level.codenum_3_hints.size)] SetVisibleToAll();

	//Set initial states
	level.codenum_1_state = 0;
	level.codenum_2_state = 0;
	level.codenum_3_state = 0;
	//Set solution check boolean
	level.codenum_solved = false;

	//Initialize hintstrings
	codenum_1_trig SetHintString(&"ZOMBIE_NEED_POWER");
	codenum_1_trig SetCursorHint("HINT_NOICON");
	codenum_2_trig SetHintString(&"ZOMBIE_NEED_POWER");
	codenum_2_trig SetCursorHint("HINT_NOICON");
	codenum_3_trig SetHintString(&"ZOMBIE_NEED_POWER");
	codenum_3_trig SetCursorHint("HINT_NOICON");

	//Require power
	if(REQUIRE_POWER)
	{
		level waittill("power_on");
		codenum_1_trig SetHintString("Authorization Not Met");
		codenum_1_trig SetCursorHint("HINT_NOICON");
		codenum_2_trig SetHintString("Authorization Not Met");
		codenum_2_trig SetCursorHint("HINT_NOICON");
		codenum_3_trig SetHintString("Authorization Not Met");
		codenum_3_trig SetCursorHint("HINT_NOICON");
		level waittill("amongusconvo");
	}

	//Set hint colors of lights
	codenum_1_light SetModel("p7_light_fixture_led_utility_codenum_red");
	codenum_2_light SetModel("p7_light_fixture_led_utility_codenum_blue");
	codenum_3_light SetModel("p7_light_fixture_led_utility_codenum_yellow");
	//Start trigger threads
	codenum_1_trig thread codenum_trig_1_thread(codenum_1_digit);
	codenum_2_trig thread codenum_trig_2_thread(codenum_2_digit);
	codenum_3_trig thread codenum_trig_3_thread(codenum_3_digit);
	//Start solution checking thread
	level thread codenum_check_solution_thread();
	//Wait for code number to be solved
	level waittill("codenum_solved");
	//Set all lights to green to indicate success
	codenum_1_light SetModel("p7_light_fixture_led_utility_codenum_green");
	codenum_2_light SetModel("p7_light_fixture_led_utility_codenum_green");
	codenum_3_light SetModel("p7_light_fixture_led_utility_codenum_green");
	
	//Open doors
	level.oilsafedoor movez (30, 1);
	foreach(clip in codenum_door_clips)
	{
		clip Delete();
	}
	foreach(door in codenum_industrial_door_models)
	{
		if(DELETE_DOOR_MODELS_WHEN_OPEN)
		{
			door Delete();
		}
		else
		{
			door RotateYaw(DOOR_OPEN_ANGLE_DEGREES, DOOR_OPEN_SPEED_SECS);
		}
	}
	foreach(door in codenum_double_security_door_right_models)
	{
		if(DELETE_DOOR_MODELS_WHEN_OPEN)
		{
			door Delete();
		}
		else
		{
			door RotateYaw(DOOR_OPEN_ANGLE_DEGREES, DOOR_OPEN_SPEED_SECS);
		}
	}
	foreach(door in codenum_double_security_door_left_models)
	{
		if(DELETE_DOOR_MODELS_WHEN_OPEN)
		{
			door Delete();
		}
		else
		{
			door RotateYaw((-1 * DOOR_OPEN_ANGLE_DEGREES), DOOR_OPEN_SPEED_SECS);
		}
	}
	foreach(door in codenum_garage_doors)
	{
		if(DELETE_DOOR_MODELS_WHEN_OPEN)
		{
			door Delete();
		}
		else
		{
			door MoveZ(GARAGE_DOOR_OPEN_HEIGHT, DOOR_OPEN_SPEED_SECS);
		}
	}

	//Set hintstrings to indicate success
	codenum_1_trig SetHintString("Code accepted");
	codenum_2_trig SetHintString("Code accepted");
	codenum_3_trig SetHintString("Code accepted");
	wait(2);

	//Remove hintstrings
	codenum_1_trig Delete();
	codenum_2_trig Delete();
	codenum_3_trig Delete();

	level waittill("playercoveredinoil");
	level.oilsafedoor Delete();
}

function codenum_set_hint_model(model, codenum)
{
	switch(codenum)
	{
		case 0:
			model SetModel("p7_clipboard_01_wpaper_codenum_0");
			break;
		case 1:
			model SetModel("p7_clipboard_01_wpaper_codenum_1");
			break;
		case 2:
			model SetModel("p7_clipboard_01_wpaper_codenum_2");
			break;
		case 3:
			model SetModel("p7_clipboard_01_wpaper_codenum_3");
			break;
		case 4:
			model SetModel("p7_clipboard_01_wpaper_codenum_4");
			break;
		case 5:
			model SetModel("p7_clipboard_01_wpaper_codenum_5");
			break;
		case 6:
			model SetModel("p7_clipboard_01_wpaper_codenum_6");
			break;
		case 7:
			model SetModel("p7_clipboard_01_wpaper_codenum_7");
			break;
		case 8:
			model SetModel("p7_clipboard_01_wpaper_codenum_8");
			break;
		case 9:
			model SetModel("p7_clipboard_01_wpaper_codenum_9");
			break;
	}
}

function codenum_trig_1_thread(digit)
{
	self SetHintString("Press ^3[{+activate}]^7 to cycle");
	while(level.codenum_solved == false)
	{
		self waittill("trigger", player);
		if(level.codenum_solved == false)
		{
			if(USE_SOUND_EFFECTS)
			{
				player playLocalSound( "numpad_beep" );
			}
			level.codenum_1_state += 1;
			switch(level.codenum_1_state)
			{
				case 0:
					digit SetModel("codenum_pad_plane_0");
					break;
				case 1:
					digit SetModel("codenum_pad_plane_1");
					break;
				case 2:	
					digit SetModel("codenum_pad_plane_2");
					break;
				case 3:
					digit SetModel("codenum_pad_plane_3");
					break;
				case 4:
					digit SetModel("codenum_pad_plane_4");
					break;
				case 5:
					digit SetModel("codenum_pad_plane_5");
					break;
				case 6:	
					digit SetModel("codenum_pad_plane_6");
					break;
				case 7:
					digit SetModel("codenum_pad_plane_7");
					break;
				case 8:	
					digit SetModel("codenum_pad_plane_8");
					break;
				case 9:
					digit SetModel("codenum_pad_plane_9");
					break;
				default:
					digit SetModel("codenum_pad_plane_0");
					level.codenum_1_state = 0;
			}
			self SetHintString("Press ^3[{+activate}]^7 to cycle");
			level notify("codenum_updated");
		}
	}
}
function codenum_trig_2_thread(digit)
{
	self SetHintString("Press ^3[{+activate}]^7 to cycle");
	while(level.codenum_solved == false)
	{
		self waittill("trigger", player);
		if(level.codenum_solved == false)
		{
			if(USE_SOUND_EFFECTS)
			{
				player playLocalSound( "numpad_beep" );
			}
			level.codenum_2_state += 1;
			switch(level.codenum_2_state)
			{
				case 0:
					digit SetModel("codenum_pad_plane_0");
					break;
				case 1:
					digit SetModel("codenum_pad_plane_1");
					break;
				case 2:	
					digit SetModel("codenum_pad_plane_2");
					break;
				case 3:
					digit SetModel("codenum_pad_plane_3");
					break;
				case 4:
					digit SetModel("codenum_pad_plane_4");
					break;
				case 5:
					digit SetModel("codenum_pad_plane_5");
					break;
				case 6:	
					digit SetModel("codenum_pad_plane_6");
					break;
				case 7:
					digit SetModel("codenum_pad_plane_7");
					break;
				case 8:	
					digit SetModel("codenum_pad_plane_8");
					break;
				case 9:
					digit SetModel("codenum_pad_plane_9");
					break;
				default:
					digit SetModel("codenum_pad_plane_0");
					level.codenum_2_state = 0;
			}
			self SetHintString("Press ^3[{+activate}]^7 to cycle");
			level notify("codenum_updated");
		}
	}
}
function codenum_trig_3_thread(digit)
{
	self SetHintString("Press ^3[{+activate}]^7 to cycle");
	while(level.codenum_solved == false)
	{
		self waittill("trigger", player);
		if(level.codenum_solved == false)
		{
			if(USE_SOUND_EFFECTS)
			{
				player playLocalSound( "numpad_beep" );
			}
			level.codenum_3_state += 1;
			switch(level.codenum_3_state)
			{
				case 0:
					digit SetModel("codenum_pad_plane_0");
					break;
				case 1:
					digit SetModel("codenum_pad_plane_1");
					break;
				case 2:	
					digit SetModel("codenum_pad_plane_2");
					break;
				case 3:
					digit SetModel("codenum_pad_plane_3");
					break;
				case 4:
					digit SetModel("codenum_pad_plane_4");
					break;
				case 5:
					digit SetModel("codenum_pad_plane_5");
					break;
				case 6:	
					digit SetModel("codenum_pad_plane_6");
					break;
				case 7:
					digit SetModel("codenum_pad_plane_7");
					break;
				case 8:	
					digit SetModel("codenum_pad_plane_8");
					break;
				case 9:
					digit SetModel("codenum_pad_plane_9");
					break;
				default:
					digit SetModel("codenum_pad_plane_0");
					level.codenum_3_state = 0;
			}
			self SetHintString("Press ^3[{+activate}]^7 to cycle");
			level notify("codenum_updated");
		}
	}
}

function codenum_check_solution_thread()
{
	while(level.codenum_solved == false)
	{
		level waittill("codenum_updated");
		if((level.codenum_1 == level.codenum_1_state) && (level.codenum_2 == level.codenum_2_state) && (level.codenum_3 == level.codenum_3_state))
		{
			level.codenum_solved = true;
			level notify("codenum_solved");
			if(DEBUG)
			{
				IPrintLnBold("CODENUM SOLVED");
			}
			if(USE_SOUND_EFFECTS)
			{
				wait(0.2);
				foreach(player in GetPlayers())
				{
					if(USE_SOUND_EFFECTS)
					{
						player playLocalSound( "numpad_success" );
					}
				}
				
			}
			level notify("codenumstartcleanup");
		}
		else if(DEBUG)
		{
			IPrintLn("Need: " + level.codenum_1 + " " + level.codenum_2 + " " + level.codenum_3);
			IPrintLn("Have: " + level.codenum_1_state + " " + level.codenum_2_state + " " + level.codenum_3_state);
		}
	}
}