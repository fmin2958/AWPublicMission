/*
Author: SENSEI

Last modified: 8/9/2015

Description: spawns civilians

             returns nothing
__________________________________________________________________*/
private ["_unitArray","_vehArray","_driverArray","_grp","_vehgrp","_roads","_veh","_unit"];
params ["_pos", "_unitCount", "_vehCount", "_trgVar"];
_unitArray = [];
_vehArray = [];
_driverArray = [];
_grp = createGroup civilian;
_vehgrp = createGroup civilian;
_roads = _pos nearRoads 50;
missionNameSpace setvariable [_trgVar,true];

for "_i" from 0 to (_vehCount min (count _roads)) - 1 do {
    _veh = (SEN_vehPoolCiv call BIS_fnc_selectRandom) createVehicle (getposATL (_roads select _i));
    _unit = _vehgrp createUnit [(SEN_unitPoolCiv call BIS_fnc_selectRandom), _pos, [], 0, "NONE"];
    _unit disableAI "TARGET";
    _unit disableAI "AUTOTARGET";
    _unit disableAI "AIMINGERROR";
    _unit disableAI "SUPPRESSION";
    _unit setBehaviour "CARELESS";
    _unit moveInDriver _veh;
    _vehArray pushBack _veh;
    _driverArray pushBack _unit;
    [_unit,700,false] spawn SEN_fnc_setPatrolVeh;
};

for "_i" from 0 to _unitCount - 1 do {
    _unit = _grp createUnit [(SEN_unitPoolCiv call BIS_fnc_selectRandom), _pos, [], 0, "NONE"];
    _unit disableAI "FSM";
    _unit disableAI "TARGET";
    _unit disableAI "AUTOTARGET";
    _unit disableAI "AIMINGERROR";
    _unit disableAI "SUPPRESSION";
    _unit setBehaviour "CARELESS";
    _unitArray pushBack _unit;
};

if (random 100 < ((call SEN_fnc_getApproval) select 0)) then {
    _unit = ((_unitArray + _driverArray) call BIS_fnc_selectRandom);
    _unit setVariable ["SEN_patrol_exit",true];
    [_unit,((SEN_range*0.04) max 400)+50] call SEN_fnc_spawnCivSuicide;
};

[_grp,80] spawn SEN_fnc_setPatrolGroup;

waitUntil {uiSleep 30; !(missionNameSpace getVariable [_trgVar,false])};

SEN_objectCleanup append _unitArray;
SEN_objectCleanup append _vehArray;
SEN_objectCleanup append _driverArray;
