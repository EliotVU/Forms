class MyMainMenu extends FPage;

// A simple label displaying the player's name.
var() `{Automated} FLabel LPlayerName;

// Exit the game button.
var() `{Automated} FButton BExit;

/** Clear all object references for garbage collecting. */
function Free()
{
	super.Free();
	LPlayerName = none;
	BExit = none;
}

/** Executed when Initialize() is called. */
function InitializeComponent()
{
	local PlayerReplicationInfo PRI;

	PRI = PlayerReplicationInfo(Player().PlayerReplicationInfo);
	if( PRI != none )
	{
		LPlayerName.SetText( PRI.PlayerName );
	}
}

/** Executed whenever a button is pressed(If delegated) */
function Click( FComponent sender, optional bool bRight )
{
	switch( sender )
	{
		case BExit:	
			// Exit the game.
			sender.ConsoleCommand( "Exit" );
			break;
	}
}

defaultproperties
{
	// Centered
	RelativePosition=(X=0.25,Y=0.10)
	RelativeSize=(X=0.25,Y=0.8)
	
	// Once you have your own textures you should remove this and configue the style for MyMainMenu through the DefaultForms.ini!
	begin object name=oStyle
		Image=Texture2D'EngineResources.WhiteSquareTexture'	
		ImageColor=(R=128,G=128,B=128,A=200)
	end object
	Style=oStyle

	begin object name=oLPlayerName class=FLabel
		RelativePosition=(X=0.0,Y=0.18)
		RelativeSize=(X=1.0,Y=0.76)
		RelativeOffset=(X=16,Y=16)
		Text="PLAYERNAME"
		TextAlign=TA_Left
		TextVAlign=TA_Top
		TextRenderInfo=(bClipText=true)	// Set to false if you want to warp the text.
	end object
	LPlayerName=oLPlayerName
	Components.Add(oLPlayerName)

	begin object name=oBExit class=FButton
		RelativePosition=(X=1.0,Y=1.0)
		RelativeSize=(X=0.1,Y=0.05)
		HorizontalDock=HD_Right // Snap to the right (Pos X becomes the end position and Size X becomes the offset from the end)
		VerticalDock=VD_Bottom	// Snap to the bottom (Pos Y becomes the end position and Size Y becomes the offset from the end)
		Text="Exit"
		// Executes in Default_MyMainMenu, all references will be NONE! 
		//	- Use sender.Controller instead of just Controller!
		OnClick=Click
		// Share style with parent. You should remove this and configue the style for FButtons through the UDKForms.ini!
		Style=oStyle
	end object
	BExit=oBExit
	Components.Add(oBExit)
}