class CfgPatches
{
	class fa_snow
	{
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.2;
		requiredAddons[] = {};
		author = "NikkoJT, darkChozo, Ciaran";
	};
};

class cfgFunctions
{
	class fa_snow
	{
		class functions
		{
			file = "fa_snow";
			class snowInit
			{
				postInit = 1;
			};
		};
	};
};