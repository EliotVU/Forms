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

/* LIST OF FONTS
Font'EngineFonts.SmallFont'
Font'EngineFonts.TinyFont'
MultiFont'UI_Fonts.MultiFonts.MF_HugeFont'
MultiFont'UI_Fonts.MultiFonts.MF_HudSmall'
MultiFont'UI_Fonts_Final.HUD.MF_Medium'
*/

var(Component, Display) privatewrite string			Text;
/** Whether this label text should be localized(translated). */
var(Component, Display) bool						bLocalizeText;
var(Component, Display) Color						TextColor;
var(Component, Display) Font						TextFont;
var(Component, Display) const FontRenderInfo		TextRenderInfo;
var(Component, Display) const Vector2D				TextFontScaling;

var(Component, Display) enum EDecoration
{
	D_None,
	D_Underlined,
	D_Overlined
}													TextDecoration;
var(Component, Display) int							TextDecorationSize;
var(Component, Display) Color						TextDecorationColor;

var(Component, Display) enum EHAlign
{
	TA_Left,
	TA_Center,
	TA_Right
}													TextAlign;

var(Component, Display) enum EVAlign
{
	TA_Top,
	TA_Center,
	TA_Bottom
}													TextVAlign;

var(Component, Positioning) const Vector2D			RelativeOffset;
var(Component, Positioning) bool					bAutoSize;

var private bool bAutoSized;

delegate OnTextChanged( FComponent sender );

function Free()
{
	super.Free();
	TextFont = none;
	OnTextChanged = none;
}

function InitializeComponent()
{
	super.InitializeComponent();
	if( bLocalizeText )
	{
		Text = Localize( string(Name), Text, "Forms" );
	}
}

protected function RenderComponent( Canvas C )
{
	super.RenderComponent( C );
	RenderLabel( C, LeftX, TopY, WidthX, HeightY, TextColor );
}

final protected function RenderLabel( Canvas C, float X, float Y, float W, float H, Color drawColor, optional out float XL, optional out float YL )
{
	local float AX, AY;
//	local float cX, cY;
	local FontRenderInfo renderInfo;

	X += RelativeOffset.X;
	Y += RelativeOffset.Y;

	C.Font = TextFont != none ? TextFont : C.GetDefaultCanvasFont();
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
	renderInfo = C.CreateFontRenderInfo( 
		TextRenderInfo.bClipText, 
		TextRenderInfo.bEnableShadow,
		TextRenderInfo.GlowInfo.GlowColor,
		TextRenderInfo.GlowInfo.GlowOuterRadius,
		TextRenderInfo.GlowInfo.GlowInnerRadius
	);
	C.DrawText( Text, false, TextFontScaling.X, TextFontScaling.Y, renderInfo );
	
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
			C.SetPos( AX, AY + YL * 0.5 - TextDecorationSize );
			C.DrawColor = TextDecorationColor;
			C.DrawRect( XL, TextDecorationSize, C.DefaultTexture );
			break;
	}
}

function SetText( coerce string newText )
{
	Text = newText;
	bAutoSized = false;
	OnTextChanged( self );
}

defaultproperties
{
	RelativePosition=(X=0.01,Y=0.01)
	RelativeSize=(X=0.4,Y=0.18)
	RelativeOffset=(X=0.0,Y=0.0)

	Text="Label"
	TextFont=MultiFont'UI_Fonts_Final.HUD.MF_Small'
	TextColor=(R=245,G=245,B=245,A=255)
	TextAlign=TA_Left
	TextVAlign=TA_Center

	TextRenderInfo=(bClipText=true)
	TextFontScaling=(X=1.0,Y=1.0)
	TextDecorationSize=1
	TextDecorationColor=(R=255,G=255,B=255,A=255)

	bEnabled=`devmode
	bClipComponent=true
}