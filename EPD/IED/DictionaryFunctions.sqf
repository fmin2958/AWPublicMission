GET_IED_ARRAY = {
    private ["_sectionDictionary", "_ieds"];
    params ["_sectionName", "_iedName"];
    _sectionDictionary = [iedDictionary, _sectionName] call Dictionary_fnc_get;
    _ieds = [_sectionDictionary, "ieds"] call Dictionary_fnc_get;
    [_ieds, _iedName] call Dictionary_fnc_get;
};

GET_REMAINING_IED_COUNT = {
    private ["_sectionName", "_sectionDictionary", "_ieds", "_keys"];
    _sectionName = _this;
    _sectionDictionary = [iedDictionary, _sectionName] call Dictionary_fnc_get;
    _ieds = [_sectionDictionary, "ieds"] call Dictionary_fnc_get;
    _keys = _ieds call Dictionary_fnc_keys;

    count _keys;
};

GET_IED_SECTION_INFORMATION = {
    private ["_sectionName", "_sectionDictionary"];
    _sectionName = _this;
    _sectionDictionary = [iedDictionary, _sectionName] call Dictionary_fnc_get;

    [_sectionDictionary, "infos"] call Dictionary_fnc_get;
};

REMOVE_IED_ARRAY = {
    private ["_iedArray", "_sectionDictionary", "_ieds", "_iedArray"];
    params ["_sectionName", "_iedName"];

    _sectionDictionary = [iedDictionary, _sectionName] call Dictionary_fnc_get;
    _ieds = [_sectionDictionary, "ieds"] call Dictionary_fnc_get;
    _iedArray = [_ieds, _iedName] call Dictionary_fnc_get;
    if (typeName _iedArray != "ARRAY") exitWith {};
    if !(isNull (_iedArray select 0)) then {
        deleteVehicle (_iedArray select 0); //item
    };
    if (typeName _iedArray != "ARRAY") exitWith {};
    diag_log _iedArray;
    if !(isNull (_iedArray select 1)) then {
        deleteVehicle (_iedArray select 1); //trigger
    };
    [_ieds, _iedName] call Dictionary_fnc_remove;
    if (typeName _iedArray != "ARRAY") exitWith {};
    deleteMarker (_iedArray select 4);
    if (typeName _iedArray != "ARRAY") exitWith {};
    terminate (_iedArray select 5);
    if (typeName _iedArray != "ARRAY") exitWith {};
    terminate (_iedArray select 6);
    if (typeName _iedArray != "ARRAY") exitWith {};
};

PREPARE_IED_FOR_CLEANUP = {
    private ["_iedArray", "_sectionDictionary", "_ieds", "_iedArray", "_position", "_arr"];
    params ["_sectionName", "_iedName"];

    _sectionDictionary = [iedDictionary, _sectionName] call Dictionary_fnc_get;
    _ieds = [_sectionDictionary, "ieds"] call Dictionary_fnc_get;
    _iedArray = [_ieds, _iedName] call Dictionary_fnc_get;

    _position = getpos (_iedArray select 0);

    deleteVehicle (_iedArray select 1); //trigger
    [_ieds, _iedName] call Dictionary_fnc_remove;
    deleteMarker (_iedArray select 4);

    terminate (_iedArray select 5);
    terminate (_iedArray select 6);

    _arr = [_sectionDictionary, "cleanUp"] call Dictionary_fnc_get;
    _arr set[count _arr, _iedArray select 0];

    [_ieds, _iedName] call Dictionary_fnc_remove;

    _position;
};

INCREMENT_EXPLOSION_COUNTER = {
    private ["_sectionName", "_sectionDictionary", "_arr"];

    _sectionName = _this;
    _sectionDictionary = [iedDictionary, _sectionName] call Dictionary_fnc_get;

    _arr = [_sectionDictionary, "infos"] call Dictionary_fnc_get;
    _arr set[0, 1 + (_arr select 0)];
};

INCREMENT_DISARM_COUNTER = {
    private ["_sectionName", "_sectionDictionary", "_arr"];
    _sectionName = _this;
    _sectionDictionary = [iedDictionary, _sectionName] call Dictionary_fnc_get;

    _arr = [_sectionDictionary, "infos"] call Dictionary_fnc_get;
    _arr set[1, 1 + (_arr select 1)];
};

CREATE_IED_SECTION_DICTIONARY = {
    private ["_sectionName", "_sectionDictionary"];
    _sectionName = _this;
    _sectionDictionary = call Dictionary_fnc_new;
    [iedDictionary, _sectionName, _sectionDictionary] call Dictionary_fnc_set;

    [_sectionDictionary, "infos", [0, 0]] call Dictionary_fnc_set;
    [_sectionDictionary, "ieds", call Dictionary_fnc_new] call Dictionary_fnc_set;
    [_sectionDictionary, "fake", call Dictionary_fnc_new] call Dictionary_fnc_set;
    [_sectionDictionary, "cleanUp", []] call Dictionary_fnc_set;

    _sectionDictionary;

};

REMOVE_IED_SECTION = {
    private ["_sectionDictionary", "_iedsDictionary", "_iedKeys", "_fakesDictionary", "_fakeKeys", "_cleanUp"];
    _sectionDictionary = [iedDictionary, _this] call Dictionary_fnc_get;
    _iedsDictionary = [_sectionDictionary, "ieds"] call Dictionary_fnc_get;
    _iedKeys = _iedsDictionary call Dictionary_fnc_keys;

    {
        [_this, _x] call REMOVE_IED_ARRAY;
        nil
    } count _iedKeys;

    _fakesDictionary = [_sectionDictionary, "fake"] call Dictionary_fnc_get;
    _fakeKeys = _fakesDictionary call Dictionary_fnc_keys;
    {
        private "_fakeArr";
        _fakeArr = [_fakesDictionary, _x] call Dictionary_fnc_get;
        deleteVehicle (_fakeArr select 0);
        deleteMarker (_fakeArr select 1);
        [_fakesDictionary, _x] call Dictionary_fnc_remove;
        nil
    } count _fakeKeys;

    _cleanUp = [_sectionDictionary, "cleanUp"] call Dictionary_fnc_get;

    {
        deleteVehicle _x;
        nil
    } count _cleanUp;

    [iedDictionary, _this] call Dictionary_fnc_remove;

};

ADD_IED_TO_SECTION = {
    private "_iedsDictionary";
    params ["_sectionDictionary", "_iedName", "_iedArray"];
    _iedsDictionary = [_sectionDictionary, "ieds"] call Dictionary_fnc_get;
    [_iedsDictionary, _iedName, _iedArray] call Dictionary_fnc_set;
};

ADD_TRIGGER_TO_IED = {
    private ["_iedArray", "_iedsDictionary"];
    params ["_sectionDictionary", "_iedName", "_trigger"];
    _iedsDictionary = [_sectionDictionary, "ieds"] call Dictionary_fnc_get;
    _iedArray = [_iedsDictionary, _iedName] call Dictionary_fnc_get;
    _iedArray set [1, _trigger];
};

REMOVE_TRIGGER_FROM_IED = {
    try{
        private ["_iedArray", "_iedsDictionary", "_trigger"];
        params ["_sectionDictionary", "_iedName"];
        _iedsDictionary = [_sectionDictionary, "ieds"] call Dictionary_fnc_get;
        _iedArray = [_iedsDictionary, _iedName] call Dictionary_fnc_get;
        _trigger = _iedArray select 1;
        deleteVehicle _trigger;
        _iedArray set [1, objNull];
    } catch {};
};

ADD_DISARM_AND_PROJECTILE_DETECTION = {
    if(count _this == 0) then {
        private "_sectionKeys";
        _sectionKeys = iedDictionary call Dictionary_fnc_keys;
        {
            private ["_sectionName", "_sectionDictionary", "_iedsDictionary", "_iedKeys"];
            _sectionName = _x;
            _sectionDictionary = [iedDictionary, _x] call Dictionary_fnc_get;
            _iedsDictionary = [_sectionDictionary, "ieds"] call Dictionary_fnc_get;
            _iedKeys = _iedsDictionary call Dictionary_fnc_keys;

            {
                [_sectionName, _x] spawn DISARM_ADD_ACTION;
                if(allowExplosiveToTriggerIEDs) then {
                    [_sectionName, _x] spawn EXPLOSION_EVENT_HANDLER_ADDER;
                };
                nil
            } count _iedKeys;
            nil
        } count _sectionKeys;
    } else {
        private ["_sectionDictionary", "_iedsDictionary", "_iedKeys"];
        _sectionDictionary = [iedDictionary, _this] call Dictionary_fnc_get;
        _iedsDictionary = [_sectionDictionary, "ieds"] call Dictionary_fnc_get;
        _iedKeys = _iedsDictionary call Dictionary_fnc_keys;
            {
                [_this,_x] spawn DISARM_ADD_ACTION;
                if(allowExplosiveToTriggerIEDs) then {
                    [_this,_x] spawn EXPLOSION_EVENT_HANDLER_ADDER;
                };
                nil
            } count _iedKeys;
    };
};
