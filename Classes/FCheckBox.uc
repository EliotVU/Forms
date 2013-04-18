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
 * FCheckBox: A simple button like component but instead toogles @bChecked and triggers OnChecked, 
 *  - which is useful to setup boolean configurations such as "Enable Bloom".
 * ======================================================== */
class FCheckBox extends FLabel;

var(CheckBox, Usage) bool bChecked;

delegate OnChecked( FComponent sender );

function Free()
{
	super.Free();
	OnChecked = none;
}

protected function RenderComponent( Canvas C )
{
	super(FComponent).RenderComponent( C );
	RenderBackground( C, GetImageColor() );

	if( Text != "" )
	{
		TextDecoration = bChecked ? default.TextDecoration : D_Overlined;
		RenderLabel( C, LeftX, TopY, WidthX, HeightY, GetStateColor( FLabelStyle(Style).TextColor ) );
	}
}

function Click( FComponent sender, optional bool bRight )
{
	Checked( !IsChecked() );
}

function bool IsChecked()
{
	return bChecked;
}

final function Checked( bool c )
{
	bChecked = c;
	OnChecked( self );
}

defaultproperties
{
	OnClick=Click

	Text="CheckBox"
	TextAlign=TA_Left
	TextDecorationColor=(R=200,G=0,B=0,A=128)
	TextDecorationSize=3

	StyleNames.Add(CheckBox)
	
	bEnabled=true
	bEnableClick=true
	bEnableCollision=true
}