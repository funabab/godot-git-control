extends "res://addons/godot-git-control.funabab/scripts/cl_base.gd"

var Utils = preload("res://addons/godot-git-control.funabab/scripts/utils/utils.gd");
const CMD_CONSOLE_PREFIX = "> git ";

func _setup():
	git.connect("cmd_processed", self, "_on_cmd_ok");
	pass

func _on_cmd_ok(cmd):
	if cmd.show_cmd_in_terminal:
		print_cmd_console(parse_cmd_message(cmd));

	if cmd.type == cmd.GIT_DIFF:
		var diff = parse_diff(cmd.results[0][0]);
		if diff:
			print_output(diff);
	else:
		if cmd.show_result_in_output:
			var out = "";
			for result in cmd.results:
				out += Utils.string_array_to_string(result, "", "\n") + "\n";
			print_output(out);
	pass

func parse_diff(data):
	if data.empty():
		return null;
	var result = PoolStringArray();
	var lines = data.c_unescape().split("\n");
	for line in lines:
		var val = line;
		if line.begins_with("diff --git "):
			val = val.right("diff --git ".length());
			val = val.substr(0, val.find_last(" ")).get_file();
			val = "[color=aqua][b]" + val + "[/b][/color]";
		elif line.begins_with("index "):
			continue;
		elif line.begins_with("---") || line.begins_with("+++"):
			continue;
		elif line.begins_with("-"):
			##removed lines
			val = "\t[color=red]" + val + "[/color]";
		elif line.begins_with("+"):
			##added lines
			val = "\t[color=teal]" + val + "[/color]";
		elif line.begins_with("@@"):
			val = "[color=gray]" + val + "[/color]";
		else:
			val = "\t" + val;
		result.append(val);
	return result.join("\n");
	pass

func parse_cmd_message(cmd):
	var message = "";
	for i in range(cmd.commands.size()):
		message += CMD_CONSOLE_PREFIX + Utils.string_array_to_string(cmd.commands[i], "", " ", true) + "\n";
		if (cmd.show_result_in_terminal && !cmd.results[i][0].empty()):
			message += Utils.string_array_to_string(cmd.results[i], "", "\n");
	return message;
	pass

func print_cmd_console(message):
	if !message.empty():
		git.call_action(git.action.UI_WRITE_GIT_TERMINAL, message);
	pass

func print_output(message):
	if !message.empty():
		git.call_action(git.action.UI_WRITE_CONSOLE_OUTPUT, message);
	pass

