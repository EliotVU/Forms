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
 * FWindow: Anything that needs a title and body should subclass this!
 * This class gives you a pre-defined Header and Body block along with a configurable title.
 * Windows can be dragged as well, using the Header block.
 * ======================================================== */
class FWindow extends FPage;

var(Window, Advanced) `{Automated} FContainer Header;
var(Window, Advanced) `{Automated} FLabel HeaderTitle;

var(Window, Advanced) `{Automated} FContainer Body;

var(Window, Usage) bool bDraggable;
var(Window, Usage) bool bClampPosition;

var transient IntPoint DragMPosition;
var transient Vector2D DragCPosition;

function Free()
{
	super.Free();
	Header = none;
	HeaderTitle = none;
	Body = none;
}

protected function InitializeComponent()
{
	local FComponent comp;

	super.InitializeComponent();

	Body = FContainer(CreateComponent( Body.Class,, Body ));
	Body.Components = Components;
	foreach Components( comp )
	{
		comp.Parent = Body;
	}
	Components.Length = 0;
	AddComponent( Body );

	Header = FContainer(CreateComponent( Header.Class,, Header ));
	AddComponent( Header );

	HeaderTitle = FLabel(CreateComponent( HeaderTitle.Class, Header, HeaderTitle ));
	if( bDraggable )
	{
		HeaderTitle.OnMouseButtonPressed = BeginDragEvent;
		HeaderTitle.OnMouseButtonRelease = EndDragEvent;
	}
	Header.AddComponent( HeaderTitle );
}

protected function RenderComponent( Canvas C )
{
	RenderBackground( C, GetStateColor() );
	if( HasFocus() )
	{
		C.DrawColor = Style.FocusColor;
		C.SetPos( PosX, C.CurY );
		C.DrawBox( SizeX, SizeY );
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
	
	if( bClampPosition && RelativeSize.X <= 1.0 && RelativeSize.Y <= 1.0 )
	{
		SetPos( FClamp( newX, 0.0, 1.0-RelativeSize.X ), FClamp( newY, 0.0, 1.0-RelativeSize.Y ) );
	}
	else
	{
		SetPos( newX, newY );	
	}
	DragMPosition = scene.MousePosition;
}

function EndDragEvent( FComponent sender, optional bool bRight )
{
	HeaderTitle.OnMouseMove = none;
}

defaultproperties
{
	bDraggable=true
	bClampPosition=true

	begin object name=oHeader class=FContainer
		RelativePosition=(X=0.0,Y=0.0)
		RelativeSize=(X=1.0,Y=32.0)
		// Counter the padding from FWindow
		Margin=(X=-8,W=-8,Y=-8,Z=-8)

		begin object name=oHeaderTitle class=FLabel
			Margin=(X=8,W=8,Y=4,Z=4)
			RelativePosition=(X=0.0,Y=0.0)
			RelativeSize=(X=1.0,Y=1.0)
			Text="Window Title"
			StyleNames.Add(WindowHeader)

			bEnableCollision=true
			bEnableClick=true
			bEnabled=true
		end object
	end object
	Header=oHeader
	HeaderTitle=oHeader.oHeaderTitle
	
	begin object name=oBody class=FContainer
		Margin=(Y=16.0,Z=32.0)
		RelativePosition=(X=0.0,Y=0.0)
		RelativeSize=(X=1.0,Y=1.0)

		// Actual components!
	end object
	Body=oBody
}