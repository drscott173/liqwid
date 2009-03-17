/*
 * Copyright 2009 (c) Scott Penberthy, scottpenberthy.com 
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */


package com.jsp.audio
{		
	import com.jsp.events.LiqwidEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.ID3Info;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	public class MusicPlayer extends Sprite
	{
		
		private var _mp3:String;					// The local MP3 file
		private var _sound:Sound;					// Three objects to control sound
		private var _channel:SoundChannel;
		private var _transform:SoundTransform;
		
		private var _playing:Boolean;				// True when playing media	
		private var _watching:Boolean;				// True when progress alerts are firing
		private var _lastPos:int;					// Last seek position, in msec
		private var _musicTimer:Timer;				// A timer to update seek bar
		private var _duration:Number;				// The duration of the music, in msec
		private var _progress:Object = 				// A cache for updating progress
		            {playHead: 0, currentTime: "00:00"};
		
		public function MusicPlayer() {
			_musicTimer = new Timer(500);
			_musicTimer.addEventListener(TimerEvent.TIMER, soundTic);
			_playing = false;
			_sound = null;
			_mp3 = null;
			_lastPos = 0;
			_duration = 0;
		}
		
		//
		// INTERFACE
		//
		
		public function play(url:String):void {
			// we call this when we want to load a new MP3, whether or
			// not the visuals and sounds are playing.
			if (_playing) {
				_channel.stop();
				ignoreProgress();
			}
			_mp3 = url;
			setupSound();
			_channel = _sound.play();
			_channel.soundTransform = _transform;
			_playing = true;
			watchProgress();
		}
					
		private function start(pos:Number = 0):void {
			if (_channel) {
				_channel.stop();
				_channel.removeEventListener(Event.SOUND_COMPLETE, onMP3Complete);
				_channel = null;
			}
			_channel = _sound.play(pos);
			_channel.addEventListener(Event.SOUND_COMPLETE, onMP3Complete);
			_channel.soundTransform = _transform;
		}
	
		public function pause():void {
			if (!_sound || !_playing) return;
			_lastPos = _channel.position;
			_channel.stop();
			ignoreProgress();
			_playing = false;
		}
		
		public function resume():void {
			if (!_sound || _playing) return;
			trace("Restarting MP3");
			_channel = _sound.play(_lastPos);
			_channel.soundTransform = _transform;
			_playing = true;
			watchProgress();
		}
	
		public function seek(pct:Number):void {
			if (!_sound) return;
			if (pct < 0) pct = 0;
			if (pct > 1) pct = 1;
			var duration:Number = guessDuration();
			var pos:Number = Math.floor(pct*duration);
			
			if (_playing) {
				start(pos);
			}
			else {
				_lastPos = Math.floor(pos);
			}
		}
		
		public function set volume(pct:Number):void {
			if (!_sound) return;
			if (pct < 0) pct = 0;
			if (pct > 1) pct = 1;
			_transform.volume = pct;
			_channel.soundTransform = _transform;
		}
		
		//
		// Event handling
		//
		
		private function watchProgress():void {
			if (!_watching) _musicTimer.start();
			_watching = true;
		}
		
		private function ignoreProgress():void {
			if (_watching) _musicTimer.stop();
			_watching = false;
		}
		
		private function onID3InfoReceived(e:Event):void {
			var id3:ID3Info = e.target.id3;
			var myInfo:Object = new Object;
			
			myInfo.title = id3['TIT2'];
			myInfo.artist = id3['TPE1'];
			myInfo.album = id3['TALB'];
			myInfo.year = id3['TYER'];
			myInfo.copyright = id3['TCOP'];
			myInfo.track = id3['TRCK'];
			myInfo.commercial = id3['COMM'];
			_duration = parseInt(id3['TLEN']);
			myInfo.totalTime = _humanTime(_duration*0.001);				// for the time display
			
			trace("MP3: '"+myInfo.title+"', "+myInfo.album+" ("+myInfo.year+")");

		 	dispatchEvent(new LiqwidEvent(LiqwidEvent.METADATA, myInfo, true, true));
		}
		
		public function onMP3Error(e:IOErrorEvent):void {
			_sound = null;
			trace("MP3 error: "+e.text);
		}
		
		public function onSecurityError(e:SecurityErrorEvent):void {
			_sound = null;
			trace("MP3 security error: "+e.text);
		}
		
		public function onMP3Complete(e:Event):void {
			dispatchEvent(new LiqwidEvent(LiqwidEvent.MEDIA_COMPLETE, null, true, true));
		}
		
		public function onMP3LoadProgress(e:Event):void {
			//trace("Loaded "+Math.floor(_sound.bytesLoaded/_sound.bytesTotal * 100)+"% ");
		}
		
		private function soundTic(e:Event):void {
			if (!_sound) return;	
			var duration:Number = guessDuration();
			var msec:Number = _channel.position;

			_progress.playHead = msec/duration;
			_progress.currentTime = _humanTime(msec/1000);
			dispatchEvent(new LiqwidEvent(LiqwidEvent.PROGRESS, _progress, true, true));
		}
		
		public function currentTimeString():String {
			if (!_sound) return "00:00";	
			var duration:Number = guessDuration();
			var msec:Number = _playing ? _channel.position : _lastPos;
		
			return _humanTime(msec/1000);
		}
		
		//
		// Helper methods
		//

		private function setupSound():void {
			_sound = new Sound(new URLRequest(_mp3));
			_transform = new SoundTransform(1.0,0);
			_lastPos = 0;
			_sound.addEventListener(Event.ID3, onID3InfoReceived);
			_sound.addEventListener(IOErrorEvent.IO_ERROR, onMP3Error);
			_sound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_sound.addEventListener(ProgressEvent.PROGRESS, onMP3LoadProgress);
		}
		
		private function _humanTime(t:Number):String {
			var sec:Number = Math.round(t % 60);
			var min:Number = Math.floor(t / 60);
			var now:String = twoDigit(min) + ':' + twoDigit(sec);
			return now;
		}
		
		private var _digits:Array = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
		
		private function twoDigit(n:Number):String {
			var d1:Number = n % 10;
			var d2:Number = ((n - d1)/10) % 10;
			return _digits[d2] + _digits[d1];
		}
		
		private function guessDuration():Number {
			return _duration > 0 ? _duration : Math.ceil(_sound.length / (_sound.bytesLoaded / _sound.bytesTotal));
		}

	}
}