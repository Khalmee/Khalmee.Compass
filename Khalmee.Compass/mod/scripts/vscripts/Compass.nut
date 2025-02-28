untyped
global function CompassInit

struct
{
	float size
	float position
	float baseAlpha
	float screenX
	float screenY
	float compassWidth
	int style
	vector colour
	var[9] barRUIs
	var centerRUI
	bool isVisible = false
}file

void function CompassInit()
{
	RegisterButtonPressedCallback(MOUSE_LEFT, aaa)
	thread CompassThread()
}

void function aaa(var button)
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

void function CompassThread()
{
	file.screenX = GetScreenSize()[0]
	file.screenY = GetScreenSize()[1]
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
			/*
			if(!file.isVisible) //might be redundant, TODO: check this afterwards
			{
				ShowCompass()
				file.isVisible = true
			}
			*/
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
	RuiSetString(rui, "msgText", "|")
	RuiSetFloat(rui, "msgFontSize", file.size)
	RuiSetFloat(rui, "msgAlpha", file.baseAlpha)
	RuiSetFloat(rui, "thicken", 0.0)
	RuiSetFloat3(rui, "msgColor", <1,1,1>)
	//experimental
	RuiSetString(rui, "msgAlign", "Center")
	return rui
}

var function CreateCenterRUI()
{
	var rui = RuiCreate( $"ui/cockpit_console_text_center.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, -1 )
	RuiSetInt(rui, "maxLines", 3)
	RuiSetInt(rui, "lineNum", 1)
	RuiSetFloat2(rui, "msgPos", <0,0,0>)
	RuiSetString(rui, "msgText", "\\/\n\n")
	RuiSetFloat(rui, "msgFontSize", file.size)
	RuiSetFloat(rui, "msgAlpha", file.baseAlpha)
	RuiSetFloat(rui, "thicken", 0.0)
	RuiSetFloat3(rui, "msgColor", <1,1,1>)
	RuiSetString(rui, "msgAlign", "Center")
	return rui
}

void function UpdateCompassRUIs()
{
	//	Bar RUIs
	//
	// Each bar has an assigned position within a certain range
	// There are 9 bars in total
	// Bars closer to the edge get less visible
	// Each RUI has 3 lines
	// Line 1 serves as an offset for the center marker
	// Line 2 contains the bar
	// Line 3 contains a number (1 - 360, with the offset of 15) or the directional symbol: N, NE, E, etc.
	
	float xAngle = (GetLocalViewPlayer().EyeAngles().y - 180) * (-1) //View angle in degrees (range -180 to 180 by default, correcting)
	float offset = GetBarOffset(xAngle)
	float barPosition
	
	
	for(int i = 0; i<9; ++i)
	{
		//file.barRUIs[i]

		//Dynamic stuff
		barPosition = GetBarPosition(i, offset)
		//RuiSetInt(file.barRUIs[i], "lineNum", 3) //might need to put this in different places
		RuiSetFloat2(file.barRUIs[i], "msgPos", <barPosition, file.position, 0>)
		RuiSetFloat(file.barRUIs[i], "msgAlpha", GetBarAlpha(barPosition))
		//RuiSetString(file.barRUIs[i], "msgText", GetBarValue(i, xAngle, offset))
		RuiSetString(file.barRUIs[i], "msgText", "\n|\n" + GetBarValue(i, xAngle, offset))

		//Settings based stuff
		RuiSetFloat(file.barRUIs[i], "msgFontSize", file.size)
		RuiSetFloat3(file.barRUIs[i], "msgColor", file.colour)

		//RuiSetInt(file.barRUIs[i], "lineNum", 2)
		//RuiSetFloat(file.barRUIs[i], "msgAlpha", GetBarAlpha(barPosition))

	}

	//	Center RUI
	//
	// Alpha, position and size need to be updated

	RuiSetFloat(file.centerRUI, "msgFontSize", file.size)
	RuiSetFloat3(file.centerRUI, "msgColor", file.colour)
	RuiSetFloat(file.centerRUI, "msgAlpha", file.baseAlpha)
	RuiSetFloat2(file.centerRUI, "msgPos", <0, file.position, 0>)
	//RuiSetInt(file.centerRUI, "currentLineNum", 1)
	//RuiSetString(file.centerRUI, "msgText", "\\/")
	//RuiSetInt(file.centerRUI, "currentLineNum", 3)
	//RuiSetString(file.centerRUI, "msgText", int(xAngle).tostring())
	//RuiSetInt(file.centerRUI, "currentLineNum", 1)
	//RuiSetString(file.centerRUI, "msgText", "\\/\n\n" + int(xAngle).tostring())
	
	/*
	if(file.style == 0) //Style: Bars
	{
		for(int i = 0; i<9; ++i)
		{
			//file.barRUIs[i]
			//Dynamic stuff
			barPosition = GetBarPosition(i, offset)
			RuiSetInt(file.barRUIs[i], "lineNum", 2) //might need to put this in different places
			RuiSetFloat2(file.barRUIs[i], "msgPos", <barPosition, file.position, 0>)
			RuiSetFloat(file.barRUIs[i], "msgAlpha", GetBarAlpha(barPosition))
			RuiSetString(file.barRUIs[i], "msgText", "|\n" + GetBarValue(i, xAngle, offset))
			
			//Settings based stuff
			RuiSetFloat(file.barRUIs[i], "msgFontSize", file.size)
			RuiSetFloat3(file.barRUIs[i], "msgColor", file.colour)
		}
		
		//	Center RUI
		//RuiSetInt(file.centerRUI, "lineNum", 1)
		//RuiSetString(file.centerRUI, "msgText", "\\/\n\n")
		//RuiSetFloat(file.centerRUI, "msgFontSize", file.size)
		//RuiSetFloat3(file.centerRUI, "msgColor", file.colour)
		//RuiSetFloat(file.centerRUI, "msgAlpha", file.baseAlpha)
		//RuiSetFloat2(file.centerRUI, "msgPos", <0, file.position, 0>)
	}
	else if(file.style == 1) //Style: Minimalistic
	{
		for(int i = 0; i<9; ++i)
		{
			//file.barRUIs[i]
			//Dynamic stuff
			barPosition = GetBarPosition(i, offset)
			RuiSetInt(file.barRUIs[i], "lineNum", 2) //might need to put this in different places
			RuiSetFloat2(file.barRUIs[i], "msgPos", <barPosition, file.position, 0>)
			RuiSetFloat(file.barRUIs[i], "msgAlpha", GetBarAlpha(barPosition))
			RuiSetString(file.barRUIs[i], "msgText", GetBarValue(i, xAngle, offset))
			
			//Settings based stuff
			RuiSetFloat(file.barRUIs[i], "msgFontSize", file.size)
			RuiSetFloat3(file.barRUIs[i], "msgColor", file.colour)
		}
		
		//	Center RUI
		//RuiSetInt(file.centerRUI, "lineNum", 1)
		//RuiSetString(file.centerRUI, "msgText", "\\/\n\n")
		//RuiSetFloat(file.centerRUI, "msgFontSize", file.size)
		//RuiSetFloat3(file.centerRUI, "msgColor", file.colour)
		//RuiSetFloat(file.centerRUI, "msgAlpha", file.baseAlpha)
		//RuiSetFloat2(file.centerRUI, "msgPos", <0, file.position, 0>)
	}
	else //Style: Number
	{
		for(int i = 0; i<9; ++i)
		{
			//file.barRUIs[i]
			//Dynamic stuff
			barPosition = GetBarPosition(i, offset)
			RuiSetInt(file.barRUIs[i], "lineNum", 1) //might need to put this in different places
			RuiSetFloat2(file.barRUIs[i], "msgPos", <barPosition, file.position, 0>)
			RuiSetFloat(file.barRUIs[i], "msgAlpha", GetBarAlpha(barPosition))
			RuiSetString(file.barRUIs[i], "msgText", GetBarValue(i, xAngle, offset) + "\n")
			
			//Settings based stuff
			RuiSetFloat(file.barRUIs[i], "msgFontSize", file.size)
			RuiSetFloat3(file.barRUIs[i], "msgColor", file.colour)
		}
		
		//	Center RUI
		//RuiSetInt(file.centerRUI, "lineNum", 1)
		//RuiSetFloat(file.centerRUI, "msgFontSize", file.size)
		//RuiSetString(file.centerRUI, "msgText", "\\/\n\n" + int(xAngle).tostring())
		//RuiSetFloat3(file.centerRUI, "msgColor", file.colour)
		//RuiSetFloat(file.centerRUI, "msgAlpha", file.baseAlpha)
		//RuiSetFloat2(file.centerRUI, "msgPos", <0, file.position, 0>)
	}
	*/
	
}

void function UpdateSettings()
{
	//TODO: Get from ConVars
	file.style = GetConVarInt("compass_style")
	
	
	//for debugging, default values
	file.size = 24
	file.position = 0
	file.baseAlpha = 1
	file.colour = <1,1,1>
	file.compassWidth = 0.5
	//file.style = 0
}

bool function ShouldShowCompass()
{
	if(!IsLobby() && IsValid(GetLocalViewPlayer()) && IsAlive(GetLocalViewPlayer()))
		return true
	return false
}

void function ShowCompass()
{
	foreach(rui in file.barRUIs){
		RuiSetFloat(rui, "msgAlpha", file.baseAlpha)
	}
	
	RuiSetFloat(file.centerRUI, "msgAlpha", file.baseAlpha)
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
	
	if (temp < 0)
		offset = ((1 - fabs(temp)) * (file.compassWidth/18)) * (-1.0)
	else
		offset = (1 - temp) * (file.compassWidth/18)
	
	return offset
	//for x in range of -1 to 1, where the lowest result should be... 
}

float function GetBarPosition(int index, float offset) //needs fixing, angle is not included in the calculations
{
	//this looks correct, but incomplete:
	//(index * file.compassWidth/9 + file.compassWidth/18 + offset) - file.compassWidth/2
	return (index * file.compassWidth/9 + file.compassWidth/18 + offset) - file.compassWidth/2
}

float function GetBarAlpha(float position)
{
	return file.baseAlpha * ((file.compassWidth/2 - fabs(position)) / (file.compassWidth / 2))
}

string function GetBarValue(int index, float angle, float offset)
{
	//Calculation for bar 4
	
	//We need to move the angle by 180 to face north
	int iAngle = (int(angle) + 180)%360
	
	int result = 0
	if(offset >= 0)
		result = ((iAngle - iAngle%15) + 15)
	else
		result = ((iAngle - iAngle%15)) 
		
	//Value for other bars:
	result = abs(result + 15 * (index - 4)) % 360
	
	string str = ""
	
	switch (result)
	{
		case 0:
			str = "N"
			break
		case 45:
			str = "NE"
			break
		case 90:
			str = "E"
			break
		case 135:
			str = "SE"
			break
		case 180:
			str = "S"
			break
		case 225:
			str = "SW"
			break
		case 270:
			str = "W"
			break
		case 315:
			str = "NW"
			break
		default:
			if(file.style == 2)
				str = "|"
			else
				str = result.tostring()
			break
	}
	
	return str
}

//TODO:
//Implement 3 styles:
//- minimalistic (current)
//- bars (target)
//- number (modernized)
// This can be done by messing with the RUI
//Implement customizability:
// Hook up mod settings, fix the update function
//Clean up the comments

//Issues:
//By manipulating the line numbers and the GetBarValue function I somehow broke the layout, can't quite figure out how to place the text in the spot i want it to be
//The problems began after adding stuff to the center RUI
//LOOK INTO: a4_structs.c, line 929

/*
struct ruiDataStruct_cockpit_console_text_center
{
  BYTE gap_0[24];
  float msgColor[3];
  float msgFontSize;
  float thicken;
  float msgPos[2];
  float msgAlpha;
  char* msgText;
  char* msgText2;
  char* msgAlign;
  int lineNum;
  int maxLines;
  float lineHoldtime;
  int autoMove;
  int initialized;
  int currentLineNum;
  float startTime;
  BYTE gap_6c[28];
};
*/