GET_PLACES_OF_INTEREST = {
    private ["_placesToKeep", "_cities", "_villages", "_locals", "_placesCfg"];
    _placesToKeep = ["NameCityCapital","NameCity","NameVillage", "NameLocal"];
    _cities = ["NameCityCapital","NameCity"];
    _villages = ["NameVillage"];
    _locals = ["NameLocal"];

    iedAllMapLocations = call Dictionary_fnc_new;
    iedCityMapLocations = call Dictionary_fnc_new;
    iedVillageMapLocations = call Dictionary_fnc_new;
    iedLocalMapLocations = call Dictionary_fnc_new;

    _placesCfg = configFile >> "CfgWorlds" >> worldName >> "Names";
    for "_i" from 0 to (count _placesCfg)-1 do
    {
        params ["_place", "_name", "_sizeX", "_sizeY", "_avgSize", "_position", "_type"];
        _place = _placesCfg select _i;
        _name =     toUpper(getText(_place >> "name"));
        _sizeX = getNumber (_place >> "radiusA");
        _sizeY = getNumber (_place >> "radiusB");
        _avgSize = (_sizeX+_sizeY)/2;
        _position = getArray (_place >> "position");
        _type = getText(_place >> "type");
        if(_type in _placesToKeep) then {
            [iedAllMapLocations, _name , [_name, _position, _avgSize]] call Dictionary_fnc_set;
        };
        if(_type in _cities) then {
            [iedCityMapLocations, _name , [_name, _position, _avgSize]] call Dictionary_fnc_set;
        };
        if(_type in _villages) then {
            [iedVillageMapLocations, _name , [_name, _position, _avgSize]] call Dictionary_fnc_set;
        };
        if(_type in _locals) then {
            [iedLocalMapLocations, _name , [_name, _position, _avgSize]] call Dictionary_fnc_set;
        };
    };
};

FIND_LOCATION_BY_ROAD = {
    private ["_orthogonalDist", "_road", "_dir", "_position", "_offSetDirection", "_positionX", "_positionY", "_tx", "_ty", "_extraOffSet"];
    params ["_roads", "_roadCount"];
    _orthogonalDist = 5;
    _road = _roads select(floor random(_roadCount));
    _dir = 0;
    if(count (roadsConnectedTo _road) > 0) then {
        _dir  = [_road, (roadsConnectedTo _road) select 0] call BIS_fnc_DirTo;
    };
    _position = getpos _road;
    (getpos _road) params ["_opositionX", "_opositionY"];

    _offSetDirection = [-1, 1] select ((random 100) > 50);

    _positionX = _opositionX + (random 5) * _offSetDirection * sin(_dir);
    _positionY = _opositionY + (random 5) * _offSetDirection * cos(_dir);

    if((random 100) > 50) then { _offSetDirection = -1 * _offSetDirection;};

    _tx = _positionX;
    _ty = _positionY;

    while{isOnRoad [_tx,_ty,0]} do {
        _orthogonalDist = _orthogonalDist + _offSetDirection;
        _tx = (_positionX + (_orthogonalDist * cos(_dir)));
        _ty = (_positionY + (_orthogonalDist * sin(_dir)));
    };

    _extraOffSet = 1 + random 5;
    //move it off the road a random amount
    _tx = (_positionX + ((_orthogonalDist + _extraOffSet *_offSetDirection) * cos(_dir)));
    _ty = (_positionY + ((_orthogonalDist + _extraOffSet *_offSetDirection) * sin(_dir)));

    //ensure we didn't put it on another road, this happens a lot at Y type intersections
    while{isOnRoad [_tx,_ty,0]} do
    {
        _extraOffSet = _extraOffSet - 0.5;
        _tx = (_positionX + ((_orthogonalDist + _extraOffSet *_offSetDirection) * cos(_dir)));
        _ty = (_positionY + ((_orthogonalDist + _extraOffSet *_offSetDirection) * sin(_dir)));
    };

    [_tx,_ty,0];
};

GET_SIZE_AND_TYPE = {
    private ["_size", "_type", "_r"];
    params [["_smallChance", smallChance, [0]], ["_mediumChance", mediumChance, [0]], ["_largeChance", largeChance, [0]]];

    _size = "SMALL";
    _r = floor random (_smallChance + _mediumChance + _largeChance);
    if (_r > _smallChance) then {
        _size = "MEDIUM";
    };

    if (_r > _smallChance + _mediumChance) then {
        _size = "LARGE";
    };

    _type = switch _size do {
        case "SMALL": {
            iedSmallItems call BIS_fnc_selectRandom
        };
        case "MEDIUM": {
            iedMediumItems call BIS_fnc_selectRandom
        };
        case "LARGE": {
            iedLargeItems call BIS_fnc_selectRandom
        };
        default {(iedSmallItems + iedMediumItems + iedLargeItems) call BIS_fnc_selectRandom};
    };
    [_size,_type]
};

CREATE_RANDOM_IED_NAME = {
    private ["_letters", "_name", "_numberOfLettersToUse"];
    _letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","1","2","3","4","5","6","7","8","9","0"];
    _name = "ied";
    _numberOfLettersToUse = 10;
    _count = count _letters;
    for "_i" from 0 to _numberOfLettersToUse - 1 do {
        _name = _name + (_letters select (floor(random _count)));
    };
    if (_name in JK_iedNameSecure) exitWith {call CREATE_RANDOM_IED_NAME};
    JK_iedNameSecure pushBack _name;
    _name
};

CHECK_ARRAY = {
    private "_good";
    params ["_arr"];
    _good = true;
    for "_i" from 0 to (count _arr) -1 do{
        if (!ScriptDone (_arr select _i)) then {_good = false;};
    };

    _good
};

GET_CENTER_LOCATION_AND_SIZE = {
    private ["_origin", "_centerPos", "_size", "_dictLocation", "_sizeArray", "_predefinedLocationIndex"];
    _origin = _this;
    _centerPos = [0,0,0];
    _size = 0;
    if(typename _origin == "ARRAY") then {
        _centerPos = _origin select 0;
        _size = _origin select 1;
    } else {
        //check if it is a location defined in cfgWorlds
        _dictLocation = [iedAllMapLocations,  toUpper(_origin)] call Dictionary_fnc_get;
        if(typename _dictLocation == "ARRAY") then {
            _centerPos = _dictLocation select 1;
            _size = _dictLocation select 2;
        } else {
            //check if it is a marker on the map
            if( getMarkerColor _origin != "") then {
                _centerPos = getMarkerPos _origin;
                _sizeArray = getMarkerSize _origin;
                _size = ((_sizeArray select 0) + (_sizeArray select 1))/2;
                if(_origin in iedSafeZones) then {
                    if(hideSafeZoneMarkers) then {
                        (_origin) setMarkerAlpha 0;
                    };
                } else {
                    if(hideIedSectionMarkers) then {
                        (_origin) setMarkerAlpha 0;
                    };
                };
            } else {
                //check if it is in the predefined array
                _predefinedLocationIndex = -1;
                for "_i" from 0 to iedPredefinedLocationsSize -1 do{
                    if(predefinedLocations select _i select 0 == _origin) then {
                        _predefinedLocationIndex = _i;
                        _i = (count predefinedLocations);
                    };
                };
                if(_predefinedLocationIndex > -1) then {
                    _centerPos = predefinedLocations select _predefinedLocationIndex select 1;
                    _size = predefinedLocations select _predefinedLocationIndex select 2;
                };
            };
        };
    };

    [_centerPos, _size]
};
