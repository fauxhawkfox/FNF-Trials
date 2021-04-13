// marker names for checkpoints
checkpoints = ["circuitStart", "waypoint1", "waypoint2", "waypoint3", "waypoint4", "waypoint5", "circuitEnd"];
// is the race/timetrial, ordered or unordered
inorder = false;
// "race", "timetrial", "cargo", "precision"
gamemodetype = "race";
// number of spawned groups (2-8) particapating in event
numberofgroups = 8;

// number of waypoints (markers labeled markerX)
waypointcount = 5;
// enable visible 3d marker in world space indicating waypoint locations
visible3d = true;
// enable hint messages for debugging
debug = true;

// dont edit below
gameready = false;
gamestart = false;
if !(isServer) exitwith {};
// associates players to vehicles and places markers
call compile preprocessFileLineNumbers "gamemodes\gamesetup.sqf";

switch (gamemodetype) do {
    case "race": {
        call compile preprocessFileLineNumbers "gamemodes\race.sqf";
    };
    case "timetrial": {
        call compile preprocessFileLineNumbers "gamemodes\timetrial.sqf";
    };
    case "cargo": {
        call compile preprocessFileLineNumbers "gamemodes\cargo.sqf";
    };
    case "precision": {
        call compile preprocessFileLineNumbers "gamemodes\precision.sqf";
    };
    default {
        call compile preprocessFileLineNumbers "gamemodes\race.sqf";
    };
};

addMissionEventHandler ["MPEnded", {
    times = [];

    // waitUntil {
    // count (entities ["Helicopter", [], false, true] select {
    //     istouchingGround _x && !(isEngineOn _x) && count crew _x == 0
    // }) > 0;
    // };

    _timesRaw = [];
    {
        _playertime = (_x getVariable ["mytime", 0]);
        if (_playertime != 0) then {
            times pushBack [(name _x), _playertime];
            _timesRaw pushBack format["%1: %2", name _x, _playertime];
            _x addscore _playertime;
        };
    } forEach allunits;

timesRecord = _timesRaw joinstring "<br/>";

}];

// ref for helipads
/* pad condition
hbird_2 inArea thistrigger && !(isEngineOn hbird_2) && (count crew hbird_2) == 0 && gamestart == true;
*/
/* pad activation remoteExec
{
    ["HelipadsTask", "SUCCEEDED", true] remoteExec ["BIS_fnc_tasksetState", _x];
} forEach (thislist select {
    isplayer _x
});
/* pad activation
{
    _obj = _x;
    if (!(["RaceTask"] call BIS_fnc_taskExists) || ["RaceTask"] call BIS_fnc_taskCompleted) exitwith {};
    
    if (count (("RaceTask" call BIS_fnc_taskChildren) select {
        !(_x call BIS_fnc_taskCompleted);
    }) > 1 || count (("RaceTask" call BIS_fnc_taskChildren) select {
        (_x call BIS_fnc_taskState) == 'FAILED'
    }) > 0) then {
        ["HelipadsTask", "SUCCEEDED", true] remoteExec ["BIS_fnc_tasksetState", _obj];
        ["RaceTask", "FAILED", true] remoteExec ["BIS_fnc_tasksetState", _obj];
        _obj setVariable ["raceFinished", false, true];
    } else {
        ["HelipadsTask", "SUCCEEDED", true] remoteExec ["BIS_fnc_tasksetState", _obj];
        ["RaceTask", "SUCCEEDED", true] remoteExec ["BIS_fnc_tasksetState", _obj];
        _obj setVariable ["raceFinished", true, true];
    };
} forEach (thislist select {
    isplayer _x
});
*/

// ref for trigger contents, each waypoint incremented by number
/* condition
this && gamestart == true;
/*

/* on activation
{
    {
        _obj = _x select 0;
        if (isplayer _obj && (typeOf _obj == 'B_helicrew_F')) then {
            _y = 1;
            
            if ((format["Waypoint%1Task", _y]) != (_obj call BIS_fnc_taskCurrent) || (format["Waypoint%1Task", _y] call BIS_fnc_taskCompleted)) then {
                ["RaceTask", "FAILED", false] remoteExec ["BIS_fnc_tasksetState", _obj];
                diag_log format["%1 failed the race missing waypoint %2", _obj, _y];
                
                [
                    "DQTask",
                    _obj,
                    ["Return to the helipads and power down.", "land and Power down Immediately", ""],
                    (getmarkerPos "helipads"),
                    true,
                    99,
                    true,
                    false,
                    "land",
                    (if (visible3d) then {
                        true;
                    } else {
                        false;
                    })
                ] call BIS_fnc_setTask;
                
                [format["waypoint%1Task", _y], "FAILED", true] remoteExec ["BIS_fnc_tasksetState", _obj];
                for "_i" from _y to waypointcount do {
                    [format["waypoint%1Task", _i], "CANCELLED", false] remoteExec ["BIS_fnc_tasksetState", _obj];
                };
                _obj setVariable ["raceFinished", false, true];
            } else {
                [format["waypoint%1Task", _y], "SUCCEEDED", false] remoteExec ["BIS_fnc_tasksetState", _obj];
            };
        };
    } forEach (fullCrew _x);
} forEach thislist;
*/