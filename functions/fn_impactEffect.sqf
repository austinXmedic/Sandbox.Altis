private["_unit", "_strength", "_power", "_color"];
_unit = _this select 0;
_strength = _this select 1;

if (!(_unit == player)) exitWith {};

if (vehicle _unit == _unit && {cameraView in ["INTERNAL","GUNNER"]}) then {
	if (_strength < 0.2) then {_strength = 0.2 + (random 0.3)};
	if (_strength > 5) then {_strength = 4 + (random 1)};

	_power = _strength + 4;
	addCamShake [_power, 0.4, 30];
	
	if(_strength > 4) then
	{
		playSound "combat_deafness";
	};

	_color = 1 - _strength;
	if (_color < 0.15) then {_color = 0.15};

	"colorCorrections" ppEffectEnable true;
	"colorCorrections" ppEffectAdjust [1, 1, 0, [1, 1, 1, 0.0], [1, 1, 1, _color],  [1, 1, 1, 0.0]];
	"colorCorrections" ppEffectCommit 0;

	"dynamicBlur" ppEffectEnable true;
	"dynamicBlur" ppEffectAdjust [1.8];
	"dynamicBlur" ppEffectCommit 0;

	"colorCorrections" ppEffectAdjust [1, 1, 0, [1, 1, 1, 0.0], [1, 1, 1, 1],  [1, 1, 1, 0.0]];
	"colorCorrections" ppEffectCommit _strength;

	"dynamicBlur" ppEffectAdjust [0];
	"dynamicBlur" ppEffectCommit _strength;
};

true