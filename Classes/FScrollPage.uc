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
 * FScrollPage: A FPage with an auto-generated FScrollBar.
 * ======================================================== */
class FScrollPage extends FPage;

var editinline FScrollBar ScrollBar;

function Free()
{
	super.Free();
	ScrollBar = none;
}

protected function InitializeComponent()
{
	super.InitializeComponent();
	ScrollBar = FScrollBar(CreateComponent( class'FScrollBar',, ScrollBar ));
	ScrollBar.MaskComponent = self;
	ScrollBar.OnValueChanged = ScrollBarValueChanged;
	InsertComponent( ScrollBar, 0 );

	// Redirect any mouse wheel input on this page or any of its components.
	OnMouseWheelInput = ScrollBar.OnMouseWheelInput;
}

function ScrollBarValueChanged( FComponent sender )
{
	OriginOffset.Y = -ScrollBar.Value;
}

defaultproperties
{
	begin object name=ScrollBarTemplate class=FScrollBar
		//StepProgress=0.25
	end object
	ScrollBar=ScrollBarTemplate
	Positioning=P_Fixed
	bClipComponent=true
}