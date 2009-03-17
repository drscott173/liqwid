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
	import flash.display.Sprite;
	
	//
	// A set of charts that we display in a stack
	//

	public class ChartSet extends Sprite
	{
		private var _charts:Array;
		private var _size:Number;
		private var _names:Array;
		private var _w:Number;
		private var _h:Number;
		
		private static var OFFSET:Number = 40;
		
		public function ChartSet(names:Array, width:Number=400, height:Number=100)
		{
			super();
			_names = names;
			_size = names.length;
			_w = width;
			_h = height;
			init();
		}
		
		private function init():void {
			_charts = new Array(_size);
			for (var i:int=0; i < _size; i++) {
				var c:Chart = new Chart(_names[i],_w,_h);
				c.y = i*(_h+OFFSET);
				_charts[i] = c;
				addChild(c);	
			}
		}
		
		public function sample(values:Array):void {
			var len:Number = Math.min(_size,values.length);
			for (var i:int=0; i < len; i++) {
				var c:Chart = _charts[i];
				if (values[i] is Array) {
					c.plot(values[i]);
				}
				else {
					c.track(values[i]);
				}
			}
		}
		
		public function plot():void {
			for (var i:int=0; i < _size; i++) {
				var c:Chart = _charts[i];
				c.plot();
			}
		}
		
		// TODO maybe add functions for adding, deleting particular names we track?
		
	}
}