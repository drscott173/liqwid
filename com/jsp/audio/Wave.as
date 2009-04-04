﻿/*       *      Copyright 2009 (c) Scott Penberthy, scottpenberthy.com. All Rights Reserved. *       *      This software is distributed under commercial and open source licenses. *      You may use the GPL open source license described below or you may acquire  *      a commercial license from scottpenberthy.com. You agree to be fully bound  *      by the terms of either license. Consult the LICENSE.TXT distributed with  *      this software for full details. *       *      This software is open source; you can redistribute it and/or modify it  *      under the terms of the GNU General Public License as published by the  *      Free Software Foundation; either version 2 of the License, or (at your  *      option) any later version. See the GNU General Public License for more  *      details at: http://scottpenberthy.com/legal/gplLicense.html *       *      This program is distributed WITHOUT ANY WARRANTY; without even the  *      implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  *       *      This GPL license does NOT permit incorporating this software into  *      proprietary programs. If you are unable to comply with the GPL, you must *      acquire a commercial license to use this software. Commercial licenses  *      for this software and support services are available by contacting *      scott.penberthy@gmail.com. * */package com.jsp.audio{	import com.jsp.graphics.Path;	import com.jsp.graphics.uvSprite;		import flash.filters.BlurFilter;	import flash.filters.GlowFilter;	public class Wave extends uvSprite	{		public var r:Number;							// red component, 0-1		public var g:Number;							// green component, 0-1		public var b:Number;							// blue component, 0-1		public var a:Number;							// alpha component, 0-1		public var thick:Number;						// thickness		public var solid:Boolean = false;				// true if this is solid, e.g filled		public var dots:Boolean = false;				// true if we plot the edge as dots		public var blur:Number;							// amount of blur, 0-1		public var glow:Number;							// amount of glow, 0-1		public var scale:Number;		public var gr:Number;							// glow red component, 0-1		public var gg:Number;							// glow green component, 0-1		public var gb:Number;							// glow blue component, 0-1		public var ga:Number;							// glow alpha, 0-1		public var brightColors:Boolean = true;				private var _left:Path;		private var _right:Path;		private var _leftData:Array;		private var _rightData:Array;				       				private var _edgeX:Array = new Array(2);		// edges for rotated waves		private var _edgeY:Array = new Array(2);				private var _nVerts:Number;  					// the number of vertices in our waveform		private var _v:Array;							// raw data for waveform		private var _v1:Array;							// raw data for a second waveform				private var _u0:Number;							// location of wave in (u,v)		private var _v0:Number;		private var _mystery:Number;					// a mystery number to tweak wave properties		private var _mode:uint;							// current wave mode		private var _progress:Number;					// how far along we are in this preset animation				private var _bass:Number;						// relative sound levels in bass, mid-range and treble		private var _mid:Number;		private var _treb:Number				private var _blurFilter:BlurFilter = new BlurFilter(4,4,1);		private var _filters:Array;				private var _glowFilter:GlowFilter = new GlowFilter();			public static const NSAMPLES:Number = 256;				public static const CIRCLE:uint 			= 0;		public static const XY_OSCILLATOR:uint 		= 1;		public static const NEBULA:uint 			= 2;		public static const SPIRO:uint 				= 3;		public static const MILKDROP_4:uint 		= 4;		public static const EXPLOSIVE:uint 			= 5;		public static const MILKDROP_6:uint			= 6;		public static const MILKDROP_7:uint			= 7;		public static const MILKDROP_8:uint			= 8;				public function Wave(width:Number = 1, height:Number = 1)		{			super(width,height);			_filters = [_blurFilter,_glowFilter];			init();					}				private function init():void {			_aspect = _w/_h;			_left = new Path(NSAMPLES,_w,_h);			_right = new Path(NSAMPLES,_w,_h);			_mystery = 0;			_progress = 0;			_u0 = _v0 = 0.5;			_bass = _mid = _treb = 0.5;			scale = 0.8;			_nVerts = NSAMPLES;			_leftData = new Array(NSAMPLES);			_rightData = new Array(NSAMPLES);			_v = new Array(NSAMPLES);			_v1 = new Array(NSAMPLES);			zero(_leftData);			zero(_rightData);			zero(_v);			zero(_v1);			r = g = b = a = 1.0;			gr = gg = gb = ga = 0.0;			blur = 0;			glow = 0;			thick = 1;			addChild(_left);			addChild(_right);		}				public function setLevels(bass:Number, midRange:Number, treble:Number):void {			_bass = bass;			_mid = midRange;			_treb = treble;		}				public function set mode(mode:uint):void {			_mode = mode;		}				public function get mode():uint {			return _mode;		}				public function set mystery(n:Number):void {			_mystery = n;		}				public function uv(u:Number, v:Number):void {			_u0 = u;			_v0 = v;			//checkUVRange();		}				private function checkUVRange():void {			if ((_u0 < 0) || (_u0 > 1) || (_v0 < 0) || (_v0 > 1)) {				trace("WAVE range error: ("+_u0.toFixed(4)+","+_v0.toFixed(4)+")");			}		}				public function get u():Number {			return _u0;		}				public function get v():Number {			return _v0;		}				public function set progress(p:Number):void {			//if (p < 0) p = 0;			//if (p > 1) p = 1;			_progress = p;		}				override protected function afterResize():void {			_left.setSize(_w,_h);			_right.setSize(_w,_h);			_aspect = _w/_h;		}				private function rangeCheck(val:Number, lo:Number, hi:Number, name:String):Number {			if ((val < lo) || (val > hi)) {				trace("wave range check: "+name+"="+val);				if (val < lo) val = lo;				if (val > hi) val = hi;			}			return val;		}				public function setColor(r:Number, g:Number, b:Number, a:Number):void {			if (brightColors) {				var max:Number = r;				if (g > max) max=g;				if (b > max) max=b;				max = (max == 0) ? 1.0 : 1/max;				r *= max;				g *= max;				b *= max;			}			this.r = r;			this.g = g;			this.b = b;			this.a = a;			/** for debugging purposes only 			rangeCheck(r,0,1,'red');			rangeCheck(g,0,1,'green');			rangeCheck(b,0,1,'blue');			rangeCheck(a,0,1,'alpha');			**/		}				public function setGlow(intensity:Number=0.25,red:Number=1, green:Number=1, blue:Number=1, alpha:Number=0.5):void {			glow = intensity;			gr = red;			gg = green;			gb = blue;			ga = alpha;		}				private function zero(a:Array):void {			var len:Number = a.length;			for (var i:uint=0; i < len; i++) a[i] = 0;		}				public function sampleLeft(data:Array):void {			var len:Number = data ? data.length : 0;			if (len == 0) {				zero(_leftData);				return;			}			doSample(data,len,_leftData);		}				public function sampleRight(data:Array):void {			var len:Number = data ? data.length : 0;			if (len == 0) {				zero(_rightData);				return;			}			doSample(data,len,_rightData);		}				private function doSample(source:Array, len:Number, dest:Array):void {			var stride:Number = NSAMPLES/len;			if (stride == 1) {				for (var index:uint=0; index < NSAMPLES; index++) dest[index]=source[index];			}			else {				var k:uint = Math.floor(stride);				for (var i:Number=0; i < NSAMPLES; i += stride) {					var avg:Number = 0;					var first:uint = Math.floor(i);					var last:uint = Math.floor(i + stride);					if (k < 1) {						dest[i] = source[first];					}					else {						for (var j:uint=first; j < last; j++) {							avg += source[j];						}						dest[i] = avg/k;					}				}			}		}				//		// Main interface		//				public function sample(left:Array, right:Array, mode:uint = CIRCLE):void {			_leftData = left;			_rightData = right;			_mode = mode;			_left.thick = _right.thick = thick;			_left.r = _right.r = r;			_left.g = _right.g = g;			_left.b = _right.b = b;			_left.a = _right.a = alphatize(a);			update();		}				private function update():void {			_nVerts = NSAMPLES;			//			// TODO should this be an array instead?			//						switch (_mode) {				case CIRCLE:								circle(); 					break;				case XY_OSCILLATOR:							xyOscillator(); 					break;				case NEBULA:						nebula(); 					break;				case SPIRO:					spiro();					break;				case MILKDROP_4:					milkdrop4();					break;				case EXPLOSIVE:					thingy();					break;				case MILKDROP_6:				case MILKDROP_7:				case MILKDROP_8:					angleWave();					break;								default:									circle(); 					break;			}			doEffects();		}				private function doEffects():void {			if (blur > 0) {				_blurFilter.blurX = blur*50;				_blurFilter.blurY = blur*50;				_left.filters = _filters;				_right.filters = _filters;			}			if (glow > 0 && ga >= 0.1) {				_glowFilter.blurX = glow*50;				_glowFilter.blurY = glow*50;				_glowFilter.alpha = ga;				_glowFilter.color = makeColor(gr,gg,gb,0);				_left.filters = _filters;				_right.filters = _filters;			}		}						//		// Wave modes		//		private function circle():void {			_nVerts = NSAMPLES/2;			var inv_nverts_minus_one:Number = 1.0/(_nVerts-1);			var early:Number = _nVerts/10;			var offset:uint = (NSAMPLES - _nVerts)/2;			var rad:Number;			var ang:Number;			var mix:Number;			var rad2:Number;			var vx:Number;			var vy:Number;			var ia:Number = 1/_aspect;						_left.visible = true;			_right.visible = false;						for (var i:uint=0; i < _nVerts; i++) {				rad = 0.5 + 0.4*_rightData[i+offset] + _mystery;				ang = i * inv_nverts_minus_one * 6.28  + _progress * 0.2;				if (i < early) {					mix = i/(_nVerts*0.1);					mix = 0.5 - 0.5*Math.cos(mix*3.1416);					rad2 = 0.5 + 0.4*_rightData[i+_nVerts+offset] + _mystery;					rad = rad2*(1-mix) + rad*(mix);				}				vx = scale*rad*Math.cos(ang)*ia + _u0; // used to have *_aspect here				vy = scale*rad*Math.sin(ang) + _v0;				_left.setUV(i,vx,vy);			}			_left.copyUV(_nVerts-1, 0);			_left.render(_nVerts, solid, dots);			//_left.uvPlot(_v, _nVerts);		}						private function xyOscillator():void {			_nVerts = _nVerts/2;			_left.visible = true;			_right.visible = false;			var ia:Number = 1/_aspect;						for (var i:int=0; i < _nVerts; i++) {				// milkdrop used 0.53 + 0.43, but it kept going off the screen				var rad:Number = 0.33 + 0.23*_rightData[i] + _mystery;				var ang:Number = _leftData[i+16]*1.57 + _progress*2.3;				var vx:Number = rad*Math.cos(ang)*ia + _u0;				var vy:Number = rad*Math.sin(ang) + _v0;				_left.setUV(i,vx,vy);			}			_left.render(_nVerts, solid, dots);		}				private function nebula():void {			// A nebula-like wisp			var ia:Number = 1/_aspect;						_left.visible = true;			_right.visible = false;			_left.a *= 0.11;			for (var i:uint=0; i < _nVerts; i++) {				var vx:Number = _rightData[i]*ia + _u0;				var vy:Number = _leftData[(i+32)%_nVerts] + _v0;				_left.setUV(i,vx,vy);			}			_left.render(_nVerts, solid, dots);		}		private function spiro():void {			// a centered spiro, aimed at having a strong audio-visual tie-in			// where colors are always bright			_left.visible = true;			_right.visible = false;						var alpha:Number = 0.3 * ((_treb <= 0) ? 1 : Math.pow(_treb, 2.0));			var ia:Number = 1/_aspect;			if (alpha < 0) alpha = 0;			if (alpha > 1) alpha = 1;			_left.a = alphatize(alpha);			 			for (var i:uint = 0; i < _nVerts; i++) {				var vx:Number = _rightData[i]*ia + _u0;				var vy:Number = _leftData[(i+32)%_nVerts] + _v0;				_left.setUV(i,vx,vy);			}			_left.render(_nVerts, solid, dots);		}       private function milkdrop4():void {       		// a horizontal "script", whatever that is       		_left.visible = true;       		_right.visible = false;       		          	_nVerts = _nVerts/2;          	var w1:Number = 0.45 + 0.5*(_mystery*0.5 + 0.5);          	var w2:Number = 1.0 - w1;          	var inv_nverts:Number = 1.0/_nVerts;          	var offset:Number = _nVerts;          	var vx0:Number = 0, vy0:Number = 0;          	var vx1:Number, vy1:Number;          	          	for (var i:int=0; i < _nVerts; i++) {          		var vx:Number = -1.0 + 2.0*i*inv_nverts + _u0;          		var vy:Number = _leftData[(i+offset)%_nVerts]*0.47 + _v0;          		vx += _rightData[(i+25+offset)%_nVerts]*0.44;          		if (i > 1) {          			vx = vx*w2 + w1*(vx1*2 - vx0);          			vy = vy*w2 + w1*(vy1*2 - vy0);           		}          		if (vx > 1) {          			vx = vx*1;          		}          		vx0 = vx1;          		vy0 = vy1;          		vx1 = vx;          		vy1 = vy;              		_left.setUV(i,vx,vy);          	}          	_left.render(_nVerts, solid, dots);       }              private function thingy():void {       	// a weird, complex thingy (milkdrop #5)       	var alpha:Number = a * 0.11;       	var cos_rot:Number = Math.cos(_progress*0.3);       	var sin_rot:Number = Math.sin(_progress*0.3);		var ia:Number = 1/_aspect;       	       	_left.a = alphatize(alpha);       	_left.visible = true;       	       	for (var i:int=0; i < _nVerts; i++) {       		var i32:Number = (i+16)%_nVerts;       		var x0:Number = _rightData[i]*_leftData[i32] +       		                _leftData[i]*_rightData[i32];       		var y0:Number = _rightData[i]*_rightData[i] -        		                _leftData[i32]*_rightData[i32];       		var vx:Number = (x0*cos_rot - y0*sin_rot)*ia + _u0;       		var vy:Number = (x0*sin_rot + y0*cos_rot) + _v0;       		_left.setUV(i,vx,vy);       	}       	_left.render(_nVerts,solid,dots);       }		private function angleWave():void {			// a port of milkdrop's angle-adjustable left channel wave 6			// waveParam sets the angle, a multiple of pi/2			//			var ang:Number = _mystery * 1.57;	        var ang2:Number;			var perp_dx:Number, perp_dy:Number;			var dx:Number = Math.cos(ang);			var dy:Number = Math.sin(ang);			var i:int, f:Number, qdx:Number, qdy:Number;			var vx:Number, vy:Number;			var sep:Number = 0;			var iSamples:Number = 1/NSAMPLES;						_edgeX[0]= _u0 * Math.cos(ang + 1.57) - dx*3;			_edgeY[0]= _u0 * Math.sin(ang + 1.57) - dy*3;			_edgeX[1]= _u0 * Math.cos(ang + 1.57) + dx*3;			_edgeY[1]= _u0 * Math.sin(ang + 1.57) + dy*3;						clipEdges();			dx = (_edgeX[1] - _edgeX[0]) * iSamples; 			dy = (_edgeY[1] - _edgeY[0]) * iSamples; 			ang2 = Math.atan2(dy,dx);			perp_dx = Math.cos(ang2 + 1.57);			perp_dy = Math.sin(ang + 1.57);			sep = (_mode == 7) ? Math.pow(_v0*0.5 + 0.2, 2) : 0;  // was +0.5						if ((_mode == 6) || (_mode == 7)) {				qdx = perp_dx * 0.25;				qdy = perp_dy * 0.25;			  for(i=0; i < NSAMPLES; i++) {				  vx = _edgeX[0] + dx*i + qdx*_leftData[i] + perp_dx*sep;				  vy = _edgeY[0] + dy*i + qdy*_leftData[i] + perp_dy*sep;				  _left.setUV(i,vx,vy);				  //trace("Angle_"+i+" xy ("+V1[i].x+","+V1[i].y+")");			  }			}			else if (_mode == 8) {				for (i=0; i < NSAMPLES; i++) {					var left:Number  = _leftData[i] + _leftData[i+1];					f = 0.1 * Math.log(left);					if (isNaN(f)) f = 0.1;				    vx = _edgeX[0] + dx*i + perp_dx*f ;				    vy = _edgeY[0] + dy*i + perp_dy*f;				    _left.setUV(i,vx,vy);				}			}			if (_mode == 7) {				_right.visible = true;				for (i=0; i < NSAMPLES; i++) {					vx = _edgeX[0] + dx*i + qdx*_rightData[i] - perp_dx*sep;				    vy = _edgeY[0] + dy*i + qdy*_rightData[i] - perp_dy*sep;				    _right.setUV(i,vx,vy);				}			}			_left.render(_nVerts,solid,dots);			if (_mode == 7) _right.render(_nVerts,solid,dots);		}				private function clipEdges():void {			var t:Number, dx:Number, dy:Number;			// now clip the edge (x0,y0) -> (x1,y1) against all four sides			var d:Number;			for (var i:int=0; i<2; i++) {				for (var j:int=0; j<4; j++) {					var bclip:Boolean = false;					switch (j) {						case 0: 						if (_edgeX[i] > 1.1) {							d = (_edgeX[i] - _edgeX[1-i]);							t = (d == 0) ? 1 : (1.1 - _edgeX[1-i]) / d;							bclip = true;						}						break;												case 1:						if (_edgeX[i] < -1.1) {							d = (_edgeX[i] - _edgeX[1-i]);							t = (d == 0) ? 1 : (-1.1 - _edgeX[1-i]) / d;							bclip = true;						}						break;											case 2: 						if (_edgeY[i] > 1.1) {							d = (_edgeY[i] - _edgeY[1-i]);							t = (d == 0) ? 1 : (1.1 - _edgeY[1-i]) / d;							bclip = true;						}						break;												case 3:						if (_edgeY[i] < -1.1) {							d = (_edgeY[i] - _edgeY[1-i]);							t = (d == 0) ? 1 : (-1.1 - _edgeY[1-i]) / d;							bclip = true;						}						break;					}										if (bclip) {						dx = _edgeX[i] - _edgeX[1-i];						dy = _edgeY[i] - _edgeY[1-i];						if (dx == 0) {							// t could be NaN							_edgeX[i] = _edgeX[1-i];						}						else {						 _edgeX[i] = _edgeX[1-i] + dx*t;						}						if (dy == 0) {							// t could be NaN							_edgeY[i] = _edgeY[1-i];						}						else {						  _edgeY[i] = _edgeY[1-i] + dy*t;						}					}				}			}		}		}}