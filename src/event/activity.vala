
namespace Kraken {

	class Activity : Object {

		private DateTime start;
		private DateTime end;

		public enum ActivityType {
			APPLICATION,
			FILE,
			URL,
			WIFI_NETWORK,
			GEOPOSITION
		}

		public ActivityType activity_type {get; private set;}
		public string data {get; private set;}

		public Activity(string data, ActivityType type) {
			this.data = data;
			activity_type = type;

			start = new DateTime.now_utc();
			stdout.printf("start time : %s\n", start.to_string());
		}

	}

}
