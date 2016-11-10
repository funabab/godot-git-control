
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

class GitViewManager extends Object:

	var git_manager;

	const VIEW_CREATE_BRANCH = 1;
	const VIEW_CREATE_TAG = 2;
	const VIEW_COMMIT_MESSAGE = 3;
	const VIEW_DELETE_BRANCH_CONFIRM = 4;
	const VIEW_REVERT_CONFIRM = 5;
	const VIEW_REBASE_BRANCH = 6;
	const VIEW_MERGE_BRANCH = 7;
	

	var create_branch_dialog;
	var create_tag_dialog;
	var commit_message_dialog;
	var delete_branch_dialog;
	var revert_confirm_dialog;
	var rebase_dialog;
	var merge_branch_dialog;


	func _init(git_manager):
		self.git_manager = git_manager;

		self.create_branch_dialog = preload("res://addons/godot-git-control.funabab/controls/create_branch_dialog.tscn").instance();
		self.create_tag_dialog = preload("res://addons/godot-git-control.funabab/controls/create_tag_dialog.tscn").instance();
		self.commit_message_dialog = preload("res://addons/godot-git-control.funabab/controls/commit_message_dialog.tscn").instance();
		self.delete_branch_dialog = preload("res://addons/godot-git-control.funabab/controls/delete_branch_dialog.tscn").instance();
		self.revert_confirm_dialog = preload("res://addons/godot-git-control.funabab/controls/revert_confirm_dialog.tscn").instance();
		self.rebase_dialog = preload("res://addons/godot-git-control.funabab/controls/rebase_dialog.tscn").instance();
		self.merge_branch_dialog = preload("res://addons/godot-git-control.funabab/controls/merge_branch_dialog.tscn").instance();
	
		self.create_branch_dialog._params(self.git_manager.base_control);
		self.create_tag_dialog._params(self.git_manager.base_control);
		self.commit_message_dialog._params(self.git_manager.base_control);
		self.delete_branch_dialog._params(self.git_manager.base_control);
		self.revert_confirm_dialog._params(self.git_manager.base_control);
		self.rebase_dialog._params(self.git_manager.base_control);
		self.merge_branch_dialog._params(self.git_manager.base_control);
	
		self.create_branch_dialog.connect("on_create_branch", self, "_on_create_branch");
		self.create_tag_dialog.connect("on_create_tag", self, "_on_create_tag");
		self.commit_message_dialog.connect("on_commit", self, "_on_commit");
		self.delete_branch_dialog.connect("on_delete_confirmed", self, "_on_delete_branch_confirmed");
		self.revert_confirm_dialog.connect("on_revert", self, "_on_revert");
		self.rebase_dialog.connect("on_rebase", self, "_on_rebase");
		self.merge_branch_dialog.connect("on_merge", self, "_on_merge_branch");
	
		self.git_manager.base_control.add_child(self.create_branch_dialog);
		self.git_manager.base_control.add_child(self.create_tag_dialog);
		self.git_manager.base_control.add_child(self.commit_message_dialog);
		self.git_manager.base_control.add_child(self.delete_branch_dialog);
		self.git_manager.base_control.add_child(self.revert_confirm_dialog);
		self.git_manager.base_control.add_child(self.rebase_dialog);
		self.git_manager.base_control.add_child(self.merge_branch_dialog);
		pass

	func hide_all_views():
		self.create_branch_dialog.hide();
		self.create_tag_dialog.hide();
		self.commit_message_dialog.hide();
		self.delete_branch_dialog.hide();
		self.revert_confirm_dialog.hide();
		self.rebase_dialog.hide();
		self.merge_branch_dialog.hide();
		pass


	func _on_create_branch(new_branch, checkout = false):
		self.git_manager._run_create_branch(new_branch, checkout);
		pass

	func _on_create_tag(tag_name, tag_commit_ref, tag_message, force_tag = false):
		self.git_manager._run_cmd_tag(tag_name, tag_commit_ref, tag_message, force_tag);
		pass

	func _on_commit(files_to_commit, commit_message):
		self.git_manager._run_cmd_commit(files_to_commit, commit_message);
		pass

	func _on_delete_branch_confirmed(branch_name, force_delete = false):
		self.git_manager._run_branch_delete(branch_name, force_delete);
		pass

	func _on_revert(selected_files):
		self.git_manager._run_cmd_revert(selected_files);
		pass

	func _on_rebase(rebase_branch):
		self.git_manager._run_cmd_rebase(rebase_branch);
		pass

	func _on_merge_branch(merge_branch, no_fast_forward):
		self.git_manager._run_cmd_merge(merge_branch, no_fast_forward);
		pass
