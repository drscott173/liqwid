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
	import flash.display.Sprite;
	
	//
	// A generic class for wipe effects from the Society of Motion Picture and Television Engineers (SMPTE)
	//
	
	public class SmpteWipe extends Wipe
	{
		protected var _wipeFn:Function;  // move to base class?
		protected var _default:int = -1;
		
		public function SmpteWipe(config:Object)
		{
			chooseEffect(config.smpte ? config.smpte : _default);
			super(config);
		}
		
		// make this part of the interface
		public function chooseEffect(smpte:Number):void {
			_wipeFn = rectangle;
		}

		override public function tweenTarget(mask:Sprite, image:Bitmap, percent:Number):void {
			_mask = mask;
			_image = image;
			_p = percent;
			_mask.graphics.beginFill(0xffffff);
			_wipeFn();
			//
			// handle rotation here
			//
			_mask.graphics.endFill();
		}
		
		override public function tweenSource(mask:Sprite, image:Bitmap, percent:Number):void {
			identity(mask, 1.0);
		}
		
		private function rectangle():void {
			var p1:Number = 0.5 - 0.5*_p;
			box(p1,p1,_p,_p);
		}
		
	}
}