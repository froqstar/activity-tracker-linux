namespace Kraken {

	public enum TriggerType {
		FILE,
		FOCUS
	}

	interface ITrigger : Object {
		public abstract void activate();
	}

}
