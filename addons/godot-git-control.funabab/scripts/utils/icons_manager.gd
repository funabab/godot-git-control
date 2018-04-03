extends Reference

const Octicon = preload("res://addons/godot-git-control.funabab/scripts/utils/octicons_codes.gd");
#const FontAwesome = preload("res://addons/godot-git-control.funabab/scripts/utils/font_awesome_codes.gd");

const LOOKUP = {
	"refresh_btn": "octicon-sync",
	"delete_branch_btn": "octicon-trashcan",
	"commit_btn": "octicon-git-commit",
	"diff_btn": "octicon-diff",
	"revert_btn": "octicon-mail-reply",
	"tag_btn": "octicon-tag",
	"rebase_btn": "octicon-circuit-board",
	"merge_btn": "octicon-git-merge",
	"branch_btn": "octicon-git-branch",
	"log_btn": "octicon-book",
	"settings_btn": "octicon-gear",
	"gitignore_btn": "octicon-diff-ignored"
}

const FONTS = {
		"octicon": preload("res://addons/godot-git-control.funabab/scenes/res/octicon_font.tres"),
#		"fa": preload("res://addons/godot-git-control.funabab/scenes/res/font_awesome_font.tres")
};

static func _get_icon(name):
	var split = name.find("-");
	if split == -1: return null;

	var types = {
		"octicon": Octicon,
#		"fa": FontAwesome
	}

	var icon_type = name.left(split);
	var icon_name = name.right(split + 1);

	if types.has(icon_type):
		var code = types[icon_type].get(icon_name);
		if !code.empty():
			return {
				"type": icon_type,
				"code": code
				};
	return null;
	pass

static func _get_font(type):
	if FONTS.has(type):
		return FONTS[type];
	else:
		return null;
	pass
