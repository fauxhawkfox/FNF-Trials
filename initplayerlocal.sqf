waitUntil {getClientStatenumber == 8};
hint "match loaded";

// if (leader group player ==  player) then{
  switch (gamemodetype) do {
      case "race": {
        call compile preprocessFileLineNumbers "client\race.sqf";
      };
      case "timetrial": {
        call compile preprocessFileLineNumbers "client\timetrial.sqf";
      };
      case "cargo": {
        call compile preprocessFileLineNumbers "client\cargo.sqf";
      };
      case "precision": {
        call compile preprocessFileLineNumbers "client\precision.sqf";
      };
      default {
        call compile preprocessFileLineNumbers "client\race.sqf";
      };
    };
// };
