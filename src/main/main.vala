using Gee;

namespace Kraken {

	class KrakenDaemon : Object, ITriggerHandler, IGeneratorHandler {

		private HashMap<string, ITrigger> triggers = new HashMap<string, ITrigger>();
		private HashMap<string, IGenerator> generators = new HashMap<string, IGenerator>();

		private Activity current_application;
		private Activity current_url;
		private Activity current_file;
		private Activity current_position;

		private ILogger log;

		public KrakenDaemon(ILogger log) {
			this.log = log;

			new FirefoxGenerator(this);

			ITrigger xtrigger = new XFocusChangeTrigger(this);
			triggers.set("x", xtrigger);
			xtrigger.activate();

			ITrigger geocluetrigger = new GeoClueTrigger(this, this);
			triggers.set("geoclue", geocluetrigger);
			geocluetrigger.activate();
		}

		public void on_trigger_fired(string? identifier) {
			if (identifier == null) return;
			stdout.printf("trigger '%s' fired.\n", identifier);
			if (generators.has_key(identifier)) {
				generators.get(identifier).generate();
			} else {
				stdout.printf("no generator registered for '%s', creating default activity.\n", identifier);
				on_activity_started(new Activity(identifier, Activity.ActivityType.APPLICATION));
			}
		}

		public void register_generator_for_file(IGenerator generator, string path) {
			generators.set(path, generator);
			if (!triggers.has_key(path)) {
				stdout.printf("need to create new file trigger for path '%s'.\n", path);
				FileChangeTrigger trigger = new FileChangeTrigger(path, this);
				triggers.set(path, trigger);
				trigger.activate();
			} else {
				stdout.printf("file trigger for path '%s' already exists.\n", path);
			}
		}

		public void register_generator_for_window_class(IGenerator generator, string window_class) {
			generators.set(window_class, generator);
		}

		public void on_activity_started(Activity activity) {
			switch (activity.activity_type) {
				case Activity.ActivityType.APPLICATION:
					if (current_application.data != activity.data) { // new activity
						on_activity_finished(current_url);
						on_activity_finished(current_file);
						on_activity_finished(current_application);
						current_application = activity;
						log.log("OPENED APPLICATION: " + activity.data);
					}
					break;
				case Activity.ActivityType.URL:
					if (current_url.data != activity.data) {
						on_activity_finished(current_url);
						current_url = activity;
						log.log("OPENED URL: " + activity.data);
					}
					break;
				case Activity.ActivityType.GEOPOSITION:
					on_activity_finished(current_position);
					current_position = activity;
					log.log("MOVED TO: " + activity.data);
					break;
				default:
					break;
			}
		}

		public void on_activity_finished(Activity? activity) {
			if (activity != null) {
				switch (activity.activity_type) {
					case Activity.ActivityType.APPLICATION:
						log.log("LEFT APPLICATION: " + activity.data);
						current_application = null;
						break;
					case Activity.ActivityType.URL:
						log.log("LEFT URL: " + activity.data);
						current_url = null;
						break;
					case Activity.ActivityType.FILE:
						log.log("CLOSED FILE: " + activity.data);
						current_file = null;
						break;
					case Activity.ActivityType.GEOPOSITION:
						log.log("MOVED FROM: " + activity.data);
						current_position = null;
						break;
					default:
						break;
				}
			}
		}

		public static int main(string[] args) {

			KrakenDaemon daemon = new KrakenDaemon(new FileLogger("log/krakenlog.log"));

			//TODO: use Glib.timeout or sync?
			//http://stackoverflow.com/questions/12561695/efficient-daemon-in-vala

			MainLoop loop = new MainLoop ();
			loop.run ();

			return 0;
		}
	}

}
