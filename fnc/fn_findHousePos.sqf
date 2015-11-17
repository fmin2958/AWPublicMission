/*
Author: SENSEI

Last modified: 7/22/2015

Description: finds an interior house position

        returns array [house, position in house]
__________________________________________________________________*/
private ["_pos","_return","_houseArray","_house","_housePosArray","_dummypad"];

params [["_center", [0,0,0]], ["_range", 100, [0]]];
_pos = [];
_return = [];

_houseArray = _center nearObjects ["House",_range];
if !(_houseArray isEqualTo []) then {
    _house = _houseArray call BIS_fnc_selectRandom;
    _housePosArray = [_house] call JK_Core_fnc_buildingPositions;

    if !(_housePosArray isEqualTo []) then {
        {
            _dummypad = createVehicle ["Land_HelipadEmpty_F", _x, [], 0, "CAN_COLLIDE"];
            if !((lineIntersectsObjs [(getposASL _dummypad), [(getposASL _dummypad select 0),(getposASL _dummypad select 1),((getposASL _dummypad select 2) + 20)]]) isEqualTo []) exitWith {
                _pos = _x;
                deleteVehicle _dummypad;
            };
            deleteVehicle _dummypad;
            nil
        } count _housePosArray;
    };
};

if !(count _pos isEqualTo 0) exitWith {_return = [_house,_pos]; _return};

[2,"fn_findHousePos: Cannot find a suitable house position."] call SEN_fnc_log;
_return = [objNull,[]];
_return
