# Displays an interactive editor for the button of a KeyPromptTexture.
# If a controller is connected, it will allow the user to select the controller button
# for which the KeyPromptTexture will display an icon.

extends Control

# Whether joypad input is currently being listened for.
var listening : bool = false

# The texture being edited by this instance.
var texture : KeyPromptTexture

# The control shown in the inspector
var button : Button

# Called from key_prompt_texture_inspector_plugin.gd
func _init(_texture : KeyPromptTexture):
	texture = _texture
	custom_minimum_size.y = 125
	# It's nice to have the visual scene for designing the property editor.
	var scene = preload("inspector_key_picker.tscn").instantiate()
	button = scene.get_node("key_picker_button")
	add_child(scene)
	button.pressed.connect(configure_button)

# Theme icons are not available in _init, so the button text is only set up here.
func _ready():
	refresh_button_text()
	
func _input(event : InputEvent):
	# The event is only relevant if waiting for input.
	if listening:
		# A joypad button was pressed.
		if event is InputEventJoypadButton:
			texture.button = event.button_index
			refresh_button_text()
			listening = false
		else:
			# Cancel.
			if event is InputEventKey and event.keycode == KEY_ESCAPE:
				refresh_button_text()
				listening = false
	
func configure_button():
	if listening:
		return
		
	# Start waiting for joypad input.
	listening = true
	button.text = "Awaiting joypad input...\n(Esc to cancel)"
	button.icon = null
	
func refresh_button_text():
	# Although awkward, this is the best way to get a helpful string representation for the name of a joypad button.
	# It will be the same text that shows up in the project settings input map for any given button.
	var pseudo_to_string = InputEventJoypadButton.new()
	pseudo_to_string.button_index = texture.button
	# Add new lines to prevent text overflow.
	button.text = pseudo_to_string.as_text().replace("(", "\n(").replace(",", ",\n")
	
	# The icon cascades from the editor theme in parent nodes.
	button.icon = get_theme_icon(&"JoyButton", &"EditorIcons")
