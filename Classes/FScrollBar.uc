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
/**
 * MinValue is used as the Minimum(pix), where MaxValue is used as Maximum(pix), and Value is the pixels we've scrolled past.
 *
*/
class FScrollBar extends FScrollComponent;

var(Component, Usage) float StepProgress;
var(Component, Functionality) FMultiComponent MaskComponent;

var() protected transient float VisibleHeight;
var protected transient float ClickOffset;
var protected transient float InterpolatedValue;

function Free()
{
	super.Free();
	MaskComponent = none;
}

/** Must be called after all components in MaskComponent have been initialized! */
function InitializeScrollBar()
{
	local FComponent component;
	local float endPos, maxHeight;

	Assert( MaskComponent != none );

	VisibleHeight = MaskComponent.GetHeight();
	foreach MaskComponent.Components( component )
	{
		endPos = component.GetTop() + component.GetHeight();
		if( endPos >= maxHeight )
		{
			maxHeight = endPos;	
		} 
	}

	MinValue = 0.0;
	if( maxHeight > VisibleHeight )
	{
		MaxValue = maxHeight;
	} 
	else 
	{
		MaxValue = VisibleHeight;
		//SetVisible( false );
	}
	
	Value = 0.0;

	OnValueChanged = ValueChanged;
}

function MouseWheelInput( FComponent sender, optional bool bUp )
{
	if( bSliding )
		return;

	if( bUp )
	{
		ScrollUp();
	}
	else
	{
		ScrollDown();
	}
}

function ScrollUp()
{
	InterpolatedValue = -(MaxValue*StepProgress);
}

function ScrollDown()
{
	InterpolatedValue = (MaxValue*StepProgress);
}

function Update( float deltaTime )
{
	local float valueToAdd;

	if( InterpolatedValue > 0 )
	{
		valueToAdd = InterpolatedValue*0.1*deltaTime;
		InterpolatedValue = FMax( InterpolatedValue - valueToAdd, 0 );
		SetValue( Value + -valueToAdd );
	}
	else if( InterpolatedValue < 0 )
	{
		valueToAdd = -InterpolatedValue*-0.1*-deltaTime;
		InterpolatedValue = FMin( InterpolatedValue + valueToAdd, 0 );
		SetValue( Value + valueToAdd );
	}
}

function float GetSliderSize()
{
	return HeightY*(VisibleHeight/MaxValue);
}

function float GetSliderOffset()
{
	return FMin( Value/MaxValue*HeightY, MaxValue - GetSliderSize() );
}

function RenderSlider( Canvas C )
{
	local float sliderY;
	local float sliderSize;
	local FScrollStyle myStyle;
	
	myStyle = FScrollStyle(Style);
	if( myStyle == none )
	{
		//`Log( "No FScrollStyle found for" @ self, 'Forms' );
		return;
	}

	sliderY = GetSliderOffset();
	sliderSize = GetSliderSize();	
	C.SetPos( LeftX, TopY + sliderY );
	C.DrawColor = GetStateColor();
	myStyle.DrawTracker( C, WidthX, sliderSize );
}

function SetValue( float newValue )
{
	Value = FClamp( newValue, MinValue, MaxValue - GetSliderSize() );
	OnValueChanged( self );
}

function ValueChanged( FComponent sender )
{
	// Update just incase!
	VisibleHeight = MaskComponent.GetHeight();
	MaskComponent.OriginOffset.Y = -FClamp( Value, MinValue, MaxValue );
}

function StartSliding()
{
	local float yPos;

	yPos = Scene().MousePosition.Y - TopY;
	if( yPos >= GetSliderOffset() && yPos <= GetSliderOffset() + GetSliderSize() )
	{
		bSliding = true;
		ClickOffset = GetSliderOffset() - yPos;
	}
	else if( yPos < GetSliderOffset() )
	{
		ScrollUp();
		StopSliding();
	}
	else if( yPos > GetSliderOffset() + GetSliderSize() )
	{
		ScrollDown();
		StopSliding();
	}
}

function UpdateValue()
{
	if( bSliding )
	{
		//RelativeMousePosition.X = Clamp( Scene().MousePosition.X - LeftX, 0.0, WidthX );
		RelativeMousePosition.Y = FClamp( Scene().MousePosition.Y - TopY, 0.0, HeightY );
		SetValue( RelativeMousePosition.Y + ClickOffset );
		InterpolatedValue = 0;
	}
}

function StopSliding()
{
	bSliding = false;
}

defaultproperties
{
	RelativePosition=(X=1.0,Y=0.0)
	RelativeSize=(X=0.05,Y=1.0)

	HorizontalDock=HD_Right
	Positioning=P_Fixed

	StepProgress=0.1

	OnMouseWheelInput=MouseWheelInput
}