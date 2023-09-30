extends Control

const BUTTON_PRESSED_TEXT = "%s pressed!"

func _ready():
	%Back.grab_focus()
	%Back.pressed.connect(%Info.set_text.bind(BUTTON_PRESSED_TEXT % "Back"))
	%Previous.pressed.connect(%Info.set_text.bind(BUTTON_PRESSED_TEXT % "Previous"))
	%Select.pressed.connect(%Info.set_text.bind(BUTTON_PRESSED_TEXT % "Select"))

func _input(event : InputEvent):
	if event is InputEventJoypadButton and event.pressed:
		match(event.button_index):
			JOY_BUTTON_BACK:
				%Back.grab_focus()
				%Back.emit_signal(&"pressed")
			JOY_BUTTON_LEFT_SHOULDER:
				%Previous.grab_focus()
				%Previous.emit_signal(&"pressed")
			JOY_BUTTON_A:
				%Select.grab_focus()
				%Select.emit_signal(&"pressed")
				
func change_locale(idx : int):
	match(idx):
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("de")
		2:
			TranslationServer.set_locale("zh")
