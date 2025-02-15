extends EditorProperty
const BitFlagGrid := preload("res://addons/bit_flags/bit_flag_grid.gd")

var grid: BitFlagGrid

func _grid_changed(value: int) -> void:
	emit_changed(get_edited_property(), value)
	pass


func _init():
	var hb := HBoxContainer.new()
	hb.clip_contents = true
	add_child(hb)
	
	grid = BitFlagGrid.new()
	grid.flag_changed.connect(_grid_changed)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	hb.add_child(grid)
	
	set_bottom_editor(hb)

func set_layer_info(value: int, layer_count: int = 64, group_size: int = 4, layer_names: PackedStringArray = []) -> void:
	grid.layer_group_size = group_size
	grid.layer_count = layer_count
	grid.tooltips = layer_names

	grid.set_flag(value)
