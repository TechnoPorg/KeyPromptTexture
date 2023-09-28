# Displays an interactive editor for the button of a KeyPromptTexture.
# If a controller is connected, it will allow the user to select the controller button
# for which the KeyPromptTexture will display an icon.

extends EditorProperty

# Whether joypad input is currently being listened for.
var listening : bool = false

# The control shown in the inspector when a joypad is connected
var button : Button

# The control shown when no joypad is connected.
var dropdown : OptionButton

# Although awkward, this is the best way to get a helpful string representation for the name of a joypad button.
	# It will be the same text that shows up in the project settings input map for any given button.
func joy_button_to_text(button : int):
	var pseudo_to_string = InputEventJoypadButton.new()
	pseudo_to_string.button_index = button
	# Add new lines to prevent text overflow.
	return pseudo_to_string.as_text().replace("(", "\n(").replace(",", ",\n")

func _init():
	button = Button.new()
	button.add_theme_constant_override(&"h_separation", 10)
	add_child(button)
	add_focusable(button)
	button.pressed.connect(configure_button)
	
	dropdown = OptionButton.new()
	for i in range(JOY_BUTTON_SDL_MAX):
		dropdown.add_item(joy_button_to_text(i))
	dropdown.item_selected.connect(func(button):
		get_edited_object().button = button
		emit_changed(get_edited_property(), button)
		)
	add_child(dropdown)

func _update_property():
	refresh_button()

# Theme icons are not available in _init, so the button text is only set up here.
func _ready():
	refresh_button()
	Input.joy_connection_changed.connect(_set_current_editor.unbind(2))
	_set_current_editor()
	
func _set_current_editor():
	if Input.get_connected_joypads().size() == 0:
		button.visible = false
		dropdown.visible = true
		dropdown.selected = get_edited_object().button
		custom_minimum_size = dropdown.get_minimum_size()
	else:
		button.visible = true
		dropdown.visible = false
		custom_minimum_size = button.get_minimum_size()
	
func _input(event : InputEvent):
	# The event is only relevant if waiting for input.
	if listening:
		# A joypad button was pressed.
		if event is InputEventJoypadButton:
			get_edited_object().button = event.button_index
			refresh_button()
			emit_changed(get_edited_property(), event.button_index)
			listening = false
		else:
			# Cancel.
			if event is InputEventKey and event.keycode == KEY_ESCAPE:
				refresh_button()
				listening = false
	
func configure_button():
	if listening:
		return
		
	# Start waiting for joypad input.
	listening = true
	button.text = "Awaiting joypad input...\n(Esc to cancel)"
	button.icon = null
	
func refresh_button():
	button.text = joy_button_to_text(get_edited_object().button)
	
	# The icon cascades from the editor theme in parent nodes.
	button.icon = get_theme_icon(&"JoyButton", &"EditorIcons")
