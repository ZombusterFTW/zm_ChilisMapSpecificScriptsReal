
#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_util;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_unitrigger;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\madgaz\_zm_perk_planet_wunderfizz2.gsh;

#namespace zm_perk_wunderfizz2;

REGISTER_SYSTEM_EX( "wunderfizz", undefined, &FirstFrame, undefined )

#precache("model", "dfury_wunderfizz2");
#precache("model", "dfury_wunderfizz2_on");

#precache("fx", "dlc1/castle/fx_castle_elec_sparks_bounce_sm_blue");
#precache("fx", "dlc2/island/fx_elec_perk_mulekick");
#precache("fx", "_custom/wunderfizz/fx_gaz_wonderfizz_portal");

//MADE BY PLANET FOR MADGAZ
//V1.0

function FirstFrame(){
    wait 0.05;
    
    level.wunderfizzMachines = [];
    level.wunderfizzIndex = -1;
    wunderfizzMachines = GetEntArray("wunderfizz_perk_location", "targetname");

    startingLocations = [];
    
    foreach(machine in wunderfizzMachines){
        trigger_struct = SpawnStruct();
        trigger_struct.angles = machine.angles;
        trigger_struct.origin = machine.origin + (0, 0, 64);
        trigger_struct.collision  = util::spawn_model( "zm_collision_perks1", machine.origin, machine.angles );
	    trigger_struct.collision.script_noteworthy = "clip";
	    trigger_struct.collision DisconnectPaths();
        trigger_struct.model = machine;
        trigger_struct.index = level.wunderfizzMachines.size;
        trigger_struct.uses = 0;
        trigger_struct.power_on = true;
        trigger_struct ResetWunderfizz();
        if(isDefined(machine.script_noteworthy) && machine.script_noteworthy == "starting_location") startingLocations[startingLocations.size] = machine;

        level.wunderfizzMachines[level.wunderfizzMachines.size] = trigger_struct;
    }

    if(startingLocations.size > 0){
        level.wunderfizzIndex = RandomInt(startingLocations.size);
        level.currentWunderMachine = startingLocations[level.wunderfizzIndex];
    } 
    else{
        level.wunderfizzIndex = RandomInt(level.wunderfizzMachines.size);
        level.currentWunderMachine = level.wunderfizzMachines[level.wunderfizzIndex];
    } 
    if(WUNDERFIZZ_WAIT_FOR_POWER_ON)
    {
        level waittill("power_on");
    }
    level.currentWunderMachine AwakeWunderFizz();
}

function ResetWunderfizz(){
    if(isDefined(self.s_unitrigger)) zm_unitrigger::unregister_unitrigger(self.s_unitrigger); //Make sure trigger is disabled
    self.model SetModel("dfury_wunderfizz2");
    if(isDefined(self.bottle)) self.bottle Delete();
    self.machine_cost = MACHINE_COST_WUNDERFIZZ;
    self.IsGivingPerk = false;
    self.grabber = -1;    
    self.uses = 0;
}

function AwakeWunderFizz(){
    self notify("FizzMachineArrived");
    self endon("FizzMachineArrived");
    self.model SetModel("dfury_wunderfizz2_on");

    PlaySoundAtPosition( "wunderfizz_random_turnon", self.origin);

    level.wunderfizzIndex = self.index; //We are now using this machine, might be unneccessary but I'll keep it for safety

    while(1){
        self zm_unitrigger::create_unitrigger( HINT_WUNDERFIZZ + self.machine_cost + "]", 80, &WunderFizzBuy_prompt, &WunderFizzUseLogic);
        
        self waittill("trigger_activated", player);
        
        zm_unitrigger::unregister_unitrigger(self.s_unitrigger);

        player thread zm_score::minus_to_player_score( self.machine_cost ); //Take points from player

        self thread PlayBUYFxs();
        self.grabber = player.characterIndex;
        self.uses++;
        player zm_score::minus_to_player_score( self.cost );
        self.model PlaySound("zmb_cha_ching");

        perk = self RandomizePerk(player);
        self zm_unitrigger::create_unitrigger( HINT_WUNDERFIZZ_GRAB, 80, &WunderFizzGrab_prompt, &WunderFizzGrabLogic);
        self thread perkTimeOutListener();
        self.IsGivingPerk = true;
        self waittill("trigger_activated", player);
        self notify("kill_buy_fxs");
        zm_unitrigger::unregister_unitrigger(self.s_unitrigger);
        if(self.IsGivingPerk){
            self notify("perk_has_been_taken");
            self.IsGivingPerk = false;
            self GivePerk(player, perk);
            self shouldGiveBonusPerk(player);
        }
        time = SoundGetPlaybackTime("wunderfizz_random_recharge_afterperk") * .001;
        PlaySoundAtPosition("wunderfizz_random_recharge_afterperk", self.model.origin);
        wait time - 0.5;

        if(self shouldWunderFizzChangeLocation()){ //TODO PLAY LEAVE SOUNDS
            self WunderFizzAwayAnimation(); //Shake away
            self ResetWunderfizz(); //Disable this machine
            player thread playSighFail();
            do{
                level.wunderfizzIndex = randomInt(level.wunderfizzMachines.size);
                wait 0.05;
            }while(level.wunderfizzIndex == self.index); //Pick an index that is different from the current one

            level thread DelayNewWunderFizz();
            break;
        }

    }  
}

function perkTimeOutListener(){
    self endon("perk_has_timedout");
    self endon("perk_has_been_taken");
    wait 1; //Wait seconds before timingout
    time_to_wait = WUNDERFIZZ_PERK_TIMEOUT_TIME; // 100%
    tenth = time_to_wait / 100 ;
    current_scale = 1.01;
    while(isDefined(self.bottle) && self.IsGivingPerk && time_to_wait > 0){
        wait tenth;
        current_scale -= 0.01;
        self.bottle SetScale(current_scale);
        time_to_wait -= tenth;
    }
    self.bottle Delete();
    self.IsGivingPerk = false;
    self notify("trigger_activated", undefined);
    self notify("perk_has_timedout");
}

function shouldWunderFizzChangeLocation(){
    if(level.wunderfizzMachines.size < 2 ) return false; //There's no new places to move to
    if(self.uses < WUNDERFIZZ_MIN_USES_TO_MOVE) return false; //Uses haven't reached the threshold

    if(self.uses < ( WUNDERFIZZ_MIN_USES_TO_MOVE + 3 ) && randomInt(100) < 25 )  return true;
    else if(self.uses <= ( WUNDERFIZZ_MIN_USES_TO_MOVE + 6 ) && randomInt(100) < 50) return true;
    else if(self.uses > ( WUNDERFIZZ_MIN_USES_TO_MOVE + 6 ) ) return true;

    return false; //No luck, stay here
}

function DelayNewWunderFizz(){

    index = level.wunderfizzIndex;
    machine = level.wunderfizzMachines[index]; //Grab the new machine
    wait WUNDERFIZZ_DELAY_NEW_SPAWN; //Wait set delay
    level.currentWunderMachine = machine;
    machine thread AwakeWunderFizz();
}

function GivePerk(player, perk){
    self thread zm_perks::vending_trigger_post_think( player, perk );
    self.bottle Delete();
}

function shouldGiveBonusPerk(player){
    chance = randomInt( 100 );
	if (  chance <= BONUS_PERK_CHANCE_WUNDERFIZZ  ){
		perks = player PlayerUnowedPerks();
		if ( !isDefined( perks )) return;
		player zm_perks::give_perk( perks[ randomInt( perks.size ) ], 0 );
	}
}

function PlayerUnowedPerks(){
    mapPerks = getArrayKeys( level._custom_perks );
	if( !isDefined( mapPerks ) || mapPerks.size < 1 ) return undefined; //For some reason we have no perks?
	
	unownedPerks = [];
    foreach( perk in mapPerks ) if(!self HasPerk(perk)) unownedPerks[unownedPerks.size] = perk;
	return unownedPerks;
}

function RandomizePerk(player){
    self endon("stop_randomizing");
    if(isDefined(self.bottle)) self.bottle Delete();
    PlaySoundAtPosition("wunderfizz_random_start", self.origin);
    self.model PlayLoopSound("wunderfizz_random_loop", 0.1);

    self.bottle = util::spawn_model( "tag_origin", self.model GetTagOrigin("tag_bottle") + (0, 0, 5), self.model.angles );
    self.bottle Rotate((0, 720, 0));

    perk = self _Randomize(player);
    //self waittill("randomization_done");
    self.bottle MoveTo(self.bottle.origin, 0.1);
    self.bottle RotateTo( self.model.angles, 0.2);

    self.model StopLoopSound(0.1);
    PlaySoundAtPosition("wunderfizz_random_done", self.origin);

    return perk;
}

function WunderFizzAwayAnimation(){

    tag_fx_origin = util::spawn_model( "tag_origin", self.model.origin, self.model.angles );
    PlayFXOnTag("dlc2/island/fx_elec_perk_mulekick", tag_fx_origin, "tag_origin");

    direction = self.model.origin;
    direction = (direction[1], direction[0], 0);    
    if(direction[1] < 0 || (direction[0] > 0 && direction[1] > 0)) {
        direction = (direction[0], direction[1] * -1, 0);
    }
    else if(direction[0] < 0){
        direction = (direction[0] * -1, direction[1], 0);
    }
    self.model Vibrate( direction, 0.5, 0.5, 5);
    for(i = 5; i > 0; i--){
        self.model SetModel("dfury_wunderfizz2");
        wait 0.5;
        self.model SetModel("dfury_wunderfizz2_on");
        wait 0.5;
    }

    tag_fx_origin Delete();
}

function playSighFail(){
    PlaySoundAtPosition( "evt_perk_deny", self.origin);
    self zm_audio::create_and_play_dialog( "general", "sigh" );
}

function playOutOfMoney(){
    PlaySoundAtPosition( "evt_perk_deny", self.origin);
	self zm_audio::create_and_play_dialog( "general", "outofmoney" );
}

function private _Randomize(player){
    self endon("stop_randomizing");
    availablePerks = player PlayerUnowedPerks();
    availablePerks = array::randomize(availablePerks);
    i = RANDOMIZE_TIME_WUNDERFIZZ; // Seconds
    while(i > 0){
        if(availablePerks.size < 1) break;
        perk = availablePerks[RandomInt(availablePerks.size)];
        //ArrayRemoveValue(availablePerks, perk);
        self.bottle SetModel( GetWeaponWorldModel( level._custom_perks[ perk ].perk_bottle_weapon ) );

        if      ( i < 20 ) { wait .05;  i -= .05;   self.bottle Rotate((0, 100, 0));    }
		else if ( i < 30 ) { wait .1;   i -= .01;   self.bottle Rotate((0, 200, 0));    }
		else if ( i < 35 ) { wait .2;    i -= .02;  self.bottle Rotate((0, 360, 0));    }
		else if ( i < 38 ) { wait .3;   i -= .03;   self.bottle Rotate((0, 500, 0));    }
    }

    return perk;
}

function PlayBUYFxs(){
    tag_fx_bulb = util::spawn_model( "tag_origin", self.model GetTagOrigin("tag_bottle") + (0, 0, 17), self.model.angles );
    tag_fx = util::spawn_model( "tag_origin", self.model GetTagOrigin("tag_bottle") + (0, 0, 6), self.model.angles );
    PlayFXOnTag("dlc1/castle/fx_castle_elec_sparks_bounce_sm_blue", tag_fx_bulb, "tag_origin");
    PlayFXOnTag("_custom/wunderfizz/fx_gaz_wonderfizz_portal", tag_fx, "tag_origin");
    self waittill("kill_buy_fxs");
    if(isDefined(tag_fx_bulb))
    {
        tag_fx_bulb Delete();
    }
    if(isDefined(tag_fx))
    {
        tag_fx Delete();
    }
        
}

// Unitrigger funcs
function stub_update_prompt( player ){	
	if( !zm_utility::is_player_valid( player ) )
		return false;
	if( player zm_utility::in_revive_trigger() )
		return false;
	if( IS_DRINKING(player.is_drinking) )
		return false;
	return true;
}

function WunderFizzBuy_prompt( player ){	
	self endon( "kill_trigger" );
	can_use = stub_update_prompt( player );
	self setInvisibleToPlayer( player, !can_use );
	self SetHintString( self.stub.hint_string );
	return can_use;
}

function WunderFizzGrab_prompt( player ){	
	self endon( "kill_trigger" );
	can_use = stub_update_prompt( player );
    if( isdefined( self.stub.related_parent.grabber ) && self.stub.related_parent.grabber != player.characterIndex )
    {
        can_use = false;
    }

	self setInvisibleToPlayer( player, !can_use );
	self SetHintString( self.stub.hint_string );
	return can_use;
}

function WunderFizzGrabLogic(){	
	self endon("kill_trigger");
	
	while ( true )
	{
		self waittill( "trigger", player );

        // revive triggers override trap triggers
		if( self.stub.related_parent.grabber != player.characterIndex || //If it's not the right played don't even continue
            player zm_utility::in_revive_trigger() ||
            IS_DRINKING( player.is_drinking ) ||
            !zm_utility::is_player_valid( player )
        )   continue;

		self.stub.related_parent notify( "trigger_activated", player );
	}
}

function WunderFizzUseLogic(){	
	self endon("kill_trigger");
	
	while ( true )
	{
		self waittill( "trigger", player );

        // revive triggers override trap triggers
		if( player zm_utility::in_revive_trigger() ||
            IS_DRINKING( player.is_drinking ) ||
            !zm_utility::is_player_valid( player ) ||
            !self.stub.related_parent canSpinWunderFizz(player)
        )   continue;

		self.stub.related_parent notify( "trigger_activated", player );
	}
}

function canSpinWunderFizz(player){
    
    unownedPerks = player PlayerUnowedPerks();
    if ( !player zm_utility::can_player_purchase_perk() || !isDefined( unownedPerks )  || unownedPerks.size < 1){
        self thread playSighFail();
        return false;
    }
    if ( !player zm_score::can_player_purchase( self.machine_cost ) ){
		player thread playOutOfMoney();
		return false;
	}
    return true;
}