namespace Kraken {

	interface IGeneratorHandler : Object {

		public abstract void register_generator_for_file(IGenerator generator, string path);

		public abstract void register_generator_for_window_class(IGenerator generator, string window_class);

		public abstract void on_activity_started(Activity activity);

		public abstract void on_activity_finished(Activity? activity);
	}

}
