#using scripts\codescripts\struct;
#using scripts\shared\ai\archetype_apothicon_fury;
#using scripts\shared\ai\zombie;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#namespace namespace_c21dfba4;


#precache( "client_fx", "dlc4/genesis/fx_apothicon_fury_spawn_in");
#precache( "client_fx", "dlc4/genesis/fx_apothicon_fury_spawn_in_exp");

/*
	Name: __init__sytem__
	Namespace: namespace_c21dfba4
	Checksum: 0x9A29205B
	Offset: 0x320
	Size: 0x33
	Parameters: 0
	Flags: AutoExec
*/
function autoexec __init__sytem__()
{
	system::register("zm_genesis_apothicon_fury", &__init__, undefined, undefined);
}

/*
	Name: __init__
	Namespace: namespace_c21dfba4
	Checksum: 0xE9AB9C79
	Offset: 0x360
	Size: 0x99
	Parameters: 0
	Flags: None
*/
function __init__()
{
	if(ai::shouldRegisterClientFieldForArchetype("apothicon_fury"))
	{
		clientfield::register("scriptmover", "apothicon_fury_spawn_meteor", 15000, 2, "int", &apothicon_fury_spawn_meteor, 0, 0);
	}
	level._effect["apothicon_fury_meteor_fx"] = "dlc4/genesis/fx_apothicon_fury_spawn_in";
	level._effect["apothicon_fury_meteor_exp"] = "dlc4/genesis/fx_apothicon_fury_spawn_in_exp";
}

/*
	Name: function_87fb20f7
	Namespace: namespace_c21dfba4
	Checksum: 0x41DCBDA8
	Offset: 0x408
	Size: 0x14B
	Parameters: 7
	Flags: None
*/
function apothicon_fury_spawn_meteor(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(newVal === 0)
	{
		if(isdefined(self.var_7b71ef61))
		{
			stopfx(localClientNum, self.var_7b71ef61);
		}
	}
	if(newVal === 1)
	{
		self.var_7b71ef61 = PlayFXOnTag(localClientNum, level._effect["apothicon_fury_meteor_fx"], self, "tag_origin");
	}
	if(newVal == 2)
	{
		PlayFXOnTag(localClientNum, level._effect["apothicon_fury_meteor_exp"], self, "tag_origin");
		self Earthquake(0.1, 1, self.origin, 100);
		self PlayRumbleOnEntity(localClientNum, "damage_heavy");
	}
}

