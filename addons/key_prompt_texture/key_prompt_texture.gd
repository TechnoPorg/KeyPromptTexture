@tool
@icon("key_prompt_texture.svg")

## Adapts the texture displayed based on the currently connected controller.
## Useful for button prompts in UI elements.
##
## Will search for a valid icon to display based on the first connected controller, and fall back to a default
## if the type of the main connected controller is not supported by the plugin.
## If no controller is connected, an optional "None" texture can be shown (for example, a keyboard prompt for a desktop game).
## [br]The textures used by [KeyPromptTexture]s can be changed by replacing or adding files in the [code]res://addons/key_prompt_texture/textures/JOY_BUTTON_*[/code]
## folders.
## [br]To configure the mapping of [url=https://github.com/gabomdq/SDL_GameControllerDB/blob/master/gamecontrollerdb.txt]controller names[/url]
## to textures, edit [code]res://addons/key_prompt_texture/controller_name_mappings.json[/code].
## When editing or creating these high-level mappings,
## use the name of a general class of controllers as the JSON key,
## and an array of regular expressions which will be used to match device names (as provided by [method Input.get_joy_name]) as the value.
## [br]"None" in a device name entry will cause the associated key to be used when no controller is connected,
## whereas "Default" will configure what is used to handle all unknown controllers.
## [br]Changes to this file are necessary to change the types of controller for which icons will be handled by [KeyPromptTexture] in the current project.
## [br][br]Joypad axes such as LT are not currently supported.

class_name KeyPromptTexture
extends Texture2D

#region Static Members
# All for internal use only

# Because Godot has no static signals,
# this little helper class and a static variable are used in place.
class _StaticNotifier:
	signal changed
	
static var _static_notifier : _StaticNotifier = _StaticNotifier.new()

# The different types of controller handled in the current project.
# These correspond to the unique filenames which will be loaded from JOY_BUTTON_* folders.
static var _controller_names : Array

# The name of the controller whose icon pack will be displayed for unknown controllers.
# Designated by the "Default" entry in controller_name_mappings.json
static var _default_controller_name : String = ""

# A dictionary with a regular expression for device name matching as the key,
# and the name of the high-level controller type as the value.
static var _controller_name_mappings : Dictionary = {}

# Either "Default" for no or no supported controller,
# or the type of controller currently connected.
# Accessed by instances to determine which texture to display, since it is shared across the project.
static var _current_controller_name : String = "Default":
	get:
		return _current_controller_name
	set(value):
		_current_controller_name = value
		# Inform all instances to reload.
		_static_notifier.changed.emit()

# Setup for shared class data / actions
static func _static_init():
	Input.joy_connection_changed.connect(preload("key_prompt_texture.gd")._update_controller_name.unbind(2)) # A bug currently prevents directly referencing the static member.
	
	# Load the data from controller_name_mappings.json
	var controller_name_mappings = preload("controller_name_mappings.json").data
	# Loads the list of controller names for which icons are supported.
	_controller_names = controller_name_mappings.keys()
	
	for controller_name in _controller_names:
		for alias in controller_name_mappings[controller_name]:
			# Invert the storage scheme from the JSON:
			# Although it's more human-readable to have the device names as an array of values,
			# it's technically easier to handle if we have them as keys internally.
			
			if alias == "Default":
				_default_controller_name = controller_name
				continue
			else:
				_controller_name_mappings[RegEx.create_from_string(alias)] = controller_name
		
	# So that textures are properly set up on load
	if _default_controller_name == "":
		push_warning("KeyPromptTexture: No default controller name configured. No prompts will be displayed for unknown controllers.")
		
	_update_controller_name()

# Handles controller connection changes on behalf of all KeyPromptTextures.
# _current_controller_name is set by this function.
static func _update_controller_name():
	var main_joy_name : String
	# No controller connected
	if Input.get_connected_joypads().size() == 0:
		main_joy_name = "None"
	else:
		main_joy_name = Input.get_joy_name(0)
	for alias in _controller_name_mappings:
		# alias is a RegEx object here
		if alias.search(main_joy_name):
			_current_controller_name = _controller_name_mappings[alias]
			return
	
	# Nothing found for current controller type,
	# so fall back to the default type.
	_current_controller_name = _default_controller_name
#endregion

#region Instance Members

## The physical button for which this controller displays an icon.
## [br]It can be set interactively through the inspector, or directly.
@export var button : JoyButton:
	get:
		return button
	set(value):
		button = value
		_changed()

# Internal storage for the texture which represents the physical button on the current controller.
var _active_texture : Texture2D = PlaceholderTexture2D.new()

func _init():
	button = JOY_BUTTON_A
	_static_notifier.changed.connect(_changed)

# Called whenever the current controller or selected button changes.
func _changed():
	# Folder names come from the JoyButton enum.
	var path = "res://addons/key_prompt_texture/textures/JOY_BUTTON_%d/%s.png" % [button, _current_controller_name]
	if FileAccess.file_exists(path):
		_active_texture = load(path)
	else:
		# Assume that the dev doesn't want anything to be shown, since not even a catch-all is configured.
		_active_texture = PlaceholderTexture2D.new()
	emit_changed()
#endregion

#region Texture2D Overrides

# KeyPromptTexture doesn't actually provide any texture functionality of its own.
# It's just a wrapper which forwards calls to the currently active texture.

func _draw(to_canvas_item, pos, modulate, transpose):
	_active_texture.draw(to_canvas_item, pos, modulate, transpose)
	
func _draw_rect(to_canvas_item, rect, tile, modulate, transpose):
	_active_texture.draw_rect(to_canvas_item, rect, tile, modulate, transpose)
	
func _draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv):
	_active_texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)

func _get_height() -> int:
	return _active_texture.get_height()
	
func _get_width() -> int:
	return _active_texture.get_width()
	
func _has_alpha() -> bool:
	return _active_texture.has_alpha()

func _is_pixel_opaque(x, y) -> bool:
	return _active_texture._is_pixel_opaque(x, y)
#endregion
