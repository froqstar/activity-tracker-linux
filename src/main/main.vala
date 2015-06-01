using Gee;

namespace Kraken {

	class KrakenDaemon : Object, IActivityHandler, ITriggerHandler, IGeneratorHandler {

		private HashMap<string, ITrigger> triggers = new HashMap<string, ITrigger>();
		private HashMap<string, IGenerator> generators = new HashMap<string, IGenerator>();

		private Activity current_activity;

		public KrakenDaemon() {
			ITrigger xtrigger = new XFocusChangeTrigger(this);
			triggers.set("x", xtrigger);
			xtrigger.activate();
		}

		public void on_trigger_fired(string identifier) {
			stdout.printf("trigger '%s' fired.\n", identifier);
			generators.get(identifier).generate();
		}

		public void register_generator_for_file(IGenerator generator, string path) {
			generators.set(path, generator);
			if (!triggers.has_key(path)) {
				stdout.printf("need to create file trigger for %s\n", path);
			}
		}

		public void register_generator_for_window_class(IGenerator generator, string window_class) {
			generators.set(window_class, generator);
		}

		public void on_activity_started(Activity activity) {
		}

		public void on_activity_finished(Activity activity) {
		}

		public static int main(string[] args) {

			KrakenDaemon daemon = new KrakenDaemon();

			//TODO: setup triggers
			//TODO: setup generators
			//TODO: setup logger

			//TODO: use Glib.timeout or sync?
			//http://stackoverflow.com/questions/12561695/efficient-daemon-in-vala

			MainLoop loop = new MainLoop ();
			loop.run ();

			return 0;
		}
	}

}
