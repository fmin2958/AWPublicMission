/*
gear-adding function by joko
Idea by Belbo
adds the loadouts from ADV_Setup\gear\west\*.sqf to the units
If custom content is added to the units, they possibly have to be added to _glrfls (if there are rifles with grenade launchers).
define per cfgFunctions or from init.sqf or initPlayerLocal.sqf as early as possible via
call JK_loadOut_fnc_gear;
*/
_unit setCaptive true;

private ["_uniform", "_headgear", "_vest", "_backpack", "_count"];
params ["_unit"];

//randomizers:
_uniform = JK_uniforms call BIS_fnc_selectRandom;
_headgear = JK_headgears call BIS_fnc_selectRandom;
_vest = JK_vests call BIS_fnc_selectRandom;
_backpack = JK_backpacks call BIS_fnc_selectRandom;

if (typeName JK_primaryweapon == "ARRAY") then {JK_primaryweapon = JK_primaryweapon call BIS_fnc_selectRandom;};


//removals:
removeUniform _unit;
removeallItems _unit;
removeAllAssignedItems _unit;
removeallWeapons _unit;
removeHeadgear _unit;
removeBackpack _unit;
removeVest _unit;
{_unit removeMagazine _x} forEach magazines _unit;
//...and readding. Clothing:
_unit forceAddUniform _uniform;
_unit addVest _vest;
if (_backpack != "") then {
    _unit addBackpack _backpack;
};
_unit addHeadgear _headgear;
if (JK_useProfileGoggles == 0) then {
    removeGoggles _unit;
    _unit addGoggles JK_goggles;
};

if (JK_mediKit == 0) then {
    for "_i" from 1 to JK_FirstAidKits do    {
        _unit addItem "FirstAidKit";
    };
};
if (JK_mediKit >= 1) then {
    _unit addItemToBackpack "MediKit";
    for "_i" from 1 to JK_FirstAidKits do    {
        _unit addItemToBackpack "FirstAidKit";
    };
};

//'nades:
_IR_GrenType = switch (side (group _unit)) do {
    case west: {"B_IR_Grenade"};
    case east: {"O_IR_Grenade"};
    case independent: {"I_IR_Grenade"};
    default {"I_IR_Grenade"};
};

JK_grenadeArray = [["HandGrenade", JK_grenadeHE], ["SmokeShell", JK_grenadeSmokeWhite],["SmokeShellYellow", JK_grenadeSmokeYellow],["SmokeShellOrange", JK_grenadeSmokeOrange],["SmokeShellRed", JK_grenadeSmokeRed],["SmokeShellPurple", JK_grenadeSmokePurple],["SmokeShellBlue", JK_grenadeSmokeBlue],["SmokeShellGreen", JK_grenadeSmokeGreen],["Chemlight_Yellow", JK_chemlightYellow],["Chemlight_Red", JK_chemlightRed],["Chemlight_Green", JK_chemlightGreen],["Chemlight_Blue", JK_chemlightBlue],[_IR_GrenType, JK_IRgrenade],["1Rnd_HE_Grenade_shell", JK_40mmHeGrenadesAmmo],["1Rnd_Smoke_Grenade_shell", JK_40mmSmokeGrenadesWhite],["1Rnd_SmokeYellow_Grenade_shell", JK_40mmSmokeGrenadesYellow],["1Rnd_SmokeOrange_Grenade_shell", JK_40mmSmokeGrenadesOrange],["1Rnd_SmokeRed_Grenade_shell", JK_40mmSmokeGrenadesRed],["1Rnd_SmokePurple_Grenade_shell", JK_40mmSmokeGrenadesPurple],["1Rnd_SmokeBlue_Grenade_shell", JK_40mmSmokeGrenadesBlue],["1Rnd_SmokeGreen_Grenade_shell", JK_40mmSmokeGrenadesGreen],["UGL_FlareWhite_F", JK_40mmFlareWhite],["UGL_FlareYellow_F", JK_40mmFlareYellow],["UGL_FlareRed_F", JK_40mmFlareRed],["UGL_FlareGreen_F", JK_40mmFlareGreen],["UGL_FlareCIR_F", JK_40mmFlareIR]];
{
    _unit addMagazines _x;
    nil
} count JK_grenadeArray;

//weapons
[_unit,JK_binocular,1] call BIS_fnc_addWeapon;
[_unit,JK_handgun,JK_handgunAmmo] call BIS_fnc_addWeapon;
{_unit addHandgunItem _x; true} count JK_itemsHandgun;
[_unit,JK_launcher,JK_launcherAmmo,JK_launcherHandle] call BIS_fnc_addWeapon;
if (JK_primaryweaponTracers >= 1) then {
    if (JK_primaryWeapon in ["arifle_MX_SW_Black_F", "arifle_MX_SW_F"]) then {
        [_unit, JK_primaryWeapon, JK_primaryweaponTracers, JK_ARhandle + 1] call BIS_fnc_addWeapon;
        [_unit, JK_primaryWeapon, JK_primaryweaponAmmo, JK_ARhandle] call BIS_fnc_addWeapon;
    } else {
        [_unit, JK_primaryWeapon, JK_primaryweaponAmmo, JK_ARhandle] call BIS_fnc_addWeapon;
        [_unit, JK_primaryWeapon, JK_primaryweaponTracers, JK_ARhandle + 1] call BIS_fnc_addWeapon;
    };
} else {
    [_unit, JK_primaryWeapon, JK_primaryweaponAmmo, JK_ARhandle] call BIS_fnc_addWeapon;
};
{
    if (typeName _x == "ARRAY") then {
        private "_primAttachmentTemp";
        _primAttachmentTemp = (_x call BIS_fnc_selectRandom);
        if (_primAttachmentTemp != "") then {
            if (_primAttachmentTemp in ["optic_Hamr", "ACE_optic_Hamr_2D", "ACE_optic_Hamr_PIP"]) then {
                _unit addPrimaryWeaponItem (["optic_Hamr", "ACE_optic_Hamr_2D", "ACE_optic_Hamr_PIP"] select JK_Optics);
            } else {
                _unit addPrimaryWeaponItem _primAttachmentTemp;
            };
        };
    } else {
        if (_x in ["optic_Hamr", "ACE_optic_Hamr_2D", "ACE_optic_Hamr_PIP"]) then {
            _unit addPrimaryWeaponItem (["optic_Hamr", "ACE_optic_Hamr_2D", "ACE_optic_Hamr_PIP"] select JK_Optics);
        } else {
            _unit addPrimaryWeaponItem _x;
        };
    };
    nil
} count JK_itemsPrimaryweapon;

{
    if (typeName _x == "ARRAY") then {
        private "_secAttachmentTemp";
        _secAttachmentTemp = (_x call BIS_fnc_selectRandom);
        if (_secAttachmentTemp != "") then {
            _unit addSecondaryWeaponItem _secAttachmentTemp;
        };
    } else {
        _unit addSecondaryWeaponItem  _x;
    };
    nil
} count JK_launcherItems;
_unit selectWeapon JK_primaryweapon;

_ivBag = if (ace_medical_level == 1) then {
     "ACE_bloodIV";
} else {
    "ACE_salineIV";
};

for "_i" from 1 to JK_IVBagSaline250 do {
    _unit addItem (_ivBag + "_250");
};

for "_i" from 1 to JK_IVBagSaline500 do {
    _unit addItem (_ivBag + "_500");
};

for "_i" from 1 to JK_IVBagSaline1000 do {
    _unit addItem _ivBag;
};

for "_i" from 1 to JK_epinephrine do {
    _unit addItem "ACE_epinephrine";
};

for "_i" from 1 to JK_morphine do {
    _unit addItem "ACE_morphine";
};

for "_i" from 1 to JK_atropine do {
    _unit addItem "ACE_atropine";
};

for "_i" from 1 to JK_fieldDressing do {
    _unit addItem "ACE_fieldDressing";
};

for "_i" from 1 to JK_packingBandage do {
    _unit addItem "ACE_packingBandage";
};

for "_i" from 1 to JK_elasticBandage do {
    _unit addItem "ACE_elasticBandage";
};

for "_i" from 1 to JK_quikclot do {
    _unit addItem "ACE_quikclot";
};

for "_i" from 1 to JK_tourniquet do {
    _unit addItem "ACE_tourniquet";
};

for "_i" from 1 to JK_earPlugs do {
    _unit addItem "ACE_EarPlugs";
};

for "_i" from 1 to JK_swapBarrel do {
    _unit addItem "ACE_SpareBarrel";
};

//items:
{_unit linkitem _x; false} count JK_itemslink;
{_unit addItemToUniform _x; false} count JK_itemsUniform;
{_unit addItemToVest _x; false} count JK_itemsVest;
if (_backpack != "") then {
    {_unit addItemToBackpack _x; false} count JK_itemsBackpack;
};
{_unit addItem _x; false} count JK_items;
if (name _unit in ["joko // Jonas"]) then {
    [_unit, "ACE_insignia_banana"] call BIS_fnc_setUnitInsignia;
} else {
    if (typeName JK_insignium == "ARRAY") then {
        private "_temp";
        _temp = (JK_insignium call BIS_fnc_selectRandom);
        if !(_temp isEqualTo "") then {
            [_unit, _temp] call BIS_fnc_setUnitInsignia;
        };
    } else {
        [_unit, JK_insignium] call BIS_fnc_setUnitInsignia;
    };
};

_unit setVariable ["ace_medical_medicClass", JK_medicClass];
_unit setVariable ["JK_CrateSpawnAllowed", JK_spawnAllowed];
_unit setVariable ["ACE_IsEngineer", JK_isEngineer];
_unit setVariable ["JK_isPilot", JK_isPilot];
_unit setCaptive false;
