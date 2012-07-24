/* ========================================================
 * Copyright 2012 Eliot van Uytfanghe
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

/** Initialize all associated Components. */
function Initialize( FIController c )
{
	local FComponent component;

	super.Initialize( c );
	foreach Components( component )
	{
		component.Parent = self;
		component.Initialize( c );
	} 	
}

function Render( Canvas C )
{
	super.Render( C );
	RenderChildren( C );
}

/** Render all associated Components. */
protected function RenderChildren( Canvas C )
{
	local FComponent component;

	foreach Components( component )
	{
		if( component.CanRender() )
		{
			component.Render( C );
		}
	}
}

/** Update all associated Components. */
function Update( float DeltaTime )
{
	local FComponent component;

	super.Update( DeltaTime );
	foreach Components( component )
	{
		component.Update( DeltaTime );
	}
}


// Do NOT call Free on other objects here!
function Free()
{
	OnComponentInitialized = none;
	Components.Length = 0;
	super.Free();
}

/** Test all associated components for collision. */
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

/** Add a component to the associated Components. */
function AddComponent( FComponent component )
{
	component.Parent = self;
	component.Initialize( Controller );
	Components.AddItem( component );	
}

/** Remove a component from the associated Components. */
function RemoveComponent( FComponent component, optional bool freeComponent = false )
{
	Components.RemoveItem( component );
	component.Parent = none;

	if( freeComponent )
	{
		Scene().FreeObject( component );
	}
}

/** Find a component within the associated Components. */
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