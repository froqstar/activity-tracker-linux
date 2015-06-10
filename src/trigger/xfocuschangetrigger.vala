using Xcb;

namespace Kraken {

	/*
	This class leverages the X window system to extract currently focused windows
	and get notified on focus changes.
	*/
	class XFocusChangeTrigger : Object, ITrigger {

		private Xcb.Connection connection;
		private Xcb.GenericError? error;
		private Xcb.Window focused_window;

		private ITriggerHandler handler;

		private unowned Thread<void*> looperthread;
		private bool enabled = false;

		public XFocusChangeTrigger(ITriggerHandler handler) {
			connection = new Xcb.Connection(null, null);
			this.handler = handler;
		}

		~XFocusChangeTrigger() {
			enabled = false;
		}

		public void activate() {
			enabled = true;
			try {
				// we need to process events in a separate thread because waiting
				// for them is a blocking operation
				looperthread = Thread.create<void*> (loop, true);
			} catch (ThreadError e) {
				stderr.printf (e.message);
				enabled = false;
			}
		}

		public void* loop() {
			while (enabled) {
				focused_window = get_focused_window();
				//stdout.printf("focused window: %d\n", (int) focused_window);

				//string window_title = get_window_title(focused_window);
				string window_class = get_window_class(focused_window);
				//stdout.printf("window title: %s\nwindow class: %s\n\n\n", window_title, window_class);

				handler.on_trigger_fired(window_class);

				register_focus_change_event(focused_window);

				int response_type = 0;
				while ((response_type = connection.wait_for_event().response_type) != Xcb.FOCUS_OUT) {
					//stdout.printf("X event type %d\n", response_type);
				}
				//stdout.printf("FOCUS CHANGE EVENT\n");

				deregister_focus_change_event(focused_window);
			}
			return null;
		}


		private Xcb.Window get_focused_window() {
			Xcb.GetInputFocusCookie cookie = connection.get_input_focus();
		    Xcb.GetInputFocusReply window_focus = connection.get_input_focus_reply(cookie, out error);
		    return window_focus.focus;
		}

		// get the title of the window
		private string get_window_title(Xcb.Window w) {
			Xcb.GetPropertyCookie propertyCookie = connection.get_property(
		    											false,
		                                              	w - 1, // don't know why, this is messed up...
		                                                Xcb.Atom.WM_NAME,
		                                                Xcb.Atom.STRING,
		                                                0, 100);
		    Xcb.GetPropertyReply window_name = connection.get_property_reply(propertyCookie, out error);
			if (window_name != null) {
		    	return window_name.value_as_string();
		    } else {
		    	return null;
		    }
		}

		// get the class (~process-name) of the window
		private string get_window_class(Xcb.Window w) {
			Xcb.GetPropertyCookie propertyCookie2 = connection.get_property(
		    											false,
		                                              	w - 1, // don't know why, this is messed up...
		                                                Xcb.Atom.WM_CLASS,
		                                                Xcb.Atom.STRING,
		                                                0, 100);
		    Xcb.GetPropertyReply program_name = connection.get_property_reply(propertyCookie2, out error);
		    if (program_name != null) {
		    	return program_name.value_as_string();
		    } else {
		    	return null;
		    }
		}

		// register at the X-server for FOCUS_CHANGE events of a window
		private void register_focus_change_event(Xcb.Window w) {
			// http://xcb.freedesktop.org/tutorial/events/
			connection.flush();
			uint32[] event_types = {Xcb.EventMask.FOCUS_CHANGE};
			connection.change_window_attributes (w, Xcb.CW.EVENT_MASK, event_types);
			connection.flush(); //make sure our request gets processed before doing anything else
		}

		private void deregister_focus_change_event(Xcb.Window w) {
			connection.flush();
			uint32[] event_types = {0};
			connection.change_window_attributes (w, Xcb.CW.EVENT_MASK, event_types);
			connection.flush();
		}
	}
}
