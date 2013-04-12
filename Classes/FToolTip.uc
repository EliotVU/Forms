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
 * FToolTip: A basic tooltip control with a label and a background, similar to that of Windows.
 * Can be extended either inside the component that initializes this tooltip or by extending this class.
 * ======================================================== */
class FToolTip extends FMultiComponent;

/** The tooltip's text. */
var(ToolTip, Display) editconst string 			ToolTipText;

/** For how long should the tooltip be delayed before being shown? In seconds. */
var(ToolTip, Display) float 					ToolTipDelayTime;

/** For how long should the tooltip be shown? In Seconds. */
var(ToolTip, Display) float 					ToolTipShowTime;

/** The tooltip's attach algorithm. */
var(ToolTip, Display) enum EAttachPosition
{
	/** Align below(or above) the mouse's position at the time of the tooltip triggering. */
	P_Mouse,

	/** Align below(or above) the tooltip owner's position. */
	P_Component
} 												ToolTipAttachPosition;

/** The tooltip's background using the style 'ToolTipBackground' see in @DefaultForms.ini */
var(ToolTip, Advanced) editinline FPage 		ToolTipBackground;

/** The tooltip's label. Use @ToolTipText to set this label's text. */
var(ToolTip, Advanced) editinline FLabel 		ToolTipLabel;

function Free()
{
	super.Free();
	ToolTipBackground = none;
	ToolTipLabel = none;
}

function bool CanRender()
{
	local float timeSinceLastActivity;

	timeSinceLastActivity = `STimeSince( Scene().LastActivityTime ); 
	return super.CanRender() 
		&& timeSinceLastActivity >= ToolTipDelayTime && (ToolTipShowTime == -1 || timeSinceLastActivity <= ToolTipShowTime);
}

protected function InitializeComponent()
{
	super.InitializeComponent();

	ToolTipBackground = FPage(CreateComponent( ToolTipBackground.Class, self, ToolTipBackground ));
	AddComponent( ToolTipBackground );

	ToolTipLabel = FLabel(CreateComponent( ToolTipLabel.Class, ToolTipBackground, ToolTipLabel ));
	ToolTipLabel.SetText( ToolTipText );
	//ToolTipLabel.OnSizeChanged = ToolTipSizeChanged;
	ToolTipBackground.AddComponent( ToolTipLabel );
}

function AttachToPosition( IntPoint mousePosition, Vector2D screenSize )
{
	local float x, y, w, h;

	w = GetCachedWidth();
	h = GetCachedHeight();
	switch( ToolTipAttachPosition )
	{
		case P_Mouse:
			x = mousePosition.X/screenSize.X;
			y = (mousePosition.Y + Scene().CursorPointCoords.VL*Scene().CursorScaling)/screenSize.Y;

			// Align above if the tooltip would overflow screen size.
			if( y+h > screenSize.Y )
			{
				y = (mousePosition.Y - Scene().CursorPointCoords.VL*Scene().CursorScaling)/screenSize.Y;
			}
			break;

		case P_Component:
			x = FComponent(Outer).GetCachedLeft()/screenSize.X;
			y = (FComponent(Outer).GetCachedTop() + FComponent(Outer).GetCachedHeight())/screenSize.Y;

			// Align above if the tooltip would overflow screen size.
			if( y+h > screenSize.Y )
			{
				y -= (FComponent(Outer).GetCachedHeight() + h)/screenSize.Y;
			}
			break;
	}	
	SetPos( x, y );	
}

// Resize the tooltip size's equal to that of the tooltip label.
/*function ToolTipSizeChanged( FComponent sender )
{
	switch( sender )
	{
		case ToolTipLabel:
			SetSize( ToolTipLabel.GetWidth() + Padding.W + Padding.X, GetCachedHeight() );
			break;
	}
}*/

defaultproperties
{
	begin object name=oToolTipBackground class=FPage
		RelativePosition=(X=0.0,Y=0.0)
		RelativeSize=(X=1.0,Y=1.0)
		StyleNames.Empty()
		StyleNames.Add(ToolTipBackground)
	end object
	ToolTipBackground=oToolTipBackground

	begin object name=oToolTipText class=FLabel
		RelativePosition=(X=0.0,Y=0.0)
		RelativeSize=(X=1.0,Y=1.0)
		RelativeOffset=(X=0.0,Y=0.0)
		//bAutoSize=true
	end object
	ToolTipLabel=oToolTipText

	Margin=(X=0,Y=8,W=0,Z=8)
	RelativeSize=(X=200,Y=40)
	bEnabled=false

	// 500 milliseconds.
	ToolTipDelayTime=0.5

	// -1 == infinite.
	ToolTipShowTime=-1

	// Position nicely below(or above) the component that owns this tooltip.
	ToolTipAttachPosition=P_Component
}