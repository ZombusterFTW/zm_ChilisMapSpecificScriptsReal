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



#define WAIT_FOR_POWER 1				//wait for power to be on
#define OVERRIDE_MUS_SYSTEM 1			//stops round music

#define TRIGGER_WIDTH 64				//radius of jukebox trigger
#define TRIGGER_HEIGHT 32				//height of jukebox trigger




//		DON'T TOUCH ANYTHING UNDER HERE
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

REGISTER_SYSTEM( "jukebox", &__init__, undefined )
//don't touch

#precache( "lui_menu", "JukeboxMenu");
#precache( "eventstring", "JukeboxSongs" );


function __init__()
{
//clientfield::register("world", "jukebox_counter", VERSION_SHIP, 1, "counter");

level waittill("all_players_connected");
GetPlayers()[0] OpenMenu("JukeboxMenu");
wait 0.5;
GetPlayers()[0] CloseMenu("JukeboxMenu");

level.jukebox_songs = array();
level.jukebox_titles = array();
level.jukebox_songs_3d = array();
level.jukebox_titles_3d = array();
level.jukebox_cost = 500; 

//register_jukebox_songs();
//send_jukebox_songs_to_lua();
jukeboxes = GetEntArray("jukebox", "targetname");
foreach(box in jukeboxes)
	box thread setup_jukebox();
}



function setup_jukebox()
{

mode = "2d"; //why cant do 3d = 0;?
if(isdefined(self.script_noteworthy) && self.script_noteworthy == "3d")
	mode = "3d";

cost = 0;
if(isdefined(self.zombie_cost))
	cost = self.zombie_cost;

trig = Spawn("trigger_radius_use", self.origin, 0, TRIGGER_WIDTH, TRIGGER_HEIGHT);
trig SetCursorHint("HINT_NOICON");
trig SetTeamForTrigger("allies");
trig SetHintString(&"ZOMBIE_NEED_POWER");


if(WAIT_FOR_POWER)
	level flag::wait_till("power_on");


trig SetHintString("Press ^3[{+activate}]^7 to activate jukebox");
if(cost != 0)
	trig SetHintString("Press ^3[{+activate}]^7 to activate jukebox. Cost: ["+cost+"] COPYRIGHT WARNING");

jukebox_sound_ent = Spawn("script_origin", (0,0,0));
old_snd = "";

while(1)
	{
	trig TriggerEnable(1);
	trig waittill("trigger", player);
if( isDefined(level.jukebox_cost) && player.score >= level.jukebox_cost )
				{
					player zm_score::minus_to_player_score( level.jukebox_cost );
					PlaySoundAtPosition( "cha_ching", trig.origin);
					trig TriggerEnable(0); //stop other nibbas
					player OpenMenu("JukeboxMenu");
					player waittill("menuresponse", menu, response);
					//IPrintLnBold(response);
if(response == "X")
{
	player zm_score::add_to_player_score( level.jukebox_cost );
	PlaySoundAtPosition( "cha_ching", trig.origin);
	continue;
}
	if(response != "X")
		{
		if(mode == "3d")
			{
			self StopSounds();
			wait 1;
			self PlaySound(response);
			}
		else
			{
			if(response == "Stop")
				{
				if(isdefined(jukebox_sound_ent))
					{
					foreach(player in GetPlayers())
						player StopLocalSound(old_snd);
					jukebox_sound_ent Delete();
					level.musicSystemOverride = 0;
					}
					trig TriggerEnable(1);
					player zm_score::add_to_player_score( level.jukebox_cost );
					continue; 
				}
				else if( isDefined( level.jukeboxcost ) && player.score < level.jukebox_cost )
				{
					PlaySoundAtPosition( "nsz_deny", trig.origin);
					trig TriggerEnable(1); 
					wait(1); 
					continue; 
				}

	
		}


			level zm_audio::sndMusicSystem_StopAndFlush();
			if(isdefined(jukebox_sound_ent))
				{
				//jukebox_sound_ent StopSounds();
				foreach(player in GetPlayers())
					player StopLocalSound(old_snd);
				jukebox_sound_ent Delete();
				}

			if(OVERRIDE_MUS_SYSTEM)
				level.musicSystemOverride = 1;
			level notify("jukebox_new_song");
			
			jukebox_sound_ent = Spawn("script_origin", (0,0,0));

			foreach(player in GetPlayers())
				player PlayLocalSound(response);
			old_snd = response;

			//jukebox_sound_ent PlaySoundOnTag(response, "tag_origin");
			jukebox_sound_ent thread wait_for_song_end(response);
			jukebox_sound_ent thread wait_for_game_end(response);
			}
		}

	
	}

}


function wait_for_song_end(alias)
{
level endon("jukebox_new_song");
pbtime = SoundGetPlaybackTime(alias)*0.001;
wait(pbtime);
if(OVERRIDE_MUS_SYSTEM)
	level.musicSystemOverride = 0;
}



function wait_for_game_end(alias)
{
level endon("jukebox_new_song");

level waittill("end_game");
foreach(player in GetPlayers())
	player StopLocalSound(alias);
self Delete();
}