using Gee;

namespace Kraken {

	// get PID of a process, based off its executable name. returns 0 if no PID could be found
	public static int getPIDFromExecutable(string executableName) {
		string stdout;
		string stderr;
		int status;

		Process.spawn_command_line_sync ("pidof " + executableName,
									out stdout,
									out stderr,
									out status);
		string[] pids = stdout.split(" ");

		if (pids.length > 0) {
			return int.parse(stdout.split(" ")[0]);
		} else {
			return 0;
		}
	}
}
