using Xcb;

namespace Kraken {

	class FileChangeTrigger : Object, ITrigger {

		private ITriggerHandler handler;
		private string path;
		private FileMonitor monitor;

		public FileChangeTrigger(string path, ITriggerHandler handler) {
			this.path = path;
			this.handler = handler;
		}

		public void activate() {

			File file = File.new_for_path (path);
			monitor = file.monitor (FileMonitorFlags.NONE, null);
			stdout.printf("monitoring file/directory '%s' for changes.\n", file.get_path ());

			if (!file.query_exists ()) {
		    	stdout.printf("file or directory '%s' does not exist, aborting...\n", path);
		    	return;
			}

			monitor.changed.connect(on_change);
		}

		public void on_change(File file, File? other_file, FileMonitorEvent event_type) {
			if (event_type == FileMonitorEvent.CHANGES_DONE_HINT) {
				handler.on_trigger_fired(path);
			}
		}
	}
}
