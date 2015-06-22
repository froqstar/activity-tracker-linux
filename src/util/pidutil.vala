using Gee;

namespace Kraken {

	public static int getPIDFromExecutable(string executableName) {
		string stdout;
		string stderr;
		int status;

		Process.spawn_command_line_sync ("pidof " + executableName,
									out stdout,
									out stderr,
									out status);
		return int.parse(stdout.split(" ")[0]);
	}
}
