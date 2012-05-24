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
class FScrollComponent extends FComponent
	abstract;

/** The value of the scroller. */
var(Component, Usage) float MinValue;
var(Component, Usage) float MaxValue;
var(Component, Usage) float Value;

var Texture2D ProgressImage;

var transient bool bSliding;
var transient IntPoint RelativeMousePosition;

delegate OnValueChanged( FComponent sender );

function Free()
{
	super.Free();
	ProgressImage = none;
}

function MouseButtonPressed( FComponent sender, optional bool bRight )
{
	StartSliding();
}

function MouseButtonRelease( FComponent sender, optional bool bRight )
{
	if( bSliding )
	{
		StopSliding();
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

function RenderComponent( Canvas C )
{
	super.RenderComponent( C );
	RenderBackground( C );
	RenderSlider( C );
}

function RenderSlider( Canvas C );

function SetValue( float newValue )
{
	Value = FClamp( newValue, MinValue, MaxValue );
	OnValueChanged( self );
}

function StartSliding()
{
	bSliding = true;
	UpdateValue();
}

function StopSliding();

function UpdateValue()
{
	if( bSliding )
	{
		RelativeMousePosition.X = Clamp( Scene().MousePosition.X - LeftX, 0.0, WidthX );
		RelativeMousePosition.Y = Clamp( Scene().MousePosition.Y - TopY, 0.0, HeightY );
	}
}

defaultproperties
{
	RelativePosition=(X=0.0,Y=0.0)
	RelativeSize=(X=0.4,Y=1.0)

	MinValue=0.0
	MaxValue=255.0
	Value=0.0

	bEnabled=true
	OnMouseButtonPressed=MouseButtonPressed
	OnMouseButtonRelease=MouseButtonRelease
	OnMouseMove=MouseMove
	OnUnFocus=FocusLost
	//OnUnHover=FocusLost
	
	begin object name=oStyle class=FScrollStyle
	end object
	Style=oStyle
}