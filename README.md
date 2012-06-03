Forms
=====
Forms is a very easy to use Game User Interface framework.
This frameworks delivers you all of the most common controls you will ever need in your game's menu.

Installing Forms
=====
Download forms using the "Zip" button on this.

Extract the Zip file content into /Development/Src/Forms/.
Extract the DefaultForms.ini to your /Config/ folder and the FormsPlayerController into your project.

Add Forms to ModEditPackages in DefaultEngine.ini.


(OPTIONAL)Change the extension of the forms controller to what you like, 
but beware this should not extend your PlayerController but one of the engine, 
then change your PlayerController extension to this FormsPlayerController, 
or simply copy paste all the code of the FormsPlayerController into yours if you wish to.

Build your project, if you get any errors, make sure you followed the instructions right, or if else report the issue!

Once installed, start by making your first menu: http://github.com/EliotVU/Forms/wiki/Your-First-Menu

Testing
=====
There will come a time you will need to fix the positions of your components with visual help, this can be done if you build Forms in debug mode.

Make a shortcut to your game if you haven't got one yet. Add the parameter -debug and -wxwindows.

Then launch your game through the shortcut, and hit alt+enter to go windowed mode. 

Hold Shift and CTRL, and click on the component you wish to modify, this will popup a dialog with all the options you wish to edit, when done copy those settings to your code.

About
=====
Home: http://eliotvu.com/portfolio/view/48/forms-udk-gui-framework

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