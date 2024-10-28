@tool

extends Resource
class_name LootTable

@export var resource_table : Array[Resource]:
	set(val):
		resource_table = val
		resource_weights.resize(val.size())
		total_weight = resource_weights.reduce(func(total_weight, num): return total_weight + num)

@export var resource_weights : Array[int]:
	set(val):
		resource_weights = val
		resource_table.resize(val.size())
		total_weight = resource_weights.reduce(func(total_weight, num): return total_weight + num)

@export var sort_weights : bool = false:
	set(val): 
		SortByWeight()
		sort_weights = false

@export_group("Advanced Settings")
#@export var normalize_weights : bool = false: ## sorts the weights, removes negatives and divides by common factors
	#set(val):
		#NormalizeWeights()
		#normalize_weights = false


@export var total_weight : int = 0

var rng : RandomNumberGenerator

func _init():
	rng = RandomNumberGenerator.new()
	rng.randomize()

func RollItem(rarity) -> Resource:
	if rarity is float:
		if rng.randf_range(0.0,1.0) > rarity % 1: rarity = floor(rarity)
		else: rarity = ceil(rarity)
	
	var roll : int
	for k in rarity:
		roll = max(roll, randi_range(0, total_weight - 1))
	
	var current_total = 0
		
	for n in resource_weights.size():
		current_total += resource_weights[n]
		
		if current_total > roll:
			return resource_table[n]
	
	printerr("LootTable Roll Failure.")
	return null


func RollItems(rarity, quantity) -> Array[Resource]:
	if rarity is float:
		if rng.randf_range(0.0,1.0) > rarity % 1: rarity = floor(rarity)
		else: rarity = ceil(rarity)
	
	if quantity is float:
		if rng.randf_range(0.0,1.0) > quantity % 1: quantity = floor(quantity)
		else: quantity = ceil(quantity)
	
	var items : Array[Resource] = []
	
	for i in quantity:
		var roll : int
		for k in rarity:
			roll = max(roll, randi_range(0, total_weight - 1))
		
		var current_total = 0
		
		for n in resource_weights.size():
			current_total += resource_weights[n]
			
			if current_total > roll:
				items.append(resource_table[n])
				break
	
	print(items)
	return items



func SortByWeight(inverted : bool = false):
	var temp_array : Array[int] = []
	
	temp_array.resize(resource_weights.size())
	for i in temp_array.size():
		temp_array[i] = i
	
	temp_array.sort_custom(SortMap)
	
	var temp_weights = resource_weights.duplicate()
	var temp_resources = resource_table.duplicate()
	
	for i in temp_resources.size():
		resource_weights[i] = temp_weights[temp_array[i]]
		resource_table[i] = temp_resources[temp_array[i]]


func SortMap(a,b): return resource_weights[a] > resource_weights[b]

func NormalizeWeights():
	for i in resource_weights.size():
		if resource_weights[i] < 0:
			resource_weights[i] = 0
	
	resource_weights.sort()
	
	var min = resource_weights[0]
	var primes : Array[int] = [2,3,5,7,11,13,17,19]
	
	var valid_primes : Array[int] = []
	
	
	if min == 0: valid_primes = primes
	else:
		for p in primes:
			if min % p == 0:
				valid_primes.append(p)
	
	
	for i in resource_weights.size() - 1:
		var number = resource_weights[i + 1]
		if number == 0: continue
		
		for k in valid_primes.size():
			var p = valid_primes[valid_primes.size() - k - 1]
			
			if number % p != 0:
				valid_primes[valid_primes.size() - k - 1] = 0
		
		var iter = 0
		for k in valid_primes.size():
			var p = valid_primes[k - 1]
			
			if p == 0: continue
			
			valid_primes[iter] = p
			iter += 1
		valid_primes.resize(iter)
	
	var denom = 1
	for prime in valid_primes:
		denom *= prime
	
	for i in resource_weights.size():
		resource_weights[i-1] /= denom
