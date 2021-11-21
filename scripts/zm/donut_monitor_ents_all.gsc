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

#namespace dm_ents_all;

REGISTER_SYSTEM_EX( "dm_ents_all", &__init__, &__main__, "donut_monitor" )

function __init__()
{
	// Starting values for configs
	level.monitor_config["min_val"] = INIT_MIN_VAL;
}

function __main__()
{
	// Thread our dvar watchers			//  Example usage:
	thread set_min_count_for_list(); 	//  /modvar monitor_min 3
}


/* -------------------------------------------------------------------------- */
/*                                MONITOR VIEWS                               */
/* -------------------------------------------------------------------------- */

/* -------------------- All ent counts + classname counts ------------------- */
function monitor_view_ents_all(all_ents)
{
	dm_util::make_text_line("All Entities: ^3"+all_ents.size);
	classname_count = [];
	all_triggers = [];
	players = GetPlayers();

	// Normal Ents
	if(level.monitor_config["show_ent_ent"])
	{
		foreach( ent in all_ents )
		{
			enttype_info = ent get_enttype_info();

			// Triggers dont count toward ent limit apparently
			if(enttype_info["is_trigger"])
				all_triggers[all_triggers.size] = ent;

			// Check if it's being filtered rn
			filter_status = level.monitor_config["filters"][enttype_info["group"]];
			if( isdefined(filter_status) && !filter_status )
				continue;

			if( isdefined( classname_count[ent.classname] ) )
				classname_count[ent.classname]++;
			else
				classname_count[ent.classname] = 1;

			// check if in distance of player
			if( level.monitor_config["player_distance_check"] && (isdefined(ent) && isdefined(ent.origin)) && (isdefined(players[0]) && isdefined(players[0].origin)) )
			{
				if( DistanceSquared( ent.origin, players[0].origin ) > level.monitor_config["player_distance_check"] )
					continue;
			}

			ent_config = ent get_ent_classname_config(enttype_info);
			dm_util::show_ent_visual(ent, ent_config);
		}
	}

	// Structs
	if(level.monitor_config["filters"]["struct"])
	{
		foreach(ent_struct in level.struct)
		{
			if( isdefined( classname_count["struct"] ) )
				classname_count["struct"]++;
			else
				classname_count["struct"] = 1;

			// check if in distance of player
			if( level.monitor_config["player_distance_check"] && (isdefined(ent_struct) && isdefined(ent_struct.origin)) && (isdefined(players[0]) && isdefined(players[0].origin)) )
			{
				if( DistanceSquared( ent_struct.origin, players[0].origin ) > level.monitor_config["player_distance_check"] )
					continue;
			}
			
			enttype_info = ent_struct get_enttype_info("struct");
			ent_config = ent_struct get_ent_classname_config(enttype_info, "struct");
			dm_util::show_ent_visual(ent_struct, ent_config);
		}
	}

	// Unitriggers
	if(level.monitor_config["filters"]["unitrigger"])
	{
		foreach(ent_unitrigger in level._unitriggers.trigger_stubs)
		{
			if( isdefined( classname_count["unitrigger"] ) )
				classname_count["unitrigger"]++;
			else
				classname_count["unitrigger"] = 1;

			// check if in distance of player
			if( level.monitor_config["player_distance_check"] && (isdefined(ent_unitrigger) && isdefined(ent_unitrigger.origin)) && (isdefined(players[0]) && isdefined(players[0].origin)) )
			{
				if( DistanceSquared( ent_unitrigger.origin, players[0].origin ) > level.monitor_config["player_distance_check"] )
					continue;
			}
			
			enttype_info = ent_unitrigger get_enttype_info("unitrigger");
			ent_config = ent_unitrigger get_ent_classname_config(enttype_info, ent_unitrigger.script_unitrigger_type);
			dm_util::show_ent_visual(ent_unitrigger, ent_config);
		}
	}

	dm_util::make_text_line("Non-Trigger Entities: ^3"+ (all_ents.size - all_triggers.size), true );
	// dm_util::make_text_line("Unique Classnames: ^3"+classname_count.size, true);

	foreach( classname, ent_count in classname_count )
	{
		if( !IsSubStr( classname, "weapon_") && (ent_count >= level.monitor_config["min_val"]) )
			dm_util::make_text_line( classname+": ^3"+ ent_count );
	}
}


// self = ent
function get_enttype_info(special)
{
	enttype_info = [];
	enttype_info["group"] = "other"; // ai, triggers, tempents, etc
	enttype_info["color"] = WHITE;
	enttype_info["force_classname"] = undefined; // used for tempents "TempSound", "TempFX", etc
	enttype_info["is_trigger"] = false;

	// Special cases
	if(isdefined(special))
	{
		switch(special)
		{
			case "struct":
			{
				enttype_info["group"] = "struct";
				enttype_info["color"] = GRAY5;
				enttype_info["force_classname"] = "struct";
				return enttype_info;
			}
			case "unitrigger":
			{
				enttype_info["group"] = "unitrigger";
				enttype_info["color"] = GRAY2;
				enttype_info["force_classname"] = "unitrigger";
				return enttype_info;
			}
			default:
				break;
		}
	}

	enttype = self GetEntityType();

	switch(enttype)
	{
		case ET_GENERAL:
		{
			enttype_info["group"] = "general";
			enttype_info["color"] = PURPLE;
			break;
		}
		case ET_PLAYER:
		case ET_PLAYER_CORPSE:
		case ET_PLAYER_INVISIBLE:
		{
			enttype_info["group"] = "player";
			enttype_info["color"] = CYAN;
			break;
		}
		case ET_ITEM:
		{
			enttype_info["group"] = "item";
			enttype_info["color"] = BROWN;
			break;
		}
		case ET_SCRIPTMOVER:
		{
			enttype_info["group"] = "scriptmover";
			enttype_info["color"] = YELLOW;
			break;
		}
		case ET_ACTOR:
		case ET_ACTOR_SPAWNER:
		case ET_ACTOR_CORPSE:
		{
			enttype_info["group"] = "ai";
			enttype_info["color"] = ORANGE;
			break;
		}
		case ET_ZBARRIER:
		{
			enttype_info["group"] = "zbarrier";
			enttype_info["color"] = OLIVE;
			break;
		}
		case ET_TRIGGER:
		{
			enttype_info["group"] = "trigger";
			enttype_info["color"] = GREEN;
			enttype_info["is_trigger"] = true;
			break;
		}
		case ET_TEMP_SOUND_INT:
		{
			enttype_info["group"] = "tempent";
			enttype_info["color"] = RED;
			enttype_info["force_classname"] = ET_TEMP_SOUND_NAME;
			break;
		}
		case ET_TEMP_FX_INT:
		{
			enttype_info["group"] = "tempent";
			enttype_info["color"] = BLUE;
			enttype_info["force_classname"] = ET_TEMP_FX_NAME;
			break;
		}
		default:
			break;
	}

	return enttype_info;
}


// self = ent
function get_ent_classname_config(enttype_info, debug_name)
{
	if(!isdefined(debug_name))
		debug_name = self.classname;
	debug_shape = "sphere";
	debug_radius = 5;
	debug_targ_lines = true;

	switch(debug_name)
	{
		case "script_model":
		case "script_origin":
		case "script_brushmodel":
		{
			if(level.monitor_config["show_ent_model_outline"])
				debug_shape = "box";
			break;
		}
		case "info_player_start":
		case "volume_weathergrime":
		case "volume_outdoor":
		case "volume_sun":
		case "volume_litfog":
		case "volume_worldfog":
		case "trigger_use":
		case "trigger_multiple":
		case "trigger_use_touch":
		case "trigger_damage":
		case "trigger_box":
		{
			debug_shape = "box";
			break;
		}
		case "trigger_radius":
		case "trigger_radius_use":
		{
			if(isdefined(self.radius))
				debug_radius = self.radius;
			break;
		}
		case "info_volume":
		{
			if( !level.monitor_config["show_zone_target"] )
				debug_targ_lines = false;
			debug_shape = "box";
			break;
		}
		case "struct":
		{
			debug_shape = "struct";
			break;
		}
		case "unitrigger_radius":
		case "unitrigger_radius_use":
		{
			debug_shape = "sphere";
			// if(isdefined(self.radius))
			debug_radius = 2;
			break;
		}
		case "unitrigger_box":
		case "unitrigger_box_use":
		{
			debug_shape = "sphere";
			break;
		}
		default:
		{
			break;
		}
	}

	if(isdefined(enttype_info["force_classname"]))
		debug_name = enttype_info["force_classname"];

	// Check and get target(s) of ent
	all_targs = [];
	if( isdefined(self.target) )
	{
		targ_ents = GetEntArray(self.target, "targetname");
		foreach(t_ent in targ_ents)
			all_targs[all_targs.size] = t_ent;

		targ_structs = struct::get_array(self.target);
		foreach(t_struct in targ_structs)
			all_targs[all_targs.size] = t_struct;
	}
	if(all_targs.size == 0)
		all_targs = undefined;

	return dm_util::get_ent_debug_config(debug_name, enttype_info["color"], debug_shape, debug_radius, self get_ent_subtitle(all_targs), all_targs, debug_targ_lines);
}


// self = ent
function get_ent_subtitle(all_targs)
{
	if(!level.monitor_config["show_ent_subtitles"])
		return undefined;

	subtitle = undefined;

	// targetname
	if( isdefined(self.targetname) && level.monitor_config["show_ent_tn"] )
	{
		subtitle = "TN: "+ self.targetname;
	}
	// target
	if( isdefined(self.target) && level.monitor_config["show_ent_t"] )
	{
		if(!isdefined(subtitle))
		{
			if(isdefined(all_targs))
				subtitle = "T: "+ self.target +" {"+all_targs.size+"}";
			else
				subtitle = "T: "+ self.target;
		}
		else
		{
			if(isdefined(all_targs))
				subtitle = subtitle +"\nT: "+ self.target +" {"+all_targs.size+"}";
			else
				subtitle = subtitle +"\nT: "+ self.target;
		}
	}
	// script_noteworthy
	if( isdefined(self.script_noteworthy) && level.monitor_config["show_ent_sn"] )
	{
		if(!isdefined(subtitle))
			subtitle = "SN: "+ self.script_noteworthy;
		else subtitle = subtitle +"\nSN: "+ self.script_noteworthy;
	}
	// script_int
	if( isdefined(self.script_int) && level.monitor_config["show_ent_si"] )
	{
		if(!isdefined(subtitle))
			subtitle = "SI: "+ self.script_int;
		else subtitle = subtitle +"\nSI: "+ self.script_int;
	}
	// script_label
	if( isdefined(self.script_label) && level.monitor_config["show_ent_sl"] )
	{
		if(!isdefined(subtitle))
			subtitle = "SL: "+ self.script_label;
		else subtitle = subtitle +"\nSL: "+ self.script_label;
	}

	return subtitle;
}


/* -------------------------------------------------------------------------- */
/*                                DVAR CONFIGS                                */
/* -------------------------------------------------------------------------- */

// Set minimum count a classname should have before showing on screen
function set_min_count_for_list()
{
    for(;;)
    {
        if(GetDvarString("monitor_min") != "")
        {
            string = GetDvarString("monitor_min");
            tokenized = StrTok(string, " ");
            min_val = Int(tokenized[0]);
			if(min_val < 0)
				min_val = 0;

			level.monitor_config["min_val"] = min_val;
			IPrintLnBold("Set monitor minimum ent count: " + min_val);

            SetDvar("monitor_min", "");
        } 
        WAIT_SERVER_FRAME;
    }
}
