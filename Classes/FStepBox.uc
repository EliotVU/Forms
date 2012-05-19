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
class FStepBox extends FMultiComponent;

var(Component, Advanced) `{Automated} FButton Previous;
var(Component, Advanced) `{Automated} FLabel SelectedChoice;
var(Component, Advanced) `{Automated} FButton Next;

var(Component, Usage) array<string> Choices;
var(Component, Usage) int ChoiceIndex;

var(Component, Display) privatewrite editinline FStyle 
	PreviousButtonStyle,
	NextButtonStyle;

delegate OnValueChanged( FComponent sender );

function InitializeComponent()
{
	Previous = FButton(CreateComponent( class'FButton' ));
	Previous.SetPos( 0.0, 0.0 );
	Previous.SetSize( 0.2, 1.0 );
	Previous.SetMargin( 0.0, 0.0, 0.0, 0.0 );
	Previous.OnClick = Click;
	Previous.OnDoubleClick = Click;
	Previous.bRenderCaption = false;
	Previous.bJustify = true;
	Previous.SetStyle( PreviousButtonStyle );
	AddComponent( Previous );

	SelectedChoice = FLabel(CreateComponent( class'FLabel' ));
	SelectedChoice.SetPos( 0.20, 0.0 );
	SelectedChoice.SetSize( 0.8, 1.0 );
	SelectedChoice.SetMargin( 0.0, 0.0, 0.0, 0.0 );
	SelectedChoice.TextAlign = TA_Center;
	AddComponent( SelectedChoice );

	Next = FButton(CreateComponent( class'FButton' ));
	Next.SetPos( 1.0, 0.0 );
	Next.SetSize( 0.2, 1.0 );
	Next.SetMargin( 0.0, 0.0, 0.0, 0.0 );
	Next.bRenderCaption = false;
	Next.OnClick = Click;
	Next.OnDoubleClick = Click;
	Next.bJustify = true;
	Next.HorizontalDock = HD_Right;
	Next.SetStyle( NextButtonStyle );
	AddComponent( Next );

	UpdateChoice();
}

function Click( FComponent sender, optional bool bRight )
{
	switch( sender )
	{
		case Previous:
			StepLeft();
			break;

		case Next:
			StepRight();
			break;
	}
}

function RenderComponent( Canvas C )
{
	super.RenderComponent( C );
	RenderBackground( C );
}

function StepLeft()
{
	ChoiceIndex = Max( ChoiceIndex-1, 0 );
	UpdateChoice();
}

function StepRight()
{
	ChoiceIndex = Min( ChoiceIndex+1, Choices.Length - 1 );
	UpdateChoice();
}

function UpdateChoice()
{
	if( Choices.Length == 0 || ChoiceIndex > Choices.Length-1 )
		return;

	SelectedChoice.SetText( Choices[ChoiceIndex] );
	OnValueChanged( self );
}

function SetValue( string value )
{
	ChoiceIndex = Choices.Find( value );
	if( ChoiceIndex != -1 )
	{
		UpdateChoice();	
	}
	else
	{
		SelectedChoice.SetText( value );
		OnValueChanged( self );
	}
}

defaultproperties
{
	Padding=(X=2,Y=2,W=2,Z=2)
	
	begin object name=oPreviousButtonStyle class=FStyle
	end object
	PreviousButtonStyle=oPreviousButtonStyle

	begin object name=oNextButtonStyle class=FStyle
	end object
	NextButtonStyle=oNextButtonStyle
}