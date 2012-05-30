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
// FWindow: Anything that needs a title and body should subclass this!
// This class gives you a pre-defined Header and Body block along with a configurable title.
// Windows can be dragged as well, using the Header block.
//=============================================================================
class FWindow extends FPage;

var(Component, Advanced) `{Automated} FContainer Header;
var(Component, Advanced) `{Automated} FImage HeaderBackground;
var(Component, Advanced) `{Automated} FLabel HeaderTitle;

var(Component, Advanced) `{Automated} FContainer Body;

var transient IntPoint DragMPosition;
var transient Vector2D DragCPosition;
var bool bDraggable;

function Free()
{
	super.Free();
	Header = none;
	HeaderBackground = none;
	HeaderTitle = none;
	Body = none;
}

function InitializeComponent()
{
	local FComponent comp;

	super.InitializeComponent();
	
	Header = FContainer(CreateComponent( class'FContainer', self, Header ));
		HeaderBackground = FImage(CreateComponent( class'FImage', self, HeaderBackground ));
		Header.AddComponent( HeaderBackground );
	
		HeaderTitle = FLabel(CreateComponent( class'FLabel', self, HeaderTitle ));
		if( bDraggable )
		{
			HeaderTitle.OnMouseButtonPressed = BeginDragEvent;
			HeaderTitle.OnMouseButtonRelease = EndDragEvent;
		}
		Header.AddComponent( HeaderTitle );

	Body = FContainer(CreateComponent( class'FContainer', self, Body ));
	Body.Components = Components;
	foreach Components( comp )
	{
		comp.Parent = Body;
	}
	Components.Length = 0;

	AddComponent( Header );
	AddComponent( Body );
}

function RenderComponent( Canvas C )
{
	RenderBackground( C, GetStateColor() );
	if( HasFocus() )
	{
		C.DrawColor = Style.FocusColor;
		C.SetPos( LeftX, C.CurY );
		C.DrawBox( WidthX, HeightY );
	}
	super(FComponent).RenderComponent( C );
}

function BeginDragEvent( FComponent sender, optional bool bRight )
{
	DragMPosition = Scene().MousePosition;
	DragCPosition = RelativePosition;
	HeaderTitle.OnMouseMove = DraggingEvent;
}

function DraggingEvent( FScene scene, float DeltaTime )
{
	local float newX, newY;

	newX = MoveLeft( float(scene.MousePosition.X - DragMPosition.X) );
	newY = MoveTop( float(scene.MousePosition.Y - DragMPosition.Y) );
	SetPos( FClamp( newX, 0.0, 1.0-RelativeSize.X ), FClamp( newY, 0.0, 1.0-RelativeSize.Y ) );

	DragMPosition = scene.MousePosition;
}

function EndDragEvent( FComponent sender, optional bool bRight )
{
	HeaderTitle.OnMouseMove = none;
}

defaultproperties
{
	bSupportSelection=true
	bDraggable=true

	begin object name=oHeader class=FContainer
		RelativePosition=(X=0.0,Y=0.0)
		RelativeSize=(X=1.0,Y=32.0)
		// Counter the padding from FWindow
		Margin=(X=-10,W=-10,Y=-10,Z=-10)
		begin object name=oHeaderBackground class=FImage
			RelativePosition=(X=0.0,Y=0.0)
			RelativeSize=(X=1.0,Y=1.0)
			begin object name=oHeaderImage class=FStyle
				//Image=Texture2D'GameUI.Tiles.HeaderBackground'
				begin object name=oColor class=FElementGradient
					BeginColor=(R=60,G=60,B=60,A=255)
					EndColor=(R=14,G=14,B=15,A=255)
				end object
				Elements.Add(oColor)
			end object
			Style=oHeaderImage
			bEnabled=false	// Ensure it's disabled.
			bSupportHovering=false
		end object
			
		begin object name=oHeaderTitle class=FLabel
			Margin=(X=8,W=8,Y=4,Z=4)
			RelativePosition=(X=0.0,Y=0.0)
			RelativeSize=(X=1.0,Y=1.0)
			Text="Window Title"
			TextFont=MultiFont'UI_Fonts_Final.HUD.MF_Medium'
			bEnabled=true
			bSupportSelection=true
			bSupportHovering=true
		end object
		
	end object
		HeaderBackground=oHeader.oHeaderBackground
		HeaderTitle=oHeader.oHeaderTitle
	Header=oHeader
	
	begin object name=oBody class=FContainer
		Margin=(Y=32.0,Z=32.0)
		RelativePosition=(X=0.0,Y=0.0)
		RelativeSize=(X=1.0,Y=1.0)

		// Actual components!
	end object
	Body=oBody
}