
namespace Kraken {

	class KrakenEvent : Object {

		public DateTime start {get; private set;}
		public DateTime end {get; set;}

		public enum KrakenEventType {
			APPLICATION,
			FILE,
			URL,
			WIFI_NETWORK,
			GEOPOSITION
		}

		public KrakenEventType activity_type {get; private set;}
		public string data {get; private set;}

		public KrakenEvent(string data, KrakenEventType type) {
			this.data = data;
			activity_type = type;

			start = new DateTime.now_utc();
			stdout.printf("start time : %s\n", start.to_string());
		}

	}

}
