
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

# This class manages git branches
class GitBranchManager extends Object:

	var git_controller;
	var branches = [];
	var current_branch_idx = -1;
	var branches_hash;

	func _init(git_controller):
		self.git_controller = git_controller;
		self.git_controller.git_manager.connect("cmd_processed", self, "_on_cmd_ok");
		pass

	func _on_cmd_ok(cmd):
		var cmd_type = cmd._get_type();
		if (cmd_type == self.git_controller.git_manager.cmd_manager.CMD_GIT_BRANCH):
			self.update_branches(cmd._get_results());
		elif (cmd_type == self.git_controller.git_manager.cmd_manager.CMD_GIT_CHECKOUT):
			self.branches_hash = null; ## required in other for re updating of control titles to work properly
		pass

	func add_branch(name):
		if (name.begins_with("*")):
			name = name.right(2);
			self.branches.push_back(name);
			self.current_branch_idx = self.branches.size()-1;
		else:
			self.branches.push_back(name);
		pass

	func update_branches(cmd_branch_result):
		if (self.branches_hash == cmd_branch_result.hash()):
			## A simple hash check to see if branches changed/updated
			## or return if no changes occured
			return;
		self.branches = [];
		self.current_branch_idx = -1;

		if (cmd_branch_result[0][0].empty()):
			## If git was initalized (an empty repo was created), git by default wont return any branches with [git branch]
			## Just assume (create) branch master if that occurs
			self.add_branch("* master");
			self.git_controller.write_output("Git Initialized!\nFor best of experience, please make your first commit");
		else:
			var split = cmd_branch_result[0][0].c_escape().split("\\n", false);
			var id = 0;
			for branch in split:
				branch = branch.strip_edges();
				self.add_branch(branch);
		self.branches_hash = cmd_branch_result.hash();
		self.git_controller._call_action(self.git_controller.ACTION_BRANCHES_UPDATED, self.get_branches_count());
		pass

	func get_current_branch_name():
		if (self.current_branch_idx == -1):
			return "";
		return self.branches[self.current_branch_idx];
		pass

	func get_all_branch_names(exclude_current = false):
		if (!exclude_current):
			return self.branches;
		var result = [];
		for i in range(self.branches.size()):
			if (i == self.current_branch_idx):
				continue;
			result.append(self.branches[i]);
		return result;
		pass

	func get_branches_count():
		return self.branches.size();
		pass
