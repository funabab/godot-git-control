
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

tool
extends ConfirmationDialog
var branch_name;
var base_control;

signal on_delete_confirmed;

func _enter_tree():
	self.get_ok().set_text("Delete");
	self.add_button("Force Delete", true, "_on_force_delete");
	self.connect("confirmed", self, "_on_action_pressed");
	self.connect("custom_action", self, "_on_action_pressed");
	pass

func _params(base_control):
	self.base_control = base_control;
	pass

func _show_dialog(branch_name):
	self.branch_name = branch_name;
	get_node("label").set_text("Are you sure to delete Branch '" + branch_name + "'?");
	self.popup_centered()
	pass

func _on_action_pressed(custom_action = null):
	if (custom_action == null):
		self.emit_signal("on_delete_confirmed", self.branch_name);
	elif (custom_action == "_on_force_delete"):
		self.emit_signal("on_delete_confirmed", self.branch_name, true);
	self.hide();
	pass
