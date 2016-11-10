
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

class Utils:

	static func string_array_to_string(array, prefix = "", suffix = "", quote_whitespace_spaced_text = false):
		var result = "";
		for val in array:
			if (quote_whitespace_spaced_text):
				if (val.find(" ") != -1):
					val = "\"" + val + "\"";
			result = result + prefix + val + suffix;
		return result;
		pass

	static func merge_array(dest, src):
		if (typeof(dest) != typeof(src)):
			return [];
		for val in src:
			dest.push_back(val);
		return dest;
		pass

	static func unquote_string(text):
		text.strip_edges();
		if (text[0] != "\"" && text[text.length()-1] != "\""):
			return text;
		return text.substr(1, text.length()-2);
		pass

	static func get_datetime_string():
		var datetime = OS.get_datetime();
		return str(datetime["day"]) + "/" + str(datetime["month"]) + "/" + str(datetime["year"]) + "/ " + str(datetime["hour"]) + ":" + str(datetime["minute"]) + ":" + str(datetime["second"]);
		pass


