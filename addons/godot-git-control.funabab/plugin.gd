tool
extends EditorPlugin

var git_manager;
var git_control = preload("res://addons/godot-git-control.funabab/controls/git_control.tscn").instance();
var git_toolbar = preload("res://addons/godot-git-control.funabab/controls/git_notification_toolbar.tscn").instance();
var settings_manager = SettingsManager.new();
var plugin_mode;
var git_control_toolbutton;
var fatal_error = false;

func _enter_tree():
	self.git_manager = preload("res://addons/godot-git-control.funabab/scripts/git_manager.gd").GitManager.new(self.get_base_control(), self.settings_manager);
	if (self.startup_error()):
		self.fatal_error = true;
		git_manager.free();
		git_control.free();
		return;

	var GitignoreManager = preload("res://addons/godot-git-control.funabab/scripts/gitignore_manager.gd").GitignoreManager;
	var git_ignore = GitignoreManager.new("res://.gitignore");
	git_ignore.add_exclusion("addons/godot-git-control.funabab/");
	git_ignore.write_all();
	self.git_manager.controller.connect("action_event", self, "_on_action_event");
	plugin_mode = self.settings_manager.get_value_int("git_control", "mode", 1);

	if (plugin_mode == 1 || plugin_mode == 2):
		self.git_control._params(self.git_manager);
		self.git_control_toolbutton = self.add_control_to_bottom_panel(git_control, "Git Control");

	if (plugin_mode == 1 || plugin_mode == 0):
		self.git_toolbar._params(self.git_manager);
		self.add_control_to_container(self.CONTAINER_TOOLBAR, self.git_toolbar);
	self.git_manager._run_refresh();
	self.git_manager.set_auto_refresh(self.settings_manager.get_value_int("git_control", "auto_refresh_duration", 0));
	self.git_manager.set_auto_commit_duration(self.settings_manager.get_value_int("git_control", "auto_commit_duration", 0));
	pass

func startup_error():
	if (!git_manager.is_git_installed()):
		self.show_fatal_error("Git not found\n\nCauses\n.1 Git not properly installed on your machine");
		return true;
	if (!git_manager.is_git_configured()):
		self.show_fatal_error("Git not configured\n\nCauses\n.1 You have not properly setup your git Name or Email");
		return true;
	if (!git_manager.is_git_initialized()):
		self.show_fatal_error("Git have not been initialize in project");
		return true;
	return false;
	pass

func show_fatal_error(msg):
	var fatal_error_output_mode = settings_manager.get_value_int("git_control", "fatal_error_output_mode", 1);
	if (fatal_error_output_mode == 0):
		return;
	elif (fatal_error_output_mode == 2):
		print(msg);
		return;
	msg = "Fatal Error!\n" + msg;
	var accept_dialog = AcceptDialog.new();
	accept_dialog.set_title("Git Control");
	accept_dialog.set_text(msg);
	accept_dialog.set_exclusive(true);
	accept_dialog.set_pos(Vector2((self.get_base_control().get_viewport_rect().size.x - accept_dialog.get_rect().size.x) / 2, (self.get_base_control().get_viewport_rect().size.y - accept_dialog.get_rect().size.y) / 2));
	accept_dialog.show();
	self.get_base_control().add_child(accept_dialog);
	pass

func _exit_tree():
	if (!fatal_error):
		if (plugin_mode == 1 || plugin_mode == 2):
			remove_control_from_bottom_panel(self.git_control);
			self.git_control.free();
		if (plugin_mode == 1 || plugin_mode == 0):
			self.git_toolbar.free();
	pass

func _on_action_event(what, args):
	if (what == self.git_manager.controller.ACTION_WORKSPACE_FILES_UPDATED):
		if (args > 0):
			if (self.plugin_mode == 1 || self.plugin_mode == 2):
				self.git_control_toolbutton.set_text("Git Control*");
		else:
			if (self.plugin_mode == 1 || self.plugin_mode == 2):
				self.git_control_toolbutton.set_text("Git Control");
	if (what == self.git_manager.controller.ACTION_AUTO_COMMIT_ACTIVATED):
		self.git_control_toolbutton.add_color_override("font_color", Color("bc8e8e"));
		self.git_control_toolbutton.add_color_override("font_color_hover", Color("bc8e8e"));
	pass

class SettingsManager:
	var settings_path = "res://addons/godot-git-control.funabab/user_settings.cfg";
	var config;
	var loaded;
	func _init():
		load_settings();
		pass

	func load_settings():
		self.config = ConfigFile.new();
		self.loaded = self.config.load(self.settings_path) == OK;
		pass

	func save_settings():
		return self.config.load(self.settings_path) == OK;
		pass

	func get_value_string(section, key, default = ""):
		if (!self.loaded):
			return default;
		var value;
		if (self.config.has_section(section) && self.config.has_section_key(section, key)):
			value = str(self.config.get_value(section, key));
		else:
			value = str(default);
		return value;
		pass

	func get_value_int(section, key, default):
		if (!self.loaded):
			return default;
		var value;
		if (self.config.has_section(section) && self.config.has_section_key(section, key)):
			value = int(self.config.get_value(section, key));
		else:
			value = int(default);
		return value;
		pass

		return value;
		pass
