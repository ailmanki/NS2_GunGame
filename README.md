# NS2 GunGame

GunGame is a fast game modification where players join in a arena and have to progress through a list weapons.. You start with the pistol and after number of designated kills you "level up" to the next weapon and so on and so forth through all the weapons, ending with the grenade and axe. The first person to reach last level wins overall. You still have teams, therefore its not just FFA like you might think.

### Basics (Terms)

The **Ready Room** is the lobby mechanic in all NS2 maps. It is where all players initially spawn when they join a map and where all players return to at the end of a round.

The **Arena** is map area where actual fight happens. Usually consist of one big room or several smaller connected together with big corridors. Arena should be constructed in way, that neither teams have advantage. Therefore it is usually mirrored for both teams with colour signs to mark which team owns this part of map.

**Level indicator** is located at bottom of screen. Levels are represented as row of generic ns2 weapon icons. Levels are columns of icons ordered from left to right and represents weapon and player class which are given to player. Actual level is highlighted by different colour of icons (orange).

**Kill counter** located at bottom right corner is row of skull icons. Number of skulls represents number enemies which must be killed to level up.

When players are kill, they are re-spawned immediately with **spawn protection**.
Spawn protection is basically impenetrable nano-shield. Players are re-spawned only on specific spawn locations. Spawn locations are chosen by game in semi-random order from all spawn locations available for player's team (or shared spawn locations for both teams).
> Semi-random algorithm first gets all spawn locations for team, including shared spawn locations, as unordered collection. Next step is to randomly shuffle this collection. Algorithm then serve spawn locations from top of collection one by one for re-spawn purpose. Once all spawn locations are used, algorithm reset to beginning: Get all spawn locations, shuffle, serve ... This should evenly spread player's re-spawns between all spawn locations.

**Spawn protection** duration can be modified by mapper per GunGame map. The time can be specified by seconds in ns2_gamerules entity  (default 3 seconds). Recommended spawn protection durations are:
* Default **3 seconds** definitely suits medium sized maps like *gg_shelter* & *gg_pyramid*.
* Small arena based maps like *gg_basic* and *gg_mini_mario* should have small spawn protection time around **1.5 second**. Because elsewhere a jetpack marine can get to the other side of the map and score 1 - 2 kills without taking any damage at all.
* Large and complex maps like *gg_match*, where is hard to prevent spawn killing as spawn locations are open and big/complex enough to hide enemy should have spawn protection duration increased to around **5 to 8 second**.

**Powerups** are experimental feature introduces into GunGame recently. They are not usual in GunGame modifications of other games (i.e. CounterStrike), but player can experience powerups in arena match games like: Doom, Quake or Unreal Tournament. 

Powerups entity specify the map locations where **powerup drops** are spawned regularly. Mapper can specify the drop rate per powerup in seconds. The next powerup drop will not be dropped when another powerup drop of the same type is in specified radius by entity (prevent stacking).

>Actually NS2 GunGame implements only CatPack powerups on gg_basic map as experiment. But there are planned different types of drops: medpack ,ammo, catpack or random on all available maps.

## GamePlay (Basic Rules)

**PreGame** is the specific time period after map is loaded (or previous game ends) when players can't level-up. This time (usually just a 30 seconds) allow other players with slower connection to load map and jump into arena before actual fight starts.
>During PreGame time period the **level indicator** and **kill counter** are red coloured to explicitly show disabled state.

**Game Start** when *PreGame* time expires and at least two player are in arena. The players re-spawns on spawn locations and fight begins after countdown (6 sec).
>Be aware, that players does not have spawn protection enabled right after game starts. Mappers should always create spawn locations in places, where enemy players does not have clear view on each other.

**Game End** when one of the players in game reach last level and fulfil all kills for this level. That means the player is on *Axe + Jeetpack* level and manage to kill enemy with axe.

After each kill of enemy **with primary weapon** associated with actual level, the player is rewarded by one skull. Once *kill counter* is full, the player advance to another **level** and *kill counter* is reset with number of skulls required to reach next level.

**Axe** & Exosuit's **Claw** (*as secondary weapon during whole game*) have specific role in game-play. Killing with axe or claw **steals** the whole level from enemy. That means that victim loose actual level and killer is rewarded by advancing to next level instead of just a single skull. 

The **kill counter** (number of acquired skulls) is not reset for these players, only levels are affected. Players can't drop below first level (pistol).

#### Player can level up only once with axe or claw kill! 
*This change was made to prevent just axing for levels and ruin the game for other players.*

Player which level-up with axe or claw kill will be not rewarded on second axe (or claw) kill in row with whole level but simple skull until level is changed. Level changed means **level-up** or (*this is important*) **level-down**!
 
Therefore players can't level up only by axe (or claw) any-more, but actually need to shot by primary weapon to progress faster then others.

### GunGame Map List

* **gg_basic** .. small arena like map
* **gg_shelter** .. two floors of corridors around open central area
* **gg_pyramid** .. medium sized ancient feeling map with three floors
* **gg_match** .. largest map with complex industrial like architecture
* **gg_mini_mario_2** .. fun made map based on mini_mario counter strike map (mod-id: )


### GunGame Mod ID - 2573eb73
```sh
Server.exe -mods "2573eb73"
```

### SteamWorkshop link

http://steamcommunity.com/sharedfiles/filedetails/?id=628353907