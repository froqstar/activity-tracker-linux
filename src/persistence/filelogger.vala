using Gee;

namespace Kraken {

	class FileLogger : Object, ILogger {

		private File logfile;
		private DataOutputStream log_stream;

		private bool changes_since_last_sync = false;

		private Gee.HashMap<string, Activity> activities_since_last_sync = new HashMap<string, Activity>();

		public FileLogger(string file) {
			logfile = File.new_for_path (file);
			FileOutputStream file_stream;

            try {
            	// Test for the existence of file
		        if (logfile.query_exists ()) {
		            file_stream = logfile.append_to(FileCreateFlags.NONE);
		        } else {
		        	file_stream = logfile.create(FileCreateFlags.NONE);
		        }
		        log_stream = new DataOutputStream (file_stream);
            } catch (Error e) {
				stderr.printf ("%s\n", e.message);
			}
		}

		public void log(string content) {
			try {
				log_stream.put_string(content + "\n");
			} catch (IOError e) {
				stderr.printf ("%s\n", e.message);
			}
		}

		public void log_start(Activity activity) {
			if (activity != null) {
				switch (activity.activity_type) {
					case Activity.ActivityType.APPLICATION:
						log(activity.start.to_string() + " : OPENED APPLICATION: " + activity.data);
						break;
					case Activity.ActivityType.URL:
						log(activity.start.to_string() + " : OPENED URL: " + activity.data);
						break;
					case Activity.ActivityType.FILE:
						log(activity.start.to_string() + " : OPENED FILE: " + activity.data);
						break;
					case Activity.ActivityType.WIFI_NETWORK:
						log(activity.start.to_string() + " : CONNECTED TO WIFI NETWORK: " + activity.data);
						break;
					case Activity.ActivityType.GEOPOSITION:
						log(activity.start.to_string() + " : MOVED TO: " + activity.data);
						break;
					default:
						break;
				}
				changes_since_last_sync = true;
				activities_since_last_sync.set(activity.data, activity);
			}
		}

		public void log_end(Activity activity) {
			if (activity != null) {
				switch (activity.activity_type) {
					case Activity.ActivityType.APPLICATION:
						log(activity.end.to_string() + " : LEFT APPLICATION: " + activity.data);
						break;
					case Activity.ActivityType.URL:
						log(activity.end.to_string() + " : LEFT URL: " + activity.data);
						break;
					case Activity.ActivityType.FILE:
						log(activity.end.to_string() + " : CLOSED FILE: " + activity.data);
						break;
					case Activity.ActivityType.WIFI_NETWORK:
						log(activity.end.to_string() + " : DISCONNECTED FROM WIFI NETWORK: " + activity.data);
						break;
					case Activity.ActivityType.GEOPOSITION:
						log(activity.end.to_string() + " : MOVED FROM: " + activity.data);
						break;
					default:
						break;
				}
				changes_since_last_sync = true;
				activities_since_last_sync.set(activity.data, activity);
			}
		}

		public void sync() {
			if (changes_since_last_sync) {
				foreach (Activity a in activities_since_last_sync.values()) {
					if (a.end != null) { // ignore not-yet-finished events
						log(a.start.to_string() + " - " + a.end.to_string() + " : " + a.data);
						activities_since_last_sync.unset(a.data);
					}
				}
			}
		}
	}

}
