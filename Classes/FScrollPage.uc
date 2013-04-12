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
class FScrollPage extends FPage;

var `{Automated} FScrollBar ScrollBar;

function Free()
{
	super.Free();
	ScrollBar = none;
}

protected function InitializeComponent()
{
	super.InitializeComponent();
	ScrollBar = FScrollBar(CreateComponent( class'FScrollBar' ));
	ScrollBar.MaskComponent = self;
	AddComponent( ScrollBar );

	ScrollBar.InitializeScrollBar();
	ScrollBar.OnMouseWheelInput = MouseWheelInput;
}

function MouseWheelInput( FComponent sender, optional bool bUp )
{
	if( ScrollBar != none )
	{
		ScrollBar.OnMouseWheelInput( sender, bUp );
	}
}

defaultproperties
{
	bClipComponent=true
	Positioning=P_Fixed
}