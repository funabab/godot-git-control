
## Copyright (c) 2016 AA. Funsho
## funabab@gmail.com

tool
extends Tree

var root_control;
var dropdown_icon = preload("res://addons/godot-git-control.funabab/images/dropdown.png");
var checked_icon = preload("res://addons/godot-git-control.funabab/images/checked.png");
var unchecked_icon = preload("res://addons/godot-git-control.funabab/images/unchecked.png");

var root_item;
var root_item_bg_color = Color("312e37");
var item_file_color_modified = Color("f1f1aa");
var item_file_color_deleted = Color("929293");
var item_file_color_unknown = Color("a5efac");
var item_empty_color = Color("929293");


const META_ITEM_TYPE = "item_type";
const META_ITEM_SELECTED = "item_checked";

const ITEM_TYPE_PARENT = "item_type_parent";
const ITEM_TYPE_CHILD = "item_type_child";
const ITEM_TYPE_CHILD_EMPTY = "item_type_child_empty";

func _enter_tree():
	self.root_control = self.get_node("../../../").get_parent();

	self.create_item();
	self.set_hide_root(true);
	self.set_hide_folding(true);
	self.set_columns(3);

	self.set_column_expand(0, false);
	self.set_column_expand(1, true);
	self.set_column_expand(2, false);

	self.set_column_min_width(0, 36)
	self.set_column_min_width(2, 36);

	self.connect("button_pressed", self, "_on_item_selected");
	self.root_control.git_manager.controller.connect("action_event", self, "_on_action_event");
	pass

func create_root_item(disable_check_select = false):
	if (self.root_item != null):
		self.get_root().remove_child(self.root_item);
	self.root_item = self.create_item_parent(self.get_root(), "workspace", disable_check_select);
	pass

func create_item_parent(parent, name, disable_check_select = false):
	var item = self.create_item(parent);

	item.set_cell_mode(0, item.CELL_MODE_STRING);
	item.set_cell_mode(1, item.CELL_MODE_STRING);

	item.set_text(0, ""); ## There is a font-awesome fa-angle-down icon here, which godot cant may not show.
	item.set_text(1, name);
	item.add_button(2, unchecked_icon, 0, disable_check_select);

	item.set_selectable(0, false);
	item.set_selectable(1, false);

	item.set_custom_bg_color(0, self.root_item_bg_color);
	item.set_custom_bg_color(1, self.root_item_bg_color);
	item.set_custom_bg_color(2, self.root_item_bg_color);

	item.set_meta(self.META_ITEM_TYPE, self.ITEM_TYPE_PARENT);
	item.set_meta(self.META_ITEM_SELECTED, false);
	return item;
	pass

func create_item_child(parent, workspace_file):
	var item = create_item(parent);

	item.set_cell_mode(0, item.CELL_MODE_STRING);
	item.set_cell_mode(1, item.CELL_MODE_STRING);

	if (workspace_file._get_type() == self.root_control.git_manager.controller.workspace.FILE_TYPE_MODIFIED):
		item.set_text(0, ""); ## There is a font-awesome fa-file icon here, which godot cant may not show.
		item.set_custom_color(1, self.item_file_color_modified);
	elif (workspace_file._get_type() == self.root_control.git_manager.controller.workspace.FILE_TYPE_DELETED):
		item.set_text(0, ""); ## There is a font-awesome fa-times icon here, which godot cant may not show.
		item.set_custom_color(1, self.item_file_color_deleted);
	else:
		item.set_text(0, ""); ## There is a font-awesome fa-question-circle icon here, which godot cant may not show.
		item.set_custom_color(1, self.item_file_color_unknown);
	item.set_text(1, workspace_file._get_path());
	item.add_button(2, checked_icon, 0);

	item.set_selectable(0, false);
	item.set_selectable(1, false);

	item.set_meta(self.META_ITEM_TYPE, self.ITEM_TYPE_CHILD);
	item.set_meta(self.META_ITEM_SELECTED, true);
	return item;
	pass

func create_child_item_empty(parent, name):
	var item = create_item(parent);

	item.set_cell_mode(1, item.CELL_MODE_STRING);
	item.set_text(1, name);
	item.set_custom_color(1, self.item_empty_color);

	item.set_selectable(0, false);
	item.set_selectable(1, false);
	item.set_selectable(2, false);

	item.set_meta(self.META_ITEM_TYPE, self.ITEM_TYPE_CHILD_EMPTY);
	return item;
	pass

func _on_item_selected(item, column_id, btn_id):
	var texture;
	var toogle = !item.get_meta(self.META_ITEM_SELECTED);
	if (toogle):
		texture = self.checked_icon;
	else:
		texture = self.unchecked_icon;
	if (item.get_meta(self.META_ITEM_TYPE) == self.ITEM_TYPE_PARENT):
		self.select_children(item, toogle);
	item.set_button(2, 0, texture);
	item.set_meta(self.META_ITEM_SELECTED, toogle);
	self.select_action(item);
	pass

func select_children(parent, toogle):
	if (parent == null):
		return;
	var texture;
	if (toogle):
		texture = self.checked_icon;
	else:
		texture = self.unchecked_icon;
	var child = parent.get_children();
	while(true):
		if (child == null):
			break;
		if (child.get_meta(self.META_ITEM_TYPE) == self.ITEM_TYPE_CHILD_EMPTY):
			child = child.get_next();
			continue;
		child.set_button(2, 0, texture);
		child.set_meta(self.META_ITEM_SELECTED, toogle);
		child = child.get_next();
	pass

func select_action(item):
	if (item.get_meta(self.META_ITEM_TYPE) == self.ITEM_TYPE_CHILD):
		item = item.get_parent();
	self.root_control.git_manager.controller._call_action(self.root_control.git_manager.controller.ACTION_WORKSPACE_TREE_SELECTION_CHANGED, self.get_item_selected_children_count(item));
	pass

func get_item_selected_children_file_path(parent):
	var selected_children = [];
	if (parent == null):
		return selected_children;
	var child = parent.get_children();
	while(true):
		if (child == null):
			break;
		if (child.get_meta(self.META_ITEM_TYPE) == self.ITEM_TYPE_CHILD_EMPTY):
			child = child.get_next();
			continue;
		if (child.get_meta(self.META_ITEM_SELECTED)):
			selected_children.push_back(child.get_text(1));
		child = child.get_next();
	return selected_children;
	pass

func get_item_selected_children_count(parent):
	return self.get_item_selected_children_file_path(parent).size();
	pass

func update_tree():
	for workspace_file in self.root_control.git_manager.controller.workspace.get_all_files():
		self.create_item_child(self.root_item, workspace_file);
	pass

func update_workspace_tree(files_count):
	if (files_count < 1):
		self.create_root_item(true);
		self.create_child_item_empty(self.root_item, "no changes detected, working directory is clean");
	else:
		self.create_root_item(false);
		self.update_tree();
	self.select_action(self.root_item);
	pass

func _on_action_event(what, args):
	if (what == self.root_control.git_manager.controller.ACTION_WORKSPACE_FILES_UPDATED):
		self.update_workspace_tree(args);
	elif (what == self.root_control.git_manager.controller.ACTION_COMMIT_WORKSPACE_TREE_SELECTED_FILES):
		self.root_control.git_manager.controller._show_view_commit_message_dialog(self.get_item_selected_children_file_path(self.root_item));
	elif (what == self.root_control.git_manager.controller.ACTION_REVERT_WORKSPACE_TREE_SELECTED_FILES):
		self.root_control.git_manager.controller._show_view_revert_confirm_dialog(self.get_item_selected_children_file_path(self.root_item));
	pass

