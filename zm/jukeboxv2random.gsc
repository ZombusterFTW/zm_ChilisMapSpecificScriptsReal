#using scripts\codescripts\struct;
#using scripts\shared\music_shared;
#using scripts\shared\audio_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_score;
#using scripts\shared\flag_shared;
#using scripts\zm\_zm_audio;
#using scripts\shared\clientfield_shared;
#using scripts\Sphynx\_zm_subtitles;
#using scripts\zm\_zm_utility;
#using scripts\shared\util_shared;
#using scripts\Sphynx\_zm_subtitles;
#using scripts\shared\array_shared;

#define WAIT_FOR_POWER 1				//wait for power to be on
#define OVERRIDE_MUS_SYSTEM 1			//stops round music

#precache("fx", "light/fx_light_doa_pickup_glow_green");
#precache("fx", "light/fx_light_doa_pickup_glow_red");
#precache("model", "abracadvre");
#precache("model", "alwaysrunning");
#precache("model", "archangel");
#precache("model", "boa");
#precache("model", "braxelbrobots");
#precache("model", "carrion");
#precache("model", "deadagain");
#precache("model", "deadended");
#precache("model", "deadflowers");
#precache("model", "dramophone");
#precache("model", "enemylikeme");
#precache("model", "icarly");
#precache("model", "joliecoquine");
#precache("model", "lonedigger");
#precache("model", "lullabyforadeadman");
#precache("model", "notready");
#precache("model", "paredolia");
#precache("model", "rightwherewebelong");
#precache("model", "rockitforme");
#precache("model", "sweetrascal");
#precache("model", "thegift");
#precache("model", "theone");
#precache("model", "undone");
#precache("model", "snakeskinboots");
#precache("model", "cominghome");



///REMOVE THE DISPLAYED HINT STRINGS, either make the jukebox use a model system or a random system, lets do models with a condensed version of each song title. Hintstrings are too intensive

function __init__()
{
	level waittill("all_players_connected");
	level.jukeboxisplayingchilis = false;
	level.jukebox_cost = 500; 
	level.chilismusicmodel = GetEnt("chilismusicmodel", "targetname");
	level.hotelmusicmodel = GetEnt("hotelmusicmodel", "targetname");
	level.jukeboxmusicspot = GetEnt("jukeboxmusicspot", "targetname");
	level.chilisdmgspot = GetEnt("chilisjukedamage", "targetname");
	level.hoteldmgspot = GetEnt("hoteljukedamage", "targetname");
	level.jukeboxes = GetEntArray("zb_jukebox", "targetname");
	level.hotelsongs = array("braxelbrobots", "dramophone", "enemylikeme", "joliecoquine", "lonedigger", "sweetrascal", "rockitforme","plume","snakeskinboots", "heartaches","rwwb"); 
	level.hotelsongsmodels = array("braxelbrobots","dramophone", "enemylikeme", "joliecoquine", "lonedigger", "sweetrascal", "rockitforme", "plume", "snakeskinboots", "heartaches", "rightwherewebelong");
	level.hotelsongnames = array("Braxel Brobots by Peggy Suave", "Dramophone by Caravan Palace", "Enemy Like Me by Peggy Suave", "Jolie Coquine by Caravan Palace", "Lone Digger by Caravan Palace", "Sweet Rascal by Jaime Berry", "Rock It For Me by Caravan Palace","Plume by Caravan Palace", "Snakeskin Boots by Jack Wall", "Heartaches by Al Bowlly", "Right Where We Belong by Jack Wall");
	level.chilissongs = array("icarlytheme", "boa","deadagain","abra","alwaysrun","archangel","notready2die","carrion","cominghome","deadende","deadflowers","undone_mx","lullably","paredolia","thegift","theone");
	level.chilissongsmodels = array("icarly", "boa", "deadagain", "abracadvre", "alwaysrunning","archangel", "notready", "carrion", "cominghome", "deadended", "deadflowers", "undone", "lullabyfordeadman", "paredolia", "thegift", "theone");
	level.chilissongnames = array("iCarly Theme by Miranda Cosgrove and Drake Bell", "Beauty of Anihilation by Kevin Sherwood and Elena Siegman", "Dead Again by Kevin Sherwood and Elena Siegman", "Abracadvre by Kevin Sherwood and Elena Siegman", "Always Running by Kevin Sherwood and Malukah", "Archangel by Kevin Sherwood, Clark S Nova, Elena Siegman, and Malukah", "Not Ready To Die by Avenged Sevenfold", "Carrion by Kevin Sherwood and Clark S Nova", "Coming Home by Kevin Sherwood and Elena Siegman", "Dead Ended by Kevin Sherwood and Clark S Nova", "Dead Flowers by Kevin Sherwood and Malukah", "Undone by Kevin Sherwood", "Lullaby for A Dead Man by Kevin Sherwood and Elena Siegman","Paredolia by Kevin Sherwood and Elena Siegman", "The Gift by Kevin Sherwood and Elena Siegman", "The One by Kevin Sherwood and Elena Siegman");
	level.jukeboxglobalindex = 0;
	level.currentsongplayingjbv2 = "";
	level.currentsongplayingdescjbv2 = "";
	//function unlocked songs are canned
	//level thread unlockedsongs();
	foreach(jukebox in level.jukeboxes)
	{
		jukebox.jukeboxindex = 0;
		self.isplaying = false;
		jukebox thread setup_jukebox(0);
	}
}


function spawnfxandmodel(stringnotify, fx, model)
{
	fxspot = util::spawn_model("tag_origin", self.origin);
	WAIT_SERVER_FRAME;
	PlayFXOnTag(fx, fxspot, "tag_origin");
	level waittill(stringnotify);
	fxspot Delete();
}


function setup_jukebox(int)
{
	WAIT_SERVER_FRAME;
	level.jukeboxisplayingchilis = false;
	level.jukeboxsongtitleplaying = "";
	level notify("starting_jukeboxes");
	if(int == 0)
	{
		self UseTriggerRequireLookAt();
		jukeboxstrings = StrTok(self.script_string, ",");
		self.jukeboxnotify = jukeboxstrings[1];
		self.jukeboxnotif2 = jukeboxstrings[2];
		switch(jukeboxstrings[0])
		{

			case "chilis":
			{
				self.soundarray = level.chilissongs;
				self.namesarray = level.chilissongnames;
				self.musicmodel = level.chilismusicmodel;
				self.modelarray = level.chilissongsmodels;
				self.dmgtrigger = level.chilisdmgspot;
				break;
			}
			case "hotel":
			{
				self.soundarray = level.hotelsongs;
				self.namesarray = level.hotelsongnames;
				self.musicmodel = level.hotelmusicmodel;
				self.modelarray = level.hotelsongsmodels;
				self.dmgtrigger = level.hoteldmgspot;
				break;
			}
		}
		model = GetEnt(self.target, "targetname");
		fxspot = util::spawn_model("tag_origin", model.origin);
		WAIT_SERVER_FRAME;
		self SetHintString(&"ZOMBIE_NEED_POWER");
		if(WAIT_FOR_POWER) level waittill("power_on");
		PlayFXOnTag(level.terminalfxlinkblue, fxspot, "tag_origin");
		self SetHintString(jukeboxstrings[4]);
		level waittill(jukeboxstrings[3]);
		fxspot Delete();
		//PlayFX(level._effect["poltergeist"], model.origin);
		PlayFxWithCleanup(level._effect["poltergeist"], model.origin);
		model Vibrate((0,-100,0), 0.3, 0.4, 1.5);
		//if(isDefined(self.script_string)) level waittill(self.script_string);
	}
	//self SetHintString("Press ^3[{+activate}]^7 To Activate Jukebox");
	self thread jukeboxmusicplay(self.soundarray, self.namesarray, self.jukeboxnotify, self.jukeboxnotif2, model);
}

function isplayinghint(jukeboxnotify, model)
{
	level endon("restartjukeboxes");
	level waittill(jukeboxnotify);
	level notify("endknifecycle");
	self thread spawnfxandmodel("starting_jukeboxes", "light/fx_light_doa_pickup_glow_red", model);
	self SetHintString("A jukebox is currently playing, please wait");
}


function jukeboxmusicplay(soundarray, namesarray, jukeboxnotify, jukeboxnotif2, model)
{
	
	self.isplaying = false;
	level.jukeboxisplayingchilis = false;
	if(self.jukeboxindex > soundarray.size-1) self.jukeboxindex = 0;
	level notify("endknifecycle");
	self thread knifetocycle(jukeboxnotify,jukeboxnotif2,soundarray);
	self thread isplayinghint(jukeboxnotif2, model);
	self thread spawnfxandmodel("jukebox_new_song", "light/fx_light_doa_pickup_glow_green", model);
	level endon(jukeboxnotif2);
	level endon("restartjukeboxes");
	while(1)
	{
		self SetHintString("Press ^3[{+activate}]^7 To Play Song Cost: [^3"+level.jukebox_cost+"^7] ^1Knife the box to cycle songs");
		//"+namesarray[self.jukeboxindex]+". ^3Cost^7: ["+level.jukebox_cost+"] ^1Knife the box to cycle songs");
		self.musicmodel SetModel(self.modelarray[self.jukeboxindex]);
		self waittill("trigger", player);
		if( isDefined(level.jukebox_cost) && player.score >= level.jukebox_cost )
		{
			player zm_score::minus_to_player_score( level.jukebox_cost );
			PlaySoundAtPosition( "cha_ching", self.origin);
			self SetHintString("");
			if(OVERRIDE_MUS_SYSTEM) level thread zm_audio::sndMusicSystem_StopAndFlush();
			self PlaySound("jbstart");
			break;
		}
		else if( isDefined( level.jukeboxcost ) && player.score < level.jukebox_cost )
		{
			//PlaySoundAtPosition( "nsz_deny", self.origin);
			player PlayLocalSound("defaultfail");
			//self SetHintString(player.playername+" Lacks the required funds");
			wait(0.5); 
			continue; 
		}			
	}
	thread zm_subtitles::subtitle_display(undefined, 3, "^5Jukebox", "^3[Now Playing]:^7 " + namesarray[self.jukeboxindex]);
	level notify("jukebox_new_song");
	level notify(jukeboxnotify);
	level.jukeboxisplayingchilis = true;
	self.isplaying = true;
	self thread wait_for_game_end(soundarray[self.jukeboxindex]);
	self thread allowsongskip(soundarray[self.jukeboxindex], namesarray, player);
	//time = SoundGetPlaybackTime(soundarray[self.jukeboxindex]);
	self SetHintString("Press ^3[{+activate}]^7 to skip");
	level.currentsongplayingdescjbv2 = namesarray[self.jukeboxindex];
	level.currentsongplayingjbv2 = soundarray[self.jukeboxindex];
	level.jukeboxmusicspot PlaySound(soundarray[self.jukeboxindex]);
	level.jukeboxsongtitleplaying = soundarray[self.jukeboxindex];
	self thread spawnfxandmodel("starting_jukeboxes", "light/fx_light_doa_pickup_glow_red", model);
	//IPrintLnBold(SoundGetPlaybackTime(soundarray[self.jukeboxindex])/1000 + "s");
	time = SoundGetPlaybackTime(soundarray[self.jukeboxindex])/1000;
	wait(time);
	//IPrintLnBold("SONG OVER");
	self PlaySound("jbstop");
	level notify("jukeboxsongcomplete");
	self.jukeboxindex = self.jukeboxindex + 1;
	//level.jukeboxglobalindex ++;
	foreach(jukebox in level.jukeboxes)
	{
		jukebox thread setup_jukebox(1);
	}
	//self thread jukeboxmusicplay(soundarray, namesarray, jukeboxnotify);
}

function allowsongskip(alias, namesarray, player)
{
	self thread eedisallowuse(alias, namesarray, self.jukeboxindex, player);
	wait 0.5;
	level endon("jukeboxsongcomplete");
	level endon("storycriteescene");
	self waittill("trigger", player);
	level notify("jukebox_new_song");
	level.jukeboxmusicspot StopSound(alias);
	level notify("restartjukeboxes");
	//self SetHintString(namesarray[self.jukeboxindex]+" was skipped");
	thread zm_subtitles::subtitle_display(undefined, 3, "^5Jukebox", "[^3"+namesarray[self.jukeboxindex]+"^7] was skipped by ^2" + player.playername);
	level notify("chilisjjukeboxskipped");
	self.jukeboxindex = self.jukeboxindex + 1;
	wait 0.5;
	foreach(jukebox in level.jukeboxes)
	{
		jukebox thread setup_jukebox(1);
	}
}

function PlayFxWithCleanup(fx, origin, duration = 0.5)
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

function eedisallowuse(alias, namesarray, intindex, player)
{
		level endon("jukeboxsongcomplete");
		level endon("chilisjjukeboxskipped");
		level waittill("storycriteescene");
		level.jukeboxisplayingchilis = false;
		player zm_score::add_to_player_score( level.jukebox_cost );
			//jukebox SetHintString(namesarray[self.jukeboxindex]+" was skipped due to a EE moment.");
		thread zm_subtitles::subtitle_display(undefined, 3, "^5Jukebox", "[^3"+namesarray[self.jukeboxindex]+"^7] was skipped due to a EE moment.");
		PlaySoundAtPosition( "cha_ching", player.origin);
		level.jukeboxmusicspot StopSound(alias);
		level notify("restartjukeboxes");
		level notify("jukebox_new_song");
		level waittill("storycritsceneended");
		foreach(jukebox in level.jukeboxes)
			{
				jukebox thread setup_jukebox(1);
			}
}

function knifetocycle(jukeboxnotify, jukeboxnotif2, soundarray)
{
	//model = GetEnt(self.target, "targetname");
	model = self.dmgtrigger;
	//model SetCanDamage(1);
	//level endon("endknifecycle");
	level endon("end_game");
	level endon(jukeboxnotify);
	level endon(jukeboxnotif2);
	while(1)
	{
		model waittill( "damage", damage, attacker, dir, point, mod, model, tag, part, weapon, flags, inflictor, chargeLevel );
		//IPrintLnBold("dmg");
		//if(zm_utility::is_melee_weapon(weapon) && IsPlayer(attacker))
		if(zm_utility::is_melee_weapon(weapon) && mod == "MOD_MELEE" && IsPlayer(attacker))
		{
			//IPrintLnBold("Cycled song");
			PlayFxWithCleanup(level._effect["powerup_grabbed"], self.origin);
			//PlayFX(level._effect["powerup_grabbed"], self.origin); 
			model PlaySound("jbskip");
			level notify("jukebox_new_song");
			level notify("restartjukeboxes");
			self.jukeboxindex = self.jukeboxindex + 1;
			if(self.jukeboxindex > soundarray.size-1) self.jukeboxindex = 0;
			foreach(jukebox in level.jukeboxes)
			{
				jukebox thread setup_jukebox(1);
			}
			break;
		}
		else if(mod == "MOD_GRENADE_SPLASH") 
		{
			self thread knifetocycle(jukeboxnotify, jukeboxnotif2, soundarray);
			break;
		}
		wait(0.05);
	}
}


function wait_for_game_end(alias)
{
	level endon("jukebox_new_song");
	level waittill("end_game");
	level.jukeboxmusicspot StopSound(alias);
	self Delete();
}