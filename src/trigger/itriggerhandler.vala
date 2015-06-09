namespace Kraken {

	interface ITriggerHandler : Object {
		public abstract void on_trigger_fired(string? identifier);
	}

}
