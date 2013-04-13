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
 * FToolTipBase: See FToolTip.uc for an implementation.
 * ======================================================== */
class FToolTipBase extends FComponent
	abstract;
	
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

function bool CanRender()
{
	local float timeSinceLastActivity;

	timeSinceLastActivity = `STimeSince( Scene().LastActivityTime ); 
	return super.CanRender() 
		&& timeSinceLastActivity >= ToolTipDelayTime && (ToolTipShowTime == -1 || timeSinceLastActivity <= ToolTipShowTime);
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

defaultproperties
{
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