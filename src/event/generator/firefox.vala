namespace Kraken {

	class FirefoxGenerator : Object, IGenerator {

		private string session_file_path = "./";

		private IGeneratorHandler handler;

		public FirefoxGenerator(IGeneratorHandler handler) {
			this.handler = handler;
			session_file_path = get_session_file_path();

			handler.register_generator_for_window_class(this, "Navigator");
			handler.register_generator_for_file(this, session_file_path);
		}

		public void generate() {
			handler.on_activity_started(new Activity("firefox", Activity.ActivityType.APPLICATION));
			handler.on_activity_started(new Activity(extract_current_url(), Activity.ActivityType.URL));
		}

		private string get_session_file_path() {
			string home = Environment.get_home_dir();
			string firefox_folder = home + "/.mozilla/firefox/";
			string profile_folder = "";
			string file_path = "";

			try {
				Dir dir = Dir.open (firefox_folder, 0);
				string? name = null;

				while ((name = dir.read_name ()) != null) {
					//TODO: check if pattern holds for all versions, even <34?
					if (name.contains(".default")) {
						//default profile, run with it...
						profile_folder = firefox_folder + name + "/";
						break;
					}
				}
			} catch (FileError err) {
				stderr.printf (err.message);
				return "";
			}
			if (profile_folder.char_count() == 0) {
				return "";
			}

			//check for possible session file locations
			if (FileUtils.test (profile_folder + "sessionstore.js", FileTest.EXISTS)) {
				file_path = profile_folder + "sessionstore.js";
			} else if (FileUtils.test (profile_folder + "sessionstore-backups/recovery.js", FileTest.EXISTS)) {
				file_path = profile_folder + "sessionstore-backups/recovery.js";
			}
			return file_path;
		}

		private string extract_current_url() {
			string content;
			FileUtils.get_contents(session_file_path, out content);

			var parser = new Json.Parser ();
			parser.load_from_data (content, -1);

			var root_object = parser.get_root().get_object ();

			int active_window_index = (int) root_object.get_int_member("selectedWindow") - 1;
			var active_window = root_object.get_array_member("windows").get_elements().nth_data(active_window_index).get_object();

			int active_tab_index = (int) active_window.get_int_member("selected") - 1;
			var active_tab = active_window.get_array_member("tabs").get_elements().nth_data(active_tab_index).get_object();

			int active_entry_index = (int) active_tab.get_int_member("index") - 1;
			var active_entry = active_tab.get_array_member("entries").get_elements().nth_data(active_entry_index).get_object();
			return active_entry.get_string_member("url");
		}
	}

}
