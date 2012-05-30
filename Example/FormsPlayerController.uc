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
/**
 *	FormsPlayerController - Forms initializer and methods to access Forms.
 */
class FormsPlayerController extends UDKPlayerController
	abstract;

/** 
 * Our FController. The Core of the Forms Framework. 
 * This reference instance holds the reference to the 'FScene' instance and redirects all input, updates and drawing to 'FScene'. 
 */
var transient FController	FormsController;

/** The FController class for Forms to initialize. */
var() class<FController>	FormsControllerClass;

/** The FScene class for Forms to initialize. */
var() class<FScene>			FormsSceneClass;

/** The FPage to be opened and non-closable if the loaded map is the UDKFrontEnd map. */
var() FPage					MainMenu;

/** The FPage to be opened when Escape is hit, if no prior pages are open. */
var() FPage					EscapeMenu;

/** Pages that need to be opened once the game is ready. Overrides MainMenu! */
var() array< class<FPage> > PagesQue;

var() PostProcessChain		MenuPostProcessChain;

/**
 * This is overriden so that we can add our 'FController' interaction before the 'Input' interaction, -
 *	while also initializing the 'FScene' class after 'Input' has been initialized.
 */
simulated event InitInputSystem()
{
	// We initialize the interaction before PlayerInput - 
	// because we need to have complete control of inputs which we can't have past this.
	// Ignore PIE because we do not yet clean up FObject's.
	if( FormsController == none && !WorldInfo.IsPlayInEditor() )
	{
		FormsController = new( self ) FormsControllerClass;
		Interactions.InsertItem( 0, FormsController );
		//LocalPlayer(Player).ViewportClient.InsertInteraction( FormsController, 0 );
		super.InitInputSystem();
		// We initialize the scene after the PlayerInput instance has been created -
		// because they'll need to access it at this point.
		if( FormsController != none )
		{
			FormsController.InitializeScene( FormsSceneClass );
			SceneInitialized();
		}
	}
	else
	{
		super.InitInputSystem();
	}
}

/**
 * SceneInitialized: Called when the 'FScene' class is initialized for the first time.
 * You should initialize your prefered settings for the Scene, add your pages and initialize visiblities if desired.
 */
simulated function SceneInitialized()
{
	local class<FPage> pageClass;

	`Log( "SceneInitialized",, 'Forms' );

	// The PostProcessChain to use when the FScene is visible.
	FormsController.Scene().MenuPostProcessChain = MenuPostProcessChain;

	MainMenu.Controller = FormsController;
	// Open any que'ing page, for example a Ready page when the a level is loaded that needs to be opened when possible.
	if( PagesQue.Length > 0 )
	{
		foreach PagesQue( pageClass )
		{
			ClientOpenPage( pageClass );
		}
		PagesQue.Length = 0;
	}
	else
	{
		// UDKFrontEnd, open our menu if set. Cannot be closed.
		if( WorldInfo.IsMenuLevel( GetURLMap() ) && MainMenu != none )
		{	
			FormsController.Scene().AddPage( MainMenu );
		}
	}	
}

/** Command the client to open a FPage class. (Closable) */
final reliable client function ClientOpenPage( class<FPage> pageClass )
{
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		FormsController.Scene().OpenPage( pageClass );
	}
}

/** Command the client to close all or front FPage's. (Closable) */
final reliable client function ClientClosePage( optional bool bCloseAll )
{
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		FormsController.Scene().ClosePage( bCloseAll );
	}
}

/** Toggle EscapeMenu/PauseMenu */
exec function ShowMenu()
{
	if( FormsController == none )
	{
		return;
	}

	// Logically we should only open the EscapeMenu when there are no other pages open!
	if( FormsController.Scene().Pages.Length == 0 )
	{
		if( EscapeMenu != none )
		{
			FormsController.Scene().AddPage( EscapeMenu );
		}
	}
	else
	{
		// The MainMenu cannot be closed! If there's more than one page, then close the front page.
		if( WorldInfo.IsMenuLevel( GetURLMap() ) && FormsController.Scene().Pages.Length == 1 )
		{
			return;
		}
		else
		{
			FormsController.Scene().ClosePage();
		}
	}
}

function Destroyed()
{
	// Let's remove these references to ensure that all GUI components are disconnected prior its garbage collecting invokes.
	MainMenu = none;
	EscapeMenu = none;
	PagesQue.Length = 0;
	super.Destroyed();	
}

defaultproperties
{
	FormsControllerClass=class'FController'
	FormsSceneClass=class'FScene'

	// Replace YOURPAGE with your MainMenu class. It's recommend that you handle properties within the class itself!
	begin object name=oMainMenu class=YOURPAGE
		// Properties
	end object
	MainMenu=oMainMenu

	// Replace YOURPAGE with your EscapeMenu class. It's recommend that you handle properties within the class itself!
	begin object name=oEscapeMenu class=YOURPAGE
		// Properties
	end object
	EscapeMenu=oEscapeMenu

	MenuPostProcessChain=PostProcessChain'PACKAGE.GROUP.NAME'
}