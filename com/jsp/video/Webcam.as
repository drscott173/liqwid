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

package com.jsp.video
{
	import flash.display.*;
	import flash.events.*;
	import flash.external.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.utils.*;
	

	public class Webcam extends Sprite
	{
		public static const CAM_WIDTH:int = 			320;
		public static const CAM_HEIGHT:int =	 		240;
		public static const CAM_KEYFRAMES:int = 		48;
		public static const CAM_FPS:Number = 			12;
		public static const CAM_QUALITY:int = 			0;
		public static const CAM_BANDWIDTH:int = 		96600;	
		
		private var _cam:Camera;
		private var _vid:Video;
		private var _camSprite:Sprite = null;
		private var _cw2:Number; 
		private var _ch2:Number;
		private var _gotCamera:Boolean = false;
		private var _cams:Array;
		private var _vids:Array;
		private var _raw:BitmapData;
		
		public function Webcam()
		{
			_raw = null;
		}
		
		public function startCamera():void {
			_cam = null;
			var USBCam:String = findUSBCamera();
			_gotCamera = false;
			return;
			
			if (!USBCam) {
				if (!Camera.names.length) return;
				_cam = Camera.getCamera();
			}
			else {
				_cam = Camera.getCamera(USBCam);
			}
			_gotCamera = true;
			_cam.addEventListener(StatusEvent.STATUS, camStatus);
			_vid= new Video();
		    _vid.attachCamera(_cam);  
		}
		
		private function startup():void {
			_camSprite = new Sprite();
			_camSprite.addChild(_vid);
			_cw2 = _camSprite.width * 0.5;
			_ch2 = _camSprite.height * 0.5;
			  
			trace("Camera size is "+_vid.width+"x"+_vid.height);

			setRecordingParameters();
			addChild(_camSprite);
			_raw = new BitmapData(_camSprite.width, _camSprite.height, true, 0x000000);
			dispatchEvent(new Event(Event.COMPLETE, true, false));
			//addListeners();
		}
		
		public function get raw():BitmapData {
			if (_camSprite) _raw.draw(_camSprite);  // snap a photo
			return _raw;
		}
		
		private function setRecordingParameters():void {
			_cam.setKeyFrameInterval(CAM_KEYFRAMES);
			_cam.setQuality(CAM_BANDWIDTH, CAM_QUALITY);
			_cam.setMode(CAM_WIDTH, CAM_HEIGHT, CAM_FPS);
		}
				
		private function showAllCameras():void {
			trace("Current camera is "+Camera.getCamera().name);
			for (var i:uint = 0; i < Camera.names.length; i++) {
				trace("Camera #"+i+" is "+Camera.names[i]);
			}
		}
		
		private function findUSBCamera():String {
			var cam:String = null;
			_cams = new Array();
			_vids = new Array();
			for (var i:uint = 0; i < Camera.names.length; i++) {
				var thisCamera:String = Camera.names[i];
				var iname:String = i + "";
				var obj:Camera = Camera.getCamera(iname);
				var vid:Video = new Video();
				
				vid.attachCamera(obj);
				_cams[i] = {cam: obj, video: vid, name: thisCamera};
				obj.addEventListener(StatusEvent.STATUS, camStatus);
				obj.addEventListener(ActivityEvent.ACTIVITY, cameraMotionHandler);
						
				trace("Found camera "+i+": "+thisCamera);
				//thisCamera.toUpperCase();
				//if (thisCamera.search('USB') >= 0) cam = "" + i;  
			}
			//trace("Found USB Camera: "+cam);
			return cam;
		}
		
		private function cameraMotionHandler(e:ActivityEvent):void {
			var c:Camera = e.target as Camera;
			var i:Number;
			var chosen:Number = -1;
			
			for (i=0; i < Camera.names.length; i++) {
				var info:Object = _cams[i];
				if (info.cam == c) {
					trace("Camera "+info.name+" had activity!  Index="+i);
					chosen = i;
				}
			}
			
			if (chosen > 0) {
				chooseCamera(chosen);
			}
		}
		
		private function chooseCamera(index:Number):void {
			var info:Object = _cams[index];
			
			_vid = info.video;
			_cam = info.cam;
			_cam.removeEventListener(ActivityEvent.ACTIVITY, cameraMotionHandler);
			
			_gotCamera = true;
			_cam.addEventListener(StatusEvent.STATUS, camStatus); 
			
			//_vid.x = _vid.y = 7;
			
			for (var i:uint=0; i < Camera.names.length; i++) {
				if (i != index) {
					info = _cams[i];
					info.cam.removeEventListener(ActivityEvent.ACTIVITY, cameraMotionHandler);
					info.cam.removeEventListener(StatusEvent.STATUS, camStatus);
					// clean up video??
				}
			}
			startup();
		}
		
		private function camStatus(e:StatusEvent):void {
			trace("CamStatus: "+e.code);
			switch (e.code) {
				case "Camera.Muted":
					trace("Woops!  No camera enabled.  Do something");
					break;
					
				case "Camera.Unmuted":
				   // LongMessage.visible = false;
				    //startup();
					break;
				
				default:
				    trace("Got camera status "+e.code);
			}
		}
		
	}
}