extends Label

@export var selector:MenuButton;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var itemIndex := selector.get_popup().get_focused_item();
	
	if(itemIndex >= 0):
		text = selector.get_popup().get_item_text(itemIndex);
	else:
		text = "NONE";
	pass
