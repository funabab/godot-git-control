
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

class GitRemoteManager extends Object:

	var git_controller;
	var remotes = [];

	func _init(git_controller):
		self.git_controller = git_controller;
		self.git_controller.git_manager.connect("cmd_processed", self, "_on_cmd_ok");
		pass

	func set_remote_url(remote_name, remote_url, url_type):
		var remote_ = self.get_remote(remote_name);
		if (remote_ == null):
			remote_ = Remote.new(remote_name);
			self.remotes.push_back(remote_);
		if (url_type == "(fetch)"):
			remote_._set_fetch_url(remote_url);
		elif (url_type == "(push)"):
			remote_._set_push_url(remote_url);
		pass

	func get_remote(remote_name):
		for val in self.remotes:
			if (val._get_name() == remote_name):
				return val;
		return null;
		pass

	func get_remotes_count():
		return self.remotes.size();
		pass

	func update_remotes(cmd_remote_result):
		var chunk;
		var remote_name;
		var remote_url;
		var remote_url_type;
		self.remotes = [];
		if (cmd_remote_result[0][0].empty()):
			return;
		var split = cmd_remote_result[0][0].c_escape().split("\\n", false);
		for val in split:
			var chunk = val.split("\\t");
			remote_name = chunk[0].strip_edges();
			remote_url = chunk[1].substr(0, chunk[1].find_last(" ")).strip_edges();
			remote_url_type = chunk[1].right(chunk[1].find_last(" ")).strip_edges();
			self.set_remote_url(remote_name, remote_url, remote_url_type);
		pass

	func _on_cmd_ok(cmd):
		if (cmd._get_type() == self.git_controller.git_manager.cmd_manager.CMD_GIT_REMOTE):
			self.update_remotes(cmd._get_results());
			self.git_controller._call_action(self.git_controller.ACTION_REMOTES_UPDATED, self.get_remotes_count());
		pass

	class Remote:
		var name;
		var fetch_url;
		var push_url;
	
		func _init(name):
			self.name = name;
			pass
	
		func _get_name():
			return self.name;
			pass
	
		func _get_fetch_url():
			return self.fetch_url;
			pass
	
		func _get_push_url():
			return self.push_url;
			pass
	
		func _set_fetch_url(url):
			self.fetch_url = url;
			pass
	
		func _set_push_url(url):
			self.push_url = url;
			pass

