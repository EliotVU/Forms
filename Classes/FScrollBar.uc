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
 * FScrollBar: A scroll bar similar to Sublime Text 2's scroll bar.
 * ======================================================== */
class FScrollBar extends FScrollComponent;

var(ScrollBar, Advanced) editinline FMultiComponent	 	MaskComponent;
var(ScrollBar, Function) float 							StepProgress;
var(ScrollBar, Function) bool 							bScrollSmooth;

var protected transient editconst float					StartPos, StartValue;
var protected transient editconst float 				InterpolatedValue;
var protected transient editconst float 				VisibleHeight;

function Free()
{
	super.Free();
	MaskComponent = none;
}

/** Must be called after all components in MaskComponent have been initialized! */
protected function InitializeComponent()
{
	super.InitializeComponent();
	Assert( MaskComponent != none );

	MinValue = 0.0;
	Value = 0.0;
	OnMouseWheelInput = MouseWheelInput;
}

function MouseWheelInput( FComponent sender, optional bool bUp )
{
	if( !CanInteract() || bSliding )
		return;

	if( bUp )
	{
		ScrollDecrement();
	}
	else
	{
		ScrollIncrement();
	}
}

function ScrollDecrement()
{
	InterpolatedValue = -(MaxValue*StepProgress);
}

function ScrollIncrement()
{
	InterpolatedValue = (MaxValue*StepProgress);
}

function Update( float deltaTime )
{
	InterpolateValue( deltaTime );
	UpdateMaxValue();
}

function InterpolateValue( float deltaTime )
{
	local float incrValue;

	incrValue = (bScrollSmooth ? Abs( InterpolatedValue )*deltaTime : Abs( InterpolatedValue ));
	if( InterpolatedValue > 0 )
	{
		InterpolatedValue = FMax( InterpolatedValue - incrValue, 0 );	
	}
	else if( InterpolatedValue < 0 )
	{
		InterpolatedValue = -FMax( Abs( InterpolatedValue ) - incrValue, 0 );
		incrValue = -incrValue;
	}
	
	if( incrValue != 0 )
	{
		SetValue( Value + incrValue );
	}
}

function UpdateMaxValue()
{
	local FComponent component;
	local float endPos, maxHeight;

	foreach MaskComponent.Components( component )
	{
		if( component.Positioning == P_Fixed )
			continue;

		endPos = component.GetTop() + component.GetHeight();
		if( endPos >= maxHeight )
		{
			maxHeight = endPos;	
		} 
	}

	maxHeight = maxHeight - MaskComponent.OriginOffset.Y;

	VisibleHeight = MaskComponent.GetHeight();
	if( maxHeight > VisibleHeight )
	{
		MaxValue = maxHeight;
		SetEnabled( true );
		SetVisible( true );
	} 
	else // Nothing to be scrolled.
	{
		MaxValue = VisibleHeight;
		SetEnabled( false );
		SetVisible( false );
	}
}

// Get visible pixels in ScrollBar ratio.
function float GetSliderSize()
{
	return MaxValue > 0 ? VisibleHeight/MaxValue*SizeY : SizeY;
}

// Get skipped pixels in ScrollBar ratio.
function float GetSliderOffset()
{
	return MaxValue > 0 ? Value/MaxValue*SizeY : 0.0;
}

protected function RenderComponent( Canvas C )
{
	super(FComponent).RenderComponent( C );
	RenderSlider( C );
}

protected function RenderSlider( Canvas C )
{
	local float sliderY;
	local float sliderSize;
	
	sliderY = GetSliderOffset();
	sliderSize = GetSliderSize();	

	C.SetPos( PosX, PosY + sliderY );
	C.DrawColor = GetImageColor();
	Style.DrawBackground( C, SizeX, sliderSize );
}

function SetValue( float newValue )
{
	Value = FClamp( newValue, MinValue, MaxValue - VisibleHeight );
	OnValueChanged( self );
}

/**
 * Update the @Value variable in here.
 * -- 
 * Called everytime:
 *	The mouse moves within this component @MouseMove
 *  The user starts sliding @StartSliding()
 *	The user stops sliding @StopSliding()
 */
function UpdateValue()
{
	UpdateRelativeMousePosition();
	if( bSliding )
	{
		SetValue( StartValue + (RelativeMousePosition.Y - StartPos)*2.0 );
		InterpolatedValue = 0; // Stop active interpolation.
	}
}

function StartSliding()
{
	InterpolatedValue = 0; // Stop active interpolation.
	
	StartPos = Direction == D_Horizontal 
		? Scene().MousePosition.X - PosX 
		: Scene().MousePosition.Y - PosY;

	StartValue = Value;
	if( StartPos >= GetSliderOffset() && StartPos <= GetSliderOffset() + GetSliderSize() )
	{
		bSliding = true;
	}
	else if( StartPos < GetSliderOffset() )
	{
		ScrollDecrement();
	}
	else if( StartPos > GetSliderOffset() + GetSliderSize() )
	{
		ScrollIncrement();
	}
}

function StopSliding()
{
	bSliding = false;
}

defaultproperties
{
	RelativePosition=(X=1.0,Y=0.0)
	RelativeSize=(X=32,Y=1.0)
	Margin=(W=0,X=0,Y=4,Z=4)
	Padding=(W=8,X=8,Y=0,Z=0)

	HorizontalDock=HD_Right
	Positioning=P_Fixed
	Direction=D_Vertical

	StepProgress=0.25

	StyleNames.Add(ScrollBar)
	StyleClass=class'FStyle'

	bDynamic=false
	bScrollSmooth=true
}