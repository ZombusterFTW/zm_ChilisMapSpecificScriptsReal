// Credits:

// Scobalula 
// Symbo


//-----------------------CHANGE THE VALUES TO YOUR NEEDS-----------------------------

// NOTES: Some of these values are defaults ones in case no kvps overrides them.
//        So each zipline and sewer can have its own price, speed, thirdperson view enable or disable.

#define ZIPLINE_COST									250 // default zipline cost, can be override with "zombie_cost" kvp on the struct with the pannel model assign.
#define ZIPLINE_SPEED									15 // default zipline speed, can be override with "speed" kvp on the struct with the pannel model assign.
#define SEWER_COST										500 // default sewer cost, can be override with "zombie_cost" kvp on the struct with the pannel model assign.
#define SEWER_SPEED										20 // default sewer speed, can be override with "speed" kvp on the struct with the pannel model assign.
#define WAIT_FOR_POWER									true // true or false, can NOT be override trough kvps.
#define THIRD_PERSON 									false // set to true if you want to be in thirdperson view while traveling, can be override with "script_special" kvp on the struct, and true/false as value.
#define SEWER_CURRENT_FX 								"debris/fx_debris_underwater_current_sgen_os" // if you want a different fx for the sewer, change it there and load it in zone: fx,fx_path.

#define ZIPLINE_LAST_NODE_RADIUS						180 // this is more technical. the elements of the opposite side of a zipline are grab with the last node, the closest struct within this radius will be chosen.
#define SEWER_LAST_NODE_RADIUS							280 // same as above