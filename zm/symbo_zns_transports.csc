#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_weapons;
#using scripts\shared\filter_shared;
#using scripts\shared\visionset_mgr_shared;
#insert scripts\zm\symbo_zns_transports.gsh;

#precache( "client_fx", SEWER_CURRENT_FX);

#namespace namespace_34c58dc;


function autoexec init()
{
	clientfield::register("vehicle", "sewer_current_fx", 9000, 1, "int", &function_1647aec4, 0, 0);
	clientfield::register("toplayer", "tp_water_sheeting", 9000, 1, "int", &function_6be6da89, 0, 0);
	clientfield::register("toplayer", "wind_blur", 9000, 1, "int", &function_4a01cc4e, 0, 0);

	level._effect["current_effect"] = SEWER_CURRENT_FX;
}

function function_1647aec4(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(newVal == 1)
	{
		if(!isdefined(self.var_7e61ace3))
		{
			self.var_7e61ace3 = [];
		}
		self thread function_a39e4663(localClientNum);
	}
	else
	{
		self notify("hash_ab837d11");
		if(isdefined(self.var_7e61ace3[localClientNum]))
		{
			deletefx(localClientNum, self.var_7e61ace3[localClientNum], 0);
		}
	}
}


function function_a39e4663(localClientNum)
{
	self endon("hash_ab837d11");
	while(1)
	{
		self.var_7e61ace3[localClientNum] = PlayFXOnTag(localClientNum, level._effect["current_effect"], self, "tag_origin");
		wait(0.05);
	}
}

function function_6be6da89(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(newVal)
	{
		StartWaterSheetingFX(localClientNum, .5, .6);
		playsound(localClientNum, "evt_sewer_transport_start");
		self.var_14108ea4 = self PlayLoopSound("evt_sewer_transport_loop", 0.3);
		wait .6;
		StartWaterSheetingFX(localClientNum, 0, .1);
	}
	else
	{
		StopWaterSheetingFX(localClientNum, 0.5);
		self StopLoopSound(self.var_14108ea4);
	}
}


function function_4a01cc4e(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(newVal)
	{
        self PlayRumbleLoopOnEntity(localClientNum, "zm_island_rumble_zipline");
		EnableSpeedBlur(localClientNum, 0.07, 0.55, 0.9, 0, 100, 100);
	}
	else
	{
        self StopRumble(localClientNum,"zm_island_rumble_zipline");
		DisableSpeedBlur(localClientNum);
	}
}

