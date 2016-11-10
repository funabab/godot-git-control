
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

tool
extends TextEdit

var root_control;

func _enter_tree():
	self.root_control = get_node("../../../").get_parent();
	self.set_readonly(true);
	self.root_control.git_manager.controller.connect("action_event", self, "_on_action_event");
	self.root_control.git_manager.connect("cmd_processed", self, "_on_cmd_ok");
	self.console_write("@funabab (c) 2016");
	pass

func console_write(msg = ""):
	msg = " *** Output Console ***\n" + msg;
	self.set_text(msg);
	pass

func _on_action_event(what, args):
	if (what == self.root_control.git_manager.controller.ACTION_CLEAR_CONSOLE_OUTPUT):
		self.console_write();
	if (what == self.root_control.git_manager.controller.ACTION_WRITE_CONSOLE_OUTPUT):
		self.console_write(args);
	pass

func _on_cmd_ok(cmd):
	var cmd_type = cmd._get_type();
	if (cmd_type == self.root_control.git_manager.cmd_manager.CMD_GIT_CHECKOUT):
		self.console_write();
	elif (cmd_type == self.root_control.git_manager.cmd_manager.CMD_GIT_COMMIT):
		self.console_write();
	pass
