# Key Prompt Texture

![Key Prompt Texture Demo](/demo/demo.png)

This addon allows showing a different texture depending on the currently connected controller through the `KeyPromptTexture` class.

## Key Prompt Configuration:

Editing `controller_name_mappings.json` allows one to change how devices are mapped to the textures displayed.
The textures themselves can be found and changed under `res://addons/key_prompt_texture/textures`.
Details can also be found in the class documentation for `KeyPromptTexture`.

## Localization:

Different button prompts can be shown in different locales by using Godot's [asset remapping tool](https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html#localizing-icons-and-images) on the base key prompt images.

As an example use case, if a key prompt texture needed to contain the written word "Menu", it would be necessary to display a different texture for every game locale. See the asset remaps in the demo project for an example of how this might be done.

![Key Prompt Texture Demo](/demo/demo.gif)

### Credits:

Ships by default with [Xelu's Free Controller Prompts](https://thoseawesomeguys.com/prompts/) (CC0).

### License:

This project is available under the MIT License.
