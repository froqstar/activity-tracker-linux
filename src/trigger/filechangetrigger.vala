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
			stdout.printf ("Monitoring: %s\n", file.get_path ());

			if (!file.query_exists ()) {
		    	stdout.printf("file or directory '%s' does not exist, aborting...\n", path);
		    	return;
			}

			monitor.changed.connect(on_change);


			monitor.changed.connect ((src, dest, event) => {
				if (dest != null) {
					stdout.printf ("%s: %s, %s\n", event.to_string (), src.get_path (), dest.get_path ());
				} else {
					stdout.printf ("%s: %s\n", event.to_string (), src.get_path ());
				}
			});

		}

		public void on_change(File file, File? other_file, FileMonitorEvent event_type) {
			stdout.printf("file %s changed.\n", path);
			handler.on_trigger_fired(path);
		}
	}
}
