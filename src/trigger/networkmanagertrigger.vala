//using DBus;

namespace Kraken {

	[DBus (name = "org.freedesktop.NetworkManager")]
	interface NetworkManager : Object {
		public abstract ObjectPath activating_connection {owned get;}
		public abstract ObjectPath primary_connection {owned get;}
		public abstract string primary_connection_type {owned get;}
		public signal void state_changed(uint32 nm_state);
	}

	[DBus (name = "org.freedesktop.NetworkManager.Connection.Active")]
	interface Connection : Object {
		public abstract string id {owned get;}
		//public abstract string type {owned get;}
	}


	/*
	This Trigger uses the freedesktop.org NetworkManager to determine the
	currently active wifi network of the machine and get notified of network changes
	*/
	class NetworkManagerTrigger : Object, ITrigger, IGenerator {

		// the dbus address of the NetworkManager service
		private static string NM_DBUS_ADDRESS = "org.freedesktop.NetworkManager";
		private static string NM_DBUS_PATH = "/org/freedesktop/NetworkManager";

		private ITriggerHandler trigger_handler;
		private IGeneratorHandler generator_handler;

		private NetworkManager manager;

		private Activity active_network = null;

		public NetworkManagerTrigger(ITriggerHandler handler, IGeneratorHandler generator_handler) {
			this.trigger_handler = handler;
			this.generator_handler = generator_handler;
		}

		~NetworkManagerTrigger() {

		}

		public void activate() {
    		try {
        		manager = Bus.get_proxy_sync(
        			BusType.SYSTEM,
        			NM_DBUS_ADDRESS,
                  	NM_DBUS_PATH);
				manager.state_changed.connect(on_nm_state_changed);
				report_active_wifi_ssid();
            } catch (IOError e) {
				stderr.printf ("%s\n", e.message);
				stdout.printf("NetworkManager not available, network updates won't work.\n");
			}
		}

		public void generate(string? identifier, TriggerType type) {

		}

		private void on_nm_state_changed(uint32 nm_state) {
			// https://developer.gnome.org/NetworkManager/unstable/spec.html#type-NM_STATE
			if (nm_state > 50) { // connected
				stdout.printf("connected to network.\n");
				report_active_wifi_ssid();
			} else { // disconnected
				stdout.printf("disconnected from network.\n");
				if (active_network != null) {
					stdout.printf("finishing network activity.\n");
					generator_handler.on_activity_finished(active_network);
					active_network = null;
				}
			}
			stdout.printf("network state %d.\n", (int) nm_state);
		}

		private void report_active_wifi_ssid() {
			try {
				//only report wifi ssids
				if (manager.primary_connection_type == "802-11-wireless") {
					string connection_path = manager.primary_connection;
					Connection conn = Bus.get_proxy_sync(
							BusType.SYSTEM,
							NM_DBUS_ADDRESS,
				          	connection_path);
				    string ssid = conn.id;

				    stdout.printf("SSID = %s\n", ssid);
			    	active_network = new Activity(ssid, Activity.ActivityType.WIFI_NETWORK);
      				generator_handler.on_activity_started(active_network);
      				stdout.printf("reported\n");
		        } else {
		        	stdout.printf("Active connection is no wifi, skipping.\n");
		        }
	        } catch (IOError e) {
				stderr.printf ("%s\n", e.message);
				stdout.printf("Active connection not available.\n");
			}
		}
	}
}
