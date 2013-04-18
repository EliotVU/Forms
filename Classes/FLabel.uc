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
 * ========================================================
 * FLabel: A rich featured text component.
 * ======================================================== */
class FLabel extends FComponent;

/* LIST OF FONTS
Font'EngineFonts.SmallFont'
Font'EngineFonts.TinyFont'
MultiFont'UI_Fonts.MultiFonts.MF_HugeFont'
MultiFont'UI_Fonts.MultiFonts.MF_HudSmall'
MultiFont'UI_Fonts_Final.HUD.MF_Medium'
*/

var(Label, Display) privatewrite string			Text;
var deprecated Color							TextColor;
var deprecated Font								TextFont;
var deprecated const FontRenderInfo				TextRenderInfo;
var deprecated const Vector2D					TextFontScaling;

var(Label, Display) enum EDecoration
{
	D_None,
	D_Underlined,
	D_Overlined
}												TextDecoration;
var(Label, Display) int							TextDecorationSize;
var(Label, Display) Color						TextDecorationColor;

var(Label, Display) enum EHAlign
{
	TA_Left,
	TA_Center,
	TA_Right
}												TextAlign;

var(Label, Display) enum EVAlign
{
	TA_Top,
	TA_Center,
	TA_Bottom
}												TextVAlign;

var(Label, Positioning) const Vector2D			RelativeOffset;
var(Label, Positioning) bool					bAutoSize;

var private bool bAutoSized;

delegate OnTextChanged( FComponent sender );

function Free()
{
	super.Free();
	OnTextChanged = none;
}

protected function InitializeComponent()
{
	super.InitializeComponent();
	LocalizeText();
}

final private function LocalizeText()
{
	const LOCALIZEDTAG = "@";

	local int idx;
	local array<string> group;
	local string s;

	idx = InStr( Text, LOCALIZEDTAG );
	if( idx != INDEX_NONE )
	{
		s = Mid( Text, idx + Len( LOCALIZEDTAG ) );
		group = SplitString( s, "." );
		Text = Localize( group[1], group[2], group[0] );
	}	
}

final function int GetCharacterIndexAt( float posX )
{
	local int xl, yl;
	local int i, charIndex;
	local string s;

	charIndex = INDEX_NONE;
	if( posX >= 0.0 )
	{
		for( i = 0; i < Len( Text ); ++ i )
		{
			s = Left( Text, i );
			FLabelStyle(Style).TextFont.GetStringHeightAndWidth( s, yl, xl );
			if( posX >= xl )
			{
				charIndex = i + 1;
			}
		}
	}
	return charIndex;
}


protected function RenderComponent( Canvas C )
{
	super.RenderComponent( C );
	RenderLabel( C, LeftX, TopY, WidthX, HeightY, FLabelStyle(Style).TextColor );
}

final protected function RenderLabel( Canvas C, float X, float Y, float W, float H, Color drawColor, optional out float XL, optional out float YL )
{
	local float AX, AY;
//	local float cX, cY;
	local FontRenderInfo renderInfo;
	local FLabelStyle sty;

	sty = FLabelStyle(Style);

	X += RelativeOffset.X;
	Y += RelativeOffset.Y;

	C.Font = sty.TextFont != none ? sty.TextFont : C.GetDefaultCanvasFont();
	if( bClipComponent )
	{
		C.TextSize( Text, XL, YL );	
	}
	else
	{
		C.StrLen( Text, XL, YL );
	}
	
	if( bAutoSize && !bAutoSized )
	{
		// ALT: XL/Parent.GetCachedWidth() or just XL.
		SetSize( XL/GetCachedWidth()*RelativeSize.X, YL/GetCachedHeight()*RelativeSize.Y );
		bAutoSized = true;
	}

	switch( TextAlign )
	{
		case TA_Left:
			AX = X;
			break;

		case TA_Center:
			AX = X + W * 0.5 - XL * 0.5;
			break;

		case TA_Right:
			AX = X + W - XL;
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
	
	//if( TextRenderInfo.bClipText )
	//{
		//cX = XL;
		//cY = YL;
		//StartClipping( C, cX, cY );
	//}

	C.SetPos( AX, AY );
	C.DrawColor = drawColor;
	C.DrawText( Text, false, sty.TextFontScaling.X, sty.TextFontScaling.Y, sty.TextRenderInfo );
	
	//if( TextRenderInfo.bClipText )
	//{
		//StopClipping( C, cX, cY );
	//}
	
	switch( TextDecoration )
	{
		case D_Underlined:	
			C.SetPos( AX, AY + YL - TextDecorationSize );
			C.DrawColor = TextDecorationColor;
			C.DrawRect( XL, TextDecorationSize, C.DefaultTexture );
			break;
			
		case D_Overlined:
			C.SetPos( AX, AY + YL * 0.5 - TextDecorationSize * 0.5 );
			C.DrawColor = TextDecorationColor;
			C.DrawRect( XL, TextDecorationSize, C.DefaultTexture );
			break;
	}
}

function SetText( coerce string newText )
{
	Text = newText;
	LocalizeText();
	
	bAutoSized = false;
	OnTextChanged( self );
}

defaultproperties
{
	RelativePosition=(X=0.01,Y=0.01)
	RelativeSize=(X=0.4,Y=0.18)
	RelativeOffset=(X=0.0,Y=0.0)

	Text="Label"
	TextAlign=TA_Left
	TextVAlign=TA_Center
	TextDecorationSize=1
	TextDecorationColor=(R=255,G=255,B=255,A=255)

	bEnabled=`devmode

	StyleNames.Add(Label)
	StyleClass=class'FLabelStyle'

	bEnableClick=false
	bEnableCollision=false
}