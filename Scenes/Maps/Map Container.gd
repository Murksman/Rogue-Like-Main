extends NavigationRegion2D

var free_nodes : Array[Object]

func _ready():
	bake_navigation_polygon(true)

func _physics_process(delta):
	query_free_nodes()

func query_free_nodes():
	var list_size = free_nodes.size()
	for n in list_size:
		var wr = weakref(free_nodes[list_size - n - 1])
		if (!wr.get_ref()):
			bake_navigation_polygon(true)
			free_nodes.remove_at(list_size - n - 1)

func add_free_node(obj):
	free_nodes.append(obj)
