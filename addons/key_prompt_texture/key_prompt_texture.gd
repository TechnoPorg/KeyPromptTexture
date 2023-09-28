@tool
@icon("key_prompt_texture.svg")
class_name KeyPromptTexture
extends Texture2D

# Static members
# All for internal use only

static var _controller_names : Array
static var _controller_name_mappings : Dictionary = {}
static var _current_controller_name : String = "Default"

static func _static_init():
	Input.joy_connection_changed.connect(preload("key_prompt_texture.gd")._joy_connection_changed)
	
	var controller_name_mappings = preload("controller_name_mappings.json").data
	_controller_names = controller_name_mappings.keys()
	for controller_name in _controller_names:
		for alias in controller_name_mappings[controller_name]:
			_controller_name_mappings[RegEx.create_from_string(alias)] = controller_name

static func _joy_connection_changed(device : int, connected : bool):
	if Input.get_connected_joypads().size() == 0:
		_current_controller_name = "Default"
		return
		
	var main_joy_name = Input.get_joy_name(0)
	for alias in _controller_name_mappings:
		if alias.search(main_joy_name):
			_current_controller_name = _controller_name_mappings[alias]
			return
	_current_controller_name = "Default"

# Instance members

var button : JoyButton:
	get:
		return button
	set(value):
		button = value
		_textures = {}
		for filename in DirAccess.get_files_at("res://addons/key_prompt_texture/textures/JOY_BUTTON_%d" % button):
			if filename.get_extension() == "png":
				_textures[filename.get_basename()] = load("res://addons/key_prompt_texture/textures/JOY_BUTTON_%d/%s" % [button, filename])
		emit_changed()

var _textures : Dictionary

func _init():
	button = JOY_BUTTON_A
	Input.joy_connection_changed.connect(emit_changed.unbind(2))
	
# Texture2D overrides

func _draw(to_canvas_item, pos, modulate, transpose):
	if _textures.has(_current_controller_name) and _textures[_current_controller_name] != null:
		_textures[_current_controller_name].draw(to_canvas_item, pos, modulate, transpose)
	
func _draw_rect(to_canvas_item, rect, tile, modulate, transpose):
	if _textures.has(_current_controller_name) and _textures[_current_controller_name] != null:
		_textures[_current_controller_name].draw_rect(to_canvas_item, rect, tile, modulate, transpose)
	
func _draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv):
	if _textures.has(_current_controller_name) and _textures[_current_controller_name] != null:
		_textures[_current_controller_name].draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)

func _get_height() -> int:
	if _textures.has(_current_controller_name) and _textures[_current_controller_name] != null:
		return _textures[_current_controller_name].get_height()
	return 0
	
func _get_width() -> int:
	if _textures.has(_current_controller_name) and _textures[_current_controller_name] != null:
		return _textures[_current_controller_name].get_width()
	return 0
	
func _has_alpha() -> bool:
	if _textures.has(_current_controller_name) and _textures[_current_controller_name] != null:
		return _textures[_current_controller_name].has_alpha()
	return false

func _is_pixel_opaque(x, y) -> bool:
	if _textures.has(_current_controller_name) and _textures[_current_controller_name] != null:
		return _textures[_current_controller_name]._is_pixel_opaque(x, y)
	return false
