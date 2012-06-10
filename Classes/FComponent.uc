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
	abstract
	forcescriptorder(true);

/** Cannot be used(same for other objects) from delegate events if that delegate is initialized via the DefaultProperties block! */
var transient editconst FIController Controller;

/** Cannot be used(same for other objects) from delegate events if that delegate is initialized via the DefaultProperties block! */
var(Component, Advanced) noclear editconst FComponent Parent;

/** Is this component visible? */
var(Component, Function) protectedwrite bool bVisible;

/** Is this component interactable? */
var(Component, Function) protectedwrite bool bEnabled;

var(Component, Function) const bool bSupportSelection;
var(Component, Function) const bool bSupportHovering;

/** The relative position of this component, relative starting from the parent's position, in percentage! */
var(Component, Positioning) privatewrite Vector2D RelativePosition;

/** The relative size of this component, relative starting from the parent's size, in percentage! */
var(Component, Positioning) privatewrite Vector2D RelativeSize;

/**
 *  X, W, Y, Z margin in pixels:
 *	X = Right	Margin
 *	W = Left	Margin
 *	Y = Bottom	Margin
 *	Z = Top		Margin
 */
var(Component, Positioning) privatewrite Vector4 Margin;

/**
 *  X, W, Y, Z padding in pixels:
 *	X = Right	Padding
 *	W = Left	Padding
 *	Y = Bottom	Padding
 *	Z = Top		Padding
 */
var(Component, Positioning) privatewrite Vector4 Padding;

struct Boundary
{
	var float Min, Max;
	var bool bEnabled;
};
/** Max/Min width for this component. */
var(Component, Positioning) Boundary WidthBoundary;

/** Max/Min height for this component. */
var(Component, Positioning) Boundary HeightBoundary;

/** The width of the component will be set to that of height in pixels. */
var(Component, Positioning) bool bJustify;

/** The X(of RelativePosition) that the component will stick to. */
var(Component, Positioning) enum EHorizontalDock
{
	/** Start drawing from RelativePosition X. */
	HD_Left,
	/** End drawing at RelativePosition X. */
	HD_Right
} HorizontalDock;

/** The Y(of RelativePosition) that the component will stick to. */
var(Component, Positioning) enum EVerticalDock
{
	/** Start drawing from RelativePosition Y. */
	VD_Top,
	/** End drawing at RelativePosition Y. */
	VD_Bottom
} VerticalDock;

/** How to handle positioning for this component. */
var(Component, Positioning) enum EPositioning
{
	/** Position Relative: Default. */
	P_Relative,
	/** Position Fixed: Scrolling will not move this component. */
	P_Fixed,
} Positioning;

/** The collision shape of this component. */
var(Component, Collision) enum ECollisionShape
{
	CS_Rectangle,
	CS_Circle
} CollisionShape;

/** The style for this component to use. */
var(Component, Display) privatewrite editinline FStyle Style;

/** Whether to clip anything going out of this component region. */
var(Component, Display) bool bClipComponent;

const ES_None			= 0x00;
const ES_Hover			= 0x01;
const ES_Selected		= 0x02;
const ES_Active			= 0x04;

/** The current interaction state, e.g. Hover, Selected or Active. */
var transient editconst byte InteractionState;

// This component's cached positions and size.
var protectedwrite transient editconst float TopY, LeftX, WidthX, HeightY;

// A dynamic position offset(Controlled by scrolling).
var transient Vector2D OriginOffset;

// This component has been initialized?
var transient editconst bool bInitialized;

/** Useful todo animations when hovering/unhovering. RealTimeSeconds! */
var transient editconst float LastHoveredTime, LastUnhoveredTime;
var transient editconst float LastFocusedTime, LastUnfocusedTime;
var transient editconst float LastActiveTime, LastUnactiveTime;
var transient editconst float LastStateChangeTime;
var transient editconst Color LastStateColor;

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
delegate OnPostRender( FComponent sender, Canvas C );

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
function Initialize( FIController c )
{
	Controller = c;
	//`Log( Name $ "Initialize",, 'FormsInit' );

	if( bInitialized )
		return;
		
	if( FMultiComponent(Parent) != none )
	{
		FMultiComponent(Parent).OnComponentInitialized( self );
	}
	
	Scene().AddToPool( self );
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
	// This re-calculates the position and size.
	Refresh();
	
	if( bClipComponent )
	{
		C.SetOrigin( C.OrgX + LeftX, C.OrgY + TopY );
		C.SetClip( WidthX, HeightY );

		// Foolish hack :P Sets new start position for the draw functions without hardcoding 0 there!
		TopY = 0;
		LeftX = 0;
		
		// SELF REMINDER: Use Pos? + Org? if the pos is independent of Origin.
	}

	if( Style != none )
	{
		Style.Render( C );
		Style.RenderFirstElements( C, self );
		
		C.SetPos( LeftX, TopY );
		RenderComponent( C );
		
		Style.RenderLastElements( C, self );
	}
	OnPostRender( self, C );

	`if( `isdefined( DEBUG ) )
		if( Scene().bRenderRectangles )
		{
			C.SetPos( 0, 0 );	
			C.DrawColor = class'HUD'.default.GreenColor;
			C.DrawColor.A = IsHovered() ? 200 : 64;
			C.DrawBox( C.ClipX, C.ClipY );

			C.SetPos( LeftX, TopY );	
			C.DrawColor = class'HUD'.default.RedColor;
			C.DrawColor.A = IsHovered() ? 200 : 64;
			C.DrawBox( WidthX, HeightY );
		}
	`endif

	if( bClipComponent )
	{
		C.SetClip( C.SizeX, C.SizeY );
		
		// Restore so that GetCachedLeft() can still function.
		TopY = C.OrgY;
		LeftX = C.OrgX;
	}
	C.SetOrigin( 0, 0 );
}

/** Override this to render anything specific to a unique component. */
protected function RenderComponent( Canvas C );

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
	if( newStyle == none )
		return;
		
	Style = newStyle;
	Style.Initialize();
	Scene().AddToPool( Style );
}

final function SetPos( const float X, const float Y )
{
	RelativePosition.X = X;
	RelativePosition.Y = Y;
}

final function SetSize( const float X, const float Y )
{
	RelativeSize.X = X;
	RelativeSize.Y = Y;
}

final function SetMargin( float leftPixels, float topPixels, float rightPixels, float bottomPixels )
{
	Margin.X = rightPixels;
	Margin.Y = bottomPixels;
	Margin.W = leftPixels;
	Margin.Z = topPixels;
}

final function SetPadding( float leftPixels, float topPixels, float rightPixels, float bottomPixels )
{
	Padding.X = rightPixels;
	Padding.Y = bottomPixels;
	Padding.W = leftPixels;
	Padding.Z = topPixels;
}

/** Calculates the screen height for this component. */
protected function float GetHeight()
{
	local float h;
	
	h = (RelativeSize.Y > 1.0 
		? RelativeSize.Y 
		: Parent.GetCachedHeight() * RelativeSize.Y) 
		- (Margin.Y << 1) - (Parent.Padding.Y << 1);
		
	return HeightBoundary.bEnabled ? FClamp( h, HeightBoundary.Min, HeightBoundary.Max ) : h;
}

/** Retrieves the cached Height that was calculated the last time this component was rendered. Recommend for use within Tick functions. */
final function float GetCachedHeight()
{
	return HeightY;
}

/** Calculates the screen width for this component. */
protected function float GetWidth()
{
	local float w;
	
	w = (bJustify 
		? GetCachedHeight() 
		: RelativeSize.X > 1.0 
			? RelativeSize.X 
			: Parent.GetCachedWidth() * RelativeSize.X) 
			- (Margin.X << 1) - (Parent.Padding.X << 1);
	
	return WidthBoundary.bEnabled ? FClamp( w, WidthBoundary.Min, WidthBoundary.Max ) : w;
}

/** Retrieves the cached Width that was calculated the last time this component was rendered. Recommend for use within Tick functions. */
final function float GetCachedWidth()
{
	return WidthX;
}

/** Calculates the top screen position for this component. */
protected function float GetTop()
{
	local float y, oy;
	
	y = (Parent.GetCachedTop() + Parent.GetCachedHeight() * RelativePosition.Y);
	oy = (Margin.Z + Parent.Padding.Z) + ((Positioning < EPositioning.P_Fixed) ? Parent.OriginOffset.Y : 0.0f);
	return (VerticalDock == VD_Bottom) ? y - GetCachedHeight() - oy : y + oy;
}

/** Retrieves the cached Top that was calculated the last time this component was rendered. Recommend for use within Tick functions. */
final function float GetCachedTop()
{
	return TopY;
}

/** Calculates the left screen position for this component. */
protected function float GetLeft()
{
	local float x, ox;
	
	x = (Parent.GetCachedLeft() + Parent.GetCachedWidth() * RelativePosition.X);
	ox = (Margin.W + Parent.Padding.W) + ((Positioning < EPositioning.P_Fixed) ? Parent.OriginOffset.X : 0.0f);	
	return (HorizontalDock == HD_Right) ? x - GetCachedWidth() - ox : x + ox;
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
	return (bEnabled 
	`if( `isdefined( DEBUG ) )
		|| Scene().bRenderRectangles
	`endif
	) && CanRender();
}

final function SetVisible( bool v )
{
	bVisible = v;
	OnVisibleChanged( self );
}

final function SetEnabled( bool e )
{
	bEnabled = e;
	OnEnabledChanged( self );
}

function bool IsHover( IntPoint mousePosition, out FComponent hoveredComponent )
{
	if( Collides( mousePosition ) )
	{
		hoveredComponent = self;
		return true;
	}
	return false;
}

final function Vector2D GetPosition()
{
	local Vector2D v;
	
	v.X = GetCachedLeft();
	v.Y = GetCachedTop();
	return v;
}

final function Vector2D GetSize()
{
	local Vector2D v;
	
	v.X = GetCachedWidth();
	v.Y = GetCachedHeight();
	return v;
}

final static function Vector PointToVect( IntPoint point )
{
	local Vector v;
	
	v.X = point.X;
	v.Y = point.Y;
	return v;	
}

final protected function bool Collides( IntPoint mousePosition )
{
	local Vector2D pos, size;
	
	pos = GetPosition();
	size = GetSize();
	switch( CollisionShape )
	{
		case CS_Rectangle:
			return ((mousePosition.X >= pos.X) && (mousePosition.X <= pos.X + size.X))
					&& 
				   ((mousePosition.Y >= pos.Y) && (mousePosition.Y <= pos.Y + size.Y));
					   
		// My math is terrible :D
		case CS_Circle:
			pos.X += size.X*(0.5 - HorizontalDock);
			pos.Y += size.Y*(0.5 - VerticalDock);
			return Abs( pos.X - mousePosition.X ) <= size.X && Abs( pos.Y - mousePosition.Y ) <= size.Y; 
	}
	return false;
}

// TODO: Move all of the states code to Scene using its own delegates.

/** Notify that the component is selected! */
final function Focus()
{
	LastFocusedTime = `STime;
	LastStateChangeTime = LastFocusedTime;
	InteractionState = InteractionState | ES_Selected;
	OnFocus( self );
	
	Scene().OnFocus( self );
}

/** Notify that the component is no longer selected! */
final function UnFocus()
{
	LastUnfocusedTime = `STime;
	LastStateChangeTime = LastUnfocusedTime;
	InteractionState = InteractionState & ~ES_Selected;
	OnUnFocus( self );
	
	Scene().OnUnFocus( self );
}

final function Active()
{
	LastActiveTime = `STime;
	LastStateChangeTime = LastActiveTime;
	InteractionState = InteractionState | ES_Active;
	OnActive( self );
	
	Scene().OnActive( self );
}

final function UnActive()
{
	LastUnactiveTime = `STime;
	LastStateChangeTime = LastUnactiveTime;
	InteractionState = InteractionState & ~ES_Active;
	OnUnActive( self );
	
	Scene().OnUnActive( self );
}

final function Hover()
{
	LastHoveredTime = `STime;
	LastStateChangeTime = LastHoveredTime;
	InteractionState = InteractionState | ES_Hover;
	OnHover( self );
	
	Scene().OnHover( self );
}

final function UnHover()
{
	LastUnhoveredTime = `STime; 
	LastStateChangeTime = LastUnhoveredTime;
	InteractionState = InteractionState & ~ES_Hover;
	OnUnHover( self );
	
	Scene().OnUnHover( self );
}

//=====================================================
// HELPER METHODS

final function FScene Scene()
{
	return Controller.Scene();
}

final function PlayerController Player()
{
	return Controller.Player();
}

final function string ConsoleCommand( string command )
{
	return Controller.Player().ConsoleCommand( command );
}

final protected function RenderBackground( Canvas C, Color drawColor = Style.ImageColor )
{
	if( Style == none )
	{
		`Log( "Attempting to draw a background for component:" @ self @ "without a style!" );
		return;
	}
	
	C.DrawColor = drawColor;
	Style.DrawBackground( C, WidthX, HeightY );
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
	local Color newStateColor;
	
	if( !CanInteract() )
	{
		newStateColor = Style.DisabledColor;
	}
	else if( IsActive() )
	{
		FadingSwapColor( newStateColor, Style.ActiveColor, LastStateChangeTime );	
	}
	else if( IsHovered() )
	{
		FadingSwapColor( newStateColor, Style.HoverColor, LastStateChangeTime );
	}
	else if( HasFocus() )
	{
		FadingSwapColor( newStateColor, Style.FocusColor, LastStateChangeTime );	
	}
	else
	{
		FadingSwapColor( newStateColor, defaultColor, LastStateChangeTime );	
	}
	return newStateColor;
}

final protected function FadingSwapColor( out Color newColor, Color destColor, float oldColorTime )
{
	const FadingSwapTime = 4.0;
	local float pct;
	
	pct = FMin( `STimeSince( oldColorTime )/FadingSwapTime, 1.0 );
	newColor = LastStateColor + destColor*pct - LastStateColor*pct;
	newColor.A = destColor.A;
	LastStateColor = newColor;
}

/** Create a new instance of @componentClass. 
 *	Used to create components at run-time.
 */
final protected function FComponent CreateComponent( class<FComponent> componentClass, optional Object componentOuter = self, optional FComponent componentTemplate = none )
{
	return new(componentOuter) componentClass (componentTemplate);
}

final static function StartClipping( Canvas C, out float x, out float y )
{
	local float xc, yc;
	
	xc = C.ClipX;
	yc = C.ClipY;
	C.SetClip( x, y );
	x = xc;
	y = yc;
}

final static function StopClipping( Canvas C, float x, float y )
{
	C.SetClip( x, y );
}

// ALT: RelativePosition.X - (pixels/GetLeft()*RelativePosition.X)
final function float MoveLeft( float pixels )
{
	return (GetCachedLeft() + pixels)/Parent.GetCachedWidth();
}

// ALT: RelativePosition.Y - (pixels/GetTop()*RelativePosition.Y)
final function float MoveTop( float pixels )
{
	return (GetCachedTop() + pixels)/Parent.GetCachedHeight();
}

defaultproperties
{
	bVisible=true
	bEnabled=true
	bSupportSelection=true
	bSupportHovering=true
	bClipComponent=false

	begin object name=oStyle class=FStyle
		// Styles...	
	end object
	Style=oStyle

	HorizontalDock=HD_Left
	VerticalDock=VD_Top

	RelativePosition=(X=0.0,Y=0.0)
	Margin=(X=2,Y=2,Z=2,W=2)
	//Padding=(X=2,Y=2,Z=2,W=2)
}