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
 * FButton: A clickable component with a caption, animation and icon options.
 * ======================================================== */
class FButton extends FLabel;

var(Button, Display) bool					bRenderCaption;
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

function Update( float deltaTime )
{
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
	C.SetPos( PosX, PosY );
	RenderBackground( C, GetImageColor() );
	RenderButton( C );
}

protected function RenderButton( Canvas C )
{
	local float x, y;
	local float icoSize;
	
	if( bRenderCaption && Text != "" )
	{
		x = PosX + TextMoveOffset;
		if( Icon.Texture != none )
		{
			x += SizeY;		
		}
		
		RenderLabel( C, x, PosY, SizeX, SizeY, GetStateColor( FLabelStyle(Style).TextColor ),, icoSize );
	} 
	else if( Icon.Texture != none )
	{
		if( Icon.Texture.GetSurfaceHeight() < SizeY ) 
			icoSize = SizeY;
		else 
			icoSize = Icon.Texture.GetSurfaceHeight(); 
	}
	
	if( Icon.Texture != none )
	{
		x = PosX + Padding.W + (SizeY - icoSize)*0.5; 
		y = PosY + SizeY*0.5 - icoSize*0.5;
		C.SetPos( x, y );
		C.DrawColor = GetStateColor( class'HUD'.default.WhiteColor );
		C.DrawTile( Icon.Texture, icoSize, icoSize, Icon.U, Icon.V, Icon.UL, Icon.VL );
	}
}

defaultproperties
{
	RelativePosition=(X=0.0,Y=0.0)
	RelativeSize=(X=0.4,Y=0.18)
	Padding=(W=4)

	Text="Button"
	TextAlign=TA_Center
	bRenderCaption=true

	bEnabled=true
	bEnableClick=true
	bEnableCollision=true

	AnimateSpeed=15
	AnimateOffset=6

	StyleNames.Add(Button)
}