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

	public class FolderChooser {
		
		private var completionFunction:Function = null;
		
		private var cancelFunction:Function = null;
		
		private var title:String = null;
		
		public function FolderChooser(title:String, completionFunction:Function, cancelFunction:Function = null) {
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
		
		public function choose():void {
			var folder:File = File.desktopDirectory;
			folder.addEventListener(Event.SELECT, selectDirectoryListener);
			folder.addEventListener(Event.CANCEL, cancelDirectoryListener);
			folder.browseForDirectory(this.title);
		}
		
		protected function selectDirectoryListener(event:Event):void {
			var dir:File = event.target as File;

			dir.removeEventListener(Event.SELECT, selectDirectoryListener);
			dir.removeEventListener(Event.CANCEL, cancelDirectoryListener);
			
			this.cancelFunction = null;
			
			var callable:Function = this.completionFunction;
			this.completionFunction = null;
			
			callable(dir);
		}
		
		protected function cancelDirectoryListener(event:Event):void {
			var dir:File = event.target as File;
			
			dir.removeEventListener(Event.SELECT, selectDirectoryListener);
			dir.removeEventListener(Event.CANCEL, cancelDirectoryListener);
			
			this.completionFunction = null;
			
			var callable:Function = this.cancelFunction;
			this.cancelFunction = null;
			
			if(callable != null) {
				callable();
			}
		}
	}
}
