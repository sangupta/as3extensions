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

package com.sangupta.as3extensions.io {
	
	import flash.events.Event;
	import flash.filesystem.File;
	
	public class FileChooser {
		
		private var completionFunction:Function = null;
		
		private var cancelFunction:Function = null;
		
		private var title:String = null;
		
		private var filters:Array;
		
		public function FileChooser(title:String, completionFunction:Function, cancelFunction:Function = null) {
			if(title == null) {
				throw new ArgumentError('Title is required.');
			}
			
			if(completionFunction == null) {
				throw new ArgumentError('Completion function is a must.');
			}
			
			this.completionFunction = completionFunction;
			this.cancelFunction = cancelFunction;
			
			this.title = title;
		}
		
		public function setFilters(filters:Array):FileChooser {
			this.filters = filters;
			return this;
		}
		
		public function choose():void {
			var file:File = File.desktopDirectory;
			file.addEventListener(Event.SELECT, selectDirectoryListener);
			file.addEventListener(Event.CANCEL, cancelDirectoryListener);
			
			if(this.filters != null) {
				file.browseForOpen(this.title, this.filters);
			} else {
				file.browseForOpen(this.title);
			}
		}
		
		protected function selectDirectoryListener(event:Event):void {
			var file:File = event.target as File;
			
			file.removeEventListener(Event.SELECT, selectDirectoryListener);
			file.removeEventListener(Event.CANCEL, cancelDirectoryListener);
			
			this.cancelFunction = null;
			
			var callable:Function = this.completionFunction;
			this.completionFunction = null;
			
			callable(file);
		}
		
		protected function cancelDirectoryListener(event:Event):void {
			var file:File = event.target as File;
			
			file.removeEventListener(Event.SELECT, selectDirectoryListener);
			file.removeEventListener(Event.CANCEL, cancelDirectoryListener);
			
			this.completionFunction = null;
			
			var callable:Function = this.cancelFunction;
			this.cancelFunction = null;
			
			if(callable != null) {
				callable();
			}
		}
	}
}
