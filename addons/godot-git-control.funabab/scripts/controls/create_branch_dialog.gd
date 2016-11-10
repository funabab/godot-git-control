
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

tool
extends ConfirmationDialog
var base_control;

signal on_create_branch;

func _enter_tree():
	self.get_ok().set_text("Create Branch");
	self.add_button("Checkout Branch", true, "_on_checkout_branch_action");
	self.connect("custom_action", self, "_on_action_pressed");
	self.connect("confirmed", self, "_on_action_pressed");
	pass

func _params(base_control):
	self.base_control = base_control;
	pass

func _show_dialog(current_branch):
	get_node("container/current_branch/input").set_text(current_branch);
	get_node("container/new_branch/input").set_text("");
	self.hide_errors();
	self.set_pos(Vector2((base_control.get_viewport_rect().size.x - self.get_rect().size.x) / 2, (base_control.get_viewport_rect().size.y - self.get_rect().size.y) / 2));
	self.show();
	pass

func validate_inputs():
	if (get_node("container/new_branch/input").get_text().empty()):
		var error_label = get_node("container/new_branch/error_label");
		error_label.set_text("Error! Branch name cant be empty");
		error_label.show();
		return false;
	elif (get_node("container/new_branch/input").get_text().find(" ") != -1):
		var error_label = get_node("container/new_branch/error_label");
		error_label.set_text("Error! Branch name should not contain whitespace");
		error_label.show();
		return false;
	return true;
	pass

func hide_errors():
	get_node("container/new_branch/error_label").hide();
	pass

func _on_action_pressed(custom_action = null):
	if (!self.validate_inputs()):
		self.show();
		return;
	var new_branch = get_node("container/new_branch/input").get_text();
	if (custom_action == null):
		self.emit_signal("on_create_branch", new_branch);
	elif (custom_action == "_on_checkout_branch_action"):
		self.emit_signal("on_create_branch", new_branch, true);
	self.hide();
	pass
