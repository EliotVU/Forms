// This is your controller. Start from this one or modify yours to extend FormsPlayerController like below.
class MyPlayerController extends FormsPlayerController;

defaultproperties
{
	// It's recommend that you handle properties within the class itself!
	begin object name=oMainMenu class=MyMainMenu
		// Properties
	end object
	MainMenu=oMainMenu

	// It's recommend that you handle properties within the class itself!
	begin object name=oEscapeMenu class=MyGameMenu
		// Properties
	end object
	EscapeMenu=oEscapeMenu
}