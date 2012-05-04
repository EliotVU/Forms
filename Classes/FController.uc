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
//=============================================================================
// FController: The Input processing, updating and drawing redirector for the 'FScene' class.
// Within: We use within so we don't have to cast PlayerController on the Outer reference!
//=============================================================================
class FController extends Interaction within UDKPlayerController
	config(Forms);

var() privatewrite editinline FScene Scene;

final function InitializeScene( optional class<FScene> sceneClass = class'FScene' )
{
	if( Scene == none )
	{
		Scene = new( none, "Forms" ) sceneClass;
		if( Scene != none )
		{
			Scene.Initialize( self );
		}
		else
		{
			assert( false );
		}
	}
}

final function bool OnKeyInput( int ControllerId, name Key, EInputEvent EventType, optional float AmountDepressed=1.f, optional bool bGamepad )
{
	if( Scene == none )
		return false;

	if( Scene.CanInteract() )
	{
		`if( `DEBUG )
			Player().ClientMessage( string(Key) );
		`endif

		if( Scene.OnKeyInput( Key, EventType ) )
		{
			// HACK: Don't break "ShowMenu"
			if( Key == 'Escape' )
			{
				return false;
			}
			return true;
		}
	}
	return false;
}

final function bool OnCharInput( int ControllerId, string Unicode )
{
	if( Scene != none && Scene.CanInteract() )
	{
		return Scene.OnCharInput( Unicode );
	}	
	return false;
}

event Tick( float DeltaTime )
{
	if( Scene != none && Scene.CanRender() )
	{
		Scene.Update( DeltaTime );	
	}
}

event PostRender( Canvas C )	
{
	if( Scene != none )
	{
		// DIRTY HACK: To get updates while the game is paused.
		if( Outer.WorldInfo.Pauser != none )
		{
			Scene.Update( `STimeSince( Scene.LastRenderTime ) );	
		}

		if( Scene.CanRender() )
		{
			Scene.Render( C );
		}
	}
}

function NotifyGameSessionEnded()
{
	if( Scene != none )
	{
		Scene.Free();
		Scene = none;
	}
}

final function PlayerController Player()
{
	return Outer;//GetLocalPlayer( 0 ).Actor;
}

defaultproperties
{
	OnReceivedNativeInputKey=OnKeyInput
	OnReceivedNativeInputChar=OnCharInput
}