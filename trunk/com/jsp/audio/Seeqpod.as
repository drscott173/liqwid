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

package com.jsp.audio
{
	import com.jsp.events.LiqwidEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import com.jsp.global.Config;

	public class Seeqpod extends EventDispatcher
	{
		private static var _uid:String = Config.SEEQPOD_UID;
		private static var _key:String = Config.SEEQPOD_KEY;
		private static var _apiBase:String = "http://www.seeqpod.com/api/";
		private static var _proxy:String = Config.PROXY;
		
		public function Seeqpod(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		//
		// Seeqpod search
		//
		// 
		// s = new Seeqpod();
		// s.addEventListener(LiqwidEvent.MP3_LIST, gotList);
		// s.search('search string');
		//
		// We throw an event LiqwidEvent.MP3_LIST whose .data contains an object {mp3list: m}
		// where m is an array of objects, {title: "string", creator: "string", mp3: "seeqpod mp3 tag"}
		//
		
		public function search(what:String):void {
			var apiURL:String = getSearchURL(what);
			var u:URLRequest = new URLRequest(apiURL);
			var l:URLLoader = new URLLoader();
			
			trace("Searching "+apiURL+" ...");
			
			l.addEventListener(Event.COMPLETE, gotSearch);
			l.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			l.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			l.load(u);
		}

		
		private function getSearchURL(what:String):String {
			return Config.proxify(_apiBase+'v0.2/'+_uid+'/music/search/'+escape(what)+'/0/50');
		}
		
		private static var _xspf:Namespace = new Namespace("http://xspf.org/ns/0/");
		
		private function gotSearch(e:Event):void {
			default xml namespace = _xspf;
			var l:URLLoader = e.target as URLLoader;
			var xml:XML = XML(l.data);
			var result:Array = new Array();;
			
			for each (var track:XML in xml.trackList.track) {
				result.push({title: track.title,
							 creator: track.creator,
							 mp3: track.extension.mp3_url_id});
			}
			dispatchEvent(new LiqwidEvent(LiqwidEvent.MP3_LIST, {mp3list: result}));
		}
		
		//
		// Map an MP3 identifier to a URL
		//
		// s.getURL('mp3 identifier')
		//
		// The MP3 identifiers are returned from a search call.  We turn this into a URL,
		// then throw an event LiqwidEvent.CACHE_URL whose data is {url: "location"}
		//
		
		public function getURL(mp3:String):void {
			var apiURL:String = getCacheURL(mp3);
			var u:URLRequest = new URLRequest(apiURL);
			var l:URLLoader = new URLLoader();
			
			l.addEventListener(Event.COMPLETE, gotURL);
			l.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			l.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			l.load(u);
		}
		
		private function getCacheURL(id:String):String {
			var ans:String = _apiBase+'adserve/results?uid='+_uid+"&mp3_url_id="+id;
			return Config.proxify(ans);
		}
		
		private function ioError(e:IOErrorEvent):void {
			trace("Seeqpod IO Error: "+e.text);
		}  
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			trace("Seeqpod IO Error: "+e.text);
		}
		
		private function gotURL(e:Event):void {
			var l:URLLoader = e.target as URLLoader;
			var loc:String = l.data as String;
			
			dispatchEvent(new LiqwidEvent(LiqwidEvent.CACHE_URL, 
								{url: Config.proxify(loc)}, 
								true, false));
		}
	
	}
}