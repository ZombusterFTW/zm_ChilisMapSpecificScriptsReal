#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\weapons\_weaponobjects;
//#using scripts\zm\_zm_elemental_zombies;

#namespace electroball_grenade;

/*
	Name: __init__sytem__
	Namespace: namespace_3df25fcf
	Checksum: 0xFD18013
	Offset: 0x3E8
	Size: 0x33
	Parameters: 0
	Flags: AutoExec
*/

#precache( "client_fx", "dlc1/castle/fx_wpn_115_blob" );
#precache( "client_fx", "dlc1/castle/fx_wpn_115_bul_trail" );
#precache( "client_fx", "dlc1/castle/fx_wpn_115_canister" );



function autoexec __init__sytem__()
{
	system::register("electroball_grenade", &__init__, undefined, undefined);
}

/*
	Name: __init__
	Namespace: namespace_3df25fcf
	Checksum: 0x7758A97B
	Offset: 0x428
	Size: 0x223
	Parameters: 0
	Flags: None
*/
function __init__()
{
	clientfield::register("toplayer", "tazered", 1, 1, "int", undefined, 0, 0);
	clientfield::register("allplayers", "electroball_shock", 1, 1, "int", &shock_player_fx, 0, 0);
	clientfield::register("actor", "electroball_make_sparky", 1, 1, "int", &electroball_make_sparky, 0, 0);
	clientfield::register("missile", "electroball_stop_trail", 1, 1, "int", &on_land, 0, 0);
	clientfield::register("missile", "electroball_play_landed_fx", 1, 1, "int", &electroball_play_landed_fx, 0, 0);
	level._effect["fx_wpn_115_blob"] = "dlc1/castle/fx_wpn_115_blob";
	level._effect["fx_wpn_115_bul_trail"] = "dlc1/castle/fx_wpn_115_bul_trail";
	level._effect["fx_wpn_115_canister"] = "dlc1/castle/fx_wpn_115_canister";
	level._effect["electroball_grenade_player_shock"] = "weapon/fx_prox_grenade_impact_player_spwner";
	level._effect["electroball_grenade_sparky_conversion"] = "weapon/fx_prox_grenade_exp";
	callback::add_weapon_type("electroball_grenade", &proximity_spawned);
	level thread watchForProximityExplosion();
}

/*
	Name: proximity_spawned
	Namespace: namespace_3df25fcf
	Checksum: 0x1AC2C6A6
	Offset: 0x658
	Size: 0xB3
	Parameters: 1
	Flags: None
*/
function proximity_spawned(localClientNum)
{
	self util::waittill_dobj(localClientNum);
	if(self isGrenadeDud())
	{
		return;
	}
//IPrintLnBold("not dud");
	self.nade_trail = PlayFXOnTag(localClientNum, level._effect["fx_wpn_115_bul_trail"], self, "j_grenade_front");
	self.nade_canister = PlayFXOnTag(localClientNum, level._effect["fx_wpn_115_canister"], self, "j_grenade_back");
}

/*
	Name: watchForProximityExplosion
	Namespace: namespace_3df25fcf
	Checksum: 0x1A0A9F4E
	Offset: 0x718
	Size: 0x197
	Parameters: 0
	Flags: None
*/
function watchForProximityExplosion()
{
	if(GetActiveLocalClients() > 1)
	{
		return;
	}
	weapon_proximity = GetWeapon("electroball_grenade");
	while(1)
	{
		level waittill("explode", localClientNum, position, mod, weapon, owner_cent);
		if(weapon.rootweapon != weapon_proximity)
		{
			continue;
		}
		localPlayer = GetLocalPlayer(localClientNum);
		if(!localPlayer util::is_player_view_linked_to_entity(localClientNum))
		{
			explosionRadius = weapon.explosionRadius;
			if(DistanceSquared(localPlayer.origin, position) < explosionRadius * explosionRadius)
			{
				if(isdefined(owner_cent))
				{
					if(owner_cent == localPlayer || !owner_cent util::friend_not_foe(localClientNum, 1))
					{
						localPlayer thread postfx::playPostfxBundle("pstfx_shock_charge");
					}
				}
			}
		}
	}
}

/*
	Name: function_72eeb2e6
	Namespace: namespace_3df25fcf
	Checksum: 0xD7A9E66F
	Offset: 0x8B8
	Size: 0x153
	Parameters: 7
	Flags: None
*/
function electroball_make_sparky(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	ai_zombie = self;
	if(isdefined(level.a_electroball_grenades))
	{
		electroball = ArrayGetClosest(ai_zombie.origin, level.a_electroball_grenades);
	}
	a_sparky_tags = Array("J_Spine4", "J_SpineUpper", "J_Spine1");
	tag = Array::random(a_sparky_tags);
	if(isdefined(electroball))
	{
		var_d72ccbc = BeamLaunch(localClientNum, electroball, "tag_origin", ai_zombie, tag, "electric_arc_beam_electroball");
		wait(1);
		if(isdefined(var_d72ccbc))
		{
			BeamKill(localClientNum, var_d72ccbc);
		}
	}
}

/*
	Name: function_1619af16
	Namespace: namespace_3df25fcf
	Checksum: 0x723ACDD3
	Offset: 0xA18
	Size: 0x77
	Parameters: 7
	Flags: None
*/
function shock_player_fx(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	FX = PlayFXOnTag(localClientNum, level._effect["electroball_grenade_player_shock"], self, "J_SpineUpper");
}

/*
	Name: function_bd1f6a88
	Namespace: namespace_3df25fcf
	Checksum: 0x38108816
	Offset: 0xA98
	Size: 0x123
	Parameters: 7
	Flags: None
*/
function on_land(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(!isdefined(level.a_electroball_grenades))
	{
		level.a_electroball_grenades = [];
	}
	Array::add(level.a_electroball_grenades, self);
	self thread function_1d823abf();
	if(isdefined(self.nade_trail))
	{
		stopfx(localClientNum, self.nade_trail);
	}
	if(isdefined(self.var_626a3201))
	{
		stopfx(localClientNum, self.var_626a3201);
	}
	if(isdefined(self.var_7a731cc6))
	{
		stopfx(localClientNum, self.var_7a731cc6);
	}
	if(isdefined(self.nade_canister))
	{
		stopfx(localClientNum, self.nade_canister);
	}
}

/*
	Name: function_1d823abf
	Namespace: namespace_3df25fcf
	Checksum: 0xAA9EF4BF
	Offset: 0xBC8
	Size: 0x33
	Parameters: 0
	Flags: None
*/
function function_1d823abf()
{
	self waittill("entityshutdown");
	level.a_electroball_grenades = Array::remove_undefined(level.a_electroball_grenades);
}

/*
	Name: function_96325d01
	Namespace: namespace_3df25fcf
	Checksum: 0x5E8F2EA5
	Offset: 0xC08
	Size: 0xB7
	Parameters: 7
	Flags: None
*/
function electroball_play_landed_fx(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	self.landed_fx = PlayFXOnTag(localClientNum, level._effect["fx_wpn_115_blob"], self, "tag_fx");
	//self.var_3b22ba3c = PlayFXOnTag(localClientNum, level._effect["fx_wpn_115_blob"], self, "tag_origin");
	//dynEnt = CreateDynEntAndLaunch(localClientNum, "p7_zm_ctl_115_grenade_broken", self.origin, self.angles, self.origin, (0, 0, 0));
}

