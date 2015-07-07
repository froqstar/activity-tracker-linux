namespace Kraken {

	/**
	 * Default generator used when no other generator is registered for the identifier
	 */
	class DefaultGenerator : Object, IGenerator {

		private IGeneratorHandler handler;

		public DefaultGenerator(IGeneratorHandler handler) {
			this.handler = handler;
		}

		public void generate(string? identifier, TriggerType type) {
			if (identifier == null) return;

			string fd_path = "";
			if (type == TriggerType.FILE) {
				fd_path = identifier;
			} else {
				int pid = getPIDFromExecutable(identifier);
				fd_path = "/proc/"+pid.to_string()+"/fd";
				handler.register_generator_for_file(this, fd_path);
			}

			handler.on_activity_started(new Activity(identifier, Activity.ActivityType.APPLICATION));

			try {
				Dir dir = Dir.open(fd_path, 0);
				string? name = null;

				while ((name = dir.read_name ()) != null) {
					string fname = name;
					string abspath = fd_path + "/" + name;
					if (FileUtils.test(abspath, FileTest.IS_SYMLINK)) {
						fname = FileUtils.read_link(abspath);
					}
					//stdout.printf("evaluating opened file '%s'\n", fname);
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
