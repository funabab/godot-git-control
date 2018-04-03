extends Reference

const OBJECT_TYPE_ADDED = 1;
const OBJECT_TYPE_COPIED = 2;
const OBJECT_TYPE_DELETED = 3;
const OBJECT_TYPE_MODIFIED = 4;
const OBJECT_TYPE_RENAMED = 5;
const OBJECT_TYPE_CONFLICT = 6;
const OBJECT_TYPE_NEW = 7;
const OBJECT_TYPE_UNKNOWN = 8;

var type;
var path;
var selected = true;
func _init(type, path, selected = true):
	self.type = type;
	self.path = path;
	self.selected = selected;
	pass

