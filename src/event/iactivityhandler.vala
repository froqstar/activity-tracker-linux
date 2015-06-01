namespace Kraken {

	interface IActivityHandler : Object {

		public abstract void on_activity_started(Activity activity);

		public abstract void on_activity_finished(Activity activity);
	}

}
