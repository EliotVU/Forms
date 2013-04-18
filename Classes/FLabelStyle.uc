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
 * FLabelStyle: Adds configurable styling options for FLabel and anything extending that class.
 * ======================================================== */
class FLabelStyle extends FStyle;

var(Style, Display) config const Color				TextColor;
var(Style, Display) Font							TextFont;
var config string									TextFontName;
var(Style, Display) config const FontRenderInfo		TextRenderInfo;
var(Style, Display) config const Vector2D			TextFontScaling;

function Initialize()
{
	if( TextFontName != "" )
	{
		TextFont = Font(DynamicLoadObject( TextFontName, class'Font', true ));
	}
	super.Initialize();
}

function Free()
{
	super.Free();
	TextFont = none;
}