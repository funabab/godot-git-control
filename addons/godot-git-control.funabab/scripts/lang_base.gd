extends Reference

const LANG = {
	"git_not_found": "Fatal error: Git not found"
}

static func get(key):
	return LANG[key] if LANG.has(key) else "";
	pass

