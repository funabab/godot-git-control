extends AcceptDialog

const CUSTOM_ACTION = "custom_btn_action";

var manager;
var dialog;
var _custom_btn;
var Lang;
func setup(manager, dialog):
	self.manager = manager;
	self.dialog = dialog;

	Lang = manager.git.Lang;
	pass

func _ready():
	if _get_cancel_btn_text():
		var btn = add_cancel(_get_cancel_btn_text());
		btn.connect("pressed", self, "hide");

	if _get_ok_btn_text():
		get_ok().text = _get_ok_btn_text();

	if _get_custom_btn_text():
		_custom_btn = add_button(_get_custom_btn_text(), true, CUSTOM_ACTION);
		connect("custom_action", self, "_on_dialog_confirmed");

	manager.git.connect("action_event", self, "_action_notification");
	connect("confirmed", self, "_on_dialog_confirmed");
	_tr();
	_on_ready();
	pass

func _get_cancel_btn_text():
	return "Cancel";
	pass

func _tr():
	pass

func _on_ready():
	pass

func _on_show_dialog(args):
	pass

func _get_ok_btn_text():
	return null;
	pass

func get_custom_btn():
	return _custom_btn;
	pass

func _get_custom_btn_text():
	return null;
	pass

func hide():
	visible = false;
	pass

func _action_notification(what, args):
	if what == manager.git.action.KILL_ALL_PROCESS:
		manager.git.disconnect("action_event", self, "_action_notification");
		queue_free();
		return;
	_on_action_event(what, args);
	pass

func _on_action_event(what, args):
	pass

func _on_dialog_confirmed(custom = null):
	manager._on_dialog_confirmed(dialog, _get_result(custom));
	hide();
	pass

func _get_result(custom):
	return true;
	pass

func center_dialog():
	rect_global_position = (manager.git.base_control.get_viewport_rect().size - get_global_rect().size) * .5;
	pass

func show_dialog(args = null):
	center_dialog();
	_on_show_dialog(args);
	show();
	pass


