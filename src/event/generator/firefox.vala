namespace Kraken {

	class FirefoxGenerator : Object, IGenerator {

		private string session_file_path = "/home/martin/.mozilla/firefox/pap607rg.default/sessionstore-backups/recovery.js";

		private IGeneratorHandler handler;

		public FirefoxGenerator(IGeneratorHandler handler) {
			//TODO: determine version
			//
			this.handler = handler;
			handler.register_generator_for_window_class(this, "Navigator");
			//TODO: determine session file path for current session/user
			handler.register_generator_for_file(this, session_file_path);
		}

		public void generate() {
			handler.on_activity_started(new Activity("firefox", Activity.ActivityType.APPLICATION));
			handler.on_activity_started(new Activity(extract_current_url(), Activity.ActivityType.URL));
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
