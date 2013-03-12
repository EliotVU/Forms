/* ========================================================
 * Copyright 2012 Eliot van Uytfanghe
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
 * FCheckBox: 
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
	RenderBackground( C, bChecked ? FCheckBoxStyle(Style).CheckedColor : FCheckBoxStyle(Style).UncheckedColor );

	if( Text != "" )
	{
		RenderLabel( C, LeftX, TopY, WidthX, HeightY, GetStateColor( TextColor ) );
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
	TextColor=(R=255,G=255,B=255,A=255)
	TextAlign=TA_Left

	StyleNames.Add(CheckBox)
	StyleClass=class'FCheckBoxStyle'

	bEnabled=true
}