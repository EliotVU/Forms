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
class FTextBox extends FInputBox;

var(Component, Function) int MaxTextLength;
var(Component, Function) bool bReadyOnly;

var(Component, Display) bool bUnderlined;
var(Component, Display) bool bCarret;

var(Component, Display) const Color UnderlineColor;
var(Component, Display) const Color CarretColor;

var transient int CarretIndex;
var transient float LastCarretMoveTime;

protected function RenderComponent( Canvas C )
{
	local float XL, YL, TXL, TYL;
	local string S;

	super(FComponent).RenderComponent( C );
	RenderBackground( C );
	RenderLabel( C, LeftX, TopY, WidthX, HeightY, TextColor, TXL, TYL );
	if( HasFocus() && bEditing )
	{
		// Underline
		if( bUnderlined )
		{
			C.SetPos( C.CurX - (TextRenderInfo.bClipText ? 0.0 : TXL), C.CurY + TYL );
			C.DrawColor = UnderlineColor;
			C.DrawRect( TXL, 1 );
		}
		
		// Carret
		if( bCarret )
		{
			if( (`STime - LastCarretMoveTime) % 0.5 <= 0.4 )
			{
				S = Left( Text, CarretIndex );
				C.StrLen( S, XL, YL );
				C.SetPos( C.CurX - TXL + XL - 1, C.CurY - 1 - TYL );
				C.DrawColor = CarretColor;
				C.DrawRect( 1, TYL );	
			}
		}
	}
}

function StartEdit( FComponent sender, optional bool bRight )
{	
	if( bReadyOnly )
		return;

	super.StartEdit( sender, bRight );
	CarretIndex = Len( Text );
	LastCarretMoveTime = `STime;
}

function StopEdit( FComponent sender )
{
	super.StopEdit( sender );
	CarretIndex = 0;
	LastCarretMoveTime = `STime;
}

function bool KeyInput( name Key, EInputEvent EventType )
{
	if( bReadyOnly )
		return false;

	switch( Key )
	{
		case 'Escape':
			if( EventType != IE_Released || !bEditing )
				break;
		
			StopEdit( self );
			SetText( OriginalText );
			return true;

		case 'Enter':
			if( EventType != IE_Released )
				break;

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

	if( EventType == IE_Pressed || EventType == IE_Repeat )
	{
		switch( Key )
		{
			case 'BackSpace':
				BackSpace();
				return true;
				
			case 'Delete':
				Delete();
				return true;	
			
			case 'Left':
				MoveCarretLeft();
				return true;
			
			case 'Right':
				MoveCarretRight();
				return true;
		}
	}
	return false;
}

final function MoveCarretLeft()
{
	CarretIndex = Max( CarretIndex-1, 0 );
	LastCarretMoveTime = `STime;
}

final function MoveCarretRight()
{
	CarretIndex = Min( CarretIndex+1, Len( Text ) );	
	LastCarretMoveTime = `STime;
}

function bool CharInput( string Unicode )
{
	local string newText;

	if( bReadyOnly )
		return false;

	if( bEditing && IsChar( Unicode ) )
	{
		if( Len( Text ) >= MaxTextLength )
		{
			BackSpace();	
		}
		newText = Left( Text, CarretIndex );
		newText $= Unicode;
		newText $= Mid( Text, CarretIndex );
		SetText( newText );
		MoveCarretRight();
		return true;
	}
	return false;
}

final static function bool IsChar( string Unicode )
{
	local int Code;

	Code = Asc( Unicode );
	return Code >= 0x20 && Code <= 0x7E;
}

final function BackSpace()
{
	local string newText;

	if( Text == "" )
		return;

	newText = Left( Text, CarretIndex-1 );
	newText $= Mid( Text, CarretIndex );
	SetText( newText );
	MoveCarretLeft();
}

final function Delete()
{
	local string newText;

	if( Text == "" )
		return;

	newText = Left( Text, CarretIndex );
	newText $= Mid( Text, CarretIndex+1 );
	SetText( newText );
}

defaultproperties
{
	OnCharInput=CharInput

	Text="None"
	MaxTextLength=32
	TextAlign=TA_Left
	TextVAlign=TA_Center

	bReadyOnly=false
	bCarret=true
	bUnderlined=true

	CarretColor=(R=122,G=122,B=122,A=146)
	UnderlineColor=(R=255,G=255,B=255,A=128)
}