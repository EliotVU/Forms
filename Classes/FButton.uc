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
class FButton extends FLabel;

var(Component, Display) bool bRenderCaption;
var(Component, Display) bool bImageUseStateColor;
var(Component, Display) bool bAnimateOnHover;
var(Component, Display) float AnimateSpeed;
var(Component, Display) float AnimateOffset;
var protected transient float TextMoveOffset;

// TODO: Using DeltaTime from Tick breaks the speed O_O
function Update( float DeltaTime )
{
	super.Update( DeltaTime );
	if( bAnimateOnHover )
	{
		if( IsHovered() )
		{
			TextMoveOffset = FMin( TextMoveOffset + AnimateSpeed * Scene().RenderDeltaTime, AnimateOffset );
		}
		else if( TextMoveOffset > 0.0 )
		{
			TextMoveOffset = FMax( TextMoveOffset - AnimateSpeed * Scene().RenderDeltaTime, 0.0 );
		}
	}
}

function RenderComponent( Canvas C )
{
	super(FComponent).RenderComponent( C );
	C.SetPos( LeftX, TopY );
	// If no caption, then colorize the background based on the component's state.
	C.DrawColor = (bRenderCaption && !bImageUseStateColor) ? Style.ImageColor : GetStateColor();
	RenderBackground( C, C.DrawColor );
	RenderButton( C );
}

function RenderButton( Canvas C )
{
	if( HasFocus() )
	{
		C.SetPos( LeftX, C.CurY );
		C.DrawColor = Style.FocusColor;
		C.DrawBox( WidthX, HeightY );
	}

	if( bRenderCaption && Text != "" )
	{
		RenderLabel( C, LeftX + TextMoveOffset, TopY, WidthX, HeightY, 
			(bImageUseStateColor) ? TextColor : GetStateColor( TextColor ) 
		);
	}
}

defaultproperties
{
	RelativePosition=(X=0.0,Y=0.0)
	RelativeSize=(X=0.4,Y=0.18)

	Text="Button"
	TextColor=(R=255,G=255,B=255,A=255)
	TextAlign=TA_Center
	bRenderCaption=true

	bEnabled=true

	AnimateSpeed=10
	AnimateOffset=6
}