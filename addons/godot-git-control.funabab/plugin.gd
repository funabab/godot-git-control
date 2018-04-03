tool
extends EditorPlugin

const NAME = "GitControl";
const DIR_LANG = "res://addons/godot-git-control.funabab/scripts/lang/";
enum PluginMode {DEFAULT = 0, BOTTOM_DOCK = 1, TOOLBAR = 2};

var Git;
var Settings;
var Lang;
var control;
var control_toolbar_btn;

var toolbtn;
var plugin_mode = 0;

func _enter_tree():
	Settings = load("res://addons/godot-git-control.funabab/scripts/settings.gd").new();
	Lang = load_lang(Settings.get("language"));
	Git = load("res://addons/godot-git-control.funabab/scripts/git.gd").new(get_editor_interface().get_base_control(), Settings, Lang);

	plugin_mode = Settings.get_as_int("plugin_mode");
	if plugin_mode == PluginMode.DEFAULT || plugin_mode == PluginMode.BOTTOM_DOCK:
		control = load("res://addons/godot-git-control.funabab/scenes/main_gui.tscn").instance();
		control.setup(Git);
		toolbtn = add_control_to_bottom_panel(control, NAME);
		Git.connect("action_event", self, "_on_action_event");
	if plugin_mode == PluginMode.DEFAULT || plugin_mode == PluginMode.TOOLBAR:
		control_toolbar_btn = load("res://addons/godot-git-control.funabab/scenes/git_control_toolbar.tscn").instance();
		control_toolbar_btn.setup(Git);
		add_control_to_container(CONTAINER_TOOLBAR, control_toolbar_btn);
	Git.call_deferred("initialize"); ## should be called last
#	Git.initialize(); ## should be called last
	pass

func load_lang(lang):
	return load(DIR_LANG + "lang_" + lang + ".gd");
	pass

func _on_action_event(what, args):
	if what == Git.action.UI_WORKSPACE_UPDATE:
		if args.size() > 0:
			toolbtn.text = NAME + "*";
		else:
			toolbtn.text = NAME;
	pass

func _exit_tree():
	if control:
		Git.disconnect("action_event", self, "_on_action_event");
		remove_control_from_bottom_panel(control);
		control.free();
		control = null;
	if control_toolbar_btn:
		remove_control_from_container(CONTAINER_TOOLBAR, control_toolbar_btn);
		control_toolbar_btn.free();
	toolbtn = null;
	Git.kill_process();
	pass