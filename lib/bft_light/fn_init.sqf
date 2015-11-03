if (!hasInterface) exitWith {};

BG_BFT_Icons = [];
BG_BFT_onlyPlayer = false;

BG_BFT_iconTypes=[];

player setVariable ["BG_BFT_playerSide", playerSide, true];

["playerInventoryChanged", {

    with uiNamespace do {
        if (!isNil "BG_UI_BFT_ctrlGroup" && {ctrlShown BG_UI_BFT_ctrlGroup}) then {
            call missionNameSpace getVariable ["BG_fnc_bftdialog_editButton", {}];
        };

    };
    _var = 0;
    if ("ACE_DAGR" in (Items player)) then {
        _var = 1;
    };
    if ("ACE_HuntIR_monitor" in (Items player)) then {
        _var = 2;
        with uiNamespace do {
            BG_UI_BFT_editButton ctrlShow true;
        };
    };
    player setVariable ["BG_BFT_item", _var, true];
}] call ace_common_fnc_addEventhandler;

private ["_classes","_keys", "_values", "_side"];
_keys = [];
_values = [];

_classes = "getText (_x >> 'markerClass') in ['NATO_BLUFOR', 'NATO_OPFOR', 'NATO_Independent']" configClasses (configfile >> "CfgMarkers");

{
    _keys pushBack configName _x;
    _values pushBack [
        getText (_x >> "icon"),
        (_x >> "color") call BIS_fnc_colorConfigToRGBA,
        getNumber (_x >> "size"),
        getText (_x >> "name"),
        switch (getText (_x >> "markerClass")) do {
            case ("NATO_BLUFOR"): {
                west
            };
            case ("NATO_OPFOR"): {
                east
            };
            case ("NATO_Independent"): {
                independent
            };
        },
        configName _x
    ];
} forEach _classes;

BG_BFT_iconTypes = [_keys,_values];

[] call BG_fnc_iconUpdateLoop;


[] spawn {
    waitUntil {!isNull ((findDisplay 12) displayCtrl 51)};
    [] call BG_fnc_bftdialog;
    ((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["Draw",BG_fnc_drawEvent];
    ((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["MouseMoving",BG_fnc_mouseMovingEvent];
    [{
        [] call BG_fnc_iconUpdateLoop;
    }, 10, []] call CBA_fnc_addPerFrameHandler;
};
