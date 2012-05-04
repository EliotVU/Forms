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
class FTabButton extends FButton;

/** The FPage this button controls. */
var(Component, Display) editinline FPage TabPage;

/** The FTabControler this button is associated with. */
var(Component, Advanced) editinline FTabControl TabControl;

/** When the set FPage is visibile, this button will be drawn using this color. */
var(Component, Display) const Color ActiveColor;

function Initialize( FController c )
{
	super.Initialize( c );
	TabControl = FTabControl(Parent);
	if( TabPage.Parent == none )
	{
		if( TabControl.TabPagesParent != none )
		{
			TabPage.Parent = TabControl.TabPagesParent;
		}
		else TabPage.Parent = TabControl;
	}
	TabPage.Initialize( c );
}

function RenderComponent( Canvas C )
{
	super(FComponent).RenderComponent( C );
	RenderBackground( C, TabControl.ActivePage == TabPage ? ActiveColor : Style.ImageColor );
	RenderButton( C );
}

function Free()
{
	super.Free();
	TabControl = none;
	TabPage = none;
}

defaultproperties
{
	ActiveColor=(R=94,G=94,B=94,A=255)
	bAnimateOnHover=true
}