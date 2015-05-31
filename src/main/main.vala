Using Gee;
Using Glib;

namespace Kraken {

	class KrakenDaemon : GLib.Object {

		List<Trigger> triggers;

		public static int main(string[] args) {

			Trigger xtrigger = new XFocusChangeTrigger();
			xtrigger.activate();

			//TODO: setup triggers
			//TODO: setup generators
			//TODO: setup logger

			//TODO: use Glib.timeout or sync?
			//http://stackoverflow.com/questions/12561695/efficient-daemon-in-vala

			MainLoop loop = new MainLoop ();
			loop.run ();

			return 0;
		}
	}

}
