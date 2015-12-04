if (isServer || !isMultiplayer) then
{
	scriptName "main_loop_serverPersist";
	if(time < 5) then
	{
		[] execVM "sand_scripts\sand_FPSsaver.sqf";

		sleep 0.01;

		disableSpawning = false;
		publicVariable "disableSpawning";

		GV_Sand_Balance = profileNamespace getVariable ["#AUSMD#Balance",500000];
		publicVariable "GV_Sand_Balance";

		PatrolBase1Up = profileNamespace getVariable ["#AUSMD#PB1",false];
		PatrolBase2Up = profileNamespace getVariable ["#AUSMD#PB2",false];
		PatrolBase3Up = profileNamespace getVariable ["#AUSMD#PB3",false];
		CommandBaseUp = profileNamespace getVariable ["#AUSMD#CB",false];
		WeaponsBaseUp = profileNamespace getVariable ["#AUSMD#WS",false];

		publicVariable "PatrolBase1Up";
		publicVariable "PatrolBase2Up";
		publicVariable "PatrolBase3Up";
		publicVariable "CommandBaseUp";
		publicVariable "WeaponsBaseUp";

		if(PatrolBase1Up) then
		{
			pb1Pos = profileNamespace getVariable ["#AUSMD#PB1Pos",[0,0,0]];
			[1,pb1Pos] spawn AUSMD_fnc_patrolBases;
		};
		if(PatrolBase2Up) then
		{
			pb2Pos = profileNamespace getVariable ["#AUSMD#PB2Pos",[0,0,0]];
			[2,pb2Pos] spawn AUSMD_fnc_patrolBases;
		};
		if(PatrolBase3Up) then
		{
			pb3Pos = profileNamespace getVariable ["#AUSMD#PB3Pos",[0,0,0]];
			[3,pb3Pos] spawn AUSMD_fnc_patrolBases;
		};
		if(CommandBaseUp) spawn
		{
			CBPos = profileNamespace getVariable ["#AUSMD#CBPos",[0,0,0]];
			[4,CBPos] spawn AUSMD_fnc_patrolBases;
		};
		if(WeaponsBaseUp) spawn
		{
			WSPos = profileNamespace getVariable ["#AUSMD#WSPos",[0,0,0]];
			[5,WSPos] spawn AUSMD_fnc_patrolBases;
		};

		AUSMD_uids = [];
		publicVariable "AUSMD_uids";
		missionRunning = false;
		publicVariable "missionRunning";


		_boxes = [RS3,RS2,RS1,RSE1,RSL1,PHQ1,RS9,RS8,RS7,RSE3,RSL3,PHQ3,PHQ2,RSL2,RS4,RS5,RS6,CWA,CWB,CHW,CHE,CHQ,AUSMD_buyBox,BoxJump];
		_items = profileNameSpace getVariable ["#AUSMD#Boxes",[]];
		if(!(_items isEqualTo [])) then
		{
			{
				_box = _x;
				{
					_subArr = _items select _forEachIndex;
					if((_items select _forEachIndex) select 0 isEqualTo (vehicleVarName _box)) then
					{
						_weps = _subArr select 1;
						_wepsCount = _subArr select 2;
						_mags = _subArr select 3;
						_magsCount = _subArr select 4;
						_itemss = _subArr select 5;
						_itemsCount = _subArr select 6;
						_backpacks = _subArr select 7;
						_backpacksCount = _subArr select 8;
						{
							_box addWeaponCargoGlobal[_x,_wepsCount select _forEachIndex];
						} forEach _weps;
						{
							_box addMagazineCargoGlobal[_x,_magsCount select _forEachIndex];
						} forEach _mags;
						{
							_box addItemCargoGlobal[_x,_itemsCount select _forEachIndex];
						} forEach _itemss;
						{
							_box addBackpackCargoGlobal[_x,_backpacksCount select _forEachIndex];
						} forEach _backpacks;
					};
				} forEach _items;
			} forEach _boxes;
		};
		_vehicleToSpawn = profileNameSpace getVariable ["#AUSMD#Vehicles",[]];
		if(!(_vehicleToSpawn isEqualTo [])) then
		{
			{
				_veh = _x select 0;
				_pos = _x select 1;
				_dir = _x select 2;
				_stuff = _x select 3;
				_wepss = _stuff select 0;
				_wepsCounts = _stuff select 1;
				_magss = _stuff select 2;
				_magsCounts = _stuff select 3;
				_itemsss = _stuff select 4;
				_itemsssCount = _stuff select 5;
				_backpacksss = _stuff select 6;
				_backpacksssCount = _stuff select 7;
				_vehicle = _veh createVehicle _pos;
				_vehicle lock 0;
				_vehicle setDir _dir;
				if(_veh isEqualTo "C_Offroad_01_F") then
				{
					[
						_vehicle,
						["beige",1],
						[
							"HideBumper2", 0,
							"HideConstruction", 0,
							"Proxy", 0,
							"Destruct", 0
						]
					] call BIS_fnc_initVehicle;
				};

				clearWeaponCargoGlobal _vehicle;
				clearMagazineCargoGlobal _vehicle;
				clearItemCargoGlobal _vehicle;
				clearBackpacKCargoGlobal _vehicle;
				{
					_vehicle addWeaponCargoGlobal [_x,_wepsCounts select _forEachIndex];
				} forEach _wepss;
				{
					_vehicle addMagazineCargoGlobal [_x,_magsCounts select _forEachIndex];
				} forEach _magss;
				{
					_vehicle addItemCargoGlobal [_x,_itemsssCount select _forEachIndex];
				} forEach _itemsss;
				{
					_vehicle addBackpackCargoGlobal [_x,_backpacksssCount select _forEachIndex];
				} forEach _backpacksss;
			} forEach _vehicleToSpawn;


		};
	};

	[] spawn
	{
		scriptName "loop_box_restock";
		sleep 5;
		//publicVariable "GV_Sand_Balance";

		_boxes = [RS3,RS2,RS1,RSE1,RSL1,PHQ1,RS9,RS8,RS7,RSE3,RSL3,PHQ3,PHQ2,RSL2,RS4,RS5,RS6,CWA,CWB,CHW,CHE,CHQ,AUSMD_buyBox];
		while{true} do
		{
			sleep 10;
			Zeus addCuratorEditableObjects[allPlayers,true];
			Zeus2 addCuratorEditableObjects[allPlayers,true];
			Zeus3 addCuratorEditableObjects[allPlayers,true];
			profileNameSpace setVariable ["#AUSMD#Balance",GV_Sand_Balance];
			//ammo boxes

			_saveArray = [];

			{
				_boxName = [(vehicleVarName _x)];
				_guns = getWeaponCargo _x;
				_mags = getMagazineCargo _x;
				_items = getItemCargo _x;
				_backpacks = getBackpackCargo _x;
				_subArray = _boxName + _guns + _mags + _items + _backpacks;
				_saveArray set [count _saveArray,_subArray];
			} forEach _boxes;

			profileNameSpace setVariable ["#AUSMD#Boxes",_saveArray];

			_vehicles = nearestObjects[(getMarkerPos "HQ"),["Car","Tank","Air"],200];
			_vehicles2 = nearestObjects[(getMarkerPos "PB1"),["Car","Tank","Air"],200];
			_vehicles3 = nearestObjects[(getMarkerPos "PB2"),["Car","Tank","Air"],200];
			_vehicles4 = nearestObjects[(getMarkerPos "PB3"),["Car","Tank","Air"],200];
			_vehicles5 = nearestObjects[(getMarkerPos "CB"),["Car","Tank","Air"],200];
			_vehicles6 = nearestObjects[(getMarkerPos "WS"),["Car","Tank","Air"],200];

			if(!(_vehicles2 isEqualTo [])) then
			{
				{
					_vehicles set[count _vehicles,_x];
				} forEach _vehicles2;
			};
			if(!(_vehicles3 isEqualTo [])) then
			{
				{
					_vehicles set[count _vehicles,_x];
				} forEach _vehicles3;
			};
			if(!(_vehicles4 isEqualTo [])) then
			{
				{
					_vehicles set[count _vehicles,_x];
				} forEach _vehicles4;
			};
			if(!(_vehicles5 isEqualTo [])) then
			{
				{
					_vehicles set[count _vehicles,_x];
				} forEach _vehicles5;
			};
			if(!(_vehicles6 isEqualTo [])) then
			{
				{
					_vehicles set[count _vehicles,_x];
				} forEach _vehicles6;
			};
			_vehicleArray = [];

			{
				_weapons = getWeaponCargo _x;
				_mags = getMagazineCargo _x;
				_items = getItemCargo _x;
				_backpacks = getBackpackCargo _x;
				_combine = [];
				_combine = _weapons + _mags + _items + _backpacks;
				_vehicleArray set[count _vehicleArray,[(typeOf(_x)),(getPos _x),(getDir _x),_combine]];
			} forEach _vehicles;

			profileNameSpace setVariable ["#AUSMD#Vehicles",_vehicleArray];

			//patrol base saving
			profileNamespace setVariable ["#AUSMD#PB1",PatrolBase1Up];
			profileNamespace setVariable ["#AUSMD#PB2",PatrolBase2Up];
			profileNamespace setVariable ["#AUSMD#PB3",PatrolBase3Up];
			profileNamespace setVariable ["#AUSMD#CB",CommandBaseUp];
			profileNamespace setVariable ["#AUSMD#WS",WeaponsBaseUp];
			profileNamespace setVariable ["#AUSMD#PB1Pos",getMarkerPos "PB1"];
			profileNamespace setVariable ["#AUSMD#PB2Pos",getMarkerPos "PB2"];
			profileNamespace setVariable ["#AUSMD#PB3Pos",getMarkerPos "PB3"];
			profileNamespace setVariable ["#AUSMD#CBPos",getMarkerPos "CB"];
			profileNamespace setVariable ["#AUSMD#WSPos",getMarkerPos "WS"];

			saveProfileNamespace;
		};
	};

	[] spawn
	{
		scriptName "tiles_decay_loop";
		while{true} do
		{
			sleep 15000 + round(random 10000);
			{
				_variableName = format["visit_%1",_x];
				_townVisits = profileNamespace getVariable [_variableName,0];
				if(_townVisits > 0 && random 30 > 15) then
				{
					profileNamespace setVariable [_variableName,(_townVisits - 1 - round(random 2))];
					saveProfileNamespace;
				};
			} forEach AUSMD_gridPositions;
		};
	};
/*
	//update damage of houses
	[] spawn
	{
		scriptName "property_damage_track";
		while{true} do
		{
			{
					sleep 20;
				_variableName = format["buildings_%1",_x];
				_allData = [];
				_houses = nearestObjects[(getMarkerPos _x),["House"],250];
				{
					_houseData = [];
					_houseData set[0,_x];
					_houseData set[1,getDammage _x];
					if((profileNamespace getVariable [_variableName,[]]) isEqualTo []) then {_houseData set[2,false];};
					_allData set[count _allData,_houseData];
					diag_log format["Updating house array - %1",_houseData];
				} forEach _houses;
				profileNamespace setVariable [_variableName,_allData];
				saveProfileNamespace;
			} forEach AUSMD_townPositions;
		};
	};

	//evaluate damages every couple of minutes
	[] spawn
	{
		scriptName "property_damage_apply";
		private["_totalDamage","_oldHealth"];
		while{true} do
		{
			sleep 50;
			_totalDamage = 0;
			{
				_variableName = format["buildings_%1",_x];
				_buildings = profileNamespace getVariable[_variableName,[]];
				{
					diag_log format["Evaluating %1",_x];
					_curBuildHealth = getDammage _x select 0;
					_oldHealth = _x select 1;
					_alreadyPayedFor = _x select 2;
					if(_curBuildHealth < _oldHealth && !_alreadyPayedFor) then
					{
						_damages = _oldHealth * round(random 4) + 1;
						_totalDamage = _totalDamage + _damages;
						GV_Sand_Balance = GV_Sand_Balance - _damages;
						_buildings set[_forEachIndex,[_x select 0,_x select 1,true]];
						diag_log format["Building %1 - damage %2",_x select 0,_damages];
					};
				} forEach _buildings;
				profileNamespace setVariable[_variableName,_buildings];
			} forEach AUSMD_townPositions;
			publicVariable "GV_Sand_Balance";
			hint format["ASG has been fined $%1 for damages to housing.",_totalDamage];
		};
	};
	*/
	[] spawn
	{
		scriptName "tile_system_main";
		while{true} do
		{
			{
				_variableName = format["visit_%1",_x];
				_townVisits = profileNamespace getVariable [_variableName,0];
				_variableName = format["coolDown_%1",_x];
				_onCoolDown = profileNamespace getVariable [_variableName,0];
				_enemyCount = 2 + round(random 3);
				if(_townVisits > 3) then
				{
					_enemyCount = 2 + round(random 1);
					if(count allPlayers > 10) then
					{
						_enemyCount = _enemyCount + round(random 1);
					};
				};
				if(_townVisits > 5) then
				{
					_enemyCount = round(random 1);
				};
				if(_townVisits > 9) then
				{
					_enemyCount = 0;
				};
				private "_markerPosition";
				_markerPosition = getMarkerPos _x;
				_nearbyUnits = [_markerPosition,1000] call AUSMD_fnc_nearUnits;
				if(count _nearbyUnits > 0 && _onCoolDown isEqualTo 0 && !disableSpawning) then
				{
					_variableName = format["visit_%1",_x];
					profileNamespace setVariable [_variableName,(_townVisits + 1)];
					_loc = [_markerPosition,2000,"",900, [0,0,0],0] call AUSMD_fnc_findLoc;

					_group = [resistance,50,_loc] call AUSMD_fnc_createGroup;
					{
						[_x] call IndiGear;
					} forEach units _group;

					Zeus addCuratorEditableObjects[units _group,true];
					Zeus2 addCuratorEditableObjects[units _group,true];
					Zeus3 addCuratorEditableObjects[units _group,true];
					if(_nearbyUnits select 0 distance (getMarkerPos "PB1") > 350 && _nearbyUnits select 0 distance (getMarkerPos "PB2") > 350 && _nearbyUnits select 0 distance (getMarkerPos "PB3") > 350 && _nearbyUnits select 0 distance (getMarkerPos "CB") > 350 && _nearbyUnits select 0 distance (getMarkerPos "WS") > 350 && _nearbyUnits select 0 distance (getMarkerPos "HQ") > 350) then
					{
						if(random 10 > 5) then
						{
							_wp = _group addWaypoint [(getPos (_nearbyUnits select 0)), 0];
							_wp setWaypointType "MOVE";
							_wp setWaypointSpeed "FULL";
						}
						else
						{
							[_group,(getPos leader _group),1000,8] call AUSMD_fnc_Patrol;
						};
					};
					_variableName = format["coolDown_%1",_x];
					profileNamespace setVariable [_variableName,150];
					saveProfileNamespace;
				};
				if(!(_onCoolDown isEqualTo 0)) then
				{
					_variableName = format["coolDown_%1",_x];
					_coolDownTime = profileNamespace getVariable [_variableName,0];
					if(_coolDownTime < 1) then {_coolDownTime = 0;};
					profileNamespace setVariable [_variableName,(_coolDownTime - 1)];
					saveProfileNamespace;
				};
			} forEach AUSMD_gridPositions;
			sleep 30;
		};
	};

	[] spawn
	{
		scriptName "UserID_LOOP";
		while{true} do
		{
			uiSleep 86400;
			AUSMD_uids = [];
			publicVariable "AUSMD_uids";
			{
				_variableName = format["jobsDone_%1",_x];
				_jobsDone = profileNamespace getVariable [_variableName,0];
				_cash = 0;
				if(_jobsDone > 0) then
				{
					GV_Sand_Balance = GV_Sand_Balance + 5000;
					_cash = _cash + 5000;
				};
				if(_jobsDone > 3) then
				{
					GV_Sand_Balance = GV_Sand_Balance + 20000;
					_cash = _cash + 20000;
				};
				if(_jobsDone > 7) then
				{
					GV_Sand_Balance = GV_Sand_Balance + 50000;
					_cash = _cash + 50000;
				};
				publicVariable "GV_Sand_Balance";
				profileNamespace setVariable [_variableName,0];
				saveProfileNamespace;
				diag_log format["PAY SYSTEM :: %1 has generated $ %2 today.",_x,_cash];
			} forEach AUSMD_townPositions;
		};
	};

	[] spawn
	{
		scriptName "populate_town_loop";
		while{true} do
		{
			{
				_marker = _x;
				_nearPlayers = [_marker] call AUSMD_fnc_nearUnits;
				if(count _nearPlayers > 0 && !(missionNamespace getVariable _x)) then
				{
					missionNamespace setVariable [_x,true];
					[_x] spawn AUSMD_fnc_populateTown;
				};
			} forEach AUSMD_townPositions;
			sleep 15;
		};
	};
};
