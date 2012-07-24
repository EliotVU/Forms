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
 * FDialog: A basic dialog window with a common set of controls such as OK or YES and NO.
 * ======================================================== */
class FDialog extends FWindow;

var() enum EDialogButtons
{
	DB_OK,
	DB_OKCancel,
	DB_YesNO
} Buttons;

var() FButton DialogButtonTemplate;
var() string DialogTitle;

delegate OnDialogResult( FDialog sender, name id );

function Free()
{
	super.Free();
	DialogButtonTemplate = none;
	OnDialogResult = none;
}

function InitializeComponent()
{
	local FButton nextButton;
	
	super.InitializeComponent();
	HeaderTitle.SetText( DialogTitle );
	switch( Buttons )
	{
		case DB_OK:
			nextButton = FButton(CreateComponent( DialogButtonTemplate.class, self, DialogButtonTemplate, "OKButton" ));
			nextButton.SetText( "OK" );
			nextButton.OnClick = DialogButtonClicked;
			nextButton.SetPos( 0.0, 1.0 );
			Body.AddComponent( nextButton );
			break;
			
		case DB_OKCancel:
			nextButton = FButton(CreateComponent( DialogButtonTemplate.class, self, DialogButtonTemplate, "OKButton" ));
			nextButton.SetText( "OK" );
			nextButton.OnClick = DialogButtonClicked;
			nextButton.SetPos( 0.0, 1.0 );
			Body.AddComponent( nextButton );
			
			nextButton = FButton(CreateComponent( DialogButtonTemplate.class, self, DialogButtonTemplate, "CANCELButton" ));
			nextButton.SetText( "CANCEL" );
			nextButton.OnClick = DialogButtonClicked;
			nextButton.SetPos( 0.25, 1.0 );
			Body.AddComponent( nextButton );
			break;
			
		case DB_YesNO:
			nextButton = FButton(CreateComponent( DialogButtonTemplate.class, self, DialogButtonTemplate, "YESButton" ));
			nextButton.SetText( "YES" );
			nextButton.OnClick = DialogButtonClicked;
			nextButton.SetPos( 0.0, 1.0 );
			Body.AddComponent( nextButton );
			
			nextButton = FButton(CreateComponent( DialogButtonTemplate.class, self, DialogButtonTemplate, "NOButton" ));
			nextButton.SetText( "NO" );
			nextButton.OnClick = DialogButtonClicked;
			nextButton.SetPos( 0.25, 1.0 );
			Body.AddComponent( nextButton );
			break;
	}
}

function DialogButtonClicked( FComponent sender, optional bool bRight )
{
	switch( sender.Name )
	{
		case 'OKButton':
			OnDialogResult( self, 'OK' );
			break;
			
		case 'CANCELButton':
			OnDialogResult( self, 'CANCEL' );
			break;
			
		case 'YESButton':
			OnDialogResult( self, 'YES' );
			break;
			
		case 'NOButton':
			OnDialogResult( self, 'NO' );
			break;
	}
	
	Scene().RemovePage( self );
}

defaultproperties
{
	RelativePosition=(X=0.25,Y=0.375)
	RelativeSize=(X=0.5,Y=0.25)
	
	begin object name=oDialogButton class=FButton
		RelativeSize=(X=0.20,Y=0.25)
		VerticalDock=VD_Bottom
	end object
	DialogButtonTemplate=oDialogButton
	
	bSupportHovering=false
	DialogTitle="Dialog"
}