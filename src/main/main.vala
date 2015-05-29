Using Gee;
Using Glib;

namespace (Kraken) {

	class KrakenDaemon : GLib.Object {

		List<KrakenTrigger> triggers;

		public static int main(string[] args) {

			//TODO: use Glib.MainLoop
			http://stackoverflow.com/questions/12561695/efficient-daemon-in-vala


			Xcb.GenericError? error;

			Thread.usleep (200000);

			stdout.printf("Active window:\n");

		    Xcb.Connection connection = new Xcb.Connection(null, null);

		    Xcb.GetInputFocusCookie cookie = connection.get_input_focus();
		    Xcb.GetInputFocusReply window_focus = connection.get_input_focus_reply(cookie, out error);

		    stdout.printf("Focus = %d\n", (int) window_focus.focus);

		    Xcb.GetPropertyCookie propertyCookie = connection.get_property(
		    											false,
		                                              	window_focus.focus - 1, // don't know why, this is messed up...
		                                                Xcb.Atom.WM_NAME,
		                                                Xcb.Atom.STRING,
		                                                0, 100);

		    Xcb.GetPropertyReply window_name = connection.get_property_reply(propertyCookie, out error);

		    stdout.printf("Window Title: %s\n", window_name.value_as_string());

		    Xcb.GetPropertyCookie propertyCookie2 = connection.get_property(
		    											false,
		                                              	window_focus.focus - 1, // don't know why, this is messed up...
		                                                Xcb.Atom.WM_CLASS,
		                                                Xcb.Atom.STRING,
		                                                0, 100);

		    Xcb.GetPropertyReply program_name = connection.get_property_reply(propertyCookie2, out error);

		    stdout.printf("Program Name: %s\n", program_name.value_as_string());

		    /*if(error != null) {
		    	stdout.printf("Error = %d", error.error_code);
			}

		    stdout.printf("Type = %d\n", (int) window_name.type);
		    stdout.printf("Value length = %d\n", window_name.value_length());
		    stdout.printf("Value format = %d\n", window_name.format);

		    if(window_name.type == Xcb.Atom.STRING) {
		    	stdout.printf("Window Title: %s\n", window_name.value_as_string());
		    }*/

		    return 0;
		}
	}

}
