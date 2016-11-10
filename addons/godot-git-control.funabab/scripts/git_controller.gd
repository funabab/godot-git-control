
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

class GitController extends Object:

	var git_manager;
	var remotes;
	var branches;
	var workspace;
	var views;

	signal action_event;

	## Actions
	const ACTION_CLEAR_CONSOLE_OUTPUT = 1;
	const ACTION_BRANCHES_UPDATED = 2;
	const ACTION_WORKSPACE_FILES_UPDATED = 3;
	const ACTION_COMMIT_WORKSPACE_TREE_SELECTED_FILES = 4;
	const ACTION_WORKSPACE_TREE_SELECTION_CHANGED = 5;
	const ACTION_REMOTES_UPDATED = 6;
	const ACTION_REVERT_WORKSPACE_TREE_SELECTED_FILES = 7;
	const ACTION_WRITE_CONSOLE_OUTPUT = 8;
	const ACTION_WRITE_CONSOLE_GIT = 9;
	const ACTION_AUTO_REFRESH_ACTIVATED = 10;
	const ACTION_AUTO_COMMIT_ACTIVATED = 11;

	func _init(git_manager):
		self.git_manager = git_manager;
		self.branches = preload("res://addons/godot-git-control.funabab/scripts/git_branch_manager.gd").GitBranchManager.new(self);
		self.remotes = preload("res://addons/godot-git-control.funabab/scripts/git_remote_manager.gd").GitRemoteManager.new(self);
		self.workspace = preload("res://addons/godot-git-control.funabab/scripts/git_workspace_manager.gd").GitWorkspaceManager.new(self);
		self.views = preload("res://addons/godot-git-control.funabab/scripts/git_view_manager.gd").GitViewManager.new(self.git_manager);
		self.git_manager.connect("cmd_processed", self, "_on_cmd_ok");
		pass

	func _on_cmd_ok(cmd):
		self.output_git_command(cmd);
		if (cmd._get_type() == self.git_manager.cmd_manager.CMD_GIT_LOG):
			self.write_output(self.git_manager.Utils.string_array_to_string(cmd._get_results()[0], "", "\n"));
		pass

	func output_git_command(cmd):
		if (cmd.show_cmd_in_console):
			var commands = cmd._get_commands();
			var results = cmd._get_results();
			var command_output = "";
			for i in range(commands.size()):
				command_output = command_output + " > git " + self.git_manager.Utils.string_array_to_string(commands[i], "", " ", true) + "\n";
				if (cmd.show_result_in_console && !results[i][0].empty()):
					command_output = command_output + self.git_manager.Utils.string_array_to_string(results[i], "", "\n");
			var output_command_mode = self.git_manager.settings.get_value_int("git", "command_output_mode", 1);
			if (output_command_mode == 1):
				self.emit_signal("action_event", self.ACTION_WRITE_CONSOLE_GIT, command_output);
			elif (output_command_mode == 2):
				print(command_output);
		pass

	func write_output(message):
		var output_mode = self.git_manager.settings.get_value_int("git_control", "output_mode", 1);
		if (output_mode == 1):
			self.emit_signal("action_event", self.ACTION_WRITE_CONSOLE_OUTPUT, message);
		elif (output_mode == 2):
			print(message);
		pass

	func _call_action(what, args = null):
		self.emit_signal("action_event", what, args);
		pass

	func _show_view_create_branch_dialog():
		self.views.hide_all_views();
		self.views.create_branch_dialog._show_dialog(self.branches.get_current_branch_name());
		pass

	func _show_view_commit_message_dialog(selected_files):
		self.views.hide_all_views();
		self.views.commit_message_dialog._show_dialog(selected_files);
		pass

	func _show_view_revert_confirm_dialog(selected_files, message = null):
		self.views.hide_all_views();
		if (self.git_manager.settings.get_value_int("cmd", "cmd_confirm_revert", 1) == 1):
			self.views.revert_confirm_dialog._show_dialog(selected_files, message);
		else:
			self.git_manager._run_cmd_revert(selected_files);
		pass

	func _show_view_delete_branch_dialog(branch_name):
		self.views.hide_all_views();
		self.views.delete_branch_dialog._show_dialog(branch_name);
		pass

	func _show_view_create_tag_dialog():
		self.views.hide_all_views();
		self.views.create_tag_dialog._show_dialog();
		pass

	func _show_view_rebase_branch_dialog():
		self.views.hide_all_views();
		self.views.rebase_dialog._show_dialog(self.branches.get_current_branch_name(), self.branches.get_all_branch_names(true));
		pass

	func _show_view_merge_branch_dialog():
		self.views.hide_all_views();
		self.views.merge_branch_dialog._show_dialog(self.branches.get_current_branch_name(), self.branches.get_all_branch_names(true));
		pass

	



