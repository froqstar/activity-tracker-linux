//using DBus;

namespace Kraken {

	[DBus (name = "org.freedesktop.GeoClue2.Location")]
	class GeoClueLocation : Object {
		public double latitude{get; set;}
		public double longitude{get; set;}
		public double accuracy{get; set;}
		public string description{get; set;}
	}

	[DBus (name = "org.freedesktop.GeoClue2.Client")]
	interface GeoClueClient : Object {
		public abstract void start() throws IOError;
		public abstract void stop() throws IOError;

		public signal void location_updated(string old_location_path, string new_location_path);
	}

	[DBus (name = "org.freedesktop.GeoClue2.Manager")]
	interface GeoClueManager : Object {
		public abstract string get_client() throws IOError;
		public abstract void add_agent(string id) throws IOError;
	}



	class GeoClueTrigger : Object, ITrigger {

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

                manager.get_client();
                client.location_updated.connect(on_location_updated);
                client.start();
            } catch (IOError e) {
				stderr.printf ("%s\n", e.message);
			}
		}

		private void extract_location(string path) {
		/*
			GeoClueLocation location = Bus.get_proxy_sync(
        			BusType.SYSTEM,
        			"org.freedesktop.GeoClue2",
                  	path);
                  	*/
          	//stdout.printf("new location: %d|%d\n", location.latitude, location.longitude);
		}

		public void on_location_updated(string old_location_path, string new_location_path) {
			extract_location(new_location_path);
		}
	}
}
