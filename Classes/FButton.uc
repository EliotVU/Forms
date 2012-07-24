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
 * FButton: A clickable component with a caption, animation and icon options.
 * ======================================================== */
class FButton extends FLabel;

var(Button, Display) bool					bRenderCaption;
var(Button, Display) bool					bImageUseStateColor;
var(Button, Display) bool					bAnimateOnHover;
var(Button, Display) float					AnimateSpeed;
var(Button, Display) float					AnimateOffset;
var protected transient float				TextMoveOffset;

var(Button, Display) CanvasIcon				Icon;

function Free()
{
	super.Free();
	Icon.Texture = none;
}

// TODO: Using DeltaTime from Tick breaks the speed O_O
function Update( float deltaTime )
{
	// FIXME: deltaTime is always -1.0.
	deltaTime = Scene().RenderDeltaTime;
	super.Update( deltaTime );
	if( bAnimateOnHover )
	{
		if( IsHovered() )
		{
			TextMoveOffset = FMin( TextMoveOffset + AnimateSpeed*deltaTime, AnimateOffset );
		}
		else if( TextMoveOffset > 0.0 )
		{
			TextMoveOffset = FMax( TextMoveOffset - AnimateSpeed*deltaTime, 0.0 );
		}
	}
}

protected function RenderComponent( Canvas C )
{
	super(FComponent).RenderComponent( C );
	C.SetPos( LeftX, TopY );
	// If no caption, then colorize the background based on the component's state.
	C.DrawColor = (bRenderCaption && !bImageUseStateColor) ? Style.ImageColor : GetStateColor();
	RenderBackground( C, C.DrawColor );
	RenderButton( C );
}

protected function RenderButton( Canvas C )
{
	local float x, y;
	local float icoSize;
	
	//if( HasFocus() )
	//{
		//C.SetPos( LeftX, C.CurY );
		//C.DrawColor = Style.FocusColor;
		//C.DrawBox( WidthX, HeightY );
	//}

	if( bRenderCaption && Text != "" )
	{
		x = LeftX + TextMoveOffset;
		if( Icon.Texture != none )
		{
			x += HeightY;		
		}
		
		RenderLabel( C, x, TopY, WidthX, HeightY, 
			(bImageUseStateColor) ? TextColor : GetStateColor( TextColor ),, icoSize
		);
	} 
	else if( Icon.Texture != none )
	{
		if( Icon.Texture.GetSurfaceHeight() < HeightY ) 
			icoSize = HeightY;
		else 
			icoSize = Icon.Texture.GetSurfaceHeight(); 
	}
	
	if( Icon.Texture != none )
	{
		x = LeftX + Padding.W + (HeightY - icoSize)*0.5; 
		y = TopY + HeightY*0.5 - icoSize*0.5;
		C.SetPos( x, y );
		C.DrawColor = bImageUseStateColor ? class'HUD'.default.WhiteColor : GetStateColor( class'HUD'.default.WhiteColor );
		C.DrawTile( Icon.Texture, icoSize, icoSize, Icon.U, Icon.V, Icon.UL, Icon.VL );
	}
}

defaultproperties
{
	RelativePosition=(X=0.0,Y=0.0)
	RelativeSize=(X=0.4,Y=0.18)
	Padding=(W=4)

	Text="Button"
	TextFont=MultiFont'UI_Fonts_Final.HUD.MF_Medium'
	TextColor=(R=255,G=255,B=255,A=255)
	TextAlign=TA_Center
	bRenderCaption=true

	bEnabled=true

	AnimateSpeed=15
	AnimateOffset=6
}