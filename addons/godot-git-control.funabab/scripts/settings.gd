extends Reference

const SETTINGS_PATH = "res://addons/godot-git-control.funabab/user_settings.json";

const LAYOUT = {
	"git_path": "",
	"language": ["en"],
	"plugin_mode": ["default", "bottom_dock", "toolbar"],
	"create_gitignore_file": true,
	"auto_refresh_duration": "3",
	"auto_commit_duration": "0"
}

var data = {};

func _init():
	data = get_settings();
	verify_data_layout();
	pass

func verify_data_layout():
	var result = {};
	for key in LAYOUT:
		if !data.has(key):
			result[key] = get_default(key);
			continue;

		match(typeof(LAYOUT[key])):
			TYPE_ARRAY:
				if LAYOUT[key].find(data[key]) == -1:
					result[key] = get_default(key);
				else:
					result[key] = data[key].strip_edges();
			TYPE_BOOL:
				result[key] = bool(data[key]);
			TYPE_STRING:
				result[key] = data[key].strip_edges();
	data = result;
	pass

func get_hash():
	return data.hash();
	pass

func get_settings():
	var file = File.new();
	if file.file_exists(SETTINGS_PATH):
		file.open(SETTINGS_PATH, File.READ);
		var content = file.get_as_text();
		file.close();

		var json_result = JSON.parse(content);
		if json_result.error == OK && typeof(json_result.result) == TYPE_DICTIONARY:
			return json_result.result;
	return get_default_settings();
	pass

func set(key, value):
	data[key] = value;
	pass

func save_settings():
	var json = JSON.print(data);
	var file = File.new();
	file.open(SETTINGS_PATH, File.WRITE);
	file.store_string(json);
	file.close();
	pass

func get_default_settings():
	var result = {}
	for key in LAYOUT:
		result[key] = get_default(key);
	return result;
	pass

func get_default(key):
	return LAYOUT[key][0] if typeof(LAYOUT[key]) == TYPE_ARRAY else LAYOUT[key];
	pass

func get_default_as_int(key):
	return 0 if typeof(LAYOUT[key]) == TYPE_ARRAY else int(LAYOUT[key]);
	pass

func get_as_int(key):
	var data = self.data[key];
	if typeof(LAYOUT[key]) == TYPE_ARRAY && typeof(data) == TYPE_STRING:
		return LAYOUT[key].find(data);
	return int(data);
	pass

func get(key):
	return data[key];
	pass