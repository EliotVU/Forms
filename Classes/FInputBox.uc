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
 * FInputBox: A simple box that accepts and hooks the KeyInput delegate.
 * Escape key cancels the editing and restores the input key.
 * Check FBindingBox to use this.
 * ======================================================== */
class FInputBox extends FLabel;

var transient bool bEditing;
var transient string OriginalText;

protected function RenderComponent( Canvas C )
{
	super(FComponent).RenderComponent( C );
	RenderBackground( C );
	TextDecoration = bEditing ? D_Underlined : default.TextDecoration;
	RenderLabel( C, LeftX, TopY, WidthX, HeightY, GetStateColor( FLabelStyle(Style).TextColor ) );
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
	TextAlign=TA_Left

	bEnabled=true
	bEnableClick=true
	bEnableCollision=true
}