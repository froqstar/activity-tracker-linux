namespace Kraken {

	class FileLogger : Object, ILogger {

		private File logfile;
		private DataOutputStream log_stream;

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
			DateTime start = new DateTime.now_local();
			try {
				log_stream.put_string ("" + start.to_string() + " : " + content + "\n");
			} catch (IOError e) {
				stderr.printf ("%s\n", e.message);
			}
		}
	}

}
