namespace Kraken {

	class FirefoxGenerator : Object, IGenerator {

		private string sessionFilePath;

		private IGeneratorHandler handler;

		public FirefoxGenerator(IGeneratorHandler handler) {
			//TODO: determine version
			//
			this.handler = handler;
			handler.register_generator_for_window_class(this, "firefox");
			//TODO: determine file for current session/user
			handler.register_generator_for_file(this, "/home/martin/.mozilla/firefox/pap607rg.default/sessionstore-backups/previous.js");
		}

		public void generate() {
			//TODO: read session file
			handler.on_activity_started(new Activity("firefox", Activity.ActivityType.URL));
		}
	}

}
