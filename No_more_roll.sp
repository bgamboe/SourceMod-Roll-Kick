/*
SM-ViewAngle-Fix
pasted by bgamboe
*/
#pragma tabsize 0
#include <sourcemod>
#define PATH			"logs/ROLL_SHITTERS.log"
public Plugin myinfo = 
{ 
	name = "ViewAngle Fix", 
	author = "Alvy Piper / sapphyrus edited by bgamboe", 
	description = "Normalizes out of bounds viewangles & kicks on roll. Holy Shit i pasted this whole thing together <3 ~bgamboe", 
	version = "0.5", 
	url = "github.com/sapphyrus/ + bgamboe#7767" 
};
int ticksRolling[65] = {0};
bool g_bShouldStartCheckingUntrstedAngle = false;

public void OnPluginStart()
{
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("round_freeze_end", Event_Round_Freeze_End);
}

public Action Event_Round_Freeze_End(Event event, const char[] name, bool dontBroadcast) //monolith fix pt. 1
{
	g_bShouldStartCheckingUntrstedAngle = true;
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) //monolith fix pt. 2
{	
	g_bShouldStartCheckingUntrstedAngle = false;
}


public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (GetClientTeam(client) <=2){ //prim fix, has to be this way cuz 'unassigned' is a thing >:(
		ticksRolling[client] = 0;
		angles[2] == 0.0;
		g_bShouldStartCheckingUntrstedAngle = false;
		sobrietyCheck = true;
		return Plugin_Continue;
	} else {
		if (sobrietyCheck && !intermission){ //NL fix?
			g_bShouldStartCheckingUntrstedAngle = true;
			sobrietyCheck = false;
		}
	}
	if (!IsPlayerAlive(client)) { 
		ticksRolling[client] = 0;
		return Plugin_Continue;
	}
	// clamp pitch
	if (angles[0] > 89.0) {
		angles[0] = 89.0;
	} else if (angles[0] < -89.0) {
		angles[0] = -89.0;
	}

	// normalize yaw
	if (angles[1] > 180.0 || angles[1] < -180.0) {
		float flRevolutions = angles[1] / 360.0;

		if (flRevolutions < 0.0) {
			flRevolutions = -flRevolutions;
		}

		int iRevolutions = RoundToFloor(flRevolutions);

		if (angles[1] > 0.0) {
			angles[1] -= iRevolutions * 360.0;
		} else {
			angles[1] += iRevolutions * 360.0;
		}
	}

	// clamp roll
	if (g_bShouldStartCheckingUntrstedAngle){
	if (angles[2] != 0) {
       ticksRolling[client] = ticksRolling[client] + 1;
       char id[64];
       GetClientAuthId(client, AuthId_Steam2, id, sizeof(id));
       LogToPluginFile("%N (%s) has been rolling for  %i ticks.", client, id, ticksRolling[client])
	}
		if (ticksRolling[client] > 16){
			char id[64];
			GetClientAuthId(client, AuthId_Steam2, id, sizeof(id));
			KickClient(client, "Anti-Shitter (Roll): If you believe this is a bug DM 'bgamboe#7767'");
			PrintToChatAll("\x03%N \x07Was kicked for rolling.", client)
			LogToPluginFile("%N (ID: %s) Was kicked for rolling %i ticks in a round.", client, id, ticksRolling[client]);
		}
	}else{
		angles[2] = 0.0;
        ticksRolling[client] = 0;
    }

	return Plugin_Changed;
}
stock void LogToPluginFile(const char[] format, any:...)
{
	char f_sBuffer[1024], f_sPath[1024];
	VFormat(f_sBuffer, sizeof(f_sBuffer), format, 2);
	BuildPath(Path_SM, f_sPath, sizeof(f_sPath), PATH);
	LogToFile(f_sPath, "%s", f_sBuffer);
}
