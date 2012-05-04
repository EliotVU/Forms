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
class FormsPlayerController extends UDKPlayerController
	abstract;

/** 
 * Our FController. The Core of the Forms Framework. 
 * This reference instance holds the reference to the 'FScene' instance and redirects all input, updates and drawing to 'FScene'. 
 */
var transient FController	FormsController;
var() class<FController>	FormsControllerClass;
var() class<FScene>			FormsSceneClass;

var() FPage MainMenu;
var() FPage EscapeMenu;

var() array< class<FPage> > PagesQue;

/**
 * This is overriden so that we can add our 'FController' interaction before the 'Input' interaction, -
 *	while also initializing the 'FScene' class after 'Input' has been initialized.
 */
simulated event InitInputSystem()
{
	// We initialize the interaction before PlayerInput - 
	// because we need to have complete control of inputs which we can't have past this.
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

	`Log( "SceneInitialized" );

	FormsController.Scene.MenuPostProcessChain = PostProcessChain'GameContent.Effects.MenuPostProcess';

	MainMenu.Controller = FormsController;
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
		if( WorldInfo.IsMenuLevel( GetURLMap() ) && MainMenu != none )
		{	
			FormsController.Scene.AddPage( MainMenu );
		}
	}	
}

final reliable client function ClientOpenPage( class<FPage> pageClass )
{
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		FormsController.Scene.OpenPage( pageClass );
	}
}

final reliable client function ClientClosePage( optional bool bCloseAll )
{
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		FormsController.Scene.ClosePage( bCloseAll );
	}
}

exec function ShowMenu()
{
	if( FormsController == none )
	{
		return;
	}

	if( FormsController.Scene.Pages.Length == 0 )
	{
		if( EscapeMenu != none )
		{
			FormsController.Scene.AddPage( EscapeMenu );
		}
	}
	else
	{
		if( WorldInfo.IsMenuLevel( GetURLMap() ) && FormsController.Scene.Pages.Length == 1 )
		{
			return;
		}
		else
		{
			FormsController.Scene.ClosePage();
		}
	}
}

defaultproperties
{
	FormsControllerClass=class'FController'
	FormsSceneClass=class'FScene'

	// EXAMPLE
	/*begin object name=oMainMenu class=YOURPAGE
		// Properties
	end object
	MainMenu=oMainMenu

	begin object name=oEscapeMenu class=YOURPAGE
		// Properties
	end object
	EscapeMenu=oEscapeMenu*/
}