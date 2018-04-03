tool
extends VBoxContainer

var git;
signal action_event;
signal ui_action;

onready var launch_terminal_btn = $main/consoles/command_terminal/container/header/container/options/link_container/launch_terminal_btn;

func setup(git):
	self.git = git;
	self.git.connect("action_event", self, "_on_action_event");
	pass

func _on_action_event(what, args):
	if what == git.action.UI_TERMINAL_NOT_FOUND:
		launch_terminal_btn.visible = false;
		return;
	emit_signal("action_event", what, args);
	pass

func _ready():
	var IconsManager = load("res://addons/godot-git-control.funabab/scripts/utils/icons_manager.gd");
	var Utils = load("res://addons/godot-git-control.funabab/scripts/utils/utils.gd");

	var btns = Utils.get_node_type_in_children(self, "BaseButton");
	for btn in btns:
		if IconsManager.LOOKUP.has(btn.name):
			var icon = IconsManager._get_icon(IconsManager.LOOKUP[btn.name]);
			if icon:
				btn.text = icon.code;
				btn.add_font_override("font", IconsManager._get_font(icon.type));
		else:
			var text = git.Lang.tr("node_text_" + btn.name);
			if text:
				btn.text = text;
		btn.hint_tooltip = git.Lang.tr("node_tooltip_" + btn.name);

	launch_terminal_btn.connect("pressed", self, "_on_launch_terminal_btn_pressed");
	pass

func _on_launch_terminal_btn_pressed():
	git.call_action(git.action.SHOW_TERMINAL);
	pass
