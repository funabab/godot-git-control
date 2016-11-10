
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

tool
extends HBoxContainer

var root_control;

var refresh_btn;

var commit_btn;
var revert_btn;
var tag_btn;
var fetch_btn;
var pull_btn;
var push_btn;
var rebase_btn;
var merge_btn;
var branch_btn;
var log_btn;
var clear_btn;

func _enter_tree():
	self.root_control = get_parent();

	self.refresh_btn = get_node("refresh_btn");
	self.branch_btn = get_node("toolbar_action_btns/branch_btn");
	self.commit_btn = get_node("toolbar_action_btns/commit_btn");
	self.revert_btn = get_node("toolbar_action_btns/revert_btn");
	self.tag_btn = get_node("toolbar_action_btns/tag_btn");
	self.fetch_btn = get_node("toolbar_action_btns/fetch_btn");
	self.pull_btn = get_node("toolbar_action_btns/pull_btn");
	self.rebase_btn = get_node("toolbar_action_btns/rebase_btn");
	self.merge_btn = get_node("toolbar_action_btns/merge_btn");
	self.log_btn = get_node("toolbar_action_btns/log_btn");
	self.clear_btn = get_node("toolbar_action_btns/clear_btn");

	self.refresh_btn.connect("pressed", self, "_on_refresh_btn_pressed");
	self.branch_btn.connect("pressed", self, "_on_branch_btn_pressed");
	self.commit_btn.connect("pressed", self, "_on_commit_btn_pressed");
	self.revert_btn.connect("pressed", self, "_on_revert_btn_pressed");
	self.tag_btn.connect("pressed", self, "_on_tag_btn_pressed");
	self.fetch_btn.connect("pressed", self, "_on_fetch_btn_pressed");
	self.pull_btn.connect("pressed", self, "_on_pull_btn_pressed");
	self.rebase_btn.connect("pressed", self, "_on_rebase_btn_pressed");
	self.merge_btn.connect("pressed", self, "_on_merge_btn_pressed");
	self.log_btn.connect("pressed", self, "_on_log_btn_pressed");
	self.clear_btn.connect("pressed", self, "_on_clear_btn_pressed");

	self.root_control.git_manager.controller.connect("action_event", self, "_on_action_event");
	pass

func _on_refresh_btn_pressed():
	self.root_control.git_manager.controller.views.hide_all_views();
	self.root_control.git_manager._run_refresh(true);
	pass

func _on_branch_btn_pressed():
	self.root_control.git_manager.controller._show_view_create_branch_dialog();
	pass

func _on_commit_btn_pressed():
	self.root_control.git_manager.controller._call_action(self.root_control.git_manager.controller.ACTION_COMMIT_WORKSPACE_TREE_SELECTED_FILES);
	pass

func _on_revert_btn_pressed():
	self.root_control.git_manager.controller._call_action(self.root_control.git_manager.controller.ACTION_REVERT_WORKSPACE_TREE_SELECTED_FILES);
	pass

func _on_tag_btn_pressed():
	self.root_control.git_manager.controller._show_view_create_tag_dialog();
	pass

func _on_fetch_btn_pressed():
	self.root_control.git_manager._run_cmd_fetch();
	pass

func _on_pull_btn_pressed():
	self.root_control.git_manager._run_cmd_pull();
	pass

func _on_rebase_btn_pressed():
	self.root_control.git_manager.controller._show_view_rebase_branch_dialog();
	pass

func _on_merge_btn_pressed():
	self.root_control.git_manager.controller._show_view_merge_branch_dialog();
	pass

func _on_log_btn_pressed():
	self.root_control.git_manager._run_cmd_log();
	pass

func _on_clear_btn_pressed():
	self.root_control.git_manager.controller._call_action(self.root_control.git_manager.controller.ACTION_CLEAR_CONSOLE_OUTPUT);
	pass

func _on_action_event(what, args):
	if (what == self.root_control.git_manager.controller.ACTION_WORKSPACE_TREE_SELECTION_CHANGED):
		var toogle = (args == 0);
		self.commit_btn.set_disabled(toogle);
		self.revert_btn.set_disabled(toogle);
	elif (what == self.root_control.git_manager.controller.ACTION_BRANCHES_UPDATED):
		var toogle = (args < 2);
		self.rebase_btn.set_disabled(toogle);
		self.merge_btn.set_disabled(toogle);
	elif (what == self.root_control.git_manager.controller.ACTION_REMOTES_UPDATED):
		var toogle = (args < 1);
		self.fetch_btn.set_disabled(toogle);
		self.pull_btn.set_disabled(toogle);
	pass
