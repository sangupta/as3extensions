package org.myjerry.as3extensions.io {
	
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
