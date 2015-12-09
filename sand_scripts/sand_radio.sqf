CHANNELS = [ //Your channel names and colours
    ["Platoon 1",[1,0,0,1]],
    ["Platoon 2",[0,1,0,1]],
    ["Platoon 3",[0,0,1,1]],
    ["Company Radio Net",[1,1,0,1]],
    ["Headquarters",[1,1,0,1]]
];

CHANNEL_DATA = [ //MUST ALL BE UPPER CASE!
    ["A11","A12","A13","PL1","PS1","RO1","CM1"], //Members of 'Channel 1'
    ["A21","A22","A23","PL2","PS2","RO2","CM2"], //Members of 'Channel 2'
    ["A31","A32","A33","PL3","PS3","RO3","CM3"], //Members of 'Channel 3'
    ["RO6","RO1","RO2","RO3","HP1","HP2","HP3","WSL","ASL"], //Members of 'Channel 4'
    ["HQ6","HQ5","HQ4","OPS","RO6","CM6","HP1","HP2","HP3","WSL","ASL"] //Members of 'Channel 5'
];

GAME_CHANNELS = [ //Used to convert currentChannel to actual channel name. For game channels only.
    [localize "str_channel_global"],
    [localize "str_channel_side"],
    [localize "str_channel_command"],
    [localize "str_channel_group"],
    [localize "str_channel_vehicle"],
    [localize "str_channel_direct"]
];

CHANNEL_BACKUPS = [
[["A11A","A11B"],["A12A","A12B"],["A13A","A13B"],[],[],[],[]],	//Backup to 'Channel 1'
[["A21A","A21B"],["A22A","A22B"],["A23A","A23B"],[],[],[],[]],	//Backup to 'Channel 2'
[["A31A","A31B"],["A32A","A32B"],["A33A","A33B"],[],[],[],[]],	//Backup to 'Channel 3'
[["HQ6","HQ4","HQ5"],["PL1","PS1","CM1"],["PL2","PS2","CM2"],["PL3","PS3","CM3"],[],[],[],[],[]],    //Backup to 'Channel 4'
[[],["PL1","PS1","CM1"],["PL2","PS2","CM2"],["PL3","PS3","CM3"],[],[],[],[],[],[],[]]    //Backup to 'Channel 5'
];

ACTIVE_BACKUPS = [];	//active backups are stored here.
publicVariable "ACTIVE_BACKUPS";


if (hasInterface && !isServer) then { //if not the server and is a client that is playing i.e not headless
    RADIO = { //define function that will simply send any parameters to the server
        PV__RADIO = _this;
        publicVariableServer "PV__RADIO"; //send passed values to the server, whis will trigger publicvariable event for PV__RADIO on server
    };
};

channelSetup = { //Function to determine channel to be added to and add player to it
    private ["_channels","_channel"];
    _channels = [];
    { 
        if (toUpper str player in _x) then { //see if the players unit name (set in editor) is in the current channel_data array
            _channel = CHANNELS select _forEachIndex select 0;
            _channels pushBack _channel;
            [true,_channel,[player]] call RADIO //if it is add the player to the channel (see RADIO function comments)
        }
    } forEach CHANNEL_DATA; //go through each of the CHANNEL_DATA elements (look at these commands on the wiki)
    _channels
};

channelInfo = {
    if (typeName _this in ["SCALAR","STRING"]) exitWith { //If number or string, we're asking for the members of a channel
        _channelID = -1;
        if (typeName _this == "STRING") then [{ //I sting, determine CHANNELS index
            _channelID = {
                if (_x select 0 == _this) exitWith {_forEachIndex};
                -1
            } forEach CHANNELS;
        },{
            if (_channelID > count CHANNELS -1) then { //If passed number is not a valid index, we can't proceed
                _channelID = -1;
            };
        }];
        _members = [];
        if (_channelID != -1) then [{ //If ID was found
            //Create list of member objects
            {
                if !(isNull (missionNamespace getVariable [_x,objNull])) then {
                    _members pushBack (missionNamespace getVariable _x)
                };
            } forEach (CHANNEL_DATA select _channelID);
        },{
            diag_log format["channelInfo: Something went wrong! _channelID == -1 _this: %1",_this];
        }];
        [_channelID,_members] //Return channel index and all channel members
    };

    //If object, or other type return the channel IDs and names of all channels that object belong to
    if (typeName _this != "OBJECT") then {
        _this = player
    };

    _channels = [];
    {
        if (toUpper str _this in _x) then {
            _channels pushBack [_forEachIndex,CHANNELS select _forEachIndex select 0]
        };
    } forEach CHANNEL_DATA;
    _channels
};

if isServer then { //Only do this if we are a server
    RADIO = {
        if (typeName (_this select 0) == "BOOL") then [{ //if the first element in the passed array is boolean, do this stuff... (all to do with adding/removing from EXISTING channels)
            _chan = if (typeName (_this select 1) != "STRING") then [{str (_this select 1)},{_this select 1}]; //the channel name passed to the function with some validation...
            _id = missionNamespace getVariable ["#RADIO#"+_chan,nil]; //get the actual channel ID from the variable created earlier
            if (isNil '_id') exitWith {diag_log format["RADIO: Invalid channel name: '%1'",_chan]}; //if no ID retrieved (some error?) exit the script with error in .rpt
            _units = [_this, 2, [], [[]]] call BIS_fnc_param; //get the units to add to the channel (lookup BIS_fnc_param on the wiki)
            if (_units isEqualTo []) exitWith {diag_log format["RADIO: No units to be added/removed from '%1'",_chan]}; //if no units were sent to be added exit with error

            if (_this select 0) then [{ //if the first element in the passed array is true
                diag_log format["RADIO: Added %1 to %2(%3)",_units,_chan,_id];
                _id radioChannelAdd _units //add new units to the channel
            },{
                diag_log format["RADIO: Removed %1 from %2(%3)",_units,_chan,_id];
                _id radioChannelRemove _units //if false, remove units
            }];
        },{
            _chan = if (typeName (_this select 0) != "STRING") then [{str (_this select 0)},{_this select 0}]; //the channel name passed to the function with some validation...
            _add = [_this, 1, true, [true]] call BIS_fnc_param; //if second element in array is true, creating channel. If false, removing/emptying
            _units = [_this, 2, [], [[]]] call BIS_fnc_param;  //get the units to add to the channel once it is created
            _chanVar = "#RADIO#"+_chan; //The variable name used for storing the actual channel ID simply #RADIO# plus the channel name itself
            _id = missionNamespace getVariable [_chanVar,0]; //check if the variable already exists, if not _id == 0
            if (_add && {_id != 0}) exitWith { //if we're adding a channel and the ID is not equal to 0, then channel exists already
                diag_log format["RADIO: Channel '%1' already exists",_chan] //error to .rpt
            };
            if _add then [{ //if we're adding a channel, do this stuff...
                _callsign = [_this, 4, "%UNIT_NAME", [""]] call BIS_fnc_param;
                _id = radioChannelCreate [ //create radio channel based off of following parameters, _id is set to new channel ID from radioChannelCreate command (lookup on wiki)
                    ([_this, 3, [random 1,random 1,random 1,1], [[]], [4]] call BIS_fnc_param), //1st param - colour - use passed colour, if not passed/invalid use random colour
                    _chan, //2nd param - name - from _chan stored earlier as passed to fucntion
                    //3rd param - callsign - below I was not 100% sure of its use and in the end assumed it had to do with what is shown as the "sender" of a message/voice comm
                    //The line below ensures it is a compatible type passed (from https://community.bistudio.com/wiki/radioChannelSetCallSign) if not default to %UNIT_NAME
                    (if !(_callsign in ["%CHANNEL_LABEL","%UNIT_SIDE","%UNIT_NAME","%UNIT_RANK","%UNIT_ID","%UNIT_REF","%UNIT_GRP_NAME","%UNIT_GRP_LEADER","%UNIT_VEH_NAME","%UNIT_VEH_POSITION"]) then [{"%UNIT_NAME"},{_callsign}]),
                    _units //4th param - units to add - from _units array as passed to funcction
                ];
                diag_log format["RADIO: Created channel %1 with id %2%3",_chan,_id,(if (_units isEqualTo []) then [{""},{format[" and added %1",_units]}])];
            },{
                _id radioChannelRemove allUnits; //if we're not adding a channel, I guess we're removing it. Remove allUnits from the channel
            }];
            if (_id == 0) exitWith { //if _id == 0 then we must be at the max supported of 10 (https://community.bistudio.com/wiki/radioChannelCreate) EXIT
                diag_log format["RADIO: More than 10 channels created, could not create channel: '%1'",_chan]; //error to .rpt
            };
            missionNamespace setVariable [_chanVar,_id]; //set the variable to the channel ID. Variable name is #RADION#+ channel name
        }];
    };
    "PV__RADIO" addPublicVariableEventHandler { //Whenever PV__RADIO is publicvariabled the below is run on the server
        (_this select 1) call RADIO; //the publicvariabled value of PV__RADIO is passed to RADIO function on server
    };
    { [_x select 0,true,[],_x select 1] call RADIO } forEach CHANNELS; //Create all the channels from 'CHANNELS' array ready for players to be added to
};

if hasInterface then { //If not a dedicated server, do this
    uiSleep 1;
    waitUntil {!isNull player};
    hintSilent format["Channels: %1",call channelSetup]; //Run the 'channelSetup' function to add player to the appopriate channel
    player addEventHandler ["Respawn",{call channelSetup}]; //Add a event handler that runs 'channelSetup' function when player respawns as the game removes a unit automatically when it dies
    waitUntil {!isNull findDisplay 46};
    MOSES_radio_broadcasting = false; //Set broadcasting variable to false. This variable will be true when broadcasting and false when not.
    MOSES_radio_noBeepChannels = [0,1,4,5]; //Array of GAME channel ids to not beep for. Default is DirectChannel only.
    MOSES_radio_recieve = {
        if !(params [["_from",objNull,[objNull]],["_start",true,[true]],["_channel","",[""]]]) exitWith {};
        diag_log format["RADIO: %1 of broadcast from %2 in %3",if _start then [{"Start"},{"End"}],name _from,_channel];
        playSound format["radio_%1",if _start then [{"start"},{"end"}]];
    };
    findDisplay 46 displayAddEventHandler ["KeyDown",{ //Add KeyDown event handler for tracking key presses
        _keys = actionKeys "PushToTalk"; //Jeys associated with "PushToTalk" control
        _keys append actionKeys "VoiceOverNet"; //add keys associated with "VoiceOverNet" control
        //If key pressed is associated with voice comms and we are not broadcasting already and the relevant UI displays are active
        if (_this select 1 in _keys && !MOSES_radio_broadcasting) exitWith {
            _currentChannel = currentChannel; //Store current channel ID, -1 if custom
            if (_currentChannel in MOSES_radio_noBeepChannels) exitWith {FALSE}; //If the channel has beeps disabled exit
            if (_currentChannel == 1 && {count allPlayers > 18}) exitWith {TRUE}; //Disable side chat when more than 18 players in server
            if (isNull findDisplay 55) exitWith {
                playSound "radio_start";
            };
            MOSES_radio_broadcasting = true; //set broadcasting variable to true.

            _channelMembers = []; //Create array to add channel members to. So we can send recieve sound play request to appropriate clients
            _channelName = ""; //Set channel name to blank for now
            if (_currentChannel == -1 || _currentChannel > 5) then [{ //If its a custom channel
                //Use channelInfo function to determine members and channel ID from the channel name aquired from the current channel name showin bottom left od screen
                _channelMembers = ctrlText (findDisplay 63 displayCtrl 101) call channelInfo;
                _channelName = CHANNELS select (_channelMembers select 0) select 0; //get custom channel name using info form channelInfo function
                _channelMembers = _channelMembers select 1; //Now actuall set the members. Its the second elemetn of the array returned by channelInfo
            },{
                //If we're here then currentChannel wasn't -1 so we're using a game channel
                _channelName = GAME_CHANNELS select _currentChannel select 0; //Use channel Id retrieved from currentChannel command to get channel name
                _channelMembers = playableUnits; //If it's a game channel everyone has access to it so we need to notify all player units
            }];
            _channelMembers = _channelMembers - [player];
            if (_channelMembers isEqualTo []) then [{ //If there are no units that need to play the recieve
                diag_log format["RADIO: No members of %1 channel to start broadcast to",_channelName]; //Log it, good for testing
            },{
                [player,true,_channelName] remoteExecCall ["MOSES_radio_recieve",_channelMembers]; //Run the 'MOSES_radio_recieve' function on the members of the channel
                diag_log format["RADIO: Starting broadcast to %1 member(s) of %2 channel",count _channelMembers,_channelName]; //Again, logging. Good for testing
            }];
            
            //Add an event handler to the part of the UI that appears when using voice chat.
            //This event wil fire when this part of the UI dissappears. i.e Player stops broadcasting...
            //It is a string because... It's awkward to explain.
            findDisplay 55 displayAddEventHandler ["Unload",format['
                MOSES_radio_broadcasting = false;
                playSound "radio_end";
                if (%1 isEqualTo []) then [{
                    diag_log "RADIO: No members of %3 channel to end broadcast to";
                },{
                    [player,false,"%3"] remoteExecCall ["MOSES_radio_recieve",%1];
                    diag_log "RADIO: Ending broadcast to %2 member(s) of %3 channel";
                }];
            ',_channelMembers,count _channelMembers,_channelName]];
            FALSE
        };

        //If change channel button is pressed when ALREADY brodcasting, stop it. It could cause some weird issues.
        if (_this select 1 in actionKeys "NextChannel" || _this select 1 in actionKeys "PrevChannel") exitWith {
            if MOSES_radio_broadcasting exitWith {TRUE}; //If already broadcasting exit
            playsound "clicksoft"; //play click on channel change
            5 enableChannel ({player distance _x < 50} count allPlayers < 18); //Disable direct when more than 18 players within 75m
            FALSE
        };
    }];
};
