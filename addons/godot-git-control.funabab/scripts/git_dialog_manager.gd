extends Object

const VIEW_COMMIT_MSG = 1;
const VIEW_CREATE_BRANCH = 2;
const VIEW_DELETE_BRANCH = 3;
const VIEW_REVERT_WORKSPACE = 4;
const VIEW_CREATE_TAG = 5;
const VIEW_MERGE_BRANCH = 6;
const VIEW_REBASE = 7;
const VIEW_SETTINGS = 8;
const VIEW_GITIGNORE = 9;

var views = {
	VIEW_COMMIT_MSG: preload("res://addons/godot-git-control.funabab/scenes/commit_message_dialog.tscn").instance(),
	VIEW_CREATE_BRANCH: preload("res://addons/godot-git-control.funabab/scenes/create_branch_dialog.tscn").instance(),
	VIEW_DELETE_BRANCH: preload("res://addons/godot-git-control.funabab/scenes/delete_branch_dialog.tscn").instance(),
	VIEW_REVERT_WORKSPACE: preload("res://addons/godot-git-control.funabab/scenes/revert_confirm_dialog.tscn").instance(),
	VIEW_CREATE_TAG: preload("res://addons/godot-git-control.funabab/scenes/create_tag_dialog.tscn").instance(),
	VIEW_MERGE_BRANCH: preload("res://addons/godot-git-control.funabab/scenes/merge_branch_dialog.tscn").instance(),
	VIEW_REBASE: preload("res://addons/godot-git-control.funabab/scenes/rebase_dialog.tscn").instance(),
	VIEW_SETTINGS: preload("res://addons/godot-git-control.funabab/scenes/settings_dialog.tscn").instance(),
	VIEW_GITIGNORE: preload("res://addons/godot-git-control.funabab/scenes/gitignore_dialog.tscn").instance()
};

var git;
func _init(git):
	self.git = git;
	self.git.connect("action_event", self, "_on_action_event");

	for key in views:
		views[key].setup(self, key);
		git.base_control.add_child(views[key]);
	pass

func _on_dialog_confirmed(dialog, args = null):
	if dialog == VIEW_COMMIT_MSG:
		git.run_cmd_commit(git.cl_workspace.get_all_selected_object_path(), args);
	elif dialog == VIEW_CREATE_BRANCH:
		git.run_create_branch(args.name, args.checkout_branch);
	elif dialog == VIEW_DELETE_BRANCH:
		git.run_branch_delete(args.branch, args.force);
	elif dialog == VIEW_REVERT_WORKSPACE:
		git.run_cmd_revert(git.cl_workspace.get_all_selected_object_path());
	elif dialog == VIEW_CREATE_TAG:
		git.run_cmd_tag(args.tag_name, args.tag_commit_ref, args.tag_message, args.force);
	elif dialog == VIEW_MERGE_BRANCH:
		git.run_cmd_merge(git.cl_branch.get_branch(args.merge_branch_idx), args.no_fast_forward);
	elif dialog == VIEW_REBASE:
		git.run_cmd_rebase(git.cl_branch.get_branch(args));
	elif dialog == VIEW_SETTINGS:
		var modified = args;
		if modified:
			git.print_output(git.Lang.tr("reload_to_commit_changes"));
	pass

func _on_action_event(what, args):
	if what == git.action.KILL_ALL_PROCESS:
		git.disconnect("action_event", self, "_on_action_event");
		call_deferred("free");
	pass

func show(what, args = null):
	for key in views:
		if key == what:
			views[what].show_dialog(args);
		else:
			views[key].visible = false;
	pass

