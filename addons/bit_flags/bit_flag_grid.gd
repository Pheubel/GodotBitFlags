extends Control

signal flag_changed(new_value: int)

const INT64_MAX: int = 9223372036854775807
const INVALID_INDEX = -1

var value: int = 0

var layer_group_size: int
var layer_count: int

var expand_hovered: bool = false
var expanded: bool = false
var expansion_rows = 0
var hovered_index: int = INT64_MAX
var expand_rect: Rect2
var flag_rects: Array[Rect2] = []
var read_only: bool

var tooltips: PackedStringArray


func _get_minimum_size() -> Vector2:
	var min_size = get_grid_size()
	
	if expanded:
		var bsize = int((min_size.y * 80 / 100) / 2)
		for i in expansion_rows:
			min_size.y += 2 * (bsize + 1) + 3
	
	return min_size


func set_read_only(ro: bool) -> void:
	read_only = ro


func _get_tooltip(at_position: Vector2) -> String:
	for i in flag_rects.size():
		if i < tooltips.size() and flag_rects[i].has_point(at_position):
			return tooltips[i]
	
	return ""


func set_flag(flag_mask: int) -> void:
	value = flag_mask
	queue_redraw()


func get_grid_size() -> Vector2:
	var font = get_theme_font(&"font", &"Label")
	var font_size = get_theme_font_size(&"font_size", &"Label")
	return Vector2(0, font.get_height(font_size) * 3)


func _gui_input(event: InputEvent) -> void:
	if read_only:
		return
	
	var mouse_motion_event: InputEventMouseMotion = event as InputEventMouseMotion
	if mouse_motion_event:
		_update_hovered(mouse_motion_event.position)
		return 
	
	var mouse_button_event: InputEventMouseButton = event as InputEventMouseButton
	if mouse_button_event and mouse_button_event.pressed:
		if mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			_update_hovered(mouse_button_event.position)
			_update_flag(mouse_button_event.is_command_or_control_pressed())


func _update_hovered(position: Vector2) -> void:
	var expand_was_hoevered: bool = expand_hovered
	expand_hovered = expand_rect.has_point(position)
	if expand_hovered != expand_was_hoevered:
		queue_redraw()
	
	if not expand_hovered:
		for i in flag_rects.size():
			if flag_rects[i].has_point(position):
				hovered_index = i
				queue_redraw()
				return
	
	if hovered_index != INT64_MAX:
		hovered_index = INT64_MAX
		queue_redraw()


func _on_hover_exit() -> void:
	if expand_hovered:
		expand_hovered = false
		queue_redraw()
	if hovered_index != INT64_MAX:
		hovered_index = INT64_MAX
		queue_redraw()


func _update_flag(replace: bool) -> void:
	if hovered_index != INT64_MAX:
		# acts as solo mode where only one flag can be active
		if replace:
			if value == 1 << hovered_index:
				value = INT64_MAX - (1 << hovered_index)
			else:
				value = 1 << hovered_index
		else:
			if value & (1 << hovered_index):
				value &= ~(1 << hovered_index)
			else:
				value |= (1 << hovered_index)
		
		flag_changed.emit(value)
		queue_redraw()
	elif expand_hovered:
		expanded = !expanded
		update_minimum_size()
		queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAW:
		var grid_size: Vector2 = get_grid_size()
		grid_size.x = size.x
		
		flag_rects.clear()
		
		var prev_expansion_rows = expansion_rows
		expansion_rows = 0
		
		var b_size: int = int((grid_size.y * 80 / 100) / 2)
		var h = b_size * 2 + 1
		
		var color: Color = get_theme_color(&"highlight_disabled_color" if read_only else &"highlight_color", &"Editor")
		
		var text_color: Color = get_theme_color(&"font_disabled_color" if read_only else &"font_color", &"Editor")
		text_color.a *= 0.5
		
		var text_color_on: Color = get_theme_color(&"font_disabled_color" if read_only else &"font_hover_color", &"Editor")
		text_color_on.a *= 0.7
		
		var vofs: int = int((grid_size.y - h) / 2)
		
		var layer_index: int = 0
		var arrow_pos: Vector2
		var block_ofs: Vector2 = Vector2(4, vofs)
		
		while true:
			var ofs: Vector2 = block_ofs
			
			for i in 2:
				for j in layer_group_size:
					# not the cleanest, but whatever
					if layer_index >= layer_count:
						break
					
					var on = value & (1 << layer_index)
					var rect2: Rect2 = Rect2(ofs, Vector2(b_size, b_size))
					
					color.a = 0.6 if on else 0.2
					if layer_index == hovered_index:
						color.a += 0.15
					
					draw_rect(rect2, color)
					flag_rects.append(rect2)
					
					var font = get_theme_font(&"font", &"Label")
					var font_size = get_theme_font_size(&"font_size", &"Label")
					
					var offset: Vector2
					offset.y = rect2.size.y * 0.75
					
					draw_string(font, rect2.position + offset, str(layer_index + 1), HORIZONTAL_ALIGNMENT_CENTER, rect2.size.x, font_size, text_color_on if on else text_color)
					
					ofs.x += b_size + 1
					
					layer_index += 1
				
				ofs.x = block_ofs.x
				ofs.y += b_size + 1
			
			if layer_index >= layer_count:
				if not flag_rects.is_empty() and expansion_rows == 0:
					var last_rect = flag_rects[flag_rects.size() - 1]
					arrow_pos = last_rect.end
				break
			
			var block_size_x = layer_group_size * (b_size + 1)
			block_ofs.x += block_size_x + 3
			
			if block_ofs.x + block_size_x + 12 > grid_size.x:
				if not flag_rects.is_empty() and expansion_rows == 0:
					var last_rect = flag_rects[flag_rects.size() - 1]
					arrow_pos = last_rect.end
				expansion_rows += 1
				
				if expanded:
					block_ofs.x = 4
					block_ofs.y += 2 * (b_size + 1) + 3
				else:
					break
		
		if expansion_rows != prev_expansion_rows and expanded:
			update_minimum_size()
		
		if expansion_rows == 0 and layer_index == layer_count:
			return
		
		var arrow = get_theme_icon(&"arrow", &"Tree")
		
		var arrow_color = get_theme_color(&"highlight_color", &"Editor")
		arrow_color.a = 1.0 if expand_hovered else 0.6
		
		arrow_pos.x += 2.0
		arrow_pos.y -= arrow.get_height()
		
		var arrow_draw_rect: Rect2 = Rect2(arrow_pos, arrow.get_size())
		expand_rect = arrow_draw_rect
		if expanded:
			arrow_draw_rect.size.y += -1.0
		
		var canvas_rid = get_canvas_item()
		arrow.draw_rect(canvas_rid, arrow_draw_rect, false, arrow_color)
	
	if what == NOTIFICATION_MOUSE_EXIT:
		_on_hover_exit()
