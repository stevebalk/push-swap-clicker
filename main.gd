extends Control

var stack_size := 100

var stack_a: Array[int]
var stack_b: Array[int]

var undo_stack: Array[String]
var redo_stack: Array[String]

@onready var backgroundA := $backgroundA
@onready var backgroundB := $backgroundB
var backgroundA_rect : Rect2
var backgroundB_rect : Rect2
var linesize: Vector2

func _ready() -> void:
	linesize = backgroundA.size
	backgroundA_rect = backgroundA.get_rect()
	backgroundB_rect = backgroundB.get_rect()
	linesize.y = backgroundA.get_rect().size.y / stack_size
	stack_a.assign(range(1, stack_size + 1))
#	stack_a.shuffle()

func _draw() -> void:
	_draw_stack(stack_a, backgroundA_rect, linesize)
	_draw_stack(stack_b, backgroundB_rect, linesize)









func _draw_stack(stack: Array[int], rect: Rect2, size: Vector2):
	rect.size.y = size.y
	for value in stack:
		var rel_value = float(value) / float(stack_size)
		rect.size.x = rel_value * size.x
		draw_rect(rect, Color.from_hsv(rel_value, 1.0, 1.0))
		rect.position.y += size.y
	queue_redraw()

func _randomize_stack() -> void:
	stack_b.clear()
	stack_a.clear()
	stack_a.assign(range(1, stack_size + 1))
	stack_a.shuffle()
	queue_redraw()

func _add_undo(function_name: String) -> void:
	undo_stack.append(function_name)

func _remove_undo() -> void:
	undo_stack.pop_back()

func _clear_undo_stack() -> void:
	undo_stack.clear()

func _add_redo(function_name: String) -> void:
	redo_stack.append(function_name)

func _clear_redo_stack() -> void:
	redo_stack.clear()













# Push swap functions

func _push(src: Array[int],  dst: Array[int]) -> void:
	dst.insert(0, src.pop_front())
	queue_redraw()

func _pa() -> void:
	_push(stack_a, stack_b)

func _pb() -> void:
	_push(stack_b, stack_a)

func _rotate(stack: Array[int]) -> void:
	stack.append(stack.pop_front())
	queue_redraw()

func _ra() -> void:
	_rotate(stack_a)

func _rb() -> void:
	_rotate(stack_b)

func _rr() -> void:
	_rotate(stack_a)
	_rotate(stack_b)

func _swap(stack: Array[int]) -> void:
	var temp := 0
	if stack.size() > 1:
		temp = stack[1]
		stack[1] = stack[0]
		stack[0] = temp
		queue_redraw()

func _sa() -> void:
	_swap(stack_a)

func _sb() -> void:
	_swap(stack_b)

func _ss():
	_swap(stack_a)
	_swap(stack_b)

func _reverse_rotate(stack: Array[int]) -> void:
	stack.insert(0, stack.pop_back())
	queue_redraw()

func _rra() -> void:
	_reverse_rotate(stack_a)

func _rrb() -> void:
	_reverse_rotate(stack_b)

func _rrr() -> void:
	_reverse_rotate(stack_a)
	_reverse_rotate(stack_b)

# Button functions

# Misc buttons

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_undo_pressed() -> void:
	pass

func _on_redo_pressed() -> void:
	pass # Replace with function body.

func _on_randomize_button_pressed() -> void:
	_randomize_stack()

# Push swap buttons
func _on_pa_pressed() -> void:
	_pa()


func _on_pb_pressed() -> void:
	_pb()


func _on_ra_pressed() -> void:
	_ra()


func _on_rb_pressed() -> void:
	_rb()


func _on_rr_pressed() -> void:
	_rr()


func _on_sa_pressed() -> void:
	_sa()


func _on_sb_pressed() -> void:
	_sb()


func _on_ss_pressed() -> void:
	_ss()


func _on_rra_pressed() -> void:
	_rra()


func _on_rrb_pressed() -> void:
	_rrb()


func _on_rrr_pressed() -> void:
	_rrr()



