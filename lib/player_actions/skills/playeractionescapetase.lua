PlayerAction.EscapeTase = {}
PlayerAction.EscapeTase.Priority = 1
function PlayerAction.EscapeTase.Function(t, dt, player_manager, target_time)
	local time = 0
	local controller = player_manager:player_unit():base():controller()
	local co = coroutine.running()
	while target_time > time do
		if controller:get_input_pressed("interact") then
			player_manager:send_message(Message.EscapeTase, nil, nil)
			break
		end
		time = time + dt
		coroutine.yield(co)
	end
end
