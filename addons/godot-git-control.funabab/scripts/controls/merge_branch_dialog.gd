
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

tool
extends ConfirmationDialog

var base_control;
var no_fast_forward = false;

signal on_merge;

func _enter_tree():
	self.get_ok().set_text("Merge");
	self.connect("confirmed", self, "_on_action_pressed");
	self.get_node("container/no_fast_forward/checkbox").connect("toggled", self, "_on_checkbox_toggled");
	pass

func _params(base_control):
	self.base_control = base_control;
	pass

func _show_dialog(current_branch, branches):
	self.get_node("container/current_branch/input").set_text(current_branch);
	self.update_branch_options(branches);
	self.set_pos(Vector2((base_control.get_viewport_rect().size.x - self.get_rect().size.x) / 2, (base_control.get_viewport_rect().size.y - self.get_rect().size.y) / 2));
	self.show();
	pass

func update_branch_options(branches):
	var branch_options = get_node("container/merge_branch/branches");
	branch_options.clear();
	var id = 0;
	for val in branches:
		branch_options.add_item(val, id);
		id += 1;
	pass

func _on_action_pressed():
	var branches = get_node("container/merge_branch/branches");
	self.emit_signal("on_merge", branches.get_item_text(branches.get_selected()), self.no_fast_forward);
	pass

func _on_checkbox_toggled(toggle):
	self.no_fast_forward = toggle;
	pass
