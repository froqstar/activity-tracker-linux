
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
		public string application {get; private set;}
		public string path {get; set;}
		public string url {get; set;}

		public Activity(string application, ActivityType type) {
			this.application = application;
			activity_type = type;

			start = new DateTime.now_utc();
			stdout.printf("start time : %s\n", start.to_string());
		}

	}

}
