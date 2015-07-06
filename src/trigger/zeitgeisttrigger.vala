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

			GenericArray<Zeitgeist.Event> templates = new GenericArray<Zeitgeist.Event>();
			Event files = new Event();
			files.add_subject(new Subject.full(null, ZG.ACCESS_EVENT, null, null, null, null, null));
			templates.add(files);
			eventMonitor = new Monitor(new TimeRange.from_now (), templates);
    		eventMonitor.events_inserted.connect(on_events_inserted);
		}

		~ZeitgeistTrigger() {

		}

		public void activate() {
			log.install_monitor(eventMonitor);
		}

		public void generate() {

		}

		private void on_events_inserted(Zeitgeist.TimeRange time_range, Zeitgeist.ResultSet events) {
			foreach (Event event in events) {
				string filename = event.get_subject(0).uri;
				stdout.printf("event received: %s\n", filename);
				Activity file_event = new Activity(filename, Activity.ActivityType.FILE);
				generator_handler.on_activity_started(file_event);
			}
		}
	}
}
