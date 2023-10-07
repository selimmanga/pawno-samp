#include <a_samp>
#include <a_mysql>

#define MYSQL_HOST	"localhost"
#define MYSQL_USER	"root"
#define MYSQL_PASS 	""
#define MYSQL_DB	"veritabani"

enum
{
    DIALOG_UNUSED,
    DIALOG_KAYIT,
    DIALOG_GIRIS
};
new MySQL: veritabani;

enum e_Data
{
	ID,,
	Sifre[65],
	Salt[17],
	Isim[MAX_PLAYER_NAME],
	Olum,
	Oldurme,
	Para,
	Skor,
	GirisDenemesi,
	GirisZamanlayici,
	bool:OyuncuBaglandi
}
new Player[MAX_PLAYERS][e_Data];

public OnFilterScriptInit()
{
	mysql_log(ALL);
	dbHandle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB);
	if(mysql_errno(veritabani) != 0)
	{
		print("[MySQL] Veri tabanı bağlantısı kurulamadı sunucu kapatılıyor...");
		SendRconCommand("exit");
	}
	else
	{
		printf("[MySQL] Veri tabanı bağlantısı başarılı! Bağlanılan veri tabanı");
		printf("[MySQL] Bağlanılan veri tabanı: %s", MYSQL_DB);
	}
	mysql_tquery(veritabani,  "CREATE TABLE IF NOT EXISTS `oyuncular` (\
														`ID` INT(11) NOT NULL AUTO_INCREMENT,\
														`Isim` VARCHAR(24) NOT NULL,\
														`Sifre` VARCHAR(129) NOT NULL,\
														`Salt` VARCHAR(16) NOT NULL,\
														`Olum` INT(11) NOT NULL,\
														`Oldurme` INT(11) NOT NULL,\
														`Para` INT(11) NOT NULL,\
														`Skor` INT(11) NOT NULL,\
														PRIMARY KEY (`UserID`))");
	return 1;
}
public OnFilterScriptExit()
{
	mysql_close(veritabani);
	return 1;
}
public OnPlayerConnect(playerid)
{
	ResetPlayerMoney(playerid);
	for(new i; e_Data:i < e_Data; i++) Player[playerid][e_Data:i] = 0;

	GetPlayerName(playerid, Player[playerid][Isim], MAX_PLAYER_NAME);

	new query[128];
	mysql_format(veritabani, query, sizeof(query),"SELECT * FROM `oyuncular` WHERE `Isim` = '%e' LIMIT 1", Player[playerid][Isim]);
	mysql_tquery(veritabani, query, "HesapKontrol", "i", playerid);
	return 1;
}

forward HesapKontrol(playerid);
public HesapKontrol(playerid)
{
	if(cache_num_rows())
	{
		cache_get_value_name(0, "Sifre", Player[playerid][Sifre], 129);
		cache_get_value_name(0, "Salt", Player[playerid][Salt], 17);
		ShowPlayerDialog(playerid, DIALOG_GIRIS, DIALOG_STYLE_INPUT, "Giriş", "Oyuna bağlanmak için hesabınıza giriş yapmalısınız.", "Giriş Yap", "Oyundan Çık");
		Player[playerid][GirisZamanlayici] = SetTimerEx("OnLoginTimeout", 30 * 1000, false, "d", playerid);
	}
	else
	{
		ShowPlayerDialog(playerid, DIALOG_KAYIT, DIALOG_STYLE_INPUT, "Kayıt", "Hoş geldin! Sunucuda adına kayıtlı bir hesap bulunmuyor, hemen bir tane oluştur!", "Kayıt Ol", "Çıkış Yap");
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case DIALOG_UNUSED: return 1;
	    case DIALOG_GIRIS:
	    {
	        if(!response) return Kick(playerid);

			new hashed_pass[65], query[128];
			SHA256_PassHash(inputtext, Player[playerid][Salt], hashed_pass, 65);
			if(strcmp(hashed_pass, Player[playerid][Giris]) == 0)
			{
				mysql_format(veritabani, query, sizeof(query), "SELECT * FROM `oyuncular` WHERE `Isim` = '%e' LIMIT 1", Player[playerid][Isim]);
				mysql_tquery(veritabani, query, "HesapYukle", "i", playerid);
				KillTimer(Player[playerid][GirisZamanlayici]);
				Player[playerid][GirisZamanlayici] = 0;
			}
			else
			{
				Player[playerid][GirisDenemesi]++;
				if(Player[playerid][GirisDenemesi] >= 3)
				{
					ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Giriş - Hata", "Şifreni 3 defa yanlış girdiğin için sunucudan atıldın.", "Kapat", "");
					Kick(playerid);
					return 1;
				}
				ShowPlayerDialog(playerid, DIALOG_GIRIS, DIALOG_STYLE_INPUT, "Giriş", "Hatalı şifre girdin!\nŞifreni tekrar deneyerek giriş yap.", "Giriş Yap", "Kapat");
			}
		}
		case DIALOG_KAYIT:
		{
		    if(!response) return Kick(playerid);

		    if(strlen(inputtext) < 6) return ShowPlayerDialog(playerid, DIALOG_KAYIT, DIALOG_STYLE_INPUT, "Kayıt - Hata", "Şifreniz 6 karakterden kısa olamaz!\nTekrar deneyerek bir şifre oluşturun.", "Kayıt ol", "Kapat");
			
			for (new i = 0; i < 16; i++) Player[playerid][Salt][i] = random(94) + 33;
			SHA256_PassHash(inputtext, Player[playerid][Salt], Player[playerid][Sifre], 65);

			new query[256];
			mysql_format(dbHandle, query, sizeof(query), "INSERT INTO `oyuncular` (`Isim`, `Sifre`, `Salt`) VALUES ('%e', '%s', '%e')", Player[playerid][Isim], Player[playerid][Sifre], Player[playerid][Salt]);
			mysql_tquery(veritabani, query, "HesapKaydet", "i", playerid);
		}
		default: return 0;
	}
	return 1;
}

forward HesapYukle(playerid);
public HesapYukle(playerid)
{
    cache_get_value_name_int(0, "ID", Player[playerid][ID]);
	cache_get_value_name_int(0, "Oldurme", Player[playerid][Oldurme]);
	cache_get_value_name_int(0, "Olum", Player[playerid][Olum]);
	cache_get_value_name_int(0, "Para", Player[playerid][Para]);
	cache_get_value_name_int(0, "Skor", Player[playerid][Skor]);

 	SetPlayerScore(playerid, Player[playerid][Skor]);
 	GivePlayerMoney(playerid, Player[playerid][Para]);
	Player[playerid][OyuncuGirdi] = true;
	SendClientMessage(playerid, -1, "SUNUCU: Sunucumuza hoş geldin! Yeni kayıt olan oyuncularımıza verilen hediyeleri topla ve eğlenceye katıl.");
	GivePlayerMoney(playerid, 50000);
	return 1;
}

forward HesapKaydet(playerid);
public HesapKaydet(playerid)
{
    Player[playerid][ID] = cache_insert_id();
    Player[playerid][OyuncuGirdi] = true;
    return 1;
}
forward ZamanAsimi(playerid);
public ZamanAsimi(playerid)
{
	Player[playerid][GirisZamanlayici] = 0;

	ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Giriş - Kick", "Çok uzun süre giriş yapmadığınız ya da kayıt olmadığınız için sunucudan atıldınız.", "Kapat", "");
	Kick(playerid);
	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
	UpdatePlayerData(playerid);
	if(Player[playerid][LoginTimer])
	{
		KillTimer(Player[playerid][LoginTimer]);
		Player[playerid][LoginTimer] = 0;
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(killerid != INVALID_PLAYER_ID)
	{
		Player[killerid][Oldurme]++;
	}
	Player[playerid][Olum]++;
	return 1;
}

stock UpdatePlayerData(playerid)
{
    if(Player[playerid][pLogged] == true)
	{
		new query[256];
		mysql_format(veritabani, query, sizeof(query), "UPDATE `oyuncular` SET `Oldurme` = %d, `Olum` = %d, `Para` = %d, `Skor` = %d WHERE `ID` = %d", Player[playerid][Oldurme], Player[playerid][Olum], GetPlayerMoney(playerid), GetPlayerScore(playerid), Player[playerid][ID]);
		mysql_tquery(veritabani, query);
	}
	return 1;
}
