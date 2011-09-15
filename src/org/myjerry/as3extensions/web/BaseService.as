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
	import flash.net.URLRequest;
	import flash.net.URLStream;
	
	public class BaseService {
		
		/**
		 * Default constructor
		 */
		public function BaseService(url:String, completionHandler:Function, errorHandler:Function = null, progressHandler:Function = null) {
			super();
			
			if(url == null) {
				throw new ArgumentError('A non-null/non-empty URL is needed.');
			}
			this._url = url;
			
			if(completionHandler == null) {
				throw new ArgumentError('Completion function must be specified.');
			}
			this._completionHandler = completionHandler;
			
			this._errorHandler = errorHandler;
			this._progressHandler = progressHandler;
		}
		
		protected var _url:String = null;
		
		protected var _completionHandler:Function = null;
		
		protected var _errorHandler:Function = null;
		
		protected var _progressHandler:Function = null;
		
		/**
		 * Internal handle for data that needs to be passed to different handlers.
		 * 
		 * @private
		 */
		protected var _callbackData:Object = null;
		
		/**
		 * Set up an error handler for any error event that may occur.
		 */
		public function setErrorHandler(errorHandler:Function):void {
			this._errorHandler = errorHandler;
		}
		
		/**
		 * Set up a progress handler for capturing progress events.
		 */
		public function setProgressHandler(progressHandler:Function):void {
			this._progressHandler = progressHandler;
		}
		
		/**
		 * Just do the job.
		 */
		public function execute(callbackData:Object = null):void {
			var request:URLRequest = new URLRequest(this._url);
			
			fireRequest(request, callbackData);
		}
		
		/**
		 * Function that actually fires the built up <code>URLRequest</code>
		 */
		protected function fireRequest(request:URLRequest, callbackData:Object):void {
			this._callbackData = callbackData;
			
			var stream:URLStream = new URLStream();
			
			stream.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			stream.addEventListener(Event.COMPLETE, onDownloadComplete);
			stream.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadError);
			stream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatusHandler);
			
			stream.load(request);
		}
		
		/**
		 * Event listener for progress events.
		 */
		protected function onDownloadProgress(event:ProgressEvent):void {
			if(this._progressHandler != null) {
				this._progressHandler(event, this._callbackData);
			}
		}
		
		/**
		 * Event listener for download complete event.
		 */
		protected function onDownloadComplete(event:Event):void {
			var stream:URLStream = event.target as URLStream;
			var data:String = stream.readUTFBytes(stream.bytesAvailable);
			
			var message:* = massageStreamData(data); 
			
			stream.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			stream.removeEventListener(Event.COMPLETE, onDownloadComplete);
			stream.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			stream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadError);
			stream.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatusHandler);
			
			// completion handler will never be NULL
			var func:Function = this._completionHandler;
			
			// clean up for GC
			this._completionHandler = null;
			this._errorHandler = null;
			this._progressHandler = null;
			
			func(message, this._callbackData);
		}
		
		/**
		 * Function that massages that returned stream data, generating the returnable
		 * object and sends it back.
		 * 
		 * The default implementation returns the stream data back without modifications.
		 */
		protected function massageStreamData(streamData:String):* {
			return streamData;
		}
		
		/**
		 * Event listener for download error event.
		 */
		protected function onDownloadError(event:Event):void {
			var stream:URLStream = event.target as URLStream;
			
			stream.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			stream.removeEventListener(Event.COMPLETE, onDownloadComplete);
			stream.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			stream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadError);
			stream.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatusHandler);
			
			// clean up for GC
			this._completionHandler = null;
			this._progressHandler = null;
			
			if(this._errorHandler != null) {
				var func:Function = this._errorHandler;
				this._errorHandler = null;
				
				func(event, this._callbackData);
			}
		}
		
		protected function onResponseStatusHandler(event:HTTPStatusEvent):void {
			// do nothing
		}

	}
}
