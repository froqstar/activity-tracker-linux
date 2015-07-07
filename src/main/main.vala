using Gee;

namespace Kraken {

	class KrakenDaemon : Object, ITriggerHandler, IGeneratorHandler {

		private HashMap<string, ITrigger> triggers = new HashMap<string, ITrigger>();
		private HashMap<string, IGenerator> generators = new HashMap<string, IGenerator>();
		private IGenerator default_generator;

		private KrakenEvent current_application;
		private KrakenEvent current_url;
		private KrakenEvent current_file;
		private KrakenEvent current_network;
		private KrakenEvent current_position;

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

		public void on_activity_started(KrakenEvent activity) {
			if (activity != null) {
				switch (activity.activity_type) {
					case KrakenEvent.KrakenEventType.APPLICATION:
						if (current_application.data != activity.data) { // new activity
							on_activity_finished(current_application);
							current_application = activity;
						}
						break;
					case KrakenEvent.KrakenEventType.URL:
						if (current_url.data != activity.data) {
							on_activity_finished(current_url);
							current_url = activity;
						}
						break;
					case KrakenEvent.KrakenEventType.FILE:
						if (current_file.data != activity.data) {
							on_activity_finished(current_file);
							current_file = activity;

						}
						break;
					case KrakenEvent.KrakenEventType.WIFI_NETWORK:
						if (current_network.data != activity.data) {
							on_activity_finished(current_network);
							current_network = activity;
						}
						break;
					case KrakenEvent.KrakenEventType.GEOPOSITION:
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

		public void on_activity_finished(KrakenEvent? activity) {
			if (activity != null) {
				switch (activity.activity_type) {
					case KrakenEvent.KrakenEventType.APPLICATION:
						on_activity_finished(current_url);
						on_activity_finished(current_file);
						current_application = null;
						break;
					case KrakenEvent.KrakenEventType.URL:
						current_url = null;
						break;
					case KrakenEvent.KrakenEventType.FILE:
						current_file = null;
						break;
					case KrakenEvent.KrakenEventType.WIFI_NETWORK:
						current_network = null;
						break;
					case KrakenEvent.KrakenEventType.GEOPOSITION:
						current_position = null;
						break;
					default:
						break;
				}
				activity.end = new DateTime.now_utc();
				log.log_end(activity);
			}
		}

		public bool sync_persistence() {
			log.sync();
			return true;
		}

		public static int main(string[] args) {

			KrakenDaemon daemon = new KrakenDaemon(new FileLogger("log/krakenlog.log"));

			//TODO: use Glib.timeout or sync?
			//http://stackoverflow.com/questions/12561695/efficient-daemon-in-vala

			MainLoop loop = new MainLoop ();
			Timeout.add(1000*30, sync_persistence, GLib.Priority.LOW);
			loop.run ();

			return 0;
		}
	}

}
