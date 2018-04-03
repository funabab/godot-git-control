extends Reference

const FILE = "res://.gitignore";
const DEFAULT_PATTERNS = [
	"/.import/*",
	"/addons/godot-git-control.funabab/*"];

func initialize():
	var dir = Directory.new();
	if !dir.file_exists(FILE):
		save_patterns(DEFAULT_PATTERNS);
	pass

func save_patterns(patterns):
	var file = File.new();
	file.open(FILE, File.WRITE);
	for pattern in patterns:
		file.store_line(pattern);
	file.close();
	pass

func load_patterns():
	var patterns = [];
	var file = File.new();
	file.open(FILE, File.READ);
	while(!file.eof_reached()):
		var line = file.get_line().strip_edges();
		if !line.empty() && !line.begins_with("#"):
			patterns.append(line);
	file.close();
	return patterns;
	pass
