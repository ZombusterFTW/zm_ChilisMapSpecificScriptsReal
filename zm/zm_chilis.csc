#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_perks;
//#using scripts\_NSZ\chilismainquest.csc;
// MECHZ ZOMBIE
#using scripts\zm\_zm_ai_mechz;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;

//Traps
//Traps
#using scripts\zm\zm_usermap;
// BO3 WEAPON STUFF
//#using scripts\zm\_zm_t7_weapons;

// DER WUNDERFIZZ
//#using scripts\zm\_zm_perk_random;
#using scripts\zm\_hb21_zm_magicbox;
#using scripts\zm\_hb21_zm_hero_weapon;
// BO3 WEAPONS
#using scripts\zm\craftables\_hb21_zm_craft_blundersplat;
#using scripts\zm\_hb21_zm_weap_blundersplat;
#using scripts\zm\_hb21_zm_weap_magmagat;
//#using scripts\zm\zm_giant_fx;
// Sphynx's Console Commands
#using scripts\Sphynx\_zm_subtitles;
// Sphynx's Craftables
//#using scripts\Sphynx\craftables\_zm_craft_gravityspikes;
//#using scripts\Sphynx\craftables\_zm_craft_spectral_shield;
// Sphynx's Craftables
#using scripts\Sphynx\craftables\_zm_craft_origins_shield;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\filter_shared;
#using scripts\shared\postfx_shared;
//#using scripts\zm\_zm_perk_elemental_pop;
//#insert scripts\zm\_zm_perk_elemental_pop.gsh;
//#using scripts\zm\_zm_T8_ZA;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;
//#using scripts\zm\_zm_perk_vulture_aid;
//#using scripts\zm\_zm_perk_whoswho;
//#using scripts\zm\_zm_perk_tombstone;
//#using scripts\zm\_zm_perk_phdflopper;
//#using scripts\zm\_zm_perk_elemental_pop;
//#using scripts\zm\_zm_perk_random;

#precache( "client_fx", "zombie/t9_perks_fx/share/raw/fx/custom/t9_perks/t9_jugg_fx" );
#precache( "client_fx", "zombie/t9_perks_fx/share/raw/fx/custom/t9_perks/t9_quick_revive_fx" );
#precache( "client_fx", "zombie/t9_perks_fx/share/raw/fx/custom/t9_perks/t9_speed_cola_fx" );
#precache( "client_fx", "zombie/t9_perks_fx/share/raw/fx/custom/t9_perks/t9_vending_ads_fx" );
#precache( "client_fx", "zombie/t9_perks_fx/share/raw/fx/custom/t9_perks/t9_staminup_fx" );
#precache ("client_fx", "custom/flashlight/flashlight_loop");
#precache ("client_fx", "custom/flashlight/flashlight_loop_world");
#precache ("client_fx", "custom/flashlight/flashlight_loop_view_moths");

#define JUGGERNAUT_MACHINE_LIGHT_FX                         "jugger_light"      
#define QUICK_REVIVE_MACHINE_LIGHT_FX                       "revive_light"      
#define STAMINUP_MACHINE_LIGHT_FX                           "marathon_light"    
#define SLEIGHT_OF_HAND_MACHINE_LIGHT_FX                    "sleight_light"        
#define DEADSHOT_MACHINE_LIGHT_FX                           "deadshot_light"   


//Frost Iceforge's custom eye color
#define RED_EYE_FX    "frost_iceforge/red_zombie_eyes"
#define ORANGE_EYE_FX    "frost_iceforge/orange_zombie_eyes"
#define GREEN_EYE_FX    "frost_iceforge/green_zombie_eyes"
#define BLUE_EYE_FX    "frost_iceforge/blue_zombie_eyes"
#define PURPLE_EYE_FX    "frost_iceforge/purple_zombie_eyes"
#define PINK_EYE_FX    "frost_iceforge/pink_zombie_eyes"
#define WHITE_EYE_FX    "frost_iceforge/white_zombie_eyes"
#precache( "client_fx", RED_EYE_FX );
#precache( "client_fx", ORANGE_EYE_FX );
#precache( "client_fx", GREEN_EYE_FX );
#precache( "client_fx", BLUE_EYE_FX );
#precache( "client_fx", PURPLE_EYE_FX );
#precache( "client_fx", PINK_EYE_FX );
#precache( "client_fx", WHITE_EYE_FX );




function main()
{
	//// LEVEL EFFECTS //// ##############################################################################

    level._effect[ "flashlight_fx_loop_view" ]          = "custom/flashlight/flashlight_loop";
    level._effect[ "flashlight_fx_loop_view_moths" ]    = "custom/flashlight/flashlight_loop_view_moths";
    level._effect[ "flashlight_fx_loop_world" ]         = "custom/flashlight/flashlight_loop_world";

    //// CLIENTFIELDS //// ##############################################################################

    clientfield::register( "toplayer",      "flashlight_fx_view",           VERSION_SHIP, 1, "int", &flashlight_fx_view,        !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    clientfield::register( "toplayer",      "filter_branch",           VERSION_SHIP, 1, "int", &filter_branch,        !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    clientfield::register( "toplayer",      "filter_hotel",           VERSION_SHIP, 1, "int", &filter_hotel,        !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    clientfield::register( "toplayer",      "filter_source",           VERSION_SHIP, 1, "int", &filter_source,        !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    clientfield::register( "toplayer",      "filter_brooms",           VERSION_SHIP, 1, "int", &filter_brooms,        !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    clientfield::register( "toplayer",      "tele_filter",           VERSION_SHIP, 1, "int", &tele_filter,        !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    clientfield::register( "allplayers",    "flashlight_fx_world",          VERSION_SHIP, 1, "int", &flashlight_fx_world,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
clientfield::register("world", "employeekeycardchilis", VERSION_SHIP, 1, "int", &CF, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
clientfield::register("world", "element153pic", VERSION_SHIP, 1, "int", &CF, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
visionset_mgr::register_visionset_info("desaturatedred", VERSION_SHIP, 1, undefined, "desaturatedred");

LuiLoad( "ui.uieditor.menus.hud.t7hud_zm_custom" );
	//HUD
LuiLoad("ui.uieditor.menus.hud.t7hud_zm_usermap");
	//TIMER
LuiLoad("ui.uieditor.widgets.zminventorystalingrad.gametimegroup");
LuiLoad("ui.uieditor.widgets.zminventorystalingrad.gametimewidget");

//clientfield::register("world", "piece_riotshield_door", VERSION_SHIP, 1, "int", &CF, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
//clientfield::register("world", "piece_riotshield_dolly", VERSION_SHIP, 1, "int", &CF, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
//clientfield::register("world", "piece_riotshield_clamp", VERSION_SHIP, 1, "int", &CF, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );

//P-06
	LuiLoad("ui.uieditor.widgets.reticles.chargeshot.chargershot_4corner_bracket");
	LuiLoad("ui.uieditor.widgets.reticles.chargeshot.chargershot_4corner_line");
	LuiLoad("ui.uieditor.widgets.reticles.chargeshot.chargershot_active_center");
	LuiLoad("ui.uieditor.widgets.reticles.chargeshot.chargershot_activelock");
	LuiLoad("ui.uieditor.widgets.reticles.chargeshot.chargershot_brackets");
	LuiLoad("ui.uieditor.widgets.reticles.chargeshot.chargershot_moving_arrow");
	LuiLoad("ui.uieditor.widgets.reticles.chargeshot.chargershot_reticle_side");
	LuiLoad("ui.uieditor.widgets.reticles.chargeshot.chargershot_top_arrow");
	LuiLoad("ui.uieditor.widgets.reticles.chargeshot.chargeshot_activeline");
	LuiLoad("ui.uieditor.widgets.reticles.chargeshot.chargeshot_centerreticle");
	LuiLoad("ui.uieditor.widgets.reticles.chargeshot.chargeshot_outerreticle");
	LuiLoad("ui.uieditor.widgets.reticles.chargeshot.chargeshot_reticle");
	LuiLoad("ui.uieditor.widgets.reticles.chargeshot.chargeshot_reticle_ui3d");
	LuiLoad("ui.uieditor.widgets.reticles.chargeshot.chargeshot_smallcenter");
	//R70 Ajax
	LuiLoad("ui.uieditor.widgets.reticles.infinite.lmginfinitereticle");
	LuiLoad("ui.uieditor.widgets.reticles.infinite.lmginfinitereticle_ammobar");
	LuiLoad("ui.uieditor.widgets.reticles.infinite.lmginfinitereticle_extras");
	LuiLoad("ui.uieditor.widgets.reticles.infinite.lmginfinitereticle_light");
	LuiLoad("ui.uieditor.widgets.reticles.infinite.lmginfinitereticle_status");
	LuiLoad("ui.uieditor.widgets.reticles.infinite.lmginfinitereticle_ui3d");
	LuiLoad("ui.uieditor.widgets.reticles.infinite.lmginfinitereticle_ui3d_internal");
	//LV8 Basilisk
	LuiLoad("ui.uieditor.widgets.reticles.pulserifle.pulseriflereticle_numbers");
	LuiLoad("ui.uieditor.widgets.reticles.pulserifle.pulseriflereticle_numbers_widget");
	LuiLoad("ui.uieditor.widgets.reticles.pulserifle.pulseriflereticle_numbersint");
	LuiLoad("ui.uieditor.widgets.reticles.pulserifle.pulseriflereticle_numbersscreen");
    LuiLoad("ui.Scobalula.InGame.Menus.ZMSettingsMenu");


	zm_usermap::main();

	include_weapons();
	
	util::waitforclient( 0 );

	//Frost Iceforge's custom eye color
	set_eye_color();

    foreach(player in GetLocalPlayers())
    {
        filter::init_filter_oob( player );
        filter::init_filter_ev_interference( player );
        filter::init_filter_tactical( player );
        filter::init_filter_overdrive( player );
        filter::init_filter_teleportation( player );
    }

}
//Frost Iceforge's custom eye color
function set_eye_color()
{
	level._override_eye_fx = PURPLE_EYE_FX; //Change "BLUE" to any of the other colors.
}



function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}
function CF( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    model = CreateUIModel( GetUIModelForController( localClientNum ), fieldName );
    SetUIModelValue( model, newVal );
}


//// FLASHLIGHT //// ##############################################################################


function tele_filter( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
    if ( newVal )
    {
        self thread postfx::PlayPostfxBundle( "zm_teleporter" );
    }
}

function filter_branch( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == player
{
    if ( newVal )
    {
        filter::enable_filter_oob( self, 0 );
    }
    else
    {
        filter::disable_filter_oob( self, 0 );
    }
}
function filter_hotel( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == player
{
    if ( newVal )
    {
        filter::enable_filter_ev_interference( self, 1 );
        filter::set_filter_ev_interference_amount( self, 1, 75 );
        wait(2);
        filter::enable_filter_ev_interference( self, 1 );
        filter::set_filter_ev_interference_amount( self, 1, 0.75 );
    }
    else
    {
        filter::disable_filter_ev_interference( self, 1 );
    }
}
function filter_source( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == player
{
    if ( newVal )
    {
        filter::enable_filter_tactical( self, 2 );
        filter::set_filter_tactical_amount( self, 2, 70 );

    }
    else
    {
        filter::disable_filter_tactical( self, 2 );
    }
}
function filter_brooms( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == player
{
    if ( newVal )
    {
        filter::enable_filter_ev_interference( self, 7 );
        filter::set_filter_ev_interference_amount( self, 7, 75 );
        wait(1);
        filter::set_filter_ev_interference_amount( self, 7, 0.35 );
        filter::enable_filter_oob( self, 0 );
    }
    else
    {
        filter::disable_filter_ev_interference( self, 7);
        filter::disable_filter_oob( self, 0 );
    }
}

function flashlight_fx_view( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == player
{
    if ( newVal )
    {
        if ( isdefined( self.fx_flashlight_view ) )
            KillFx( localClientNum, self.fx_flashlight_view );

        if ( isdefined( self.fx_flashlight_moth ) )
            KillFx( localClientNum, self.fx_flashlight_moth );

        flash_fx_view = level._effect[ "flashlight_fx_loop_view" ];
            self.fx_flashlight_view = PlayViewmodelFx( localclientnum, flash_fx_view, "tag_flash" ); 

        flash_fx_moth = level._effect[ "flashlight_fx_loop_view_moths" ];
            self.fx_flashlight_moth = PlayFxOnTag( localClientNum, flash_fx_moth, self, "j_spine4" );


            //check a player side bool to see if they are in an alt area and run a function on them. We can thread this in the main chilis.gsc onconnect like the flashlight func
        playsound( localClientNum, "flashlight_on", self.origin ); 
    }

    else
    {
        if ( isdefined( self.fx_flashlight_view ) )
        {
            KillFx( localClientNum, self.fx_flashlight_view );
                self.fx_flashlight_view = undefined;

            playsound( localClientNum, "flashlight_off", self.origin ); 
        }

        if ( isdefined( self.fx_flashlight_moth ) )
        {
            KillFx( localClientNum, self.fx_flashlight_moth );
                self.fx_flashlight_moth = undefined;
        }
    }
}

function flashlight_fx_world( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == player
{
    if ( newVal )
    {
        curr_player = GetLocalPlayer( localClientNum );

        if ( isdefined( self.fx_flashlight_world ) )
            KillFx( localClientNum, self.fx_flashlight_world );

        if( curr_player != self )
        {
            flash_fx_world = level._effect[ "flashlight_fx_loop_world" ];
                self.fx_flashlight_world = PlayFxOnTag( localClientNum, flash_fx_world, self, "tag_flash" );
        }
    }

    else
    {
        if ( isdefined( self.fx_flashlight_world ) )
        {
            KillFx( localClientNum, self.fx_flashlight_world );
                self.fx_flashlight_world = undefined;
        }
    }
}