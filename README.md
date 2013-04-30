Forms - GUI framework
=====
Forms is a graphical user interface(GUI) framework for the Unreal Development Kit(UDK). Completely written in UnrealScript.

Example Demo
=====
(Forms in action on Linear Celerity)
![Potention](https://imageshack.us/a/img15/1985/920c66fdba564d189ef1306.png)
You can view an example by following this guide [Installing Forms - Wiki](http://github.com/EliotVU/Forms/wiki/Installing-Forms)

Controls
=====
- Pages(Scrollable)
- Windows
- Buttons
- Checkboxes
- BindingBoxes
- GroupBoxes
- TextBoxes
- Sliders
- Labels(Paragraphs)
- ColumnSets
- Dialogs(Draggable)
- Tabs
- ToolTips
- And more...

Features
=====
- 100% UnrealScript
- Doesn't require Adobe Flash Professional
- Customizable controls through DefaultForms.ini(Hover, Focus, and Active states)

Documentation
=====
An example demonstrating how a typical menu's code could look like:

    // The MainMenu. Contains all the basic components such as inline pages and/or buttons.
    class MyMainMenu extends FPage;
    
    // A reference to our ExitButton, so that we could edit properties at run-time or identify delegate events.
    var FButton ExitButton;
    
    function OnExit( FComponent sender, bool bRight )
    {
        // Execute a console command named "Exit", we use sender so that it is executed in an instanced component instead of this archetype(where OnClick is assigned)
        sender.ConsoleCommand("Exit");
    }
    
    defaultproperties
    {
        // Relative position in percentage from parent(FScene(Canvas) in this case)
        RelativePosition=(X=0.25,Y=0.25)
        // Relative size in percentage from parent(FScene(Canvas) in this case)
        RelativeSize=(X=0.5,Y=0.5)
    
        // Let's add a button to exit the game.
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
        // Assign this object to ExitButton, so that we can access it later at run-time.
        ExitButton=oExitButton
        Components.Add(oExitButton) // We must add our button to the components list, so it can be processed and drawn.
    }

  
Component examples
=====

Creating a page with a button

    // Note: Read the tutorials above to understand how to run this:
    begin object name=MainMenu class=MyMainMenu
        RelativePosition=(X=0.10,Y=0.10)
        RelativeSize=(X=0.90,Y=0.90)
    end object
    // This registers the component so that Forms can render, and communicate with this object.
    Components.Add(MainMenu)
    
    then in your created class:
    class MyMainMenu extends FPage;
    
    defaultproperties
    {
      begin object name=ExitButton class=FButton
        // Position at the end of "MainMenu"
        RelativePosition=(X=1.0,Y=1.0)
        
        // Without these the button would begin at X=1 and Y=1 but with those it will end at X=1 and Y=1 instead.
        VerticalDock=VD_Bottom
        HorizontalDock=HD_Right
        
        // The button text, you can set this optionally to Text="@UDKGameUI.Generic.Exit" 
        // - which means the button's text will be whatever Exit is set to in UDKGameUI.ini
        Text="Exit"
      end object
      Components.Add(ExitButton)
    }
    
Creating a Label

    begin object name=Label1 class=FLabel
      RelativePosition=(X=0.0,Y=0.00)
      RelativeSize=(X=1.0,Y=0.10)
      Text="Hello, and welcome to my game!"
    end object
    Components.Add(Label1)
    
Creating a Checkbox and Slider
    
    begin object name=EnableBloom class=FCheckBox
      // See other examples on how to setup positions and sizes.
      Text="Bloom"
      OnInitialize=InitializeComponents
      OnChecked=ValueChanged
      TextAlign=TA_Center
    end object
    Components.Add(EnableBloom)
    
    
    // Add "var FSlider SoundVolume;" to your class.

    begin object name=oSoundVolume class=FSlider
      // See other examples on how to setup positions and sizes.
      PostFix="%"
      MinValue=0
      Value=80
      MaxValue=100
      SnapPower=1.0
      
      // This determines whether the value accepts decimals or not.
      bInteger=true
      
      // See below on how to use these:
      OnInitialize=InitializeComponents
      OnValueChanged=ValueChanged
    end object
    Components.Add(oSoundVolume)
    
    // So you can reference this component easily within your code.
    // - You can also use the FindComponentByName function if you prefer that!
    SoundVolume=oSoundVolume
    
Using delegates

    // Called when a component is initializing.
    // ---
    // This is pseudo code just to give you an idea on how it's done, 
    // - the idea is to set the components values to the values loaded from an .ini or whatever you're using.
    function InitializeComponents( FComponent sender )
    {
      SoundVolume.Value = 80;	
    }
    
    // Called when a component changes it value.
    function ValueChanged( FComponent sender )
    {
      switch( sender )
    	{
    		case SoundVolume:
    			sender.ConsoleCommand( "insert_console_command_here" @ SoundVolume.Value;
    			break;
    	}
    }
    
    // Note: When the events are assigned through defaultproperties 
    // - you have to use "sender." to perform code 
    // - because the function's code is not executed in the context of your class's instance,
    // - but in the generated DEFAULT__NAME object(UDK bug!)
    
Using tooltips

    defaultproperties
    {
      begin object name=ExitButton class=FButton
        // Position at the end of "MainMenu"
        RelativePosition=(X=1.0,Y=1.0)
        
        // Without these the button would begin at X=1 and Y=1 but with those it will end at X=1 and Y=1 instead.
        VerticalDock=VD_Bottom
        HorizontalDock=HD_Right
        
        // The button text, you can set this optionally to Text="@UDKGameUI.Generic.Exit" 
        // - which means the button's text will be whatever Exit is set to in UDKGameUI.ini
        Text="Exit"
        begin object name=ExitToolTip class=FToolTip
          Text="Do you want to exit the game?"
          // or if you want it to be localized, this can be done for any other FLabel as well!
          //Text="@LOCALIZATION_INI_NAME.SECTION.KEY_NAME"
        end object
      end object
      Components.Add(ExitButton)
    }


Other controls

FGroupBox - A container with a title and box border similar to the GroupBoxs on Windows

FStepBox - A component with one FLabel and two FButtons, where the FLabel is the chosen value, and the two buttons allow you to step through a list of values i.e a left arrow and a right arrow.

FBindingBox - A component that can bind automaticaly to key bindings. The user can choose a primary and secondary key to assing for a specified console command.

FTextBox - A component allowing the user to type in, such as a name.

FTabControl and FTabButton - Associates multiple FTabButtons with FPages. The rest is self-explantory what this is :P

FImage - An image component.

// Work in progress - FDialog , FColumn and FColumnSet are quite usuable but might still change over time.
FDialog, FWindow, FColumn, FColumnSet, FScrollPage

Testing
=====
There will come a time that you will need to fix the positions of your components with visual help, this can be done if you build Forms in debug mode.

Make a shortcut to your game if you haven't got one yet. Then add the following arguments: 

-debug and -wxwindows.

Launch your game through that shortcut, and hit Alt+Enter to go into windowed mode. 
And hold Shift and CTRL, then click on a component you wish to modify; This will popup a dialog with every available variable as defined in the UnrealScript classes. When you are done you may copy those settings and apply them to your code if you are happy with the new values. Of course you do the trial and error way but sometimes it's a good idea to get first the idea of position, size units before doing this all out of your head!

About
=====
Home: http://eliotvu.com/portfolio/view/48/forms-udk-gui-framework
Forums: http://eliotvu.com/forum/forumdisplay.php?fid=11

License
=====
Copyright 2012-2013 Eliot van Uytfanghe

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
