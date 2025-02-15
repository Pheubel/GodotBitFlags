extends EditorInspectorPlugin

var BitFlagEditor = preload("res://addons/BitFlags/BitFlagEditor.gd")


func _can_handle(object: Object) -> bool:
	return true


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if type == TYPE_INT and hint_type == PROPERTY_HINT_FLAGS:
		
		if hint_string.is_empty():
			return false
		
		var parts: PackedStringArray = hint_string.split(",")
		if parts.size() < 1 or not parts[0].is_valid_int():
			return false
		
		var set_size: int = parts[0].to_int()
		assert(set_size > 0 and set_size <= 64, "size parameter out of range, expected number between 1 and 64 inclusive.")
		
		parts.remove_at(0)
		
		#if parts.size() > set_size:
			#push_warning("There are more flag names than visible bits")
		
		var editor = BitFlagEditor.new()
		editor.set_layer_info(set_size, 4,parts)
		add_property_editor(name, editor)
		
		return true
	
	return false
