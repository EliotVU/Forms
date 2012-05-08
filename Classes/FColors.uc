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
class FColors extends Object
	abstract;

var const Color YellowColor;
var const Color GoldColor;
var const Color BlackColor;
var const Color GrayColor;
var const Color DarkColor;
var const Color AlphaColor;

defaultproperties
{
	YellowColor=(R=255,G=255,B=0,A=255)
	GoldColor=(R=255,G=215,B=0,A=255)
	BlackColor=(R=0,G=0,B=0,A=255)
	GrayColor=(R=128,G=128,B=128,A=255)
	DarkColor=(R=64,G=64,B=64,A=0)
	AlphaColor=(A=128)
}