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
 * FColumn: 
 * ======================================================== */
class FColumn extends FLabel;

var(Column) editinline Object 	AssociatedObject;
var(Column) string 				AssociatedCode;

var(Column, Display) editinline Texture2D ColumnImage;

function Free()
{
	super.Free();
	AssociatedObject = none;
	ColumnImage = none;
}

protected function RenderComponent( Canvas C )
{
	super(FComponent).RenderComponent( C );
	RenderBackground( C, CanInteract() ? GetImageColor() : Style.DisabledColor );
	RenderImage( C );
	RenderLabel( C, PosX, PosY, SizeX, SizeY, FLabelStyle(Style).TextColor );
	
	if( IsSelected() )
	{
		C.SetPos( PosX, PosY );
		// Still try to use another color if selected but also hovered or active.
		C.DrawColor = GetStateColor( Style.ActiveColor );
		C.DrawBox( SizeX+1, SizeY+1 );
	}
	else if( IsHovered() )
	{
		C.SetPos( PosX, PosY );
		// Even though we are hovered, lets still use other colors if it is both hovered and active etc.
		C.DrawColor = GetStateColor();
		C.DrawBox( SizeX+1, SizeY+1 );
	}
	// For the sake of undoing previous states.
	else GetStateColor();
}

protected function RenderImage( Canvas C )
{
	if( ColumnImage == none )
		return;
		
	C.SetPos( PosX, PosY );
	C.DrawColor = Style.ImageColor;
	C.DrawTile( ColumnImage, SizeX, SizeY, 0, 0, ColumnImage.SizeX, ColumnImage.SizeY );
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
	
	StyleNames.Add(Column)
	
	bEnabled=true
	bEnableClick=true
	bEnableCollision=true
}