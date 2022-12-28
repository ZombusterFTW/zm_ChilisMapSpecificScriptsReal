#using scripts\codescripts\struct; 
#using scripts\shared\system_shared; 
#using scripts\shared\array_shared; 
#using scripts\shared\vehicle_shared; 
#using scripts\zm\_zm_score;
#using scripts\shared\flag_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared; 
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\scene_shared;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\shared\_burnplayer;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai_shared;
#insert scripts\shared\shared.gsh;


#using_animtree("generic");

#namespace floating_debris; // HARRY COMMENT

REGISTER_SYSTEM_EX( "floating_debris", &__init__, &__main__, undefined ) // HARRY COMMENT

function __init__()
{
    
}

function __main__()
{
	
	debris = GetEntArray("floating_debris","targetname");	
		foreach(debri in debris)
			debri thread doors_open();	

}

function doors_open()
{
	self useanimtree(#animtree);
	self AnimScripted( "optionalNotify", self.origin , self.angles, %idle_debris_anim);
	origin = self.origin;
	trig = GetEnt(self.target,"targetname");
	clip = GetEnt(trig.target, "targetname");
	trig SetCursorHint("HINT_NOICON");
	while( 1 )
	{
		trig SetHintString("Press &&1 to open the door [Cost: "+trig.zombie_cost + "]");
		trig waittill("trigger", player);
			if(player.score >= trig.zombie_cost)
				{
					PlaySoundAtPosition(trig.script_sound,origin);
					PlayFX( level._effect["poltergeist"], origin );
					self AnimScripted( "optionalNotify", self.origin , self.angles, %rise_debris_anim);
					trig Delete();
					clip Delete();
					level flag::set(trig.script_flag);
					wait 2;
					self Delete();
					break;
				}

			 else
                {
                    score_left = trig.zombie_cost - player.score;
                    self SetHintString("Damnit " +player.name+"! you are missing " +score_left+ " points");
                    wait 1.5;
                }
	}
		
}