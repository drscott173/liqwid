/*      
 *      Copyright 2009 (c) Scott Penberthy, scottpenberthy.com. All Rights Reserved.
 *      
 *      This software is distributed under commercial and open source licenses.
 *      You may use the GPL open source license described below or you may acquire 
 *      a commercial license from scottpenberthy.com. You agree to be fully bound 
 *      by the terms of either license. Consult the LICENSE.TXT distributed with 
 *      this software for full details.
 *      
 *      This software is open source; you can redistribute it and/or modify it 
 *      under the terms of the GNU General Public License as published by the 
 *      Free Software Foundation; either version 2 of the License, or (at your 
 *      option) any later version. See the GNU General Public License for more 
 *      details at: http://scottpenberthy.com/legal/gplLicense.html
 *      
 *      This program is distributed WITHOUT ANY WARRANTY; without even the 
 *      implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 *      
 *      This GPL license does NOT permit incorporating this software into 
 *      proprietary programs. If you are unable to comply with the GPL, you must
 *      acquire a commercial license to use this software. Commercial licenses 
 *      for this software and support services are available by contacting
 *      scott.penberthy@gmail.com.
 *
 */

package com.jsp.graphics
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	public class IrisWipe extends SmpteWipe
	{
		private var _rot:Number;	   // how much to rotate this iris
		private var _uvPath:Array;
		private var _iris:Sprite;
		private var _irisFn:Function;
		private var _code:Number;
		
		public function IrisWipe(config:Object)
		{
			_default = 101;
			_code = -1;
			super(config);
		}

		override public function chooseEffect(smpte:Number):void {
			switch (smpte) {
				case 101:				_irisFn = rectangle; break;
				case 102:				_irisFn = diamond; break;
				case 103:				_irisFn = triangleUp; break;
				case 104:				_irisFn = triangleRight; break;
				case 105:				_irisFn = triangleDown; break;
				case 106:				_irisFn = triangleLeft; break;
				
				default:				rectangle(); break;
			}
			_wipeFn = doIris;
		}
		
		protected function doIris():void {
			newPath();
			_irisFn();
			buildIris();
		}
		
		private function newPath():void {
			_uvPath = new Array();
		}
		
		private function iuv(u:Number, v:Number):void {
			//
			// Start a new subpath at (u,v);
			//
			var path:Array = new Array();
			path.push({u: u, v: v});
			_uvPath.unshift(path);
		}
		
		private function iuvTo(u:Number, v:Number):void {
			var path:Array = _uvPath[0];
			path.push({u: u, v: v});
		}

		private function iSpin(theta:Number):void {
			// spin the uvPath about the center (0.5,0.5)
			var cos_rot:Number = Math.cos(theta);
			var sin_rot:Number = Math.sin(theta);
			for (var n:int=_uvPath.length-1; n >= 0; n--) {
				var path:Array = _uvPath[n];
				for (var i:int=path.length-1; i >=0; i--) {
					var u2:Number = path[i].u - 0.5;
					var v2:Number = path[i].v - 0.5;
					
					path[i].u = u2*cos_rot - v2*sin_rot + 0.5;
					path[i].v = u2*sin_rot + v2*cos_rot + 0.5;
				}
			}
		}
		
		private function buildIris():void {
			var g:Graphics = _mask.graphics;
			g.clear();
			g.beginFill(0xffffff);
			for (var n:int=_uvPath.length-1; n >= 0; n--) {
				var path:Array = _uvPath[n];
				var len:Number = path.length;
				var u:Number = path[i].u;
				var v:Number = path[i].v;
			
				g.moveTo(u*_w, v*_h);
			
				for (var i:int=1; i < len; i++) {
					u = path[i].u;
					v = path[i].v;
					g.lineTo(u*_w, v*_h);
				}
			}
			g.endFill();
		}
		
		override protected function box(u:Number, v:Number, w:Number, h:Number):void {
			iuv(u,v);	
			iuvTo(u+w, v);
			iuvTo(u+w,v+h);
			iuvTo(u, v+h);
			iuvTo(u,v);
		}
		
		private function rectangle():void {
			var p1:Number = 0.5 - 0.5*_p;
			box(p1,p1,_p,_p);
		}
		
		private function diamond():void {
			_p *= 1.5;
			rectangle();
			iSpin(Math.PI*0.25);
		}
		
		//
		// Triangles
		//
		
		private function triangleUp():void {
			var dtheta:Number = 2*Math.PI/3;
			var ang:Number = Math.PI/2;
			var k:Number = _p*1.5;
			var u:Number = 0.5 - k*Math.cos(ang);
			var v:Number = 0.5 - k*Math.sin(ang);
			
			iuv(u,v);
			for (var i:int=0; i < 3; i++) {
				ang += dtheta;
				u = 0.5 - k*Math.cos(ang);
				v = 0.5 - k*Math.sin(ang);
				iuvTo(u,v);
			}
		}
		
		private function triangleRight():void {
			triangleUp();
			iSpin(Math.PI/6);
		}
		
		private function triangleDown():void {
			triangleUp();
			iSpin(Math.PI);
		}
		
		private function triangleLeft():void {
			triangleUp();
			iSpin(-Math.PI/6);
		}
		
		//
		// 
	}
}