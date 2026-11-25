extends Node

func _ready() -> void :

	capture_android_screenshot()

func capture_android_screenshot() -> void :
	await RenderingServer.frame_post_draw
	var capture: Image = get_viewport().get_texture().get_image()


	var path: String = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	var full_path: String = path.path_join("screenshot.png")


	var error = capture.save_png(full_path)
	if error == OK:
		print("Imagem salva com sucesso em: ", full_path)
	else:
		print("Falha ao salvar a imagem. Erro: ", error)
