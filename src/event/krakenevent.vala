
namespace (Kraken) {

	class Event : Glib.Object {

		public enum EventType {
			FILE,
			URL,
			NETWORK,
			GEOPOSITION
		}

		private EventType type;
		private string url;
		private string path;

		public Event(EventType type){

		}
	}

}
