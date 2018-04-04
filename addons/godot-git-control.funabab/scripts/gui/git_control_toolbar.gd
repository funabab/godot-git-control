tool
extends MenuButton

var menu_branches;
var menu_delete_branches;

const ITEM_REFRESH = 0;
const ITEM_CHECKOUT_BRANCH = 1;
const ITEM_DELETE_BRANCH = 2;
const ITEM_COMMIT_ALL = 3;
const ITEM_REVERT_ALL = 4;
#const ITEM_FETCH = 5;
#const ITEM_PULL = 6;
const ITEM_CREATE_BRANCH = 7;
const ITEM_MERGE_BRANCH = 8;
const ITEM_REBASE_BRANCH = 9;
const ITEM_TAG = 10;
const ITEM_GITIGNORE_MANAGER = 11;
const ITEM_SETTINGS = 12;
const ITEM_LAUNCH_TERMINAL = 13;

onready var items_cat = [
	{
		ITEM_REFRESH: Lang.tr("item_refresh")
	},

	{
		ITEM_CHECKOUT_BRANCH: Lang.tr("item_checkout_branch"),
		ITEM_DELETE_BRANCH: Lang.tr("item_delete_branch")
	},

	{
		ITEM_COMMIT_ALL: Lang.tr("item_commit_all"),
		ITEM_REVERT_ALL: Lang.tr("item_revert_all"),
	},

	{
		ITEM_CREATE_BRANCH: Lang.tr("item_create_branch"),
		ITEM_MERGE_BRANCH: Lang.tr("item_merge_branch"),
		ITEM_REBASE_BRANCH: Lang.tr("item_rebase_branch")
	},

	{
		ITEM_TAG: Lang.tr("item_tag")
	},

	{
		ITEM_GITIGNORE_MANAGER: Lang.tr("item_gititnore_manager"),
		ITEM_SETTINGS: Lang.tr("item_settings")
	},

	{
		ITEM_LAUNCH_TERMINAL: Lang.tr("node_text_launch_terminal_btn")
	}
]

var current_branch_name;
var git;
var Lang;
func setup(git):
	self.git = git;
	Lang = self.git.Lang;
	pass

func _ready():
	var popup = get_popup();
	popup.connect("id_pressed", self, "_on_item_id_pressed");
	git.connect("action_event", self, "_on_action_event");
	menu_branches = PopupMenu.new();
	menu_branches.name = "menu_branches";

	menu_delete_branches = PopupMenu.new();
	menu_delete_branches.name = "menu_delete_branches";
	popup.add_child(menu_branches);
	popup.add_child(menu_delete_branches);

	menu_branches.connect("index_pressed", self, "_on_menu_branches_index_pressed");
	menu_delete_branches.connect("index_pressed", self, "_on_menu_delete_branches_index_pressed");

	var size = items_cat.size();
	for i in size:
		var cat = items_cat[i];
		for item in cat:
			if item == ITEM_CHECKOUT_BRANCH:
				popup.add_submenu_item(cat[item], menu_branches.name);
			elif item == ITEM_DELETE_BRANCH:
				popup.add_submenu_item(cat[item], menu_delete_branches.name);
			else:
				popup.add_item(cat[item], item);
		if i < size - 1:
			popup.add_separator();
	pass

func update_branches(branches):
	current_branch_name = branches[0];
	var branch_count = branches.size();
	menu_branches.clear();
	menu_delete_branches.clear();
	for i in branch_count:
		menu_branches.add_item(branches[i], i);
		menu_delete_branches.add_item(branches[i], i);
	menu_branches.set_item_disabled(0, true);
	menu_delete_branches.set_item_disabled(0, true);

	var popup = get_popup();
	popup.set_item_disabled(get_item_idx(ITEM_MERGE_BRANCH), branch_count < 2);
	popup.set_item_disabled(get_item_idx(ITEM_REBASE_BRANCH), branch_count < 2);
	pass

func _on_item_id_pressed(item_id):
	if item_id == ITEM_REFRESH:
		git.run_refresh(true, true);
	elif item_id == ITEM_COMMIT_ALL:
		git.call_action(git.action.GIT_WORKSPACE_COMMIT_SELECTED_OBJECTS);
	elif item_id == ITEM_REVERT_ALL:
		git.call_action(git.action.GIT_WORKSPACE_REVERT_SELECTED_OBJECTS);
	elif item_id == ITEM_CREATE_BRANCH:
		git.call_action(git.action.GIT_CREATE_BRANCH);
	elif item_id == ITEM_MERGE_BRANCH:
		git.call_action(git.action.GIT_MERGE_BRANCH);
	elif item_id == ITEM_REBASE_BRANCH:
		git.call_action(git.action.GIT_REBASE);
	elif item_id == ITEM_TAG:
		git.call_action(git.action.GIT_CREATE_TAG);
	elif item_id == ITEM_GITIGNORE_MANAGER:
		git.call_action(git.action.GIT_GITIGNORE_MANAGER);
	elif item_id == ITEM_SETTINGS:
		git.call_action(git.action.GIT_SHOW_SETTINGS);
	elif item_id == ITEM_LAUNCH_TERMINAL:
		git.call_action(git.action.SHOW_TERMINAL);
	pass

func _on_menu_branches_index_pressed(index):
	git.call_action(git.action.GIT_CHECKOUT_BRANCH, index);
	pass

func _on_menu_delete_branches_index_pressed(index):
	git.call_action(git.action.GIT_DELETE_BRANCH, index);
	pass

func set_title(postfix = ""):
	text = current_branch_name + postfix;
	pass

func _on_action_event(what, args):
	if what == git.action.UI_BRANCH_UPDATE:
		update_branches(args);
	elif what == git.action.UI_WORKSPACE_UPDATE:
		var empty_workspace = args.size() == 0;
		set_title("*" if !empty_workspace else "");
		var popup = get_popup();
		popup.set_item_disabled(get_item_idx(ITEM_COMMIT_ALL), empty_workspace);
		popup.set_item_disabled(get_item_idx(ITEM_REVERT_ALL), empty_workspace);
	elif what == git.action.UI_TERMINAL_NOT_FOUND:
		get_popup().set_item_disabled(get_item_idx(ITEM_LAUNCH_TERMINAL), true);
	elif what == git.action.FATAL_ERROR:
		visible = false;
	elif what == git.action.START_PROCESS:
		visible = true;
	pass

func get_item_idx(id):
	var popup = get_popup();
	var item_count = popup.get_item_count();
	for i in item_count:
		if id == popup.get_item_id(i):
			return i;
	return -1;
	pass