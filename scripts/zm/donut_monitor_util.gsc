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

#namespace dm_util;

REGISTER_SYSTEM_EX( "dm_util", &__init__, &__main__, "donut_monitor" )

function __init__()
{
	level.monitor_hud = [];
}

function __main__()
{
}


/* -------------------------------------------------------------------------- */
/*                         HUD ELEMENT HANDLING FUNCS                         */
/* -------------------------------------------------------------------------- */

function make_text_line( text_to_set, pad_after = false )
{
	line_difference = 8;
	index = level.monitor_hud.size;
	if(index <= 0)
		prev_y = -440;
	else
	{
		prev_y = level.monitor_hud[index-1].y;
		if( IS_TRUE(level.monitor_hud[index-1].pad_after) )
			prev_y += 5;
	}

	level.monitor_hud[index] = NewHudElem();
	level.monitor_hud[index].x = 15;
	level.monitor_hud[index].y = (prev_y + line_difference);
	level.monitor_hud[index].alignX = "left";
	level.monitor_hud[index].alignY = "bottom";
	level.monitor_hud[index].horzAlign = "left";
	level.monitor_hud[index].vertAlign = "bottom";
	level.monitor_hud[index].foreground = 1;
	level.monitor_hud[index].fontscale = 1;
	level.monitor_hud[index].alpha = 1;
	if(pad_after)
		level.monitor_hud[index].pad_after = true;

	level.monitor_hud[index] SetText( text_to_set );
}


function destroy_text_lines()
{
	foreach(line in level.monitor_hud)
	{
		line Destroy();
	}
	level.monitor_hud = [];
}


/* -------------------------------------------------------------------------- */
/*                                 UTIL FUNCS                                 */
/* -------------------------------------------------------------------------- */

function combine_ent_info(info_arr)
{
	all_info_str = "";
	
	foreach( title, value in info_arr )
	{
		new_str = create_ent_info_str(title, value);

		if(all_info_str == "")
			all_info_str = new_str;
		else
			all_info_str = all_info_str+ ", " +new_str;
	}

	return all_info_str;
}

function create_ent_info_str(title, value)
{
	if(!isdefined(value))
		new_str = "UNDEFINED";
	else
	{
		new_str = "" + value;
		if(new_str == "")
			new_str = "EMPTY_STR";
	}
	if( !isdefined(title) || (IsInt(title) && title == 0) ) // if name is 0 dont put anything, should only be one like this in array
		return new_str;
	else
		return title +": "+ new_str;
}


// 	- combine ent settings based on optional ent_group parameter
function get_ent_debug_config(ent_title, ent_color, ent_shape, ent_radius, ent_subtitle, ent_targets, ent_target_lines)
{
	if(!isdefined(ent_color))
		ent_color = (1,1,1);
	if(!isdefined(ent_shape))
		ent_shape = "sphere";
	if(!isdefined(ent_radius))
		ent_radius = 5;
	if(!isdefined(ent_target_lines))
		ent_radius = true;

	ent_config = [];
	ent_config[0] = ent_title+"";		// name
	ent_config[1] = ent_color;			// color
	ent_config[2] = ent_shape;			// debug shape
	ent_config[3] = ent_radius;			// radius
	ent_config[4] = ent_subtitle;		// usually targetname
	ent_config[5] = ent_targets;		// array of other ents/structs to draw lines to
	ent_config[6] = ent_target_lines;	// t/f if line should be drawn to target(s)

	return ent_config;
}


function show_ent_visual(ent, ent_config)
{
	if( level.monitor_config["show_ent_visuals"] )
	{
		render_time = level.monitor_config["debug_render_time"];
		// Show 3D text above ent
		/# print3d( ent.origin + vectorscale((0, 0, 1), DEBUG_TEXT_HEIGHT_TITLE), ent_config[0], ent_config[1], 1, DEBUG_TEXT_SCALE_TITLE, render_time ); #/
		// Show smaller targetname if applicable
		if( isdefined(ent_config[4]) )
			/# print3d( ent.origin + vectorscale((0, 0, 1), DEBUG_TEXT_HEIGHT_SUBTITLE), ent_config[4], GRAY3, 1, DEBUG_TEXT_SCALE_SUBTITLE, render_time ); #/

		switch(ent_config[2])
		{
			case "sphere":
				/# sphere( ent.origin, ent_config[3], ent_config[1], 0.05, true, GET_SPHERE_SIDES(ent_config[3]), render_time ); #/
				break;
			case "box":
				/# box( ent.origin, ent GetMins(), ent GetMaxs(), ent.angles[1], ent_config[1], 0.25, 1, render_time ); #/
				break;
			case "struct":
				/# box( ent.origin, vectorscale((-1, -1, -1), DEBUG_STRUCT_BOX_SCALE), vectorscale((1, 1, 1), DEBUG_STRUCT_BOX_SCALE), 0, ent_config[1], 0.25, 1, render_time ); #/
				break;
			default:
				/# sphere( ent.origin, ent_config[3], ent_config[1], 0.05, true, GET_SPHERE_SIDES(ent_config[3]), render_time ); #/
				break;
		}

		// Draw a line to ent's target if applicable
		if( level.monitor_config["show_ent_t"] && ent_config[6] && isdefined(ent_config[5]) )
		{
			foreach(targ in ent_config[5])
			{
				if(isdefined(targ.origin))
					/# line(ent.origin + (0,0,1), targ.origin, ent_config[1], 1, true, render_time); #/
			}
		}
	}
}

function darken_debug_text(original_color)
{

}


function drawcylinder(pos, rad, height)
{
	/#
		time = 0;
		while(true)
		{
			currad = rad;
			curheight = height;
			if(time < level.teargasfillduration)
			{
				currad = currad * time / level.teargasfillduration;
				curheight = curheight * time / level.teargasfillduration;
			}
			for(r = 0; r < 20; r++)
			{
				theta = r / 20 * 360;
				theta2 = r + 1 / 20 * 360;
				line(pos + (cos(theta) * currad, sin(theta) * currad, 0), pos + (cos(theta2) * currad, sin(theta2) * currad, 0));
				line(pos + (cos(theta) * currad, sin(theta) * currad, curheight), pos + (cos(theta2) * currad, sin(theta2) * currad, curheight));
				line(pos + (cos(theta) * currad, sin(theta) * currad, 0), pos + (cos(theta) * currad, sin(theta) * currad, curheight));
			}
			time = time + 0.05;
			if(time > level.teargasduration)
			{
				break;
			}
			wait(0.05);
		}
	#/
}

/* -------------------------------------------------------------------------- */
/*                                 MISC NOTES                                 */
/* -------------------------------------------------------------------------- */
	// info_arr[info_arr.size] = add_to_build_str("EntType", ent GetEntityType());
	// info_arr[info_arr.size] = add_to_build_str("EventID", ent GetCurrentEventId());
	// info_arr[info_arr.size] = add_to_build_str("EventType", ent GetCurrentEventType());
	// info_arr[info_arr.size] = add_to_build_str("EventName", ent GetCurrentEventName());
	// info_arr[info_arr.size] = add_to_build_str("EventTypeName", ent GetCurrentEventTypeName());
	// info_arr[info_arr.size] = add_to_build_str("EventOrig", ent GetCurrentEventOriginator());
