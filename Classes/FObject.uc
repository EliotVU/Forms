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
 * FObject: The base class of all components and styles.
 * ======================================================== */
class FObject extends Object
	hidecategories(Object)
	abstract;

//==============CONSTANTS==============
const Colors = class'FColors';

//==============INTERFACE==============
function Free();
function Render( Canvas C );

//==============METHODS==============
public final static function string SplitArray( array<name> nameArray, string spacer = "-" )
{
	local int i;
	local string ret;

	for( i = 0; i < nameArray.Length; ++ i )
	{
		ret $= nameArray[i];
		if( i != nameArray.Length - 1 )
		{
			ret $= "-";
		}
	}
	return ret;
}

public final static function Vector PointToVect( out IntPoint point )
{
	local Vector v;
	
	v.X = point.X;
	v.Y = point.Y;
	return v;	
}