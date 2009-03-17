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
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;

	public class EdgeWipe extends SmpteWipe
	{

		public function EdgeWipe(config:Object)
		{
			_default = 1;
			super(config);  
		}
		
		override public function chooseEffect(smpte:Number):void {
			switch (smpte) {
				case 1:					_wipeFn = leftToRight; break;
				case 2:					_wipeFn = topToBottom; break;
				case 3:					_wipeFn = topLeft; break;
				case 4:					_wipeFn = topRight; break;
				case 5:					_wipeFn = bottomRight; break;
				case 6:					_wipeFn = bottomLeft; break;
				
				case 23:				_wipeFn = topCenter; break;
				case 24:				_wipeFn = rightCenter; break;
				case 25:				_wipeFn = bottomCenter; break;
				case 26:				_wipeFn = leftCenter; break;
				
				case 7:					_wipeFn = cornersIn; break;
				
				case 21:				_wipeFn = vertical; break;
				case 22:				_wipeFn = horizontal; break;
				case 45:				_wipeFn = diagonalBottomLeft; break;
				case 46:				_wipeFn = diagonalTopLeft; break;
				case 41:				_wipeFn = topLeftCorner; break;
				case 42:				_wipeFn = topRightCorner; break;
				
				case 43:				_wipeFn = verticalBowtie; break;
				case 44:				_wipeFn = horizontalBowtie; break;
				
				case 61:				_wipeFn = downV; break;
				case 62:				_wipeFn = leftV; break;
				case 63:				_wipeFn = upV; break;
				case 64:				_wipeFn = rightV; break;		
				
				
				default:				_wipeFn = leftToRight; break;
			}
		}
		
		//
		// Effects
		//
				
		private function leftToRight():void {
			box(0, 0, _p, 1);
		}
		
		private function topToBottom():void {
			box(0, 0, 1, _p);
		}
		
		private function topLeft():void {
			box(0, 0, _p, _p);
		}
		
		private function topRight():void {
			box(1-_p, 0, _p, _p);
		}
		
		private function bottomRight():void {
			box(1-_p, 1-_p, _p, _p);
		}
		
		private function bottomLeft():void {
			box(0, 1-_p, _p, _p);
		}
		
		private function topCenter():void {
			box(0.5*(1-_p), 0, _p, _p);
		}
		
		private function rightCenter():void {
			box(1-_p, 0.5*(1-_p), _p, _p);
		}
		
		private function bottomCenter():void {
			box(0.5*(1-_p), 1-_p, _p, _p);
		}
		
		private function leftCenter():void {
			box(0, 0.5*(1-_p), _p, _p);
		}
		
		private function cornersIn():void {
			_p *= 0.5;
			topLeft();
			topRight();
			bottomLeft();
			bottomRight();
		}
		
		//
		// "barnDoorWipe"
		//
		
		private function vertical():void {
			box(0.5*(1-_p), 0, _p, 1);
		}
		
		private function horizontal():void {
			box(0, 0.5*(1-_p), 1, _p);
		}
		
		private function diagonalBottomLeft():void {
			uv(1-_p,0);
			uvTo(1,0);
			uvTo(1,_p);
			uvTo(_p,1);
			uvTo(0,1);
			uvTo(0,1-_p);
			uvTo(1-_p,0);
		}
		
		private function diagonalTopLeft():void {
			uv(0,0);
			uvTo(_p,0);
			uvTo(1,1-_p);
			uvTo(1,1);
			uvTo(1-_p,1);
			uvTo(0,_p);
			uvTo(0,0);
		}
		
		//
		// "diagonalWipe"
		//
		
		private function topLeftCorner():void {
			var p1:Number;
			
			if (_p <= 0.5) {
				p1 = 2*_p;
				uv(0,0);
				uvTo(p1,0);
				uvTo(0,p1);
				uvTo(0,0);
			}
			else {
				p1 = 2*(_p - 0.5);

				uv(0,0);
				uvTo(1,0);
				uvTo(1,p1);
				uvTo(p1,1);
				uvTo(0,1);
				uvTo(0,0);
			}
		}
		
		private function topRightCorner():void {
			var p1:Number = 2*Math.min(_p, 0.5);
			
			if (_p <= 0.5) {
				p1 = 2*_p;
				uv(1-p1,0);
				uvTo(1,0);
				uvTo(1,p1);
				uvTo(1-p1,0);
			}
			else {
				p1 = 2*(_p - 0.5);
				uv(0,p1);
				uvTo(0,0);
				uvTo(1,0);
				uvTo(1,1);
				uvTo(1-p1, 1);
				uvTo(0,p1);
			}
			
		}
		
		//
		// "bowTieWipe"
		//
		
		private function verticalBowtie():void {
			uv(0,0);
			uvTo(1,0);
			uvTo(0.5,_p);
			uvTo(0,0);
			
			uv(0,1);
			uvTo(1,1);
			uvTo(0.5,(1-_p));
			uvTo(0,1);
		}
		
		private function horizontalBowtie():void {
			uv(0,0);
			uvTo(_p,0.5)
			uvTo(0,1);
			uvTo(0,0);
			
			uv(1,0);
			uvTo(1-_p,0.5);
			uvTo(1,1);
			uvTo(1,0);
		}
		
		//
		// "miscDiagonalWipe"
		//
		
		private function doubleBarnDoor():void {
			diagonalBottomLeft();
			diagonalTopLeft();		
		}
		
		//
		// "veeWipe"
		//
		
		private var _theta:Number;
		private var _dy:Number;
		private var _dx:Number;
		
		private function prepareV():void {
			_theta = Math.atan2(0.5*_w,_h);
			_dy = 2*_p;
			_dx = _dy*Math.tan(_theta)*(_h/_w);
		}
		
		private function prepareVflipped():void {
			_theta = Math.atan2(0.5*_h,_w);
			_dy = 2*_p;
			_dx = _dy*Math.tan(_theta)*(_w/_h);
		}
		 
		private function downV():void {
			prepareV();
			uv(0.5,_dy);
			uvTo(0.5-_dx,0);
			uvTo(0.5+_dx,0);
			uvTo(0.5,_dy);
		}
		
		private function upV():void {
			prepareV();
			uv(0.5,1-_dy);
			uvTo(0.5+_dx,1);
			uvTo(0.5-_dx,1);
			uvTo(0.5,1-_dy);
		}
		
		private function leftV():void {
			prepareV();
			uv(1-_dy,0.5);
			uvTo(1,0.5-_dx);
			uvTo(1,0.5+_dx);
			uvTo(1-_dy,0.5);
		}
		
		private function rightV():void {
			prepareVflipped();
			uv(_dy,0.5);
			uvTo(0,0.5-_dx);
			uvTo(0,0.5+_dx);
			uvTo(_dy,0.5);
		}
		
	}
}