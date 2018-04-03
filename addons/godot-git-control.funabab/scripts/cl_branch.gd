extends "res://addons/godot-git-control.funabab/scripts/cl_base.gd"

var branches = [];
var branches_update_hash;

func _setup():
	git.connect("cmd_processed", self, "_on_cmd_ok");
	pass

#func _on_action_event(what, args):
#	if what == git.action.GIT_CHECKOUT_BRANCH:
#		git.run_cmd_checkout(branches[args]);
#	elif what == git.action.GIT_DELETE_BRANCH:
#		git.show_dialog(git.dialog.VIEW_DELETE_BRANCH, branches[args]);
#	pass

func _on_action_event(what, args):
	if what == git.action.START_PROCESS || what == git.action.FATAL_ERROR:
		clear();
	pass

func get_branch(id):
	return branches[id];
	pass

func get_branches_count():
	return branches.size();
	pass

func _on_cmd_ok(cmd):
	if cmd.type == cmd.GIT_BRANCH:
		update_branches(cmd.results);
	elif cmd.type == cmd.GIT_CHECKOUT || cmd.type == cmd.GIT_INIT || cmd.type == cmd.GIT_COMMIT:
		## required in other for re updating of control titles to work properly
		clear();
	pass

func clear():
	branches_update_hash = null;
	branches = [];
	pass

func add_branch(name):
	if name.begins_with("*"):
		name = name.right(2);
		branches.push_front(name);
	else:
		branches.push_back(name);
	pass

func update_branches(cmd_branch_result):
	if branches_update_hash == cmd_branch_result.hash():
		## A simple hash check to see if branches changed/updated
		## or return if no changes occured
		return;

	clear();
	if cmd_branch_result[0][0].empty():
		## If git was initalized (an empty repo was created), git by default wont return any branches with [git branch]
		## Just assume (create) branch master if that occurs
		self.add_branch("* master");
	else:
		var split = cmd_branch_result[0][0].c_escape().split("\\n", false);
		var id = 0;
		for branch in split:
			branch = branch.strip_edges();
			add_branch(branch);
	branches_update_hash = cmd_branch_result.hash();
	git.call_action(git.action.UI_BRANCH_UPDATE, branches);
	pass
