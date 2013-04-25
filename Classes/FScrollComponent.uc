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
 * FScrollComponent: Base functionality for any component that wants scrolling functionality.
 * ======================================================== */
class FScrollComponent extends FComponent
	abstract;

/** The present value of the scroller. */
var(Scroll, Usage) float Value;

/** The minimum @Value can be. */
var(Scroll, Usage) float MinValue;

/** The maximum @Value can be. */
var(Scroll, Usage) float MaxValue;

// Must be implemented by subclasses.
var(Scroll, Usage) float SnapPower;

var(Scroll, Usage) bool bInteger;

/** If true, SetValue() will be performed while sliding. */
var(Scroll, Usage) bool bDynamic;

// Not yet implemented!
var(Scroll, Display) enum EDirection
{
	D_Horizontal,
	D_Vertical
} Direction;

var transient bool bSliding, bWasRightClick;
var transient IntPoint RelativeMousePosition;

delegate OnValueChanged( FComponent sender );

function Free()
{
	super.Free();
	OnValueChanged = none;
}

function MouseButtonPressed( FComponent sender, optional bool bRight )
{
	// Don't allow dual clicking(both left and right)
	if( bSliding && bRight != bWasRightClick )
		return;

	bWasRightClick = bRight;
	StartSliding();
	OnMouseMove = MouseMove;
}

function MouseButtonRelease( FComponent sender, optional bool bRight )
{
	// Only stop if it's the same button as the one that initiated!
	if( bRight != bWasRightClick )
		return;
		
	if( bSliding )
	{
		StopSliding();
		OnMouseMove = none;
	}
}

function MouseMove( FScene scene, float DeltaTime )
{
	UpdateValue();
}

// UnFocus, UnHover
function FocusLost( FComponent sender )
{
	if( bSliding )
	{
		StopSliding();
	}
}

protected function RenderComponent( Canvas C )
{
	super.RenderComponent( C );
	RenderBackground( C );
	RenderSlider( C );
}

protected function RenderSlider( Canvas C );

function StartSliding()
{
	bSliding = true;
	UpdateValue();
}

function StopSliding()
{
	bSliding = false;
	UpdateValue();
}

function SetValue( float newValue )
{
	if( newValue != Value )
	{
		Value = newValue;
		OnValueChanged( self );
	}
}

function float CalcValue()
{
	local float newValue;
	
	newValue = GetSliderBegin()/GetSliderEnd()*MaxValue;
	if( SnapPower > 0.00 )
	{
		newValue = newValue - (newValue % SnapPower) + SnapPower;
	}
	return FClamp( bInteger ? float(int(newValue)) : newValue, MinValue, MaxValue );
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

	// Only update the value if sliding is inactive or if Real-Time(bDynamic)
	if( !bSliding || bDynamic )
	{
		SetValue( CalcValue() );
	}
}

final function UpdateRelativeMousePosition()
{
	RelativeMousePosition.X = FClamp( Scene().MousePosition.X - PosX, 0.0, SizeX );
	RelativeMousePosition.Y = FClamp( Scene().MousePosition.Y - PosY, 0.0, SizeY );
}

final function float GetSliderBegin()
{
	return Direction == D_Horizontal ? RelativeMousePosition.X : RelativeMousePosition.Y;
}

final function float GetSliderEnd()
{
	return Direction == D_Horizontal ? SizeX : SizeY;
}

defaultproperties
{
	RelativePosition=(X=0.0,Y=0.0)
	RelativeSize=(X=0.4,Y=1.0)

	MinValue=0.0
	MaxValue=255.0
	Value=0.0
	SnapPower=0.0

	bDynamic=true
	
	Direction=D_Horizontal

	OnMouseButtonPressed=MouseButtonPressed
	OnMouseButtonRelease=MouseButtonRelease
	OnUnFocus=FocusLost
	
	// Uncomment if you want inner-only-sliding
	//OnUnHover=FocusLost
	StyleClass=class'FScrollStyle'
}