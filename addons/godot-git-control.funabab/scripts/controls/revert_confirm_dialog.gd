
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

tool
extends ConfirmationDialog

var base_control;
var selected_files;
signal on_revert;

func _enter_tree():
	self.get_ok().set_text("Revert");
	self.connect("confirmed", self, "_on_action_pressed");
	pass

func _params(base_control):
	self.base_control = base_control;
	pass

func _show_dialog(selected_files, message = null):
	if (message == null):
		message = "Revert will erase changes in selected files since last commit\nAre you sure to continue?";
	self.selected_files = selected_files;
	self.set_text(message);
	self.set_pos(Vector2((base_control.get_viewport_rect().size.x - self.get_rect().size.x) / 2, (base_control.get_viewport_rect().size.y - self.get_rect().size.y) / 2));
	self.show();
	pass

func _on_action_pressed():
	self.emit_signal("on_revert", self.selected_files);
	pass


