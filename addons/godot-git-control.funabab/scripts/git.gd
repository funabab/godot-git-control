extends Object

var CMD = preload("res://addons/godot-git-control.funabab/scripts/cmd.gd");
var CMDProcessor;
var Settings;
var Lang;
var GitignoreManager

var cl_output;
var cl_branch;
var cl_workspace;
var cl_remote;

var base_control;
var git_path;
var terminal_path;

var timer_auto_refresh;
var timer_auto_commit;

signal action_event;
signal cmd_processed;

var action = preload("res://addons/godot-git-control.funabab/scripts/git_actions.gd");
var dialog;

func _init(base_control, settings, lang):
	self.base_control = base_control;
	Settings = settings;
	Lang = lang;
	GitignoreManager = load("res://addons/godot-git-control.funabab/scripts/gitignore_manager.gd").new();
	dialog = load("res://addons/godot-git-control.funabab/scripts/git_dialog_manager.gd").new(self);
	CMDProcessor = load("res://addons/godot-git-control.funabab/scripts/cmd_processor.gd").new(self);

	cl_output = load("res://addons/godot-git-control.funabab/scripts/cl_output.gd").new();
	cl_output._initialize(self);

	cl_branch = load("res://addons/godot-git-control.funabab/scripts/cl_branch.gd").new();
	cl_branch._initialize(self);

	cl_workspace = load("res://addons/godot-git-control.funabab/scripts/cl_workspace.gd").new();
	cl_workspace._initialize(self);

#	cl_remote = load("res://addons/godot-git-control.funabab/scripts/cl_remote.gd").new();
#	cl_remote._initialize(self);
	pass

func initialize():
	set_git_path();
	git_path = Settings.get("git_path");
	terminal_path = get_terminal_path();
	if !terminal_path:
		call_action(action.UI_TERMINAL_NOT_FOUND);
	set_auto_refresh();
	set_auto_commit();
	start(true);
	pass

func set_auto_refresh():
	var duration = Settings.get_as_int("auto_refresh_duration");
	if duration == 0:
		return;
	##call_action(action.GIT_AUTO_REFRESH_ACTIVATED);
	timer_auto_refresh = Timer.new();
	timer_auto_refresh.wait_time = duration;
	timer_auto_refresh.one_shot = false;
	timer_auto_refresh.autostart = false;
	timer_auto_refresh.connect("timeout", self, "run_auto_refresh");
	base_control.add_child(timer_auto_refresh);
	pass

func set_auto_commit():
	var duration = Settings.get_as_int("auto_commit_duration");
	if duration == 0:
		return;

#	call_action(action.GIT_AUTO_COMMIT_ACTIVATED);
	print_output(Lang.tr("auto_commit_active"));
	timer_auto_commit = Timer.new();
	timer_auto_commit.wait_time = duration;
	timer_auto_commit.one_shot = false;
	timer_auto_commit.autostart = false;
	timer_auto_commit.connect("timeout", self, "run_auto_commit");
	base_control.add_child(timer_auto_commit);
	pass

func start_timers():
	if timer_auto_refresh:
		timer_auto_refresh.start();
	if timer_auto_commit:
		timer_auto_commit.start();
	pass

func stop_timers():
	if timer_auto_refresh:
		timer_auto_refresh.stop();
	if timer_auto_commit:
		timer_auto_commit.stop();
	pass

func check_fatal_error():
	var error = false;
	if !git_path:
		call_action(action.FATAL_ERROR);
		print_output(Lang.tr("git_not_found"));
		error = true;

	elif !is_git_path_valid():
		call_action(action.FATAL_ERROR);
		print_output(Lang.tr("git_path_not_valid"));
		error = true;

	elif !is_git_initialized():
		call_action(action.FATAL_ERROR);
		print_output(Lang.tr("git_not_initialized") % action.get_action_as_text(action.GIT_INITIALIZE));
		error = true;
	if error:
		stop_timers();
	return error;
	pass

func start(is_started = false):
	if check_fatal_error():
		return;
	if Settings.get("create_gitignore_file"):
		GitignoreManager.initialize();
	var is_restart = !is_started;
	call_action(action.START_PROCESS, is_restart);
	start_timers();
	run_refresh();
	pass

func call_action(what, args = null):
	var a = 0;
	if typeof(what) == TYPE_INT:
		a = what;
	elif typeof(what) == TYPE_STRING:
		a = action.get_action_from_text(what);
	if a == 0:
		return;

	if !handle_action(a, args):
		emit_signal("action_event", a, args);
	pass

func handle_action(what, args):
	match(what):

		action.GIT_INITIALIZE:
			run_cmd_init();

		action.GIT_CREATE_BRANCH:
			dialog.show(dialog.VIEW_CREATE_BRANCH);
			return true;

		action.GIT_CHECKOUT_BRANCH:
			run_cmd_checkout(cl_branch.branches[args]);

		action.GIT_DIFF:
			run_cmd_diff();
			return true;

		action.GIT_DELETE_BRANCH:
			dialog.show(dialog.VIEW_DELETE_BRANCH, cl_branch.branches[args]);
			return true;

		action.GIT_MERGE_BRANCH:
			if cl_branch.get_branches_count() > 1:
				dialog.show(dialog.VIEW_MERGE_BRANCH);
			else:
				print_output(Lang.tr("no_branch_to_merge"));
			return true;

		action.GIT_REBASE:
			if cl_branch.get_branches_count() > 1:
				dialog.show(dialog.VIEW_REBASE);
			else:
				print_output(Lang.tr("no_branch_to_rebase"));
			return true;

		action.GIT_CREATE_TAG:
			dialog.show(dialog.VIEW_CREATE_TAG);
			return true;

		action.GIT_SHOW_SETTINGS:
			dialog.show(dialog.VIEW_SETTINGS);
			return true;

		action.GIT_GITIGNORE_MANAGER:
			dialog.show(dialog.VIEW_GITIGNORE);
			return true;

		action.GIT_WORKSPACE_OBJECT_SELECTION:
			cl_workspace.set_object_selection(args.idx, args.select);
			return true;

		action.GIT_WORKSPACE_COMMIT_SELECTED_OBJECTS:
			if cl_workspace.get_all_selected_object_path().size() > 0:
				dialog.show(dialog.VIEW_COMMIT_MSG);
			else:
				print_output(Lang.tr("nothing_object_seleted_to_commit"));
			return true;

		action.GIT_WORKSPACE_REVERT_SELECTED_OBJECTS:
			if cl_workspace.get_all_selected_object_path().size() > 0:
				dialog.show(dialog.VIEW_REVERT_WORKSPACE);
			else:
				print_output(Lang.tr("nothing_object_seleted_to_revert"));
			return true;

		action.SHOW_TERMINAL:
			OS.shell_open(terminal_path);
			return true;

	return false;
	pass

func print_output(what):
	call_action(action.UI_WRITE_CONSOLE_OUTPUT, what);
	pass

func show_dialog(what, args = null):
	dialog.show(what, args);
	pass

func run_cmd_custom(custom_cmd):
	if custom_cmd.empty() || (custom_cmd.size() == 1 && custom_cmd[0] == "git"):
		return;

	if custom_cmd[0] == "git":
		custom_cmd.remove(0);
	else:
		print_output(Lang.tr("not_a_git_command"));
		return;

	var cmd = CMD.new(CMD.CUSTOM);
	cmd.show_result_in_output = true;

	cmd.push_command(custom_cmd);
	CMDProcessor.queue_cmd(cmd);
	run_refresh(false);
	pass

func run_refresh(show_in_console = false, check_init_error = false):
	if check_init_error && check_fatal_error():
		return;

	run_cmd_branch(show_in_console);
	run_cmd_status(show_in_console);
#	run_cmd_remote();
	pass

func run_auto_refresh():
	run_refresh();
	pass

func run_auto_commit():
	if cl_workspace.get_all_selected_object_path().size() == 0:
		return;
	var d = OS.get_datetime();
	var datetime = "%02d/%02d/%d %02d:%02d:%02d" % [d.day, d.month, d.year, d.hour, d.minute, d.second];
	run_cmd_commit(cl_workspace.get_all_selected_object_path(), Lang.tr("auto_commit_at") % datetime);
	pass

func run_cmd_branch(show_in_console = false):
	var cmd = CMD.new(CMD.GIT_BRANCH);
	cmd.show_cmd_in_terminal = show_in_console;
	cmd.show_result_in_terminal = show_in_console;
	cmd.push_command(["branch"]);
	CMDProcessor.queue_cmd(cmd);
	pass

func run_cmd_status(show_in_console = false):
	var cmd = CMD.new(CMD.GIT_STATUS);
	cmd.show_cmd_in_terminal = show_in_console;
	cmd.push_command(["status", "--porcelain", "--untracked-files=all"]);
	CMDProcessor.queue_cmd(cmd);
	pass

func run_cmd_init():
	var cmd = CMD.new(CMD.GIT_INIT);
	cmd.show_result_in_output = true;
	cmd.push_command(["init"]);
	CMDProcessor.queue_cmd(cmd);
	pass

func run_cmd_diff():
	var cmd = CMD.new(CMD.GIT_DIFF);
	cmd.push_command(["--no-pager", "diff"]);
	CMDProcessor.queue_cmd(cmd);
	pass

func run_cmd_rebase(rebase_branch):
	var cmd = CMD.new(CMD.GIT_REBASE);
	cmd.show_result_in_output = true;
	cmd.show_result_in_terminal = true;
	cmd.push_command(["rebase", rebase_branch]);
	CMDProcessor.queue_cmd(cmd);
	pass

func run_cmd_merge(merge_branch, no_fast_forward):
	var cmd = CMD.new(CMD.GIT_MERGE);
	cmd.show_result_in_output = true;
	cmd.show_result_in_terminal = true;

	if (no_fast_forward):
		cmd.push_command(["merge", "--no-ff", merge_branch]);
	else:
		cmd.push_command(["merge", merge_branch]);
	CMDProcessor.queue_cmd(cmd);
	pass

func run_cmd_log():
	var cmd = CMD.new(CMD.GIT_LOG);
	cmd.show_result_in_output = true;
	cmd.push_command(["--no-pager", "log", "--format=fuller", "--graph", "--all", "--decorate"]);
	CMDProcessor.queue_cmd(cmd);
	pass

func run_cmd_checkout(branch_name, show_in_console = true):
	var cmd = CMD.new(CMD.GIT_CHECKOUT);
	cmd.show_result_in_output = true;
	cmd.show_result_in_terminal = true;
	cmd.push_command(["checkout", branch_name]);
	CMDProcessor.queue_cmd(cmd);
	run_refresh(false);
	pass

#func run_cmd_remote():
#	var cmd = CMD.new(CMD.GIT_REMOTE);
#	cmd.show_result_in_terminal = false;
#	cmd.push_command(["remote", "-v"]);
#	CMDProcessor.queue_cmd(cmd);
#	pass

func run_create_branch(new_branch, checkout = false):
	var cmd = CMD.new(CMD.CREATE_BRANCH);
	cmd.show_result_in_output = true;
	cmd.show_result_in_terminal = true;
	cmd.push_command(["branch", new_branch]);
	CMDProcessor.queue_cmd(cmd);
	if (checkout):
		run_cmd_checkout(new_branch, false);
	else:
		run_refresh(false);
	pass

func run_cmd_commit(files_to_commit, commit_message):
	var cmd = CMD.new(CMD.GIT_COMMIT);
	cmd.show_result_in_output = true;
	cmd.show_result_in_terminal = true;
	cmd.push_command(["add", "--"] + files_to_commit);
	cmd.push_command(["commit", "--allow-empty-message", "-m", commit_message]);
	CMDProcessor.queue_cmd(cmd);
	run_refresh(false);
	pass

func run_cmd_revert(selected_files):
	var cmd = CMD.new(CMD.GIT_REVERT);
	cmd.show_result_in_output = true;
	cmd.show_result_in_terminal = true;
	cmd.push_command(["checkout", "--"] + selected_files);
	CMDProcessor.queue_cmd(cmd);
	run_refresh(false);
	pass

func run_cmd_tag(tag_name, tag_commit_ref, tag_message, force = false):
	var cmd = CMD.new(CMD.GIT_TAG);
	cmd.show_result_in_output = true;
	cmd.show_result_in_terminal = true;

	var command = ["tag", "-a", tag_name];
	if (force):
		command.push_back("--force");
	if (!tag_message.empty()):
		command.push_back("-m");
		command.push_back(tag_message);
	if (!tag_commit_ref.empty()):
		command.push_back(tag_commit_ref);

	cmd.push_command(command);
	CMDProcessor.queue_cmd(cmd);
	pass

func run_branch_delete(branch_name, force_delete = false):
	var cmd = CMD.new(CMD.BRANCH_DELETE);
	cmd.show_result_in_output = true;
	cmd.show_result_in_terminal = true;

	if (force_delete):
		cmd.push_command(["branch", "-D", branch_name]);
	else:
		cmd.push_command(["branch", "-d", branch_name]);
	CMDProcessor.queue_cmd(cmd);
	run_refresh(false);
	pass

func kill_process():
	base_control == null;
	if timer_auto_refresh:
		timer_auto_refresh.queue_free();
	if timer_auto_commit:
		timer_auto_commit.queue_free();
	call_action(action.KILL_ALL_PROCESS);
	call_deferred("free");
	pass

func _on_cmd_processed(cmd):
	run_on_cmd_ok(cmd);
	emit_signal("cmd_processed", cmd);
	pass

func run_on_cmd_ok(cmd):
	if cmd.type == CMD.GIT_INIT:
		call_action(action.INITIALIZED_GIT); # not used yet
		start();
	pass

func set_git_path():
	if Settings.get("git_path").empty():
		var path = find_git_path();
		if path:
			print_output(Lang.tr("git_found") % path);
			Settings.set("git_path", path);
			Settings.save_settings();
	pass

func find_git_path():
	var os = OS.get_name().to_lower();
	match(os):
		"x11", "osx":
			var result = CMDProcessor.run_command(["git"], "which");
			if result.empty():
				return null;
			result = result[0].c_escape().split("\\n", false);
			return result[0].strip_edges();
		"windows":
			var result = CMDProcessor.run_command(["git"], "where");
			return null if result.empty() else result[0].strip_edges();
	pass

func is_git_initialized():
	return !CMDProcessor.run_git_command(["status"])[0].empty();
	pass

func is_git_path_valid():
	return !CMDProcessor.run_git_command(["help"])[0].empty();
	pass

# experimental feature
func get_terminal_path():
	var os = OS.get_name().to_lower();
	match(os):
		"windows":
			return "cmd.exe";
		"x11":
			return null;
		"osx":
			return null;
	pass
