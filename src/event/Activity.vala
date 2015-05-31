
namespace Kraken {

	class Activity : Object {

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
		}

	}

}
