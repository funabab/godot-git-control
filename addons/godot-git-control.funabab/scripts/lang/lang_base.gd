extends Reference

const LANG = {
}

static func tr(key):
	return LANG[key] if LANG.has(key) else "";
	pass

