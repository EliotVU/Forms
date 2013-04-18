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
	
	curX = Object.GetCachedLeft();
	curY = Object.GetCachedTop();
	
	if( Left.Size > 0 )
	{
		C.SetPos( curX, curY );
		C.DrawColor = Left.Color;
		C.DrawRect( Left.Size, Object.GetCachedHeight() );
	}
	
	if( Right.Size > 0 )
	{
		C.SetPos( curX + Object.GetCachedWidth() - Right.Size, curY );
		C.DrawColor = Right.Color;
		C.DrawRect( Right.Size, Object.GetCachedHeight() );
	}

	if( Top.Size > 0 )
	{
		C.SetPos( curX, curY );
		C.DrawColor = Top.Color;
		C.DrawRect( Object.GetCachedWidth(), Top.Size );
	}
	
	if( Bottom.Size > 0 )
	{
		C.SetPos( curX, curY + Object.GetCachedHeight() - Bottom.Size );
		C.DrawColor = Bottom.Color;
		C.DrawRect( Object.GetCachedWidth(), Bottom.Size );
	}
}

defaultproperties
{
	// Render after background.
	RenderOrder=O_Last
}