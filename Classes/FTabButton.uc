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

function Free()
{
	super.Free();
	TabPage = none;
}

protected function RenderComponent( Canvas C )
{
	super(FComponent).RenderComponent( C );
	C.DrawColor = ((FTabControl(Parent).ActivePage == TabPage)
		? Style.SelectedColor 
		: (bRenderCaption && !bImageUseStateColor) 
			? Style.ImageColor 
			: GetStateColor());
	RenderBackground( C, C.DrawColor );
	RenderButton( C );
}

defaultproperties
{
	StyleNames.Add(TabButton)
	bAnimateOnHover=true
}