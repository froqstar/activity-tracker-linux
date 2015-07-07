namespace Kraken {

	interface ILogger : Object {
		public abstract void log(string content);

		public abstract void log_start(Activity activity);

		public abstract void log_end(Activity activity);
	}

}
