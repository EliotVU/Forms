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
/** A style object, where all the styles are configured with element objects. 
	A style object is shared between more than one FComponent! */
class FStyle extends FObject
	perobjectconfig
	config(Forms);

/** The texture to be used as the component's background/image (If supported) */
var(Style, Display) editinline Texture2D		Image;
var(Style, Positioning) TextureCoordinates		ImageCoords;
var config const editconst string				ImageName;
var config const editconst TextureCoordinates	ImageNameCoords;

/** The texture to be used as the component's background/image (If supported) */
var(Style, Display) editinline Texture2D		Shadow;
var(Style, Positioning) TextureCoordinates		ShadowCoords;
var config const editconst string				ShadowName;
var config const editconst TextureCoordinates	ShadowNameCoords;
var int											ShadowSize;

/** The material to be used as the component's image (If supported) */
var(Style, Display) editinline Material			Material;
var config const editconst string				MaterialName;

var(Style, Colors) const Color ImageColor;
var(Style, Colors) const Color ShadowColor;
var(Style, Colors) const Color HoverColor;
var(Style, Colors) const Color FocusColor;
var(Style, Colors) const Color ActiveColor;
var(Style, Colors) const Color DisabledColor;

/** Collection of elements to render after the associated component(s). */
var(Style, Elements) protectedwrite editinline array<FElement> Elements;

function Initialize()
{
	if( ImageName != "" )
	{
		Image = Texture2D(DynamicLoadObject( ImageName, class'Texture2D', true ));
		if( ImageNameCoords.UL > 0.00 && ImageNameCoords.VL > 0.00 )
		{
			ImageCoords = ImageNameCoords;
		}
	}
	
	if( ShadowName != "" )
	{
		Shadow = Texture2D(DynamicLoadObject( ShadowName, class'Texture2D', true ));
		if( ShadowNameCoords.UL > 0.00 && ShadowNameCoords.VL > 0.00 )
		{
			ShadowCoords = ShadowNameCoords;
		}
	}

	if( MaterialName != "" )
	{
		Material = Material(DynamicLoadObject( MaterialName, class'Material', true ));
	}

	InitializeElements();
	
	`if( `isdefined( DEBUG ) )
		SaveConfig();
	`endif
}

function InitializeElements()
{
	local int i;

	for( i = 0; i < Elements.Length; ++ i )
	{
		Elements[i].Initialize();
	}
}

function Render( Canvas C );

function RenderElements( Canvas C, FComponent Object )
{
	local int i;

	for( i = 0; i < Elements.Length; ++ i )
	{
		Elements[i].RenderElement( C, Object );
	}
}

function DrawBackground( Canvas C, float width, float height )
{
	local float UL, VL;
	local float curX, curY;
	local Color curColor;
	
	if( Image == none )
		return;
		
	if( Shadow != none )
	{
		curColor = C.DrawColor;
		curX = C.CurX;
		curY = C.CurY; 
		
		DrawShadow( C, width, height );
		
		C.SetPos( curX, curY );
		C.DrawColor = curColor;
	}
	
	UL = (ImageCoords.UL <= 1.0) ? float(Image.SizeX) : ImageCoords.UL;
	VL = (ImageCoords.VL <= 1.0) ? float(Image.SizeY) : ImageCoords.VL;		
	C.DrawTileStretched( Image, width, height, ImageCoords.U, ImageCoords.V, UL, VL );
}

function DrawShadow( Canvas C, float width, float height )
{
	local float UL, VL;
	
	if( Shadow == none )
		return;
	
	UL = (ShadowCoords.UL <= 1.0) ? float(Shadow.SizeX) : ShadowCoords.UL;
	VL = (ShadowCoords.VL <= 1.0) ? float(Shadow.SizeY) : ShadowCoords.VL;		
	
	C.DrawColor = ShadowColor;
	C.SetPos( C.CurX - ShadowSize, C.CurY - ShadowSize );
	C.SetClip( C.ClipX + ShadowSize, C.ClipY + ShadowSize );
	C.DrawTile( Image, width + ShadowSize*2, height + ShadowSize*2, ShadowCoords.U, ShadowCoords.V, UL, VL );
	C.SetClip( C.ClipX - ShadowSize, C.ClipY - ShadowSize );
}

function Free()
{
	Elements.Length = 0;
	Image = none;
	Shadow = none;
	Material = none;
}

defaultproperties
{
	HoverColor=(R=255,G=255,B=0,A=255)
	FocusColor=(R=180,G=180,B=180,A=255)
	ActiveColor=(R=200,G=200,B=200,A=255)
	DisabledColor=(R=0,G=0,B=0,A=255)
	
	ImageCoords=(U=0.0,V=0.0,UL=1.0,VL=1.0)
	ImageColor=(R=255,G=255,B=255,A=255)
	
	ShadowCoords=(U=0.0,V=0.0,UL=1.0,VL=1.0)
	ShadowColor=(A=32)
	ShadowSize=4
}