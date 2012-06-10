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
	ColumnImage = none;
}

protected function RenderComponent( Canvas C )
{
	super(FComponent).RenderComponent( C );
	RenderBackground( C );
	RenderImage( C );
	RenderLabel( C, LeftX, TopY, WidthX, HeightY, TextColor );
	
	if( IsSelected() )
	{
		C.SetPos( LeftX, TopY );
		// Still try to use another color if selected but also hovered or active.
		C.DrawColor = GetStateColor( Style.ActiveColor );
		C.DrawBox( WidthX, HeightY );
	}
	else if( IsHovered() )
	{
		C.SetPos( LeftX, TopY );
		// Even though we are hovered, lets still use other colors if it is both hovered and active etc.
		C.DrawColor = GetStateColor();
		C.DrawBox( WidthX, HeightY );
	}
	// For the sake of undoing previous states.
	else GetStateColor();
}

protected function RenderImage( Canvas C )
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
	RelativeOffset=(Y=8)
	TextVAlign=TA_Top
	TextAlign=TA_Center
	
	begin object name=oStyle
		HoverColor=(R=200,A=120)
		ActiveColor=(R=0,G=200,B=0,A=128)
		DisabledColor=(R=200,G=0,B=0,A=255)
	end object
	Style=oStyle
	
	bEnabled=true
}