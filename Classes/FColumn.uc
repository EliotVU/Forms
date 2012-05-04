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
class FColumn extends FLabel;

var() editinline Object AssociatedObject;
var() string AssociatedCode;

var(Component, Display) editinline Texture2D ColumnImage;

function Free()
{
	super.Free();
	AssociatedObject = none;
}

function RenderComponent( Canvas C )
{
	super(FComponent).RenderComponent( C );
	RenderBackground( C );
	RenderImage( C );
	RenderLabel( C, LeftX, TopY, WidthX, HeightY, TextColor );
	
	if( IsSelected() )
	{
		C.SetPos( LeftX, TopY );
		C.DrawColor = Style.ActiveColor;
		C.DrawBox( WidthX, HeightY );
	}
	else if( IsHovered() )
	{
		C.SetPos( LeftX, TopY );
		C.DrawColor = Style.HoverColor;
		C.DrawBox( WidthX, HeightY );
	}
}

function RenderImage( Canvas C )
{
	if( ColumnImage == none )
		return;
		
	C.SetPos( LeftX, TopY );
	C.DrawColor = Style.ImageColor;
	C.DrawTile( ColumnImage, WidthX, HeightY, 0, 0, ColumnImage.SizeX, ColumnImage.SizeY );
}

final function bool IsSelected()
{
	return FColumnsSet(Parent).SelectedColumn == self;
}

defaultproperties
{
	Margin=(X=2,Y=2,Z=2,W=2)
	Padding=(X=4,Y=4,Z=4,W=4)
	TextVAlign=TA_Top
	TextAlign=TA_Center
	
	begin object name=oStyle
		ImageColor=(R=255,G=255,B=255,A=255)
		HoverColor=(R=255,G=255,B=0,A=255)
		ActiveColor=(R=0,G=255,B=0,A=255)
		DisabledColor=(R=255,G=0,B=0,A=255)
	end object
	Style=oStyle
}