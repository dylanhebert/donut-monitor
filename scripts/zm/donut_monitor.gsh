
#define INIT_WAIT_MONITOR_FRAME			0.5
#define INIT_VIEW_CASE				    0
#define INIT_MIN_VAL				    2
#define INIT_SHOW_VISUALS			    true
#define INIT_SHOW_SUBTITLES		        true
#define INIT_SHOW_TARGETNAME		    true
#define INIT_SHOW_TARGET		        true
#define INIT_SHOW_SCR_NOTEWORTHY		true
#define INIT_SHOW_SCR_INT		        true
#define INIT_SHOW_SCR_LABEL		        true
#define INIT_SHOW_ENT_STRUCT		    true
#define INIT_SHOW_ENT_ENT		        true
#define INIT_SHOW_ZONE_TARGET		    false
#define INIT_SHOW_ENT_MOD_OUTLINE		true
#define INIT_PLAYER_DISTANCE_CHECK		1000

#define HIGHEST_VIEW_CASE			    1

#define SPHERE_RADIUS_TEMPENT		    5
#define DEBUG_TEXT_SCALE_TITLE		    0.20
#define DEBUG_TEXT_SCALE_SUBTITLE	    0.10
#define DEBUG_TEXT_HEIGHT_TITLE		    16
#define DEBUG_TEXT_HEIGHT_SUBTITLE		13
#define DEBUG_STRUCT_BOX_SCALE		    5

#define GET_SPHERE_SIDES(__i) (Int(10 * ( 1 + Int(__i) % 100 )))

//// ENT DEBUG CONFIGS ////
// Classnames
#define CN_PLAYER_COLOR             ( 0, 1, 1 ) // CYAN
#define CN_PLAYER_RADIUS            5
#define CN_GROUP_AI_COLOR           ( 1, .5, 0 ) // ORANGE
#define CN_GROUP_AI_RADIUS          5
#define CN_GROUP_TRIGS_COLOR        ( 0.75, 0.75, 0.75 ) // GREY
#define CN_GROUP_TRIGS_RADIUS       5

// Entity types
#define ET_TEMP_SOUND_INT			28
#define ET_TEMP_SOUND_NAME          "TempSound"
#define ET_TEMP_SOUND_COLOR         ( 1, 0, 0 ) // RED
#define ET_TEMP_SOUND_RADIUS        5
#define ET_TEMP_FX_INT				119
#define ET_TEMP_FX_NAME             "TempFX"
#define ET_TEMP_FX_COLOR            ( 0, 0, 1 ) // BLUE
#define ET_TEMP_FX_RADIUS           5


