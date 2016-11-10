
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

tool
extends ConfirmationDialog
var base_control;
var files_to_commit;

signal on_commit;

func _enter_tree():
	self.get_ok().set_text("Commit");
	self.connect("confirmed", self, "_on_action_pressed");
	pass

func _params(base_control):
	self.base_control = base_control;
	pass

func _show_dialog(files_to_commit):
	self.files_to_commit = files_to_commit;
	self.get_node("commit_message/input").set_text("");
	self.set_pos(Vector2((base_control.get_viewport_rect().size.x - self.get_rect().size.x) / 2, (base_control.get_viewport_rect().size.y - self.get_rect().size.y) / 2));
	self.show();
	pass

func _on_action_pressed():
	self.emit_signal("on_commit", self.files_to_commit, get_node("commit_message/input").get_text());
	pass
