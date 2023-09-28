# The custom inspector plugin for a key prompt texture.
# The heavy lifting is split into inspector_key_picker.

extends EditorInspectorPlugin

var key_picker : GDScript = preload("inspector_key_picker.gd")

func _can_handle(object):
	return object is KeyPromptTexture

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "button":
		add_property_editor(name, key_picker.new())
		return true
	return false
