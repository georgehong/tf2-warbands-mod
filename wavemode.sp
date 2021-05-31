#include <sdktools>
#include <sourcemod>

public Plugin myinfo =
  {
    name = "Wave Mode Plugin",
    author = "George Hong",
    description = "Plugin for simulating bot wave-mode",
    version = "0.0.1",
    url = "www.google.com"};

public void OnPluginStart()
{
    PrintToServer("Wave Mode Plugin Initializing");
    RegAdminCmd("sm_unleash_wave", Command_Unleash_Wave, ADMFLAG_SLAY);
    HookEvent("player_death", Event_PlayerDeath);
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    // Kick bots that are killed.  This ensures that a wave can be beaten
    int victim_id = event.GetInt("userid");
    int victim = GetClientOfUserId(victim_id);
    // https://forums.alliedmods.net/showthread.php?t=174577
    if(!IsClientInGame(victim_id))
    {
        //PrintToServer("tf_bot_kick \"%N\"", victim);
        ServerCommand("tf_bot_kick \"%N\"", victim);
        PrintToServer("[SM] %N was removed from the wave", victim);
    }
}

//==========================================================================
// Warband Configs
//==========================================================================

int g_section; // 1: warband name, 2: class name
char g_class[32]; // class to create
char g_difficulty[32]; 
char g_name[32];
char g_warband[32]; // name of warband (attacking group)
char g_team[32]; // red or blue
char g_target_warband[32];
//int[] g_buffs;

public SMCResult Warband_KeyValue(SMCParser smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes)
{
    return SMCParse_Continue;
}
public SMCResult Warband_EndSection(SMCParser smc)
{
    g_section--;
    return SMCParse_Continue;
}
public SMCResult Warband_NewSection(SMCParser smc, const char[] name, bool opt_quotes)
{
    g_section++;
    if(g_section == 2)
    {
        strcopy(g_class, strlen(name), name);
        PrintToServer("Encountered %s", g_class);
    }
    return SMCParse_Continue;
}

// sm_myslap [warband name] [team]
public Action Command_Unleash_Wave(int client, int args)
{
    char arg1[32], arg2[32];

    GetCmdArg(1, g_target_warband, sizeof(arg1));
    GetCmdArg(2, g_team, sizeof(arg2));

    // strcopy(g_target_warband, strlen(arg1), arg1);
    // strcopy(g_team, strlen(arg2), arg2);

    SMCParser parser = new SMCParser();
    SMC_SetReaders(parser, Warband_NewSection, Warband_KeyValue, Warband_EndSection);

    char error[128];
    int line = 0, col = 0;
    g_section = 0;
    // SMCError result = parser.ParseFile(file, line, col);

    // if( result != SMCError_Okay )
    // {
    // 	if( parser.GetErrorString(result, error, sizeof(error)) )
    // 	{
    // 		SetFailState("%s on line %d, col %d of %s [%d]", error, line, col, file, result);
    // 	}
    // 	else
    // 	{
    // 		SetFailState("Unable to load config. Bad format? Check for missing { } etc.");
    // 	}
    // }
    // delete parser;
    return Plugin_Handled;
}
