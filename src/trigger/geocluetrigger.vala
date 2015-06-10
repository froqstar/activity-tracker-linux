//using DBus;

namespace Kraken {

	[DBus (name = "org.freedesktop.GeoClue2.Location")]
	interface GeoClueLocation : Object {
		public abstract double latitude {owned get;}
		public abstract double longitude {owned get;}
		public abstract double accuracy {owned get;}
		public abstract string description {owned get;}
	}

	[DBus (name = "org.freedesktop.GeoClue2.Client")]
	interface GeoClueClient : Object {
		public abstract ObjectPath location {owned get;}
		public abstract uint32 distance_threshold {owned get; owned set;}
		public abstract string desktop_id {owned get; owned set;}
		public abstract uint32 requested_accuracy_level {owned get; owned set;}

		public abstract void start() throws IOError;
		public abstract void stop() throws IOError;

		public signal void location_updated(ObjectPath old_location_path, ObjectPath new_location_path);
	}

	[DBus (name = "org.freedesktop.GeoClue2.Manager")]
	interface GeoClueManager : Object {
		public abstract ObjectPath get_client() throws IOError;
		//public abstract void add_agent(string id) throws IOError;
	}


	/*
	This Trigger uses the freedesktop.org GeoClue2 service to determine the
	current location of the machine and get notified of location changes
	exceeding a certain threshold.
	*/
	class GeoClueTrigger : Object, ITrigger, IGenerator {

		// the dbus address of the GeoClue2 service
		private static string GEOCLUE_DBUS_ADDRESS = "org.freedesktop.GeoClue2";
		//this value is used to authenticate the app to obtain permission to use the GeoClue2 service
		private static string DESKTOP_ID = "kraken.me";
		// the distance in meters to fire an event
		private static int DISTANCE_THRESHOLD = 50;

		private ITriggerHandler trigger_handler;
		private IGeneratorHandler generator_handler;

		private GeoClueManager manager;
		private GeoClueClient client;

		public GeoClueTrigger(ITriggerHandler handler, IGeneratorHandler generator_handler) {
			this.trigger_handler = handler;
			this.generator_handler = generator_handler;
		}

		~GeoClueTrigger() {
			if (client != null) {
				client.stop();
			}
		}

		public void activate() {
    		try {
        		manager = Bus.get_proxy_sync(
        			BusType.SYSTEM,
        			GEOCLUE_DBUS_ADDRESS,
                  	"/org/freedesktop/GeoClue2/Manager");

                client = Bus.get_proxy_sync(
        			BusType.SYSTEM,
        			GEOCLUE_DBUS_ADDRESS,
                  	manager.get_client());

				client.desktop_id = DESKTOP_ID;
				client.distance_threshold = DISTANCE_THRESHOLD;

                client.location_updated.connect(on_location_updated);
                client.start(); //start receiving updates
            } catch (IOError e) {
				stderr.printf ("%s\n", e.message);
				stdout.printf("GeoClue not available, location updates won't work.\n");
			}
		}

		public void generate() {

		}

		public void on_location_updated(ObjectPath old_location_path, ObjectPath new_location_path) {
			try {
				GeoClueLocation location = Bus.get_proxy_sync(
		    			BusType.SYSTEM,
		    			GEOCLUE_DBUS_ADDRESS,
		              	new_location_path);

		      	stdout.printf("new location: %f|%f\n", location.latitude, location.longitude);

				Activity activity = new Activity("%f|%f".printf(location.latitude, location.longitude), Activity.ActivityType.GEOPOSITION);
		      	generator_handler.on_activity_started(activity);
			} catch (IOError e) {
				stderr.printf ("%s\n", e.message);
			}
		}
	}
}
