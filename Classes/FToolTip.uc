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
 * FToolTip: A basic tooltip control with a label and a background, similar to that of Windows.
 * Can be extended either inside the component that initializes this tooltip or by extending this class.
 * ======================================================== */
class FToolTip extends FToolTipBase;

/** The tooltip's text. */
var(ToolTip, Display) editconst string 			ToolTipText;

/** The tooltip's background using the style 'ToolTipBackground' see in @DefaultForms.ini */
var(ToolTip, Advanced) editinline FPage 		ToolTipBackground;

/** The tooltip's label. Use @ToolTipText to set this label's text. */
var(ToolTip, Advanced) editinline FLabel 		ToolTipLabel;

function Free()
{
	super.Free();
	ToolTipBackground = none;
	ToolTipLabel = none;
}

protected function InitializeComponent()
{
	super.InitializeComponent();

	ToolTipBackground = FPage(CreateComponent( ToolTipBackground.Class,, ToolTipBackground ));
	AddComponent( ToolTipBackground );

	ToolTipLabel = FLabel(CreateComponent( ToolTipLabel.Class, ToolTipBackground, ToolTipLabel ));
	ToolTipLabel.SetText( ToolTipText );
	//ToolTipLabel.OnSizeChanged = ToolTipSizeChanged;
	ToolTipBackground.AddComponent( ToolTipLabel );
}

// Resize the tooltip size's equal to that of the tooltip label.
/*function ToolTipSizeChanged( FComponent sender )
{
	switch( sender )
	{
		case ToolTipLabel:
			SetSize( ToolTipLabel.GetWidth() + Padding.W + Padding.X, GetCachedHeight() );
			break;
	}
}*/

defaultproperties
{
	begin object name=oToolTipBackground class=FPage
		RelativePosition=(X=0.0,Y=0.0)
		RelativeSize=(X=1.0,Y=1.0)
		StyleNames.Empty()
		StyleNames.Add(ToolTipBackground)
	end object
	ToolTipBackground=oToolTipBackground

	begin object name=oToolTipText class=FLabel
		RelativePosition=(X=0.0,Y=0.0)
		RelativeSize=(X=1.0,Y=1.0)
		RelativeOffset=(X=0.0,Y=0.0)
		//bAutoSize=true
	end object
	ToolTipLabel=oToolTipText
}