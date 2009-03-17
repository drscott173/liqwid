﻿/*       *      Copyright 2009 (c) Scott Penberthy, scottpenberthy.com. All Rights Reserved. *       *      This software is distributed under commercial and open source licenses. *      You may use the GPL open source license described below or you may acquire  *      a commercial license from scottpenberthy.com. You agree to be fully bound  *      by the terms of either license. Consult the LICENSE.TXT distributed with  *      this software for full details. *       *      This software is open source; you can redistribute it and/or modify it  *      under the terms of the GNU General Public License as published by the  *      Free Software Foundation; either version 2 of the License, or (at your  *      option) any later version. See the GNU General Public License for more  *      details at: http://scottpenberthy.com/legal/gplLicense.html *       *      This program is distributed WITHOUT ANY WARRANTY; without even the  *      implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  *       *      This GPL license does NOT permit incorporating this software into  *      proprietary programs. If you are unable to comply with the GPL, you must *      acquire a commercial license to use this software. Commercial licenses  *      for this software and support services are available by contacting *      scott.penberthy@gmail.com. * */ package com.jsp.calculator {		//	// Operations for our stack machine	//		public class Op {		public static const PUSH:uint		=0;		public static const CALL1:uint 		=1;		public static const CALL2:uint		=2;		public static const CALL3:uint		=3;		public static const LOOKUP:uint		=4;		public static const STORE:uint		=5;				public var val:Number;		public var token:Number;		public var code:uint;				public function Op(opcode:uint, opToken:Number, opVal:Number = -1) {			token = opToken;			code = opcode;			val = opVal;		}				public function toString():String {			var output:String = "";			var name:String = (token == -1) ? 'none' : Token.t2s[token];			switch (code) {				case PUSH:		output = "PUSH "+val; break;				case CALL1:		output = "CALL1 "+name; break;				case CALL2:		output = "CALL2 "+name; break;				case CALL3:		output = "CALL3 "+name; break;				case LOOKUP:	output = "LOOKUP "+name; break;				case STORE:		output = "STORE "+name; break;			}		//	output += " ("+code+" "+token+(val == -1 ? ')' : " "+val+")");			return output;		}	}}