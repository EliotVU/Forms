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
class FLabel extends FComponent;

var(Component, Display) privatewrite string Text;
var(Component, Display) Color TextColor;
var(Component, Display) const Font TextFont;
var(Component, Display) const FontRenderInfo TextRenderInfo;
var(Component, Display) const Vector2D TextFontScaling;

var(Component, Display) enum EHAlign
{
	TA_Left,
	TA_Center,
	TA_Right
} TextAlign;

var(Component, Display) enum EVAlign
{
	TA_Top,
	TA_Center,
	TA_Bottom
} TextVAlign;

var(Component, Positioning) const Vector2D RelativeOffset;

delegate OnTextChanged( FComponent sender );

function RenderComponent( Canvas C )
{
	super.RenderComponent( C );
	RenderLabel( C, LeftX, TopY, WidthX, HeightY, TextColor );
}

final function RenderLabel( Canvas C, float X, float Y, float W, float H, Color drawColor, optional out float XL, optional out float YL )
{
	local float AX, AY;

	X += RelativeOffset.X;
	Y += RelativeOffset.Y;

	//if( bClipComponent )
	//{
		//C.TextSize( Text, XL, YL );	
	//}
	//else
	//{
		C.StrLen( Text, XL, YL );
	//}

	switch( TextAlign )
	{
		case TA_Left:
			AX = X;
			break;

		case TA_Center:
			AX = X + W * 0.5 - XL * 0.5;
			break;

		case TA_Right:
			AX = -X + (W - XL);
			break;
	}

	switch( TextVAlign )
	{
		case TA_Top:
			AY = Y;
			break;

		case TA_Center:
			AY = (Y + H * 0.5 - YL * 0.5);
			break;

		case TA_Bottom:
			AY = Y + H - YL;
			break;
	}

	C.SetPos( AX, AY );
	C.DrawColor = drawColor;
	C.Font = TextFont != none ? TextFont : C.GetDefaultCanvasFont();
	C.DrawText( Text, true, TextFontScaling.X, TextFontScaling.Y, TextRenderInfo );
}

function SetText( string newText )
{
	Text = newText;
	OnTextChanged( self );
}

defaultproperties
{
	RelativePosition=(X=0.01,Y=0.01)
	RelativeSize=(X=0.4,Y=0.18)
	RelativeOffset=(X=0.0,Y=0.0)

	Text="Label"
	TextColor=(R=255,G=255,B=255,A=255)
	TextAlign=TA_Left
	TextVAlign=TA_Center

	TextRenderInfo=(bClipText=true)
	TextFontScaling=(X=1.0,Y=1.0)

	`if( `isdefined( DEBUG ) )
		bEnabled=true
	`else
		// Disable any interaction
		bEnabled=false
	`endif

	bClipComponent=true
}