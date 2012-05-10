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
}

function StopEdit( FComponent sender )
{
	bEditing = false;
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
	
	begin object name=oStyle
		ImageColor=(R=255,G=255,B=255,A=255)
		HoverColor=(R=255,G=255,B=0,A=255)
		FocusColor=(R=100,G=100,B=100,A=255)
		ActiveColor=(R=200,G=200,B=200,A=255)
		DisabledColor=(R=0,G=0,B=0,A=255)
	end object
}