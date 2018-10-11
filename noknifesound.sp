#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_AUTHOR "Hexah"
#define PLUGIN_VERSION "1.00"

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = 
{
	name = "NoKnifeSound", 
	author = PLUGIN_AUTHOR, 
	description = "Disable knifing sound if no damage is done.", 
	version = PLUGIN_VERSION, 
	url = "github.com/Hexer10"
};


//OnTakeDamage will always be called even if there is no damage done.
bool bTakeDam[MAXPLAYERS + 1];
//OnTakeDamageAlive will only be called if a damage is done.
//If a damage is done both TakeDamage and TakeDamageAlive are called in the same frame.
bool bTakeDamAlive[MAXPLAYERS + 1];

bool bLate;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	bLate = late;
}

public void OnPluginStart()
{
	//Late load
	if (bLate)
	{
		for (int i = 1; i <= MaxClients; i++)if (IsClientInGame(i))
		{
			SDKHook(i, SDKHook_OnTakeDamagePost, Hook_OnTakeDamagePost);
			SDKHook(i, SDKHook_OnTakeDamageAlivePost, Hook_OnTakeDamageAlivePost);
		}
	}
	AddNormalSoundHook(Hook_NormalSound);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamagePost, Hook_OnTakeDamagePost);
	SDKHook(client, SDKHook_OnTakeDamageAlivePost, Hook_OnTakeDamageAlivePost);
}

public void Hook_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
	if (damage <= 0.0)
		return;
	bTakeDam[attacker] = true;
}

public void Hook_OnTakeDamageAlivePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
	if (damage <= 0.0)
		return;
	bTakeDamAlive[attacker] = true;
}

public Action Hook_NormalSound(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	char classname[32];
	GetEdictClassname(entity, classname, sizeof(classname));
	
	if (StrContains(classname, "knife") == -1)
		return Plugin_Continue;
	
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (bTakeDam[client] && bTakeDamAlive[client])
	{
		bTakeDam[client] = false;
		bTakeDamAlive[client] = false;
		return Plugin_Stop;
	}
	bTakeDam[client] = false;
	bTakeDamAlive[client] = false;
	
	return Plugin_Continue;
}
