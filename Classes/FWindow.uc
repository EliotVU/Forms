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
class FWindow extends FPage;

function RenderComponent( Canvas C )
{
	C.SetPos( LeftX, TopY );
	C.DrawColor = ((InteractionState & ES_Hover) != ES_None) ? Style.HoverColor : Style.ImageColor;
	C.DrawTileStretched( Style.Image, WidthX, HeightY, 0, 0, Style.Image.SizeX, Style.Image.SizeY );
	if( HasFocus() )
	{
		C.DrawColor = Style.FocusColor;
		C.SetPos( LeftX, C.CurY );
		C.DrawBox( WidthX, HeightY );
	}
	super(FComponent).RenderComponent( C );
}

defaultproperties
{
	bSupportSelection=true
}