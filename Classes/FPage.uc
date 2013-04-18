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
 * FPage: Basically the equivalant of <div>s in HTML. 
 * This is a required component for the FScene in order to use any other component
 * ======================================================== */
class FPage extends FMultiComponent;

// Open, Close functionality works only on FPages with the FScene as parent's instance.
delegate OnOpen( FPage sender );
delegate OnClose( FPage sender );

function Free()
{
	super.Free();
	OnOpen = none;
	OnClose = none;
}

function Opened()
{
	OnOpen( self );
}

function Closed()
{
	OnClose( self );
}

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
	Padding=(X=8,Y=8,Z=8,W=8)
	RelativeSize=(X=0.8,Y=0.8)

	StyleNames.Add(Page)
}