Forms
=====
Forms is a graphical user interface(GUI) framework for the Unreal Development Kit(UDK). Purely programmed in UnrealScript independent of Scaleforms and UIScene. 
Inspired by the OOP and subobjects semantics of the Unreal Engine 2 GUIs framework.

This framework will give you most of the common GUI building components of which: 

  Page, Button, Dialog, Tab Control, Label, and many more!

Forms in action:
![Potention](http://cloud.steampowered.com/ugc/540677266034363535/8F08FE0DA245238DDAE1250622ADF9E078294B0E/)
Graphics not included!

Example
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

Installing Forms
=====
Read this short tutorial on installing forms: http://github.com/EliotVU/Forms/wiki/Installing-Forms
Once installed, start by making your first menu: http://github.com/EliotVU/Forms/wiki/Your-First-Menu

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
