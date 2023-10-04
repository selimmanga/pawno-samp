#include <a_samp>
#include <a_mysql>

main()
{
	print("###############################");
	print("Geliştirilebilir Roleplay Modu");
	print("Hazırlayan: Hardiez");
	print("###############################");
	
}

#define MesajGonder(%0,%1) \
	SendClientMessageEx(%0, 0x00DD00AA, "[!]{C8C8C8} "%1)

#define SunucuMesaji(%0,%1) \
	SendClientMessageEx(%0, 0x00DD00AA, "SERVER:{C8C8C8} "%1)

#define BilgiMesajGonder(%0,%1) \
	SendClientMessageEx(%0, 0x00DD00AA, "BİLGİ:{C8C8C8} "%1)

#define KullanimMesaji(%0,%1) \
	SendClientMessageEx(%0, 0x4aad34AA, "[?]{0099ff} "%1)

#define YeniMesaj(%0,%1) \
    SendClientMessageEx(%0, 0xf2b529AA, "UYARI:{C8C8C8} "%1)

#define HataMesajGonder(%0,%1) \
	SendClientMessageEx(%0, 0xce2121AA, "HATA:{c8c8c8} "%1)

#define HataMesaji(%0,%1) \
	SendClientMessageEx(%0, 0xCC0000AA, "[!] "%1)

#define SendAdminAction(%0,%1) \
	SendClientMessageEx(%0, 0x00DD00AA, "[!] {F5F5F5}"%1)


#define MYSQL_HOST          "localhost"
#define MYSQL_USER          "root"
#define MYSQL_PASSWORD      ""
#define MYSQL_DATABASE      "samp_rp"

new MySQL:SQL_baglanti;

enum OyuncuVerileri
{
	SQLID,
	pYas,
	pCinsiyet,
	pDogum[30],
	pTen,
	pSkin,
	pPara,
	pEXP,
	pMaas,
	pMaasSure,
	pCK,
	Cache: Cache_ID
}

new Oyuncu[MAX_PLAYERS][OyuncuVerileri];

enum
{
	DIALOG_GECERSIZ,
	DIALOG_GIRIS,
	DIALOG_KAYIT
}

public OnGameModeInit()
{
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
    new isim[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, isim, sizeof(isim));
	
    if (!IsValidRoleplayName(isim))
    {
        HataMesajGonder(playerid, "İsminiz Ad_Soyad formatında olmalıdır. İsminizi değiştirip tekrar giriş yapınız. (Adınız: %s)", isim);
        Kick(playerid);
        return 1;
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
    MesajGonder(playerid, "Karakter Oluşturma: Bindiğiniz uçak Los Santos'a vardı. Artık dolaşmaya başlayabilirsin!");
    SetPlayerPos(playerid, 1685.6610, -2330.6836, 13.5469);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
//================================ STOCKS ======================================
//==============================================================================

stock IsValidRoleplayName(const name[])
{
	if (!name[0] || strfind(name, "_") == -1)
	    return 0;

	else for (new i = 0, len = strlen(name); i != len; i ++) {
	    if ((i == 0) && (name[i] < 'A' || name[i] > 'Z'))
	        return 0;

		else if ((i != 0 && i < len  && name[i] == '_') && (name[i + 1] < 'A' || name[i + 1] > 'Z'))
		    return 0;

		else if ((name[i] < 'A' || name[i] > 'Z') && (name[i] < 'a' || name[i] > 'z') && name[i] != '_' && name[i] != '.')
		    return 0;
	}
	return 1;
}

stock SendClientMessageEx(playerid, color, const text[], {Float, _}:...)
{
	static
	    args,
	    str[144];

	if ((args = numargs()) == 3)
	{
	    SendClientMessage(playerid, color, text);
	}
	else
	{
		while (--args >= 3)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit PUSH.S 8
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessage(playerid, color, str);

		#emit RETN
	}
	return 1;
}
//==============================================================================
