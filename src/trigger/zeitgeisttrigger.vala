using Zeitgeist;

namespace Kraken {

	/*
	This Trigger uses the freedesktop.org zeitgeist service to gain access to its monitored events.
	*/
	class ZeitgeistTrigger : Object, ITrigger, IGenerator {

		private ITriggerHandler trigger_handler;
		private IGeneratorHandler generator_handler;

		private Zeitgeist.Log log;
		private Monitor eventMonitor;

		public ZeitgeistTrigger(ITriggerHandler handler, IGeneratorHandler generator_handler) {
			this.trigger_handler = handler;
			this.generator_handler = generator_handler;

			//log = new Zeitgeist.Log();
			log = Zeitgeist.Log.get_default();

			GenericArray<Zeitgeist.Event> templates = new GenericArray<Zeitgeist.Event>();
			Event files = new Event();
			files.add_subject(new Subject.full("", ZG.ACCESS_EVENT, "", "", "", "", ""));
			templates.add(files);
			eventMonitor = new Monitor(new TimeRange.anytime(), templates);
    		eventMonitor.events_inserted.connect(on_events_inserted);

    		//on_events_inserted(null, log.find_events(new TimeRange.anytime(), templates, StorageState.ANY, 10, ResultType.MOST_RECENT_SUBJECTS, null));
		}

		~ZeitgeistTrigger() {

		}

		public void activate() {
			log.install_monitor(eventMonitor);
			stdout.printf("is connected? %s\n", log.is_connected? "yes":"no");

		}

		public void generate(string? identifier, TriggerType type) {

		}

		private void on_events_inserted(Zeitgeist.TimeRange time_range, Zeitgeist.ResultSet events) {
			stdout.printf("event received\n");
			foreach (Event event in events) {
				string filename = event.get_subject(0).uri;
				stdout.printf("event received: %s\n", filename);
				Activity file_event = new Activity(filename, Activity.ActivityType.FILE);
				generator_handler.on_activity_started(file_event);
			}
		}
	}
}
