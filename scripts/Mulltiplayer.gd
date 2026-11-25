extends Node

var connectPort: int = 0

const PORT: = 7777

func create_server():
	var peer: = ENetMultiplayerPeer.new()

	var error: = peer.create_server(PORT)

	if error != OK:
		print("Erro ao criar servidor: ", error)
		return
	multiplayer.multiplayer_peer = peer
	print("Servidor criado na porta ", PORT)

	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

func _on_player_connected(id):
	print("Jogador conectado: ", id)

func _on_player_disconnected(id):
	print("Jogador desconectado: ", id)

func connect_to_server(ip: String):
	var peer: = ENetMultiplayerPeer.new()

	var error: = peer.create_client(ip, PORT)

	if error != OK:
		print("Erro ao conectar: ", error)
		return

	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connected():
	print("Conectado ao servidor!")

func _on_connection_failed():
	print("Falha ao conectar.")

func _on_server_disconnected():
	print("Desconectado do servidor.")
