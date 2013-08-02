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
 * FDiv: Similar to the idea of HTML's div element.
 * This class can render a background, has no padding nor margin and no collision. Requires you to add a style of your own.
 * Used for the sake of background decoration(Like a header), no actual function purpose.
 * ======================================================== */
class FDiv extends FMultiComponent;

protected function RenderComponent( Canvas C )
{
	super.RenderComponent( C );
	RenderBackground( C );
}

defaultproperties
{
	bEnableClick=false
	bEnableCollision=false
	
	Margin=(X=0,Y=0,Z=0,W=0)
	Padding=(W=0,X=0,Y=0,Z=0)
	RelativeSize=(X=1.0,Y=1.0)
}