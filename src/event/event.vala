
namespace (Kraken) {

	class Event : Glib.Object {

		public enum EventType {
			FILE,
			URL,
			NETWORK,
			GEOPOSITION
		}

		public EventType type {get};
		public string path {get; set};
		public string url {get; set};

		public Event(EventType type) {
			this.type = type;
		}

	}

}
