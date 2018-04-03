extends Reference

static func string_array_to_string(array, prefix = "", suffix = "", quote_whitespace_spaced_text = false):
	var result = "";
	for val in array:
		if (quote_whitespace_spaced_text):
			if (val.find(" ") != -1):
				val = "\"" + val + "\"";
		result += prefix + val + suffix;
	return result;
	pass

static func unquote_string(text):
	text.strip_edges();
	if text[0] != "\"" && text[text.length()-1] != "\"":
		return text;
	return text.substr(1, text.length()-2);
	pass

#static func split_cmd_text(text):
#	## TODO: use regex expression instead
#	var result = [];
#	var in_quote = false;
#
#	var split = "";
#	var length = text.length();
#
#	for i in range(length):
#		var c_char = text[i];
#		var p_char = text[max(0, i - 1)];
#
#		if c_char == "\"":
#			if p_char != "\\":
#				in_quote = !in_quote;
#				if split:
#					result.append(split);
#					split = "";
#				continue;
#			else:
#				split = split.left(split.length() - 1); ## remove backslash
#
#		if c_char == " " && !in_quote:
#			if split:
#				result.append(split);
#				split = "";
#			continue;
#
#		split += c_char;
#		if i == length - 1:
#			if split:
#				result.append(split);
#				split = "";
#	return result;
#	pass

static func split_cmd_text(text):
	## TODO: use regex expression instead
	var result = [];
	var in_quote = false;

	var split = "";
	var length = text.length();

	for i in range(length):
		var c_char = text[i];
		var p_char = text[max(0, i - 1)];
		var n_char = text[i + 1] if i < length - 1 else null;

		if c_char == "\\" && n_char == "\"":
			continue;
		elif c_char == "\"" && p_char != "\\":
				in_quote = !in_quote;
				if split:
					result.append(split);
					split = "";
				continue;

		if c_char == " " && !in_quote:
			if split:
				result.append(split);
				split = "";
			continue;

		split += c_char;
		if i == length - 1:
			if split:
				result.append(split);
				split = "";
	return result;
	pass

static func get_node_type_in_children(node, type):
	var _scan = node;
	var _results = [];
	var _history = [];
	var idx = 0;

	while(true):
		var i = idx;
		var count = _scan.get_child_count();
		while(i < count):
			var child = _scan.get_child(i);
			if ClassDB.is_parent_class(child.get_class(), type):
				_results.append(child);
			if child.get_child_count() > 0:
				_history.append(child);
				_scan = child;
				idx = 0;
				break;
			i += 1;

		if _history.empty(): break;
		else:
			if i == count:
				var last = _history.back();
				_scan = last.get_parent();
				idx = last.get_index() + 1;
				_history.pop_back();
	return _results;
	pass

static func node_operation_in_children(node, type, function):
	var _scan = node;
	var _history = [];
	var idx = 0;

	while(true):
		var i = idx;
		var count = _scan.get_child_count();
		while(i < count):
			var child = _scan.get_child(i);
			if ClassDB.is_parent_class(child.get_class(), type):
				function.call_func(child);
			if child.get_child_count() > 0:
				_history.append(child);
				_scan = child;
				idx = 0;
				break;
			i += 1;

		if _history.empty(): break;
		else:
			if i == count:
				var last = _history.back();
				_scan = last.get_parent();
				idx = last.get_index() + 1;
				_history.pop_back();
	pass