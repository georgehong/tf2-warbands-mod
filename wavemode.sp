#include <sourcemod>
#include <sdktools>

public Plugin myinfo =
{
	name = "Wave Mode Plugin",
	author = "George Hong",
	description = "Plugin for simulating bot wave-mode",
	version = "0.0.1",
	url = "www.google.com"
};

public void OnPluginStart()
{
    PrintToServer("Wave Mode Plugin Initializing");
    HookEvent("player_death", Event_PlayerDeath);
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    // Kick bots that are killed.  This ensures that a wave can be beaten
    int victim_id = event.GetInt("userid");
    int victim = GetClientOfUserId(victim_id);
    // https://forums.alliedmods.net/showthread.php?t=174577
    if (!IsClientInGame(victim_id))
    {
        //PrintToServer("tf_bot_kick \"%N\"", victim);
        ServerCommand("tf_bot_kick \"%N\"", victim);
        PrintToServer("[SM] %N was removed from the wave", victim);
    }
}
