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
class FScene extends FComponent;

/** Add objects to this pool that have to be free'd on level change! :TODO: */
var protectedwrite array<FObject> ObjectsPool;

// First item = Top page/window.
// Last item = lowest page/window.
var(Scene, Advanced) protectedwrite editinline array<FPage> Pages;

var protectedwrite transient FComponent SelectedComponent;
var protectedwrite transient FComponent LastSelectedComponent;

var protectedwrite transient FComponent HoveredComponent;
var protectedwrite transient FComponent LastHoveredComponent;

var protectedwrite transient FComponent ActiveComponent;

/** Whether to pause the game when the scene is visible. */
var(Scene) bool														bPausedWhileVisible;

// DEPRECATED!
var(Scene, Display) deprecated bool									bConsiderAspectRatio;

var(Scene, Display) bool											bRenderCursor;
var(Scene, Display) const globalconfig TextureCoordinates			CursorPointCoords;
var(Scene, Display) const globalconfig TextureCoordinates			CursorTouchCoords;
var(Scene, Display) const globalconfig string						CursorsImageName;
var(Scene, Display) Texture2D										CursorsImage;
var(Scene, Display) const globalconfig float						CursorScaling;
var(Scene, Interaction) deprecated globalconfig float				MouseSensitivity;

var(Scene, Sound) globalconfig string								ClickSoundName;
var(Scene, Sound) globalconfig string								HoverSoundName;
var SoundCue														ClickSound;
var SoundCue														HoverSound;

var transient IntPoint MousePosition;
var transient IntPoint LastMousePosition;
var transient Vector2D Size;
var transient Vector2D Ratio;

var protectedwrite transient float RenderDeltaTime;
var privatewrite transient float LastRenderTime;

var(Scene, Advanced) PostProcessChain MenuPostProcessChain;
var protected int MenuPostProcessChainIndex;

var transient float LastClickTime;
var transient IntPoint LastClickPosition;
var transient Rotator LastPlayerRotation;

var transient bool bCtrl, bAlt, bShift;
`if( `isdefined( DEBUG ) )
	var(Scene, Debug) transient bool bRenderRectangles;
`endif

delegate OnPageRemoved( FPage sender );
delegate OnPageAdded( FPage sender );

function Initialize( FController c )
{
	local FPage page;

	LoadConfigurations();

	super.Initialize( c );
	foreach Pages( page )
	{
		page.Parent = self;
		page.Initialize( c );
	} 	

	LocalPlayer(C.Player().Player).ViewportClient.GetViewportSize( Size );
}

protected function LoadConfigurations()
{
	if( ClickSoundName != "" )
	{
		ClickSound = SoundCue(DynamicLoadObject( ClickSoundName, class'SoundCue', true ));
	}

	if( HoverSoundName != "" )
	{
		HoverSound = SoundCue(DynamicLoadObject( HoverSoundName, class'SoundCue', true ));
	}

	if( CursorsImageName != "" )
	{
		CursorsImage = Texture2D(DynamicLoadObject( CursorsImageName, class'Texture2D', true ));
	}
}

function Update( float DeltaTime )
{
	local FPage page;
	local Vector2D vector2DMP;

	// Lock the rotation so the player does not change its rotation when the mouse moves!
	Controller.Player().SetRotation( LastPlayerRotation );

	if( bRenderCursor )
	{
		LastMousePosition = MousePosition;
		vector2DMP = LocalPlayer(Controller.Outer.Player).ViewportClient.GetMousePosition();
		MousePosition.X = vector2DMP.X;
		MousePosition.Y = vector2DMP.Y;
		if( MousePosition != LastMousePosition && OnMouseMove != none )
		{
			OnMouseMove( self, DeltaTime );
			if( ActiveComponent != none && ActiveComponent.OnMouseMove != none )
			{
				ActiveComponent.OnMouseMove( self, DeltaTime );
			}
		}
	}

	super.Update( DeltaTime );
	foreach Pages( page )
	{
		page.Update( DeltaTime );
	} 
}

protected function MouseMove( FScene scene, float DeltaTime )
{
	local FPage page;
	local bool bCollided;

	foreach Pages( page )
	{
		if( page.CanRender() && !bCollided && page.CanInteract()
			&& page.IsHover( MousePosition, HoveredComponent ) )
		{
			if( (HoveredComponent != none && HoveredComponent.bSupportHovering) )
			{
				bCollided = true;
				if( LastHoveredComponent != HoveredComponent )
				{
					PlayHoverSound();

					HoveredComponent.OnHover( HoveredComponent );
					HoveredComponent.InteractionState = HoveredComponent.InteractionState | ES_Hover;
					HoveredComponent.LastHoveredTime = `STime;
					if( LastHoveredComponent != none )
					{
						LastHoveredComponent.LastUnhoveredTime = `STime; 
						LastHoveredComponent.OnUnHover( LastHoveredComponent );
						LastHoveredComponent.InteractionState = LastHoveredComponent.InteractionState & ~ES_Hover;
					}
					LastHoveredComponent = HoveredComponent;
				}
			}
			break;
		}
	}	

	if( !bCollided )
	{
		if( LastHoveredComponent != none )
		{
			LastHoveredComponent.LastUnhoveredTime = `STime; 
			LastHoveredComponent.OnUnHover( LastHoveredComponent );
			LastHoveredComponent.InteractionState = LastHoveredComponent.InteractionState & ~ES_Hover;
			LastHoveredComponent = none;	
		}
		HoveredComponent = none;
	}
}

function Render( Canvas C )
{
	local int i;

	// Resolution has been changed!
	if( C.SizeX != Size.X )
	{
		Size.X = C.SizeX;
		Size.Y = C.SizeY;
	}

	C.Reset();
	RenderDeltaTime = `STimeSince( LastRenderTime );
	//UpdateSceneRatio();
	super.Render( C );
	for( i = Pages.Length - 1; i >= 0; -- i )
	{
		if( Pages[i].CanRender() )
		{
			Pages[i].Render( C );
		}
	}
	C.Reset();

	`if( `isdefined( DEBUG ) )
		C.SetPos( 0, 0 );
		C.DrawColor = class'HUD'.default.WhiteColor;
		C.DrawText( "MP:" $ MousePosition.X $ "," $ MousePosition.Y, true );
		C.DrawText( "HC:" $ HoveredComponent, true );
		C.DrawText( "SC:" $ SelectedComponent, true );
		if( HoveredComponent != none )
		{
			C.DrawText( "P-C:" $ HoveredComponent.Parent @ HoveredComponent.Controller, true );
		}
	`endif

	if( bRenderCursor )
	{
		RenderCursor( C );
	}
	LastRenderTime = `STime;
}

protected function RenderCursor( Canvas C )
{
	C.SetPos( MousePosition.X, MousePosition.Y );
	C.DrawColor = class'HUD'.default.WhiteColor;
	if( hoveredComponent != none && hoveredComponent.bSupportSelection )
	{
		C.DrawTile( CursorsImage, CursorTouchCoords.UL * CursorScaling, CursorTouchCoords.VL * CursorScaling, CursorTouchCoords.U, CursorTouchCoords.V, CursorTouchCoords.UL, CursorTouchCoords.VL );
	} 
	else
	{
		C.DrawTile( CursorsImage, CursorPointCoords.UL * CursorScaling, CursorPointCoords.VL * CursorScaling, CursorPointCoords.U, CursorPointCoords.V, CursorPointCoords.UL, CursorPointCoords.VL );
	}	
}

function Free()
{
	local FPage page;

	// To make sure we remove postprocess and undo pause.
	SetVisible( false );
	foreach Pages( page )
	{
		page.Free();
	} 
	Pages.Length = 0;
	MenuPostProcessChain = none;
	super.Free();
}

/*function UpdateSceneRatio()
{
	if( bConsiderAspectRatio ^^ bRenderRectangles )
	{
		if( true )	// TODO: Proper detection
		{
			Ratio.X = Size.X / 1280.f;
			Ratio.Y = Size.Y / 720.f;
		}
		else
		{
			Ratio.X = Size.X / 1024.f;
			Ratio.Y = Size.Y / 768.f;
		}
	}
	else
	{
		Ratio.X = 1.0;
		Ratio.Y = 1.0;
	}

	//SetSize( 
		//Size.X * Ratio.X / Size.X,
		//Size.Y * Ratio.Y / Size.Y
	//);

	//SetPos( 
		//((Size.X - GetWidth()) * Ratio.X * 0.5) / Size.X, 
		//((Size.Y - GetHeight()) * Ratio.Y * 0.5) / Size.Y
	//);
}*/

function float GetHeight()
{
	return Size.Y * RelativeSize.Y;
}

function float GetWidth()
{
	return Size.X * RelativeSize.X;
}

function float GetTop()
{
	return GetHeight() * RelativePosition.Y;
}

function float GetLeft()
{
	return GetWidth() * RelativePosition.X;
}

final simulated function FPage OpenPage( class<FPage> pageClass )
{
	local FPage page;

	page = new( self ) pageClass;
	Assert( page != none );

	page.SetVisible( true );
	AddPage( page );
	return page;
}

final function AddPage( FPage page )
{
	if( Pages.Find( page ) != -1 )
		return;

	Player().ClientMessage( "AddedPage:" @ page );

	page.Parent = self;
	if( !page.bInitialized )
	{
		page.Initialize( Controller );
	}
	page.Opened();
	Pages.InsertItem( 0, page );

	OnPageAdded( page );
}

// TODO: Handle free'ing
final simulated function ClosePage( optional bool bCloseAll )
{
	if( Pages.Length == 0 )
	{
		return;
	}
	
	if( bCloseAll )
	{
		EmptyPages();
	}
	else
	{
		RemovePage( Pages[0] );
	}
}

final function RemovePage( FPage page )
{	
	Player().ClientMessage( "RemovedPage:" @ page );

	page.Closed();
	page.Parent = none;
	Pages.RemoveItem( page );
	OnPageRemoved( page );
}

final function EmptyPages()
{
	local FPage page;

	foreach Pages( page )
	{
		page.Closed();
		page.Parent = none;
	}
	Pages.Length = 0;
	OnPageRemoved( none );
}

protected function PageAdded( FPage sender )
{
	SetVisible( true );
}

protected function PageRemoved( FPage sender )
{
	if( Pages.Length == 0 )
	{
		SetVisible( false );
	}
}

function bool CanUnpause()
{
	return !bVisible;
}

function OnVisibleChanged( FComponent sender )
{
	if( bVisible )
	{
		Controller.Player().PlayerInput.ResetInput();
		if( MenuPostProcessChainIndex == -1 && MenuPostProcessChain != none )
		{
			MenuPostProcessChainIndex = LocalPlayer(Controller.Player().Player).InsertPostProcessingChain( MenuPostProcessChain, 0, false ) ? 0 : -1;
		}

		if( bPausedWhileVisible )
			Controller.Player().SetPause( true, CanUnpause );

		LastPlayerRotation = Controller.Player().Rotation;
	}
	else
	{
		if( MenuPostProcessChainIndex != -1 )
		{
			LocalPlayer(Controller.Player().Player).RemovePostProcessingChain( MenuPostProcessChainIndex );
			MenuPostProcessChainIndex = -1;
		}

		if( bPausedWhileVisible )
			Controller.Player().SetPause( false, CanUnpause );
	}
}

function bool KeyInput( name Key, EInputEvent EventType )
{
	local FComponent inputComponent;

	if( EventType == IE_Pressed )
	{
		switch( Key )
		{
			case 'LeftMouseButton':
				if( HoveredComponent != none )
				{
					HoveredComponent.Active();
					HoveredComponent.OnMouseButtonPressed( HoveredComponent );

					ActiveComponent = HoveredComponent;
				}
				break;

			case 'RightMouseButton':
				if( HoveredComponent != none )
				{
					HoveredComponent.Active();
					HoveredComponent.OnMouseButtonPressed( HoveredComponent, true );

					ActiveComponent = HoveredComponent;
				}
				break;

			case 'LeftControl':
			case 'RightControl':
				bCtrl = true;
				break;

			case 'LeftAlt':
			case 'RightAlt':
				bAlt = true;
				break;

			case 'LeftShift':
			case 'RightShift':
				bShift = true;
				`if( `isdefined( DEBUG ) )
					bRenderRectangles = true;
				`endif
				break;
		}
	}
	else if( EventType == IE_Released )
	{
		switch( Key )
		{
			case 'LeftMouseButton':
				if( ActiveComponent != none )
				{
					inputComponent = ActiveComponent;	
					ActiveComponent = none;
				}
				else inputComponent = HoveredComponent;

				if( inputComponent != none )
				{
					if( inputComponent == HoveredComponent )
					{
						`if( `isdefined( DEBUG ) )
							if( bCtrl )
							{
								Controller.Player().ConsoleCommand( "editobject name=" $ inputComponent.Name );
								break;
							}
						`endif

						if( `STimeSince( LastClickTime ) <= Controller.Player().PlayerInput.DoubleClickTime )
						{
							inputComponent.OnDoubleClick( inputComponent );
						}
						else
						{
							inputComponent.OnClick( inputComponent );
						}
					}
					inputComponent.UnActive();
					inputComponent.OnMouseButtonRelease( inputComponent );
					LastClickTime = `STime;
					LastClickPosition = MousePosition;

					if( !inputComponent.bSupportSelection )
					{
						break;
					}
				}
				if( inputComponent == HoveredComponent )
					OnClick( inputComponent );
				break;

			case 'RightMouseButton':
				if( ActiveComponent != none )
				{
					inputComponent = ActiveComponent;	
					ActiveComponent = none;
				}
				else inputComponent = HoveredComponent;

				if( inputComponent == HoveredComponent )
					OnClick( inputComponent, true );

				LastClickPosition = MousePosition;

				if( inputComponent != none )
				{
					inputComponent.UnActive();
					inputComponent.OnMouseButtonRelease( inputComponent, true );
				}
				break;

			case 'MouseScrollUp':
				if( HoveredComponent != none )
				{
					HoveredComponent.OnMouseWheelInput( HoveredComponent, true );
				}
				break;

			case 'MouseScrollDown':
				if( HoveredComponent != none )
				{
					HoveredComponent.OnMouseWheelInput( HoveredComponent, false );
				}
				break;	
				
			case 'LeftControl':
			case 'RightControl':
				bCtrl = false;
				break;

			case 'LeftAlt':
			case 'RightAlt':
				bAlt = false;
				break;

			case 'LeftShift':
			case 'RightShift':
				bShift = false;
				`if( `isdefined( DEBUG ) )
					bRenderRectangles = false;
				`endif
				break;	
		}
	}

	if( SelectedComponent != none && SelectedComponent != self )
	{
		if( EventType == IE_Released )
		{
			switch( Key )
			{
				case 'Space':
				case 'Enter':
					SelectedComponent.OnClick( SelectedComponent );
					break;
			}
		}

		if( SelectedComponent.OnKeyInput != none )
		{
			return SelectedComponent.OnKeyInput( Key, EventType );
		}
	}
	return true;
}

function bool CharInput( string Unicode )
{
	if( SelectedComponent != none && SelectedComponent != self )
	{
		if( SelectedComponent.OnCharInput != none )
		{
			return SelectedComponent.OnCharInput( Unicode );
		}
	}	
	return false;
}

function Click( FComponent sender, optional bool bRight )
{
	SelectedComponent = sender;
	if( SelectedComponent != none )
	{
		PlayClickSound();
		SelectedComponent.Focus();
		if( FWindow(SelectedComponent) != none )
		{
			RemovePage( FWindow(SelectedComponent) );
			AddPage( FWindow(SelectedComponent) );
		}
	}

	if( LastSelectedComponent != none && LastSelectedComponent != SelectedComponent )
	{
		LastSelectedComponent.UnFocus();
	}
	LastSelectedComponent = SelectedComponent;
}

function Focus()
{
	OnFocus( self );
}

function UnFocus()
{
	SelectedComponent = none;
	OnUnFocus( self );
}

final function PlayHoverSound()
{
	Controller.Player().ClientPlaySound( HoverSound );
}

final function PlayClickSound()
{
	Controller.Player().ClientPlaySound( ClickSound );
}

defaultproperties
{
	RelativePosition=(X=0.0,Y=0.0)
	RelativeSize=(X=1.0,Y=1.0)

	OnKeyInput=KeyInput
	OnCharInput=CharInput
	OnClick=Click
	OnMouseMove=MouseMove
	OnPageAdded=PageAdded
	OnPageRemoved=PageRemoved

	bVisible=false
	bRenderCursor=true
	bConsiderAspectRatio=false
	bPausedWhileVisible=false

	MenuPostProcessChainIndex=-1
}