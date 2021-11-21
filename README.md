# Donut Monitor
A mod for Call of Duty: Black Ops 3 that was made to help visually monitor and debug entities and structs in maps in real time. It has a variety of settings and configurations to help you narrow down exactly what you want to see.

### DVARS NEEDED:
```/scr_mod_enable_devblock 1```
- Required to run devblocks & make the mod usable

```/developer 2```
- If you can't run your map with this enabled then FIX UR SHIT

```/logfile 1```
- Highly encouraged when debugging anything

### PRIMARY COMMANDS & FEATURES:
```/modvar monitor_time {float}```
- Sets rate (seconds) at which the monitor updates (default: 0.5)

```/modvar monitor_distance {int}```
- Sets distance at which the monitor draws shapes & text (default: 1000)

```/modvar monitor_filter {category} {0 or 1}```
- Toggles visibility of a chosen entity category (see **[Steam Discussions](https://steamcommunity.com/workshop/filedetails/discussion/2657517966/3195862342461110392/)** for category list)

```/modvar monitor_visuals {0 or 1}```
- Toggles visibility of debug shapes & text

```/modvar monitor_gcrash 1```
- Prints out a list of all ents in the logfile after force-crashing (needs /logfile 1)

```/modvar dm_points all 500000```
- Gives everyone in the game 500k just cuz

See **[Steam Discussions](https://steamcommunity.com/workshop/filedetails/discussion/2657517966/3195862342461110392/)** for additional commands!<br>

This mod can be very intensive depending on how many objects it has to draw and how often it must do so. I advise you to figure out what settings work best. If your game lags, try adjusting monitor_time and monitor_distance first.<br>

Also, please do not use this for malicious intent against other people's creations. People work hard on their stuff, you work hard on your stuff. If you're trying to figure out how someone did something, just ask them.<br>

## [Visit the Mod's Steam Page here](https://steamcommunity.com/sharedfiles/filedetails/?id=2657517966)

### Credits:
func_vehicle - Partner in code<br>
Sphynx - Console command reference<br>
Treyarch - Making debug methods