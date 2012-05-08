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
class FormsPage extends FPage;

var() `{Automated} FLabel LDescription;
var() `{Automated} FButton BBack, BReady;

/** Executed when Initialize() is called. */
function InitializeComponent()
{
	local TRPlayerReplicationInfo PRI;

	PRI = TRPlayerReplicationInfo(Player().PlayerReplicationInfo);
	if( PRI != none )
	{
		LDescription.SetText( PRI.PlayerName );
	}
}

/** Executed whenever a button is pressed(If delegated) */
function Click( FComponent sender, optional bool bRight )
{
	switch( sender )
	{
		case BReady:	
			sender.Scene().ClosePage( true );
			break;
	}
}

/** Executed when this Page is about to be closed! */
function Close( FPage sender )
{
	sender.ConsoleCommand( "Ready" );
}

defaultproperties
{
	RelativePosition=(X=0.2,Y=0.1)
	RelativeSize=(X=0.6,Y=0.8)
	
	Padding=(X=4,Y=4,W=4,Z=4)
	
	OnClose=Close

	begin object name=oStyle
		Image=Texture2D'EngineResources.WhiteSquareTexture'	
		ImageColor=(R=255,G=255,B=255,A=255)
	end object
	Style=oStyle

	begin object name=oDesc class=FLabel
		RelativePosition=(X=0.0,Y=0.18)
		RelativeSize=(X=1.0,Y=0.76)
		RelativeOffset=(X=16,Y=16)
		Text="PLAYERNAME"
		TextAlign=TA_Left
		TextVAlign=TA_Top
		TextRenderInfo=(bClipText=true)	// Set to false if you want to warp the text.
	end object
	LDescription=oDesc
	Components.Add(oDesc)

	begin object name=oReady class=FButton
		RelativePosition=(X=0.99,Y=0.94)
		RelativeSize=(X=0.1,Y=0.05)
		HorizontalDock=HD_Right
		Text="Ready"
		// Executes in Default_FormsPage, all references will be NONE! 
		//	- Use sender.Controller instead of just Controller!
		OnClick=Click
	end object
	BReady=oReady
	Components.Add(oReady)
}