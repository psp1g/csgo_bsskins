/*
 *  BS Skins for CS:GO
 *    Made for SmileyBS - https://twitch.tv/psp1g
 * 
 *  Copyright (c) 2022 - Ethan (LittleBigBug) Jones <ethan@yasfu.net>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, per version 3 of the License, or
 *  any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#pragma semicolon 1
#pragma newdecls required

#define VERSION "1.0.0"
#define AUTHOR "LittleBigBug"

#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <string>
#include <regex>

#include <weapons>
#include <gloves>
#include <csgo_weaponstickers>

#include <eItems>
#include <ripext>

#include "bsskins/globals.sp"

public Plugin myinfo = 
{
    name = "BS Skins",
    version = VERSION,
    author = AUTHOR,
    description = "Preview skins in game with weapon inspect links or generate specific skins.",
    url = "https://github.com/PSP1G/BS-Skins"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    RegPluginLibrary("bsskins");
    return APLRes_Success;
}

public void OnPluginStart()
{
    if(GetEngineVersion() != Engine_CSGO)
    {
        SetFailState("Only CS:GO servers are supported!");
        return;
    }

    char reg_error[255];
    RegexError reg_error_code;

    g_hInspectLinkRegex = CompileRegex("([SM])([0-9]+)[A]([0-9]+)[D]([0-9]+)", 
        PCRE_NOTEMPTY, 
        reg_error, 
        sizeof(reg_error), 
        reg_error_code);

    RegConsoleCmd("sm_i", CommandInspect);
    RegConsoleCmd("sm_inspect", CommandInspect);

    RegConsoleCmd("sm_gen", CommandGenerate);
    RegConsoleCmd("sm_gengl", CommandGenerate);
    RegConsoleCmd("sm_generate", CommandGenerate);
    RegConsoleCmd("sm_generate_gloves", CommandGenerate);
}

public void OnConfigsExecuted()
{
    for (int i = 1; i <= MaxClients; i++)
    {
    if (IsClientInGame(i))
        {
            OnClientPutInServer(i);
        }
    }
}

public void OnClientPutInServer(int client)
{
    if(!IsClientInGame(client) || IsFakeClient(client))
    {
        return;
    }

    PrintToServer("CL Join Test %d", client);

    g_bWaitingForInspectData[client] = false;
}

public Action CommandInspect(int client, int args)
{
    if(args != 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_inspect <inspect_url>");
        return Plugin_Handled;
    }

    char inspect_url[255];
    GetCmdArg(1, inspect_url, sizeof(inspect_url));

    RegexError reg_err;
    int captures = MatchRegex(g_hInspectLinkRegex, inspect_url, reg_err);
    if(captures != 3)
    {
        ReplyToCommand(client, "[SM] Inspect link invalid!");
        return Plugin_Handled;
    }

    char first_char[1];
    char steam_or_market_id[24];
    char asset_id[24];
    char dick_id[24]; // lol

    GetRegexSubString(g_hInspectLinkRegex, 0, first_char, sizeof(first_char));
    GetRegexSubString(g_hInspectLinkRegex, 1, steam_or_market_id, sizeof(steam_or_market_id));
    GetRegexSubString(g_hInspectLinkRegex, 2, asset_id, sizeof(asset_id));
    GetRegexSubString(g_hInspectLinkRegex, 3, dick_id, sizeof(dick_id));

    first_char[0] = CharToLower(first_char[0]);

    // Inspect Link API by CSGO Float
    // https://github.com/csgofloat/inspect
    HTTPRequest api_req = new HTTPRequest("https://api.csgofloat.com");

    api_req.AppendQueryParam(first_char, steam_or_market_id);
    api_req.AppendQueryParam("a", asset_id);
    api_req.AppendQueryParam("d", dick_id);

    api_req.Get(SkinInfoCallback, client);
    g_bWaitingForInspectData[client] = true;

    return Plugin_Handled;
}

// Correct usage: !gen <def index> [paint index] [paint seed] [paint wear] ([sticker id] [sticker wear])
public Action CommandGenerate(int client, int args)
{
    if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_generate <def_index> [paint_index] [seed] [float] ([sticker_id] [sticker_float])");
        return Plugin_Handled;
    }

    char def_index_str[64];
    GetCmdArg(0, def_index_str, sizeof(def_index_str));

    int def_index = StringToInt(def_index_str);

    if (def_index < 0)
    {
        ReplyToCommand(client, "[SM] Invalid def_index!");
        return Plugin_Handled;
    }

    int skin_id = 0;
    int skin_seed = 0;
    float skin_float = 0.0;

    // Skin ID
    if (args > 1)
    {
        char paint_indx_str[64];
        GetCmdArg(1, paint_indx_str, sizeof(paint_indx_str));

        skin_id = StringToInt(paint_indx_str);
    }

    // Seed
    if (args > 2)
    {
        char seed_str[64];
        GetCmdArg(2, seed_str, sizeof(seed_str));

        skin_seed = StringToInt(seed_str);
    }

    // Float
    if (args > 3)
    {
        char float_str[64];
        GetCmdArg(3, float_str, sizeof(float_str));

        skin_float = StringToFloat(float_str);
    }

    int glove_num = eItems_GetGlovesNumByDefIndex(def_index);

    // They r Glove
    if (glove_num > 0) 
    {
        Gloves_SetGlovesWithSkin(client, def_index, skin_id);
        Gloves_SetGlovesFloat(client, skin_float);
        Gloves_SetGlovesSeed(client, skin_seed);

        return Plugin_Handled;
    }

    char weapon_class[64];
    eItems_GetWeaponClassNameByDefIndex(def_index, weapon_class, sizeof(weapon_class));

    if (eItems_IsDefIndexKnife(def_index))
    {
        Weapons_SetClientKnife(client, weapon_class, true);
    }

    Weapons_SetWeaponSkin(client, weapon_class, skin_id);
    Weapons_SetWeaponSeed(client, weapon_class, skin_seed);
    Weapons_SetWeaponFloat(client, weapon_class, skin_float);

    int active_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

    // Stickers
    if (args > 4)
    {
        for (int i = 4; i < args; i += 2)
        {
            char sticker_id_str[64];
            GetCmdArg(i, sticker_id_str, sizeof(sticker_id_str));

            if (StrContains(sticker_id_str, "_"))
            {
                continue;
            }

            // Float here
            if (StrContains(sticker_id_str, "."))
            {
                ReplyToCommand(client, "[SM] Invalid sticker ID! (Id, then float)");
                return Plugin_Handled;
            }

            int sticker_id = StringToInt(sticker_id_str);

            if (sticker_id < 0)
            {
                continue;
            }

            float sticker_float = 0.0;
            int slot = (i - 4) / 2;
            int i_float = i + 1;

            if (i_float < args)
            {
                char sticker_float_str[64];
                GetCmdArg(i_float, sticker_float_str, sizeof(sticker_float_str));

                sticker_float = StringToFloat(sticker_float_str);
            }

            Stickers_SetWeaponSticker(client, active_weapon, slot, sticker_id, sticker_float);
        }
    }

    return Plugin_Handled;
}

// Response from CSGOFloat
public void SkinInfoCallback(HTTPResponse response, any value)
{
    int client = view_as<int>(value);

    if (!IsClientInGame(client) || !g_bWaitingForInspectData[client])
    {
        return;
    }

    if (response.Status != HTTPStatus_OK || response.Data == null)
    {
        PrintToServer("CSGOFloat API Request failed!");
        ReplyToCommand(client, "There was an error trying to fetch skin info for that!");
        return;
    }

    JSONObject json_root = view_as<JSONObject>(response.Data);

    if (json_root.HasKey("error"))
    {
        char error_msg[128];
        json_root.GetString("error", error_msg, sizeof(error_msg));

        int error_code = json_root.GetInt("code");

        PrintToServer("CSGOFloat API Error Response: [%d] %s", error_code, error_msg);
        ReplyToCommand(client, "Error trying to fetch skin data: %s", error_msg);
        return;
    }

    JSONArray stickers = view_as<JSONArray>(json_root.Get("stickers"));

    int weapon_def_id = json_root.GetInt("defindex");

    int skin_id = json_root.GetInt("paintindex");
    int skin_seed = json_root.GetInt("paintseed");
    float skin_float = json_root.GetFloat("floatvalue");

    int glove_num = eItems_GetGlovesNumByDefIndex(weapon_def_id);

    // They r Glove
    if (glove_num > 0) 
    {
        Gloves_SetGlovesWithSkin(client, weapon_def_id, skin_id);
        Gloves_SetGlovesFloat(client, skin_float);
        Gloves_SetGlovesSeed(client, skin_seed);
        return;
    }

    char weapon_class[64];
    eItems_GetWeaponClassNameByDefIndex(weapon_def_id, weapon_class, sizeof(weapon_class));

    if (eItems_IsDefIndexKnife(weapon_def_id))
    {
        Weapons_SetClientKnife(client, weapon_class, true);
    }

    Weapons_SetWeaponSkin(client, weapon_class, skin_id);
    Weapons_SetWeaponSeed(client, weapon_class, skin_seed);
    Weapons_SetWeaponFloat(client, weapon_class, skin_float);

    if (json_root.HasKey("killeatervalue") && !json_root.IsNull("killeatervalue"))
    {
        int stat_trak_ct = json_root.GetInt("killeatervalue");

        Weapons_SetWeaponStatTrakStatus(client, weapon_class, true);
        Weapons_SetWeaponStatTrakCount(client, weapon_class, stat_trak_ct);
    }

    int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

    int stickerCt = stickers.Length;

    // Has some stickers on it
    if (stickerCt > 0)
    {
        for (int i = 0; i < stickerCt; i++)
        {
            JSONObject stickerData = view_as<JSONObject>(stickers.Get(i));

            int stickerId = stickerData.GetInt("stickerId");
            int slot = stickerData.GetInt("slot");
            float wear = stickerData.GetFloat("wear");

            Stickers_SetWeaponSticker(client, activeWeapon, slot, stickerId, wear);

            delete stickerData;
        }
    }

    delete stickers;
}