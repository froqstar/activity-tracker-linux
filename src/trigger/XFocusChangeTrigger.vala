using Xcb;

namespace Kraken {

	class XFocusChangeTrigger : Object, Trigger {

		private Xcb.Connection connection;
		private Xcb.GenericError? error;
		private Xcb.Window focused_window;

		public XFocusChangeTrigger() {
			connection = new Xcb.Connection(null, null);
		}

		public void activate() {
			while (true) {
				focused_window = get_focused_window();

				string window_title = get_window_title(focused_window);
				string window_class = get_window_class(focused_window);

				stdout.printf("window title: %s\nwindow class: %s\n", window_title, window_class);

				register_focus_change_event(focused_window);

				//TODO: send start event
				//stdout.printf("waiting for event...");
				Xcb.GenericEvent event = connection.wait_for_event();
				//stdout.printf("received, looking into it...\n");

				//stdout.printf("event value: %d\n", event.response_type);

				switch (event.response_type & ~0x80) {
					case Xcb.EventMask.FOCUS_CHANGE:
						stdout.printf("focus change event detected. helllllll yesssssssssssssssssss\n");
						break;
				}
				//TODO: if focus lost: send end event
			}
		}


		private Xcb.Window get_focused_window() {
			Xcb.GetInputFocusCookie cookie = connection.get_input_focus();
		    Xcb.GetInputFocusReply window_focus = connection.get_input_focus_reply(cookie, out error);
		    return window_focus.focus;
		}

		private string get_window_title(Xcb.Window w) {
			Xcb.GetPropertyCookie propertyCookie = connection.get_property(
		    											false,
		                                              	w - 1, // don't know why, this is messed up...
		                                                Xcb.Atom.WM_NAME,
		                                                Xcb.Atom.STRING,
		                                                0, 100);
		    Xcb.GetPropertyReply window_name = connection.get_property_reply(propertyCookie, out error);
		    return window_name.value_as_string();
		}

		private string get_window_class(Xcb.Window w) {
			Xcb.GetPropertyCookie propertyCookie2 = connection.get_property(
		    											false,
		                                              	w - 1, // don't know why, this is messed up...
		                                                Xcb.Atom.WM_CLASS,
		                                                Xcb.Atom.STRING,
		                                                0, 100);
		    Xcb.GetPropertyReply program_name = connection.get_property_reply(propertyCookie2, out error);
		    return program_name.value_as_string();
		}

		private void register_focus_change_event(Xcb.Window w) {
			// http://xcb.freedesktop.org/tutorial/events/
			connection.flush();
			//uint32[] event_types = {Xcb.EventMask.EXPOSURE, Xcb.EventMask.VISIBILITY_CHANGE, Xcb.EventMask.FOCUS_CHANGE};
			uint32[] event_types = {Xcb.EventMask.FOCUS_CHANGE};
			connection.change_window_attributes (w, Xcb.CW.EVENT_MASK, event_types);
			connection.flush();
		}
	}
}
