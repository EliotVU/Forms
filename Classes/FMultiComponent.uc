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
 * FMultiComponent: The component that can handle more than one component instance.
 * A MultiComponent is used for grouping a set of other controls, for example: FBindingBox, FGroupBox and especially FPage.
 * Note: MultiComponents(hence abstract) should not be used within menus, use an FContainer instead.
 * ======================================================== */
class FMultiComponent extends FComponent
	abstract;

/** Associated components. Any component in this list will receive initializing, rendering, updating and interactions. */
var(MultiComponent, Advanced) protectedwrite editinline editfixedsize array<FComponent> Components<MaxPropertyDepth=1>;

/** Called for each component that is initialized and owned by this component. */
delegate OnComponentInitialized( FComponent component );	// Instigated in FComponent.Initialize(...)

// Do NOT call Free on other objects here!
function Free()
{
	super.Free();
	OnComponentInitialized = none;
	Components.Length = 0;
}

protected function InitializeComponent()
{
	local FComponent component;

	super.InitializeComponent();
	foreach Components( component )
	{
		component.Initialize( self );
	} 	
}

function Render( Canvas c )
{
	super.Render( c );
	RenderChildren( c );
}

/**
 * Renders all associated @Components. 
 * Components are rendered in the order from top to bottom.
 */
protected function RenderChildren( Canvas c )
{
	local int i;

	for( i = Components.Length - 1; i >= 0; -- i )
	{
		if( Components[i].CanRender() )
		{
			Components[i].Render( c );
		}
	}
}

/** Updates all associated @Components. */
function Update( float deltaTime )
{
	local FComponent component;

	super.Update( deltaTime );
	foreach Components( component )
	{
		component.Update( deltaTime );
	}
}

/** 
 * Test all associated @Components for collision. 
 * Components are tested in the order from bottom to top.
 */
function bool IsHover( IntPoint mousePosition, out FComponent hoveredComponent )
{
	local FComponent component;
	local bool bHover;

	// Test this class first!
	if( Collides( MousePosition ) )
	{
		foreach Components( component )
		{
			if( component.CanInteract() && component.IsHover( mousePosition, hoveredComponent ) )
			{
				bHover = true;
				break;
			}
		}

		if( !bHover )
		{
			hoveredComponent = self;
		}
		return true;
	}
	return false;
}

/** Adds a component to the associated @Components. */
function AddComponent( FComponent component )
{
	component.Initialize( self );
	Components.AddItem( component );	
}

/** Inserts a component to the associated @Components. */
function InsertComponent( FComponent component, int index )
{
	component.Initialize( self );
	Components.InsertItem( index, component );	
}

/** Removes a component by reference. And optionally free its resources. */
function RemoveComponent( FComponent component, optional bool freeComponent = false )
{
	Components.RemoveItem( component );
	component.Parent = none;

	if( freeComponent )
	{
		Scene().FreeObject( component );
	}
}

/** Finds a component by name. */
final function FComponent FindComponentByName( const name componentName )
{
	local FComponent component;

	foreach Components( component )
	{
		if( component.Name == componentName )
		{
			return component;
		}
	}
	return none;
}

defaultproperties
{
}