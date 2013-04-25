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
 * FElementGradient: A directional rectangle gradient background.
 * Draws a gradient using @BeginColor and @EndColor.
 * ======================================================== */
class FElementGradient extends FElement;

/** Gradient direction. */
var(Gradient, Display) const config enum EDirection
{
	/** Begin drawing from the top to bottom. */
	D_Top,
	
	/** Begin drawing from the bottom to top. TBI */
	D_Left
} Direction;

/** Start color for this gradient. */
var(Gradient, Display) const config Color BeginColor;

/** End color for this gradient. */
var(Gradient, Display) const config Color EndColor;

/** The size for each color line. Lower = higher quality, Higher = better performance. */
var(Gradient, Display) const config byte Quality;

var Texture Pixel;

//==============================================
// Cached Variables
var protected byte W, H;
var protected Vector ColorVect1, ColorVect2;
var protected float ColorA1, ColorA2;

function Free()
{
	super.Free();
	Pixel = none;
}

function Refresh()
{
	W = Pixel.GetSurfaceWidth();
	H = Pixel.GetSurfaceHeight();

	ColorVect1.X = BeginColor.R;
	ColorVect1.Y = BeginColor.G;
	ColorVect1.Z = BeginColor.B;
	ColorA1 = BeginColor.A;

	ColorVect2.X = EndColor.R - ColorVect1.X;
	ColorVect2.Y = EndColor.G - ColorVect1.Y;
	ColorVect2.Z = EndColor.B - ColorVect1.Z;
	ColorA2 = EndColor.A - ColorA1;
}

function RenderElement( Canvas C, FComponent Object )
{
	local int i, lines;
	local float pct;
	local float orgX, orgY;
	local float XL, YL;

	XL = Object.GetWidth();
	YL = Object.GetHeight();

	lines = YL/float(Quality) + 1;
	orgX = Object.GetLeft();
	orgY = Object.GetTop();
	C.SetPos( orgX, orgY );
	C.PreOptimizeDrawTiles( lines, Pixel );
	for( i = 0; i < lines; ++ i )
	{
		pct = float(i)/float(lines - 1);
		C.DrawColor.R = ColorVect1.X + ColorVect2.X*pct;
		C.DrawColor.G = ColorVect1.Y + ColorVect2.Y*pct;
		C.DrawColor.B = ColorVect1.Z + ColorVect2.Z*pct;
		C.DrawColor.A = ColorA1 + ColorA2*pct;
		C.DrawTile( Pixel, 
			XL, Min( Quality, YL - (C.CurY - orgY) ),
			0, 0,
			W, H
		);
		C.SetPos( orgX, C.CurY + Quality );

		//`Log( "Line" @ i+1 $ "/" $ lines @ "Progress" @ C.CurY - orgY $ "/" $ YL @ "Fade:" @ pct );
	}
}

defaultproperties
{
	Pixel="EngineResources.WhiteSquareTexture"
}