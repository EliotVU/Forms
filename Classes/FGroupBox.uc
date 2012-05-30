class FGroupBox extends FMultiComponent;

var(Component, Advanced) `{Automated} FLabel Text;

function Free()
{
	super.Free();
	Text = none;
}

function InitializeComponent()
{
	super.InitializeComponent();
	if( Text != none )
	{
		Text.SetPos( 0.1, 0.00 );
		Text.SetSize( 0.3, 40 );
		Text.SetMargin( Text.Margin.W, -Padding.Y, Text.Margin.X, Text.Margin.Z*2 );
		Text.TextVAlign = TA_Center;
		Text.bClipComponent = false;
		AddComponent( Text );
	}
}

function RenderComponent( Canvas C )
{
	C.DrawColor = Style.ImageColor;
	
	// Left
	C.SetPos( LeftX, TopY + Padding.Z*0.5 );
	C.DrawRect( 1, HeightY - Padding.Z*0.5 );
	
	// Right
	C.SetPos( LeftX + WidthX - 1, TopY + Padding.Z*0.5 );
	C.DrawRect( 1, HeightY - Padding.Z*0.5 );
	
	if( Text != none )
	{
		// Top Left
		C.SetPos( LeftX, TopY + Padding.Z*0.5 );
		C.DrawRect( Text.GetCachedLeft() - (LeftX + C.OrgX) - Padding.W, 1 );
	
		// Top Right
		C.SetPos( Text.GetCachedLeft() + Text.GetCachedWidth() + Padding.X, TopY + Padding.Z*0.5 );
		C.DrawRect( WidthX - (Text.GetCachedLeft() - (LeftX + C.OrgX)) - Text.GetCachedWidth() - Padding.X, 1 );	
	}
	else
	{
		// Top
		C.SetPos( LeftX, TopY );
		C.DrawRect( WidthX, 1 );	
	}
	
	// Bottom
	C.SetPos( LeftX, TopY + HeightY - 1 );
	C.DrawRect( WidthX, 1 );		
}

defaultproperties
{
	Padding=(W=8,X=8,Y=8,Z=8)
	
	begin object name=oStyle
		ImageColor=(R=180,G=180,B=180,A=255)
	end object
}