extends "res://addons/godot-git-control.funabab/scripts/cl_base.gd"

var Utils = preload("res://addons/godot-git-control.funabab/scripts/utils/utils.gd");
var WorkspaceObject = preload("res://addons/godot-git-control.funabab/scripts/workspace_object.gd");

var object_identifiers = {
	"A": WorkspaceObject.OBJECT_TYPE_ADDED,
	"D": WorkspaceObject.OBJECT_TYPE_DELETED,
	"C": WorkspaceObject.OBJECT_TYPE_COPIED,
	"M": WorkspaceObject.OBJECT_TYPE_MODIFIED,
	"R": WorkspaceObject.OBJECT_TYPE_RENAMED,
	"U": WorkspaceObject.OBJECT_TYPE_CONFLICT,
	"?": WorkspaceObject.OBJECT_TYPE_NEW,
};

var objects = [];
var workspace_update_hash;
func _setup():
	git.connect("cmd_processed", self, "_on_cmd_ok");
	pass

#func _on_action_event(what, args):
#	if what == git.action.GIT_WORKSPACE_COMMIT_STAGED_OBJECTS:
#		if get_all_selected_object_path().size() > 0:
#			git.show_dialog(git.dialog.VIEW_COMMIT_MSG);
#		else:
#			git.call_action(git.action.WRITE_CONSOLE_OUTPUT, git.Lang.get("nothing_object_seleted_to_commit"));
#	elif what == git.action.GIT_WORKSPACE_REVERT_SELECTED_OBJECTS:
#		if get_all_selected_object_path().size() > 0:
#			git.show_dialog(git.dialog.VIEW_REVERT_WORKSPACE);
#		else:
#			git.call_action(git.action.WRITE_CONSOLE_OUTPUT, git.Lang.get("nothing_object_seleted_to_revert"));
#	pass

func _on_action_event(what, args):
	if what == git.action.START_PROCESS || what == git.action.FATAL_ERROR:
		clear();
	pass

func set_object_selection(idx, selected):
	objects[idx].selected = selected;
	pass

func get_all_selected_object_path():
	var result = [];
	for object in objects:
		if object.selected:
			result.append(object.path);
	return result;
	pass

func _on_cmd_ok(cmd):
	if cmd.type == cmd.GIT_STATUS:
		update_workspace_files(cmd.results);
		if objects.empty() && cmd.show_cmd_in_terminal: # do this when cmd is not a silent one i.e cmd not shown in console
			git.print_output(git.Lang.tr("workspace_empty"));
	elif cmd.type == cmd.GIT_CHECKOUT || cmd.type == cmd.GIT_INIT || cmd.type == cmd.GIT_COMMIT:
		## required in other for re updating of control titles to work properly
		clear();
	pass

func clear():
	workspace_update_hash = null;
	objects = [];
	pass

func update_workspace_files(cmd_status_result):
	if workspace_update_hash == cmd_status_result.hash():
		## A simple hash check to see if workspace changed/updated
		## or return if no changes occured
		return

	clear();
	if !cmd_status_result[0][0].empty():
		var dir = Directory.new();
		var split = cmd_status_result[0][0].c_escape().split("\\n", false);
		for val in split:
			val = val.c_unescape().strip_edges().split(" ", false);

			var object_type = WorkspaceObject.OBJECT_TYPE_UNKNOWN;
			if object_identifiers.has(val[0]):
				object_type = object_identifiers[val[0]];
			var object_path = Utils.unquote_string(val[1]);

#			if val.begins_with(IDENTIFIER_UNKNOWN):
#				object_type = WorkspaceObject.OBJECT_TYPE_UNKNOWN;
#			else:
#				if dir.file_exists("res://" + object_path):
#					object_type = WorkspaceObject.OBJECT_TYPE_MODIFIED;

			objects.push_back(WorkspaceObject.new(object_type, object_path));
	workspace_update_hash = cmd_status_result.hash();
	git.call_action(git.action.UI_WORKSPACE_UPDATE, objects);
	pass