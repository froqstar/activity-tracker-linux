//using DBus;

namespace Kraken {

	[DBus (name = "org.freedesktop.GeoClue2.Location")]
	interface GeoClueLocation : Object {
		public abstract double latitude {owned get;}
		public abstract double longitude {owned get;}
		public abstract double accuracy {owned get;}
		public abstract ObjectPath description {owned get;}
	}

	[DBus (name = "org.freedesktop.GeoClue2.Client")]
	interface GeoClueClient : Object {
		public abstract ObjectPath location {owned get;}
		public abstract uint32 distance_threshold {owned get; owned set;}
		public abstract string desktop_id {owned get; owned set;}
		public abstract uint32 requested_accuracy_level {owned get; owned set;}

		public abstract void start() throws IOError;
		public abstract void stop() throws IOError;

		public signal void location_updated(string old_location_path, string new_location_path);
	}

	[DBus (name = "org.freedesktop.GeoClue2.Manager")]
	interface GeoClueManager : Object {
		public abstract ObjectPath get_client() throws IOError;
		public abstract void add_agent(string id) throws IOError;
	}



	class GeoClueTrigger : Object, ITrigger {

		// the distance in meters to fire an event
		private static int distance_threshold = 50;

		private ITriggerHandler handler;

		private DBus.Connection dbus_connection;

		private GeoClueManager manager;
		private GeoClueClient client;

		public GeoClueTrigger(ITriggerHandler handler) {
			this.handler = handler;
		}

		public void activate() {
    		try {
        		manager = Bus.get_proxy_sync(
        			BusType.SYSTEM,
        			"org.freedesktop.GeoClue2",
                  	"/org/freedesktop/GeoClue2/Manager");

                client = Bus.get_proxy_sync(
        			BusType.SYSTEM,
        			"org.freedesktop.GeoClue2",
                  	manager.get_client());

				client.desktop_id = "kraken.me";
				client.distance_threshold = distance_threshold;

                client.location_updated.connect(on_location_updated);
                client.start();

                extract_location(client.location);
            } catch (IOError e) {
				stderr.printf ("%s\n", e.message);
			}
		}

		private void extract_location(string path) {
			GeoClueLocation location = Bus.get_proxy_sync(
        			BusType.SYSTEM,
        			"org.freedesktop.GeoClue2",
                  	path);

          	stdout.printf("new location: %f|%f\n", location.latitude, location.longitude);
		}

		public void on_location_updated(string old_location_path, string new_location_path) {
			stdout.printf("location updated.\n");
			extract_location(new_location_path);
		}
	}
}
