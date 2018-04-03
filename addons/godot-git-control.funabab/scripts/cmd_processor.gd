extends Object

var git;
var process;
var cmd_queue = [];

var kill = false;

func _init(git):
	self.git = git;
	self.git.connect("action_event", self, "_on_action_event");
	process = Thread.new();
	pass

func _on_action_event(what, args):
	if what == git.action.KILL_ALL_PROCESS:
		kill = true;
		if !process.is_active():
			kill_process();
	pass

func kill_process():
	call_deferred("free");
	pass

func queue_cmd(cmd):
	if !git.git_path:
		return;
	cmd_queue.push_back(cmd);
	process_queue();
	pass

func is_running():
	return process.is_active();

func process_queue():
	if (cmd_queue.empty() || is_running() || kill):
		return;
	process.start(self, "_process_cmd", cmd_queue.front());
	pass

func _process_cmd(cmd):
	for command in cmd.commands:
		if kill:
			break;
		cmd.results.append(self.run_git_command(command));
	cmd_queue.pop_front();
	call_deferred("_cmd_processed", cmd);
	pass

func run_command(arguments, command):
	var results = [];
	OS.execute(command, arguments, true, results);
	return results;
	pass

func run_git_command(arguments):
	if !git.git_path:
		return [];
	return run_command(arguments, git.git_path);
	pass

func _cmd_processed(cmd):
	process.wait_to_finish();
	if !kill:
		git._on_cmd_processed(cmd);
		process_queue();
	else:
		kill_process();
	pass
