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
 * FTabControl: A container for FTabButtons with associated FPages.
 * ======================================================== */
class FTabControl extends FMultiComponent;

/** The currently actively rendered and interactable tab's page. */
var(TabControl, Advanced) `{Automated} FPage ActivePage;

/** Put the @ActivePage within this ExternContainer. */
var(TabControl, Advanced) FMultiComponent ExternContainer;

/** Called when the tab control's active page is changed. */
delegate OnSwitch( FPage oldPage, FPage newPage );

function Free()
{
	super.Free();
	ActivePage = none;
	OnSwitch = none;
	ExternContainer = none;
}

protected function InitializeComponent()
{
	local FComponent component;
	local FTabButton tab;

	super.InitializeComponent();
	foreach Components( component )
	{
		if( FTabButton(component) != none )
		{
			tab = FTabButton(component);
			tab.OnClick = TabClicked;
			if( tab.TabPage == none )
			{
				`Log( "Warning! " @ tab $ "'s TabPage is none!" );
				continue;
			
			}
			if( ExternContainer == none )
			{
				tab.TabPage.Initialize( self );	
			}
			else
			{
				ExternContainer.AddComponent( tab.TabPage );
				tab.TabPage.SetVisible( false );
			}
		}
	}
	SetActivePage( ActivePage );	
}

protected function PostRender( Canvas C )
{
	super.PostRender( C );
	if( ExternContainer == none && ActivePage != none && ActivePage.CanRender() )
	{
		ActivePage.Render( C );
	}
}

function Update( float DeltaTime )
{
	super.Update( DeltaTime );
	if( ExternContainer == none && ActivePage != none && ActivePage.CanInteract() )
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
			if( ExternContainer == none && ActivePage != none && ActivePage.CanInteract() && ActivePage.IsHover( mousePosition, hoveredComponent ) )
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
	local FPage previousPage;

	previousPage = ActivePage;
	ActivePage = newPage;

	if( previousPage != none )
	{
		previousPage.SetVisible( false );
	}

	if( newPage != none )
	{
		newPage.SetVisible( true );
	}

	OnSwitch( previousPage, newPage );	
}

function TabClicked( FComponent sender, optional bool bRight )
{
	local FPage newPage;

	// Consider this as click on the FTabControl component as well!
	OnClick( sender, bRight );

	newPage = FTabButton(sender).TabPage;
	if( newPage == ActivePage )
	{
		return;
	} 
	SetActivePage( newPage );
}

defaultproperties
{
}