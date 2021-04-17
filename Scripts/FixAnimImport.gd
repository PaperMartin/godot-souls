tool
extends EditorScenePostImport

# Add string for the name of the animation track that should be left alone.
var excluded = []

func post_import(scene):
	var ap: AnimationPlayer = scene.get_node("AnimationPlayer")
	if ap != null:
		print("Found the AnimationPlayer!")
	var animations = ap.get_animation_list()
	
	for animname in animations:
		if excluded.find(animname) != -1:
			print("Skipping animation " + animname)
			continue
			
		var anim = ap.get_animation(animname)
		
		print ("Fixing animation " + animname)
		
		for ix in range(anim.get_track_count()):
			var cnt = anim.track_get_key_count(ix)
			if cnt > 1:
				var d = anim.track_get_key_time(ix, 1) - anim.track_get_key_time(ix, 0)
				anim.track_remove_key(ix, 0)
				cnt = anim.track_get_key_count(ix)
				for it in range(cnt):
					anim.track_set_key_time(ix, it, anim.track_get_key_time(ix, it) - d)
				anim.length = anim.length - d
		
	return scene
