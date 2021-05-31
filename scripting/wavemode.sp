#include <sdktools>
#include <sourcemod>

#define CONFIG_FOLDER "configs"
#define CONFIG_FILE "warbands.txt"

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

// Bug appears to come from client values exceeding the server limit
// https://forums.alliedmods.net/showthread.php?t=300581
stock bool IsValidClient(int client, bool bAllowBots = false, bool bAllowDead = true) 
{ 
    if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bAllowDead && !IsPlayerAlive(client))) 
    { 
        return false; 
    } 
    return true; 
}  

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    // Kick bots that are killed.  This ensures that a wave can be beaten
    int victim_id = event.GetInt("userid");
    int victim = GetClientOfUserId(victim_id);
    if (!IsValidClient(victim_id, true))
    {
        ServerCommand("tf_bot_kick \"%N\"", victim);
        PrintToServer("[SM] %N was removed from the wave", victim);
    }
}

//============================================================================
// Warband Configs
//============================================================================

int g_section;         // 1: root, 2: warband name, 3: class name
char g_class[32];      // class to create
char g_difficulty[32]; // difficulty of class to add
char g_name[32];
char g_team[32];            // red or blue
char g_target_warband[32];  // name of target warband to add
char g_current_warband[32]; // name of current parsed warband (attacking group)
char g_count[32];
char g_buffs[32][32];
int g_retrieved_strings;
//int[] g_buffs;

public SMCResult Warband_KeyValue(SMCParser smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes)
{
    if(strcmp(g_target_warband, g_current_warband) == 0)
    {
        if(strcmp(key, "buffs") == 0)
        {
            // TODO: Implement
            g_retrieved_strings = ExplodeString(value, " ", g_buffs, 32, 32);
        }
        else if(strcmp(key, "difficulty") == 0)
        {
            strcopy(g_difficulty, strlen(value) + 1, value);
        }
        else if(strcmp(key, "name") == 0)
        {
            strcopy(g_name, strlen(value) + 1, value);
        }
        else if(strcmp(key, "count") == 0)
        {
            strcopy(g_count, strlen(value) + 1, value);
        }
    }
    return SMCParse_Continue;
}
public SMCResult Warband_EndSection(SMCParser smc)
{
    g_section--;
    // PrintToServer("%d", g_section);
    if(g_section == 2 && strcmp(g_current_warband, g_target_warband) == 0)
    {
        // command to add class...etc
        // PrintToServer("[SM-DEBUG] tf_bot_add %s %s %s %s %s", g_count, g_class, g_team, g_difficulty, g_name);
        // PrintToServer("[SM] tf_bot_add %s %s %s %s %s", g_count, g_class, g_team, g_difficulty, g_name);
        // ServerCommand("tf_bot_add %s %s %s %s %s", g_count, g_class, g_team, g_difficulty, g_name);
        for(int bot_count = 0; bot_count < StringToInt(g_count); bot_count++)
        {
            ServerCommand("tf_bot_add 1 %s %s %s %s", g_class, g_team, g_difficulty, g_name);
        }

        for(int k = 0; k < g_retrieved_strings; k++)
        {
            // PrintToServer("[SM-DEBUG] Registered cond (buff): %s", g_buffs[k]);
            PrintToServer("[SM] bot_command %s addcond %s", g_name, g_buffs[k]);
            ServerCommand("bot_command %s addcond %s", g_name, g_buffs[k]);
            // for(int bot_copy = 1; bot_copy < StringToInt(g_count); bot_copy++)
            // {
            //     PrintToServer("[SM] bot_command \"(%d)%s\" addcond %s", bot_copy, g_name, g_buffs[k]);
            //     ServerCommand("bot_command \"(%d)%s\" addcond %s", bot_copy, g_name, g_buffs[k]);
            // }
        }
    }
    return SMCParse_Continue;
}
public SMCResult Warband_NewSection(SMCParser smc, const char[] name, bool opt_quotes)
{
    g_section++;
    // PrintToServer("%s %d", name, g_section);
    if(g_section == 2)
    {
        strcopy(g_current_warband, strlen(name) + 1, name);
    }
    if(g_section == 3 && strcmp(g_current_warband, g_target_warband) == 0)
    {
        strcopy(g_class, strlen(name) + 1, name);
        // PrintToServer("Encountered %s", g_class);
    }
    return SMCParse_Continue;
}

// sm_myslap [warband name] [team]
public Action Command_Unleash_Wave(int client, int args)
{
    char arg1[32], arg2[32];
    GetCmdArg(1, g_target_warband, sizeof(arg1));
    GetCmdArg(2, g_team, sizeof(arg2));

    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath), "%s/%s", CONFIG_FOLDER, CONFIG_FILE);

    SMCParser parser = new SMCParser();
    SMC_SetReaders(parser, Warband_NewSection, Warband_KeyValue, Warband_EndSection);

    char error[128];
    int line = 0, col = 0;
    g_section = 0;
    SMCError result = parser.ParseFile(sPath, line, col);

    if(result != SMCError_Okay)
    {
        if(parser.GetErrorString(result, error, sizeof(error)))
        {
            SetFailState("%s on line %d, col %d of %s [%d]", error, line, col, sPath, result);
        }
        else
        {
            SetFailState("Unable to load config. Bad format? Check for missing { } etc.");
        }
    }
    delete parser;
    return Plugin_Handled;
}
