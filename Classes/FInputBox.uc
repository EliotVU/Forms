/* ========================================================
 * Copyright 2012 Eliot van Uytfanghe
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
 * FInputBox: A simple box that accepts and hooks the KeyInput delegate.
 * Escape key cancels the editing and restores the input key.
 * Check FBindingBox to use this.
 * ======================================================== */
class FInputBox extends FLabel;

var transient bool bEditing;
var transient string OriginalText;

// Localized. See "Forms.int"
var privatewrite string BindText;
var privatewrite string CancelText;

protected function InitializeComponent()
{
	super.InitializeComponent();
	BindText = Localize( "InputBox", "BindText", "Forms" );
	CancelText = Localize( "InputBox", "CancelText", "Forms" );
}

protected function RenderComponent( Canvas C )
{
	super(FComponent).RenderComponent( C );
	TextDecoration = bEditing ? D_Underlined : default.TextDecoration;
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
	}

	if( !bEditing )
		return false;

	SetText( string(Key) );	
	StopEdit( self );
	return true;
}

function bool IsActive()
{
	return bEditing || super.IsActive();
}

defaultproperties
{
	OnClick=StartEdit
	OnKeyInput=KeyInput
	OnUnFocus=StopEdit

	Text="@Forms.InputBox.UnboundText"
	TextColor=(R=255,G=255,B=255,A=255)
	TextAlign=TA_Left

	bEnabled=true
	bSupportSelection=true	

	begin object name=oHints class=FToolTip
		begin object name=oToolTipBackground class=FPage
			RelativePosition=(X=0.0,Y=0.0)
			RelativeSize=(X=1.0,Y=1.0)
			StyleNames.Empty()
			StyleNames.Add(ToolTipBackground)
			begin object name=oCancelLabel class=FLabel
				RelativePosition=(X=0.0,Y=0.5)
				RelativeSize=(X=1.0,Y=0.5)
				RelativeOffset=(X=0.0,Y=0.0)
				Text="@Forms.InputBox.CancelText"
			end object
			Components.Add(oCancelLabel)
		end object
		ToolTipBackground=oToolTipBackground

		ToolTipText="@Forms.InputBox.BindText"
		begin object name=oHintLabel class=FLabel
			RelativePosition=(X=0.0,Y=0.0)
			RelativeSize=(X=1.0,Y=0.5)
			RelativeOffset=(X=0.0,Y=0.0)
		end object
		ToolTipLabel=oHintLabel
		
		RelativeSize=(X=180,Y=80)
		ToolTipAttachPosition=P_Mouse
	end object
	ToolTipComponent=oHints
}