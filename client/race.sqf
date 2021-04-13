if (debug) then {
    hint "proper file";
};
waitUntil {
    gameready == true
};
_myvehicle = vehicle player;
profileNamespace setVariable ["raceFinished", nil];
// set tasks
/* _number = 0;
[player, "race", ["Race through the checkpoints", "Race", ""], objNull, "CREATED", 1, false, "", false] call bis_fnc_taskcreate;
{
    if (inorder) then {
        [player, ["checkpoint " + (str _number), "race"], ["pass between the towers", "checkpoint "+ (str _number), ""], getmarkerPos _x, "AUtoASSIGNED", (20 -_number), false, "", false] call bis_fnc_taskcreate;
    } else {
        [player, ["checkpoint" + (str _number), "race"], ["pass between the towers", "checkpoint ", ""], getmarkerPos _x, "CREATED", 2, false, "", false] call bis_fnc_taskcreate;
    };
    (_x +"1") setMarkerAlphaLocal 1;
    _number = _number +1;
}forEach checkpoints;
*/
if (typeOf player == 'B_helicrew_F') then {
    // Create parent circuit task
    [
        "RaceTask",
        player,
        ["", "RACE", ""],
        (getmarkerPos "helipads"),
        "CREATED",
        0,
        true, // shownotification
        false, // local only
        "run",
        (if (visible3d) then {
            true;
        } else {
            false;
        })
    ] call BIS_fnc_setTask;
    
    // circuitStart
    [
        ["CircuitStartTask", "RaceTask"],
        player,
        ["Start your race!", "START", ""],
        (getmarkerPos "circuitStart"),
        "Assigned",
        (waypointcount + 1),
        true, // show notification
        false, // if true, make global task
        "move", // marker type
        (if (visible3d) then {
            true;
        } else {
            false;
        })
    ] call BIS_fnc_setTask;
    
    // sets decreasing priority for each waypoint for proper sequencing
    _p = waypointcount + 2;
    for "_i" from 1 to waypointcount do {
        // waypoints
        [
            [format["Waypoint%1Task", _i], "RaceTask"], // taskid, parenttaskid
            player, // task owner
            ["", format["Waypoint %1", _i], ""], // description ["description", "title", "marker"]
            (getmarkerPos format["waypoint%1", _i]), // destination
            "CREATED",
            _p,
            true, // shownotification
            false, // local only
            format["move%1", _i],
            (if (visible3d) then {
                true;
            } else {
                false;
            })
        ] call BIS_fnc_setTask;
        _p = _p - 1;
    };
    
    [
        ["HelipadsTask", "RaceTask"],
        player,
        ["Return to the helipads, power down, and get out.", "land, Power down, and Get Out", ""],
        (getPosATL player),
        "CREATED",
        1,
        true, // shownotification
        false, // local only
        "land",
        (if (visible3d) then {
            true;
        } else {
            false;
        })
    ] call BIS_fnc_setTask;
};

hint "checkpoints loaded";
// _list = checkpoints;
// call compile preprocessFileLineNumbers "gamemodes\safety.sqf";
waitUntil {
    Gamestart == true
};
hint "time start";
_starttime = cba_missionTime;

// start timekeeping and task completion
/*
if (inorder) then {
    while {count _list >0} do {
        // ordered
        waitUntil {
            _myvehicle inArea _list select 0
        };
        _finder = checkpoints find _x;
        ("checkpoint" + str _finder) settaskState "Succeeded";
        (_x + "1") setMarkerColorLocal "colorgreen";
        [] spawn {
            sleep 20;
            (_x + "1") setMarkerAlphaLocal 0;
        };
        _list deleteAt 0;
    };
} else {
    while {count _list >0} do {
        // unordered
        {
            if (_myvehicle inArea _x) then {
                _finder = _list find _x;
                _list deleteAt _finder;
                _finder = checkpoints find _x;
                [("checkpoint" + str _finder), "Succeeded", false] call BIS_fnc_tasksetState;
                (_x + "1") setMarkerColorLocal "colorgreen";
                [] spawn {
                    sleep 20;
                    (_x + "1") setMarkerAlphaLocal 0;
                };
            };
        }forEach _list;
    };
};
*/
// clear checkpoints and create a task to finish Race
/*
hint "checkpoints done";
{
    (_x + "1") setMarkerAlphaLocal 0;
}forEach checkpoints;
*/

// [player, "Final", ["land at the end point", "Area", ""], getmarkerPos "endpoint", "Assigned", 2, false, "", false] call bis_fnc_taskcreate;
// waitUntil {
    // istouchingGround _myvehicle && isEngineOn _myvehicle && (count crew _myvehicle) == 0
// };

// while {!(istouchingGround _myvehicle && !(isEngineOn _myvehicle) && (count crew _myvehicle) == 0 && "HelipadsTask" call BIS_fnc_taskCompleted)} do {
//     hintSilent format ["%1", CBA_missiontime - _starttime];
//     sleep 1;
// };

_trackTimeFunc = {
    private _inputs = _this select 0;
    private _myvehicle = _inputs select 0;
    private _starttime = _inputs select 1;
    private _thisFrameHandler = _this select 1;
    
    if !((istouchingGround _myvehicle && !(isEngineOn _myvehicle) && (count crew _myvehicle) == 0 && "HelipadsTask" call BIS_fnc_taskCompleted)) then {
        hintSilent format ["%1", CBA_missiontime - _starttime];
    } else {
        player setVariable ["mytime", (CBA_missiontime - _starttime), true];
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
};

_trackTime = [_trackTimeFunc, 0, [_myvehicle, _starttime]] call CBA_fnc_addPerFrameHandler;

waitUntil {
(istouchingGround _myvehicle && !(isEngineOn _myvehicle) && (count crew _myvehicle) == 0 && "HelipadsTask" call BIS_fnc_taskCompleted);
};

// 0. Check if task exists on player, if not, exit
if (!(["RaceTask"] call BIS_fnc_taskExists) || ["RaceTask"] call BIS_fnc_taskCompleted) exitwith {};


// 1. if more than one incomplete task in RaceTask (the 1 being the land obj) then fail the player

if (count (("RaceTask" call BIS_fnc_taskChildren) select {
    !(_x call BIS_fnc_taskCompleted);
}) > 1 || count (("RaceTask" call BIS_fnc_taskChildren) select {
    (_x call BIS_fnc_taskState) == 'FAILED'
}) > 0) then {
    // 2. if any objectives are failed (missed waypoint), fail the player
    ["RaceTask", "FAILED", true] call BIS_fnc_taskSetState;
    player setVariable ["raceFinished", false, true];
} else {
    // 3. if neither of the above, all waypoints have been completed and the player is successful
    ["RaceTask", "SUCCEEDED", true] call BIS_fnc_tasksetState;
    player setVariable ["raceFinished", true, true];
};


if ((player getVariable "raceFinished")) then {
    hint format ["Your time is %1", player getVariable "mytime"];
} else {
    hint "You didn't successfully finish the race.";
    player setVariable ["mytime", 0.000];
    ["TaskFailed", ["DISQUALIFIED", "You've skipped a waypoint and been disqualified."]] call BIS_fnc_shownotification;
};

// submit time