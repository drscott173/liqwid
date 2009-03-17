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


package com.jsp.graphics {
	
	import flash.display.*;
	import flash.text.*;
	
	public class Text extends Sprite {
		
		private var _config:Object;
		private var _display:Sprite;
		private var _string:String;
		private var _color:uint;
		private var _fontSize:uint;
		private var _font:String;
		private var _bold:Boolean;
		private var _align:String;
		private var _w:Number;
		private var _adjustFont:Boolean = false;
		private var _useHTML:Boolean = false;
		
		public static var ALIGN_LEFT:String = "left";
		public static var ALIGN_RIGHT:String = "right";
		public static var ALIGN_CENTER:String = "center";
		
		private static var FONT:String = 'Arial';
		private static var COLOR:uint = 0xffffff;
		private static var FONT_SIZE:Number = 14;
		
		public function Text(config:Object):void {
			_config = config;
			readConfig();
			init();
		}
		
		public function setWidth(w:Number):void {
			_w = w;
			align();
		}
		
		private function align():void {
			if (_adjustFont) adjustFontSize();

			var w1:Number = _display.width;
			switch (_align) {
				case ALIGN_CENTER:
					_display.x = (_w - w1)*0.5;
					break;
					
				case ALIGN_RIGHT:
					_display.x = (_w - w1);
					break;
					
				case ALIGN_LEFT:
				default:
					_display.x = 0;
					break;
			}

			//trace("Aligned text to "+_display.x);
		}
		
		private function adjustFontSize():void {
			var scale:Number = 1.0;
			_display.scaleX = _display.scaleY = 1.0;
			if (_display.width > _w) {
				trace("scale width="+_display.width+" _w="+_w);
				scale = (_w - 20) / _display.width;
				if (scale < 0 || scale > 1) return;
			}
			_display.scaleX = _display.scaleY = scale;
		}
				
		private function readConfig():void {
			_string = 	_config.text;
			_font =		_config.font || FONT;
			_color = 	(_config.color == null) ? COLOR : _config.color;
			_fontSize = _config.size || FONT_SIZE;
			_bold =		_config.bold ? true : false;
			_align =	_config.align || ALIGN_LEFT;
			_w =		_config.width || 400;
			_adjustFont = _config.fit || false;
			_useHTML = _config.useHTML || false;
		}
		
		private var _format:TextFormat;
		private var _field:TextField;
		
		protected function init():void {
			// Create the inner workings of text on the screen
			var s:Sprite = new Sprite();
			var format:TextFormat = new TextFormat();
			var field:TextField = new TextField();
			var ts:String = _string;
			var metrics:TextLineMetrics;
			
			format.font = _font;
			format.color = _color;
			format.size = _fontSize;
			format.bold = _bold;
			
			field.antiAliasType = flash.text.AntiAliasType.ADVANCED;
		//	field.embedFonts = true;
			field.defaultTextFormat = format;
			field.selectable = false;
			
			if (_useHTML) {
				field.htmlText = ts;
				field.multiline = true;
			}
			else {
				field.text = ts;
			}
			
			metrics = field.getLineMetrics(0);
			field.width = metrics.width + _fontSize;
			field.height = metrics.height;
			
			s.addChild(field);
			_display = s;
			_format = format;
			_field = field;
			
			addChild(_display);
			//trace("Text field has width "+_display.width);
			align();
		}
		
		public function set text(val:String):void {
			var metrics:TextLineMetrics;
			
			_string = val;
			
			if (_useHTML) {
				_field.htmlText = _string;
			}
			else {
				_field.text = _string;
			}
			_field.defaultTextFormat = _format;
			metrics = _field.getLineMetrics(0);
			_field.width = metrics.width + 0.5*_fontSize;
			_field.height = 1.1*metrics.height;
			
			align();
		}
		
	}
}
