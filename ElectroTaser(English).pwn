#include <a_samp>
#include <zcmd>

// Define pData structure for storing player data in gamemode
enum pData
{
    bool:pTaserEquipped,    // Whether the player has the taser equipped
    bool:pTased             // Whether the player is currently tased
};

//---------FORWARD---------//
forward UnTased(playerid);
//-------------------------//

public OnGameModeInit()
{
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerConnect(playerid)
{
    // Initialize player data
	pData[playerid][pTaserEquipped] = false;
	pData[playerid][pTased] = false;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    // Reset player data on disconnect
    pData[playerid][pTaserEquipped] = false;
	pData[playerid][pTased] = false;
	return 1;
}

public OnPlayerDamage(playerid, issuerid, Float: amount, weaponid)
{
    if(issuerid != INVALID_PLAYER_ID)
    {
        if(pData[issuerid][pTaserEquipped] == true && pData[playerid][pTased] == false && GetPlayerWeapon(issuerid) == 0)
        {
            TogglePlayerControllable(playerid, 0);
            ApplyPlayerAnimation(issuerid, "KNIFE", "knife_3", 4.0, 0, 1, 0, 0, 1000);
            ApplyPlayerAnimation(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0);
			new string[150];
			new sstring[150];
			format(string, 150, "{33CCFF}[INFO]: {FFFF99}You used the taser against %s, they are now paralyzed for 15 seconds.", pName(playerid));
			SendClientMessage(issuerid, -1, string);
			format(sstring, 150, "{33CCFF}[INFO]: {FFFF99}Police Officer %s used the Taser against you, you are now paralyzed for 15 seconds.", pName(issuerid));
			SendClientMessage(playerid, -1, sstring);
            SetTimerEx("UnTased", 15000, 0, "i", playerid);
            pData[playerid][pTased] = true;
		}
	}
	return 1;
}

public UnTased(playerid)
{
	SendClientMessage(playerid, -1, "{33CCFF}[INFO]: {FFFF99}Time is up, you're back to normal.");
	TogglePlayerControllable(playerid, 1);
 	ClearAnimations(playerid);
  	pData[playerid][pTased] = false;
  	return 1;
}

//---------------STOCKS----------------//
stock pName(playerid)
{
	new name[21];
	GetPlayerName(playerid, name, 21);
	return name;
}

stock ApplyPlayerAnimation(playerid, animlib[], animname[], Float:fDelta, loop, lockx, locky, freeze, time, forcesync = 0)
{
    ApplyAnimation(playerid, animlib, "null", fDelta, loop, lockx, locky, freeze, time, forcesync);
    return ApplyAnimation(playerid, animlib, animname, fDelta, loop, lockx, locky, freeze, time, forcesync);
}

//--------------COMMAND----------------//

CMD:hts(playerid)
{
	if(!IsPlayerLawEnforcement(playerid)) 
        return SendClientMessage(playerid, -1, "{CC0000}[Error]: {FFFF99}You do not have permission to use this command.");
	
    if(pData[playerid][pTaserEquipped] == false)
	{
   		if(IsPlayerInAnyVehicle(playerid)) 
            return SendClientMessage(playerid, -1, "{CC0000}[ERROR]: {FFFF99}You can't use the Taser inside a vehicle.");
		
        SendClientMessage(playerid, -1, "{33CCFF}[INFO]: {FFFF99}You now have the Taser in your hand.");
		SetPlayerAttachedObject(playerid, 0, 18642, 6, 0.06, 0.01, 0.08, 180.0, 0.0, 0.0);
		GameTextForPlayer(playerid, "Taser", 3000, 1);
		pData[playerid][pTaserEquipped] = true;
		return 1;
	}
	else
	{
 	    SendClientMessage(playerid, -1, "{33CCFF}[INFO]: {FFFF99}You have now holstered the Taser.");
 	    RemovePlayerAttachedObject(playerid, 0);
	 	pData[playerid][pTaserEquipped] = false;
	}
	return 1;
}