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
class FScrollStyle extends FStyle;

var(Style, Display) editinline Texture2D		TrackImage;
var(Style, Positioning) TextureCoordinates		TrackImageCoords;
var config const editconst string				TrackImageName;
var config const editconst TextureCoordinates	TrackImageNameCoords;

var(Style, Colors) const Color					TrackImageColor;

function Free()
{
	super.Free();
	TrackImage = none;
}

function Initialize()
{
	if( TrackImageName != "" )
	{
		TrackImage = Texture2D(DynamicLoadObject( TrackImageName, class'Texture2D', true ));
		if( TrackImageNameCoords.UL > 0.00 && TrackImageNameCoords.VL > 0.00 )
		{
			TrackImageCoords = TrackImageNameCoords;
		}
	}
	
	super.Initialize();
}

function DrawTracker( Canvas C, float width, float height )
{
	local float UL, VL;
	
	if( TrackImage == none )
		return;
		
	UL = (TrackImageCoords.UL <= 1.0) ? float(TrackImage.SizeX) : TrackImageCoords.UL;
	VL = (TrackImageCoords.VL <= 1.0) ? float(TrackImage.SizeY) : TrackImageCoords.VL;		
	C.DrawTileStretched( TrackImage, width, height, TrackImageCoords.U, TrackImageCoords.V, UL, VL );
}

defaultproperties
{
	ImageColor=(R=255,G=255,B=255,A=255)
	TrackImageColor=(R=200,G=200,B=200,A=255)
}