extends "res://addons/godot-git-control.funabab/scripts/cl_base.gd"

const REMOTE_FETCH = "(fetch)";
const REMOTE_PUSH = "(push)";

var RemoteObject = preload("res://addons/godot-git-control.funabab/scripts/remote_object.gd");
var remotes = {
	REMOTE_FETCH: [],
	REMOTE_PUSH: []
};

var remote_update_hash = null;
func _setup():
	git.connect("cmd_processed", self, "_on_cmd_ok");
	pass

func clear():
	remote_update_hash = null;
	remotes[REMOTE_FETCH] = [];
	remotes[REMOTE_PUSH] = [];
	pass

func update_remotes(cmd_remote_result):
	if remote_update_hash == cmd_remote_result.hash():
		return;

	clear();
	if cmd_remote_result[0][0].empty():
		return;
	var split = cmd_remote_result[0][0].c_escape().split("\\n", false);
	for val in split:
		var chunk = val.split("\\t");
		var remote_name = chunk[0].strip_edges();
		var pos = chunk[1].find_last(" ");
		var remote_url = chunk[1].substr(0, pos).strip_edges();
		var remote_type = chunk[1].right(pos).strip_edges();

		if remotes.has(remote_type):
			remotes[remote_type].append(RemoteObject.new(remote_name, remote_url));
	remote_update_hash = cmd_remote_result.hash();
	pass

func get_remote_count(type):
	if remotes.has(type):
		return remotes[type].size();
	return 0;
	pass

func _on_cmd_ok(cmd):
	if cmd.type == cmd.GIT_REMOTE:
		update_remotes(cmd.results);
	pass