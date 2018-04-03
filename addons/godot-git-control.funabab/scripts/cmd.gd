extends Reference

const GIT_BRANCH = 1;
const CREATE_BRANCH = 2;
const GIT_CHECKOUT = 3;
const BRANCH_DELETE = 4;
const GIT_LOG = 5;
const GIT_STATUS = 6;
const GIT_TAG = 7;
const GIT_COMMIT = 8;
const GIT_DIFF = 9
const GIT_REVERT = 10;
const GIT_REBASE = 11;
const GIT_MERGE = 12;
#const GIT_FETCH = 13;
const GIT_REMOTE = 14;
#const GIT_PULL = 15;
const GIT_INIT = 16;
const CUSTOM = 17;

var type;
var commands = [];
var results = [];
var show_result_in_output = false;
var show_cmd_in_terminal = true;
var show_result_in_terminal = false;

func _init(type):
	self.type = type;
	pass

func push_command(cmd):
	commands.push_back(cmd);
	pass

func push_result(result):
	results.push_back(result);
	pass
