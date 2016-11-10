
class GitManager extends Object:

	var base_control;
	var cmd_manager;
	var remotes;
	var controller;
	var CMD;
	var Utils = preload("res://addons/godot-git-control.funabab/scripts/utils.gd").Utils.new();
	var settings;
	signal cmd_processed;

	func _init(base_control, settings_manager):
		self.base_control = base_control;
		self.settings = settings_manager;
		self.cmd_manager = preload("res://addons/godot-git-control.funabab/scripts/command_manager.gd").CommandManager.new(self);
		self.CMD = preload("res://addons/godot-git-control.funabab/scripts/cmd.gd").CMD;
		self.controller = preload("res://addons/godot-git-control.funabab/scripts/git_controller.gd").GitController.new(self);
		pass

	func _run_refresh(show_in_console = false):
		self._run_cmd_branch(show_in_console);
		self._run_cmd_status(show_in_console);
		self._run_cmd_remote();
		pass

	func _run_auto_refresh():
		self._run_refresh();
		pass

	func _run_auto_commit():
		if (self.controller.workspace.get_files_count() < 1):
			return;
		self._run_cmd_commit(self.controller.workspace.get_all_files_path(), "AutoCommit at " + self.Utils.get_datetime_string());
		pass

	func _run_cmd_remote():
		var cmd = CMD.new(cmd_manager.CMD_GIT_REMOTE, false);
		cmd._push_command(["remote", "-v"]);
		cmd_manager.queue_cmd(cmd);
		pass

	func _run_cmd_branch(show_in_console = false):
		var cmd = CMD.new(cmd_manager.CMD_GIT_BRANCH, show_in_console, show_in_console);
		cmd._push_command(["branch"]);
		cmd_manager.queue_cmd(cmd);
		pass

	func _run_create_branch(new_branch, checkout = false):
		var cmd = CMD.new(cmd_manager.GIT_CREATE_BRANCH, true, true);
		cmd._push_command(["branch", new_branch]);
		cmd_manager.queue_cmd(cmd);
		if (checkout):
			self._run_cmd_checkout(new_branch, true);
		else:
			self._run_refresh();
		pass

	func _run_cmd_checkout(branch_name, show_in_console = false):
		var cmd = CMD.new(cmd_manager.CMD_GIT_CHECKOUT, show_in_console, show_in_console);
		cmd._push_command(["checkout", branch_name]);
		cmd_manager.queue_cmd(cmd);
		self._run_refresh();
		pass

	func _run_cmd_commit(files_to_commit, commit_message):
		var cmd = CMD.new(cmd_manager.CMD_GIT_COMMIT, true, true);
		var command = ["add", "--"];
		command = self.Utils.merge_array(command, files_to_commit);
		cmd._push_command(command);
		cmd._push_command(["commit", "--allow-empty-message", "-m", commit_message]);
		cmd_manager.queue_cmd(cmd);
		self._run_refresh();
		pass

	func _run_cmd_revert(selected_files):
		var cmd = CMD.new(cmd_manager.CMD_GIT_REVERT, true, true);
		var command = ["checkout", "--"];
		command = self.Utils.merge_array(command, selected_files);
		cmd._push_command(command);
		cmd_manager.queue_cmd(cmd);
		self._run_refresh();
		pass

	func _run_branch_delete(branch_name, force_delete = false):
		var cmd = CMD.new(cmd_manager.GIT_BRANCH_DELETE, true, true);
		if (force_delete):
			cmd._push_command(["branch", "-D", branch_name]);
		else:
			cmd._push_command(["branch", "-d", branch_name]);
		cmd_manager.queue_cmd(cmd);
		self._run_refresh(false);
		pass

	func _run_cmd_tag(tag_name, tag_commit_ref, tag_message, force_tag = false):
		var cmd = CMD.new(cmd_manager.CMD_GIT_TAG, true, true);
		var command = ["tag", "-a", tag_name];
		if (force_tag):
			command.push_back("--force");
		if (!tag_message.empty()):
			command.push_back("-m");
			command.push_back(tag_message);
		if (!tag_commit_ref.empty()):
			command.push_back(tag_commit_ref);
		cmd._push_command(command);
		cmd_manager.queue_cmd(cmd);
		pass

	func _run_cmd_fetch():
		var cmd = CMD.new(cmd_manager.CMD_GIT_FETCH, true, true);
		cmd._push_command(["fetch", "--prune"]);
		cmd_manager.queue_cmd(cmd);
		self._run_refresh();
		pass

	func _run_cmd_pull():
		var cmd = CMD.new(cmd_manager.CMD_GIT_PULL, true, true);
		cmd._push_command(["pull"]);
		cmd_manager.queue_cmd(cmd);
		self._run_refresh();
		pass

	func _run_cmd_rebase(rebase_branch):
		var cmd = CMD.new(cmd_manager.CMD_GIT_REBASE, true, true);
		cmd._push_command(["rebase", rebase_branch]);
		cmd_manager.queue_cmd(cmd);
		pass

	func _run_cmd_merge(merge_branch, no_fast_forward):
		var cmd = CMD.new(cmd_manager.CMD_GIT_MERGE, true, true);
		if (no_fast_forward):
			cmd._push_command(["merge", "--no-ff", merge_branch]);
		else:
			cmd._push_command(["merge", merge_branch]);
		cmd_manager.queue_cmd(cmd);
		pass

	func _run_cmd_log():
		var cmd = CMD.new(cmd_manager.CMD_GIT_LOG, true);
		cmd._push_command(["--no-pager", "log", "--format=fuller", "--graph", "--all", "--decorate"]);
		cmd_manager.queue_cmd(cmd);
		pass

	func _run_cmd_status(show_in_console = false):
		var cmd = CMD.new(cmd_manager.CMD_GIT_STATUS, show_in_console);
		cmd._push_command(["status", "--porcelain", "--untracked-files=all"]);
		cmd_manager.queue_cmd(cmd);
		pass

	func is_git_installed():
		return !(self.get_git_path() == null);
		pass

	func is_git_configured():
		var git_user_name = self.cmd_manager.run_command(["config", "user.name"])[0];
		var git_user_email = self.cmd_manager.run_command(["config", "user.email"])[0];
		return !(git_user_name.empty() || git_user_email.empty());
		pass

	func is_git_initialized():
		return !self.cmd_manager.run_command(["status"])[0].empty();
		pass

	func get_git_path():
		return self.cmd_manager.git_path;
		pass

	func set_auto_refresh(duration):
		if (duration == 0):
			return;
		##self.controller._call_action(self.controller.ACTION_AUTO_REFRESH_ACTIVATED);
		var timer = Timer.new();
		timer.set_wait_time(duration);
		timer.set_one_shot(false);
		timer.set_autostart(true);
		timer.connect("timeout", self, "_run_auto_refresh");
		self.base_control.add_child(timer);
		pass

	func set_auto_commit_duration(duration):
		if (duration == 0):
			return;
		self.controller._call_action(self.controller.ACTION_AUTO_COMMIT_ACTIVATED);
		self.controller.write_output("AutoCommit Activated...");
		var timer = Timer.new();
		timer.set_wait_time(duration);
		timer.set_one_shot(false);
		timer.set_autostart(true);
		timer.connect("timeout", self, "_run_auto_commit");
		self.base_control.add_child(timer);
		pass

	func _on_cmd_processed(cmd):
		self.emit_signal("cmd_processed", cmd);
		pass
