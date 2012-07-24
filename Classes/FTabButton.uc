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
 * FTabButton: The button for within TabControls. 
 * This button determines which associated TabPage will be visible and interactable.
 * ======================================================== */
class FTabButton extends FButton;

/** The FPage this button controls. */
var(TabButton, Display) `{Automated} FPage TabPage;

/** The FTabControler this button is associated with. */
var(TabButton, Advanced) `{Automated} FTabControl TabControl;

function Initialize( FIController c )
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

protected function RenderComponent( Canvas C )
{
	super(FComponent).RenderComponent( C );
	C.DrawColor = ((TabControl.ActivePage == TabPage)
		? Style.ActiveColor 
		: (bRenderCaption && !bImageUseStateColor) 
			? Style.ImageColor 
			: GetStateColor());
	RenderBackground( C, C.DrawColor );
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
	begin object name=oStyle
		ActiveColor=(R=94,G=94,B=94,A=255)
	end object
	bAnimateOnHover=true
}