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
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	
	/**
	 * Convenience wrapper to hit a given URL and return the response as an XML.
	 * The service is hit using a <code>URLStream</code> rather than an <code>HTTPService<code>
	 * to handle response size more than a few MBs. 
	 * 
	 * @author Sandeep Gupta
	 * @since 1.0
	 */
	public class XMLService {
		
		/**
		 * Contruct a one-time usable object of this service.
		 * 
		 * @param url the end-point URL that needs to be invoked.
		 * @param completionHandler Function that needs to be called when download completes.
		 * @param errorHandler Function that needs to be called in case of a failure.
		 */  
		public function XMLService(url:String, completionHandler:Function, errorHandler:Function = null) {
			super();

			this._url = url;
			this._completionHandler = completionHandler;
			this._errorHandler = errorHandler;
		}
		
		private var _url:String = null;
		
		private var _completionHandler:Function = null;
		
		private var _errorHandler:Function = null;
		
		/**
		 * Set up an error handler for any error event that may occur.
		 */
		public function setErrorHandler(errorHandler:Function):void {
			this._errorHandler = errorHandler;
		}
		
		private var _progressHandler:Function = null;
		
		/**
		 * Set up a progress handler for capturing progress events.
		 */
		public function setProgressHandler(progressHandler:Function):void {
			this._progressHandler = progressHandler;
		}
		
		/**
		 * Internal handle for data that needs to be passed to different handlers.
		 */
		private var _callbackData:Object = null;
		
		/**
		 * Just do the job.
		 */
		public function execute(callbackData:Object = null):void {
			this._callbackData = callbackData;
			
			var request:URLRequest = new URLRequest(this._url);
			var stream:URLStream = new URLStream();
			
			stream.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			stream.addEventListener(Event.COMPLETE, onDownloadComplete);
			stream.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadError);
			
			stream.load(request);
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
			var xml:XML = new XML(data);
			
			stream.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			stream.removeEventListener(Event.COMPLETE, onDownloadComplete);
			stream.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			stream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadError);

			// completion handler will never be NULL
			this._completionHandler(xml, this._callbackData);
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
