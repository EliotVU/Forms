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
class FBindingBox extends FMultiComponent;

const UNBOUND = "Unbound";

var(Component, Advanced) `{Automated} FLabel ActionLabel;

var(Component, Advanced) `{Automated} FInputBox ActionKey;
var(Component, Advanced) `{Automated} FInputBox ActionSecondaryKey;

var int PrimaryKeyIndex;
var int SecondaryKeyIndex;

var(Component, Function) bool bBindSecondary;

var(Component, Display) string ActionName;
var(Component, Function) string ActionCommand;

function Free()
{
	super.Free();
	ActionLabel = none;
	ActionKey = none;
	ActionSecondaryKey = none;
}

function InitializeComponent()
{
	local string bindKey;
	
	ActionLabel = FLabel(CreateComponent( class'FLabel' ));
	ActionLabel.SetPos( 0.0, 0.0 );
	ActionLabel.SetSize( 0.4, 1.0 );
	ActionLabel.SetMargin( 0,0,0,0 );
	ActionLabel.SetText( ActionName );
	AddComponent( ActionLabel );

	bindKey = GetBindedKeyForCommand( ActionCommand, PrimaryKeyIndex, true );
	if( bindKey != UNBOUND )
	{
		ActionKey = FInputBox(CreateComponent( class'FInputBox' ));
		ActionKey.SetPos( 0.4, 0.0 );
		ActionKey.SetSize( 0.3, 1.0 );
		ActionKey.SetMargin( 0,0,0,0 );
		ActionKey.SetText( bindKey );
		ActionKey.OnTextChanged = BindChanged;
		// Single click?
		//ActionKey.OnDoubleClick = none;
		//ActionKey.OnClick = ActionKey.StartEdit;
		AddComponent( ActionKey );
	}
	
	if( !bBindSecondary )
		return;
		
	bindKey = GetBindedKeyForCommand( ActionCommand, SecondaryKeyIndex );
	if( bindKey != UNBOUND )
	{
		ActionSecondaryKey = FInputBox(CreateComponent( class'FInputBox' ));
		ActionSecondaryKey.SetPos( 0.7, 0.0 );
		ActionSecondaryKey.SetSize( 0.3, 1.0 );
		ActionSecondaryKey.SetMargin( 0,0,0,0 );
		ActionSecondaryKey.SetText( bindKey );
		ActionSecondaryKey.OnTextChanged = BindChanged;
		AddComponent( ActionSecondaryKey );
	}
}

function RenderComponent( Canvas C )
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
	bSupportSelection=`devmode
	bSupportHovering=`devmode
	
	ActionName="None"
	ActionCommand=""
	bBindSecondary=true
	
	Padding=(W=4,X=4,Y=4,Z=4)

	// TODO: Find out why "instanced" does not work or wait for Epic Games to support nested "Component" classes
	/*begin object name=oLAction class=FLabel
		RelativePosition=(X=0.01,Y=0.0)
		RelativeSize=(X=0.4,Y=1.0)
	end object
	ActionLabel=oLAction
	Components.Add(oLAction)*/
}