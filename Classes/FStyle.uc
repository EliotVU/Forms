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
 * FStyle: A shared and dynamically loaded style object from the "DefaultForms.ini"
 * ======================================================== */
class FStyle extends FObject
	perobjectconfig
	config(Forms);

// Built-in and hardcoded image textures.

/** If ImageName is set to ImageColor then use the ImageColor property as the image. */
const IMAGE_BACKGROUND = "@ImageColor";

/** The texture to be used as the component's background/image (If supported) */
var config const string							ImageName;
var config const TextureCoordinates				ImageNameCoords;
var(Style, Display) Texture2D					Image;
var(Style, Display) TextureCoordinates			ImageCoords;
var(Style, Display) config float				ImageScaling;

/** Image scaling method for @Image. */
var(Style, Display) config enum EImageMethod		
{
	/** Scales the image by repeating the horizontal and vertical center. */
	IM_Scale,

	/** Stretch the image like a photo. */
	IM_Stretch
}												ImageMethod;

/** 
 * Blending mode for @Image. Has only an affect if @ImageMethod is set to IM_Stretch. 
 * See: http://udn.epicgames.com/Three/CanvasTechnicalGuide.html#Blending%20Modes
 */
var(Style, Display) config EBlendMode			ImageBlendMode;

/** The texture to be used as the component's background/image (If supported) */
var config const string							ShadowName;
var config const TextureCoordinates				ShadowNameCoords;

var(Style, Display) Texture2D					Shadow;
var(Style, Display) TextureCoordinates			ShadowCoords;
var(Style, Display) int							ShadowSize;

var(Style, Colors) config const bool 			bTransitionColor;

var(Style, Colors) config const Color			ImageColor;
var(Style, Colors) config const Color			ShadowColor;

var(Style, Colors) config const Color			HoverColor;
var(Style, Colors) config const Color			FocusColor;
var(Style, Colors) config const Color			SelectedColor;
var(Style, Colors) config const Color			ActiveColor;
var(Style, Colors) config const Color			DisabledColor;

/** Collection of elements to render after the associated component(s). */
var(Style, Elements) config protectedwrite editinline array<struct sElement
{
	var transient FElement Element; 
	var() name Name; 
	var() class<FElement> Class;
}> 												Elements;

var(Style, Advanced) editinline FStyle			Inheritance;

function Initialize()
{
	if( ImageName != "" && ImageName != IMAGE_BACKGROUND )
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

	if( ImageScaling == 0.0 )
		ImageScaling = 1.0;

	InitializeElements();
}

function InitializeElements()
{
	local int i;

	for( i = 0; i < Elements.Length; ++ i )
	{
		Elements[i].Element = new (none, string(Elements[i].Name)) Elements[i].Class;
		Elements[i].Element.Initialize();
	}
}

function Render( Canvas C );

function RenderFirstElements( Canvas C, FComponent Object )
{
	local int i;

	for( i = 0; i < Elements.Length; ++ i )
	{
		if( Elements[i].Element.RenderOrder == O_First )
		{
			Elements[i].Element.RenderElement( C, Object );
		}
	}
}

function RenderLastElements( Canvas C, FComponent Object )
{
	local int i;

	for( i = 0; i < Elements.Length; ++ i )
	{
		if( Elements[i].Element.RenderOrder == O_Last )
		{
			Elements[i].Element.RenderElement( C, Object );
		}
	}
}

function DrawBackground( Canvas C, float width, float height )
{
	local float UL, VL;
	local float curX, curY;
	local Color curColor;

	if( ImageName == IMAGE_BACKGROUND )
	{
		C.DrawRect( width, height );
		return;
	}
	
	if( Image == none )
	{
		return;
	}
		
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
	switch( ImageMethod )
	{
		case IM_Scale:
			C.DrawTileStretched( 
				Image, width, height, 
				ImageCoords.U, ImageCoords.V, UL, VL
				,,,, ImageScaling
			);
			break;

		case IM_Stretch:
			C.DrawTile( 
				Image, width, height, 
				ImageCoords.U, ImageCoords.V, UL, VL
				,,, ImageBlendMode 
			);
			break;
	}
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
	C.DrawTile( Image, width + ShadowSize*2, height + ShadowSize*2, ShadowCoords.U, ShadowCoords.V, UL, VL, ColorToLinearColor( ShadowColor ) );
	C.SetClip( C.ClipX - ShadowSize, C.ClipY - ShadowSize );
}

function Free()
{
	local int i;
	
	for( i = 0; i < Elements.Length; ++ i )
	{
		Elements[i].Element.Free();
		Elements[i].Element = none;
	}
	Elements.Length = 0;
	
	Image = none;
	Shadow = none;
	Inheritance = none;
}

defaultproperties
{
	ImageCoords=(U=0.0,V=0.0,UL=1.0,VL=1.0)
	
	ShadowCoords=(U=0.0,V=0.0,UL=1.0,VL=1.0)
	ShadowSize=4
}