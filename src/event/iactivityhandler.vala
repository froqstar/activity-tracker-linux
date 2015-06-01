namespace Kraken {

	interface IActivityHandler : Object {

		public abstract void register_generator_for_trigger(IGenerator generator, string identifier);

		public abstract void on_activity_started(Activity activity);

		public abstract void on_activity_finished(Activity activity);
	}

}
