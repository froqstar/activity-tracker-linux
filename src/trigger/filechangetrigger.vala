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
			stdout.printf("creating monitor for file/directory '%s'.\n", path);

			File file = File.new_for_path (path);

			if (!file.query_exists ()) {
		    	stdout.printf("file or directory '%s' does not exist, aborting...\n", path);
		    	return;
			}

			try {
				monitor = file.monitor (FileMonitorFlags.NONE, null);
				monitor.changed.connect(on_change);
				stdout.printf("success.\n");
			} catch (Error e) {
				stdout.printf("failed.\n");
				stderr.printf ("%s\n", e.message);
			}
		}

		public void on_change(File file, File? other_file, FileMonitorEvent event_type) {
			stdout.printf ("%s: %s\n", event_type.to_string (), file.get_path ());
			if (event_type == FileMonitorEvent.CHANGES_DONE_HINT) {
				handler.on_trigger_fired(path, TriggerType.FILE);
			}
		}
	}
}
