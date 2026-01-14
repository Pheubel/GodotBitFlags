## Bit flags:
This is a simple editor to change how you interact with integers as a bit mask. By default it uses a list of checkboxes that can clutter the inspector quickly. However the Godot engine already has a propery editor capable of more compactly representing a bit set and it's value. The plugin is mostly based on the original source code found in https://github.com/godotengine/godot/blob/master/editor/editor_properties.cpp

## How to use
To use the plugin, install it in your addons folder and make sure to enable the plugin. Once enabled, you can then use it as follows:
```gdscript
# Godot 4.3+
@export_custom(PROPERTY_HINT_FLAGS, "16") var spawn_group: int
```
Or by defining a property list
```gdscript
@tool
extends Node

var spawn_group: int

func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	
	props.append({
		"name": "spawn_group",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_FLAGS,
		"hint_string": "16"
	})
	
	return props

func _get(property: StringName) -> Variant:
	if property == &"spawn_group":
		return spawn_group
	return null

func _set(property: StringName, value: Variant) -> bool:
	if property == &"spawn_group" and value is int:
		spawn_group = value
	return false
```
This will result in the property looking like:

![image](https://github.com/user-attachments/assets/6d30e6df-5bca-4552-8f11-e3233561d093)

The hint string is a comma sepparated list, where the first element indicates how many flags should be displayed. Additional elements will be used as names for each individual bit in the set. If no hint string is given or the first element is not a valid interger, it will use the old property inspector instead. 
