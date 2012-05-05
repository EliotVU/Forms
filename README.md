Forms
=====
If there's something I never find in README's, it would be the fact they never mention where the most interesting parts are in the framework.

So I'm definitely gonna do this:
  The most interesting and important part you would want to understand is the FComponent, this is the base class of all components which extends FObject which is just a basic abstract class.
  The second bit is the FScene, this is the class that redirects all the events to the FComponents, whether it is hovered, selected or focused.
  The third bit is the FController, this will give you an idea where it all starts, very simple redirecting to the FScene, don't like the FController? Wrap another class and redirect it to the FScene!
  The fourth bit is the the FormsPlayerController Example, this is the class which will setup Forms, especially the FController, and Main or Escape(Pause) menu.
  One done all of these, you'd have a basic idea of what's going on, though there's definitely still much to learn.
  Check out the FStyle class, this is the class that holds images, state colors. This FStyle class can be configured within archetypes and UDKForms.ini
  So that's pretty much it. Now of course you're still lost where to start, assuming you at least figured out how to setup your FormsPlayerController with a created MainMenu and UDKFrontEndMap.
  
  Let's add a basic button to our MainMenu. MainMenu should be a FPage, this is set in your FormsPlayerController like:
    begin object name=oMainMenu class=FPage
    end object
    MainMenu=oMainMenu
    
  Now change the part where it says class=FPage to your desired FPage, for example "MyMainMenu"
    begin object name=oMainMenu class=MyMainMenu
    end object
    MainMenu=oMainMenu
    
  Let's create our "MyMainMenu" class:
    class MyMainMenu extends FPage;
    
    var FButton ExitButton;
    
    defaultproperties
    {
      // Let's center our main menu!
      
      // Relative position in percentage from parent(FScene(Canvas) in this case)
      RelativePosition=(X=0.25,Y=0.25)
      // Relative size in percentage from parent(FScene(Canvas) in this case)
      RelativeSize=(X=0.5,Y=0.5)
      
      // Let's add a button to the Exit game.
      begin object name=oExitButton class=FButton
        // Red
        TextColor=(R=255,G=0,B=0,A=255)
        // Caption(We use Text because FButton extends FLabel)
        Text="Exit"
        // Delegate OnClick to OnExit, we'll add this function later, see below!
        OnClick=OnExit
        
        // Relative position in percentage from parent(MyMainMenu in this case)
        RelativePosition=(X=0.0,Y=0.8)
        // Relative size in percentage from parent(MyMainMenu in this case)
        RelativeSize=(X=0.2,Y=0.2)
      end object
      // Assign this object to ExitButton, so that we can access it at run-time.
      ExitButton=oExitButton
      Components.Add(oExitButton) // We must add our button to the components list, so it can be processed and drawn.
    }
    
  Now we have to add a method to handle the OnClick/OnExit delegate:
    function OnExit( FComponent sender, bool bRight )
    {
      // Execute a console command named "Exit", we use sender so that it is executed in a instanced component instead of this archetype(where OnClick is assigned)
      sender.ConsoleCommand("Exit");
    }
  Congratulations, if you succeeded on all of those steps, you will now have a Menu covering half of your screen with a button to close the game!
  I recommend looking at more components and especially the FComponent to learn about more properties!