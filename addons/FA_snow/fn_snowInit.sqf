// EXIT POINT
// This mod should not be loaded on clients
if !isServer exitWith{};

0 spawn {
	// wait for FA3 conditions to complete
	sleep 1;
	// Detect relevant information
	private _FA3version = parseNumber (([missionConfigFile, "fa3_version",[0,0,0]] call BIS_fnc_returnConfigEntry) joinString "");
	private _isFA3snow = ((missionNamespace getVariable ["f_param_weather",0]) in [9,10]) && (_FA3version > 356);
	private _isFA3coldBreath = ((ambientTemperature select 0) < 6) && (_FA3version > 356);

	// EXIT POINT
	// if FA3 snow is running, it already does all the stuff we need
	if _isFA3snow exitWith {};

	// set mission conditions to FA3.5.7 light snow (https://github.com/folkarps/F3/releases/tag/v3.5.7)
	_MissionOvercast = 0.8;
	_MissionRain = 0.5;
	_MissionRainbow = 0;
	_MissionLightnings = 0;
	_MissionWindStr = 0.05;
	_MissionWindGusts = 0.05;
	_MissionWaves = 0.1;
	_MissionFogStrength = 0.15;
	_MissionFogDecay = 0.002;
	_MissionFogBase = 0;
	[
		"a3\data_f\snowflake16_ca.paa", // rainDropTexture
		16, // texDropCount
		0.01, // minRainDensity
		40, // effectRadius - decreases density as turned up
		0.5, // windCoef
		2.1, // dropSpeed
		0.5, // rndSpeed
		0.5, // rndDir
		0.06, // dropWidth
		0.06, // dropHeight
		[1, 1, 1, 1.25], // dropColor
		0.1, // lumSunFront
		0.2, // lumSunBack
		0.5, // refractCoef
		0.5, // refractSaturation
		true, // snow
		false // dropColorStrong
	] call BIS_fnc_setRain;
	setHumidity 0.9; // no dust clouds, has to be set manually because snow-flagged rain doesn't automatically increase humidity
	enableEnvironment [false, true]; // remove wildlife

	0 setOvercast  _MissionOvercast;
	0 setRain _MissionRain;
	0 setRainbow _MissionRainbow;
	0 setLightnings _MissionLightnings;

	0 setWindStr  _MissionWindStr;
	0 setWindForce _MissionWindGusts;
	0 setWaves _MissionWaves;

	0 setFog [_MissionFogStrength,_MissionFogDecay,_MissionFogBase];

	forceWeatherChange;
	
	// EXIT POINT
	// if FA3 coldbreath is already running, leave it alone
	if _isFA3coldBreath exitWith {};

	// EXIT POINT
	// if FA3 coldbreath is available, use that
	if !(isNil "f_fnc_coldBreath") exitWith {
		0 remoteExec ["f_fnc_coldBreath",[0,-2] select isDedicated];
	};

	// if not, replicate it
	f_fnc_coldBreath = compileFinal {
		f_var_coldBreathLoop = true;

		f_fnc_coldBreathLoop = compileFinal {
			while {alive _this && f_var_coldBreathLoop} do {
				if (vehicle _this == _this) then {
					sleep (4*(1 - getFatigue _this) + random 1);
					drop [["\A3\data_f\ParticleEffects\Universal\Universal", 16, 12, 8,1], "", "Billboard", 1,
					   (1-((vectorMagnitude velocity _this) / 35)) *.75 max .05,
					   _this selectionPosition "Head" vectorAdd [0,.02,0],
					   velocityModelSpace _this vectorAdd [0, .1, 0], 1, 1.3, 1, .01, [.1,.25,.33,.4], [[1, 1, 1, 0.25],[1, 1, 1, 0]], [1], 1, 0, "", "", _this];
					drop [["\A3\data_f\ParticleEffects\Universal\Universal", 16, 12, 8,1], "", "Billboard", 1,
					  (1-((vectorMagnitude velocity _this) / 35)) *.75 max .05,
					  _this selectionPosition "Head" vectorAdd [0,.02,0],
					  velocityModelSpace _this vectorAdd [0, .15, 0], 1, 1.3, 1, .01, [.1,.22,.3,.35], [[1, 1, 1, 0.25],[1, 1, 1, 0]], [1], 1, 0, "", "", _this];
				};
			};
		};

		{
		   _x spawn f_fnc_coldBreathLoop;
		} forEach allUnits;

		addMissionEventHandler ["EntityCreated",{
			params ["_entity"];
			if (_entity isKindOf "CAManBase") then {
				_entity spawn f_fnc_coldBreathLoop;
			};
		}];
	};
	publicVariable "f_fnc_coldBreath";
	0 remoteExec ["f_fnc_coldBreath",[0,-2] select isDedicated, true];
};