
namespace Kraken {

	class Activity : Object {

		private DateTime start;
		private DateTime end;

		public enum ActivityType {
			FILE,
			URL,
			NETWORK,
			GEOPOSITION
		}

		public ActivityType activity_type {get; private set;}
		public string path {get; set;}
		public string url {get; set;}

		public Activity(ActivityType type) {
			activity_type = type;

			start = new DateTime.now_local();
			stdout.printf("start time : %s\n", start.to_string());
		}

	}

}
