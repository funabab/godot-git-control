
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

class GitignoreManager extends Object:

	var path;
	var process;
	var patterns_queue = [];

	func _init(path):
		self.path = path;
		self.process = Thread.new();
		pass

	func add_exclusion(path):
		if (path.begins_with("!") || path.begins_with("#")):
			path = "\\" + path;
		self.patterns_queue.append(path);
		pass

	func add_inclusion(path):
		self.patterns_queue.append("!" + path);
		pass

	func write_all():
		if (self.patterns_queue.empty() || self.process.is_active()):
			return;
		self.process.start(self, "_process_patterns");
		pass

	func _process_patterns(params = null):
		var file = File.new();
		if (file.file_exists(self.path)):
			file.open(self.path, file.READ_WRITE);
		else:
			file.open(self.path, file.WRITE_READ);
		self.remove_existing_patterns(file);
		for val in self.patterns_queue:
			file.store_line(val);
		file.close();
		pass

	func remove_existing_patterns(file):
		var line;
		file.seek(0);
		while(!file.eof_reached()):
			line = file.get_line().strip_edges();
			for i in range(self.patterns_queue.size()):
				##just used string similarity, no real reason behind it
				if line.similarity(self.patterns_queue[i]) == 1:
					self.patterns_queue.remove(i);
					break
		pass


