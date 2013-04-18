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
 * FController: The Input processing, updating and drawing redirector for the 'FScene' class.
 * Within: We use within so we don't have to cast PlayerController on the @Outer reference!
 * ======================================================== */
class FController extends Interaction within UDKPlayerController implements(FIController)
	config(Forms);

/** Pointer to our FScene instance. All events are redirected to the Scene and processed by the Scene. */
var() privatewrite editinline FScene ScenePointer;

final function InitializeScene( optional class<FScene> sceneClass = class'FScene' )
{
	if( ScenePointer == none )
	{
		ScenePointer = new( none, "Forms" ) sceneClass;
		if( ScenePointer != none )
		{
			ScenePointer.InitializeScene( self );
		}
		else
		{
			assert( false );
		}
	}
}

final function bool OnKeyInput( int ControllerId, name Key, EInputEvent EventType, optional float AmountDepressed=1.f, optional bool bGamepad )
{
	if( ScenePointer == none )
		return false;

	if( ScenePointer.CanInteract() && ScenePointer.OnKeyInput( Key, EventType ) )
	{
		// HACK: Don't break "ShowMenu"
		return Key != 'Escape';
	}
	return false;
}

final function bool OnCharInput( int ControllerId, string Unicode )
{
	if( ScenePointer != none && ScenePointer.CanInteract() )
	{
		return ScenePointer.OnCharInput( Unicode );
	}	
	return false;
}

event Tick( float DeltaTime )
{
	if( ScenePointer != none && ScenePointer.CanRender() )
	{
		ScenePointer.Update( DeltaTime );	
	}
}

event PostRender( Canvas C )	
{
	if( ScenePointer != none )
	{
		// DIRTY HACK: To get updates while the game is paused.
		if( Outer.WorldInfo.Pauser != none )
		{
			ScenePointer.Update( `STimeSince( ScenePointer.LastRenderTime ) );	
		}

		if( ScenePointer.CanRender() )
		{
			ScenePointer.Render( C );
		}
	}
}

/*exec function ReloadStyle()
{
	local FObject obj;

	ScenePointer.Styles.Length = 0;
	foreach ScenePointer.ObjectsPool( obj )
	{
		if( FComponent(obj) != none )
		{
			FComponent(obj).ResetStyle();
		}
	}
}*/

function NotifyGameSessionEnded()
{
	`Log( "NotifyGameSessionEnded!",, 'Forms' );
	if( ScenePointer != none )
	{
		ScenePointer.Free();
		ScenePointer = none;
	}
}

final function PlayerController Player()
{
	return Outer;
}

final function FScene Scene()
{
	return ScenePointer;
}

defaultproperties
{
	OnReceivedNativeInputKey=OnKeyInput
	OnReceivedNativeInputChar=OnCharInput
}