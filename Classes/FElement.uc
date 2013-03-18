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
 * FElement: The base class of all renderable elements.
 * Elements are simple style additions for components, such as borders and gradients.
 *
 * EXAMPLE
 * \
 	begin object name=oBorderStyle class=FStyle
 		begin object name=oBorderElement class=FElementBorder
 			Left=(Color=(A=255),Size=1)	
 			Right=(Color=(A=255),Size=1)	
 			Top=(Color=(A=255),Size=1)	
 			Bottom=(Color=(A=255),Size=1)	
 		end object
		Elements.Add(oBorderElement)
 	end object
 
 	begin object name=oBorderedButton class=FButton
 		Style=oBorderStyle
 	end object
 	Components.Add(oBorderedButton)
 * ======================================================== */
class FElement extends Object
	config(Forms)
	perobjectconfig
	hidecategories(Object)
	editinlinenew
	abstract;

enum EOrder
{
	/** If element must be rendered before any component rendering starts. */
	O_First,
	
	/** If element must be rendered after the component rendering finished. */
	O_Last
};

/** Order this element should be rendered. */
var(Element, Display) EOrder		RenderOrder;

/** Cache here any variables to boost performance. */
function Initialize()
{
	Refresh();
}

/** Refresh here any cached variables. */
function Refresh();

/** Render here your element. */
function RenderElement( Canvas C, FComponent Object );

/** Cleanup here all object references for garbage collecting. */
function Free();

defaultproperties
{
	RenderOrder=O_First
}