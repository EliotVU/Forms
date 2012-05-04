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
class FSlider extends FScrollComponent;

var(Component, Display) const FontRenderInfo TextRenderInfo;

function RenderSlider( Canvas C )
{
	local float XL, YL;
	local float sliderX;
	local string S;

	if( Style != none )
	{
		if( bSliding )
		{
			sliderX = FClamp( WidthX*(RelativeMousePosition.X/WidthX), 0.0, WidthX - WidthX*0.02 ) - WidthX*0.02 * 0.5;
			C.DrawColor = Style.FocusColor;

			S = (RelativeMousePosition.X/WidthX)*MaxValue $ "/" $ MaxValue;
		}
		else
		{
			sliderX = FClamp( (Value/MaxValue*WidthX), 0.0, WidthX - WidthX*0.02 ) - WidthX*0.02 * 0.5;
			C.DrawColor = Style.HoverColor;

			S = Value $ "/" $ MaxValue;
		}	

		if( Style.Image != none )
		{
			C.SetPos( LeftX, TopY );
			C.DrawTileStretched( Style.Image, sliderX, HeightY, 0, 0, Style.Image.SizeX, Style.Image.SizeY );
		}

		C.SetPos( LeftX + sliderX, TopY );
		C.DrawTileStretched( ProgressImage, WidthX*0.02, HeightY, 0, 0, ProgressImage.SizeX, ProgressImage.SizeY );

		C.StrLen( S, XL, YL );
		C.SetPos( LeftX + WidthX * 0.5 - XL * 0.5, TopY + (HeightY * 0.5 - YL * 0.5) );
		C.DrawColor = GetStateColor();
		C.DrawText( S, false, 1.0, 1.0, TextRenderInfo );
	}
}

function StopSliding()
{
	UpdateValue();
	SetValue( (RelativeMousePosition.X/WidthX)*MaxValue );
	bSliding = false;
}

defaultproperties
{
	RelativePosition=(X=0.0,Y=0.0)
	RelativeSize=(X=0.4,Y=0.18)

	TextRenderInfo=(bClipText=true)
}