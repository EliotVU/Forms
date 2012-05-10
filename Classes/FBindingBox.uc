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

var(Component, Advanced) `{Automated} FLabel ActionLabel;
var(Component, Advanced) `{Automated} FInputBox ActionKey;

var(Component, Display) string ActionName;
var(Component, Function) string ActionCommand;

function InitializeComponent()
{
	local string bindKey;

	bindKey = GetBindedKeyForCommand( ActionCommand );
	ActionLabel = new(self) class'FLabel';
	ActionLabel.SetPos( 0.0, 0.0 );
	ActionLabel.SetSize( 0.5, 1.0 );
	ActionLabel.SetMargin( 0,0,0,0 );
	ActionLabel.SetText( ActionName );
	AddComponent( ActionLabel );

	ActionKey = new(self) class'FInputBox';
	ActionKey.SetPos( 0.5, 0.0 );
	ActionKey.SetSize( 0.5, 1.0 );
	ActionKey.SetMargin( 0,0,0,0 );
	ActionKey.SetText( bindKey );
	ActionKey.OnTextChanged = BindChanged;
	//ActionKey.OnDoubleClick = none;
	//ActionKey.OnClick = ActionKey.StartEdit;
	AddComponent( ActionKey );
}

function RenderComponent( Canvas C )
{
	super.RenderComponent( C );
	RenderBackground( C );
}

function BindChanged( FComponent sender )
{
	local name key;

	key = name(ActionKey.Text);
	if( key == 'Unbound' )
		return;

	Controller.Player().PlayerInput.SetBind( key, ActionCommand );
}

final function string GetBindedKeyForCommand( string command )
{
	local PlayerInput myInput;
	local int BindIndex;

	myInput = Controller.Player().PlayerInput;
	BindIndex = myInput.Bindings.Find( 'Command', command ); 
	return BindIndex != -1 ? string(myInput.Bindings[BindIndex].Name) : "Unbound";
}

defaultproperties
{
	ActionName="None"
	ActionCommand=""
	
	Padding=(X=0,Y=0,W=0,Z=0)

	// TODO: Find out why "instanced" does not work or wait for Epic Games to support nested "Component" classes
	/*begin object name=oLAction class=FLabel
		RelativePosition=(X=0.01,Y=0.0)
		RelativeSize=(X=0.4,Y=1.0)
	end object
	ActionLabel=oLAction
	Components.Add(oLAction)*/
}