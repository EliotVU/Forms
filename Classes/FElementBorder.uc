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
 * FElementBorder: A four side border.
 * Draws four side borders each with a prefered color and size.
 * ======================================================== */
class FElementBorder extends FElement;

/** A border structure. */
struct sBorderSide
{
	/** The border size in pixels. */
	var byte Size;
	
	/** The border color. */
	var Color Color;
};

/** Border sides. */
var(Border, Display) config sBorderSide Left, Right, Top, Bottom;

function RenderElement( Canvas C, FComponent Object )
{
	local float curX, curY;
	
	curX = Object.GetLeft();
	curY = Object.GetTop();
	
	if( Left.Size > 0 )
	{
		C.SetPos( curX, curY );
		C.DrawColor = Left.Color;
		C.DrawRect( Left.Size, Object.GetHeight() );
	}
	
	if( Right.Size > 0 )
	{
		C.SetPos( curX + Object.GetWidth() - Right.Size, curY );
		C.DrawColor = Right.Color;
		C.DrawRect( Right.Size, Object.GetHeight() );
	}

	if( Top.Size > 0 )
	{
		C.SetPos( curX, curY );
		C.DrawColor = Top.Color;
		C.DrawRect( Object.GetWidth(), Top.Size );
	}
	
	if( Bottom.Size > 0 )
	{
		C.SetPos( curX, curY + Object.GetHeight() - Bottom.Size );
		C.DrawColor = Bottom.Color;
		C.DrawRect( Object.GetWidth(), Bottom.Size );
	}
}

defaultproperties
{
	// Render after background.
	RenderOrder=O_Last
}