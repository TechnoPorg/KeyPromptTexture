extends Control

var listening : bool = false
var texture : KeyPromptTexture
var button : Button

func _init(_texture : KeyPromptTexture):
	texture = _texture
	custom_minimum_size.y = 125
	var scene = preload("inspector_key_picker.tscn").instantiate()
	button = scene.get_node("key_picker_button")
	add_child(scene)
	button.pressed.connect(configure_button)

func _ready():
	refresh_button_text()

func _update_property():
	refresh_button_text()
	
func _input(event : InputEvent):
	if listening and event is InputEventJoypadButton:
		texture.button = event.button_index
		refresh_button_text()
		listening = false
	
func configure_button():
	if listening:
		return
		
	listening = true
	button.text = "Awaiting joypad input..."
	button.icon = null
	
func refresh_button_text():
	var pseudo_to_string = InputEventJoypadButton.new()
	pseudo_to_string.button_index = texture.button
	button.text = pseudo_to_string.as_text().replace("(", "\n(").replace(",", ",\n")
	button.icon = get_theme_icon(&"JoyButton", &"EditorIcons")
