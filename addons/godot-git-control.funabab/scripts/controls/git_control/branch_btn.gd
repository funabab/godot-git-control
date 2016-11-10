
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

tool
extends OptionButton
var root_control;

var delete_branch_btn;

func _enter_tree():
	self.root_control = get_node("..").get_parent();
	self.delete_branch_btn = get_node("../delete_branch_btn");
	self.connect("item_selected", self, "_on_branch_selected");
	self.delete_branch_btn.get_popup().connect("item_pressed", self, "_on_delete_branch_btn_item_pressed");
	self.root_control.git_manager.controller.connect("action_event", self, "_on_action_event");
	pass

func add_branch_item(name, id, selected_item = false):
	if (selected_item):
		self.add_item(name, id);
		self.select(id);
		self.delete_branch_btn.get_popup().add_item("* " + name, id);
		self.delete_branch_btn.get_popup().set_item_disabled(id, true);
	else:
		self.add_item(name, id);
		self.delete_branch_btn.get_popup().add_item(name, id);
	pass

func _on_branch_selected(item_id):
	self.root_control.git_manager.controller.views.hide_all_views();
	self.root_control.git_manager._run_cmd_checkout(self.get_item_text(item_id), true);
	pass

func update_branch_list():
	var id = 0;
	self.clear();
	self.delete_branch_btn.get_popup().clear();
	for val in self.root_control.git_manager.controller.branches.get_all_branch_names():
		self.add_branch_item(val, id, (val == self.root_control.git_manager.controller.branches.get_current_branch_name()));
		id += 1;
	pass

func _on_delete_branch_btn_item_pressed(item_id):
	self.root_control.git_manager.controller._show_view_delete_branch_dialog(self.delete_branch_btn.get_popup().get_item_text(item_id));
	pass

func _on_action_event(what, args):
	if (what == self.root_control.git_manager.controller.ACTION_BRANCHES_UPDATED):
		self.update_branch_list();
	pass
