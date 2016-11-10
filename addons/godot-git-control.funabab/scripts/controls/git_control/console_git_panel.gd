
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

tool
extends Panel
var root_control;
var console;

func _enter_tree():
	self.root_control = get_node("../../../../").get_parent();
	self.console = get_node("console_git");
	self.console.set_readonly(true);
	get_node("clear_btn").connect("pressed", self, "_on_clear_btn_pressed");
	self.root_control.git_manager.controller.connect("action_event", self, "_on_action_event");
	pass

func _on_clear_btn_pressed():
	self.console.set_text("");
	pass

func console_write(msg):
	self.console.set_text(self.console.get_text() + msg);
	pass

func _on_action_event(what, args):
	if (what == self.root_control.git_manager.controller.ACTION_WRITE_CONSOLE_GIT):
		self.console_write(args);
	pass