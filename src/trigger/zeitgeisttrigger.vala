using Zeitgeist;

namespace Kraken {

	/*
	This Trigger uses the freedesktop.org zeitgeist service to gain access to its monitored events.
	*/
	class ZeitgeistTrigger : Object, ITrigger, IGenerator {

		private ITriggerHandler trigger_handler;
		private IGeneratorHandler generator_handler;

		private Monitor eventMonitor;

		public ZeitgeistTrigger(ITriggerHandler handler, IGeneratorHandler generator_handler) {
			this.trigger_handler = handler;
			this.generator_handler = generator_handler;
		}

		~ZeitgeistTrigger() {

		}

		public void activate() {
			GenericArray<Zeitgeist.Event> templates = new GenericArray<Zeitgeist.Event>();
			Event files = new Event();
			//files.add_subject(new Subject.full(interpretation=);
			templates.add(files);
			eventMonitor = new Monitor(new TimeRange.from_now (), templates);
    		eventMonitor.events_inserted.connect(on_events_inserted);
		}

		public void generate() {

		}

		private void on_events_inserted(Zeitgeist.TimeRange time_range, Zeitgeist.ResultSet events) {
			foreach (Event event in events) {
				stdout.printf("event received: %s\n", event.get_subject(0).uri);
			}
		}
	}
}
