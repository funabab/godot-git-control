
class CMD:

	var type;
	var commands = [];
	var results = [];
	var show_cmd_in_console;
	var show_result_in_console;

	func _init(type, show_cmd_in_console = true, show_result_in_console = false):
		self.type = type;
		self.show_cmd_in_console = show_cmd_in_console;
		self.show_result_in_console = show_result_in_console;
		pass

	func _push_command(command):
		self.commands.push_back(command);
		pass

	func _push_result(result):
		self.results.push_back(result);
		pass

	func _get_type():
		return self.type;
		pass

	func _get_commands():
		return self.commands;
		pass

	func _get_results():
		return self.results;
		pass
