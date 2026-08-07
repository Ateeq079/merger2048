extends SceneTree

func _init():
	print("Starting Unit Tests...")
	var tests_run = 0
	var tests_passed = 0
	
	var test_grid = preload("res://tests/test_grid_state.gd").new()
	var methods = test_grid.get_method_list()
	
	for method in methods:
		var name = method.name
		if name.begins_with("test_"):
			tests_run += 1
			print("Running: ", name)
			var result = test_grid.call(name)
			if result:
				tests_passed += 1
				print("  [PASS]")
			else:
				print("  [FAIL]")
				
	print("\n--- Test Results ---")
	print("Total: ", tests_run)
	print("Passed: ", tests_passed)
	print("Failed: ", tests_run - tests_passed)
	
	if tests_run == tests_passed:
		print("All tests passed!")
		quit(0)
	else:
		print("Some tests failed!")
		quit(1)
