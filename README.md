# TF2 Warbands: A SourceMod Plugin



## Introduction

This mod was introduced to add horde mode features to dedicated TF2 servers.  The server admin is able to unleash waves of bots for players to defeat, similar to MvM mode.  It adds the following features:

- Warbands can be configured in `warbands.txt`.  Bots in a warband can be configured to enter the game with buffs.  Bots can be added to the server all at once and by the name of their group.
- Bots that are killed are kicked from the server.  This was added to maintain a sense of progression through the wave.



## Usage

The following commands should ensure that the server will run this plugin:
```
sv_cheats 1
mp_autoteambalance 0 
mp_teams_unbalance_limit 30
tf_bot_keep_class_after_death 1
mp_disable_respawn_times 1
tf_bot_reevaluate_class_in_spawnroom 0
```

```
sm_wave_unleash [warband name] [blue/red]
```

A warband can be configured in `configs/warbands.txt`

```
"WarBands"
{
    "warband1"
    {
        "pyro" 
        {
            "buffs" "50 19"
            "difficulty" "easy"
            "name" "wb1_pyro"
            "count" "3"
        }
        "heavyweapons"
        {
            "buffs" "50 27"
            "difficulty" "easy"
            "name" "wb1_heavy"
            "count" "1"
        }
    }
    "warband2"
    {
    		...
    }
}
```

`sm_wave_unleash warband1 blue` loads 3 pyros (`wb1_pyro(1)`, `wb1_pyro(2)`, `wb1_pyro(3)`) and 1 heavy (`wb1_heavy(1)`) to the blue team.  While the names can be anything you want, one should avoid reusing names or unleashing another warband until the previous wave has been cleared.  

To clear all bots from the server, use:

```
tf_bot_kick all
```

#### Key-Values
Make sure to use the correct class names within each warband section.  The classes are _Demoman_, _Engineer_, _HeavyWeapons_, _Medic_, _Pyro_, _Scout_, _Soldier_, _Sniper_, and _Spy_.  
- `buffs` : each bot of the declared class will be buffed as if using the `addcond` command.  See https://wiki.teamfortress.com/wiki/Cheats for more info.  
- `difficulty` : `easy`/`normal`/`hard`/`expert`
- `name` : avoid name conflicts.
- `count` : number of bots to spawn with the above name-prefix and attributes.  



## Installation
1. Install SourceMod and MetaMod.  I found the following tutorial to be very clear and easy to follow: https://wiki.alliedmods.net/Installing_SourceMod_(simple)
2. Compile `scripting/wavemode.sp` and place the resulting `.smx` file into the `plugins` directory of your SourceMod folder.  Compiling can be done in a web source pawn compiler.


