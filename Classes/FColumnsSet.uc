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
 * FColumnsSet: 
 * ======================================================== */
class FColumnsSet extends FMultiComponent;

var(ColumnsSet, Display) editconst int NumColumns;
var(ColumnsSet, Display) editconst int NumRows;

var(ColumnsSet, Function) editconst class<FColumn> ColumnClass;

var(ColumnsSet, Advanced) protectedwrite editinline array<FColumn> Columns;

var protectedwrite editinline transient FColumn SelectedColumn;

delegate OnSelect( FColumn sender );

function Free()
{
	super.Free();
	Columns.Length = 0;
	SelectedColumn = none;
	OnSelect = none;
}

protected function InitializeComponent()
{
	local int i, j;
	local float columnSizeX, columnSizeY;
	local float pX, pY;
	local FColumn comp;
	
	super.InitializeComponent();
	
	columnSizeX = 1.0/float(NumColumns);
	columnSizeY = 1.0/float(NumRows);
	pY = 0.0;
	for( i = 0; i < NumRows; ++ i )
	{
		pX = 0.0;
		for( j = 0; j < NumColumns; ++ j )
		{
			comp = FColumn(CreateComponent( ColumnClass, self ));
			comp.SetPos( pX, pY );
			comp.SetSize( columnSizeX, columnSizeY );
			comp.OnClick = ColumnClicked;
			AddComponent( comp );
			Columns.AddItem( comp );
			
			pX += columnSizeX;
		}
		pY += columnSizeY;
	}
}

protected function ColumnClicked( FComponent sender, optional bool bRight )
{
	SelectColumn( FColumn(sender) );
}

final function SelectColumn( FColumn col )
{
	SelectedColumn = col;
	OnSelect( SelectedColumn );		
}

final function FColumn GetPrevColumn()
{
	local FColumn col;
	local int i, selectedIndex;

	foreach Columns( col, i )
	{
		if( col == SelectedColumn )
		{
			selectedIndex = i;
			break;
		}
	}

	col = none;
	for( i = selectedIndex - 1; i >= 0; -- i )
	{
		if( !Columns[i].CanInteract() )
			continue;

		col = Columns[i];
		break;
	}

	return col;
}

final function FColumn GetNextColumn()
{
	local FColumn col;
	local int i, selectedIndex;

	foreach Columns( col, i )
	{
		if( col == SelectedColumn )
		{
			selectedIndex = i;
			break;
		}
	}

	col = none;
	for( i = selectedIndex + 1; i < Columns.Length; ++ i )
	{
		if( !Columns[i].CanInteract() )
			continue;

		col = Columns[i];
		break;
	}

	return col;
}

protected function RenderComponent( Canvas C )
{
	super.RenderComponent( C );
	RenderBackground( C );
}

defaultproperties
{
	NumColumns=3
	NumRows=3
	ColumnClass=class'FColumn'
	
	bEnableClick=false
	bEnableCollision=false
}