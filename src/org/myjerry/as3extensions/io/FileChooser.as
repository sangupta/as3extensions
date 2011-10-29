package org.myjerry.as3extensions.io {
	
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
