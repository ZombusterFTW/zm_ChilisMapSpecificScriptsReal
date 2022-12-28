#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\animation_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\hud_shared;
#using scripts\shared\callbacks_shared;

#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_zm_powerup_nuke;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_behavior;
#using scripts\zm\_zm_behavior_utility;
#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_puppet;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_zonemgr;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_ai_dogs;

#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\zombie.gsh;
#insert scripts\shared\ai\systems\gib.gsh;
#insert scripts\zm\_zm.gsh;
#insert scripts\zm\_zm_perks.gsh;

#using scripts\zm\_zm_weap_cymbal_monkey;

function init (debug_mode){

    if(debug_mode == false){
        break;
    }

    thread spawn_dog_command();
    thread spawn_zombie_command();
    thread give_perks();
    thread take_perks();
    thread give_loadout();
    thread give_weapons();
    thread give_points();
    thread spawn_powerup();
    thread new_camo();
    thread change_round();
    //thread complete_ee_step();
    thread power_command();
    thread difficulty_command();
    thread lighting_states();
    thread stop_zombie_spawning();
    thread play_music();
    thread do_notify();

    /*
    Commands:

    Type: /modvar <command> <para1> <para2> <para...>

    spawn_dog <amount> //--Spawn dogs
    spawn_zombie <amount> //--Spawn zombies and adds them to the zombies spawn list
    give_perks <playername> (all) //--Give perks to players 
    take_perks <playername> (all) //--Take perks from players
    loadout <playername> <loadout 1-5> //--Give loadouts
    give_weapons <playername> <loadout 1-5> //--Give loadouts
    points <playername> (all) <points> //--Give points to player(s)
    powerup <playername> (all) <powerupname> (nuke, maxammo, carpenter, instakill, freeperk, wwgrenade, firesale, doublepoints, minigun, all) //--Spawn Powerups
    camo <playername> (all) <index Number> //-- Change camo of current holding weapon
    change_round <index Number> //--Changes the round
    power <on/off> //-- turn power off or on
    difficulty <1-3> (1: Easy, 2: Medium, 3: Hard) //--Change difficulty to easy,medium,hard. (Zombie Speed, zombie limit and dog difficulty)
    lighting <1-4> //--Changes the Lightinstate of your map
    */
}

function spawn_dog_command(){
    amount = 0;
    while(1)
    {
        if(GetDvarInt("spawn_dog") != amount)
        {

            IPrintLnBold("Spawned " + GetDvarInt("spawn_dog") + " dogs with dvar!");
            zm_ai_dogs::special_dog_spawn(GetDvarInt("spawn_dog"));
            
            SetDvar("spawn_dog", 0);
        } 
        WAIT_SERVER_FRAME;
    }
}

function spawn_zombie_command(){
    amount = 0;
    while(1)
    {
        if(GetDvarInt("spawn_zombie") != amount)
        {
            IPrintLnBold("Spawned " + GetDvarInt("spawn_zombie") + " zombies with dvar!");

            spawner = array::random( level.zombie_spawners );

            spawned = 0;
            while(GetDvarInt("spawn_zombie") > spawned){

                spots = GetEntArray("zombie_dog_spawner", "script_noteworthy");

                ai = zombie_utility::spawn_zombie( spawner, spawner.targetname, array::random(spots));
                ai zm_spawner::zombie_spawn_init( undefined );

                ai.gibbed = 1;
                ai.in_the_ground = 1;
                ai.ritual_zomb = true;
                    
                ai.script_string = "find_flesh";
                spawned++;
                wait 0.2;
            }
            SetDvar("spawn_zombie", 0);
        } 
        WAIT_SERVER_FRAME;
    }
}

function give_loadout(){

    activated = "";
    while(1)
    {
        if(GetDvarString("loadout") != "")
        {
            string = GetDvarString("loadout");
            tokenized = StrTok(string, " ");
            index = Int(tokenized[1]);
            playername = ToLower(tokenized[0]);

            players = GetPlayers();
            foreach(player in players)
            {
                if(ToLower(player.name) == playername){
                    switch(index)
                    {
                        case 1:
                            player TakeWeapon(player GetStowedWeapon());
                            player TakeWeapon(player GetCurrentWeapon());
                            if(player HasPerk("specialty_additionalprimaryweapon"))
                            {
                                //player zm_perk_additionalprimaryweapon::take_additionalprimaryweapon();
                            }
                            player zm_weapons::weapon_give( GetWeapon("s2_emp44_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player zm_weapons::weapon_give( GetWeapon("s2_fg42_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player thread _zm_weap_cymbal_monkey::player_give_cymbal_monkey();
                            break;

                            case 2:
                            player TakeWeapon(player GetStowedWeapon());
                            player TakeWeapon(player GetCurrentWeapon());
                            if(player HasPerk("specialty_additionalprimaryweapon"))
                            {
                                //player zm_perk_additionalprimaryweapon::take_additionalprimaryweapon();
                            }
                            player zm_weapons::weapon_give( GetWeapon("s2_kar98k_irons_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player zm_weapons::weapon_give( GetWeapon("s2_lewis_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player thread _zm_weap_cymbal_monkey::player_give_cymbal_monkey();
                            break;

                            case 3:
                            player TakeWeapon(player GetStowedWeapon());
                            player TakeWeapon(player GetCurrentWeapon());
                            if(player HasPerk("specialty_additionalprimaryweapon"))
                            {
                                //player zm_perk_additionalprimaryweapon::take_additionalprimaryweapon();
                            }
                            player zm_weapons::weapon_give( GetWeapon("s2_m1919_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player zm_weapons::weapon_give( GetWeapon("s2_m1928_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player thread _zm_weap_cymbal_monkey::player_give_cymbal_monkey();
                            break;

                            case 4:
                            player TakeWeapon(player GetStowedWeapon());
                            player TakeWeapon(player GetCurrentWeapon());
                            if(player HasPerk("specialty_additionalprimaryweapon"))
                            {
                                //player zm_perk_additionalprimaryweapon::take_additionalprimaryweapon();
                            }
                            player zm_weapons::weapon_give( GetWeapon("s2_m1941_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player zm_weapons::weapon_give( GetWeapon("s2_mas36_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player thread _zm_weap_cymbal_monkey::player_give_cymbal_monkey(); 
                            break;
                    }
                }
                if(ToLower(playername) == "all"){
                    foreach(player in players)
                    {
                       switch(index)
                        {
                            case 1:
                            player TakeWeapon(player GetStowedWeapon());
                            player TakeWeapon(player GetCurrentWeapon());
                            if(player HasPerk("specialty_additionalprimaryweapon"))
                            {
                                //player zm_perk_additionalprimaryweapon::take_additionalprimaryweapon();
                            }
                            player zm_weapons::weapon_give( GetWeapon("s2_emp44_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player zm_weapons::weapon_give( GetWeapon("s2_fg42_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player thread _zm_weap_cymbal_monkey::player_give_cymbal_monkey();
                            break;

                            case 2:
                            player TakeWeapon(player GetStowedWeapon());
                            player TakeWeapon(player GetCurrentWeapon());
                            if(player HasPerk("specialty_additionalprimaryweapon"))
                            {
                                //player zm_perk_additionalprimaryweapon::take_additionalprimaryweapon();
                            }
                            player zm_weapons::weapon_give( GetWeapon("s2_kar98k_irons_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player zm_weapons::weapon_give( GetWeapon("s2_lewis_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player thread _zm_weap_cymbal_monkey::player_give_cymbal_monkey();
                            break;

                            case 3:
                            player TakeWeapon(player GetStowedWeapon());
                            player TakeWeapon(player GetCurrentWeapon());
                            if(player HasPerk("specialty_additionalprimaryweapon"))
                            {
                                //player zm_perk_additionalprimaryweapon::take_additionalprimaryweapon();
                            }
                            player zm_weapons::weapon_give( GetWeapon("s2_m1919_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player zm_weapons::weapon_give( GetWeapon("s2_m1928_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player thread _zm_weap_cymbal_monkey::player_give_cymbal_monkey();
                            break;

                            case 4:
                            player TakeWeapon(player GetStowedWeapon());
                            player TakeWeapon(player GetCurrentWeapon());
                            if(player HasPerk("specialty_additionalprimaryweapon"))
                            {
                                //player zm_perk_additionalprimaryweapon::take_additionalprimaryweapon();
                            }
                            player zm_weapons::weapon_give( GetWeapon("s2_m1941_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player zm_weapons::weapon_give( GetWeapon("s2_mas36_up"), false, false, true, true ); //Change Weapon for custom loadout
                            player thread _zm_weap_cymbal_monkey::player_give_cymbal_monkey();
                            break;
                        }
                    }
                }
                IPrintLnBold("Gave " + playername + " Loadout: " + index + " with dvar!");
            }
            SetDvar("loadout", "");
        } 
        WAIT_SERVER_FRAME;
    }

}

function give_weapons(){
    activated = "";
    while(1){
        if(GetDvarString("give") != "")
            {
                string = GetDvarString("give");
                weaponname = ToLower(string);

                IPrintLnBold("Gave weapon: " + weaponname + " with dvar!");

                players = GetPlayers();
                foreach(player in players)
                {
                    switch(weaponname){

                        case "shield":
                        player zm_weapons::weapon_give( GetWeapon("zod_riotshield"), false, false, true, true );
                        break;

                        case "monkeys":
                        player zm_weapons::weapon_give( GetWeapon("cymbal_monkey"), false, false, true, true );
                        break;

                        /*
                        case "monkeys":
                        player zm_weapons::weapon_give( GetWeapon("cymbal_monkey"), false, false, true, true );
                        break;
                        */

                        default:
                        player zm_weapons::weapon_give( GetWeapon(weaponname), false, false, true, true );
                        break;
                    }
                }

                SetDvar("give", "");
            }
        WAIT_SERVER_FRAME;
    }
}


function do_notify()
{
    activated = "";
    while(1)
    {
        if(GetDvarString("donotify") != "")
        {
            string = GetDvarString("donotify");
            stringnotify = ToLower(string);
            IPrintLn("Notified "+ stringnotify);
            level notify(stringnotify);
            SetDvar("donotify", "");
        }
        WAIT_SERVER_FRAME;
    }
}


function give_perks(){

    activated = "";
    while(1){
        if(GetDvarString("give_perks") != "")
            {

                string = GetDvarString("give_perks");
                tokenized = StrTok(string, " ");
                index = ToLower(tokenized[1]);
                playername = ToLower(tokenized[0]);

                players = GetPlayers();
                foreach(player in players)
                {
                    if(ToLower(player.name) == playername){
                        switch(index)
                        {
                            case "quickrevive":
                            player zm_perks::give_perk( PERK_QUICK_REVIVE, false );
                            break;

                            case "juggernog":
                            player zm_perks::give_perk( PERK_JUGGERNOG, false );
                            break;

                            case "speedcola":
                            player zm_perks::give_perk( PERK_SLEIGHT_OF_HAND, false );
                            break;

                            case "doubletap":
                            player zm_perks::give_perk( PERK_DOUBLETAP2, false );
                            break;

                            case "electric":
                            player zm_perks::give_perk( PERK_ELECTRIC_CHERRY, false );
                            break;

                            case "mulekick":
                            player zm_perks::give_perk( PERK_ADDITIONAL_PRIMARY_WEAPON, false );
                            break;

                            case "staminup":
                            player zm_perks::give_perk( PERK_STAMINUP, false );
                            break;

                            case "widowswine":
                            player zm_perks::give_perk( PERK_WIDOWS_WINE, false );
                            break;

                            case "bananacolada":
                            //player zm_perks::give_perk( "specialty_immunecounteruav", false );
                            break;

                            case "bullice":
                            //player zm_perks::give_perk( "specialty_proximityprotection", false );
                            break;

                            case "crusaderale":
                            //player zm_perks::give_perk( "specialty_flashprotection", false );
                            break;

                            case "moonshine":
                            //player zm_perks::give_perk( "specialty_flakjacket", false );
                            break;

                            case "phd":
                            //player zm_perks::give_perk( "specialty_phdflopper", false );
                            break;

                            case "sodalicious":
                            //player zm_perks::give_perk( "specialty_bulletflinch", false );
                            break;

                            case "dyingwish":
                            //player zm_perks::give_perk( "specialty_loudenemies", false );
                            break;

                            case "victorious":
                            //player zm_perks::give_perk( "specialty_sprintfire", false );
                            break;

                            case "all":
                            thread give_all_perks(playername);
                            break;
                        }
                    }
                }
                if(ToLower(playername) == "all"){
                    foreach(player in players){
                        switch(ToLower(index) )
                        {
                            case "quickrevive":
                            player zm_perks::give_perk( PERK_QUICK_REVIVE, false );
                            break;

                            case "juggernog":
                            player zm_perks::give_perk( PERK_JUGGERNOG, false );
                            break;

                            case "speedcola":
                            player zm_perks::give_perk( PERK_SLEIGHT_OF_HAND, false );
                            break;

                            case "doubletap":
                            player zm_perks::give_perk( PERK_DOUBLETAP2, false );
                            break;

                            case "electric":
                            player zm_perks::give_perk( PERK_ELECTRIC_CHERRY, false );
                            break;

                            case "mulekick":
                            player zm_perks::give_perk( PERK_ADDITIONAL_PRIMARY_WEAPON, false );
                            break;

                            case "staminup":
                            player zm_perks::give_perk( PERK_STAMINUP, false );
                            break;

                            case "widowswine":
                            player zm_perks::give_perk( PERK_WIDOWS_WINE, false );
                            break;

                            case "bananacolada":
                            //player zm_perks::give_perk( "specialty_immunecounteruav", false );
                            break;

                            case "bullice":
                            //player zm_perks::give_perk( "specialty_proximityprotection", false );
                            break;

                            case "crusaderale":
                            //player zm_perks::give_perk( "specialty_flashprotection", false );
                            break;

                            case "moonshine":
                            //player zm_perks::give_perk( "specialty_flakjacket", false );
                            break;

                            case "phd":
                            //player zm_perks::give_perk( "specialty_phdflopper", false );
                            break;

                            case "sodalicious":
                            //player zm_perks::give_perk( "specialty_bulletflinch", false );
                            break;

                            case "dyingwish":
                            //player zm_perks::give_perk( "specialty_loudenemies", false );
                            break;

                            case "victorious":
                            //player zm_perks::give_perk( "specialty_sprintfire", false );
                            break;

                            case "all":
                            thread give_all_perks(1);
                            break;
                        }
                    }
                }
                SetDvar("give_perks", "");
            } 
        WAIT_SERVER_FRAME;
    }
}

function take_perks(){

    activated = "";
    while(1)
    {
        if(GetDvarString("take_perks") != "")
        {
            string = GetDvarString("take_perks");
            playername = ToLower(string);

            players = GetPlayers();
            foreach(player in players)
            {
                if (ToLower(player.name) == playername){
                    perks = player GetPerks();
                    foreach(perk in perks)
                    {
                        player zm_perks::lose_random_perk();
                    }
                    IPrintLnBold("Took all perks from " + playername + " with dvar!");
                }
            }
            if (ToLower(playername) == "all"){
                foreach(player in players)
                {
                    perks = player GetPerks();
                    foreach(perk in perks)
                    {
                        player zm_perks::lose_random_perk();
                    }                    
                }
                IPrintLnBold("Took all perks from all players with dvar!");
            }
            SetDvar("take_perks", "");
        } 
        WAIT_SERVER_FRAME;
    }

}

function give_points(){

    activated = "";
    while(1)
    {
        if(GetDvarString("points") != "")
        {
            string = GetDvarString("points");
            tokenized = StrTok(string, " ");
            index = Int(tokenized[1]);
            playername = ToLower(tokenized[0]);

            players = GetPlayers();
            foreach(player in players)
            {
                if (ToLower(player.name) == playername){
                    player zm_score::add_to_player_score( index );
                    zm_utility::play_sound_at_pos( "purchase", player.origin );
                    IPrintLnBold("Gave player " + playername + " " + index + " points with dvar!");
                }
            }
            if (ToLower(playername) == "all"){
                foreach(player in players){
                    player zm_score::add_to_player_score( index );
                    zm_utility::play_sound_at_pos( "purchase", player.origin );
                    IPrintLnBold("Gave all players " + index + " points with dvar!");
                }
            }

            SetDvar("points", "");
        } 
        WAIT_SERVER_FRAME;
    }

}

function spawn_powerup(){

    activated = "";
    while(1)
    {
        if(GetDvarString("powerup") != "")
        {

            string = GetDvarString("powerup");
            tokenized = StrTok(string, " ");
            index = ToLower(tokenized[1]);
            playername = ToLower(tokenized[0]);

            players = GetPlayers();
            foreach(player in players)
            {
                if (ToLower(player.name) == playername){
                    switch(ToLower(index) )
                    {
                        case "instakill":
                        level thread zm_powerups::specific_powerup_drop("insta_kill", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "maxammo":
                        level thread zm_powerups::specific_powerup_drop("full_ammo", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "doublepoints":
                        level thread zm_powerups::specific_powerup_drop("double_points", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "firesale":
                        level thread zm_powerups::specific_powerup_drop("fire_sale", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "nuke":
                        level thread zm_powerups::specific_powerup_drop("nuke", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "minigun":
                        level thread zm_powerups::specific_powerup_drop("minigun", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "carpenter":
                        level thread zm_powerups::specific_powerup_drop("carpenter", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "freeperk":
                        level thread zm_powerups::specific_powerup_drop("free_perk", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "wwgrenade":
                        level thread zm_powerups::specific_powerup_drop("ww_grenade", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "all":
                        level thread zm_powerups::specific_powerup_drop("insta_kill", player.origin + (150,0,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("full_ammo", player.origin + (67,92,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("double_points", player.origin + (0,150,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("fire_sale", player.origin + (-67,92,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("nuke", player.origin + (-150,0,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("minigun", player.origin + (-67,-92,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("carpenter", player.origin + (0,-150,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("free_perk", player.origin + (67,-92,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("bottomless_clip", player.origin + (87,-70,0), undefined, undefined, undefined, undefined, false );
                        break;
                    }
                }
                IPrintLnBold("Spawned " + GetDvarString("powerup") + " powerup with dvar! ");
            }
            if(ToLower(playername) == "all"){
                foreach(player in players){
                    switch(ToLower(index) )
                    {
                        case "instakill":
                        IPrintLnBold("Spawn instakill");
                        level thread zm_powerups::specific_powerup_drop("insta_kill", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "maxammo":
                        level thread zm_powerups::specific_powerup_drop("full_ammo", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "doublepoints":
                        level thread zm_powerups::specific_powerup_drop("double_points", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "firesale":
                        level thread zm_powerups::specific_powerup_drop("fire_sale", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "nuke":
                        level thread zm_powerups::specific_powerup_drop("nuke", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "minigun":
                        level thread zm_powerups::specific_powerup_drop("minigun", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "carpenter":
                        level thread zm_powerups::specific_powerup_drop("carpenter", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "freeperk":
                        level thread zm_powerups::specific_powerup_drop("free_perk", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "wwgrenade":
                        level thread zm_powerups::specific_powerup_drop("ww_grenade", player.origin + (-80,0,0), undefined, undefined, undefined, undefined, false );
                        break;

                        case "all":
                        level thread zm_powerups::specific_powerup_drop("insta_kill", player.origin + (150,0,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("full_ammo", player.origin + (67,92,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("double_points", player.origin + (0,150,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("fire_sale", player.origin + (-67,92,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("nuke", player.origin + (-150,0,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("minigun", player.origin + (-67,-92,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("carpenter", player.origin + (0,-150,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("free_perk", player.origin + (67,-92,0), undefined, undefined, undefined, undefined, false );
                        level thread zm_powerups::specific_powerup_drop("bottomless_clip", player.origin + (87,-70,0), undefined, undefined, undefined, undefined, false );
                        break;
                    }
                }
            }
            SetDvar("powerup", "");
        } 
        WAIT_SERVER_FRAME;
    }

}

function new_camo(){

    activated = "";
    while(1)
    {
        if(GetDvarString("camo") != "")
        {

            string = GetDvarString("camo");
            tokenized = StrTok(string, " ");
            index = Int(tokenized[1]);
            playername = ToLower(tokenized[0]);

            players = GetPlayers();
            foreach(player in players)
            {
                if (ToLower(player.name) == playername){
                player UpdateWeaponOptions( player GetCurrentWeapon(), player CalcWeaponOptions(index, 0, 0) );
                IPrintLnBold("Added new Camo " + index + " to player: " + playername);
                }
            }
            if (ToLower(playername) == "all"){
                foreach(player in players){
                player UpdateWeaponOptions( player GetCurrentWeapon(), player CalcWeaponOptions(index, 0, 0) );
                IPrintLnBold("Added new Camo " + index + " to all players");
                }
            }

            SetDvar("camo", "");
        } 
        WAIT_SERVER_FRAME;
    }
}

function change_round(){

    amount = 0;
    while(1)
    {
        if(GetDvarInt("change_round") != amount)
        {
            if(isdefined("between_round_over")){
                wait 0.05;
            }

            thread goto_round( GetDvarInt("change_round") );

            IPrintLnBold("Set round to: " + GetDvarInt("change_round"));

            SetDvar("change_round", 0);
        } 
        WAIT_SERVER_FRAME;
    }

}

function complete_ee_step(){
    activated = 0;
    while(1)
    {
        if(GetDvarInt("complete_ee_step") != activated)
        {
            level notify("ee_step_complete");
            
            IPrintLnBold("Complete EE Step with dvar!");
            SetDvar("complete_ee_step", 0);
        } 
        WAIT_SERVER_FRAME;
    }
}

function power_command(){

    activated = "";
    while(1)
    {
        if(GetDvarString("power") != "")
        {
            string = GetDvarString("power");
            power_state = ToLower(string);

            if (ToLower(power_state) == "on"){
                level flag::clear( "power_off" );
                level flag::set("power_on");
                level clientfield::set("zombie_power_on", 0);
            }
            else{
                level flag::clear( "power_on" );
                level flag::set("power_off");
                level clientfield::set("zombie_power_off", 0);
                level notify("power_off" );
            }
            IPrintLnBold("Turned power " + power_state + " with dvar!");
            SetDvar("power", "");
        } 
        WAIT_SERVER_FRAME;
    }

}

function difficulty_command(){
    activated = 0;
    while(1)
    {
        if(GetDvarInt("difficulty") != activated)
        {
            difficulty_index = GetDvarInt("difficulty");
            
            IPrintLnBold("Set difficulty to " +  difficulty_index + " with dvar!");

            switch(difficulty_index){
                case 1:
                    thread new_zombie_speed(1, 24, 8, 8, 2);
                    foreach(player in GetPlayers()){
                        player thread lui::screen_flash(1, 1, 1, 1, "white");
                    }
                    thread goto_round( level.round_number );
                break;

                case 2:
                    thread new_zombie_speed(5, 48, 500, 16, 20, 3);
                    foreach(player in GetPlayers()){
                        player thread lui::screen_flash(1, 1, 1, 1, "white");
                    }
                    thread goto_round( level.round_number );
                break;

                case 3:
                    thread new_zombie_speed(50, 64, 2500, 16, 20, 4);
                    foreach(player in GetPlayers()){
                        player thread lui::screen_flash(1, 1, 1, 1, "white");
                    }
                    thread goto_round( level.round_number );
                break;
            }

            SetDvar("difficulty", 0);
        } 
        WAIT_SERVER_FRAME;
    }
}

function lighting_states(){
    activated = 0;
    while(1)
    {
        if(GetDvarInt("lighting") != activated)
        {
            lighting_index = GetDvarInt("lighting");
            
            IPrintLnBold("Set Lightingstate to " +  lighting_index + " with dvar!");

            switch(lighting_index){
                case 1:
                    level util::set_lighting_state( 0 );
                break;

                case 2:
                    level util::set_lighting_state( 1 );
                break;

                case 3:
                    level util::set_lighting_state( 2 );
                break;

                case 4:
                    level util::set_lighting_state( 3 );
                break;
            }

            SetDvar("lighting", 0);
        } 
        WAIT_SERVER_FRAME;
    }
}

function stop_zombie_spawning(){

    activated = "";
    while(1)
    {
        if(GetDvarString("spawning") != "")
        {
            string = GetDvarString("spawning");
            spawning_state = ToLower(string);

            if (spawning_state == "on"){
                level flag::set("spawn_zombies");
            }
            else if(spawning_state == "off"){
                level flag::clear("spawn_zombies");
                a_ai_enemies = GetAITeamArray( "axis" );
                foreach( ai_enemy in a_ai_enemies )
                {
                    level.zombie_total++;
                    level.zombie_respawns++;    // Increment total of zombies needing to be respawned
                    
                    ai_enemy Kill();
                }
            }
            IPrintLnBold("Turned spawners " + spawning_state + " with dvar!");
            SetDvar("spawning", "");
        } 
        WAIT_SERVER_FRAME;
    }

}

function play_music(){

    activated = "";
    while(1)
    {
        if(GetDvarString("play") != "")
        {
            value = ToLower(GetDvarString("play"));

            players = GetPlayers();
            foreach(player in players){
                player PlaySoundToPlayer( value , player );
            }

            IPrintLnBold("Played: " + value + " with dvar!");

            SetDvar("play", "");
        } 
        WAIT_SERVER_FRAME;
    }

}

function new_zombie_speed(multiplier, actor_limit, dog_health, dog_total_1, dog_total_2, dog_per_player)
{
    level flag::wait_till( "initial_blackscreen_passed" ); 
    zombie_utility::set_zombie_var( "zombie_move_speed_multiplier",       multiplier,    false );    //  Multiply by the round number to give the base speed value.  0-40 = walk, 41-70 = run, 71+ = sprint
    zombie_utility::set_zombie_var( "zombie_move_speed_multiplier_easy",  multiplier,    false );    //  Multiply by the round number to give the base speed value.  0-40 = walk, 41-70 = run, 71+ = sprint

    level.zombie_actor_limit = actor_limit;
    level.zombie_ai_limit = actor_limit;

    level.dog_health = dog_health;
    level.dog_total_spawn_1 = dog_total_1;
    level.dog_total_spawn_2 = dog_total_2;

    level.dog_spawn_per_player = dog_per_player;
}

function goto_round(round_number = undefined)
{
    if(!isdefined(round_number))
        round_number = zm::get_round_number();
    if(round_number == zm::get_round_number())
        return;
    if(round_number < 0)
        return;

    // kill_round by default only exists in debug mode
    /#
    level notify("kill_round");
    #/
    // level notify("restart_round");
    level notify("end_of_round");
    level.zombie_total = 0;
    zm::set_round_number(round_number);
    round_number = zm::get_round_number(); // get the clamped round number (max 255)

    zombie_utility::ai_calculate_health(round_number);
    SetRoundsPlayed(round_number);

    foreach(zombie in zombie_utility::get_round_enemy_array())
    {
        zombie Kill();
    }

    if(level.gamedifficulty == 0)
        level.zombie_move_speed = round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
    else
        level.zombie_move_speed = round_number * level.zombie_vars["zombie_move_speed_multiplier"];

    level.zombie_vars["zombie_spawn_delay"] = [[level.func_get_zombie_spawn_delay]](round_number);

    level.sndGotoRoundOccurred = true;
    level waittill("between_round_over");
}

function give_all_perks(allplayers=false)
{
    perks = GetArrayKeys( level._custom_perks );
    if(allplayers)
    {
        players = GetPlayers();
        foreach(player in players)
        {
            if(!player laststand::player_is_in_laststand())
            {
                playerperks = player GetPerks();
                giveperks = perks.size - playerperks.size;
                for(i=0;i<giveperks;i++)
                {
                    wait(0.5);
                    player zm_perks::give_random_perk();
                }
            }
        }
    }
    else
    {
        playerperks = self GetPerks();
        giveperks = perks.size - playerperks.size;
        for(i=0;i<giveperks;i++)
        {
            wait(0.5);
            self zm_perks::give_random_perk();
        }
    }
}