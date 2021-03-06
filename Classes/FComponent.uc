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
 * FComponent: The base class of all scene controls.
 * ======================================================== */
class FComponent extends FObject
	config(Forms)
	forcescriptorder(true)
	perobjectconfig
	perobjectlocalized
	abstract;

/** Is this component visible? */
var(Component, Function) protectedwrite bool 					bVisible;

/** Is this component interactable? */
var(Component, Function) protectedwrite bool 					bEnabled;

var(Component, Function) const bool 							bEnableClick;
var(Component, Function) const bool 							bEnableCollision;

/** How RelativePosition and RelativeSize values should be handled. Auto-configured through the Size variable. */
var editconst enum EMeasureMethod
{
	/** 
	 * 1.0 = 100% of parent's size/position. 
	 * 100.0 = 100 pixels for size, but for position 100 = 1000% of parent's size. 
	 */
	EM_Standard,

	/**
	 * 1.0 = 1 pixel.
	 * 100.0 = 100 pixels.
	 */
	EM_Pixels,

	/**
	 * 1.0 = 100% of parent's size/position.
	 * 100.0 = 1000% of parent's size/position.
	 */
	EM_Percentage
} MMPosX, MMPosY, MMSizeX, MMSizeY;

/** The relative position of this component, relative starting from the parent's position, in percentage! */
var(Component, Positioning) privatewrite Vector2D 				RelativePosition;

/** The relative size of this component, relative starting from the parent's size, in percentage! */
var(Component, Positioning) privatewrite Vector2D 				RelativeSize;

var(Component, Positioning) const editconst string 				Size;

/**
 *  X, W, Y, Z margin in pixels:
 *	X = Right	Margin
 *	W = Left	Margin
 *	Y = Bottom	Margin
 *	Z = Top		Margin
 */
var(Component, Positioning) privatewrite Vector4 				Margin;

/**
 *  X, W, Y, Z padding in pixels:
 *	X = Right	Padding
 *	W = Left	Padding
 *	Y = Bottom	Padding
 *	Z = Top		Padding
 */
var(Component, Positioning) privatewrite Vector4 				Padding;

/** Max/Min width for this component. */
var(Component, Positioning) Boundary 							WidthBoundary;

/** Max/Min height for this component. */
var(Component, Positioning) Boundary 							HeightBoundary;

/** The width of the component will be set to that of height in pixels. */
var(Component, Positioning) bool								bJustify;

/** Whether to clip anything going out of this component's region. */
var(Component, Display) bool									bClipComponent;

/** The X(of RelativePosition) that the component will stick to. */
var(Component, Positioning) enum EHorizontalDock
{
	/** Start drawing from RelativePosition X. */
	HD_Left,
	/** End drawing at RelativePosition X. */
	HD_Right
} 																HorizontalDock;

/** The Y(of RelativePosition) that the component will stick to. */
var(Component, Positioning) enum EVerticalDock
{
	/** Start drawing from RelativePosition Y. */
	VD_Top,
	/** End drawing at RelativePosition Y. */
	VD_Bottom
} 																VerticalDock;

/** How to handle positioning for this component. */
var(Component, Positioning) enum EPositioning
{
	/** Position Relative: Default. */
	P_Relative,
	/** Position Fixed: Scrolling will not move this component. */
	P_Fixed,
} 																Positioning;

/** The collision shape of this component. */
var(Component, Collision) enum ECollisionShape
{
	CS_Rectangle,
	CS_Circle
} 																CollisionShape;

/**
 * If assigned to a FToolTip then the assigned component will be rendered upon hovering this component.
 *
 * Usage example:
	begin object name=oQuit class=FButton
		RelativePosition=(X=0.00,Y=1.0)
		RelativeSize=(X=1.0,Y=0.10)
		Text="@UDKGameUI.Generic.Exit"
		TextAlign=TA_Center
		VerticalDock=VD_Bottom
		StyleNames.Add(QuitButton)
		begin object name=myToolTip class=FToolTip
			ToolTipText="Exit the game?"
		end object
		ToolTipComponent=myToolTip
	end object	
	Components.Add(oQuit)
 */
var(Component, Display) editconst editinline FToolTipBase		ToolTipComponent;

/** 
 * A style object will be created and assigned to @Style based on an ini configuration 
 *  - such as [Button FStyle] then StyleNames would be 'Button'. 
 * ---
 * It's possible to use hyphens to define style inheritance:
 * 	When initializing, this specified style class will be inherited when creating this component's style. 
 * 	For example: Button-TabButton inherits Button but Button-TabButton:hover does not inherit Button:hover! :(
 *	This is defined as StyleNames.Add(Button), StyleNames.Add(TabButton)
 * ---
 * If the array is empty then @StyleName will be used instead.
 */
var(Component, Display) editconst const private array<name> 	StyleNames;
var(Component, Display) editconst const private name			StyleName;
var(Component, Display) editconst const private class<FStyle>	StyleClass;

/** The style for this component to use. */
var(Component, Display) protectedwrite editinline FStyle 		Style;

var privatewrite FStyle											InitStyle,
																PrevStyle, 
																HoverStyle, 
																ActiveStyle, 
																FocusStyle;

const ES_None			= 0x00;
const ES_Hover			= 0x01;
const ES_Selected		= 0x02;
const ES_Active			= 0x04;

/** The current interaction state, e.g. Hover, Selected or Active. */
var transient editconst byte InteractionState;

/** 
 * An absolute position in pixels, for this component. 
 * if bClipComponent is true then PosY will be relative from Canvas.Org*.
 */
var privatewrite transient editconst float PosY, PosX;

/** 
 * An absolute size in pixels, for this component. 
 */
var privatewrite transient editconst float SizeX, SizeY;

// A dynamic position offset(Controlled by scrolling).
var transient Vector2D OriginOffset;

// This component has been initialized?
var transient edithide editconst bool bInitialized;

/** Useful todo animations when hovering/unhovering. RealTimeSeconds! */
var transient edithide editconst float LastHoveredTime, LastUnhoveredTime;
var transient edithide editconst float LastFocusedTime, LastUnfocusedTime;
var transient edithide editconst float LastActiveTime, LastUnactiveTime;
var transient edithide editconst float LastStateChangeTime;
var transient edithide editconst Color LastStateColor, LastImageColor;

/** Cannot be used(same for other objects) from delegate events if that delegate is initialized via the DefaultProperties block! */
var protectedwrite transient editconst FIController Controller;

/** Cannot be used(same for other objects) from delegate events if that delegate is initialized via the DefaultProperties block! */
var protectedwrite noimport editconst FComponent Parent;

/**
 * Triggered when this component is: 
 *   (Hovered and mouse clicked), 
 *   (Focussed and Enter|Spacebar is released), 
 *   (Hovered and tapped/touch).
 *
 * @param bRight - Alternative click(Rightmouse click).
 */
delegate OnClick( FComponent sender, optional bool bRight );
delegate OnDoubleClick( FComponent sender, optional bool bRight );

delegate OnMouseButtonPressed( FComponent sender, optional bool bRight );
delegate OnMouseButtonRelease( FComponent sender, optional bool bRight );
delegate OnMouseWheelInput( FComponent sender, optional bool bUp );

function BubbleMouseWheelInput( FComponent sender, optional bool bUp )
{
	if( CanInteract() && OnMouseWheelInput != none )
	{
		OnMouseWheelInput( sender, bUp );
		return;
	}
	Parent.BubbleMouseWheelInput( sender, bUp );
}

/** Triggered for active components everytime the mouse made a move inbetween a Tick() event. */
delegate OnMouseMove( FScene scene, float DeltaTime );

/** Triggered for focussed components for every keyboard input. */
delegate bool OnKeyInput( name Key, EInputEvent EventType );
delegate bool OnCharInput( string Unicode );

// STATE
delegate OnVisibleChanged( FComponent sender );
delegate OnEnabledChanged( FComponent sender );
delegate OnPositionChanged( FComponent sender );
delegate OnSizeChanged( FComponent sender );

// DRAWING
delegate OnPostRender( FComponent sender, Canvas C );

// UPDATING
/** Called after this component and any of its children have been initialized. */
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
final function Initialize( FComponent within )
{
	//`Log( Name @ "Initialize",, 'FormsInit' );
	if( bInitialized )
		return;

	bInitialized = true;
	Parent = within;
	if( Parent != none )
	{
		Controller = Parent.Controller;
	}
	Scene().AddToPool( self );

	InitializeProperties();
	InitializeComponent();

	// Post initialize
	if( FMultiComponent(Parent) != none )
	{
		FMultiComponent(Parent).OnComponentInitialized( self );
	}
	OnInitialize( self );
}

private final function InitializeProperties()
{
	if( Size != "" )
	{
		if( InStr( Size, " " ) == INDEX_NONE )
		{
			`Warn( "Invalid @Size formatting." );
		}
		else InitSizeProperty();
	}
} 

private final function InitSizeProperty()
{
	local string remaining, val1, mes1, val2, mes2;

	// Parses: [0-9\.]px|em|pct [0-9\.]px|em|pct
	val1 = Token( Size, remaining, PARSE_NUMERIC );
	mes1 = Token( remaining, remaining, PARSE_NAME );

	val2 = Token( remaining, remaining, PARSE_NUMERIC );
	mes2 = Token( remaining, remaining, PARSE_NAME );

	switch( mes1 )
	{
		case "em":
			RelativeSize.X = float(val1);
			break;

		case "px":
			RelativeSize.X = Round(float(val1));
			break;

		case "pct":
			RelativeSize.X = float(val1)/100.0;
			break;
	}

	switch( mes2 )
	{
		case "em":
			RelativeSize.Y = float(val2);
			break;

		case "px":
			RelativeSize.Y = Round(float(val2));
			break;

		case "pct":
			RelativeSize.Y = float(val2)/100.0;
			break;
	}
}

/** Called after this component has been fully registered but not yet completely initialized. */
protected function InitializeComponent()
{
	if( ToolTipComponent != none )
	{
		ToolTipComponent.Initialize( Scene() );
		Scene().AddToPool( ToolTipComponent );
	}

	OnVisibleChanged( self );
	OnEnabledChanged( self );
	BindStyle();
}

/*public final function ResetStyle()
{
	if( HoverStyle != none ){Scene().FreeObject( HoverStyle ); HoverStyle = none;}
	if( ActiveStyle != none ){Scene().FreeObject( ActiveStyle ); ActiveStyle = none;}
	if( FocusStyle != none ){Scene().FreeObject( FocusStyle ); FocusStyle = none;}

	Scene().FreeObject( InitStyle ); InitStyle = none;
	Style = none;

	//ResetConfig( true );

	BindStyle();
}*/

private final function BindStyle()
{
	local string styleIdentifier;

	styleIdentifier = (StyleNames.Length > 0) ? SplitArray( StyleNames, "-" ) : string(StyleName);
	Style = Scene().GetStyle( styleIdentifier, StyleClass );
	InitStyle = Style;
	PrevStyle = InitStyle;

	InitStateStyles( styleIdentifier );
}

protected function InitStateStyles( string styleId )
{
	// All states inherit the default's style not Global:Hover( not supported :( ))
	HoverStyle = bEnableCollision ? GetStateStyle( styleId, "hover" ) : none;
	if( HoverStyle == none ) HoverStyle = InitStyle;

	ActiveStyle = (bEnableCollision && bEnableClick) ? GetStateStyle( styleId, "active", HoverStyle ) : none;
	if( ActiveStyle == none ) ActiveStyle = InitStyle;

	FocusStyle = (bEnableCollision && bEnableClick) ? GetStateStyle( styleId, "focus" ) : none;
	if( FocusStyle == none ) FocusStyle = InitStyle;
}

protected final function FStyle GetStateStyle( string styleIdentifier, string stateName, FStyle inheritStyle = InitStyle )
{
	if( inheritStyle == none )
		inheritStyle = InitStyle;

	return Scene().GetStyle( styleIdentifier $ ":" $ stateName, StyleClass, inheritStyle );
}

/**
 * Checks if this component contains a specified style class.
 * 
 * @param className - The style class to match against.
 * 
 * @return true if contains a specified style class.
 */
final function bool HasClass( string className )
{
	local name n;

	foreach StyleNames( n )
	{
		if( string(n) == className )
		{
			return true;
		}
	}
	return false;
}

/** Called every tick if Enabled and Visible. */
function Update( float DeltaTime )
{
	//...
	OnUpdate( self, DeltaTime );
}

/** Re-calculate all positions and sizes. */
function Refresh()
{
	PosY = CalcTop();
	PosX = CalcLeft();
	SizeX = CalcWidth();
	SizeY = CalcHeight();
}

/** Render this object. Override RenderComponent to draw component specific visuals. */
function Render( Canvas C )
{
	// This re-calculates the position and size.
	Refresh();
	
	if( bClipComponent )
	{
		C.PushMaskRegion( PosX, PosY, SizeX, SizeY );
	}

	PreRender( C );
		if( Style != none )
		{
			Style.Render( C );
			Style.RenderFirstElements( C, self );
			
			C.SetPos( PosX, PosY );
			RenderComponent( C );
			
			Style.RenderLastElements( C, self );
		}
	PostRender( C );

	`if( `isdefined( DEBUG ) )
		if( Scene().bDebugModeIsActive )
		{
			C.DrawColor = Colors.static.FadeOut( IsHovered() 
				? Colors.default.SapphireColor
				: Colors.default.GrayColor, 50.00 
			);
			C.SetPos( PosX, PosY );	
			C.DrawBox( SizeX, SizeY );	

			if( bClipComponent )
			{
				C.Draw2DLine( PosX, PosY, SizeX, SizeY, C.DrawColor );
			}
		}
	`endif

	if( bClipComponent )
	{
		C.PopMaskRegion();	
	}
}

/** Performed before this component(@RenderComponent()) has been drawn. */
protected function PreRender( Canvas C );

/** Override this to render anything specific to an unique component. */
protected function RenderComponent( Canvas C );

/** Performed after this component(@RenderComponent()) has been drawn. */
protected function PostRender( Canvas C )
{
	OnPostRender( self, C );
}

/** 
 *	Override this to clear any Object/Actor references! 
 *	Do NOT call Free on other objects here!
 */
function Free()
{
	`Log( Name $ "Free" );
	
	// POINTERS
	Controller = none;
	Parent = none;
	Style = none; InitStyle = none; PrevStyle = none; HoverStyle = none; ActiveStyle = none; FocusStyle = none;
	ToolTipComponent = none;

	// DELEGATES
	OnClick = none;
	OnDoubleClick = none;
	OnMouseButtonPressed = none;
	OnMouseButtonRelease = none;
	OnMouseWheelInput = none;
	OnMouseMove = none;
	OnKeyInput = none;
	OnCharInput = none;
	OnVisibleChanged = none;
	OnEnabledChanged = none;
	OnPositionChanged = none;
	OnSizeChanged = none;
	OnPostRender = none;
	OnInitialize = none;
	OnUpdate = none;
	OnHover = none;
	OnUnHover = none;
	OnFocus = none;
	OnUnFocus = none;
	OnActive = none;
	OnUnActive = none;

	bInitialized = false;	// So it may be restored later if desired.
}

final function SetStyle( FStyle newStyle )
{
	if( newStyle == none )
		return;
		
	Style = newStyle;
}

final function SetPos( const float X, const float Y )
{
	RelativePosition.X = X;
	RelativePosition.Y = Y;
	OnPositionChanged( self );
}

final function SetSize( const float X, const float Y )
{
	RelativeSize.X = X;
	RelativeSize.Y = Y;
	OnSizeChanged( self );
}

final function SetMargin( const float leftPixels, const float topPixels, const float rightPixels, const float bottomPixels )
{
	Margin.X = rightPixels;
	Margin.Y = bottomPixels;
	Margin.W = leftPixels;
	Margin.Z = topPixels;
}

final function SetPadding( const float leftPixels, const float topPixels, const float rightPixels, const float bottomPixels )
{
	Padding.X = rightPixels;
	Padding.Y = bottomPixels;
	Padding.W = leftPixels;
	Padding.Z = topPixels;
}

/** Calculates the screen height for this component. */
protected function float CalcHeight()
{
	local float h;
	
	h = (RelativeSize.Y > 1.0 
		? RelativeSize.Y 
		: Parent.GetHeight() * RelativeSize.Y) 
		- (Margin.Y << 1) - (Parent.Padding.Y << 1);
		
	return int(HeightBoundary.bEnabled ? FClamp( h, HeightBoundary.Min, HeightBoundary.Max ) : h);
}

/** Calculates the screen width for this component. */
protected function float CalcWidth()
{
	local float w;
	
	w = (bJustify 
		? GetHeight() 
		: RelativeSize.X > 1.0 
			? RelativeSize.X 
			: Parent.GetWidth() * RelativeSize.X) 
			- (Margin.X << 1) - (Parent.Padding.X << 1);
	
	return int(WidthBoundary.bEnabled ? FClamp( w, WidthBoundary.Min, WidthBoundary.Max ) : w);
}

/** Calculates the top screen position for this component. */
protected function float CalcTop()
{
	local float y, oy;
	
	y = (Parent.GetTop() + Parent.GetHeight() * RelativePosition.Y);
	oy = (Margin.Z + Parent.Padding.Z) + ((Positioning < EPositioning.P_Fixed) ? 
		VerticalDock == VD_Bottom ? -Parent.OriginOffset.Y : Parent.OriginOffset.Y : 0.0f);
	return int((VerticalDock == VD_Bottom) ? y - GetHeight() - oy : y + oy);
}

/** Calculates the left screen position for this component. */
protected function float CalcLeft()
{
	local float x, ox;
	
	x = (Parent.GetLeft() + Parent.GetWidth() * RelativePosition.X);
	ox = (Margin.W + Parent.Padding.W) + ((Positioning < EPositioning.P_Fixed) ? 
		HorizontalDock == HD_Right ? -Parent.OriginOffset.X : Parent.OriginOffset.X : 0.0f);	
	return int((HorizontalDock == HD_Right) ? x - GetWidth() - ox : x + ox);
}

/** 
 * Retrieves the height for this component.
 */
final function float GetHeight()
{
	return SizeY;
}

/** 
 * Retrieves the width for this component.
 */
final function float GetWidth()
{
	return SizeX;
}

/** 
 * Retrieves the left side position for this component.
 */
final function float GetLeft()
{
	return PosX;
}

/** 
 * Retrieves the right side position for this component.
 */
final function float GetRight()
{
	return PosX + SizeX;
}

/** 
 * Retrieves the top side position for this component.
 */
final function float GetTop()
{
	return PosY;
}

/** 
 * Retrieves the bottom side position for this component.
 */
final function float GetBottom()
{
	return PosY + SizeY;
}

final function Vector2D GetPosition()
{
	local Vector2D v;
	
	v.X = GetLeft();
	v.Y = GetTop();
	return v;
}

final function Vector2D GetSize()
{
	local Vector2D v;
	
	v.X = GetWidth();
	v.Y = GetHeight();
	return v;
}

final function Rect GetRect()
{
	local Rect r;
	
	r.X = GetLeft();
	r.Y = GetTop();
	r.W = GetWidth();
	r.H = GetHeight();
	return r;
}

/** Determine whether this component should receive Render() calls. */
function bool CanRender()
{
	return bVisible;
}

/** Determine whether this component can be tested for collisions. */
function bool CanInteract()
{
	return (bEnabled 
	`if( `isdefined( DEBUG ) )
		|| Scene().bDebugModeIsActive
	`endif
	) && CanRender();
}

final function SetVisible( const bool v )
{
	if( bVisible != v )
	{
		bVisible = v;
		OnVisibleChanged( self );
	}
}

final function SetEnabled( const bool e )
{
	if( bEnabled != e )
	{
		bEnabled = e;
		OnEnabledChanged( self );
	}
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

final protected function bool Collides( out IntPoint mousePosition )
{
	local Vector2D cPos, cSize;
	
	cPos = GetPosition();
	cSize = GetSize();
	switch( CollisionShape )
	{
		case CS_Rectangle:
			return ((mousePosition.X >= cPos.X) && (mousePosition.X <= cPos.X + cSize.X))
					&& 
				   ((mousePosition.Y >= cPos.Y) && (mousePosition.Y <= cPos.Y + cSize.Y));
					   
		// My math is terrible :D
		case CS_Circle:
			cPos.X += cSize.X*(0.5 - HorizontalDock);
			cPos.Y += cSize.Y*(0.5 - VerticalDock);
			return Abs( cPos.X - mousePosition.X ) <= cSize.X && Abs( cPos.Y - mousePosition.Y ) <= cSize.Y; 
	}
	return false;
}

final function FStyle GetPresentStyle()
{	
	if( IsActive() )
	{
		return ActiveStyle;
	}
	else if( IsHovered() )
	{
		return HoverStyle;	
	}
	else if( HasFocus() )
	{
		return FocusStyle;
	}
	else
	{
		return InitStyle;
	}
}

// TODO: Move all of the states code to Scene using its own delegates.

/** Notify that the component is selected! */
final function Focus()
{
	Style = FocusStyle;
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

	PrevStyle = Style;
	Style = GetPresentStyle();
}

final function Active()
{
	Style = ActiveStyle;
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

	PrevStyle = Style;
	Style = GetPresentStyle();
}

final function Hover()
{
	Style = HoverStyle;
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

	PrevStyle = Style;
	Style = GetPresentStyle();
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

final function string ConsoleCommand( const string command )
{
	return Controller.Player().ConsoleCommand( command );
}

final protected function RenderBackground( Canvas C, 
	optional Color drawColor = GetImageColor() )
{
	C.DrawColor = drawColor;
	Style.DrawBackground( C, SizeX, SizeY );
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

final function Color GetImageColor()
{
	local Color newColor;
	local float pct;
	local FStyle lastStyle, destStyle;

	if( !InitStyle.bTransitionColor )
		return Style.ImageColor;

	if( InitStyle == Style )
	{
		lastStyle = PrevStyle;
		destStyle = InitStyle;
	}
	else
	{
		lastStyle = InitStyle;
		destStyle = Style;
	}

	if( LastImageColor.A == 0 )
		LastImageColor = lastStyle.ImageColor;

	if( LastImageColor == Style.ImageColor )
		return LastImageColor;

	pct = FMin( `STimeSince( LastStateChangeTime )/1.5, 1.0 );
	newColor = LastImageColor + destStyle.ImageColor*pct - LastImageColor*pct;	
	newColor.A = Style.ImageColor.A + destStyle.ImageColor.A*pct - Style.ImageColor.A*pct;
	LastImageColor = newColor;
	return newColor;
}

/** Returns a color based on this component's state such as hover, focus, selected or disabled! */
final function Color GetStateColor( optional Color destColor = Style.ImageColor )
{
	local Color newColor;
	
	if( !CanInteract() )
	{
		destColor = Style.DisabledColor;
	}
	else if( IsActive() )
	{
		destColor = Style.ActiveColor;
	}
	else if( IsHovered() )
	{
		destColor = Style.HoverColor;
	}
	else if( HasFocus() )
	{
		destColor = Style.FocusColor;
	}
	FadingSwapColor( newColor, destColor, LastStateChangeTime );	
	return newColor;
}

final protected function FadingSwapColor( out Color newColor, const out Color destColor, const float oldColorTime )
{
	const FadingSwapTime = 4.0;
	local float pct;

	if( !InitStyle.bTransitionColor )
	{
		newColor = destColor;
		return;
	}
	
	pct = FMin( `STimeSince( oldColorTime )/FadingSwapTime, 1.0 );
	newColor = LastStateColor + destColor*pct - LastStateColor*pct;
	newColor.A = LastStateColor.A + destColor.A*pct - LastStateColor.A*pct;
	//newColor.A = destColor.A;
	LastStateColor = newColor;
}

/** Create a new instance of @componentClass. 
 *	Used to create components at run-time.
 */
final protected function FComponent CreateComponent( const class<FComponent> componentClass, 
	optional Object componentOuter = self, 
	optional FComponent componentTemplate = none, 
	optional string componentName )
{
	return new(componentOuter, componentName) componentClass (componentTemplate);
}

// ALT: RelativePosition.X - (pixels/GetLeft()*RelativePosition.X)
final function float MoveLeft( const float pixels )
{
	return (GetLeft() + pixels)/Parent.GetWidth();
}

// ALT: RelativePosition.Y - (pixels/GetTop()*RelativePosition.Y)
final function float MoveTop( const float pixels )
{
	return (GetTop() + pixels)/Parent.GetHeight();
}

defaultproperties
{
	bVisible=true
	bEnabled=true
	bEnableClick=true
	bEnableCollision=true

	StyleName=Hidden
	StyleClass=class'FStyle'

	HorizontalDock=HD_Left
	VerticalDock=VD_Top

	RelativePosition=(X=0.0,Y=0.0)
	Margin=(X=2,Y=2,Z=2,W=2)
	//Padding=(X=2,Y=2,Z=2,W=2)
}