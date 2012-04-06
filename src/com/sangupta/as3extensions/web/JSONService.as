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
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	
	/**
	 * Convenience wrapper to hit a given URL and return the response as an JSON object.
	 * The service is hit using a <code>URLStream</code> rather than an <code>HTTPService</code>
	 * to handle response size more than a few MBs. 
	 * 
	 * @author Sandeep Gupta
	 * @since 1.0
	 */
	public class JSONService extends BaseService {
		
		/**
		 * Contruct a one-time usable object of this service.
		 * 
		 * @param url the end-point URL that needs to be invoked.
		 * @param completionHandler Function that needs to be called when download completes.
		 * @param errorHandler Function that needs to be called in case of a failure.
		 */  
		public function JSONService(url:String, completionHandler:Function, errorHandler:Function = null, progressHandler:Function = null) {
			super(url, completionHandler, errorHandler, progressHandler);
		}
		
		/**
		 * Generate a JSON object out of the stream data and return that back.
		 */
		override protected function massageStreamData(streamData:String):* {
			// TODO: need to fix this per the implementation
			// either as3corelib for AIR 3.0- or native one for AIR 3.0+
			return streamData;
		}
	
	}
}
