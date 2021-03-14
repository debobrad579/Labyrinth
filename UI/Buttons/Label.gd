extends Label

export(int) var SHADOW_OFFSET_Y = 1 setget set_shadow_offset_y
export(int) var SHADOW_OFFSET_X = 1 setget set_shadow_offset_x

func set_shadow_offset_y(value):
	SHADOW_OFFSET_Y = value
	set("custom_constants/shadow_offset_y", value)

func set_shadow_offset_x(value):
	SHADOW_OFFSET_X = value
	set("custom_constants/shadow_offset_x", value)
