namespace Kraken {

	class FileLogger : Object, ILogger {

		private File logfile;
		private DataOutputStream log_stream;

		public FileLogger(string file) {
			logfile = File.new_for_path (file);
			FileOutputStream file_stream;

            // Test for the existence of file
            if (logfile.query_exists ()) {
                file_stream = logfile.append_to(FileCreateFlags.NONE);
            } else {
            	file_stream = logfile.create(FileCreateFlags.NONE);
            }
            log_stream = new DataOutputStream (file_stream);
		}

		public void log(string content) {
			DateTime start = new DateTime.now_local();
			log_stream.put_string ("" + start.to_string() + " : " + content + "\n");
		}
	}

}
