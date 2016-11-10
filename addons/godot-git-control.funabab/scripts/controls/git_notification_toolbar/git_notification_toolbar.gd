
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

tool
extends MenuButton

var git_manager;
var branches;
var delete_branches;

const ITEM_REFRESH = 0;
const ITEM_CHECKOUT_BRANCH = 2;
const ITEM_DELETE_BRANCH = 3;
const ITEM_COMMIT_ALL = 5;
const ITEM_REVERT_ALL = 6;
const ITEM_FETCH = 8;
const ITEM_PULL = 9;
const ITEM_CREATE_BRANCH = 11;
const ITEM_MERGE_BRANCH = 12;
const ITEM_REBASE_BRANCH = 13;
const ITEM_TAG = 15;

func _enter_tree():
	self.get_popup().connect("item_pressed", self, "_on_item_pressed");
	self.git_manager.controller.connect("action_event", self, "_on_action_event");
	self.branches = PopupMenu.new();
	self.delete_branches = PopupMenu.new();
	self.branches.set_name("branches");
	self.delete_branches.set_name("delete_branches");
	self.get_popup().add_child(branches);
	self.get_popup().add_child(delete_branches);
	self.get_popup().set_item_submenu(self.ITEM_CHECKOUT_BRANCH, "branches");
	self.get_popup().set_item_submenu(self.ITEM_DELETE_BRANCH, "delete_branches");
	self.branches.connect("item_pressed", self, "_on_branches_item_pressed");
	self.delete_branches.connect("item_pressed", self, "_on_delete_branches_item_pressed");
	pass

func _params(git_manager):
	self.git_manager = git_manager;
	pass

func update_toolbar(cmd_result):
	self.get_popup().set_item_disabled(2, cmd_result[0][0].empty());
	self.get_popup().set_item_disabled(3, cmd_result[0][0].empty());
	pass

func set_title(suffix = ""):
	self.set_text("" + self.git_manager.controller.branches.get_current_branch_name() + suffix);  ## There is a octicons repo-forked icon here, which godot cant may not show.
	pass

func update_branches(branches_count):
	var current_branch_name = self.git_manager.controller.branches.get_current_branch_name();
	var id = 0;
	self.branches.clear();
	self.delete_branches.clear();
	for val in self.git_manager.controller.branches.get_all_branch_names():
		if (val == current_branch_name):
			self.branches.add_item("* " + val, id);
			self.delete_branches.add_item("* " + val, id);
			self.branches.set_item_disabled(id, true);
			self.delete_branches.set_item_disabled(id, true);
		else:
			self.branches.add_item(val, id);
			self.delete_branches.add_item(val, id);
		id += 1;
	var toogle = (branches_count < 2);
	self.get_popup().set_item_disabled(self.ITEM_MERGE_BRANCH, toogle);
	self.get_popup().set_item_disabled(self.ITEM_REBASE_BRANCH, toogle);
	pass

func _on_item_pressed(item_id):
	if (item_id == self.ITEM_REFRESH):
		self.git_manager._run_refresh(true);
	elif (item_id == self.ITEM_COMMIT_ALL):
		self.git_manager.controller._show_view_commit_message_dialog(self.git_manager.controller.workspace.get_all_files_path());
	elif (item_id == self.ITEM_REVERT_ALL):
		self.git_manager.controller._show_view_revert_confirm_dialog(self.git_manager.controller.workspace.get_all_files_path(), "Revert All will erase changes in all files since last commit\nAre you sure to continue?");
	elif (item_id == self.ITEM_FETCH):
		self.git_manager._run_cmd_fetch();
	elif (item_id == self.ITEM_PULL):
		self.git_manager._run_cmd_pull();
	elif (item_id == self.ITEM_CREATE_BRANCH):
		self.git_manager.controller._show_view_create_branch_dialog();
	elif (item_id == self.ITEM_MERGE_BRANCH):
		self.git_manager.controller._show_view_merge_branch_dialog();
	elif (item_id == self.ITEM_REBASE_BRANCH):
		self.git_manager.controller._show_view_rebase_branch_dialog();
	elif (item_id == self.ITEM_TAG):
		self.git_manager.controller._show_view_create_tag_dialog();
	pass

func _on_action_event(what, args):
	if (what == self.git_manager.controller.ACTION_REMOTES_UPDATED):
		var toogle = (args < 1);
		self.get_popup().set_item_disabled(self.ITEM_FETCH, toogle);
		self.get_popup().set_item_disabled(self.ITEM_PULL, toogle);
	elif (what == self.git_manager.controller.ACTION_BRANCHES_UPDATED):
		self.update_branches(args);
	elif (what == self.git_manager.controller.ACTION_REMOTES_UPDATED):
		var toogle = (args < 1);
		self.get_popup().set_item_disabled(self.ITEM_FETCH, toogle);
		self.get_popup().set_item_disabled(self.ITEM_PULL, toogle);
	elif (what == self.git_manager.controller.ACTION_WORKSPACE_FILES_UPDATED):
		var toogle = (args < 1);
		if (toogle):
			self.set_title();
		else:
			self.set_title("*");
		self.get_popup().set_item_disabled(self.ITEM_COMMIT_ALL, toogle);
		self.get_popup().set_item_disabled(self.ITEM_REVERT_ALL, toogle);
	elif (what == self.git_manager.controller.ACTION_AUTO_COMMIT_ACTIVATED):
		self.add_color_override("font_color", Color("bc8e8e"));
		self.add_color_override("font_color_hover", Color("bc8e8e"));
	pass

func _on_branches_item_pressed(item_id):
	self.git_manager.controller.views.hide_all_views();
	self.git_manager._run_cmd_checkout(self.branches.get_item_text(item_id), true);
	pass

func _on_delete_branches_item_pressed(item_id):
	self.git_manager.controller._show_view_delete_branch_dialog(self.delete_branches.get_item_text(item_id));
	pass

