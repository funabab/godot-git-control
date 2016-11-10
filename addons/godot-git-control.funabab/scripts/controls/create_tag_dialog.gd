
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

tool
extends ConfirmationDialog
var base_control;

signal on_create_tag;

func _enter_tree():
	self.get_ok().set_text("Create Tag");
	self.add_button("Force Tag", true, "_on_force_tag")
	self.connect("custom_action", self, "_on_action_pressed");
	self.connect("confirmed", self, "_on_action_pressed");
	pass

func _params(base_control):
	self.base_control = base_control;
	pass

func _show_dialog():
	get_node("container/tag_name/input").set_text("");
	get_node("container/tag_commit/input").set_text("");
	get_node("container/tag_message/input").set_text("");
	self.hide_errors();
	self.set_pos(Vector2((base_control.get_viewport_rect().size.x - self.get_rect().size.x) / 2, (base_control.get_viewport_rect().size.y - self.get_rect().size.y) / 2));
	self.show();
	pass

func validate_inputs():
	if (get_node("container/tag_name/input").get_text().empty()):
		var error_label = get_node("container/tag_name/error_label");
		error_label.set_text("Error! Tag name cant be empty");
		error_label.show();
		return false;
	elif (get_node("container/tag_name/input").get_text().find(" ") != -1):
		var error_label = get_node("container/tag_name/error_label");
		error_label.set_text("Error! Tag name should not contain whitespace");
		error_label.show();
		return false;
	return true;
	pass

func hide_errors():
	get_node("container/tag_name/error_label").hide();
	pass

func _on_action_pressed(custom_action = null):
	if (!self.validate_inputs()):
		self.show();
		return;
	var tag_name = self.get_node("container/tag_name/input").get_text();
	var tag_commit_ref = self.get_node("container/tag_commit/input").get_text();
	var tag_message = self.get_node("container/tag_message/input").get_text();
	if (custom_action == null):
		self.emit_signal("on_create_tag", tag_name, tag_commit_ref, tag_message);
	elif (custom_action == "_on_force_tag"):
		self.emit_signal("on_create_tag", tag_name, tag_commit_ref, tag_message, true);
	self.hide();##Optional, infact not compulsory
	pass
