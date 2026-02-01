extends VBoxContainer

var options = []
var selected_index = 0
var labels = []

func setup(opts):
  options = opts
  labels = []
  
  # Clear existing children
  for child in get_children():
    child.queue_free()
    
  for opt in options:
    var label = Label.new()
    label.text = opt
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(label)
    labels.append(label)
  
  selected_index = 0
  update_visuals()

func select_next():
  selected_index = (selected_index + 1) % options.size()
  update_visuals()

func select_prev():
  selected_index = (selected_index - 1 + options.size()) % options.size()
  update_visuals()

func get_selected_option():
  if options.size() > 0:
    return options[selected_index]
  return null

func update_visuals():
  for i in range(labels.size()):
    if i == selected_index:
      labels[i].modulate = Color.YELLOW
      labels[i].text = "> " + options[i] + " <"
    else:
      labels[i].modulate = Color.WHITE
      labels[i].text = options[i]
