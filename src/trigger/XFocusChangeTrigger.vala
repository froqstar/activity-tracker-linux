Using Glib;
Using Xcb;

namespace Kraken {

	public class XFocusChangeTrigger : Glib.Object, Trigger {

		private Connection connection;
		private Window focused_window;

		public XFocusChangeTrigger() {
			connection = new Connection(null, null);
		}

		public override void activate() {
			while (true) {
				focused_window = get_focused_window();

				string window_title = get_window_title(focused_window);
				string window_class = get_window_class(focused_window);

				stdout.printf("window title: %s\nwindow class: %s\n", window_title, window_class);

				register_focus_change_event(focused_window);

				//TODO: send start event
				GenericEvent event = connection.wait_for_event();
				//TODO: if focus lost: send end event
			}
		}


		private Window get_focused_window() {
			GetInputFocusCookie cookie = connection.get_input_focus();
		    GetInputFocusReply window_focus = connection.get_input_focus_reply(cookie, out error);
		    return window_focus.focus;
		}

		private string get_window_title(Window w) {
			GetPropertyCookie propertyCookie = connection.get_property(
		    											false,
		                                              	w - 1, // don't know why, this is messed up...
		                                                Atom.WM_NAME,
		                                                Atom.STRING,
		                                                0, 100);
		    GetPropertyReply window_name = connection.get_property_reply(propertyCookie, out error);
		    return window_name.value_as_string();
		}

		private string get_window_class(Window w) {
			GetPropertyCookie propertyCookie2 = connection.get_property(
		    											false,
		                                              	w - 1, // don't know why, this is messed up...
		                                                Atom.WM_CLASS,
		                                                Atom.STRING,
		                                                0, 100);
		    GetPropertyReply program_name = connection.get_property_reply(propertyCookie2, out error);
		    return program_name.value_as_string();
		}

		private void register_focus_change_event(Window w) {
			connection.change_window_attributes (w, CW.EVENT_MASK, {EventMask.FOCUS_CHANGE});
		}
	}
}
