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

//==============STRUCTURES=============
struct atomic Rect
{
	var float X, Y, W, H;
};

struct atomic Boundary
{
	var() float Min, Max;
	var() bool bEnabled;
};

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
			ret $= spacer;
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

const PARSE_NUMERIC = 0;
const PARSE_NAME = 1;

public final static function string Token( string data, out string unparsed, byte parseMode )
{
	local int i, startIdx;
	local array<string> s;
	local string result;

	for( i = 0; i < Len( data ); ++ i )
	{
		s.AddItem( Mid( Left( data, i + 1 ), i ) );
	}

	// Get leading char
	// " 1" = 1
	// " " = ??
	// "1 " = 1
	for( i = 0; i < s.Length; ++ i )
	{
		if( s[i] != " " )
		{
			startIdx = i;
			break;
		}
	}

	switch( parseMode )
	{
		case PARSE_NUMERIC:
			// Parse for numerics
			// [0-9\.]
			for( i = startIdx; i < s.Length; ++ i )
			{
				if( (Asc( s[i] ) >= Asc( "0" ) && Asc( s[i] ) <= Asc( "9" )) || (s[i] == ".") )
				{
					result $= s[i];
					continue;
				}
				break;
			}
			unparsed = Mid( data, i );
			break;

		case PARSE_NAME:
			// Parse for names
			// [a-zA-Z_]
			for( i = startIdx; i < s.Length; ++ i )
			{
				if( (Asc( s[i] ) >= Asc( "a" ) && Asc( s[i] ) <= Asc( "z" )) 
					|| (Asc( s[i] ) >= Asc( "A" ) && Asc( s[i] ) <= Asc( "Z" ))
					|| (s[i] == "_") )
				{
					result $= s[i];
					continue;
				}
				break;
			}
			unparsed = Mid( data, i );
			break;
	}
	return result;
}