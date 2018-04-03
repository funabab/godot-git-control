extends Reference

## git related actions
const GIT_INITIALIZE = 1;
const GIT_CREATE_BRANCH = 2;
const GIT_CHECKOUT_BRANCH = 3;
const GIT_DELETE_BRANCH = 4;
const GIT_MERGE_BRANCH = 5;
const GIT_REBASE = 6;
const GIT_CREATE_TAG = 7;
const GIT_DIFF = 8
#const GIT_FETCH = 9;
#const GIT_PULL = 10;
const GIT_WORKSPACE_OBJECT_SELECTION = 11;
const GIT_WORKSPACE_COMMIT_SELECTED_OBJECTS = 12;
const GIT_WORKSPACE_REVERT_SELECTED_OBJECTS = 13;
#const GIT_REMOTES_UPDATED = 14;
#const GIT_AUTO_REFRESH_ACTIVATED = 15;
#const GIT_AUTO_COMMIT_ACTIVATED = 16;
const GIT_SHOW_SETTINGS = 17;
const GIT_GITIGNORE_MANAGER = 18;

## ui related actions
const UI_BRANCH_UPDATE = 19;
const UI_WORKSPACE_UPDATE = 20;
const UI_WRITE_CONSOLE_OUTPUT = 21;
const UI_WRITE_GIT_TERMINAL = 22;
const UI_TERMINAL_NOT_FOUND = 23

const KILL_ALL_PROCESS = 24;
const FATAL_ERROR = 25;
const INITIALIZED_GIT = 26;
const START_PROCESS = 27;
const SHOW_TERMINAL = 28;

const ACTION_TEXTS = {
	GIT_INITIALIZE: "git:initialize"
}

static func get_action_as_text(action):
	if ACTION_TEXTS.has(action):
		return ACTION_TEXTS[action];
	else:
		return null;
	pass

static func get_action_from_text(value):
	var k = 0;
	for key in ACTION_TEXTS:
		if ACTION_TEXTS[key] == value:
			k = key;
			break;
	return k;
	pass