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

var protected transient float							StartPosY, StartValue;
var protected transient float 							InterpolatedValue;
var protected transient float 							VisibleHeight;

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
	OnValueChanged = ValueChanged;
	OnMouseWheelInput = MouseWheelInput;
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
	local float incrValue;
	local FComponent component;
	local float endPos, maxHeight;

	incrValue = Abs( InterpolatedValue )*deltaTime;
	if( InterpolatedValue > 0 )
	{
		InterpolatedValue = FMax( InterpolatedValue - incrValue, 0 );	
	}
	else if( InterpolatedValue < 0 )
	{
		InterpolatedValue = -FMax( Abs( InterpolatedValue ) - incrValue, 0 );
		incrValue = -incrValue;
	}
	SetValue( Value + incrValue );

	foreach MaskComponent.Components( component )
	{
		endPos = component.GetTop() + component.GetHeight();
		if( endPos >= maxHeight )
		{
			maxHeight = endPos;	
		} 
	}

	VisibleHeight = MaskComponent.GetHeight();
	if( maxHeight > VisibleHeight )
	{
		MaxValue = maxHeight;
	} 
	else 
	{
		MaxValue = VisibleHeight;
	}
}

function float GetSliderSize()
{
	return SizeY*(VisibleHeight/MaxValue);
}

function float GetSliderOffset()
{
	return FMin( Value/MaxValue*SizeY, MaxValue - GetSliderSize() )*0.5;
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
	Value = FClamp( newValue, MinValue, MaxValue - GetSliderSize() );
	OnValueChanged( self );
}

function ValueChanged( FComponent sender )
{
	MaskComponent.OriginOffset.Y = -FClamp( Value, MinValue, MaxValue )*0.5;
}

function UpdateValue()
{
	if( bSliding )
	{
		RelativeMousePosition.Y = FClamp( Scene().MousePosition.Y - PosY, 0.0, SizeY );
		SetValue( StartValue + (RelativeMousePosition.Y - StartPosY)*2.0 );
		InterpolatedValue = 0;
	}
}

function StartSliding()
{
	// Stop previous interpolation.
	InterpolatedValue = 0;
	StartPosY = Scene().MousePosition.Y - PosY;
	StartValue = Value;
	if( StartPosY >= GetSliderOffset() && StartPosY <= GetSliderOffset() + GetSliderSize() )
	{
		bSliding = true;
	}
	else if( StartPosY < GetSliderOffset() )
	{
		ScrollUp();
	}
	else if( StartPosY > GetSliderOffset() + GetSliderSize() )
	{
		ScrollDown();
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
}