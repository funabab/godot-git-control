
class CommandManager:

	var git_manager;
	var git_path;
	var process;
	var cmd_queue = [];

	const CMD_GIT_BRANCH = 1;
	const GIT_CREATE_BRANCH = 2;
	const CMD_GIT_CHECKOUT = 3;
	const GIT_BRANCH_DELETE = 4;
	const CMD_GIT_LOG = 5;
	const CMD_GIT_STATUS = 6;
	const CMD_GIT_TAG = 7;
	const CMD_GIT_COMMIT = 8;
	const CMD_GIT_REVERT = 9;
	const CMD_GIT_REBASE = 10;
	const CMD_GIT_MERGE = 11;
	const CMD_GIT_FETCH = 12;
	const CMD_GIT_REMOTE = 13;
	const CMD_GIT_PULL = 14;

	func _init(git_manager):
		self.git_manager = git_manager;
		self.git_path = self.find_git_path();
		self.process = Thread.new();
		pass

	func is_running():
		return self.process.is_active();
		pass

	func queue_cmd(cmd):
		self.cmd_queue.push_back(cmd);
		self.process_queue();
		pass

	func process_queue():
		if (self.cmd_queue.empty() || self.is_running()):
			return;
		self.process.start(self, "_process_cmd", self.cmd_queue[0]);
		pass

	func _process_cmd(cmd):
		for command in cmd._get_commands():
			cmd._push_result(self.run_command(command));
			pass
		call_deferred("_cmd_processed", cmd);
		pass

	func _cmd_processed(cmd):
		self.process.wait_to_finish();
		if (self.git_manager.has_method("_on_cmd_processed")):
			self.git_manager._on_cmd_processed(cmd);
		self.cmd_queue.pop_front();
		self.process_queue();
		pass

	func run_command(arguments, command_name = null):
		if (command_name == null):
			command_name = self.git_path;
		var results = [];
		OS.execute(command_name, arguments, true, results);
		return results;
		pass

	func find_git_path():
		var os_name = OS.get_name().to_lower();
		var command_result;
		if (os_name == "x11"):
			command_result = self.run_command(["git"], "which");
			var split = command_result[0].c_escape().split("\\n", false);
			return split[0].strip_edges();
		elif (os_name == "osx"):
			command_result = self.run_command(["git"], "which");
			var split = command_result[0].c_escape().split("\\n", false);
			return split[0].strip_edges();
		elif (os_name == "windows"):
			return self.run_command(["git"], "where")[0].strip_edges();
		pass