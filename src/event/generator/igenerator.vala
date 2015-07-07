namespace Kraken {

	interface IGenerator : Object {

		public abstract void generate(string? identifier, TriggerType type);
	}

}
