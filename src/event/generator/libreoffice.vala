namespace Kraken {

	class LibreOfficeGenerator : Object, IGenerator {

		private IGeneratorHandler handler;

		private static const string ACTIVITY_NAME = "libreoffice";

		private int pid = 0;
		private string fd_path = "";

		public LibreOfficeGenerator(IGeneratorHandler handler) {
			this.handler = handler;
			handler.register_generator_for_window_class(this, "libreoffice");
			handler.register_generator_for_window_class(this, "soffice");
			//handler.register_generator_for_file(this, session_file_path);
		}

		public void generate() {
			if (pid == 0) {
				pid = getPIDFromExecutable("soffice.bin");
				fd_path = "/proc/"+pid.to_string()+"/fd";
				handler.register_generator_for_file(this, fd_path);
			}
			handler.on_activity_started(new Activity(ACTIVITY_NAME, Activity.ActivityType.APPLICATION));
			//handler.on_activity_started(new Activity(extract_current_url(), Activity.ActivityType.URL));

			try {
				Dir dir = Dir.open(fd_path, 0);
				string? name = null;

				while ((name = dir.read_name ()) != null) {
					string fname = name;
					string abspath = fd_path + "/" + name;
					if (FileUtils.test(abspath, FileTest.IS_SYMLINK)) {
						fname = FileUtils.read_link(abspath);
					}
					stdout.printf("evaluating opened file '%s'\n", fname);
					if ( fname.contains(Environment.get_home_dir()) && !fname.contains("/.") ) {
						handler.on_activity_started(new Activity(fname, Activity.ActivityType.FILE));
						return;
					}
				}
			} catch (FileError err) {
				stderr.printf (err.message);
				return;
			}
		}
	}
}
