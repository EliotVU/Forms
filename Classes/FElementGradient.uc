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
class FElementGradient extends FElement;

var() const enum EDirection
{
	D_Top,
	D_Left
} Direction;
var() const Color BeginColor;
var() const Color EndColor;

var() const byte Quality;
var Texture Pixel;

//==============================================
// Cached Variables
var protected byte W, H;
var protected Vector ColorVect1, ColorVect2;
var protected float ColorA1, ColorA2;

function Initialize()
{
	Refresh();
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

	XL = Object.GetCachedWidth();
	YL = Object.GetCachedHeight();

	lines = YL / float(Quality)+1;
	orgX = C.CurX;
	orgY = C.CurY;
	C.PreOptimizeDrawTiles( lines, Pixel );
	for( i = 0; i < lines; ++ i )
	{
		pct = float(i)/float(lines-1);
		C.DrawColor.R = ColorVect1.X + ColorVect2.X * pct;
		C.DrawColor.G = ColorVect1.Y + ColorVect2.Y * pct;
		C.DrawColor.B = ColorVect1.Z + ColorVect2.Z * pct;
		C.DrawColor.A = ColorA1 + ColorA2 * pct;
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
	Quality=2
	Direction=D_Top
	Pixel="EngineResources.WhiteSquareTexture"
}