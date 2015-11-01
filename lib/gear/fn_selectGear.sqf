/*
    Author: joko // Jonas

    Description:
    Take Unit and String and Call it

    Parameter(s):
    0: Unit
    1: Class as String
    Returns:
    - Nothing

    Example:
    [player,"GearName"] call JK_loadOut_fnc_selectGear;
*/
params ["_unit", "_class"];

if ((rating _unit) >= 400) then {
    _unit addrating (floor ((rating _unit) - 600));
};

_func = missionNamespace getVariable [format ["jk_loadOut_fnc_%1", _class], {hint 'Critical Error';}];

if !(isNil 'JK_respawn_EVH') then {
    _unit removeEventHandler ['Respawn',JK_respawn_EVH];
};
JK_respawn_EVH = _unit addEventhandler['Respawn', _func];
[_unit] call _func;