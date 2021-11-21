#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#insert scripts\shared\shared.gsh;
#using scripts\shared\laststand_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\hud_util_shared;
#using scripts\zm\_zm_score;
#using scripts\shared\util_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_utility;
#insert scripts\zm\_zm_utility.gsh;

#insert scripts\zm\donut_monitor.gsh;
#using scripts\zm\donut_monitor_util;
#using scripts\zm\donut_monitor_ents_all;

#namespace donut_monitor;

REGISTER_SYSTEM_EX( "donut_monitor", &__init__, &__main__, undefined )

function __init__()
{
	level.monitor_config = [];

	// Starting values for configs
	level.monitor_config["wait_time"] = INIT_WAIT_MONITOR_FRAME;
	level.monitor_config["debug_render_time"] = Int(INIT_WAIT_MONITOR_FRAME * 20);
	level.monitor_config["monitor_view"] = 0;  //HIGHEST_VIEW_CASE; // set to max view case available // took out views
	level.monitor_config["show_ent_visuals"] = INIT_SHOW_VISUALS;
	level.monitor_config["show_ent_subtitles"] = INIT_SHOW_SUBTITLES;
	level.monitor_config["show_ent_tn"] = INIT_SHOW_TARGETNAME;
	level.monitor_config["show_ent_t"] = INIT_SHOW_TARGET;
	level.monitor_config["show_ent_sn"] = INIT_SHOW_SCR_NOTEWORTHY;
	level.monitor_config["show_ent_si"] = INIT_SHOW_SCR_INT;
	level.monitor_config["show_ent_sl"] = INIT_SHOW_SCR_LABEL;
	level.monitor_config["show_ent_ent"] = INIT_SHOW_ENT_ENT;
	level.monitor_config["show_zone_target"] = INIT_SHOW_ZONE_TARGET;
	level.monitor_config["show_ent_model_outline"] = INIT_SHOW_ENT_MOD_OUTLINE;

	n_radius_squared = INIT_PLAYER_DISTANCE_CHECK * INIT_PLAYER_DISTANCE_CHECK;
	level.monitor_config["player_distance_check"] = n_radius_squared;

	level.monitor_config["filters"] = [];
	level.monitor_config["filters"]["general"] = true;
	level.monitor_config["filters"]["player"] = true;
	level.monitor_config["filters"]["item"] = true;
	level.monitor_config["filters"]["scriptmover"] = true;
	level.monitor_config["filters"]["ai"] = true;
	level.monitor_config["filters"]["zbarrier"] = true;
	level.monitor_config["filters"]["trigger"] = true;
	level.monitor_config["filters"]["tempent"] = true;
	level.monitor_config["filters"]["struct"] = true;
	level.monitor_config["filters"]["unitrigger"] = true;
}

function __main__()
{
	// Thread our dvar watchers					//  Example usage:
	thread change_update_time();				// 	/modvar monitor_time 1.3
	thread toggle_ent_filters();				//  /modvar monitor_filter trigger 1
	// thread set_monitor_view();					//  /modvar monitor_view 1
	thread force_gspawn_crash();				//  /modvar monitor_gcrash 1
	thread toggle_show_ent_visuals();			// 	/modvar monitor_visuals 1
	thread toggle_show_ent_targetname();		// 	/modvar monitor_tn 1
	thread toggle_show_ent_target();			// 	/modvar monitor_t 1
	thread toggle_show_ent_scr_noteworthy();	// 	/modvar monitor_sn 1
	thread toggle_show_ent_scr_int();			// 	/modvar monitor_si 1
	thread toggle_show_ent_scr_label();			// 	/modvar monitor_sl 1
	thread toggle_show_ent_ent();				// 	/modvar monitor_ents 1
	thread toggle_show_zone_target();			// 	/modvar monitor_zt 1
	thread toggle_show_ent_mod_outline();		// 	/modvar monitor_outline_mod 1
	thread toggle_show_subtitles();				// 	/modvar monitor_subtitles 1
	thread change_player_distance_check();		// 	/modvar monitor_distance 1500
	thread give_points();						// 	/modvar dm_points all 500000
	WAIT_SERVER_FRAME;

	for(;;)
	{
		all_ents = GetEntArray();

		dm_ents_all::monitor_view_ents_all(all_ents);
		
		// User can switch between different monitor views
		//  - Add new case in this func for a new monitor view
		// 	- Set level.monitor_config["monitor_view"] to max number of cases
		// switch( level.monitor_config["monitor_view"] )
		// {
		// 	// All ent counts + classname counts
		// 	case 0:
		// 		dm_ents_all::monitor_view_ents_all(all_ents);
		// 		break;
			
		// 	// List player info only
		// 	case 1:
		// 		dm_players::monitor_view_player_info(all_ents);
		// 		break;
		// }

		wait(level.monitor_config["wait_time"]);
		dm_util::destroy_text_lines();
	}
}


/* -------------------------------------------------------------------------- */
/*                                DVAR CONFIGS                                */
/* -------------------------------------------------------------------------- */

// Template for a binary dvar
function check_binary_dvar(dvar_string, monitor_config_string)
{
	if(GetDvarString(dvar_string) != "")
	{
		string = GetDvarString(dvar_string);
		tokenized = StrTok(string, " ");
		final_int = Int(tokenized[0]);
		if(final_int > 1 || final_int < 0)
			final_int = 0;

		level.monitor_config[monitor_config_string] = final_int;
		SetDvar(dvar_string, "");

		return true;
	}
	return false;
}

// Change update time
function change_update_time()
{
	dvar_string = "monitor_time";
    for(;;)
    {
		if(GetDvarString(dvar_string) != "")
		{
			string = GetDvarString(dvar_string);
			tokenized = StrTok(string, " ");
			final_int = Float(tokenized[0]);

			// Check if valid
			if( !IsFloat(final_int) )
			{
				SetDvar(dvar_string, "");
				continue;
			}

			if(final_int < 0.05)
				final_int = 0.05;
			else if(final_int > 30)
				final_int = 30;

			level.monitor_config["wait_time"] = final_int;
			level.monitor_config["debug_render_time"] = Int(final_int * 20);
			SetDvar(dvar_string, "");

			IPrintLnBold("Set monitor update time: "+ level.monitor_config["wait_time"]);
		}
        WAIT_SERVER_FRAME;
    }
}


// Toggle all ent filters
function toggle_ent_filters()
{
	dvar_string = "monitor_filter";
    for(;;)
    {
		if(GetDvarString(dvar_string) != "")
		{
			string = GetDvarString(dvar_string);
			tokenized = StrTok(string, " ");
			input_group = ToLower(tokenized[0]);
			final_int = Int(tokenized[1]);

			// Check if valid
			if( !isdefined(level.monitor_config["filters"][input_group]) || !IsInt(final_int) )
			{
				SetDvar(dvar_string, "");
				continue;
			}

			if(final_int > 1 || final_int < 0)
				final_int = 0;

			level.monitor_config["filters"][input_group] = final_int;
			SetDvar(dvar_string, "");

			IPrintLnBold("Set monitor filter for ent group: " + input_group + ": "+ level.monitor_config["filters"][input_group]);
		}
        WAIT_SERVER_FRAME;
    }
}


// User sets a specific view
// 	- See all monitor_views defined at top
function set_monitor_view()
{
	max_monitor_view = level.monitor_config["monitor_view"];
	view_start = INIT_VIEW_CASE;
	if(view_start > HIGHEST_VIEW_CASE)
		view_start = HIGHEST_VIEW_CASE;
	level.monitor_config["monitor_view"] = view_start;
    for(;;)
    {
        if(GetDvarString("monitor_view") != "")
        {
            string = GetDvarString("monitor_view");
            tokenized = StrTok(string, " ");
            mon_view = Int(tokenized[0]);
			if(mon_view > max_monitor_view || mon_view < 0)
				mon_view = 0;

			level.monitor_config["monitor_view"] = mon_view;
			SetDvar("monitor_view", "");
			IPrintLnBold("Set monitor type: " + level.monitor_config["monitor_view"]);
        }
        WAIT_SERVER_FRAME;
    }
}

// Toggle debug visuals (spheres, boxes, names)
function toggle_show_ent_visuals()
{
    for(;;)
    {
		if( check_binary_dvar("monitor_visuals", "show_ent_visuals") )
			IPrintLnBold("Set monitor visuals: " + level.monitor_config["show_ent_visuals"]);
        WAIT_SERVER_FRAME;
    }
}

// Forces a g_spawn crash to print out all ents in the logfile
// 	- Must have /developer 2 & /logfile 1
function force_gspawn_crash()
{
    for(;;)
    {
        if(GetDvarString("monitor_gcrash") != "")
        {
            string = GetDvarString("monitor_gcrash");
            tokenized = StrTok(string, " ");
            input_int = Int(tokenized[0]);
			if(input_int > 0)
			{
				IPrintLnBold("Forcing a g_spawn crash in 5 seconds. Enable developer 2 & logfile 1 to see complete ent list...");
				wait(5);
				spawned_count = 0;
				while(1)
				{
					PlaySoundAtPosition("zmb_laugh_child", (0,0,0));
					PlayFX( level._effect["poltergeist"], (0,0,0) );
					spawned_count += 2;
					IPrintLnBold("G_spawn force count: "+ spawned_count);
					wait(0);
				}
			}
			SetDvar("monitor_gcrash", "");
        }
        WAIT_SERVER_FRAME;
    }
}

// Toggle debug to show targetnames
function toggle_show_ent_targetname()
{
    for(;;)
    {
		if( check_binary_dvar("monitor_tn", "show_ent_tn") )
			IPrintLnBold("Set monitor visual targetname: " + level.monitor_config["show_ent_tn"]);
        WAIT_SERVER_FRAME;
    }
}

// Toggle debug to show targets
function toggle_show_ent_target()
{
    for(;;)
    {
		if( check_binary_dvar("monitor_t", "show_ent_t") )
			IPrintLnBold("Set monitor visual target: " + level.monitor_config["show_ent_t"]);
        WAIT_SERVER_FRAME;
    }
}

// Toggle debug to show script noteworthy
function toggle_show_ent_scr_noteworthy()
{
    for(;;)
    {
		if( check_binary_dvar("monitor_sn", "show_ent_sn") )
			IPrintLnBold("Set monitor visual script_noteworthy: " + level.monitor_config["show_ent_sn"]);
        WAIT_SERVER_FRAME;
    }
}

// Toggle debug to show script int
function toggle_show_ent_scr_int()
{
    for(;;)
    {
		if( check_binary_dvar("monitor_si", "show_ent_si") )
			IPrintLnBold("Set monitor visual script_int: " + level.monitor_config["show_ent_si"]);
        WAIT_SERVER_FRAME;
    }
}

// Toggle debug to show script label
function toggle_show_ent_scr_label()
{
    for(;;)
    {
		if( check_binary_dvar("monitor_sl", "show_ent_sl") )
			IPrintLnBold("Set monitor visual script_label: " + level.monitor_config["show_ent_sl"]);
        WAIT_SERVER_FRAME;
    }
}

// Toggle debug to show & outline ents
function toggle_show_ent_ent()
{
    for(;;)
    {
		if( check_binary_dvar("monitor_ents", "show_ent_ent") )
			IPrintLnBold("Set monitor visual ents: " + level.monitor_config["show_ent_ent"]);
        WAIT_SERVER_FRAME;
    }
}

// Toggle debug to show zone targets to spawners & such
function toggle_show_zone_target()
{
    for(;;)
    {
		if( check_binary_dvar("monitor_zt", "show_zone_target") )
			IPrintLnBold("Set monitor visual zone targets: " + level.monitor_config["show_zone_target"]);
        WAIT_SERVER_FRAME;
    }
}

// Toggle debug to show outlines for script_models
function toggle_show_ent_mod_outline()
{
    for(;;)
    {
		if( check_binary_dvar("monitor_outline_mod", "show_ent_model_outline") )
			IPrintLnBold("Set monitor visual script_model outlines: " + level.monitor_config["show_ent_model_outline"]);
        WAIT_SERVER_FRAME;
    }
}

// Toggle debug to show all subtitles on ents
function toggle_show_subtitles()
{
    for(;;)
    {
		if( check_binary_dvar("monitor_subtitles", "show_ent_subtitles") )
			IPrintLnBold("Set monitor visual subtitles: " + level.monitor_config["show_ent_subtitles"]);
        WAIT_SERVER_FRAME;
    }
}

// Change distance shit renders in from player
function change_player_distance_check()
{
    dvar_string = "monitor_distance";
    for(;;)
    {
		if(GetDvarString(dvar_string) != "")
		{
			string = GetDvarString(dvar_string);
			tokenized = StrTok(string, " ");
			final_int = Int(tokenized[0]);

			// Check if valid
			if( !IsInt(final_int) )
			{
				SetDvar(dvar_string, "");
				continue;
			}

			if(final_int < 0)
				final_int = 0;
			else if(final_int > 1000000)
				final_int = 1000000;

			n_radius_squared = final_int * final_int;

			level.monitor_config["player_distance_check"] = n_radius_squared;
			SetDvar(dvar_string, "");

			IPrintLnBold("Set monitor distance check from host player: "+ final_int);
		}
        WAIT_SERVER_FRAME;
    }
}


function give_points()
{
	dvar_string = "dm_points";
    for(;;)
    {
        if(GetDvarString("dm_points") != "")
        {
            string = GetDvarString("dm_points");
            tokenized = StrTok(string, " ");
            index = Int(tokenized[1]);
            playername = ToLower(tokenized[0]);

            players = GetPlayers();
            foreach(player in players)
            {
                if (ToLower(player.name) == playername){
                    player zm_score::add_to_player_score( index );
                    zm_utility::play_sound_at_pos( "purchase", player.origin );
                    IPrintLnBold("Gave player " + playername + " " + index + " points with dm dvar!");
                }
            }
            if (ToLower(playername) == "all"){
                foreach(player in players){
                    player zm_score::add_to_player_score( index );
                    zm_utility::play_sound_at_pos( "purchase", player.origin );
                    IPrintLnBold("Gave all players " + index + " points with dm dvar!");
                }
            }

            SetDvar("dm_points", "");
        } 
        WAIT_SERVER_FRAME;
    }

}