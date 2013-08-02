/* ========================================================
 * Copyright 2012-2013 Eliot van Uytfanghe
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ======================================================== */
class FSlider extends FScrollComponent;

var(Slider, Display) const FontRenderInfo TextRenderInfo;
var(Slider, Display) string PreFix, PostFix;

protected function RenderSlider( Canvas C )
{
	local float XL, YL;
	local float sliderX;
	local string S;
	local string cur, max;
	local float trackWidth;
	local FScrollStyle myStyle;
	
	myStyle = FScrollStyle(Style);
	Assert( myStyle != none );

	cur = bDynamic ? string(Value) : string(CalcValue());
	max = string(MaxValue);
	if( bInteger )
	{
		cur = string(int(cur));
		max = string(int(max));
	}
	else if( !bSliding || SnapPower % 0.1 == 0.00 )
	{
		cur = Left( cur, Len( cur ) - 2 );
		max = Left( max, Len( max ) - 2 );
	}
		
	// Progress bar
	trackWidth = SizeX*0.06;
	sliderX = FClamp( 
		bSliding ? SizeX*(GetSliderBegin()/GetSliderEnd()) : Value/MaxValue*GetSliderEnd(), 0.0,
		SizeX - trackWidth 
	) - trackWidth*0.5;

	// Tracker
	C.SetPos( PosX + sliderX + trackWidth*0.5, PosY );
	C.DrawColor = bSliding ? GetStateColor() : myStyle.TrackImageColor;
	myStyle.DrawTracker( C, trackWidth, SizeY );

	// Label
	S = PreFix $ cur $ PostFix $ "/" $ PreFix $ max $ PostFix;
	C.StrLen( S, XL, YL );
	C.SetPos( PosX + SizeX*0.5 - XL*0.5, PosY + (SizeY*0.5 - YL*0.5) );
	C.DrawColor = GetStateColor();
	C.DrawText( S, false, 1.0, 1.0, TextRenderInfo );
}

defaultproperties
{
	RelativePosition=(X=0.0,Y=0.0)
	RelativeSize=(X=0.4,Y=0.18)

	TextRenderInfo=(bClipText=true)

	SnapPower=0.1

	StyleNames.Add(Slider)
}