
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

class GitWorkspaceManager extends Object:

	var git_controller;
	var files = [];
	var workspace_hash;

	const FILE_TYPE_MODIFIED = 1;
	const FILE_TYPE_DELETED = 2
	const FILE_TYPE_UNKNOWN = 3;

	func _init(git_controller):
		self.git_controller = git_controller;
		self.git_controller.git_manager.connect("cmd_processed", self, "_on_cmd_ok");
		pass

	func update_workspace_files(cmd_status_result):
		if (self.workspace_hash == cmd_status_result.hash()):
			## A simple hash check to see if workspace changed/updated
			## or return if no changes occured
			return;
		self.files = [];
		if (!cmd_status_result[0][0].empty()):
			var type;
			var filetype;
			var filepath;
			var dir = Directory.new();
			var split = cmd_status_result[0][0].c_escape().split("\\n", false);
			for val in split:
				val = val.c_unescape();
				type = val.substr(0, 2);
				filepath = self.git_controller.git_manager.Utils.unquote_string(val.right(3));
				if (type == "??"):
					filetype = self.FILE_TYPE_UNKNOWN;
				else:
					if (dir.file_exists("res://" + filepath)):
						filetype = self.FILE_TYPE_MODIFIED;
					else:
						filetype = self.FILE_TYPE_DELETED;
				self.files.push_back(WorkspaceFile.new(filepath, filetype));
		self.workspace_hash = cmd_status_result.hash();
		self.git_controller._call_action(self.git_controller.ACTION_WORKSPACE_FILES_UPDATED, self.get_files_count()); 
		pass

	func get_all_files():
		return self.files;
		pass

	func get_all_files_path():
		var result = [];
		for val in self.get_all_files():
			result.append(val._get_path());
		return result;
		pass

	func get_files_count():
		return self.get_all_files().size();
		pass

	func _on_cmd_ok(cmd):
		var cmd_type = cmd._get_type();
		if (cmd_type == self.git_controller.git_manager.cmd_manager.CMD_GIT_STATUS):
			self.update_workspace_files(cmd._get_results());
			pass
		elif (cmd_type == self.git_controller.git_manager.cmd_manager.CMD_GIT_CHECKOUT):
			self.workspace_hash = null;## required in other for re updating of control titles to work properly
		pass
	
	class WorkspaceFile:
		var path;
		var type;

		func _init(path, type):
			self.path = path;
			self.type = type;
			pass

		func _get_type():
			return self.type;
			pass

		func _get_path():
			return self.path;
			pass