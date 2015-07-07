namespace Kraken {

	interface ILogger : Object {
		public abstract void log(string content);

		public abstract void log_start(KrakenEvent activity);

		public abstract void log_end(KrakenEvent activity);

		public abstract void sync();
	}

}
