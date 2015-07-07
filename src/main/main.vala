using Gee;

namespace Kraken {

	class KrakenDaemon : Object, ITriggerHandler, IGeneratorHandler {

		private HashMap<string, ITrigger> triggers = new HashMap<string, ITrigger>();
		private HashMap<string, IGenerator> generators = new HashMap<string, IGenerator>();
		private IGenerator default_generator;

		private Activity current_application;
		private Activity current_url;
		private Activity current_file;
		private Activity current_network;
		private Activity current_position;

		private ILogger log;

		public KrakenDaemon(ILogger log) {
			this.log = log;

			default_generator = new DefaultGenerator(this);

			new FirefoxGenerator(this);
			new LibreOfficeGenerator(this);

			ITrigger xtrigger = new XFocusChangeTrigger(this);
			triggers.set("x", xtrigger);
			xtrigger.activate();

			ITrigger geocluetrigger = new GeoClueTrigger(this, this);
			triggers.set("geoclue", geocluetrigger);
			geocluetrigger.activate();

			ITrigger networktrigger = new NetworkManagerTrigger(this, this);
			triggers.set("network", networktrigger);
			networktrigger.activate();

			ITrigger zeitgeisttrigger = new ZeitgeistTrigger(this, this);
			triggers.set("zeitgeist", zeitgeisttrigger);
			zeitgeisttrigger.activate();
		}

		public void on_trigger_fired(string? identifier, TriggerType type) {
			if (identifier == null) return;
			stdout.printf("\ntrigger '%s' fired.\n", identifier);
			if (generators.has_key(identifier)) {
				generators.get(identifier).generate(identifier, type);
			} else {
				stdout.printf("no generator registered for '%s', using default generator.\n", identifier);
				default_generator.generate(identifier, type);
			}
		}

		public void register_generator_for_file(IGenerator generator, string path) {
			stdout.printf("register generator for path '%s'.\n", path);
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
			if (activity != null) {
				switch (activity.activity_type) {
					case Activity.ActivityType.APPLICATION:
						if (current_application.data != activity.data) { // new activity
							on_activity_finished(current_application);
							current_application = activity;
						}
						break;
					case Activity.ActivityType.URL:
						if (current_url.data != activity.data) {
							on_activity_finished(current_url);
							current_url = activity;
						}
						break;
					case Activity.ActivityType.FILE:
						if (current_file.data != activity.data) {
							on_activity_finished(current_file);
							current_file = activity;

						}
						break;
					case Activity.ActivityType.WIFI_NETWORK:
						if (current_network.data != activity.data) {
							on_activity_finished(current_network);
							current_network = activity;
						}
						break;
					case Activity.ActivityType.GEOPOSITION:
						if (current_position.data != activity.data) {
							on_activity_finished(current_position);
							current_position = activity;
						}
						break;
					default:
						break;
				}
				log.log_start(activity);
			}
		}

		public void on_activity_finished(Activity? activity) {
			if (activity != null) {
				switch (activity.activity_type) {
					case Activity.ActivityType.APPLICATION:
						on_activity_finished(current_url);
						on_activity_finished(current_file);
						current_application = null;
						break;
					case Activity.ActivityType.URL:
						current_url = null;
						break;
					case Activity.ActivityType.FILE:
						current_file = null;
						break;
					case Activity.ActivityType.WIFI_NETWORK:
						current_network = null;
						break;
					case Activity.ActivityType.GEOPOSITION:
						current_position = null;
						break;
					default:
						break;
				}
				activity.end = new DateTime.now_utc();
				log.log_end(activity);
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
