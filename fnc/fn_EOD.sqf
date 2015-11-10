/*
 * Author: joko // Jonas
 * create Functions for IED/EOD
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 */
if (isNil "JK_IED") then {
    JK_IED = [];
};
JK_lastTime = time;
if !(hasInterface) exitWith {};
JK_fnc_startLoop = {
    JK_idPFH = [{
        private ["_distance", "_delete"];
        if (!("MineDetector"in items player)) exitWith {
            [_this select 1] call CBA_fnc_removePerFrameHandler;
            JK_idPFH = nil;
        };
        if (vehicle player != player) exitWith {
            [_this select 1] call CBA_fnc_removePerFrameHandler;
            JK_idPFH = nil;
            hintSilent "You are not allowed to use Mine Detector in Vehicles.";
        };
        if !(isNil "JK_EOD_IEDPos") exitWith {};
        _distance = (JK_IED select 0) distance player;
        _delete = 0;
        {
            if (isNil "_x" || {isNull _x}) then {
                JK_IED deleteAt _forEachIndex - _delete;
                _delete = _delete + 1;
            } else {
                private "_dis";
                _dis = _x distance player;
                if (_distance > _dis) then {
                    _distance = _dis;
                };
            };
        } forEach JK_IED;
        if (_distance > 30) exitWith {};
        if (time > JK_lastTime + _distance / 20) then {
            playSound "button_click";
            JK_lastTime = time;
        };
    }, 0, []] call CBA_fnc_addPerFrameHandler;
};

JK_fnc_stopLoop = {
    [JK_idPFH] call CBA_fnc_removePerFrameHandler;
    JK_idPFH = nil;
};

JK_fnc_addAction = {
    [player, "<t color='#AE2020'>Start Mine Detector</t>", JK_fnc_startLoop, {vehicle player == player && isNil'JK_idPFH' && 'MineDetector' in items player}] call JK_Core_fnc_addAction;
    [player, "<t color='#AE2020'>Stop Mine Detector</t>", JK_fnc_stopLoop, {!isNil'JK_idPFH'}] call JK_Core_fnc_addAction;
};
[] spawn {
    waitUntil {!isNull player};
    call JK_fnc_addAction;
    player addEventHandler ["Respawn", JK_fnc_addAction];
};
