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

#namespace dm_players;

REGISTER_SYSTEM_EX( "dm_players", &__init__, &__main__, "donut_monitor" )

function __init__()
{
}

function __main__()
{
}


/* -------------------------------------------------------------------------- */
/*                                MONITOR VIEWS                               */
/* -------------------------------------------------------------------------- */

function monitor_view_player_info(all_ents)
{
	dm_util::make_text_line("All Entities: ^3"+all_ents.size);
	ent_count = [];
	all_players = GetPlayers();

	foreach( player in all_players )
	{
		info_str = dm_util::combine_ent_info(player generate_player_info_kvps());
		ent_count[ent_count.size] = info_str;

		ent_config = dm_util::get_ent_debug_config(player.name, CN_PLAYER_COLOR);
		dm_util::show_ent_visual(player, ent_config);
	}

	dm_util::make_text_line("All Players: ^3"+ent_count.size, true);

	foreach( ent_num, ent_name in ent_count )
	{
		dm_util::make_text_line( ent_name );
	}
}


// self = player
function generate_player_info_kvps()
{
	info_arr = [];
	info_arr[0] = self.name;
	info_arr["Health"] = self.health;

	return info_arr;
}