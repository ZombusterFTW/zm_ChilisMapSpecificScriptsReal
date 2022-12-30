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

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
//#using scripts\zm\zm_giant_fx;
#using scripts\shared\ai\zombie_utility;
//#using scripts\zm\v7_giant_fx;
//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\shared\lui_shared;
// MECHZ ZOMBIE
#using scripts\zm\_zm_ai_mechz;
//#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_perks;
#using scripts\_NSZ\ice_insta_teleporter;
//#using scripts\zm\_zm_bgb_fix;
#using scripts\zm\jukeboxv2random;
#using scripts\zm\_zm_ai_dogs;


//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
///#using scripts\zm\_zm_trap_electric;
#using scripts\_redspace\rs_o_jump_pad;
//#using scripts\zm\_zm_powerup_weapon_minigun;

#using scripts\zm\zm_usermap;
#using scripts\zm\_hb21_zm_behavior;
// Sphynx's Craftables
//#using scripts\Sphynx\craftables\_zm_craft_gravityspikes;
//#using scripts\Sphynx\craftables\_zm_craft_spectral_shield;
//#using scripts\zm\custom_buildables_random;
//#using scripts\zm\floating_debris;
#using scripts\zm\codenum;
#using scripts\zm\bo4_carpenter;
//REX CEILING FAN
#using scripts\shared\array_shared;

//Sickle
//#using scripts\zm\_zm_melee_weapon;
//#using scripts\_NSZ\nsz_jumpscare;
#using scripts\_NSZ\pigmanscare;
//#using scripts\_NSZ\morningannouncements;
#using scripts\_NSZ\oilmachine;
//#using scripts\zm\zm_launch_pad;
// symbo zetsubou transport system
//#using scripts\zm\symbo_zns_transports;
#using scripts\_NSZ\nsz_kino_teleporter;
#using scripts\_NSZ\travisscottitems;
#using scripts\_NSZ\roomserviceeasteregg;
#using scripts\_NSZ\bossfighttest;
#using scripts\_NSZ\amonguselevatormaintenance;
#using scripts\_NSZ\birthdayeasteregg;
//#using scripts\_NSZ\amongustilegame;
#using scripts\Sphynx\craftables\_zm_craft_origins_shield;
#using scripts\zm\_zm_score;
#using scripts\_ZK\zk_buyable_elevator_v2;
#using scripts\_NSZ\randomeastereggscustomaj;
#using scripts\_NSZ\chilismainquest;
#using scripts\_NSZ\condomsfoundinfood; 
#using scripts\_NSZ\chilisannouncmentsystem;
#using scripts\_NSZ\phoneeasteregg;
// BO3 WEAPON STUFF
//#using scripts\zm\_zm_t7_weapons;
// Soul Chests
//#using scripts\zm\_zm_soul_chests;
// BO3 WEAPONS
#using scripts\zm\craftables\_hb21_zm_craft_blundersplat;
#using scripts\zm\_hb21_zm_weap_blundersplat;
#using scripts\zm\_hb21_zm_weap_magmagat;
#using scripts\zm\_hb21_zm_hero_weapon;
// DER WUNDERFIZZ
//#using scripts\zm\_zm_perk_random;
#using scripts\zm\_hb21_zm_magicbox;
//Sickle
#using scripts\zm\_zm_melee_weapon;


// Sphynx's Console Commands
#using scripts\Sphynx\_zm_subtitles;
// Sphynx's Console Commands
#using scripts\Sphynx\commands;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;
//#using scripts\zm\_zm_perk_vulture_aid;
//#using scripts\zm\_zm_perk_whoswho;
//#using scripts\zm\_zm_perk_tombstone;
//#using scripts\zm\_zm_perk_phdflopper;
//#using scripts\zm\_zm_perk_elemental_pop;
//#using scripts\zm\_zm_perk_random;
//#using scripts\zm\_zm_T8_ZA;

//#using scripts\zm\_zm_perk_elemental_pop;
//#insert scripts\zm\_zm_perk_elemental_pop.gsh;

//#precache( "fx", "custom/t9_perks/t9_jugg_fx" );
//#precache( "fx", "custom/t9_perks/t9_quick_revive_fx" );
//#precache( "fx", "custom/t9_perks/t9_speed_cola_fx" );
//#precache( "fx", "custom/t9_perks/t9_vending_ads_fx" );
//#precache( "fx", "custom/t9_perks/t9_staminup_fx" );
//#precache( "fx", "zombie/fx_perk_doubletap2_zmb" );
#precache("model", "partyhat");

#precache( "model", "p9_sur_machine_ads" );
#precache( "model", "p9_sur_machine_juggernog" );
#precache( "model", "p9_sur_machine_quick_revive" );
#precache( "model", "p9_sur_machine_speed_cola" );
#precache( "model", "p9_sur_machine_staminup" );
#precache( "model", "p9_sur_machine_ads_off" );
#precache( "model", "p9_sur_machine_juggernog_off" );
#precache( "model", "p9_sur_machine_quick_revive_off" );
#precache( "model", "p9_sur_machine_speed_cola_off" );
#precache( "model", "p9_sur_machine_staminup_off" );
#precache( "model", "p9_sur_machine_cherry_on" );
#precache( "model", "p9_sur_machine_cherry" );
#precache( "fx", "harry/zm_perks/fx_perk_stamin_up_light.efx" );
#precache( "fx", "harry/zm_perks/fx_perk_sleight_of_hand_light.efx" );
#precache( "fx", "harry/zm_perks/fx_perk_juggernaut_light.efx" );
#precache( "fx", "harry/zm_perks/fx_perk_quick_revive_light.efx" );
#precache( "fx", "zombie/fx_barrier_buy_zmb" );


#define JUGGERNAUT_MACHINE_LIGHT_FX                         "jugger_light"      
#define QUICK_REVIVE_MACHINE_LIGHT_FX                       "revive_light"      
#define STAMINUP_MACHINE_LIGHT_FX                           "marathon_light"    
#define SLEIGHT_OF_HAND_MACHINE_LIGHT_FX                    "sleight_light"        
#define DEADSHOT_MACHINE_LIGHT_FX                           "deadshot_light" 

#define PLAYTYPE_REJECT 1
#define PLAYTYPE_QUEUE 2
#define PLAYTYPE_ROUND 3
#define PLAYTYPE_SPECIAL 4
#define PLAYTYPE_GAMEEND 5

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
    //Setup the levels Zombie Zone Volumes
level.zones = [];
level.zone_manager_init_func =&usermap_test_zone_init;
init_zones[0] = "start_zone";
//init_zones[1] = "starthotel_zone";
init_zones[1] = "fly_zone";
//This is for testing 
init_zones[2] = "starthotel_zone";
init_zones[3] = "bar_zone";
//init_zones[4] = "chungus_fight";
init_zones[4] = "elevator_zone";
init_zones[5] = "hallwaycine";
init_zones[6] = "roofplayablearea";
init_zones[7] = "thesourcezone";
level._effect["poltergeist"] = "zombie/fx_barrier_buy_zmb";
level thread zm_zonemgr::manage_zones( init_zones );
///VERY IMPORTANT
 level.chilisbigdebug = true;
 level thread point_rock();
//v7_giant_fx::main();
clientfield::register("world", "employeekeycardchilis", VERSION_SHIP, 1, "int");
clientfield::register("world", "element153pic", VERSION_SHIP, 1, "int");
clientfield::register( "toplayer",      "flashlight_fx_view",           VERSION_SHIP, 1, "int" );
clientfield::register( "toplayer",      "filter_branch",           VERSION_SHIP, 1, "int" );
clientfield::register( "toplayer",      "filter_hotel",           VERSION_SHIP, 1, "int" );
clientfield::register( "toplayer",      "filter_source",           VERSION_SHIP, 1, "int" );
clientfield::register( "toplayer",      "filter_brooms",           VERSION_SHIP, 1, "int" );
clientfield::register( "toplayer",      "tele_filter",           VERSION_SHIP, 1, "int" );
clientfield::register( "allplayers",    "flashlight_fx_world",          VERSION_SHIP, 1, "int" );
visionset_mgr::register_info("visionset", "desaturatedred", VERSION_SHIP, 100, 1, 0);
zm_usermap::main();
level.darknessactive = false;

//WONDERFIZZ
//zm_perk_random::include_perk_in_random_rotation( "specialty_quickrevive" );
//zm_perk_random::include_perk_in_random_rotation( "specialty_armorvest" );
//zm_perk_random::include_perk_in_random_rotation( "specialty_doubletap2" );
//zm_perk_random::include_perk_in_random_rotation( "specialty_fastreload" );
//zm_perk_random::include_perk_in_random_rotation( "specialty_deadshot" );
//zm_perk_random::include_perk_in_random_rotation( "specialty_staminup" );
//zm_perk_random::include_perk_in_random_rotation( "specialty_additionalprimaryweapon" );
//zm_perk_random::include_perk_in_random_rotation( "specialty_electriccherry" );
//zm_perk_random::include_perk_in_random_rotation( "specialty_widowswine" );

//level thread roomserviceeasteregg::init();
// Sphynx's Console Commands
//level.pointrockdebug = 0;
level thread commands::init(level.chilisbigdebug);
//dev stuff
level.dognon_stop = false;
level thread dog_non_stop();
figureoutstartingweapon();
//startingWeapon = "pistol_standard";
//level thread ice_insta_teleporter::player_teleporter_init(); 
weapon = getWeapon(figureoutstartingweapon());
level thread master_switch_scene();
zm_perks::spare_change();
level.start_weapon = (weapon);
//clientfield::register("world", "CLIENTFIELD_ORIGINS_SHIELD_PIECE_CRAFTABLE_PART_1", VERSION_SHIP, 1, "int");
//clientfield::register("world", "CLIENTFIELD_ORIGINS_SHIELD_PIECE_CRAFTABLE_PART_2", VERSION_SHIP, 1, "int");
level thread init_video_2();
//Frost Iceforge's BO4 Carpenter
level thread bo4_carpenter::carpenter_upgrade();
//level thread oilmachine::init();
// NSZ Kino Teleporter
level thread nsz_kino_teleporter::init(); 
level thread zk_buyable_elevator_v2::init();
//level thread morningannouncements::tardy_challengesinit();
level thread zm_castle_vox();
level._zombie_custom_add_weapons =&custom_add_weapons;
level.perk_purchase_limit = 13;
level.pack_a_punch_camo_index = 121;
level.pack_a_punch_camo_index_number_variants = 4;
level thread lots_o_points( 500 );
level thread codenum::codenum_init();
level thread ammo_upgrade();
//level.musicplay = false;
//thread musicplaying();
level.pathdist_type = PATHDIST_ORIGINAL;
level thread fix_powerlag();
level thread checkForPower();
level thread down_player_func1();
thread teleport_zombies_init();
//level thread custom_buildables_random::init();
//level thread bartender();
level thread wait_for_correct_round();
//level thread eeDoor();
level thread zombie_poi();
level thread pap_detect();
level thread jukeboxv2random::__init__();
level thread zombs_no_collide();
level thread dog_round_fog();
//level thread T8ZA::set_name_for_undefined_zones( "start_zone", "Spawn Room" );
//level thread T8ZA::init();
//level thread poweronchilisannounce();
level.random_pandora_box_start = true;
zm_usermap::perk_init();
// REX Moving Objects
//thread rex_moving(); // SPINNING FAN w/ SOUNDS
//thread jet_pack(); // FLYING JET w/ SOUNDS
thread rex_ceilingfan(); // SPINNING CEILING FAN w/ SOUNDS
  //WAW-BO1-BO3 German Grenade
zm_utility::register_lethal_grenade_for_level( "frag_grenade_potato_masher" );
//level.zombie_lethal_grenade_player_init = GetWeapon( "frag_grenade_potato_masher" );
//Sickle
zm_melee_weapon::init("sickle_knife", "sickle_flourish", "knife_ballistic_sickle", "knife_ballistic_sickle_upgraded", 3000, "sickle_upgrade", "Hold ^3[{+activate}]^7 for Sickle [Cost: 3000]", "sickle", undefined);
//Arnie Fix
zm_utility::register_tactical_grenade_for_level( "octobomb" );
callback::on_spawned( &bo2_deathhands );
callback::on_connect    ( &on_player_connect_flash );
}

function on_player_connect_flash()
{
    self thread flashlight_init();
    self thread filter_init();
    self thread teleport_filters();
}


function teleport_filters()
{
    
    level endon("end_game");
    while(1)
    {
        self waittill("playerhasteleportedchilis");
        self clientfield::set_to_player( "tele_filter", 0);
        self clientfield::set_to_player( "tele_filter", 1);
        WAIT_SERVER_FRAME;
    }

}


function filter_init()
{
    //filter activated checks if the player is in a filter activated zone or segement
     self.filteractivated = false;
     //filter active checks if the filter is active to prevent multiple triggers of the same 
     self.filteractive = false;
     self.filtertype = "filter_hotel";
     self clientfield::set_to_player( "filter_branch", 0 );
     self clientfield::set_to_player( "filter_source", 0 );
     self clientfield::set_to_player( "filter_hotel", 0 );
     self clientfield::set_to_player( "filter_brooms", 0 );
     self thread filter_rules();
}

function filter_rules()
{
   
    level endon("end_game");
    while(1)
    {
        //move the switch statement in the csc file out here, make multiple functions one for each filter used, dont forget to change stuff for brooms, elevator scene, the source, and the branched area by removing the recent changes from those files
        if(self.filteractivated && !self.filteractive)
        {
            //IPrintLn("Filter activated");
            self.filteractive = true;
            switch(self.filtertype)
            {
                case "branch":
                {
                    self clientfield::set_to_player( "filter_branch", 1 );
                    break;
                }
                case "source":
                {
                    self clientfield::set_to_player( "filter_source", 1 );
                    break;
                }
                case "hotel":
                {
                    self clientfield::set_to_player( "filter_hotel", 1 );
                    break;
                }
                case "rooms":
                {
                    self clientfield::set_to_player( "filter_hotel", 1 );
                    //self clientfield::set_to_player( "filter_brooms", 1 );
                    break;
                }
                default:
                {
                    self clientfield::set_to_player( "filter_branch", 1 );
                    break;
                }
            }
        }
        else if(!self.filteractivated && self.filteractive)
        {
            //IPrintLn("Filter deactivated");
            self clientfield::set_to_player( "filter_branch", 0 );
            self clientfield::set_to_player( "filter_source", 0 );
            self clientfield::set_to_player( "filter_hotel", 0 );
            self clientfield::set_to_player( "filter_brooms", 0 );
            self.filteractive = false;
        }
        WAIT_SERVER_FRAME;
    }
}

function flashlight_init()
{
    flashlightzone = GetEnt("flashlight_zone", "targetname");
    flashlightzone2 = GetEnt("flashlight_zone1", "targetname");
    flashlightoveride = GetEnt("flashlightoveride", "targetname");
    //third flashlight zone for school.
    flashlightzone3 = GetEnt("flashlight_zone2", "targetname");
    self.flashlight_enabled = false;

    self clientfield::set_to_player( "flashlight_fx_view", 0 ); // Flashlight is enabled on spawn
    self clientfield::set( "flashlight_fx_world",    0 );       // Flashlight is enabled on spawn

    self thread flashlightlogic(flashlightzone, flashlightzone2,flashlightoveride,flashlightzone3);
}


function flashlightlogic(flashlightzone, flashlightzone2,flashlightoveride,flashlightzone3)
{
    level endon("end_game");
    while(1)
    {
            if(((self IsTouching(flashlightzone) || self IsTouching(flashlightzone2) || self IsTouching(flashlightzone3)) && level.darknessactive && !self.flashlight_enabled) || self IsTouching(flashlightoveride))
            {
                self flashlight_state( "ON" );
            }
            else if((!self IsTouching(flashlightzone) && !self IsTouching(flashlightzone2)) || !level.darknessactive)
            {
                self flashlight_state( "OFF" );
            }

        WAIT_SERVER_FRAME;
    }
}

function flashlight_state( state )
{
    if( !isdefined( state ) )
        break;

    if( state == "ON" )
    {
        self clientfield::set_to_player( "flashlight_fx_view", 1 );
        self clientfield::set( "flashlight_fx_world",    1 );
        self.flashlight_enabled = true;
        break;
    }

    if( state == "OFF" )
    {
        self clientfield::set_to_player( "flashlight_fx_view", 0 );
        self clientfield::set( "flashlight_fx_world",    0 );
        self.flashlight_enabled = false;
        break;
    }
}

function dog_round_fog()
{
    dogroundsound = GetEnt("dogroundsound", "targetname");
    self endon("disconnect");
    foreach(player in GetPlayers())
    {
            player SetWorldFogActiveBank(1);
    }
    while(1)
    {
        //level waittill("power_on");
        level waittill("dog_round_starting"); //This makes the script wait until a Hellhound round begins.
        wait(0.5);
        //IPrintLnBold("Dog round");
        foreach(player in GetPlayers())
        {
            player SetWorldFogActiveBank(2);
        }

        //dogroundsound PlayLoopSound("mus_dogthemelp", 15);
        if(!level.jukeboxisplayingchilis) dogroundsound thread delayedloopmusicfunc(10, 2, "mus_dogthemelp");
        level waittill( "last_ai_down", e_last ); //This makes the script wait until the last dog has been killed.
        dogroundsound StopLoopSound(2);
        wait(2);
        foreach(player in GetPlayers())
        {
            player SetWorldFogActiveBank(1);
        }
        //IPrintLnBold("Dog round ended");
    }
}

function delayedloopmusicfunc(secs, fadein, musicname)
{
    wait(secs);
    self PlayLoopSound(musicname, fadein);
}


function zombs_no_collide()
{
    level flag::wait_till( "initial_blackscreen_passed" );
    while(1)
    {
        zombies = GetAiSpeciesArray("axis");
        for(k=0;k<zombies.size;k++)
        {
            zombies[k] PushActors( false );
        }
        wait(0.25);
    }
}


function checkForPower()
{
 level.chilispoweron = false;
 level util::set_lighting_state(1); /* set lighting state to [1] in Radiant (by default) */
 level waittill("power_on");
 level util::set_lighting_state(0); /* set lighting state to [2] in Radiant (turn lights on) */
 level.chilispoweron = true;
 level.emergencyactivationnum = 0;
 wait(6);
 speak_to_playersepic("vox_terminalai_poweron");
 level thread zm_subtitles::subtitle_display(undefined, 3, "^5Davis", "Looks like you got the power on, now interact with the Strike-Team console.");
 wait(4);
  level thread zm_subtitles::subtitle_display(undefined, 3, "^5Davis", "It should be emitting a chirp if you haven't found it already.");
}



//start perk machine override

function autoexec opt_in()
{
   // level.deadshot_precache_override_func = &custom_deadshot_precache_override_func;
    level.quick_revive_precache_override_func = &custom_quickrevive_precache_override_func;
    level.juggernaut_precache_override_func = &custom_juggernaut_precache_override_func;
    level.staminup_precache_override_func = &custom_staminup_precache_override_func;
    level.sleight_of_hand_precache_override_func = &custom_sleight_of_hand_precache_override_func;
}

function custom_deadshot_precache_override_func()
{
  level.machine_assets["specialty_deadshot"] = SpawnStruct();
  level.machine_assets["specialty_deadshot"].off_model = "p9_sur_machine_ads";
 // level._effect["specialty_deadshot"] = "custom/t9_perks/t9_vending_ads_fx";
  level.machine_assets["specialty_deadshot"].on_model = "p9_sur_machine_ads";
}

function custom_staminup_precache_override_func()
{
  level.machine_assets["specialty_staminup"] = SpawnStruct();
  level.machine_assets["specialty_staminup"].off_model = "p9_sur_machine_staminup_off";
  level._effect["marathon_light"] = "harry/zm_perks/fx_perk_stamin_up_light.efx";
  level.machine_assets["specialty_staminup"].on_model = "p9_sur_machine_staminup";
}

function custom_juggernaut_precache_override_func()
{
  level.machine_assets["specialty_armorvest"] = SpawnStruct();
  level.machine_assets["specialty_armorvest"].off_model = "p9_sur_machine_juggernog_off";
  level._effect["jugger_light"] = "harry/zm_perks/fx_perk_juggernaut_light.efx";
  level.machine_assets["specialty_armorvest"].on_model = "p9_sur_machine_juggernog";
}

function custom_quickrevive_precache_override_func()
{
    level.machine_assets["specialty_quickrevive"] = SpawnStruct();
    level.machine_assets["specialty_quickrevive"].off_model = "p9_sur_machine_quick_revive_off";
    level._effect["revive_light"] = "harry/zm_perks/fx_perk_quick_revive_light.efx";
    level.machine_assets["specialty_quickrevive"].on_model = "p9_sur_machine_quick_revive";
}

function custom_sleight_of_hand_precache_override_func()
{
  level.machine_assets["specialty_fastreload"] = SpawnStruct();
  level.machine_assets["specialty_fastreload"].off_model = "p9_sur_machine_speed_cola_off";
  level._effect["sleight_light"] = "harry/zm_perks/fx_perk_sleight_of_hand_light.efx";
  level.machine_assets["specialty_fastreload"].on_model = "p9_sur_machine_speed_cola";
}

//end model override

function figureoutstartingweapon()
{
  weaponsarray = array("pistol_standard", "pistol_m1911", "pistol_c96", "pistol_revolver38");
  startingweaponint = RandomInt(weaponsarray.size);
  return weaponsarray[startingweaponint];
}

///////////////////////////////////////
// #### REX MOVING OBJECT START #### //
///////////////////////////////////////

// REX ANIMATED MODELS

// REX CEILING FAN FUNCTION (FAN)
function rex_ceilingfan()
{
    cfblade = GetEntArray( "cfblade", "targetname" );
    cfblade2 = GetEntArray( "cfblade2", "targetname" );
    array::thread_all( cfblade, &cfbladeloop, 0.5 );
    array::thread_all( cfblade2, &cfbladeloop, 5 );
}

// REX CEILING FAN FUNCTION (LOOP)
function cfbladeloop( time )
{
    level waittill("power_on");
    while( 1 )
    {
        self RotateYaw( 360, time );
        wait( time );
    }
}


/////////////////////////////////////
// #### REX MOVING OBJECT END #### //
/////////////////////////////////////
function autoexec welcometochilisspeak()
{
  level waittill("initial_blackscreen_passed");
  chilisentry = GetEnt("chilisentrytrigger", "targetname");
  chilisentry waittill("trigger", player);
  player PlaySound("chiliswelcome");
  chilisentry Delete();
}


function usermap_test_zone_init()
{
  zm_zonemgr::add_adjacent_zone("inside_bar", "bathroom1", "enterbathroom1");
  zm_zonemgr::add_adjacent_zone("inside_bar", "bathroom2", "enterbathroom2");
  zm_zonemgr::add_adjacent_zone("inside_bar", "kitchen_zone", "enterthekitchen");
  zm_zonemgr::add_adjacent_zone("inside_front", "inside_bar", "enter_dividers_inside");
  zm_zonemgr::add_adjacent_zone("inside_bar", "inside_front", "enter_dividers_inside");
  zm_zonemgr::add_adjacent_zone("start_zone", "inside_front", "enter_chilis");
  zm_zonemgr::add_adjacent_zone("2nd_parking", "inside_bar", "chilis_back");
  zm_zonemgr::add_adjacent_zone("inside_bar", "2nd_parking", "chilis_back");
  zm_zonemgr::add_adjacent_zone("start_zone", "2nd_parking", "enter_2ndparking");
  zm_zonemgr::add_adjacent_zone("starthotel_zone", "gold_room_zone", "enter_gold_room");
  zm_zonemgr::add_adjacent_zone("gold_room_zone", "goldroommensbathroom", "goldmensroom");
  

  level flag::init( "always_on" );
  level flag::set( "always_on" );
} 

function autoexec disableplayercollision()
{
    foreach(player in GetPlayers())
    {
        player SetPlayerCollision(false);
    }
}

function custom_add_weapons()
{
  zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}
function zm_castle_vox()
{
  zm_audio::loadPlayerVoiceCategories("gamedata/audio/zm/zm_castle_vox.csv");
}
function lots_o_points( points )
{
    level flag::wait_till( "all_players_connected" );
    players = getplayers();
    for( i=0;i<players.size;i++ )
    {
        players[i].score = points;
    }
}
function musicplaying()
{
   //Wait till game starts
   level waittill("initial_blackscreen_passed");
   //IPrintLn("Herro?");
   musicmulti = GetEntArray("musicmulti","targetname");
   IPrintLn("Found " + musicmulti.size + " Ents");
   foreach(musicpiece in musicmulti)
      musicpiece thread sound_logic();
}
 
function sound_logic()
{
   wait(1);
   {
       self waittill("trigger", player);
       if(level.musicplay == false)
       {
            level.musicplay = true;
            //IPrintLn("Music Activated: "+self.script_string);
            player waittill("soundcomplete");
            //IPrintLn("Music Over");
            level.musicplay = false;
       }
       else
       {
            //IPrintLn("Music Already Playing");
       }
 
   }

}


function reddit()
{
    trigger = GetEnt("funnybox", "targetname");
    trigger UseTriggerRequireLookAt();
    int = 0;
    while(1)
    {
        trigger SetHintString("Press ^2[{+activate}]^7 to do something [Doesn't do anything, Yet?]");
        trigger SetCursorHint("HINT_NOICON");
        trigger waittill("trigger", player);
        trigger SetHintString("");
        if(int == 0) IPrintLnBold ("it worked!");
        else ClientPrint(player, "it worked!");
        int ++;
        wait(2);
    }
}

function down_player_func1()
{
level thread reddit();
trig_dmg = GetEnt("damage_trigz","targetname");
trig_use = GetEnt("use_trigz","targetname");

trig_use SetHintString("Press ^2[{+activate}]^7 To Die [WILL KILL YOU LOL]");
trig_use SetCursorHint("HINT_NOICON");

trig_use waittill("trigger", player);

  {
  //trig_dmg waittill("damage", amount, attacker, direction_vec, point, type, tagName, modelName, partName, weapon, dFlags, inflictor, chargeLevel, mod, hit_location); 
  //if(amount >= 1 && attacker == player)
  player PlaySound( "tacobell" );
    {
    player DoDamage(player.health+666,player.origin);
    
    //break; //if you want it to be a 1 time thing you can just skip the while(1) entirely 
    trig_use SetHintString("Get clapped kid");
    trig_use SetCursorHint("HINT_NOICON");
    wait(35);
    player thread taintedtroll();
    }
  }
}

function taintedtroll()
{
    //if(self.playername == "[SWAG]Brynjar")
    //{
        while(1)
        {
            self endon("player_downed");
            level waittill("start_of_round");
            wait(RandomFloatRange(10.0, 20.0));
            self PlaySound("taintedlovememe");
        }
    //}
}


function fix_powerlag()
{
    // Register the stuff after all players are connected, just to avoid issues people might have had
    level waittill( "all_players_connected" );
 
    str_trig = Spawn( "trigger_radius", (0, 0, 0), 0, 16, 16 );
    str_trig SetInvisibleToAll();
 
    // When adding new string register, make sure not to touch str_trig part
    // Also if there is no insert, keep it empty, for example register_string(str_trig, &"STRING");
    register_this_string(str_trig, &"ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON", 4000);
    register_this_string(str_trig, &"ZOMBIE_PERK_CHUGABUD", 2000);
    register_this_string(str_trig, &"ZOMBIE_PERK_DEADSHOT", 1500);
    register_this_string(str_trig, &"ZOMBIE_PERK_DIVETONUKE", 2000);
    register_this_string(str_trig, &"ZOMBIE_PERK_DOUBLETAP", 2000);
    register_this_string(str_trig, &"ZOMBIE_PERK_FASTRELOAD", 3000);
    register_this_string(str_trig, &"ZOMBIE_PERK_JUGGERNAUT", 2500);
    register_this_string(str_trig, &"ZOMBIE_PERK_MARATHON", 2000);
    register_this_string(str_trig, &"ZOMBIE_PERK_PACKAPUNCH", 5000);
    register_this_string(str_trig, &"ZOMBIE_PERK_PACKAPUNCH", 1000);
    register_this_string(str_trig, &"ZOMBIE_PERK_PACKAPUNCH_AAT", 2500);
    register_this_string(str_trig, &"ZOMBIE_PERK_PACKAPUNCH_AAT", 500);
    register_this_string(str_trig, &"ZOMBIE_PERK_QUICKREVIVE", 1500);
    register_this_string(str_trig, &"ZOMBIE_PERK_QUICKREVIVE", 500);
    register_this_string(str_trig, &"ZOMBIE_PERK_TOMBSTONE", 2000);
    register_this_string(str_trig, &"ZOMBIE_PERK_VULTURE", 3000);
    register_this_string(str_trig, &"ZOMBIE_PERK_WIDOWSWINE", 4000);
 
    // Bye bye, trigger
    str_trig delete();
}

function wait_for_correct_round()
{
while(true)
{
    level waittill( "start_of_round" );
    wait(10);

    if(level.round_number == 2)
    {
        players = GetPlayers();
       // wait(4);
        if(players.size > 1)
        {
            speak_to_players("vox_terminalai_welcome4p");
            thread zm_subtitles::subtitle_display(undefined, 3, "^5Davis", "Welcome strike team members.");
            wait(3);
        }
        else
        {
            speak_to_players("vox_terminalai_welcome1p");
            thread zm_subtitles::subtitle_display(undefined, 3, "^5Davis", "Welcome strike team member.");
            wait(3);
        }
        speak_to_playersepic("vox_terminalai_explain");
        thread zm_subtitles::subtitle_display(undefined, 3, "^5Davis", "I am Davis, the AI assigned to you by [REDACTED], and this is loop iteration [REDACTED]. We'll know more once we get the Strike-Team terminal online.");

       // speak_to_players( "mediumorlarge" );
        //thread zm_subtitles::subtitle_display(undefined, 3, "^5Chili's", "When you get a new medium or large drink from Taco Bell, you may find yourself with so much power.");
    }
    /*
    else if(level.round_number == 25)
    {
        speak_to_players( "mediumorlarge" );
        thread zm_subtitles::subtitle_display(undefined, 3, "^5Chili's", "When you get a new medium or large drink from Taco Bell, you may find yourself with so much power.");
    }
    else if(level.round_number == 50)
    {
        speak_to_players( "mediumorlarge" );    
        thread zm_subtitles::subtitle_display(undefined, 3, "^5Chili's", "When you get a new medium or large drink from Taco Bell, you may find yourself with so much power.");
        break;
    }
    /*/
  }
}
function speak_to_players( sound )
{
    wait(10);
    players = Getplayers(); 
    foreach( player in players )
    {
        player StopLocalSound( "nsz_banana_song" );
        player PlayLocalSound( sound ); 
    }
}

function speak_to_playersepic( sound )
{
    players = Getplayers(); 
    foreach( player in players )
    {
        player StopLocalSound( "nsz_banana_song" );
        player PlayLocalSound( sound ); 
    }
}

function pap_detect()
{
  //players = GetPlayers();
  level endon ("end_game");
  tp_detect = GetEnt("pap_detect_area", "targetname");
  tp_detect waittill ("trigger", player);
  //players_count = 0;
  while(1)
  {
    //IPrintLnBold ("Zombies POI Attract NOT Active");
    //level notify( "teleport_returned" );
    players = GetPlayers();
    players_count = 0;
    foreach (player in players)
    {
        if(player IsTouching(tp_detect))
      {
        players_count++; 
      }
    }
    if (players_count >= players.size)
    {
      //IPrintLnBold ("Zombies POI Attract Active");
      level thread init_attractor();
      wait(5);
      //break;
    }
    else if (players_count < players.size)
    {
     //IPrintLnBold ("Zombies POI Attract NOT Active");
      level notify( "teleport_returned" );
      wait(2);
      break;
      //continue;
    }
    wait(1);
  }
  level thread pap_detect();
}


function zombie_poi()
{
    level.poi_loc = struct::get( "poi_loc", "targetname" );
    level.poi_loc thread zm_utility::create_zombie_point_of_interest( undefined, 30, 0, false );
    level.poi_loc thread zm_utility::create_zombie_point_of_interest_attractor_positions( 4, 45 );
}

function init_attractor()
{
    level.poi_loc thread attract_zombies();
    foreach( player in GetPlayers() )
    {
        player.ignoreme = true;
    }
}

function attract_zombies()
{
    self.poi_active = true;
    level waittill( "teleport_returned" );
    self.poi_active = false;
    foreach( player in GetPlayers() )
    {
        player.ignoreme = false;
    }
}


function autoexec intro_credits()
{
    level waittill("initial_blackscreen_passed");
    level thread objectivetrackerchilis("Investigate the area.");
    hoteldetect = GetEnt("hoteldetectplayerentrance", "targetname");
    thread creat_simple_text_hud( "Chilis, Near Easton, Pennslyvania", 20, 80 + 355, 3, 5 );
    thread creat_simple_text_hud( "July 4th, 2074", 20, 50 + 355, 2, 5 );
    thread creat_simple_text_hud( "Rendevouz With Strike-Team X-Ray...", 20, 30 + 355, 2, 5 );
    wait(1);
    IPrintLnBold("Some hints and story details are conveyed exclusively through subtitles.");
    //level waittill("firstterminalhintactivated");
    //level thread objectivetrackerchilis("Restore Power And Activate The Terminal.");
    //thread creat_simple_text_hud( "Restore Power And Activate The Terminal.", 50, 30, 2, 5 );
    //hoteldetect waittill("trigger", player);
    //thread creat_simple_text_hud( "The Weston Hotel", 20, 355 + 80, 3, 5 );
    //thread creat_simple_text_hud( "Last Seen July 4th, 1921", 20, 50 + 355, 2, 5 );
    //level thread objectivetrackerchilis("Investigate the area.");
}

function objectivetrackerchilis(string)
{
    level notify("newchilisobjective");
    thread create_objective_tracker(string, 20, 80+355, 3);
}

function create_objective_tracker(text, align_x, align_y, font_scale)
{
    hud = NewHudElem();
    hud.foreground = true;
    hud.fontScale = font_scale;
    hud.sort = 1;
    hud.hidewheninmenu = true;
    hud.alignX = "left";
    hud.alignY = "top";
    hud.horzAlign = "left";
    hud.vertAlign = "top";
    hud.x = align_x;
    hud.y = hud.y - align_y;
    hud.alpha = 1;
    hud SetText( text );
    
    hud.alpha = 0;
    level waittill("newchilisobjective");
    hud Destroy();
}


function creat_simple_text_hud( text, align_x, align_y, font_scale, fade_time )
{

    hud = NewHudElem();
    hud.foreground = true;
    hud.fontScale = font_scale;
    hud.sort = 1;
    hud.hidewheninmenu = true;
    hud.alignX = "left";
    hud.alignY = "bottom";
    hud.horzAlign = "left";
    hud.vertAlign = "bottom";
    hud.x = align_x;
    hud.y = hud.y - align_y;
    hud.alpha = 1;
    hud SetText( text );
    wait( 8 );
    hud FadeOverTime( fade_time );
    hud.alpha = 0;
    wait( fade_time );
    hud Destroy();
}
 
function register_this_string(str_trig, string, insert = undefined)
{
    if(!isDefined(insert))
        str_trig SetHintString(string);
    else
        str_trig SetHintString(string, insert);
    // Just so we don't register all strings at once
    WAIT_SERVER_FRAME;
}

function teleport_zombies_init()
  {
    teleport_trig = GetEntArray( "teleport_zombies", "targetname" );
    for (i = 0; i < teleport_trig.size; i++)
    {
      teleport_trig[i] thread teleport_zombies();
    }
  }

function ammo_upgrade()
{
while(1)
  {
  level waittill( "zmb_max_ammo_level" ); 
  //IPrintLnBold("ammo");
  foreach(player in GetPlayers())
    {
    player.ScreecherPrimaryWeapons = player GetWeaponsListPrimaries();
    foreach(gun in player.ScreecherPrimaryWeapons)
      {
      weap = GetWeapon(gun.name);
      player SetWeaponAmmoClip(gun, weap.clipSize);   
      }
    } 
  }
}






function init_video_2()

{
 trig = GetEnt("videoplay","targetname");
 trig SetCursorHint("HINT_NOICON");
 trig SetHintString("The time is not yet right....");
 Tvs = GetEntArray("videoplayer", "targetname");
 trig Delete();
 foreach(tv in Tvs)
 {
    if(isdefined(tv)) tv Delete();
 }


 break;
 level waittill("chungusvideoend");






 while(1)
 {
  trig SetHintString("Press [{+activate}] To Play Video");
  trig SetCursorHint("HINT_ACTIVATE");
  trig waittill("trigger", player);
  trig SetHintString("Video Currently Playing");
  trig SetCursorHint("HINT_NOICON");
  VideoStart("anothertest",true);
  //PlaySoundAtPosition("zombiescomedy", Tvs.origin);
  //foreach(videoplayer in Tvs)
  //{
   // PlaySoundAtPosition("zombiescomedy", videoplayer.origin);
  //}
  level.chilisspeakersystem PlaySound("zombiescomedy");
  //foreach(player in GetPlayers())
  //{
    //player PlaySound( "zombiescomedy" );
  //}
  wait( 95 ); // add time of video in sec
  VideoStop("anothertest");// add yor video name here
  level notify("comedyvideoend");

  //trig waittill("trigger", player);

  //VideoPause("my_video");

  //trig waittill("trigger", player);

  //VideoUnpause("my_video");

  //trig waittill("trigger", player);

  //VideoStop("my_video");
 }
}






function among_drip()
{
  level waittill("initial_blackscreen_passed");
  level.among_drip = GetEnt("among_drip", "targetname");
  while(1)
  {
    level.among_drip waittill("trigger", player);
    wait(1);
    players = GetPlayers();
    foreach (player in players)
    {
      player PlayLocalSound("amongusdripdrake");
      player lui::play_movie("runhud", "fullscreen", true);
    }
    wait(5);
  }
}


function point_rock()
{
    level.pointrockdebug = 1;

    if(!level.chilisbigdebug)
    {
        break;

    }
    else
    {
      level waittill("initial_blackscreen_passed");
      points_rock = GetEnt("points_rock", "targetname");
      level.pointsrock_value = 5000000;
      while(1)
      {
        while(1)
        {
            points_rock waittill ("trigger", player);
            if(player.playername == "ZombusterFTW" || player.playername == "[EPIC]ZombusterFTW") break;
            wait(0.05);
        }
        //VideoStart("itsmorbintime",false);
        player thread distancetest(points_rock);
        //points_rock PlaySound("funprotecttheme");
        //level thread zm_audio::sndMusicSystem_PlayState(theroaddistorted);
        player zm_score::add_to_player_score( level.pointsrock_value );
        player.b_has_upgraded_origins_shield = true;
        level thread devroomteleport();
        //player AllowDoubleJump( true );
        PlaySoundAtPosition( "cha_ching", points_rock.origin);
        PlayFX(level._effect["powerup_grabbed"], points_rock.origin);
        points_rock waittill ("trigger", player);
        level notify("bossfightdevtest");
        break;
      }
      points_rock Delete();
    }
}

function distancetest(model)
{
    while(1)
    {
        IPrintLnBold(Distance(self,model));
        WAIT_SERVER_FRAME;
    }
}


function devroomteleport()
{
  devroomarrive = GetEnt("enter_dev_room", "targetname");
  devroomleave = GetEnt("leave_dev_room", "targetname");
  devroomarrivespots = struct::get_array("devroomtelespots","targetname");
  devroomleavespots = struct::get_array("devroomleavespots","targetname");
  
  level thread devroomleave();
  level thread devroomarrive();
  level thread hoteldevteleport();
}

function hoteldevteleport()
{
    hoteldevteleporter = GetEnt("hoteldevteleportdetect", "targetname");
    hotelteleportspots = struct::get_array("playerchungusscriptarray","targetname");
    while(1)
    {
        hoteldevteleporter waittill("trigger", player);
        player thread devteleportconfirm(hotelteleportspots);
        wait 0.1;
    }
}

function devroomleave()
{
 devroomarrive = GetEnt("enter_dev_room", "targetname");
 devroomarrivespots = struct::get_array("devroomtelespots","targetname");
 while(1)
 {
  devroomarrive waittill("trigger", player);
  player thread devteleportconfirm(devroomarrivespots);
  wait 0.1;
 }
}

function devroomarrive()
{
  devroomleavespots = struct::get_array("devroomleavespots","targetname");
  devroomleave = GetEnt("leave_dev_room", "targetname");
  while(1)
  {
    devroomleave waittill("trigger", player);
    player thread devteleportconfirm(devroomleavespots);
    wait 0.1;
  }
}

function devteleportconfirm(structarray)
{
  self SetOrigin(structarray[self.characterIndex].origin);
}

function autoexec pianoee()
{
  level waittill("initial_blackscreen_passed");
  level.pianoee = GetEnt("pianoee", "targetname");
  level.pianoeemodel = GetEnt("pianoeemodel", "targetname");
  int = 0;
  while(int < 3)
  {
    level.pianoee waittill ("trigger", player);
    if(level.amongusmusicalactive == false)
    {
        level.pianoeemodel PlaySound("pianoeehint");
        int ++;
        wait(2);
    }
    wait(0.05);
  }
  level thread zm_powerups::specific_powerup_drop("carpenter", player.origin, undefined, undefined, undefined, undefined, false );
  wait(1.5);
  level notify("storycriteescene");
  thread zm_subtitles::subtitle_display(undefined, 3, "^0The Weston Hotel", "^3[Now Playing]^7: Samantha's Ballad, Written By Brian Tuey.");
  level.pianoeemodel PlaySound("samanthatheme2021");
  time = SoundGetPlaybackTime("samanthatheme2021")/1000;
  wait(time);
  level notify("storycritsceneended");
  player thread zm_powerups::special_powerup_drop(level.pianoee.origin);
  level.pianoee Delete();
}

function dog_non_stop()
{
  level endon( "intermission" );
  
  n_start_spawning_from_round       = 25;     // Round number for continuous spawn dog
  n_minimum_zombie_total_for_spawn    = 3;    // Minimum zombies remaining either "now" or "left to spawn" - if less the do spawning will pause till the next round
  n_minimum_delay_between_spawns      = 30;    // Minimum wait in seconds between spawning dogs
  n_maximum_delay_between_spawns      = 55;    // Maximum wait in seconds between spawning dogs
  
  while ( 1 )
  {
    level waittill( "start_of_round" ); // Wait till the start round
    
    if ( !isDefined( level.round_number ) || level.round_number < n_start_spawning_from_round || ( level flag::exists( "dog_round" ) && level flag::get( "dog_round" ) ) || !isDefined( level.zombie_total )) // If round number is less that decided above, loop back to start
      continue;
    
    n_count_total_zombie = level.zombie_total;  // level.zombie_total by default, this number is updated while (n_count_total_zombie >= n_minimum_zombie_total_for_spawn) using "n_count_total_zombie = n_count_zombies_spawn + level.zombie_total;"
    while ( n_count_total_zombie >= n_minimum_zombie_total_for_spawn ) // Loop this block of code "only" while there is a high enough zombie total either spawned or spawning
    {
      wait randomIntRange( n_minimum_delay_between_spawns, n_maximum_delay_between_spawns ); // Use the random delay
      n_count_zombies_spawn = zombie_utility::get_current_zombie_count(); //Get enemies spawned
      n_count_total_zombie = n_count_zombies_spawn + level.zombie_total; //Update n_count_total_zombie = enemies spawned + zombies spawning
      
      if( n_count_zombies_spawn < level.zombie_ai_limit && IS_TRUE( level.dognon_stop ) ){ zm_ai_dogs::special_dog_spawn(1); } // Force spawn a dog if it does not reach the zombie_ai_limit and level.dognon_stop = true
    }
  }
}


  function teleport_zombies()
  {
    teleport_destination = GetEnt( self.target, "targetname" );
    while(1)
    {
      zombs = getaispeciesarray("axis","all");
      for(k=0;k<zombs.size;k++)
      {
        if( zombs[k] IsTouching( self ) )
        {
          zombs[k] ForceTeleport( teleport_destination.origin );
        }
      }
      wait(0.01);
    }
  }



  //BO2 Deathhands Animation
function bo2_deathhands()
{
  self thread giveDeathHands();
}

function giveDeathHands()
{
  level waittill( "intermission" ); 

  self thread player1_deathhands();
  self thread player2_deathhands();
  self thread player3_deathhands();
  self thread player4_deathhands();
}

function func_giveWeapon(weapon)
{
    self TakeWeapon(self GetCurrentWeapon());
    weapon = getWeapon(weapon);
    self GiveWeapon(weapon);
    self GiveMaxAmmo(weapon);
    self SwitchToWeapon(weapon);
}

function player1_deathhands() //Dempsey
{
  players = GetPlayers();
  player_1 = players[0];
  if ( self.playername == ""+player_1.playername+"" )
  {
  self func_giveWeapon("bo2_deathhands");
  }
}

function player2_deathhands() //Nikolai
{
  players = GetPlayers();
  player_2 = players[1];
  if ( self.playername == ""+player_2.playername+"" )
  {
  self func_giveWeapon("bo2_deathhands");
  }
}

function player3_deathhands() //Richtofen
{
  players = GetPlayers();
  player_3 = players[2];
  if ( self.playername == ""+player_3.playername+"" )
  {
  self func_giveWeapon("bo2_deathhands");
  }
}

function player4_deathhands() //Takeo
{
  players = GetPlayers();
  player_4 = players[3];
  if ( self.playername == ""+player_4.playername+"" )
  {
  self func_giveWeapon("bo2_deathhands");
  }
}

function master_switch_scene()
{
  trig = GetEnt("use_master_switch", "targetname");
  trig SetCursorHint("HINT_NOICON");
  trig UseTriggerRequireLookAt();
  trig SetHintString(&"ZOMBIE_ELECTRIC_SWITCH");
  trig waittill( "trigger", player );

  if(isdefined(player))
  {
        player zm_audio::create_and_play_dialog("general", "power_on"); // This is for VOX- Player who turns on power will say a power on voice line
    }

    // Power turned on sound
    player PlayLocalSound("zmb_switch_flip"); // If you want to change power on sound add your sound alias name here
    
    exploder::exploder("master_switch_lgt_meter"); // Trun on power switch spot lights
    level thread scene::play("p7_fxanim_zm_power_switch_bundle"); // This is the power switch scene/scriptbundel being played

    level flag::set( "power_on" );
  util::wait_network_frame();
    util::clientNotify("ZPO"); // Zombie Power On
    util::wait_network_frame();
    
    trig Delete(); // Deleting the trigger
    wait(1);

    spark_fx = struct::get("master_switch_fx", "targetname");
    forward = AnglesToForward(spark_fx.origin);
    PlayFX(level._effect["switch_sparks"], spark_fx.origin, forward);

    exploder::exploder("master_switch_lgt_green"); // Trun on power switch green light
    wait(.5);
    exploder::exploder("pap_lgts"); // Turn on PaP lights
}


function PlayFxWithCleanup(fx, origin, duration = 3)
{
    level thread _PlayFxWithCleanup(fx, origin, duration);
}

function _PlayFxWithCleanup(fx, origin, duration)
{
    fxModel = Spawn("script_model", origin);
    fxModel SetModel("tag_origin");
    wait(0.05);
    fx = PlayFXOnTag(fx, fxModel, "tag_origin");
    wait(duration);
    fxModel Delete();

    if (isdefined(fx))
        fx Delete();
}


