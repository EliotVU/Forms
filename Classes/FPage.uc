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
class FPage extends FMultiComponent;

// Open, Close functionality works only on FPages with the FScene as parent's instance.
delegate OnOpen( FPage sender );
delegate OnClose( FPage sender );

function Free()
{
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
	bSupportSelection=`devmode
	bSupportHovering=`devmode
	
	bClipComponent=true
	Margin=(X=0,Y=0,Z=0,W=0)
	Padding=(X=8,Y=8,Z=8,W=8)
}