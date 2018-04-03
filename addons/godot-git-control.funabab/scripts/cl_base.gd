extends Object

var git;

func _initialize(git):
	self.git = git;
	self.git.connect("action_event", self, "_action_notification");
	_setup();
	pass

func _setup():
	pass

func _action_notification(what, args):
	if what == git.action.KILL_ALL_PROCESS:
		git.disconnect("action_event", self, "_action_notification");
		call_deferred("free");
		return;
	_on_action_event(what, args);
	pass

func _on_action_event(what, args):
	pass