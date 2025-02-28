untyped
global function CompassModSettingsHookup

void function CompassModSettingsHookup()
{
	ModSettings_AddModTitle("Compass")
	ModSettings_AddModCategory("General settings")
	ModSettings_AddEnumSetting("compass_enable", "Enable compass", [ "Disabled", "Enabled" ])
	ModSettings_AddEnumSetting("compass_style", "Compass style", [ "Bars", "Minimalistic", "Number" ])
	ModSettings_AddSliderSetting( "compass_position", "Compass position (offset from the center)", -1, 1, 0.01, false)
	ModSettings_AddSliderSetting( "compass_width", "Compass width", 0, 1, 0.01, false)
	ModSettings_AddSliderSetting( "compass_size", "Compass size", 1, 100, 0.1, false)
	ModSettings_AddSliderSetting( "compass_base_alpha", "Compass base alpha", 0, 1, 0.01, false)
	ModSettings_AddSetting("compass_colour", "Compass colour (RGB, 0-255)", "vector")

}