/**
 *
 * as3extensions - ActionScript Extension Classes
 * Copyright (C) 2010-2011, myJerry Developers
 * http://www.myjerry.org/as3extensions
 *
 * The file is licensed under the the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

package org.myjerry.as3extensions.web {
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	
	
	public class URLService {
		
		private var _url:String = null;
		
		private var _completionHandler:Function = null;
		
		private var _errorHandler:Function = null;
		
		private var _progressHandler:Function = null;
		
		/**
		 * Internal handle for data that needs to be passed to different handlers.
		 */
		private var _callbackData:Object = null;
		
		/**
		 * Tracks whether the made call is a HEAD request or not.
		 */
		private var _isHEADRequest:Boolean = false;
		
		public function URLService(url:String, completionHandler:Function, errorHandler:Function = null) {
			super();
			
			this._url = url;
			this._completionHandler = completionHandler;
			this._errorHandler = errorHandler;
		}
		
		public function executeHEAD(callbackData:Object = null, followRedirects:Boolean = true):void {
			this._callbackData = callbackData;
			this._isHEADRequest = true;
			
			var request:URLRequest = new URLRequest(this._url);
			request.followRedirects = followRedirects;
			
			var stream:URLStream = new URLStream();

			stream.removeEventListener(Event.COMPLETE, onDownloadComplete);
			stream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatusHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadError);
			
			stream.load(request);
		}
		
		/**
		 * Just do the job.
		 */
		public function executeGET(callbackData:Object = null):void {
			this._callbackData = callbackData;
			this._isHEADRequest = false;
			
			var request:URLRequest = new URLRequest(this._url);
			var stream:URLStream = new URLStream();
			
			stream.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			stream.addEventListener(Event.COMPLETE, onDownloadComplete);
			stream.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadError);
			
			stream.load(request);
		}
		
		/**
		 * Event listener for HTTP response event
		 */
		private function onResponseStatusHandler(event:HTTPStatusEvent):void {
			if(_isHEADRequest) {
				var statusCode:int = event.status;
				var headers:Array = event.responseHeaders;
				
				this._completionHandler(statusCode, headers, this._callbackData);
			}
		}
		
		/**
		 * Event listener for progress events.
		 */
		private function onDownloadProgress(event:ProgressEvent):void {
			if(this._progressHandler != null) {
				this._progressHandler(event, this._callbackData);
			}
		}
		
		/**
		 * Event listener for download complete event.
		 */
		private function onDownloadComplete(event:Event):void {
			var stream:URLStream = event.target as URLStream;
			var data:String = stream.readUTFBytes(stream.bytesAvailable);
			
			stream.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			stream.removeEventListener(Event.COMPLETE, onDownloadComplete);
			stream.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			stream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadError);
			
			// completion handler will never be NULL
			this._completionHandler(data, this._callbackData);
		}
		
		/**
		 * Event listener for download error event.
		 */
		private function onDownloadError(event:Event):void {
			var stream:URLStream = event.target as URLStream;
			
			stream.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			stream.removeEventListener(Event.COMPLETE, onDownloadComplete);
			stream.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			stream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadError);
			
			if(this._errorHandler != null) {
				this._errorHandler(event, this._callbackData);
			}
		}
	}
}
