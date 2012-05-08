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
class FMultiComponent extends FComponent
	abstract;

var(Component, Advanced) protectedwrite editinline array<FComponent> Components;

function Initialize( FController c )
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

function RenderChildren( Canvas C )
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

function Update( float DeltaTime )
{
	local FComponent component;

	super.Update( DeltaTime );
	foreach Components( component )
	{
		component.Update( DeltaTime );
	}
}

/** 
 *	Do NOT call Free on other objects here!
 */
function Free()
{
	Components.Length = 0;
	super.Free();
}

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

function AddComponent( FComponent component )
{
	component.Parent = self;
	component.Initialize( Controller );
	Components.AddItem( component );
}

function RemoveComponent( FComponent component, optional bool freeComponent = false )
{
	Components.RemoveItem( component );
	component.Parent = none;

	if( freeComponent )
	{
		Controller.Scene.FreeObject( component );
	}
}

final function FComponent FindComponentByName( name componentName )
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