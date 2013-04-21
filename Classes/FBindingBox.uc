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
 * FBindingBox: A set of controls for binding multiple keys to a single command.
 * ======================================================== */
class FBindingBox extends FMultiComponent;

const UNBOUND = "Unbound";

/** The input label for example: Move Forward. */
var(BindingBox, Advanced) `{Automated} FLabel ActionLabel;

/** The primary key InputBox. */
var(BindingBox, Advanced) `{Automated} FInputBox ActionKey;

/** The secondary key InputBox. */
var(BindingBox, Advanced) `{Automated} FInputBox ActionSecondaryKey;

var protectedwrite int PrimaryKeyIndex;
var protectedwrite int SecondaryKeyIndex;

/** Whether this ActionCommand has two binds e.g. E and Enter for Use. */
var(BindingBox, Function) editconst bool bBindSecondary;

/** The binding name for for example: GBA_Use. */
var(BindingBox, Function) string ActionCommand;

/** The caption for ActionLabel for example: Move Forward. */
var(BindingBox, Display) editconst string ActionName;

function Free()
{
	super.Free();
	ActionLabel = none;
	ActionKey = none;
	ActionSecondaryKey = none;
}

protected function InitializeComponent()
{
	local string bindKey;
	
	super.InitializeComponent();
	ActionLabel = FLabel(CreateComponent( ActionLabel.Class,, ActionLabel ));
	ActionLabel.SetText( ActionName );
	AddComponent( ActionLabel );

	bindKey = GetBindedKeyForCommand( ActionCommand, PrimaryKeyIndex, true );
	if( bindKey != UNBOUND )
	{
		ActionKey = FInputBox(CreateComponent( ActionKey.Class,, ActionKey ));
		ActionKey.SetText( bindKey );
		ActionKey.OnTextChanged = BindChanged;
		// Single click?
		//ActionKey.OnDoubleClick = none;
		//ActionKey.OnClick = ActionKey.StartEdit;
		AddComponent( ActionKey );
	}
	
	if( !bBindSecondary )
	{
		ActionKey.SetSize( ActionKey.RelativeSize.X * 2.0, ActionKey.RelativeSize.Y );
		return;
	}
		
	bindKey = GetBindedKeyForCommand( ActionCommand, SecondaryKeyIndex );
	if( bindKey != UNBOUND )
	{
		ActionSecondaryKey = FInputBox(CreateComponent( ActionSecondaryKey.Class,, ActionSecondaryKey ));
		ActionSecondaryKey.SetText( bindKey );
		ActionSecondaryKey.OnTextChanged = BindChanged;
		AddComponent( ActionSecondaryKey );
	}
}

protected function RenderComponent( Canvas C )
{
	super.RenderComponent( C );
	RenderBackground( C );
}

// bUsingGamepad
// ConsoleBuild

function BindChanged( FComponent sender )
{
	local PlayerInput myInput;
	local name key;
	local int keyIndex;

	switch( sender )
	{
		case ActionKey:
			key = name(ActionKey.Text);
			keyIndex = PrimaryKeyIndex;
			break;
	
		case ActionSecondaryKey:
			key = name(ActionSecondaryKey.Text);
			keyIndex = SecondaryKeyIndex;
			break;
	}
	
	if( key == name(UNBOUND) )
		return;
		
	if( keyIndex == INDEX_NONE )
	{
		`Log( "keyIndex is negative! Could'nt bind action" @ ActionCommand );
		return;
	}
		
	myInput = Player().PlayerInput;
	myInput.Bindings[keyIndex].Name = key;
	myInput.Bindings[keyIndex].Command = ActionCommand;
	myInput.SaveConfig();
}

// 'second' is actually primary assuming that the bindings are configured in reverse order.
final function string GetBindedKeyForCommand( string command, out int bindIndex, optional bool second )
{
	local PlayerInput myInput;
	local int i;

	myInput = Player().PlayerInput;
	bindIndex = INDEX_NONE;
	for( i = 0; i < myInput.Bindings.Length; ++ i )
	{
		if( myInput.Bindings[i].Command ~= command 
			&& (myInput.bUsingGamepad || InStr( myInput.Bindings[i].Name, "XboxTypeS" ) == -1 ) 
			)
		{	
			if( (second && bindIndex != INDEX_NONE) )
			{
				bindIndex = i;		
				break;
			}
			
			
			if( bindIndex == INDEX_NONE )
			{
				bindIndex = i;
				if( !second )
				{
					break;
				}
			}
		}
	}
	return bindIndex != INDEX_NONE ? string(myInput.Bindings[bindIndex].Name) : UNBOUND;
}

defaultproperties
{
	bEnableClick=false
	bEnableCollision=false
	
	ActionName="None"
	ActionCommand=""
	bBindSecondary=true
	
	Padding=(W=4,X=4,Y=4,Z=4)
	RelativeSize=(X=1.0,Y=0.1)

	StyleNames.Add(BindingBox)

	// FIXME: Not re-initialized after garbage collecting!
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
		
		RelativeSize=(X=250,Y=80)
		ToolTipAttachPosition=P_Mouse
	end object

	begin object name=oLAction class=FLabel
		RelativePosition=(X=0.00,Y=0.00)
		RelativeSize=(X=0.40,Y=1.00)
		RelativeOffset=(X=4)
		Margin=(W=0,X=0,Y=0,Z=0)
		StyleNames.Add(InputAction)
	end object
	ActionLabel=oLAction
	
	begin object name=oIBActionKey class=FInputBox
		RelativePosition=(X=0.40,Y=0.00)
		RelativeSize=(X=0.30,Y=1.00)
		Margin=(W=0,X=0,Y=0,Z=0)
		ToolTipComponent=oHints
		StyleNames.Add(InputKey)
		TextAlign=TA_Center
	end object
	ActionKey=oIBActionKey
	
	begin object name=oIBActionSecondaryKey class=FInputBox
		RelativePosition=(X=0.70,Y=0.00)
		RelativeSize=(X=0.30,Y=1.00)
		Margin=(W=0,X=0,Y=0,Z=0)
		ToolTipComponent=oHints
		StyleNames.Add(InputKey)
		TextAlign=TA_Center
	end object
	ActionSecondaryKey=oIBActionSecondaryKey
}