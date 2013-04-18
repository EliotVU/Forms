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
 * ======================================================== */
class FGroupBox extends FMultiComponent;

var(GroupBox, Advanced) `{Automated} FLabel Text;

function Free()
{
	super.Free();
	Text = none;
}

protected function InitializeComponent()
{
	super.InitializeComponent();
	if( Text != none )
	{
		Text.SetPos( 0.1, 0.00 );
		Text.SetSize( 0.3, 40 );
		Text.SetMargin( Text.Margin.W, -Padding.Y, Text.Margin.X, Text.Margin.Z*2 );
		Text.TextVAlign = TA_Center;
		AddComponent( Text );
	}
}

protected function RenderComponent( Canvas C )
{
	C.DrawColor = Style.ImageColor;
	
	// Left
	C.SetPos( LeftX, TopY + Padding.Z*0.5 );
	C.DrawRect( 1, HeightY - Padding.Z*0.5 );
	
	// Right
	C.SetPos( LeftX + WidthX - 1, TopY + Padding.Z*0.5 );
	C.DrawRect( 1, HeightY - Padding.Z*0.5 );
	
	if( Text != none )
	{
		// Top Left
		C.SetPos( LeftX, TopY + Padding.Z*0.5 );
		C.DrawRect( Text.GetCachedLeft() - (LeftX + C.OrgX) - Padding.W, 1 );
	
		// Top Right
		C.SetPos( Text.GetCachedLeft() + Text.GetCachedWidth() + Padding.X, TopY + Padding.Z*0.5 );
		C.DrawRect( WidthX - (Text.GetCachedLeft() - (LeftX + C.OrgX)) - Text.GetCachedWidth() - Padding.X, 1 );	
	}
	else
	{
		// Top
		C.SetPos( LeftX, TopY );
		C.DrawRect( WidthX, 1 );	
	}
	
	// Bottom
	C.SetPos( LeftX, TopY + HeightY - 1 );
	C.DrawRect( WidthX, 1 );		
}

defaultproperties
{
	bEnableClick=false
	bEnableCollision=false
	
	Padding=(W=8,X=8,Y=8,Z=8)

	StyleNames.Add(GroupBox)
}