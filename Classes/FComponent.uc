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
class FComponent extends FObject
	config(Forms)
	perobjectconfig
	perobjectlocalized
	editinlinenew
	abstract;

/** Cannot be used(same for other objects) from delegate events if that delegate is initialized via the DefaultProperties block! */
var transient FController Controller;

/** Cannot be used(same for other objects) from delegate events if that delegate is initialized via the DefaultProperties block! */
var(Component, Advanced) FComponent Parent;

var(Component, Function) protectedwrite bool bVisible;
var(Component, Function) protectedwrite bool bEnabled;
var(Component, Function) const bool bSupportSelection;
var(Component, Function) const bool bSupportHovering;

/** The relative position of this component, relative starting from the parent's position, in percentage! */
var(Component, Positioning) privatewrite Vector2D RelativePosition;
var(Component, Positioning) privatewrite Vector2D RelativeSize;
var(Component, Positioning) privatewrite Vector4 Margin;
var(Component, Positioning) privatewrite Vector4 Padding;

struct Boundary
{
	var float Min, Max;
	var bool bEnabled;
};
var(Component, Positioning) privatewrite Boundary WidthBoundary;
var(Component, Positioning) privatewrite Boundary HeightBoundary;

/** The width of the component will be set to that of height in pixels. */
var(Component, Positioning) bool bJustify;

/** The side(of RelativePosition) that the component will stick to. */
var(Component, Positioning) enum EHorizontalDock
{
	HD_Left,
	HD_Right
} HorizontalDock;

/** How to handle positioning for this component. */
var(Component, Positioning) enum EPositioning
{
	/** Position Relative: Default. */
	P_Relative,
	/** Position Fixed: Scrolling will not move this component. */
	P_Fixed,
} Positioning;

/** The style for this component to use. */
var(Component, Display) privatewrite editinline FStyle Style;

/** Whether to clip anything going out of this component region. */
var(Component, Display) bool bClipComponent;

const ES_None			= 0x00;
const ES_Hover			= 0x01;
const ES_Selected		= 0x02;
const ES_Active			= 0x04;

/** The current interaction state, e.g. Hover, Selected or Active. */
var transient byte InteractionState;
var protectedwrite transient float TopY, LeftX, WidthX, HeightY;
var transient Vector2D OriginOffset;
var transient bool bInitialized;

/** Useful todo animations when hovering/unhovering. RealTimeSeconds! */
var transient float LastHoveredTime, LastUnhoveredTime;
var transient float LastFocusedTime, LastUnfocusedTime;
var transient float LastActiveTime, LastUnactiveTime;

// KB/M EVENTS - Only called if hovered or focused!
delegate OnClick( FComponent sender, optional bool bRight );
delegate OnDoubleClick( FComponent sender, optional bool bRight );
delegate OnMouseButtonPressed( FComponent sender, optional bool bRight );
delegate OnMouseButtonRelease( FComponent sender, optional bool bRight );
delegate OnMouseWheelInput( FComponent sender, optional bool bUp );
delegate OnMouseMove( FScene scene, float DeltaTime );
delegate bool OnKeyInput( name Key, EInputEvent EventType );
delegate bool OnCharInput( string Unicode );

// STATE
delegate OnVisibleChanged( FComponent sender );
delegate OnEnabledChanged( FComponent sender );

// DRAWING
delegate OnRender( FComponent sender, Canvas C );

// UPDATING
/**
 * Called when created and/or every time when added to a Components list.
 */
delegate OnInitialize( FComponent sender );
delegate OnUpdate( FComponent sender, float DeltaTime );

// INTERACTION
delegate OnHover( FComponent sender );
delegate OnUnHover( FComponent sender );
delegate OnFocus( FComponent sender );
delegate OnUnFocus( FComponent sender );
delegate OnActive( FComponent sender );
delegate OnUnActive( FComponent sender );

/** Initializes this object. */
function Initialize( FController c )
{
	Controller = c;
	`Log( Name $ "Initialize" );

	if( bInitialized )
		return;
	
	Controller.Scene.AddToPool( self );
	OnVisibleChanged( self );
	OnEnabledChanged( self );

	InitializeComponent();
	bInitialized = true;
	OnInitialize( self );
	`if( `isdefined( DEBUG ) )
		SaveConfig();
	`endif

	if( Style != none )
	{
		SetStyle( Style );
	}
}

/** Initializes this component. Override this to add other components or objects to this component. */
function InitializeComponent();

/** Called every tick if Enabled and Visible. */
function Update( float DeltaTime )
{
	//...
	OnUpdate( self, DeltaTime );
}

/** Re-calculate all positions and sizes. */
function Refresh()
{
	TopY = GetTop();
	LeftX = GetLeft();
	WidthX = GetWidth();
	HeightY = GetHeight();
}

/** Render this object. Override RenderComponent to draw component specific visuals. */
function Render( Canvas C )
{
	//local Vector2D relativeOrigin;

	Refresh();
	/*if( Parent != none && Positioning < P_Fixed )
	{
		relativeOrigin = Parent.OriginOffset;
	}

	C.SetOrigin( relativeOrigin.X, relativeOrigin.Y );*/

	if( bClipComponent )
	{
		C.SetOrigin( C.OrgX + LeftX, C.OrgY + TopY );
		C.SetClip( WidthX, HeightY );
		//C.SetClip( WidthX + relativeOrigin.X, HeightY + relativeOrigin.X );

		// Foolish hack :P Sets new start position for the draw functions without hardcoding 0 there!
		TopY = 0;
		LeftX = 0;
	}

	C.SetPos( LeftX, TopY );
	RenderStyle( C );
	RenderComponent( C );
	OnRender( self, C );

	`if( `isdefined( DEBUG ) )
		if( Controller.Scene.bRenderRectangles )
		{
			C.SetPos( 0, 0 );	
			C.DrawColor = class'HUD'.default.GreenColor;
			if( !IsHovered() )
				C.DrawColor.A = 64;
			C.DrawBox( C.ClipX, C.ClipY );

			C.SetPos( LeftX, TopY );	
			C.DrawColor = class'HUD'.default.RedColor;
			if( !IsHovered() )
				C.DrawColor.A = 64;
			C.DrawBox( WidthX, HeightY );
		}
	`endif

	C.SetOrigin( 0, 0 );
	if( bClipComponent )
	{
		C.SetClip( C.SizeX, C.SizeY );
	}
}

/** Draw all assigned elements from the Style object, these elements could be borders or backgrounds etcetera. */
function RenderStyle( Canvas C )
{
	if( Style == none )
	{
		`Log( Name @ "has no Style reference!" );
		return;
	}
	Style.Render( C );
	Style.RenderElements( C, self );
}

/** Override this to render anything specific to a unique component. */
function RenderComponent( Canvas C );

/** 
 *	Override this to clear any Object/Actor references! 
 *	Do NOT call Free on other objects here!
 */
function Free()
{
	`Log( Name $ "Free" );
	Controller = none;
	Parent = none;
	Style = none;

	bInitialized = false;	// So it may be restored later if desired.
}

final function SetStyle( FStyle newStyle )
{
	Style = newStyle;
	Style.Initialize();
	Controller.Scene.AddToPool( Style );
}

final function SetPos( float X, float Y )
{
	RelativePosition.X = X;
	RelativePosition.Y = Y;
}

final function SetSize( float X, float Y )
{
	RelativeSize.X = X;
	RelativeSize.Y = Y;
}

final function SetMargin( float leftPixels, float topPixels, float rightPixels, float bottomPixels )
{
	Margin.X = leftPixels;
	Margin.Y = topPixels;
	Margin.W = rightPixels;
	Margin.Z = bottomPixels;
}

final function SetPadding( float leftPixels, float topPixels, float rightPixels, float bottomPixels )
{
	Padding.X = leftPixels;
	Padding.Y = topPixels;
	Padding.W = rightPixels;
	Padding.Z = bottomPixels;
}

/** Calculates the screen height for this component. */
function float GetHeight()
{
	local float h;
	
	h = (RelativeSize.Y > 1.0 
		? Parent.GetHeight() + RelativeSize.Y 
		: Parent.GetHeight() * RelativeSize.Y) - (Margin.Y << 1) - (Parent.Padding.Y << 1);
		
	return HeightBoundary.bEnabled ? FClamp( h, HeightBoundary.Min, HeightBoundary.Max ) : h;
}

/** Retrieves the cached Height that was calculated the last time this component was rendered. Recommend for use within Tick functions. */
final function float GetCachedHeight()
{
	return HeightY;
}

/** Calculates the screen width for this component. */
function float GetWidth()
{
	local float w;
	
	w = (bJustify 
		? GetHeight() 
		: RelativeSize.X > 1.0 
			? Parent.GetWidth() + RelativeSize.X 
			: Parent.GetWidth() * RelativeSize.X) - (Margin.X << 1) - (Parent.Padding.X << 1);
	
	return WidthBoundary.bEnabled ? FClamp( w, WidthBoundary.Min, WidthBoundary.Max ) : w;
}

/** Retrieves the cached Width that was calculated the last time this component was rendered. Recommend for use within Tick functions. */
final function float GetCachedWidth()
{
	return WidthX;
}

/** Calculates the top screen position for this component. */
function float GetTop()
{
	return ((Parent.GetTop() + Parent.GetHeight() * RelativePosition.Y) + Margin.Z + Parent.Padding.Z) 
		+ ((Positioning < EPositioning.P_Fixed) ? Parent.OriginOffset.Y : 0.0f);
}

/** Retrieves the cached Top that was calculated the last time this component was rendered. Recommend for use within Tick functions. */
final function float GetCachedTop()
{
	return TopY;
}

/** Calculates the left screen position for this component. */
function float GetLeft()
{
	return ((HorizontalDock == HD_Right 
		? (Parent.GetLeft() + Parent.GetWidth() * RelativePosition.X) - GetWidth() 
		: (Parent.GetLeft() + Parent.GetWidth() * RelativePosition.X)) + Margin.W + Parent.Padding.W) 
			+ ((Positioning < EPositioning.P_Fixed) ? Parent.OriginOffset.X : 0.0f);
}

/** Retrieves the cached Left that was calculated the last time this component was rendered. Recommend for use within Tick functions. */
final function float GetCachedLeft()
{
	return LeftX;
}

/**
 * Determine whether this component should receive Render calls.
 */
function bool CanRender()
{
	return bVisible;
}

function bool CanInteract()
{
	return bEnabled && CanRender();
}

function SetVisible( bool v )
{
	bVisible = v;
	OnVisibleChanged( self );
}

function SetEnabled( bool e )
{
	bEnabled = e;
	OnEnabledChanged( self );
}

function bool IsHover( IntPoint mousePosition, out FComponent hoveredComponent )
{
	/*if( Parent != none && Positioning < P_Fixed )
	{
		mousePosition.X -= Parent.OriginOffset.X;
		mousePosition.Y -= Parent.OriginOffset.Y;
	}*/
	if( Collides( mousePosition ) )
	{
		hoveredComponent = self;
		return true;
	}
	return false;
}

final function bool Collides( IntPoint mousePosition )
{
	return (mousePosition.X >= GetLeft()) 
			   && (mousePosition.X <= GetLeft() + GetWidth())
			   && (mousePosition.Y >= GetTop()) 
			   && (mousePosition.Y <= GetTop() + GetHeight());
}

/** Notify that the component is selected! */
function Focus()
{
	Scene().Focus();

	LastFocusedTime = `STime;
	InteractionState = InteractionState | ES_Selected;
	OnFocus( self );
}

/** Notify that the component is no longer selected! */
function UnFocus()
{
	LastUnfocusedTime = `STime;
	InteractionState = InteractionState & ~ES_Selected;
	OnUnFocus( self );
}

function Active()
{
	LastActiveTime = `STime;
	InteractionState = InteractionState | ES_Active;
	OnActive( self );
}

function UnActive()
{
	LastUnactiveTime = `STime;
	InteractionState = InteractionState & ~ES_Active;
	OnUnActive( self );
}

//=====================================================
// HELPER METHODS

final function FScene Scene()
{
	return Controller.Scene;
}

final function PlayerController Player()
{
	return Controller.Player();
}

final function string ConsoleCommand( string command )
{
	return Controller.Outer.ConsoleCommand( command );
}

final function RenderBackground( Canvas C, Color drawColor = Style.ImageColor )
{
	local float UL, VL;
	
	if( Style.Image != none )
	{
		C.SetPos( LeftX, TopY );
		C.DrawColor = drawColor;
		UL = (Style.ImageCoords.UL <= 1.0) ? float(Style.Image.SizeX) : Style.ImageCoords.UL;
		VL = (Style.ImageCoords.VL <= 1.0) ? float(Style.Image.SizeY) : Style.ImageCoords.VL;

		C.DrawTileStretched( Style.Image, WidthX, HeightY, 
			Style.ImageCoords.U, Style.ImageCoords.V, 
			UL, VL 
		);
	}
}

final function bool IsHovered()
{
	return (InteractionState & ES_Hover) != ES_None;
}

final function bool HasFocus()
{
	return (InteractionState & ES_Selected) != ES_None;
}

function bool IsActive()
{
	return (InteractionState & ES_Active) != ES_None;
}

/** Returns a color based on this component's state such as hover, focus, selected or disabled! */
final function Color GetStateColor( optional Color defaultColor = Style.ImageColor )
{
	if( !CanInteract() )
	{
		return Style.DisabledColor;
	}
	else if( IsActive() )
	{
		return Style.ActiveColor;	
	}
	else if( IsHovered() )
	{
		return Style.HoverColor;
	}
	else if( HasFocus() )
	{
		return Style.FocusColor;
	}
	return defaultColor;
}

/** Create a new instance of @componentClass. 
 *	Used to create components at run-time.
 */
final function FComponent CreateComponent( class<FComponent> componentClass, Object componentOuter )
{
	return new(componentOuter) componentClass;
}

defaultproperties
{
	bVisible=true
	bEnabled=true
	bSupportSelection=true
	bSupportHovering=true
	bClipComponent=false

	begin object name=oStyle class=FStyle
	end object
	Style=oStyle

	HorizontalDock=HD_Left

	RelativePosition=(X=0.0,Y=0.0)
	Margin=(X=2,Y=2,Z=2,W=2)
	//Padding=(X=2,Y=2,Z=2,W=2)
}