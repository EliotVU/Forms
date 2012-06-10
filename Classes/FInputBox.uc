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
// A simple box that accepts and hooks the KeyInput delegate.
// Escape = Stop editing and restore text back prior to editing.
// Enter = Stop editing and save current text.
// Otherwise = Insert key char.
class FInputBox extends FLabel;

var transient bool bEditing;
var transient string OriginalText;

function RenderComponent( Canvas C )
{
	super(FComponent).RenderComponent( C );
	TextDecoration = bEditing ? D_Underlined : D_None;
	RenderLabel( C, LeftX, TopY, WidthX, HeightY, GetStateColor( TextColor ) );
}

function StartEdit( FComponent sender, optional bool bRight )
{	
	bEditing = true;
	OriginalText = Text;
	
	Scene().OnPostRenderPages = RenderActiveInput;
}

function RenderActiveInput( Canvas C )
{
	local float bgY;
	local float XL, YL;
	local string S;
	local float screenY;
	
	bgY = 64;
	C.SetPos( 0.0, C.ClipY - bgY );
	C.SetDrawColor( 40, 40, 40, 170 );
	C.DrawTile( C.DefaultTexture, C.ClipX, bgY, 0.0, 0.0, 1.0, 1.0 );
	
	C.SetPos( 0.0, C.ClipY - bgY );
	C.SetDrawColor( 255, 255, 255, 170 );
	C.DrawTile( C.DefaultTexture, C.ClipX, 2, 0.0, 0.0, 1.0, 1.0 );
	
	//Localize( "Input", "BindNote", "Forms" );
	S = "Press any key to bind it!";
	C.StrLen( S, XL, YL );
	screenY = C.ClipY - bgY*0.5 - YL - YL*0.5;
	
	C.SetPos( C.ClipX * 0.5 - XL, screenY );
	C.DrawColor = class'HUD'.default.WhiteColor;
	C.DrawText( S );
	screenY += YL;
	
	//Localize( "Input", "EscapeNote", "Forms" );
	S = "Escape = Cancel";
	C.StrLen( S, XL, YL );
	
	C.SetPos( C.ClipX * 0.5 - XL, screenY );
	C.DrawColor = class'HUD'.default.WhiteColor;
	C.DrawText( S );
	screenY += YL;
	
	//Localize( "Input", "EnterNote", "Forms" );
	S = "Enter = Done";
	C.StrLen( S, XL, YL );
	
	C.SetPos( C.ClipX * 0.5 - XL, screenY );
	C.DrawText( S );
}

function StopEdit( FComponent sender )
{
	bEditing = false;
	Scene().OnPostRenderPages = none;
}

function bool KeyInput( name Key, EInputEvent EventType )
{
	if( EventType != IE_Released )
		return true;

	switch( Key )
	{
		case 'Escape':
			if( !bEditing )
				break;
		
			StopEdit( self );
			SetText( OriginalText );
			return true;

		case 'Enter':
			if( bEditing )
			{
				StopEdit( self );
			}
			else 
			{
				StartEdit( self );
			}
			return true;
	}

	if( !bEditing )
		return false;

	//StopEdit( self );
	SetText( string(Key) );	
	return true;
}

function bool IsActive()
{
	return bEditing || super.IsActive();
}

defaultproperties
{
	OnDoubleClick=StartEdit
	OnKeyInput=KeyInput
	OnUnFocus=StopEdit

	Text="Unbound"
	TextColor=(R=255,G=255,B=255,A=255)
	TextAlign=TA_Left

	bEnabled=true
	bSupportSelection=true	
}