untyped
global function CompassInit
global function CreateCustomCompassTracker
global function CreateCustomCompassWaypoint

struct
{
	float size
	float position
	float baseAlpha
	float compassWidth
	int style
	int isEnabled
	vector colour
	var[9] barRUIs
	var centerRUI
	bool isVisible = false
}file

void function CompassInit()
{
	//RegisterButtonPressedCallback(MOUSE_LEFT, aaa) //Callback for debugging
	if( !IsLobby() )
	{
		RegisterSignal( "DestroyTracker" )
		RegisterSignal( "DestroyWaypoints" )
		thread CompassThread()
		//Register the custom signals, for trackers and for waypoints
	}
}

/*
void function aaa(var button) //Debug function, disregard
{
	if(IsValid(GetLocalViewPlayer()))
	{
		float xAngle = GetLocalViewPlayer().EyeAngles().y
		//float angleReduced = angle - ((int(angle)/15) * 15)
		//print(angleReduced) //debugging
		float angle = (GetLocalViewPlayer().EyeAngles().y - 180)*(-1) //View angle in degrees (range -180 to 180 by default, correcting)
		float offset = GetBarOffset(angle)
		//Logger.Info(angle.tostring())
		Logger.Info(angle.tostring()) //correct?
		
		float angleReduced = angle - ((int(angle)/15) * 15)
	
		float temp = ((angleReduced - 7.5) / 7.5) //the result here is a value from -1 to 1
	
		//float offset = 0
	
		//if (temp < 0)
			Logger.Info((((1 - fabs(temp)) * (file.compassWidth/18)) * (-1.0)).tostring())
		//else
			Logger.Info(((1 - temp) * (file.compassWidth/18)).tostring())
		
		Logger.Info(offset.tostring())
		Logger.Info("------------")
	}
}
*/

void function CompassThread()
{
	UpdateSettings()
	
	for(int i = 0; i < 9; ++i)
	{
		file.barRUIs[i] = CreateCompassRUI()
	}
	
	file.centerRUI = CreateCenterRUI()
	
	HideCompass()
	
	while(true)
	{
		WaitFrame()
		
		UpdateSettings() //should be done only after changing mod settings, look for a callback or something
		
		if(ShouldShowCompass())
		{
			UpdateCompassRUIs()
			file.isVisible = true
		}
		else if (file.isVisible)
		{
			HideCompass()
			file.isVisible = false
		}
	}
}


var function CreateCompassRUI()
{
	var rui = RuiCreate( $"ui/cockpit_console_text_center.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, -1 )
	RuiSetInt(rui, "maxLines", 3)
	RuiSetInt(rui, "lineNum", 1)
	RuiSetFloat2(rui, "msgPos", <0,0,0>)
	RuiSetString(rui, "msgText", " | ")
	RuiSetFloat(rui, "msgFontSize", file.size)
	RuiSetFloat(rui, "msgAlpha", file.baseAlpha)
	RuiSetFloat(rui, "thicken", 0.0)
	RuiSetFloat3(rui, "msgColor", <1,1,1>)
	return rui
}

var function CreateCenterRUI()
{
	var rui = RuiCreate( $"ui/cockpit_console_text_center.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, -1 )
	RuiSetInt(rui, "maxLines", 3)
	RuiSetInt(rui, "lineNum", 1)
	RuiSetFloat2(rui, "msgPos", <0,0,0>)
	RuiSetString(rui, "msgText", "\\|/\n   \n   ")
	RuiSetFloat(rui, "msgFontSize", file.size)
	RuiSetFloat(rui, "msgAlpha", file.baseAlpha)
	RuiSetFloat(rui, "thicken", 0.0)
	RuiSetFloat3(rui, "msgColor", <1,1,1>)
	return rui
}

void function UpdateCompassRUIs()
{
	float xAngle = (GetLocalViewPlayer().EyeAngles().y - 180) * (-1) //View angle in degrees (range -180 to 180 by default, correcting)
	float offset = GetBarOffset(xAngle)
	float barPosition
	
	
	if(file.style == 0) //Style: Bars
	{
		for(int i = 0; i<9; ++i)
		{
			//Dynamic stuff
			barPosition = GetBarPosition(i, offset)
			RuiSetFloat2(file.barRUIs[i], "msgPos", <barPosition, file.position, 0>)
			RuiSetFloat(file.barRUIs[i], "msgAlpha", GetBarAlpha(barPosition))
			RuiSetString(file.barRUIs[i], "msgText", "   \n | \n" + GetBarValue(i, xAngle, offset))
			
			//Settings based stuff
			RuiSetFloat(file.barRUIs[i], "msgFontSize", file.size)
			RuiSetFloat3(file.barRUIs[i], "msgColor", file.colour)
		}
		
		//	Center RUI
		RuiSetString(file.centerRUI, "msgText", "\\|/\n   \n   ")
		RuiSetFloat(file.centerRUI, "msgFontSize", file.size)
		RuiSetFloat3(file.centerRUI, "msgColor", file.colour)
		RuiSetFloat(file.centerRUI, "msgAlpha", file.baseAlpha)
		RuiSetFloat2(file.centerRUI, "msgPos", <0, file.position, 0>)
	}
	else if(file.style == 1) //Style: Minimalistic
	{
		for(int i = 0; i<9; ++i)
		{
			//Dynamic stuff
			barPosition = GetBarPosition(i, offset)
			RuiSetFloat2(file.barRUIs[i], "msgPos", <barPosition, file.position, 0>)
			RuiSetFloat(file.barRUIs[i], "msgAlpha", GetBarAlpha(barPosition))
			RuiSetString(file.barRUIs[i], "msgText", "   \n" + GetBarValue(i, xAngle, offset) + "\n   ")
			
			//Settings based stuff
			RuiSetFloat(file.barRUIs[i], "msgFontSize", file.size)
			RuiSetFloat3(file.barRUIs[i], "msgColor", file.colour)
		}
		
		//	Center RUI
		RuiSetString(file.centerRUI, "msgText", "\\|/\n   \n   ")
		//RuiSetString(file.centerRUI, "msgText", "\\|/\n   \n%$r2_ui/menus/loadout_icons/primary_weapon/primary_softball%") //experimental, works
		RuiSetFloat(file.centerRUI, "msgFontSize", file.size)
		RuiSetFloat3(file.centerRUI, "msgColor", file.colour)
		RuiSetFloat(file.centerRUI, "msgAlpha", file.baseAlpha)
		RuiSetFloat2(file.centerRUI, "msgPos", <0, file.position, 0>)
	}
	else //Style: Number
	{
		for(int i = 0; i<9; ++i)
		{
			//Dynamic stuff
			barPosition = GetBarPosition(i, offset)
			RuiSetFloat2(file.barRUIs[i], "msgPos", <barPosition, file.position, 0>)
			RuiSetFloat(file.barRUIs[i], "msgAlpha", GetBarAlpha(barPosition))
			RuiSetString(file.barRUIs[i], "msgText", "   \n" + GetBarValue(i, xAngle, offset) + "\n   ")
			
			//Settings based stuff
			RuiSetFloat(file.barRUIs[i], "msgFontSize", file.size)
			RuiSetFloat3(file.barRUIs[i], "msgColor", file.colour)
		}
		
		//	Center RUI
		int angleNumber = (int(xAngle) + 180)%360 //could be optimized out, don't wanna bother rn so TODO
		
		RuiSetFloat(file.centerRUI, "msgFontSize", file.size)
		RuiSetString(file.centerRUI, "msgText", "\\|/\n   \n" + (angleNumber.tostring().len() == 1 ? " " + angleNumber.tostring() + " " : angleNumber.tostring()))
		RuiSetFloat3(file.centerRUI, "msgColor", file.colour)
		RuiSetFloat(file.centerRUI, "msgAlpha", file.baseAlpha)
		RuiSetFloat2(file.centerRUI, "msgPos", <0, file.position, 0>)
	}
	
}

void function UpdateSettings()
{
	file.style = GetConVarInt("compass_style")
	file.size = GetConVarFloat("compass_size")
	file.position = GetConVarFloat("compass_position") * (-0.57) //correcting for rounder numbers in settings
	file.baseAlpha = GetConVarFloat("compass_base_alpha")
	file.colour = GetConVarFloat3("compass_colour") / 255.0 //for RGB 0-255
	file.compassWidth = GetConVarFloat("compass_width")
	file.isEnabled = GetConVarInt("compass_enable")
}

bool function ShouldShowCompass()
{
	if(file.isEnabled && IsValid(GetLocalViewPlayer()) && IsAlive(GetLocalViewPlayer()))
		return true
	return false
}


void function HideCompass()
{
	foreach(rui in file.barRUIs){
		RuiSetFloat(rui, "msgAlpha", 0)
	}
	
	RuiSetFloat(file.centerRUI, "msgAlpha", 0)
}



float function GetBarOffset(float angle)
{
	float angleReduced = angle - ((int(angle)/15) * 15)
	
	float temp = ((angleReduced - 7.5) / 7.5) //the result here is a value from -1 to 1
	
	float offset = 0
	
	//I forgot what happens here, I'm just glad it works
	if (temp < 0)
		offset = ((1 - fabs(temp)) * (file.compassWidth/18)) * (-1.0)
	else
		offset = (1 - temp) * (file.compassWidth/18)
	
	return offset
}

float function GetBarPosition(int index, float offset)
{
	return (index * file.compassWidth/9 + file.compassWidth/18 + offset) - file.compassWidth/2
}

float function GetBarAlpha(float position)
{
	return file.baseAlpha * ((file.compassWidth/2 - fabs(position)) / (file.compassWidth / 2))
}

string function GetBarValue(int index, float angle, float offset)
{
	//Calculation for bar 4
	
	//We need to move the angle by 180 to face north (could be optimized by moving to the Update function, would require changes to passed args)
	int iAngle = (int(angle) + 180)%360
	
	int result = 0
	if(offset >= 0)
		result = ((iAngle - iAngle%15) + 15)
	else
		result = ((iAngle - iAngle%15)) 
	
	result += 360 //Correction for mirroring close to 0
	
	//Value for other bars:
	result = abs(result + 15 * (index - 4)) % 360
	
	string str = ""
	
	switch (result)
	{
		case 0:
			str = " N "
			break
		case 45:
			str = "NE "
			break
		case 90:
			str = " E "
			break
		case 135:
			str = "SE "
			break
		case 180:
			str = " S "
			break
		case 225:
			str = "SW "
			break
		case 270:
			str = " W "
			break
		case 315:
			str = "NW "
			break
		default:
			if(file.style == 2)
				str = " | "
			else
				str = result.tostring()
				if(str.len() < 3)
					str = str.len() == 1 ? " " + str + " " : str + " "
			break
	}
	
	return str
}

//Stolen from 4V (thanks nerd)
vector function GetConVarFloat3(string convar)
{
    array<string> value = split(GetConVarString(convar), " ")
    try{
        return Vector(value[0].tofloat(), value[1].tofloat(), value[2].tofloat()) 
    }
    catch(ex){
        throw "Invalid convar " + convar + "! make sure it is a float3 and formatted as \"X Y Z\""
    }
    unreachable
}

//==================================================================================================================

//Functions for creating custom compass markers
void function CreateCustomCompassTracker( entity target, string imagePath, float imageScaleModifier, vector colour, int compassRow )
{
	var rui = CreateCompassRUI()
	string ruiString = ""
	
	switch( compassRow )
	{
		case 1:
			ruiString = "%" + imagePath + "%\n\n"
			break
		case 2:
			ruiString = "\n%" + imagePath + "%\n"
			break
		default:
			ruiString = "\n\n%" + imagePath + "%"
			break
	}
	
	RuiSetString(rui, "msgText", ruiString )
	RuiSetFloat3(rui, "msgColor", colour )
	
	thread MaintainCustomCompassTracker( target, rui, imageScaleModifier )
}


void function CreateCustomCompassWaypoint( vector position, string imagePath, float imageScaleModifier, vector colour, int compassRow )
{
	var rui = CreateCompassRUI()
	string ruiString = ""
	
	switch( compassRow )
	{
		case 1:
			ruiString = "%" + imagePath + "%\n\n"
			break
		case 2:
			ruiString = "\n%" + imagePath + "%\n"
			break
		default:
			ruiString = "\n\n%" + imagePath + "%"
			break
	}
	
	RuiSetString(rui, "msgText", ruiString )
	RuiSetFloat3(rui, "msgColor", colour )
	
	thread MaintainCustomCompassWaypoint( position, rui, imageScaleModifier )
}
//Remember to add these newly created ruis to an array, which we will use to hide them with the HideCompass function, or use ShouldShowCompass
//Might turn out to not be necessary


//Funcs for maintaining the RUIs, they run as threads and update/delete them
void function MaintainCustomCompassTracker( entity target, var rui, float imageScaleModifier ) //add more args
{
	target.EndSignal( "OnDestroy" )
	//target.EndSignal( "OnDeath" )
	target.EndSignal( "DestroyTracker" )
	
	vector vec
	vector newAngles
	float angle
	float imagePosition
	bool isVisible = true
	
	
	//DEBUG
	//thread kys(target)
	//DEBUG END
	
	
	OnThreadEnd(
		function() : ( rui )
		{
			Logger.Info("Thread ended!")
			if(rui != null)
			{
				RuiDestroyIfAlive(rui)
			}
		}
	)
	
	for(;;)
	{
		WaitFrame()
		
		vec =  target.GetOrigin() - GetLocalClientPlayer().GetOrigin()
		newAngles = VectorToAngles( vec )
		//Logger.Info((360.0 - newAngles.y).tostring()) //Y is our argument
		//East and west are swapped
		//The rotation is in the opposite direction
		//adding 360.0 - fixed it
		angle = 360.0 - newAngles.y
		
		imagePosition = GetImagePosition( angle )
		
		RuiSetFloat2(rui, "msgPos", < imagePosition, file.position, 0 > )
		RuiSetFloat(rui, "msgAlpha", GetImageAlpha( imagePosition ) )
		RuiSetFloat(rui, "msgFontSize", file.size * imageScaleModifier )
	}
	
}


void function MaintainCustomCompassWaypoint( vector position, var rui, float imageScaleModifier )
{
	GetLocalClientPlayer().EndSignal( "DestroyWaypoints" )
	
	vector vec
	vector newAngles
	float angle
	float imagePosition
	bool isVisible = true
	
	OnThreadEnd(
		function() : ( rui )
		{
			Logger.Info("Thread ended!")
			if(rui != null)
			{
				RuiDestroyIfAlive(rui)
			}
		}
	)
	
	for(;;)
	{
		WaitFrame()
		
		vec =  position - GetLocalClientPlayer().GetOrigin()
		newAngles = VectorToAngles( vec )
		angle = 360.0 - newAngles.y
		
		imagePosition = GetImagePosition( angle )
		
		RuiSetFloat2(rui, "msgPos", < imagePosition, file.position, 0 > )
		RuiSetFloat(rui, "msgAlpha", GetImageAlpha( imagePosition ) )
		RuiSetFloat(rui, "msgFontSize", file.size * imageScaleModifier )
	}
}


float function GetImagePosition(float angle)
{
	float eyeAngle = fmod(((GetLocalViewPlayer().EyeAngles().y - 180) * (-1.0)) + 180.0, 360.0)
	float x = angle - eyeAngle
	float uDiff = min( fabs(x), fabs( fabs(x) - 360.0 ) )

	//Nasty-ass fuckin math
	float diff = uDiff //temporary assignment in case of :clueless:
	float eyeAngle2 = fmod( (eyeAngle + 180), 360.0 )
	
	if(eyeAngle > 180)
	{
		if( (angle >= 0 && angle <= eyeAngle2) || (angle > eyeAngle && angle < 360) )
			diff = uDiff
		else
			diff = uDiff * (-1.0)
	}
	else
	{
		if( (angle >= 0 && angle <= eyeAngle) || (angle > eyeAngle2 && angle < 360) )
			diff = uDiff * (-1.0)
		else
			diff = uDiff
	}
	
	return (diff / 67.5) * (file.compassWidth / 2)
}


float function GetImageAlpha(float position)
{
	return file.baseAlpha * ((file.compassWidth/2 - fabs(position)) / (file.compassWidth / 2))
}


float function fmod( float x, float y ) //the fuck
{
	return x - y * int(x / y)
}


/*
void function kys(entity target) //debug thread aaaaa
{
	target.EndSignal( "OnDestroy" )
	//target.EndSignal( "OnDeath" )
	target.EndSignal( "DestroyTracker" )
	
	for(;;)
	{
		wait 3
		Logger.Info("============")
		Logger.Info("EYE: " + (fmod(((GetLocalViewPlayer().EyeAngles().y - 180) * (-1.0)) + 180.0, 360.0)).tostring())
		//Eye func is wrong
		vector newAngles = VectorToAngles(target.GetOrigin() - GetLocalClientPlayer().GetOrigin())
		Logger.Info("POSu: " + newAngles.y.tostring())
		float angle = 360.0 - newAngles.y
		Logger.Info("POS: " + angle.tostring())
	}
}
*/


//Idea:
//Create a function that creates an icon on the compass for any entity, using an image the path to which is passed as an arg
//it could return the RUI var, but that might cause issues, we'll see
//void function CreateCustomCompassMarker(entity target, string imagePath, float imageScale)
//
//Register a new signal for the entity, so that the marker can be manually removed (put it in the init of this mod)
//RegisterSignal( "DestroyMarker" )
//
//New functions for calculating position and alpha
//RUI gets created in the function, and then is maintained in a newly created thread
//The thread should end based on any of the 2 Signals: "OnDestroy" or "DestroyMarker"
//OnThreadEnd delete the RUI
//
//If target goes outside compass range, ignore position and set visibility/alpha to 0
//
//All of that would allow the compass to be used as a dependency, and people could track any objects on it, such as batteries and teammates
//Patches could be used as generic images as they already look like map markers
//
//overhead_icon_generic has image scaling, would be viable here,but it doesn't have alpha
//basic_image doesn't have scale and position for some reason
//fw_base_marker has everything, but might be overkill, and idk if pos refers to world pos or screen pos
//loadout_image_large and loadout_image_medium exist, but do not have position
//could attempt with text center or announcement and just give it the image path as string, worked in serverside announcements
//need to find the discord discussion where that was done, i participated in it and suggested softball as an icon
//found it
//NSSendAnnouncementMessageToPlayer(player, "%%$r2_ui/menus/loadout_icons/primary_weapon/primary_softball%%", "deez nuts", <255, 0, 0>, 1, 0);


//TODO:
//Add an empty style, with no bars or numbers, for just custom markers
//Add a variant of the number style without bars
//Add colour to passed args in CreateCustomCompassTracker [DONE]
//Add conditions to Maintain functions for handling enabled/disabled compass

/*

New list of ideas
Make a struct for configuring and manipulating the custom marker, for both trackers and waypoints
entity target, string imagePath, float imageScaleModifier, vector colour, int compassRow

global struct CustomCompassMarker
{
	var rui                              // contains the RUI in the returned struct
	entity target                        // target entity, used with CreateCustomCompassTracker
	vector position                      // target location, used with CreateCustomCompassWaypoint
	string imagePath                     // 
	float imageScaleModifier             // 
	vector colour                        // 
	int compassRow                       // 3 rows
										 
	float baseAlphaModifier              // 
	bool fadeWithDistance                // 
	float maxVisibleDistance             // in HU
	bool fadeWithTime                    // 
	float startTime                      // in seconds
	float duration                       // in seconds
}

Pass the "create" function the struct, and make it return it, that way the modder has access to the RUI and its properties all the time
This WILL cause a memory leak, but it will be dismissable if it's not being called in a loop
(Structs returned by functions seem to not get cleaned up even if overwritten, cannot be manually deleted, perhaps the fix is to go out of scope, that is to leave the function where the create func was called)

Make validity checks, don't remember now in what context, but they will be necessary
if not null destroy if alive

Increase the mod priority, set it to 1 or 0
Make sure the mods that use it have priority of 2 or higher
Figure out the dependency constant to be used in mods that depend on compass so that they do not cause errors when used without it

Pass isVisible to GetImageAlpha, that way handling toggling will be easier

*/