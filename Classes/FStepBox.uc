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
 * FStepBox: An alternative to dropdown lists. 
 * Expects an array of choices and adds two buttons a previous and next button to navigate through the list.
 * ======================================================== */
class FStepBox extends FMultiComponent;

var(Component, Advanced) FButton 		Previous;
var(Component, Advanced) FLabel 		SelectedChoice;
var(Component, Advanced) FButton 		Next;

var(Component, Usage) array<string> 	Choices;
var(Component, Usage) int				ChoiceIndex;

delegate OnValueChanged( FComponent sender );

function Free()
{
	super.Free();
	Previous = none;
	SelectedChoice = none;
	Next = none;
	OnValueChanged = none;
}

protected function InitializeComponent()
{
	super.InitializeComponent();
	Previous = FButton(CreateComponent( class'FButton',, Previous ));
	Previous.OnClick = Click;
	Previous.OnDoubleClick = Click;
	AddComponent( Previous );

	SelectedChoice = FLabel(CreateComponent( class'FLabel',, SelectedChoice ));
	AddComponent( SelectedChoice );

	Next = FButton(CreateComponent( class'FButton',, Next ));
	Next.OnClick = Click;
	Next.OnDoubleClick = Click;
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

protected function RenderComponent( Canvas C )
{
	super.RenderComponent( C );
	RenderBackground( C );
}

function StepLeft()
{
	local int newIndex;
	
	newIndex = Max( ChoiceIndex-1, 0 );
	if( newIndex != ChoiceIndex )
	{
		ChoiceIndex = newIndex;
		UpdateChoice();
	}
}

function StepRight()
{
	local int newIndex;
	
	newIndex = Min( ChoiceIndex+1, Choices.Length - 1 );
	if( newIndex != ChoiceIndex )
	{
		ChoiceIndex = newIndex;
		UpdateChoice();
	}
}

function UpdateChoice()
{
	if( Choices.Length == 0 || ChoiceIndex > Choices.Length-1 )
		return;

	SelectedChoice.SetText( Choices[ChoiceIndex] );
	OnValueChanged( self );
}

function SetValue( coerce string value )
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
	
	bSupportSelection=`devmode
	bSupportHovering=`devmode

	StyleName=Hidden

	begin object name=oPrevButtonTemplate class=FButton
		RelativePosition=(X=0.0,Y=0.0)
		RelativeSize=(X=0.15,Y=1.0)
		Margin=(W=0,X=0,Y=0,Z=0)
		bRenderCaption=false
		bJustify=true
		StyleNames.Add(Previous)
	end object
	Previous=oPrevButtonTemplate

	begin object name=oChoiceLabelTemplate class=FLabel
		RelativePosition=(X=0.15,Y=0.0)
		RelativeSize=(X=0.7,Y=1.0)
		Margin=(W=0,X=0,Y=0,Z=0)
		TextAlign=TA_Center
	end object
	SelectedChoice=oChoiceLabelTemplate

	begin object name=oNextButtonTemplate class=FButton
		RelativePosition=(X=1.0,Y=0.0)
		RelativeSize=(X=0.15,Y=1.0)
		Margin=(W=0,X=0,Y=0,Z=0)
		HorizontalDock=HD_Right
		bRenderCaption=false
		bJustify=true
		StyleNames.Add(Next)
	end object
	Next=oNextButtonTemplate
}