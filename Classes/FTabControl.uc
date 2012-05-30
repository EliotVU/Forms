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
class FTabControl extends FMultiComponent;

var(Component, Advanced) `{Automated} FPage ActivePage;

/** The parent instance for the TabPages if not none! */
var FPage TabPagesParent;

delegate OnSwitch( FPage oldPage, FPage newPage );

function Free()
{
	super.Free();
	TabPagesParent = none;
	ActivePage = none;
	OnSwitch = none;
}

function Initialize( FIController c )
{
	local FComponent component;

	super.Initialize( c );
	foreach Components( component )
	{
		if( FTabButton(component) != none )
		{
			component.OnClick = Click;
		}
	}

	SetActivePage( ActivePage );
}

function Render( Canvas C )
{
	super.Render( C );
	if( ActivePage != none && ActivePage.CanRender() )
	{
		ActivePage.Render( C );
	}
}

function Update( float DeltaTime )
{
	super.Update( DeltaTime );
	if( ActivePage != none && ActivePage.CanInteract() )
	{
		ActivePage.Update( DeltaTime );
	}
}

// Ignore self
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
			hoveredComponent = none;
			if( ActivePage != none && ActivePage.CanInteract() && ActivePage.IsHover( mousePosition, hoveredComponent ) )
			{
				bHover = true;
			}
		}
		return bHover;
	}
	return false;
}

function SetActivePage( FPage newPage )
{
	local FPage C;

	C = ActivePage;
	ActivePage = newPage;
	// Make sure the page gets garbage collected!
	Scene().AddToPool( ActivePage );
	OnSwitch( C, newPage );	
}

function Click( FComponent sender, optional bool bRight )
{
	local FPage N;

	OnClick( sender, bRight );

	N = FTabButton(sender).TabPage;
	if( N == ActivePage )
	{
		return;
	} 
	SetActivePage( N );
}

defaultproperties
{
}