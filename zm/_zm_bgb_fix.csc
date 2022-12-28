#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_bgb_fix.gsh;

// BEGIN PRECACHE
#precache( "client_fx", "zombie/fx_bgb_machine_eye_activated_zmb" );
#precache( "client_fx", "zombie/fx_bgb_machine_eye_event_zmb" );
#precache( "client_fx", "zombie/fx_bgb_machine_eye_rounds_zmb" );
#precache( "client_fx", "zombie/fx_bgb_machine_eye_time_zmb" );

#precache( "client_fx", "zombie/fx_bgb_machine_available_zmb" );
#precache( "client_fx", "zombie/fx_bgb_machine_bulb_away_zmb" );
#precache( "client_fx", "zombie/fx_bgb_machine_bulb_available_zmb" );

#precache( "client_fx", "zombie/fx_bgb_machine_bulb_activated_zmb" );
#precache( "client_fx", "zombie/fx_bgb_machine_bulb_event_zmb" );
#precache( "client_fx", "zombie/fx_bgb_machine_bulb_rounds_zmb" );
#precache( "client_fx", "zombie/fx_bgb_machine_bulb_time_zmb" );

#precache( "client_fx", "zombie/fx_bgb_machine_bulb_spark_zmb" );
#precache( "client_fx", "zombie/fx_bgb_machine_smoke_zmb" );
#precache( "client_fx", "zombie/fx_bgb_machine_flying_embers_down_zmb" );
#precache( "client_fx", "zombie/fx_bgb_machine_flying_embers_up_zmb" );

#precache( "client_fx", "zombie/fx_bgb_machine_flying_elec_zmb" );
#precache( "client_fx", "zombie/fx_bgb_machine_light_interior_zmb" );
#precache( "client_fx", "zombie/fx_bgb_machine_light_interior_away_zmb" );
// END PRECACHE

#namespace zm_bgb_fix;


REGISTER_SYSTEM( "zm_bgb_fix", &__init__, undefined )

function __init__()
{
	clientfield::register( "zbarrier", "bgb_set_state", VERSION_SHIP, 4, "int", &bgb_set_state_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "bgb_set_limit_type", VERSION_SHIP, 4, "int", &bgb_set_limit_type_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "bgb_set_rarity", VERSION_SHIP, 4, "int", &bgb_set_rarity_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function bgb_set_state_callback( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	self.state = newVal;
	switch(self.state)
	{
		case ZM_BGB_MACHINE_FX_STATE_CF_IDLE:
			self bgb_idle_callback( localClientNum );
			break;
		case ZM_BGB_MACHINE_FX_STATE_CF_DISPENSING:
			self bgb_dispensing_start_callback( localClientNum );
			break;
		case ZM_BGB_MACHINE_FX_STATE_CF_READY:
			self bgb_dispensing_ready_callback( localClientNum );
			break;
		case ZM_BGB_MACHINE_FX_STATE_CF_LEAVING:
			self bgb_moving_callback( localClientNum );
			break;
		case ZM_BGB_MACHINE_FX_STATE_CF_AWAY:
			self bgb_away_callback( localClientNum );
			break;
		case ZM_BGB_MACHINE_FX_STATE_CF_ARRIVING:
			self bgb_moving_callback( localClientNum );
			break;
	}
}

// TODO: potential race condition?
function bgb_set_limit_type_callback( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	switch(newVal)
	{
		case BGB_LIMIT_TYPE_ACTIVATED_INDEX:
			self.limit_type = BGB_LIMIT_TYPE_ACTIVATED;
			self.limit_type_fx_name = ZM_BGB_MACHINE_BULB_ACTIVATED_FX;
			self.eye_fx_name = ZM_BGB_MACHINE_EYE_ACTIVATED_FX;
			break;
		case BGB_LIMIT_TYPE_EVENT_INDEX:
			self.limit_type = BGB_LIMIT_TYPE_EVENT;
			self.limit_type_fx_name = ZM_BGB_MACHINE_BULB_EVENT_FX;
			self.eye_fx_name = ZM_BGB_MACHINE_EYE_EVENT_FX;
			break;
		case BGB_LIMIT_TYPE_ROUNDS_INDEX:
			self.limit_type = BGB_LIMIT_TYPE_ROUNDS;
			self.limit_type_fx_name = ZM_BGB_MACHINE_BULB_ROUNDS_FX;
			self.eye_fx_name = ZM_BGB_MACHINE_EYE_ROUNDS_FX;
			break;
		case BGB_LIMIT_TYPE_TIME_INDEX:
			self.limit_type = BGB_LIMIT_TYPE_TIME;
			self.limit_type_fx_name = ZM_BGB_MACHINE_BULB_TIME_FX;
			self.eye_fx_name = ZM_BGB_MACHINE_EYE_TIME_FX;
			break;
	}
}

// TODO: potential race condition?
function bgb_set_rarity_callback( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	switch(newVal)
	{
		case BGB_RARITY_CLASSIC_INDEX:
			self.rarity = BGB_RARITY_CLASSIC_TAG;
			break;
		case BGB_RARITY_MEGA_INDEX:
			self.rarity = BGB_RARITY_MEGA_TAG;
			break;
		case BGB_RARITY_RARE_INDEX:
			self.rarity = BGB_RARITY_RARE_TAG;
			break;
		case BGB_RARITY_ULTRA_RARE_INDEX:
			self.rarity = BGB_RARITY_ULTRA_RARE_TAG;
			break;
		case BGB_RARITY_WHIMSICAL_INDEX:
			self.rarity = BGB_RARITY_WHIMSICAL_TAG;
			break;
	}
}

// Sets lion gumball and flying gumballs to correct type / rarity
function bgb_alter_models_callback( localClientNum )
{
	give_gumball_model = self ZBarrierGetPiece(2);
	flying_gumball_model = self ZBarrierGetPiece(4);
		
	tag_location = "tag_gumball_"+self.limit_type+"_"+self.rarity;
	
	give_gumball_model HidePart(localClientNum, "tag_gumballs", "p7_zm_zod_bubblegum_machine_lion_head_gumball", true);
	
	give_gumball_model ShowPart(localClientNum, tag_location, "p7_zm_zod_bubblegum_machine_lion_head_gumball", true);
	
	limit_type_array = [];
	limit_type_array[0] = BGB_LIMIT_TYPE_ACTIVATED;
	limit_type_array[1] = BGB_LIMIT_TYPE_EVENT;
	limit_type_array[2] = BGB_LIMIT_TYPE_ROUNDS;
	limit_type_array[3] = BGB_LIMIT_TYPE_TIME;
	
	flying_gumball_model HidePart(localClientNum, "tag_gumballs", "p7_zm_zod_bubblegum_machine_gumballs_flying", true);
	
	for (i = 0; i < 10; i++)
	{
		if (i == 0)
		{
			rng_type = self.limit_type;
		}
		else
		{
			limit_type_array = array::randomize( limit_type_array );
			rng_type = limit_type_array[0];
		}
		
		tag_location = "tag_gumball_"+rng_type+"_"+i;
		
		flying_gumball_model ShowPart(localClientNum, tag_location, "p7_zm_zod_bubblegum_machine_gumballs_flying", true);
	}
}

// Handles playing most FX
function bgb_play_fx_callback( localClientNum, fx_location, fx_name )
{
	DEFAULT( self.fx_array, [] );
	
	if (isDefined(self.fx_array[fx_location]))
	{
		DeleteFX( localClientNum, self.fx_array[fx_location] );
		self.fx_array[fx_location] = undefined;
	}
	
	if (fx_name)
	{
		if (self.state == ZM_BGB_MACHINE_FX_STATE_CF_AWAY || self.state == ZM_BGB_MACHINE_FX_STATE_CF_ARRIVING || self.state == ZM_BGB_MACHINE_FX_STATE_CF_LEAVING)
		{
			model_part = self ZBarrierGetPiece(1);
		}
		else {
			switch(fx_location)
			{
				case ZM_BGB_MACHINE_EYE_FX_TAG_LEFT:
				case ZM_BGB_MACHINE_EYE_FX_TAG_RIGHT:
					model_part = self ZBarrierGetPiece(2);
					break;
				default:
					model_part = self ZBarrierGetPiece(5);
					break;
			}
		}
		self.fx_array[fx_location] = PlayFXOnTag( localClientNum, fx_name, model_part, fx_location );
	}
}

// Deletes FX created via bgb_play_fx_callback()
function bgb_cleanup_all_fx_callback( localClientNum )
{
	foreach( fx in self.fx_array )
	{
		DeleteFX( localClientNum, fx );
	}
	self.fx_array = [];
}

function bgb_idle_callback( localClientNum )
{
	self notify("bgb_change_state");
	self endon("bgb_change_state");
	
	self bgb_cleanup_all_fx_callback( localClientNum );
	
	if ( !isDefined(self.interior_fx) ) {
		model_part = self ZBarrierGetPiece(5);
		self.interior_fx = PlayFXOnTag( localClientNum, ZM_BGB_MACHINE_LIGHT_INTERIOR_FX, model_part, ZM_BGB_MACHINE_LIGHT_INTERIOR_FX_TAG );
	}
	
	while (true)
	{
		playsound( localClientNum, "zmb_bgb_machine_light_click", self.origin );
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_TOP, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_LEFT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_RIGHT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		wait(0.75);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_TOP, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_RIGHT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, false);
		wait(0.75);
		playsound( localClientNum, "zmb_bgb_machine_light_click", self.origin );
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_TOP, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_LEFT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_RIGHT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		wait(0.75);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_TOP, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_RIGHT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, false);
		wait(0.75);
		playsound( localClientNum, "zmb_bgb_machine_light_click", self.origin );
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_TOP, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		wait(0.5);
		playsound( localClientNum, "zmb_bgb_machine_light_click", self.origin );
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		wait(0.5);
		playsound( localClientNum, "zmb_bgb_machine_light_click", self.origin );
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_LEFT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_RIGHT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		wait(0.5);
		playsound( localClientNum, "zmb_bgb_machine_light_click", self.origin );
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_RIGHT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		wait(0.5);
		playsound( localClientNum, "zmb_bgb_machine_light_click", self.origin );
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		wait(0.5);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_TOP, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, false);
		wait(0.75);
	}
}

function bgb_dispensing_start_callback( localClientNum )
{
	self notify("bgb_change_state");
	self endon("bgb_change_state");
	
	self bgb_cleanup_all_fx_callback( localClientNum );
	
	self bgb_alter_models_callback( localClientNum );
	
	self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_FLYING_ELEC_FX_TAG, ZM_BGB_MACHINE_FLYING_ELEC_FX);
	
	while (true)
	{
		playsound( localClientNum, "zmb_bgb_machine_light_click", self.origin );
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_TOP, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_LEFT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_RIGHT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, ZM_BGB_MACHINE_BULB_AVAILABLE_FX);
		wait(0.25);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_TOP, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_RIGHT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, false);
		wait(0.25);
	}
}

function bgb_dispensing_ready_callback( localClientNum )
{
	self notify("bgb_change_state");
	self endon("bgb_change_state");
	
	self bgb_cleanup_all_fx_callback( localClientNum );
	
	self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_EYE_FX_TAG_LEFT, self.eye_fx_name);
	self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_EYE_FX_TAG_RIGHT, self.eye_fx_name);
	
	while (true)
	{
		playsound( localClientNum, "zmb_bgb_machine_light_ready", self.origin );
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_TOP, self.limit_type_fx_name);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_LEFT, self.limit_type_fx_name);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_RIGHT, self.limit_type_fx_name);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, self.limit_type_fx_name);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, self.limit_type_fx_name);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, self.limit_type_fx_name);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, self.limit_type_fx_name);
		wait (0.5);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_TOP, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_RIGHT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, false);
		wait(0.5);
	}
}

function bgb_away_callback( localClientNum )
{
	self notify("bgb_change_state");
	self endon("bgb_change_state");
	
	self bgb_cleanup_all_fx_callback( localClientNum );
	
	if ( !isDefined(self.interior_fx_away) ) {
		model_part = self ZBarrierGetPiece(1);
		self.interior_fx_away = PlayFXOnTag( localClientNum, ZM_BGB_MACHINE_LIGHT_INTERIOR_AWAY_FX, model_part, ZM_BGB_MACHINE_LIGHT_INTERIOR_FX_TAG );
	}
	
	self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_TOP, ZM_BGB_MACHINE_BULB_AWAY_FX);
	self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_LEFT, ZM_BGB_MACHINE_BULB_AWAY_FX);
	self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_RIGHT, ZM_BGB_MACHINE_BULB_AWAY_FX);
	self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, ZM_BGB_MACHINE_BULB_AWAY_FX);
	self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, ZM_BGB_MACHINE_BULB_AWAY_FX);
	self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, ZM_BGB_MACHINE_BULB_AWAY_FX);
	self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, ZM_BGB_MACHINE_BULB_AWAY_FX);
}

function bgb_moving_callback( localClientNum )
{
	self notify("bgb_change_state");
	self endon("bgb_change_state");
	
	self bgb_cleanup_all_fx_callback( localClientNum );
	
	self thread bgb_moving_callback_smoke( localClientNum );
	
	self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_EYE_FX_TAG_LEFT, ZM_BGB_MACHINE_EYE_AWAY_FX);
	self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_EYE_FX_TAG_RIGHT, ZM_BGB_MACHINE_EYE_AWAY_FX);
	
	while (true)
	{
		playsound( localClientNum, "zmb_bgb_machine_light_leaving", self.origin );
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_TOP, ZM_BGB_MACHINE_BULB_AWAY_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_LEFT, ZM_BGB_MACHINE_BULB_AWAY_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_RIGHT, ZM_BGB_MACHINE_BULB_AWAY_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, ZM_BGB_MACHINE_BULB_AWAY_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, ZM_BGB_MACHINE_BULB_AWAY_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, ZM_BGB_MACHINE_BULB_AWAY_FX);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, ZM_BGB_MACHINE_BULB_AWAY_FX);
		wait(0.5);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_TOP, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_TOP_RIGHT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_RIGHT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_LEFT, false);
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_BTM_RIGHT, false);
		wait(0.5);
	}
}

function bgb_moving_callback_smoke( localClientNum )
{
	wait(2.5);
	
	model_part = self ZBarrierGetPiece(1);
	
	// Hacky fix for smoke because tag location is bugged
	self.fx_array["smoke"] = PlayFX( localClientNum, ZM_BGB_MACHINE_SMOKE_FX, self.origin, AnglesToUp( self.angles ), AnglesToRight( self.angles ) );
	self.fx_array["spark"] = PlayFXOnTag( localClientNum, ZM_BGB_MACHINE_BULB_SPARK_FX, model_part, ZM_BGB_MACHINE_BULB_FX_TAG_SIDE_MID_LEFT );
	
	if (self.state == ZM_BGB_MACHINE_FX_STATE_CF_LEAVING)
	{
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_FLYING_EMBERS_FX_TAG, ZM_BGB_MACHINE_FLYING_EMBERS_DOWN_FX);
	}
	else
	{
		self bgb_play_fx_callback(localClientNum, ZM_BGB_MACHINE_FLYING_EMBERS_FX_TAG, ZM_BGB_MACHINE_FLYING_EMBERS_UP_FX);
	}
}