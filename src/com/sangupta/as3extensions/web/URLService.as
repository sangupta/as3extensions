/**
 *
 * as3extensions - ActionScript Extension Classes
 * Copyright (C) 2010-2012, Sandeep Gupta
 * http://www.sangupta.com/projects/as3extensions
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

package com.sangupta.as3extensions.web {
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	
	/**
	 * @author sangupta
	 * @since 1.0
	 */
	public class URLService extends BaseService {
		
		/**
		 * Tracks whether the made call is a HEAD request or not.
		 * 
		 * @private
		 */
		private var _isHEADRequest:Boolean = false;
		
		/**
		 * Construct the object of a URL service with the supplied parameters.
		 * 
		 * @param url the HTTP URL to hit
		 * 
		 * @param completionHandler handler function that needs to be invoked when the call succeeds
		 * 
		 * @param errorHandler handler function that needs to be invoked if the call fails due to any reason
		 * 
		 */
		public function URLService(url:String, completionHandler:Function, errorHandler:Function = null, progressHandler:Function = null) {
			super(url, completionHandler, errorHandler, progressHandler);
		}
		
		/**
		 * 
		 */
		public function executeHEAD(callbackData:Object = null, followRedirects:Boolean = true):void {
			this._callbackData = callbackData;
			this._isHEADRequest = true;
			
			var request:URLRequest = new URLRequest(this._url);
			request.followRedirects = followRedirects;
			
			fireRequest(request, callbackData);
		}
		
		/**
		 * Just do the job.
		 */
		public function executeGET(callbackData:Object = null):void {
			this._isHEADRequest = false;
			
			var request:URLRequest = new URLRequest(this._url);
			
			fireRequest(request, callbackData);
		}
		
		/**
		 * Fire a POST request with the given data body, the content type and the call back data.
		 * 
		 * @param postData data that needs to be sent to the HTTP service
		 * 
		 * @param contentType the value that needs to be sent as the <code>Content-Type</code> request header
		 * 
		 * @param callbackData call back data that needs to be supplied between this method's invocation
		 * and the invocation of one of the success/error handlers.
		 */
		public function executePOST(postData:Object, contentType:String, callbackData:Object = null):void {
			this._isHEADRequest = false;
			
			var request:URLRequest = new URLRequest(this._url);
			request.method = URLRequestMethod.POST;
			request.contentType = contentType;
			request.data = postData;

			fireRequest(request, callbackData);
		}
		
		/**
		 * Event listener for HTTP response event
		 * 
		 * @private
		 */
		override protected function onResponseStatusHandler(event:HTTPStatusEvent):void {
			if(_isHEADRequest) {
				var statusCode:int = event.status;
				var headers:Array = event.responseHeaders;
				
				var func:Function = this._completionHandler;
				
				// clean up for GC
				this._completionHandler = null;
				this._errorHandler = null;
				this._progressHandler = null;
				
				func(statusCode, headers, this._callbackData);
			}
		}
		
	}
}
