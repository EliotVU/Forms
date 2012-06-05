/*
   Copyright 2012 Eliot van Uytfanghe

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

class FColors extends Object
	abstract;

// Use these colors by using one of the following ways:
// | A class context: "class'FColors'.default.YellowColor"
// | Copy paste those to your class
// | Copy the color values individually

// Unique colors
var const Color BronzeColor;
var const Color SilverColor;
var const Color GoldColor;
var const Color EmeraldColor;

// Dark colors
var const Color BlackColor;
var const Color GrayColor;
var const Color DarkColor;
var const Color AlphaColor;

// Common colors
var const Color YellowColor;
var const Color BlueColor;
var const Color CyanColor;	// A.K.A AquaColor
var const Color TealColor;
var const Color PinkColor;
var const Color PurpleColor;
var const Color BrownColor;
var const Color OrangeColor;

final static function int DecimalFromHex( string hexadecimal )
{
	local string char;
	local int result;
	local int i, j;

	// hexadecimal = PadRight( hexadecimal, 8, "0" )
	i = Len( hexadecimal );
	j = 8 - i;
	while( j > 0 )
	{
		hexadecimal $= "0";
		-- j;
	}
	
	hexadecimal = Caps( hexadecimal );
	j = Len( hexadecimal );
	for( i = 0; i < j; ++ i )
	{
		char = Mid( Left( hexadecimal, i+1 ), i );
		// 55 and 48 = relative position correction to skip the symbols inbetween Z and a
		result = (result << 4) | Asc( char ) - (char > "9" ? 55 : 48);
	}
	return result;
}

final static function Color RGBFromHex( string hexadecimal )
{
	local int rgbInt;
	local Color rgb;

	rgbInt = DecimalFromHex( hexadecimal );
	rgb.R = (rgbInt & 4278190080) >> 24;	
	rgb.G = (rgbInt & 16711680) >> 16;	
	rgb.B = (rgbInt & 65280) >> 8;	
	rgb.A = (rgbInt & 255);	
	return rgb;
}

final static function string HexFromRGB( Color rgb )
{
	return ToHex( rgb.R ) $ ToHex( rgb.G ) $ ToHex( rgb.B ) $ ToHex( rgb.A );
}

defaultproperties
{
	// Unique colors	
	GoldColor=(R=255,G=215,B=0,A=255)
	BronzeColor=(R=205,G=127,B=50)
	SilverColor=(R=201,G=192,B=187)
	EmeraldColor=(R=80,G=200,B=120)

	// Dark colors
	BlackColor=(R=0,G=0,B=0,A=255)
	GrayColor=(R=128,G=128,B=128,A=255)
	DarkColor=(R=64,G=64,B=64,A=0)
	AlphaColor=(A=128)

	// Common colors
	YellowColor=(R=255,G=255,B=0,A=255)
	BlueColor=(B=255,A=255)
	CyanColor=(R=24,G=167,B=181,A=255)
	TealColor=(R=0,G=128,B=128,A=255)
	PinkColor=(R=255,G=192,B=203,A=255)
	PurpleColor=(R=128,G=0,B=128,A=255)
	OrangeColor=(R=255,G=128,B=0,A=255)
	BrownColor=(R=150,G=75,B=0,A=255)
}