untyped
global function CompassModSettingsHookup

void function CompassModSettingsHookup()
{
	ModSettings_AddModTitle("Compass")
	ModSettings_AddModCategory("General settings")
	ModSettings_AddSetting("compass_size", "Compass size", "float")
	ModSettings_AddSliderSetting( "compass_position", "Compass position (0 = top of the screen)", 0, 1, 0.01, false)
	ModSettings_AddSliderSetting( "compass_base_alpha", "Compass base alpha", 0, 1, 0.01, false)

}