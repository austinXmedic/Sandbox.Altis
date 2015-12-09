sleep 5;

enableSentences false;
enableRadio false;
showHUD [true,true,true,true,true,true,false,true];

myDeaths = 0;

if(RS1 distance (getMarkerPos "HQ") > 500) then
{
	"PB1" setMarkerPos (getPos RS1);
	"PB1" SetMarkerType "mil_flag";
	"PB1" SetMarkerColor "ColorRed";
	"PB1" SetMarkerText "Platoon 1 Patrol Base";
};

if(RS4 distance (getMarkerPos "HQ") > 500) then
{
	"PB1" setMarkerPos (getPos RS4);
	"PB2" SetMarkerType "mil_flag";
	"PB2" SetMarkerColor "ColorGreen";
	"PB2" SetMarkerText "Platoon 2 Patrol Base";
};

if(RS7 distance (getMarkerPos "HQ") > 500) then
{
	"PB1" setMarkerPos (getPos RS7);
	"PB3" SetMarkerType "mil_flag";
	"PB3" SetMarkerColor "ColorBlue";
	"PB3" SetMarkerText "Platoon 3 Patrol Base";
};

if(CHQ distance (getMarkerPos "HQ") > 500) then
{
	"CB" setMarkerPos (getPos CHQ);
	"CB" SetMarkerType "mil_flag";
	"CB" SetMarkerColor "ColorUNKNOWN";
	"CB" SetMarkerText "Company HQ Base";
};

if(CHW distance (getMarkerPos "HQ") > 500) then
{
	"WS" setMarkerPos (getPos CHW);
	"WS" SetMarkerType "mil_flag";
	"WS" SetMarkerColor "ColorUNKNOWN";
	"WS" SetMarkerText "Weapons Squad Base";
};

[player] execVM "sand_scripts\sand_pLoadoutCreator.sqf";
[] execVM "sand_scripts\sand_handbook.sqf";
// [player] execVM "sand_scripts\sand_briefing.sqf";

//interact actions
player addAction["Question", { 
    0 = [cursorTarget] spawn AUSMD_fnc_interrogate
}, nil, 1.5, false, true, "", " 
    cursorTarget isKindOf ""Man"" && !(player getVariable [""BIS_revive_incapacitated"",false]) && alive cursorTarget && side cursorTarget == civilian && player distance cursorTarget < 3
"];

player addAction["Interrogate", { 
    0 = [cursorTarget] spawn AUSMD_fnc_interrogateEnemy; 
}, nil, 1.5, false, true, "", "
    cursorTarget isKindOf ""Man"" && !(player getVariable ""AUSMD_interact_transporting"") && !(cursorTarget getVariable ""AUSMD_interact_beingInterrogated"") && cursorTarget getVariable ""AUSMD_interact_arrested"" && alive cursorTarget && side cursorTarget == enemySide && !(cursorTarget getVariable ""AUSMD_interact_moving"") && player distance cursorTarget < 3
"];

//buy/sell actions
player addAction ["Sell Vehicle",AUSMD_fnc_sellVehicle,nil,1,False,True,"",' player distance sellPad < 5 && (rank player isEqualTo "LIEUTENANT" OR rank player isEqualTo "CAPTAIN" OR rank player isEqualTo "MAJOR" OR rank player isEqualTo "COLONEL" OR player in ([OPS,PL3,PS3,RO3,CM3,RO6,CM6,HQ6,HQ5,HQ4,PL2,PS2,RO2,CM2,PL1,PS1,RO1,CM1])) '];
player addAction ["Purchase Vehicle",{createDialog "PurchaseUIVeh";},nil,1.5,False,True,"",' player distance register < 5 && (rank player isEqualTo "LIEUTENANT" OR rank player isEqualTo "CAPTAIN" OR rank player isEqualTo "MAJOR" OR rank player isEqualTo "COLONEL" OR player in ([OPS,PL3,PS3,RO3,CM3,RO6,CM6,HQ6,HQ5,HQ4,PL2,PS2,RO2,CM2,PL1,PS1,RO1,CM1])) '];
player addAction ["Purchase Items",{createDialog "PurchaseUI";},nil,1.5,False,True,"",' player distance register < 5 && (rank player isEqualTo "LIEUTENANT" OR rank player isEqualTo "CAPTAIN" OR rank player isEqualTo "MAJOR" OR rank player isEqualTo "COLONEL" OR player in ([OPS,PL3,PS3,RO3,CM3,RO6,CM6,HQ6,HQ5,HQ4,PL2,PS2,RO2,CM2,PL1,PS1,RO1,CM1])) '];
player addAction ["Sell Items",AUSMD_fnc_supplyBoxSell,nil,1,False,True,"",' player distance register < 5 && (rank player isEqualTo "LIEUTENANT" OR rank player isEqualTo "CAPTAIN" OR rank player isEqualTo "MAJOR" OR rank player isEqualTo "COLONEL" OR player in ([OPS,PL3,PS3,RO3,CM3,RO6,CM6,HQ6,HQ5,HQ4,PL2,PS2,RO2,CM2,PL1,PS1,RO1,CM1])) '];
player addAction ["Company Bank",{hint format ["Company Bank: %1",GV_Sand_Balance];},nil,0.8,False,True,"",' player distance register < 5 '];
player addAction ["Jobs",{createDialog "AUSMDMissions"},nil,1.2,False,True,"",' player distance register < 5 && (rank player isEqualTo "LIEUTENANT" OR rank player isEqualTo "CAPTAIN" OR rank player isEqualTo "MAJOR" OR rank player isEqualTo "COLONEL" OR player in ([OPS,PL3,PS3,RO3,CM3,RO6,CM6,HQ6,HQ5,HQ4,PL2,PS2,RO2,CM2,PL1,PS1,RO1,CM1])) '];

// old patrol bases -- now moved to commMenu
// code left for legacy
// player addAction ["Build Menu",{createDialog "PatrolBaseAdd";},nil,0.5,False,True,"",' vehicle player == player && player in ([HQ4,HQ5,HQ6,OPS,PL1,PS1,PL2,PS2,PL3,PS3,WSL]) '];
// player addAction ["Remove Menu",{createDialog "patrolBaseRemove";},nil,0.5,False,True,"",' vehicle player == player && player in ([HQ4,HQ5,HQ6,OPS,PL1,PS1,PL2,PS2,PL3,PS3,WSL]) '];

// old earplugs -- now moved to commMenu
// code left for legacy
// player addAction ["Earplugs In",{1 fadeSound .04; AUSMD_earPlugIn = true;},nil,0.6,False,True,"",' !AUSMD_earPlugIn '];
// player addAction ["Earplugs Out",{.1 fadeSound 1; AUSMD_earPlugIn = false;},nil,0.6,False,True,"",' AUSMD_earPlugIn '];

AUSMD_selectedObject = auslog;
AUSMD_selectedVehicle = auslog;

// disabled for now, may reactivate or refactor later
/* 
player addAction ["Select Object",{[] call AUMD_fnc_selectObject;},nil,0.45,False,True,"",' !(cursorTarget getVariable ["being_loaded",false]) && alive player && vehicle player == player && typeOf cursorTarget in AUSMD_acceptedObjects && player distance cursortarget < 10'];
player addAction ["Select Vehicle",{[] call AUSMD_fnc_loadObject;},nil,0.35,False,True,"",' AUSMD_selectedObject != auslog && alive player && vehicle player == player && typeOf cursorTarget in AUSMD_acceptedVehicles && player distance cursortarget < 10'];
player addAction ["Vehicle Inventory",{createDialog "vehInventory"},nil,0.25,False,True,"",' alive player && vehicle player == player && typeOf cursorTarget in AUSMD_acceptedVehicles && player distance cursorTarget < 10'];
player addAction ["Move Object",{[] call AUSMD_fnc_constructionMove;},nil,0.15,False,True,"",' alive player && vehicle player == player && typeOf cursorTarget in AUSMD_acceptedObjects && !construction_building'];
player addAction ["Drop Object",{construction_object setVariable ["being_moved",false,true];detach construction_Object;construction_Building = false;construction_Object = objNull;hint "Object Placed.";player forceWalk false;},nil,0.15,False,True,"",' construction_building && alive player && vehicle player == player'];			
 */
 
// Earplug Toggle
comm_earplugToggle = [player,"earplugToggle",nil,nil,""] call BIS_fnc_addCommMenuItem;

// Init the specialized commMenu.
[] execVM "sand_scripts\sand_initCommMenu.sqf";

// Variable for fn_radioControl -- to be replaced with lazy evaluation
radio_backupStatus = false;

/*
	OLD ADMIN MENU CODE. LEGACY.
if(getPlayerUID player isEqualTo  76561198031485127 || getPlayerUID player isEqualTo 76561198076263154) then
{
	player addAction ["Admin Menu",{createDialog "AUSMDDebug";},nil,0.4,False,True,"", ' alive player '];
	player addAction ["TILE SYSTEM OFF",{disableSpawning = true;publicVariable "disableSpawning";},nil,0.4,False,True,"", ' alive player && !disableSpawning'];
	player addAction ["TILE SYSTEM ON",{disableSpawning = true;publicVariable "disableSpawning";},nil,0.4,False,True,"", ' alive player && disableSpawning '];
};

*/

_platoon = call ausmd_fnc_platoonMembership;
if (_platoon isEqualTo 1 && PatrolBase1Up) then 
{
    player setPos (getMarkerPos "PB1");
};

if (_platoon isEqualTo 2 && PatrolBase2Up) then 
{
    player setPos (getMarkerPos "PB2");
};

if (_platoon isEqualTo 3 && PatrolBase3Up) then 
{
    player setPos (getMarkerPos "PB3");
};

if((_platoon isEqualTo 4 || _platoon isEqualTo 6) && CommandBaseUp) then
{
	player setPos (getMarkerPos "CB");
};

if(_platoon isEqualTo 5 && WeaponsBaseUp) then
{
	player setPos (getMarkerPos "WS");
};

//special thing for Zeuses
if(_platoon isEqualTo 6 || getPlayerUID player isEqualTo 76561198031485127) then
{
	execVM "VCOMAI\init.sqf";
	if(getPlayerUID player isEqualTo 76561198031485127) then
	{
		[Zeus2] execVM "AUSMD_init.sqf";
	}
	else
	{
		[Zeus] execVM "AUSMD_init.sqf";
	};
};

player addEventHandler["Hit",{_this call AUSMD_fnc_handleDamage;}];

[player] execVM "sand_scripts\sand_lockBoxes.sqf";

alreadyRan = false;
while{true} do
{
	sleep 5;
	if(player getVariable ["BIS_revive_incapacitated",false] && !alreadyRan) then
	{
		sleep 5;
		alreadyRan = true;
		myDeaths = myDeaths + 1;
		[player, [missionNamespace, "myLoadout"]] call BIS_fnc_loadInventory;
		waitUntil{!(player getVariable ["BIS_revive_incapacitated",false])};
		alreadyRan = false;
	}
	else
	{
		myLoadout = [player, [missionNamespace, "myLoadout"]] call BIS_fnc_saveInventory;
	};
};
