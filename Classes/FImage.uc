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
class FImage extends FComponent;

function RenderComponent( Canvas C )
{
	super.RenderComponent( C );
	RenderImage( C );
}

function RenderImage( Canvas C )
{
	C.SetPos( LeftX, TopY );
	C.DrawColor = Style.ImageColor;
	C.DrawTile( Style.Image, WidthX, HeightY, 0, 0, Style.Image.SizeX, Style.Image.SizeY );
}

defaultproperties
{
	RelativePosition=(X=0.01,Y=0.01)
	RelativeSize=(X=0.2,Y=0.2)

	`if( `isdefined( DEBUG ) )
		bEnabled=true
	`else
		// Disable any interaction
		bEnabled=false
	`endif
}