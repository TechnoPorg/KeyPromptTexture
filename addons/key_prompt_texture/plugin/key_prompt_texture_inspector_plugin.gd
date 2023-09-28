extends EditorInspectorPlugin

var key_picker = preload("inspector_key_picker.gd")

func _can_handle(object):
	return object is KeyPromptTexture

func _parse_begin(object):
	add_custom_control(key_picker.new(object))
