extends Reference

const LANG = {
}

static func trr(key):
	return LANG[key] if LANG.has(key) else "";
	pass

