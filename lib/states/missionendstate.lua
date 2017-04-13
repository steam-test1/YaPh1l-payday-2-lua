require("lib/states/GameState")
if not MissionEndState then
	MissionEndState = class(GameState)
end
MissionEndState.GUI_ENDSCREEN = Idstring("guis/victoryscreen/stage_endscreen")
MissionEndState.init = function(self, name, game_state_machine, setup)
	GameState.init(self, name, game_state_machine)
	self._type = ""
	self._completion_bonus_done = false
	self._continue_cb = callback(self, self, "_continue")
	self._controller = nil
	self._continue_block_timer = 0
	managers.custom_safehouse:register_trophy_unlocked_callback(callback(self, self, "_on_safehouse_trophy_unlocked"))
end

MissionEndState.setup_controller = function(self)
	if not self._controller then
		self._controller = managers.controller:create_controller("victoryscreen", managers.controller:get_default_wrapper_index(), false)
		self._controller:set_enabled(true)
	end
end

MissionEndState.set_controller_enabled = function(self, enabled)
end

MissionEndState.at_enter = function(self, old_state, params)
	managers.environment_effects:stop_all()
	local is_safe_house = not managers.job:current_job_data() or managers.job:current_job_id() == "safehouse"
	managers.platform:set_presence("Mission_end")
	managers.platform:set_rich_presence(is_safe_house or (Global.game_settings.single_player and "SPEnd") or "MPEnd")
	managers.platform:set_playing(false)
	managers.hud:remove_updator("point_of_no_return")
	managers.hud:hide_stats_screen()
	local job_tweak = tweak_data.levels[managers.job:current_job_id()]
	if job_tweak then
		local is_safehouse_combat = job_tweak.is_safehouse_combat
	end
	self._continue_block_timer = Application:time() + 1.5
	if Network:is_server() and not is_safehouse_combat then
		managers.network.matchmake:set_server_joinable(false)
		if self._success then
			for peer_id,data in pairs(managers.player:get_all_synced_carry()) do
				if not tweak_data.carry[data.carry_id].skip_exit_secure then
					managers.loot:secure(data.carry_id, data.multiplier)
				end
				if data.carry_id == "sandwich" then
					managers.mission:call_global_event("equipment_sandwich")
				end
			end
			for _,team_ai in pairs(managers.groupai:state():all_AI_criminals()) do
				if team_ai and team_ai.unit and team_ai.unit:movement() then
					local carry_data = team_ai.unit:movement():carry_data()
				end
				if carry_data then
					if not tweak_data.carry[carry_data:carry_id()].skip_exit_secure then
						managers.loot:secure(carry_data:carry_id(), carry_data:multiplier())
					end
				if carry_data:carry_id() == "sandwich" then
					end
					managers.mission:call_global_event("equipment_sandwich")
				end
			end
		end
		managers.criminals:save_current_character_names()
	end
	if not self._server_left and not self._kicked then
		if self._success then
			managers.crime_spree:on_mission_completed(managers.crime_spree:current_mission())
		end
	else
		managers.crime_spree:on_mission_failed(managers.crime_spree:current_mission())
	end
	local player = managers.player:player_unit()
	if player then
		player:camera():remove_sound_listener()
		player:camera():play_redirect(Idstring("idle"))
		player:character_damage():disable_berserker()
	end
	managers.job:stop_sounds()
	managers.dialog:quit_dialog()
	Application:debug("1 second to managers.mission:pre_destroy()")
	self._mission_destroy_t = Application:time() + 1
	if not self._success then
		managers.job:set_stage_success(false)
	end
	if self._success then
		print("MissionEndState:at_enter", managers.job:on_last_stage())
		managers.job:set_stage_success(true)
		if managers.job:on_last_stage() then
			managers.mission:call_global_event(Message.OnHeistComplete, managers.job:current_job_id(), Global.game_settings.difficulty)
		end
	if self._type == "victory" then
		end
		managers.money:on_mission_completed(params.num_winners)
	end
	if SystemInfo:platform() == Idstring("WIN32") and managers.network.account:has_alienware() then
		LightFX:set_lamps(0, 255, 0, 255)
	end
	self._completion_bonus_done = self._completion_bonus_done or false
	self:setup_controller()
	if not self._setup then
		self._setup = true
		managers.hud:load_hud(self.GUI_ENDSCREEN, false, true, false, {}, nil, nil, true)
		managers.menu:open_menu("mission_end_menu", 1)
		self._mission_end_menu = managers.menu:get_menu("mission_end_menu")
	end
	self._old_state = old_state
	managers.menu_component:set_max_lines_game_chat(7)
	managers.hud:set_success_endscreen_hud(self._success, self._server_left)
	managers.hud:show_endscreen_hud()
	self:chk_complete_heist_achievements()
	managers.groupai:state():set_AI_enabled(false)
	local player = managers.player:player_unit()
	if player then
		player:sound():stop()
		player:character_damage():set_invulnerable(true)
		player:character_damage():stop_heartbeat()
		player:base():set_stats_screen_visible(false)
		if player:movement():current_state():shooting() then
			player:movement():current_state()._equipped_unit:base():stop_shooting()
		end
		if player:movement():tased() then
			player:sound():play("tasered_stop")
		end
	if player:movement():current_state()._interupt_action_interact then
		end
		player:movement():current_state():_interupt_action_interact()
	end
	self._sound_listener = SoundDevice:create_listener("lobby_menu")
	self._sound_listener:set_position(Vector3(0, -50000, 0))
	self._sound_listener:activate(true)
	local total_killed = managers.statistics:session_total_killed()
	self._criminals_completed = self._success and params.num_winners or 0
	managers.statistics:stop_session({success = self._success, type = self._type})
	managers.statistics:send_statistics()
	managers.hud:set_statistics_endscreen_hud(self._criminals_completed, self._success)
	if managers.statistics:started_session_from_beginning() then
		managers.achievment:check_complete_heist_stats_achivements()
	end
	if Global.level_data.level_id then
		local level_data = tweak_data.levels[Global.level_data.level_id]
	end
	if not self._success and level_data and level_data.failure_music then
		managers.menu:post_event(level_data.failure_music)
	else
		if not self._success or not managers.music:jukebox_menu_track("heistresult") then
			managers.music:post_event(managers.music:jukebox_menu_track("heistlost"))
		end
	end
	managers.enemy:add_delayed_clbk("play_finishing_sound", callback(self, self, "play_finishing_sound", self._success), Application:time() + 2)
	local ghost_bonus = 0
	if self._type == "victory" or self._type == "gameover" then
		if not params or params then
			local total_xp_bonus, bonuses = self:_get_xp_dissected(self._success, params.num_winners, params.personal_win)
		end
		self._bonuses = bonuses
		self:completion_bonus_done(total_xp_bonus)
		managers.job:clear_saved_ghost_bonus()
		managers.experience:mission_xp_process(self._success, managers.job:on_last_stage())
		ghost_bonus = managers.job:accumulate_ghost_bonus(ghost_bonus)
	end
	local is_xb1 = SystemInfo:platform() == Idstring("XB1")
	if self._success then
		local gage_assignment_state = managers.gage_assignment:on_mission_completed()
		local hud_ghost_bonus = 0
		if managers.job:on_last_stage() then
			managers.job:check_add_heat_to_jobs()
			managers.job:activate_accumulated_ghost_bonus()
			hud_ghost_bonus = managers.job:get_saved_ghost_bonus()
			if is_xb1 and not is_safe_house then
				XboxLive:write_hero_stat("heists", 1)
			end
		else
			hud_ghost_bonus = ghost_bonus
		end
		managers.hud:set_special_packages_endscreen_hud({ghost_bonus = hud_ghost_bonus, gage_assignment = gage_assignment_state, challenge_completed = managers.challenge:any_challenge_completed(), tango_mission_completed = managers.tango:any_challenge_completed()})
	end
	if is_xb1 then
		XboxLive:write_hero_stat("kills", total_killed.count)
		XboxLive:write_hero_stat("time", managers.statistics:get_session_time_seconds())
	end
	if Network:is_server() then
		managers.network:session():set_state("game_end")
	end
end

MissionEndState.is_success = function(self)
	return self._success
end

MissionEndState._get_xp_dissected = function(self, success, num_winners, personal_win)
	return managers.experience:get_xp_dissected(success, num_winners, personal_win)
end

MissionEndState._get_contract_xp = function(self, success)
	local has_active_job = managers.job:has_active_job()
	local job_and_difficulty_stars = has_active_job and managers.job:current_job_and_difficulty_stars() or 1
	local job_stars = has_active_job and managers.job:current_job_stars() or 1
	local difficulty_stars = has_active_job and managers.job:current_difficulty_stars() or 0
	local player_stars = managers.experience:level_to_stars()
	local total_stars = math.min(job_and_difficulty_stars, player_stars + 1)
	if total_stars < job_and_difficulty_stars then
		self._bonuses[5] = true
	end
	local total_difficulty_stars = math.max(0, total_stars - job_stars)
	local xp_multiplier = managers.experience:get_contract_difficulty_multiplier(total_difficulty_stars)
	self._bonuses[1] = difficulty_stars > 0 and difficulty_stars or false
	total_stars = math.min(job_stars, total_stars)
	self._bonuses[3] = has_active_job and managers.job:on_last_stage() or false
	local contract_xp = 0
	if success and has_active_job and managers.job:on_last_stage() then
		contract_xp = contract_xp + managers.experience:get_job_xp_by_stars(total_stars)
	else
		contract_xp = contract_xp + managers.experience:get_stage_xp_by_stars(total_stars)
	end
	contract_xp = contract_xp + (contract_xp) * xp_multiplier
	contract_xp = (contract_xp) * (not success and tweak_data:get_value("experience_manager", "stage_failed_multiplier") or 1)
	if not success then
		self._bonuses[4] = true
	end
	return contract_xp
end

MissionEndState.set_continue_button_text = function(self)
	if self._completion_bonus_done then
		self:_set_continue_button_text()
	end
end

MissionEndState._set_continue_button_text = function(self)
	local text_id = "failed_disconnected_continue"
	local not_clickable = false
	if self._continue_block_timer and Application:time() < self._continue_block_timer then
		text_id = "menu_es_calculating_experience"
		not_clickable = true
	else
		if managers.job:stage_success() and managers.job:on_last_stage() then
			text_id = "menu_victory_goto_payday"
		end
	end
	local continue_button = managers.menu:is_pc_controller() and "[ENTER]" or nil
	local text = utf8.to_upper(managers.localization:text(text_id, {CONTINUE = continue_button}))
	managers.menu_component:set_endscreen_continue_button_text(text, not_clickable)
end

MissionEndState.play_finishing_sound = function(self, success)
	if self._server_left then
		return 
	end
	if not success and managers.groupai:state():bain_state() then
		if Global.level_data.level_id then
			local level_data = tweak_data.levels[Global.level_data.level_id]
		end
		managers.dialog:queue_dialog(level_data and level_data.failure_event or "Play_ban_g01x", {})
	end
end

MissionEndState.completion_bonus_done = function(self, total_xp_bonus)
	self._total_xp_bonus = total_xp_bonus
	self._completion_bonus_done = false
end

MissionEndState.at_exit = function(self, next_state)
	managers.briefing:stop_event(true)
	managers.hud:hide(self.GUI_ENDSCREEN)
	managers.menu_component:hide_game_chat_gui()
	self:_clear_controller()
	if not self._debug_continue and not Application:editor() then
		managers.savefile:save_progress()
		if Network:multiplayer() then
			self:_shut_down_network()
		end
		local player = managers.player:player_unit()
		if player then
			player:camera():remove_sound_listener()
		end
		if self._sound_listener then
			self._sound_listener:delete()
			self._sound_listener = nil
		end
		if next_state:name() ~= "disconnected" then
			self:_load_start_menu(next_state)
		end
	else
		self._debug_continue = nil
		managers.groupai:state():set_AI_enabled(true)
		local player = managers.player:player_unit()
	if player then
		end
		player:character_damage():set_invulnerable(false)
	end
	managers.menu:close_menu("mission_end_menu")
end

MissionEndState._shut_down_network = function(self)
	Network:set_multiplayer(false)
	managers.network:queue_stop_network()
	managers.network.matchmake:destroy_game()
	managers.network.voice_chat:destroy_voice()
end

MissionEndState._load_start_menu = function(self, next_state)
	if next_state:name() == "disconnected" then
		return 
	end
	if managers.dlc:is_trial() then
		Global.open_trial_buy = true
	end
	managers.job:deactivate_current_job()
	setup:load_start_menu()
end

MissionEndState.on_statistics_result = function(self, best_kills_peer_id, best_kills_score, best_special_kills_peer_id, best_special_kills_score, best_accuracy_peer_id, best_accuracy_score, most_downs_peer_id, most_downs_score, total_kills, total_specials_kills, total_head_shots, group_accuracy, group_downs)
	print("on_statistics_result begin")
	if managers.network and managers.network:session() then
		local best_kills_peer = managers.network:session():peer(best_kills_peer_id)
		local best_special_kills_peer = managers.network:session():peer(best_special_kills_peer_id)
		local best_accuracy_peer = managers.network:session():peer(best_accuracy_peer_id)
		local most_downs_peer = managers.network:session():peer(most_downs_peer_id)
		local best_kills = best_kills_peer and best_kills_peer:name() or "N/A"
		local best_special_kills = best_special_kills_peer and best_special_kills_peer:name() or "N/A"
		local best_accuracy = best_accuracy_peer and best_accuracy_peer:name() or "N/A"
		local most_downs = most_downs_peer and most_downs_peer:name() or "N/A"
		local stage_cash_summary_string = nil
		if self._success and managers.job._global.next_interupt_stage then
			local victory_cash_postponed_id = "victory_cash_postponed"
			if tweak_data.levels[managers.job._global.next_interupt_stage].bonus_escape then
				victory_cash_postponed_id = "victory_cash_postponed_bonus"
			end
			stage_cash_summary_string = managers.localization:text(victory_cash_postponed_id)
		elseif self._success then
			local payouts = managers.money:get_payouts()
			local stage_payout = payouts.stage_payout
			local job_payout = payouts.job_payout
			local bag_payout = payouts.bag_payout
			local vehicle_payout = payouts.vehicle_payout
			local small_loot_payout = payouts.small_loot_payout
			local crew_payout = payouts.crew_payout
			local bonus_bags = managers.loot:get_secured_bonus_bags_amount() + managers.loot:get_secured_mandatory_bags_amount()
			local bag_cash = bag_payout
			local vehicle_amount = managers.loot:get_secured_bonus_bags_amount(true) + managers.loot:get_secured_mandatory_bags_amount(true)
			local vehicle_cash = vehicle_payout
			local loose_cash = small_loot_payout or 0
			local cleaner_cost = 0
			local assets_cost = 0
			local current_total_money = managers.money:total()
			if job_payout > 0 then
				local job_string = managers.localization:text("victory_stage_cash_summary_name_job", {stage_cash = managers.experience:cash_string(stage_payout), job_cash = managers.experience:cash_string(job_payout)})
				stage_cash_summary_string = job_string
			else
				local stage_string = managers.localization:text("victory_stage_cash_summary_name", {stage_cash = managers.experience:cash_string(stage_payout)})
				stage_cash_summary_string = stage_string
			end
			if bonus_bags > 0 and bag_cash > 0 then
				stage_cash_summary_string = stage_cash_summary_string .. " " .. managers.localization:text("victory_stage_cash_summary_name_bags", {bag_cash = managers.experience:cash_string(bag_cash), bag_amount = bonus_bags, bonus_bags = bonus_bags})
			end
			if vehicle_amount and vehicle_payout > 0 then
				stage_cash_summary_string = stage_cash_summary_string .. " " .. managers.localization:text("victory_stage_cash_summary_name_vehicles", {vehicle_cash = managers.experience:cash_string(vehicle_cash), vehicle_amount = vehicle_amount})
			end
			if self._criminals_completed and crew_payout > 0 then
				stage_cash_summary_string = stage_cash_summary_string .. " " .. managers.localization:text("victory_stage_cash_summary_name_crew", {winners = tostring(self._criminals_completed), crew_cash = managers.experience:cash_string(crew_payout)})
			end
			if loose_cash > 0 then
				stage_cash_summary_string = stage_cash_summary_string .. " " .. managers.localization:text("victory_stage_cash_summary_name_loose", {loose_cash = managers.experience:cash_string(loose_cash)})
			end
			stage_cash_summary_string = stage_cash_summary_string .. "\n"
			if cleaner_cost > 0 then
				stage_cash_summary_string = stage_cash_summary_string .. managers.localization:text("victory_stage_cash_summary_name_civ_kill", {civ_killed_cash = managers.experience:cash_string(cleaner_cost)}) .. " "
			end
			if assets_cost > 0 then
				stage_cash_summary_string = stage_cash_summary_string .. managers.localization:text("victory_stage_cash_summary_name_assets", {asset_cash = managers.experience:cash_string(assets_cost)}) .. " "
			end
			if cleaner_cost > 0 or assets_cost > 0 then
				stage_cash_summary_string = stage_cash_summary_string .. "\n"
			end
			stage_cash_summary_string = stage_cash_summary_string .. "\n"
			local offshore_string = managers.localization:text("victory_stage_cash_summary_name_offshore", {offshore = managers.localization:text("hud_offshore_account"), cash = managers.experience:cash_string(managers.money:heist_offshore())})
			local spending_string = managers.localization:text("victory_stage_cash_summary_name_spending", {cash = "##" .. managers.experience:cash_string(managers.money:heist_spending()) .. "##"})
			stage_cash_summary_string = stage_cash_summary_string .. offshore_string .. "\n"
			stage_cash_summary_string = stage_cash_summary_string .. spending_string .. "\n"
		else
			stage_cash_summary_string = managers.localization:text("failed_summary_name")
		end
		self._statistics_data = {best_killer = managers.localization:text("victory_best_killer_name", {PLAYER_NAME = best_kills, SCORE = best_kills_score}), best_special = managers.localization:text("victory_best_special_name", {PLAYER_NAME = best_special_kills, SCORE = best_special_kills_score}), best_accuracy = managers.localization:text("victory_best_accuracy_name", {PLAYER_NAME = best_accuracy, SCORE = best_accuracy_score}), most_downs = managers.localization:text("victory_most_downs_name", {PLAYER_NAME = most_downs, SCORE = most_downs_score}), total_kills = total_kills, total_specials_kills = total_specials_kills, total_head_shots = total_head_shots, group_hit_accuracy = group_accuracy .. "%", group_total_downed = group_downs, stage_cash_summary = stage_cash_summary_string}
	end
	print("on_statistics_result end")
	local level_id, all_pass, total_kill_pass, total_accuracy_pass, total_headshots_pass, total_downed_pass, level_pass, levels_pass, num_players_pass, diff_pass, is_dropin_pass, success_pass = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
	if not tweak_data.achievement.complete_heist_statistics_achievements then
		for achievement,achievement_data in pairs({}) do
		end
		level_id = managers.job:has_active_job() and managers.job:current_level_id() or ""
		if achievement_data.difficulty then
			diff_pass = table.contains(achievement_data.difficulty, Global.game_settings.difficulty)
			diff_pass = diff_pass
		end
		num_players_pass = not achievement_data.num_players or achievement_data.num_players <= managers.network:session():amount_of_players()
		level_pass = not achievement_data.level_id or achievement_data.level_id == level_id
		if achievement_data.levels then
			levels_pass = table.contains(achievement_data.levels, level_id)
			levels_pass = levels_pass
		end
		total_kill_pass = not achievement_data.total_kills or achievement_data.total_kills <= total_kills
		total_accuracy_pass = not achievement_data.total_accuracy or achievement_data.total_accuracy <= group_accuracy
		total_downed_pass = not achievement_data.total_downs or group_downs <= achievement_data.total_downs
		is_dropin_pass = achievement_data.is_dropin == nil or achievement_data.is_dropin == managers.statistics:is_dropin()
		if achievement_data.success then
			success_pass = self._success
			success_pass = success_pass
		end
		if achievement_data.total_headshots.amount or total_head_shots > not achievement_data.total_headshots or 0 then
			total_headshots_pass = not achievement_data.total_headshots.invert
			do return end
		end
		total_headshots_pass = achievement_data.total_headshots.amount or 0 <= total_head_shots
		do return end
		total_headshots_pass = true
		all_pass = not diff_pass or not num_players_pass or not level_pass or not levels_pass or not total_kill_pass or not total_accuracy_pass or not total_downed_pass or not is_dropin_pass or not total_headshots_pass or not managers.challenge:check_equipped(achievement_data) or not managers.challenge:check_equipped_team(achievement_data) or success_pass
		if all_pass then
			if achievement_data.stat then
				managers.achievment:award_progress(achievement_data.stat)
			end
		elseif achievement_data.award then
			managers.achievment:award(achievement_data.award)
		elseif achievement_data.challenge_stat then
			managers.challenge:award_progress(achievement_data.challenge_stat)
		elseif achievement_data.trophy_stat then
			managers.custom_safehouse:award(achievement_data.trophy_stat)
		elseif achievement_data.challenge_award then
			managers.challenge:award(achievement_data.challenge_award)
		else
			Application:debug("[MissionEndState] complete_heist_achievements:", achievement)
		end
	end
end

MissionEndState.generate_safehouse_statistics = function(self)
	if not managers.custom_safehouse:unlocked() then
		return 
	end
	local was_safehouse_raid = managers.job:current_job_id() == "chill_combat"
	if not self._trophies_list then
		self._trophies_list = {}
	end
	for idx,trophy_data in ipairs(managers.custom_safehouse:completed_trophies()) do
		if not table.contains(self._trophies_list, trophy_data) then
			table.insert(self._trophies_list, trophy_data)
		end
	end
	if managers.custom_safehouse:has_completed_daily() then
		local has_completed_daily = not managers.custom_safehouse:has_rewarded_daily()
	end
	if has_completed_daily then
		managers.custom_safehouse:reward_daily()
	end
	local stage_safehouse_summary_string = ""
	local total_income = managers.custom_safehouse:get_coins_income()
	local exp_income = total_income
	local trophies_income = 0
	local daily_income = 0
	local raid_income = was_safehouse_raid and game_state_machine:current_state():name() == "victoryscreen" and tweak_data.safehouse.rewards.raid or 0
	for idx,trophy_data in ipairs(self._trophies_list) do
		if trophy_data.type == "trophy" then
			trophies_income = trophies_income + trophy_data.reward
		end
		exp_income = exp_income - trophy_data.reward
	end
	if has_completed_daily then
		daily_income = tweak_data.safehouse.rewards.daily_complete
		exp_income = exp_income - daily_income
	end
	if was_safehouse_raid then
		exp_income = exp_income - raid_income
	end
	if managers.crime_spree:_is_active() and total_income > 0 then
		stage_safehouse_summary_string = managers.localization:text("menu_es_safehouse_earned", {amount = tostring(total_income)})
	end
	stage_safehouse_summary_string = stage_safehouse_summary_string .. "\n"
	if exp_income > 0 then
		exp_income = managers.experience:cash_string(math.floor(exp_income), "")
		stage_safehouse_summary_string = stage_safehouse_summary_string .. managers.localization:text("menu_es_safehouse_earned_income", {amount = exp_income}) .. "\n"
	end
	if #self._trophies_list > 0 or has_completed_daily or was_safehouse_raid then
		local challenge_income = managers.experience:cash_string(math.floor(trophies_income + daily_income), "")
		stage_safehouse_summary_string = stage_safehouse_summary_string .. managers.localization:text("menu_es_safehouse_earned_challenges", {amount = challenge_income}) .. "\n"
		for idx,trophy_data in ipairs(self._trophies_list) do
			if trophy_data.type == "trophy" then
				local trophy = managers.localization:text(trophy_data.name)
				stage_safehouse_summary_string = stage_safehouse_summary_string .. managers.localization:text("menu_es_safehouse_challenge_complete", {challenge = trophy}) .. "\n"
			end
		end
		if has_completed_daily then
			stage_safehouse_summary_string = stage_safehouse_summary_string .. managers.localization:text("menu_es_safehouse_daily_challenge_complete") .. "\n"
		end
	if was_safehouse_raid then
		end
		raid_income = managers.experience:cash_string(math.floor(raid_income), "")
		stage_safehouse_summary_string = stage_safehouse_summary_string .. managers.localization:text("menu_es_earned_safehouse_raid", {amount = raid_income}) .. "\n"
	end
	local coins_total = managers.experience:cash_string(math.floor(managers.custom_safehouse:coins()), "")
	stage_safehouse_summary_string = stage_safehouse_summary_string .. "\n" .. managers.localization:text("menu_es_safehouse_total_coins", {amount = coins_total})
	if managers.custom_safehouse:can_afford_any_upgrade() then
		stage_safehouse_summary_string = stage_safehouse_summary_string .. " " .. managers.localization:text("menu_es_safehouse_upgrade_available")
	end
	self._statistics_data.stage_safehouse_summary = stage_safehouse_summary_string
	managers.custom_safehouse:flush_completed_trophies()
end

MissionEndState._on_safehouse_trophy_unlocked = function(self, trophy_id)
	if self._statistics_feeded then
		self:generate_safehouse_statistics()
		managers.menu_component:feed_endscreen_statistics(self._statistics_data)
	end
end

MissionEndState._continue_blocked = function(self)
	local in_focus = managers.menu:active_menu() == self._mission_end_menu
	if not in_focus then
		return true
	end
	if managers.hud:showing_stats_screen() then
		return true
	end
	if managers.system_menu:is_active() then
		return true
	end
	if not self._completion_bonus_done then
		return true
	end
	if managers.menu_component:input_focus() == 1 then
		return true
	end
	if self._continue_block_timer and Application:time() < self._continue_block_timer then
		return true
	end
	return false
end

MissionEndState._continue = function(self)
	self:continue()
end

MissionEndState.continue = function(self)
	if self:_continue_blocked() then
		return 
	end
	if managers.job:stage_success() and managers.job:on_last_stage() then
		Application:debug(managers.job:stage_success(), managers.job:on_last_stage(), managers.job:is_job_finished())
		self:_clear_controller()
		managers.menu_component:close_stage_endscreen_gui()
		self:gsm():change_state_by_name("ingame_lobby_menu")
	elseif self._old_state then
		self:_clear_controller()
		self:gsm():change_state_by_name("empty")
	else
		Application:error("Trying to continue from victory screen, but I have no state to goto")
	end
end

MissionEndState._clear_controller = function(self)
	if not self._controller then
		return 
	end
	self._controller:set_enabled(false)
	self._controller:destroy()
	self._controller = nil
end

MissionEndState.debug_continue = function(self)
	if not self._success then
		return 
	end
	if not self._completion_bonus_done then
		return 
	end
	if self._old_state then
		self._debug_continue = true
		self:_clear_controller()
		self:gsm():change_state_by_name(self._old_state:name())
	end
end

MissionEndState.set_completion_bonus_done = function(self, done)
	self._completion_bonus_done = done
	self:_set_continue_button_text()
end

MissionEndState.update = function(self, t, dt)
	managers.hud:update_endscreen_hud(t, dt)
	if self._mission_destroy_t and self._mission_destroy_t <= Application:time() then
		Application:debug("managers.mission:pre_destroy()")
		managers.mission:pre_destroy()
		self._mission_destroy_t = nil
	end
	if managers.crime_spree:_is_active() then
		self._total_xp_bonus = false
	end
	if self._total_xp_bonus then
		if self._total_xp_bonus >= 0 then
			local level = managers.experience:current_level()
			local data = managers.experience:give_experience(self._total_xp_bonus)
			data.bonuses = self._bonuses
			managers.hud:send_xp_data_endscreen_hud(data, callback(self, self, "set_completion_bonus_done"))
			if SystemInfo:distribution() == Idstring("STEAM") and level ~= managers.experience:current_level() then
				managers.statistics:publish_level_to_steam()
			end
		else
			self:set_completion_bonus_done(true)
			self._total_xp_bonus = nil
		end
		if self._continue_block_timer and self._continue_block_timer <= t then
			self._continue_block_timer = nil
			self:_set_continue_button_text()
		end
		do
			local in_focus = managers.menu:active_menu() == self._mission_end_menu
			if in_focus and not self._in_focus then
				self:_set_continue_button_text()
				self._statistics_feeded = nil
			end
			if not self._statistics_feeded and self._statistics_data then
				self:generate_safehouse_statistics()
				self._statistics_data.success = self._success
				self._statistics_data.criminals_finished = self._criminals_completed
				managers.menu_component:feed_endscreen_statistics(self._statistics_data)
				self._statistics_feeded = true
			end
			self._in_focus = in_focus
		end
		 -- WARNING: missing end command somewhere! Added here
	end
end

MissionEndState.game_ended = function(self)
	return true
end

MissionEndState.on_server_left = function(self)
	IngameCleanState.on_server_left(self)
end

MissionEndState.on_kicked = function(self)
	IngameCleanState.on_kicked(self)
end

MissionEndState.on_disconnected = function(self)
	IngameCleanState.on_disconnected(self)
end

MissionEndState.chk_complete_heist_achievements = function(self)
	local player = managers.player:player_unit()
	do
		local total_killed = managers.statistics:session_total_killed()
		if self._success then
			for id,data in pairs(managers.achievment:heist_success_awards()) do
				if data.award then
					managers.achievment:award(id)
				elseif data.stat then
					managers.achievment:award_progress(id, data.progress)
				end
			end
			if not managers.statistics:is_dropin() then
				local jordan_4 = managers.job:get_memory("jordan_4")
				if not managers.game_play_central or not managers.game_play_central:get_heist_timer() then
					local t = not jordan_4 and jordan_4 ~= nil or 0
				end
				local last_jump_t = managers.job:get_memory("last_jump_t", true) or 0
				if last_jump_t and last_jump_t + tweak_data.achievement.complete_heist_achievements.jordan_4.jump_timer < t then
					print("[achievement] Failed Achievement " .. "brooklyn_4")
					managers.job:set_memory("jordan_4", false)
				end
				local ach_data = tweak_data.achievement.close_and_personal
				local session_killed = managers.statistics:session_killed()
				local has_type_stats = (ach_data.kill_type and not not total_killed[ach_data.kill_type])
				if has_type_stats then
					local total_kill_count = total_killed.count
					local total_kill_type_count = total_killed[ach_data.kill_type]
				if total_kill_count == total_kill_type_count then
					end
					local civilians = {"civilian", "civilian_female", "bank_manager"}
					local count = nil
					for i,name in ipairs(civilians) do
						count = session_killed[name]
						if count then
							total_kill_count = total_kill_count - count.count
							total_kill_type_count = total_kill_type_count - (count[ach_data.kill_type] or 0)
						end
					end
				if total_kill_count == total_kill_type_count then
					end
					local count_pass = not ach_data.count or ach_data.count <= total_kill_count
				if count_pass then
					end
					managers.achievment:award(ach_data.award)
				end
				local shotgun_one_o_one = tweak_data.achievement.shotgun_one_o_one
				if shotgun_one_o_one.count <= total_killed.count then
					local session_used_weapons = managers.statistics:session_used_weapons()
					local passed = true
					for _,weapon_id in ipairs(session_used_weapons) do
						if not tweak_data.weapon[weapon_id] or tweak_data.weapon[weapon_id].category ~= "shotgun" then
							passed = false
					else
						end
					end
				if passed then
					end
				if shotgun_one_o_one.accuracy <= managers.statistics:session_hit_accuracy() then
					end
					managers.achievment:award(shotgun_one_o_one.award)
				end
				local killed_by_weapons = managers.statistics:session_killed_by_weapons()
				local killed_by_melee = managers.statistics:session_killed_by_melee()
				local killed_by_grenade = managers.statistics:session_killed_by_grenade()
				local civilians_killed = managers.statistics:session_total_civilian_kills()
				local man_5 = tweak_data.achievement.man_5
				if managers.statistics:started_session_from_beginning() and managers.job:on_last_stage() and managers.job:current_real_job_id() == man_5.job and table.contains(man_5.difficulty, Global.game_settings.difficulty) and killed_by_melee == 0 and killed_by_grenade == 0 then
					local passed = true
					for i,weapon_id in ipairs(managers.statistics:session_used_weapons()) do
						if man_5.weapon_category ~= tweak_data:get_raw_value("weapon", weapon_id, "category") then
							passed = false
					else
						end
					end
				if passed then
					end
					managers.achievment:award(man_5.award)
				end
				local mask_pass, diff_pass, no_shots_pass, contract_pass, job_pass, jobs_pass, level_pass, levels_pass, stealth_pass, loud_pass, equipped_pass, job_value_pass, phalanx_vip_alive_pass, used_weapon_category_pass, equipped_team_pass, timer_pass, num_players_pass, pass_skills, killed_by_weapons_pass, killed_by_melee_pass, killed_by_grenade_pass, civilians_killed_pass, complete_job_pass, memory_pass, is_host_pass, character_pass, converted_cops_pass, total_accuracy_pass, weapons_used_pass, everyone_killed_by_weapons_pass, everyone_killed_by_melee_pass, everyone_killed_by_grenade_pass, everyone_weapons_used_pass, enemy_killed_pass, everyone_used_weapon_category_pass, everyone_killed_by_weapon_category_pass, everyone_killed_by_projectile_pass, killed_pass, shots_by_weapon_pass, killed_by_blueprint_pass, mutators_pass, all_pass, weapon_data, memory, level_id, stage, num_skills = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
				local phalanx_vip_alive = false
				if not managers.enemy:all_enemies() then
					for _,enemy in pairs({}) do
					end
					phalanx_vip_alive = not alive(enemy.unit) or enemy.unit:base()._tweak_table == "phalanx_vip"
					if phalanx_vip_alive then
						do return end
					end
				end
				for achievement,achievement_data in pairs(tweak_data.achievement.complete_heist_achievements) do
					level_id = managers.job:has_active_job() and managers.job:current_level_id() or ""
					if achievement_data.difficulty then
						diff_pass = table.contains(achievement_data.difficulty, Global.game_settings.difficulty)
						diff_pass = diff_pass
					end
					mask_pass = not achievement_data.mask or managers.blackmarket:equipped_mask().mask_id == achievement_data.mask
					job_pass = not achievement_data.job or not managers.statistics:started_session_from_beginning() or (not managers.job:on_last_stage() and not achievement_data.need_full_job) or managers.job:current_real_job_id() == achievement_data.job
					if achievement_data.jobs and managers.statistics:started_session_from_beginning() and (managers.job:on_last_stage() or achievement_data.need_full_job) then
						jobs_pass = table.contains(achievement_data.jobs, managers.job:current_real_job_id())
					end
					jobs_pass = jobs_pass
					level_pass = not achievement_data.level_id or achievement_data.level_id == level_id
					if achievement_data.levels then
						levels_pass = table.contains(achievement_data.levels, level_id)
						levels_pass = levels_pass
					end
					contract_pass = not achievement_data.contract or managers.job:current_contact_id() == achievement_data.contract
					if achievement_data.complete_job and managers.statistics:started_session_from_beginning() then
						complete_job_pass = managers.job:on_last_stage()
					end
					complete_job_pass = complete_job_pass
					no_shots_pass = not achievement_data.no_shots or managers.statistics:session_total_shots(achievement_data.no_shots) == 0
					if achievement_data.stealth and managers.groupai then
						stealth_pass = managers.groupai:state():whisper_mode()
					end
					stealth_pass = stealth_pass
					if achievement_data.loud and managers.groupai then
						loud_pass = not managers.groupai:state():whisper_mode()
					end
					loud_pass = loud_pass
					timer_pass = not achievement_data.timer or not managers.game_play_central or managers.game_play_central:get_heist_timer() <= achievement_data.timer
					num_players_pass = not achievement_data.num_players or achievement_data.num_players <= managers.network:session():amount_of_players()
					job_value_pass = not achievement_data.job_value or managers.mission:get_job_value(achievement_data.job_value.key) == achievement_data.job_value.value
					memory_pass = not achievement_data.memory or managers.job:get_memory(achievement, achievement_data.memory.is_shortterm) == achievement_data.memory.value
					if achievement_data.phalanx_vip_alive then
						phalanx_vip_alive_pass = phalanx_vip_alive
						phalanx_vip_alive_pass = phalanx_vip_alive_pass
					end
					if achievement_data.is_host and not Network:is_server() then
						is_host_pass = Global.game_settings.single_player
					end
					is_host_pass = is_host_pass
					converted_cops_pass = not achievement_data.converted_cops or achievement_data.converted_cops <= managers.groupai:state():get_amount_enemies_converted_to_criminals()
					total_accuracy_pass = not achievement_data.total_accuracy or achievement_data.total_accuracy <= managers.statistics:session_hit_accuracy()
					enemy_killed_pass = not achievement_data.killed
					if achievement_data.killed then
						enemy_killed_pass = true
						for enemy,count in pairs(achievement_data.killed) do
							local num_killed = managers.statistics:session_enemy_killed_by_type(enemy, "count")
							if num_killed ~= 0 then
								enemy_killed_pass = count ~= 0
								do return end
							end
							enemy_killed_pass = count <= num_killed
						if not enemy_killed_pass then
							end
					else
						end
					end
					killed_pass = not achievement_data.anyone_killed
					do
						if achievement_data.anyone_killed then
							local num_killed = managers.statistics:session_total_kills_by_anyone()
							if num_killed ~= 0 then
								killed_pass = achievement_data.anyone_killed ~= 0
							end
							do return end
						end
						killed_pass = achievement_data.anyone_killed <= num_killed
					end
					mutators_pass = not achievement_data.mutators
					if achievement_data.mutators then
						if achievement_data.mutators == true then
							mutators_pass = managers.mutators:are_mutators_active()
						end
					else
						if #achievement_data.mutators == table.size(managers.mutators:active_mutators()) then
							local required_mutators = deep_clone(achievement_data.mutators)
							for _,active_mutator in pairs(managers.mutators:active_mutators()) do
								if table.contains(required_mutators, active_mutator.mutator:id()) then
									table.delete(required_mutators, active_mutator.mutator:id())
								end
							end
							mutators_pass = #required_mutators == 0
						end
					end
					used_weapon_category_pass = true
					if achievement_data.used_weapon_category then
						local used_weapons = managers.statistics:session_used_weapons()
					if used_weapons then
						end
						local category = achievement_data.used_weapon_category
						do
							local weapon_tweak = nil
							for _,weapon_id in ipairs(used_weapons) do
								weapon_tweak = tweak_data.weapon[weapon_id]
								if not weapon_tweak or weapon_tweak.category ~= category and (category ~= "pistol" or weapon_tweak.sub_category ~= "pistol") then
									used_weapon_category_pass = false
								end
						else
							end
						end
					end
					everyone_used_weapon_category_pass = true
					if achievement_data.everyone_used_weapon_category and managers.statistics:session_anyone_used_weapon_category_except(achievement_data.everyone_used_weapon_category) then
						everyone_used_weapon_category_pass = false
					end
					everyone_killed_by_weapon_category_pass = true
					if achievement_data.everyone_killed_by_weapon_category and managers.statistics:session_anyone_killed_by_weapon_category_except(achievement_data.everyone_killed_by_weapon_category) > 0 then
						everyone_killed_by_weapon_category_pass = false
					end
					killed_by_weapons_pass = not achievement_data.killed_by_weapons
					if achievement_data.killed_by_weapons == 0 then
						if killed_by_weapons ~= 0 then
							killed_by_weapons_pass = not achievement_data.killed_by_weapons
					else
						end
					end
					killed_by_weapons_pass = achievement_data.killed_by_weapons <= killed_by_weapons
					everyone_killed_by_weapons_pass = not achievement_data.everyone_killed_by_weapons
					do
						if achievement_data.everyone_killed_by_weapons then
							local everyone_killed_by_weapons = managers.statistics:session_anyone_killed_by_weapons()
							if everyone_killed_by_weapons ~= 0 then
								everyone_killed_by_weapons_pass = achievement_data.everyone_killed_by_weapons ~= 0
							end
							do return end
						end
						everyone_killed_by_weapons_pass = achievement_data.everyone_killed_by_weapons <= everyone_killed_by_weapons
					end
					killed_by_melee_pass = not achievement_data.killed_by_melee
					if achievement_data.killed_by_melee == 0 then
						if killed_by_melee ~= 0 then
							killed_by_melee_pass = not achievement_data.killed_by_melee
					else
						end
					end
					killed_by_melee_pass = achievement_data.killed_by_melee <= killed_by_melee
					everyone_killed_by_melee_pass = not achievement_data.everyone_killed_by_melee
					do
						if achievement_data.everyone_killed_by_melee then
							local everyone_killed_by_melee = managers.statistics:session_anyone_killed_by_melee()
							if everyone_killed_by_melee ~= 0 then
								everyone_killed_by_melee_pass = achievement_data.everyone_killed_by_melee ~= 0
							end
							do return end
						end
						everyone_killed_by_melee_pass = achievement_data.everyone_killed_by_melee <= everyone_killed_by_melee
					end
					killed_by_grenade_pass = not achievement_data.killed_by_grenade
					if achievement_data.killed_by_grenade == 0 then
						if killed_by_grenade ~= 0 then
							killed_by_grenade_pass = not achievement_data.killed_by_grenade
					else
						end
					end
					killed_by_grenade_pass = achievement_data.killed_by_grenade <= killed_by_grenade
					everyone_killed_by_grenade_pass = not achievement_data.everyone_killed_by_grenade
					do
						if achievement_data.everyone_killed_by_grenade then
							local everyone_killed_by_grenade = managers.statistics:session_anyone_killed_by_grenade()
							if everyone_killed_by_grenade ~= 0 then
								everyone_killed_by_grenade_pass = achievement_data.everyone_killed_by_grenade ~= 0
							end
							do return end
						end
						everyone_killed_by_grenade_pass = achievement_data.everyone_killed_by_grenade <= everyone_killed_by_grenade
					end
					everyone_killed_by_projectile_pass = not achievement_data.everyone_killed_by_projectile
					do
						if achievement_data.everyone_killed_by_projectile and #achievement_data.everyone_killed_by_projectile > 1 then
							local everyone_killed_by_projectile = managers.statistics:session_anyone_killed_by_projectile(achievement_data.everyone_killed_by_projectile[1])
							if everyone_killed_by_projectile ~= 0 then
								everyone_killed_by_projectile_pass = achievement_data.everyone_killed_by_projectile[2] ~= 0
							end
							do return end
						end
						everyone_killed_by_projectile_pass = achievement_data.everyone_killed_by_projectile[2] <= everyone_killed_by_projectile
					end
					civilians_killed_pass = not achievement_data.civilians_killed
					if achievement_data.civilians_killed == 0 then
						if civilians_killed ~= 0 then
							civilians_killed_pass = not achievement_data.civilians_killed
					else
						end
					end
					civilians_killed_pass = achievement_data.civilians_killed <= civilians_killed
					weapons_used_pass = not achievement_data.weapons_used
					weapons_used_pass = not achievement_data.weapons_used or managers.statistics:session_killed_by_weapons_except(achievement_data.weapons_used) == 0
					everyone_weapons_used_pass = not achievement_data.everyone_weapons_used
					everyone_weapons_used_pass = not achievement_data.everyone_weapons_used or managers.statistics:session_anyone_killed_by_weapons_except(achievement_data.everyone_weapons_used) == 0
					shots_by_weapon_pass = not achievement_data.shots_by_weapon
					if achievement_data.shots_by_weapon then
						shots_by_weapon_pass = not managers.statistics:session_anyone_used_weapon_except(achievement_data.shots_by_weapon)
					end
					pass_skills = not achievement_data.num_skills
					if not pass_skills then
						num_skills = 0
						for tree,data in ipairs(tweak_data.skilltree.trees) do
							local points = managers.skilltree:get_tree_progress(tree)
							num_skills = num_skills + points
						end
						pass_skills = num_skills <= achievement_data.num_skills
					end
					character_pass = not achievement_data.characters
					if achievement_data.characters then
						character_pass = true
						for _,character_name in ipairs(achievement_data.characters) do
							local found = false
							for _,peer in pairs(managers.network:session():all_peers()) do
								if not peer:is_dropin() and peer:character() == character_name then
									found = true
							else
								end
							end
							if not found then
								character_pass = false
							end
					else
						end
					end
					if achievement_data.equipped then
						equipped_pass = false
						equipped_pass = equipped_pass
					end
					if achievement_data.equipped then
						for category,data in pairs(achievement_data.equipped) do
							weapon_data = managers.blackmarket:equipped_item(category)
							if (category == "grenades" or category == "armors") and data == weapon_data then
								equipped_pass = true
							elseif (data.weapon_id and data.weapon_id == weapon_data.weapon_id) or data.category and data.category == tweak_data:get_raw_value("weapon", weapon_data.weapon_id, "category") then
								equipped_pass = true
								if data.blueprint and weapon_data.blueprint then
									for _,part_or_parts in ipairs(data.blueprint) do
										if type(part_or_parts) == "string" and not table.contains(weapon_data.blueprint, part_or_parts) then
											equipped_pass = false
										end
									else
										for _,part_or_parts in (for generator) do
										end
										local found_one = false
										for _,part_id in ipairs(part_or_parts) do
											if table.contains(weapon_data.blueprint, part_id) then
												found_one = true
										else
											end
										end
										if not found_one then
											equipped_pass = false
									else
										end
									end
								if data.blueprint_part_data then
									end
								if weapon_data.blueprint then
									end
									for key,req_value in pairs(data.blueprint_part_data) do
										local found_one = false
										for i,part_id in ipairs(weapon_data.blueprint) do
											local part_data = tweak_data.weapon.factory.parts[part_id]
											 -- DECOMPILER ERROR: unhandled construct in 'if'

											if part_data and type(req_value) == "table" and table.contains(req_value, part_data[key]) then
												found_one = true
											else
												for i,part_id in (for generator) do
												end
												if part_data[key] == req_value then
													found_one = true
											else
												end
											end
											if not found_one then
												equipped_pass = false
											end
									else
										end
									end
								end
							end
							if achievement_data.equipped_outfit then
								equipped_pass = managers.challenge:check_equipped(achievement_data)
							end
							if achievement_data.killed_by_blueprint then
								killed_by_blueprint_pass = false
								killed_by_blueprint_pass = killed_by_blueprint_pass
							end
							if achievement_data.killed_by_blueprint then
								local blueprint = achievement_data.killed_by_blueprint.blueprint
								local amount = achievement_data.killed_by_blueprint.amount
								do
									local weapons_to_check = {managers.blackmarket:equipped_primary(), managers.blackmarket:equipped_secondary()}
									for _,weapon_data in ipairs(weapons_to_check) do
										if weapon_data then
											local weapon_id = weapon_data.weapon_id
											local weapon_amount = managers.statistics:session_killed_by_weapon(weapon_id)
										if (amount == 0 and weapon_amount == 0) or amount > 0 and amount <= weapon_amount then
											end
											local missing_parts = false
											if not weapon_data.blueprint then
												local weapon_blueprint = {}
											end
											if type(blueprint) == "string" and not table.contains(weapon_blueprint, blueprint) then
												missing_parts = true
											end
											do return end
											for _,part in ipairs(blueprint) do
												if type(part) == "string" and not table.contains(weapon_blueprint, part) then
													missing_parts = true
												else
													for _,part in (for generator) do
													end
													local found_parts = false
													for _,or_part in ipairs(part) do
														if table.contains(weapon_blueprint, or_part) then
															found_parts = true
														end
													end
													if not found_parts then
														missing_parts = true
													end
												end
											if not missing_parts then
												end
												killed_by_blueprint_pass = true
											end
									else
										end
									end
								end
								if managers.challenge:check_equipped(achievement_data) then
									equipped_team_pass = managers.challenge:check_equipped_team(achievement_data)
								end
								all_pass = not job_pass or not jobs_pass or not level_pass or not levels_pass or not contract_pass or not diff_pass or not mask_pass or not no_shots_pass or not stealth_pass or not loud_pass or not equipped_pass or not equipped_team_pass or not num_players_pass or not pass_skills or not timer_pass or not killed_by_weapons_pass or not killed_by_melee_pass or not killed_by_grenade_pass or not complete_job_pass or not job_value_pass or not memory_pass or not phalanx_vip_alive_pass or not used_weapon_category_pass or not is_host_pass or not character_pass or not converted_cops_pass or not total_accuracy_pass or not weapons_used_pass or not everyone_killed_by_weapons_pass or not everyone_killed_by_melee_pass or not everyone_killed_by_grenade_pass or not everyone_weapons_used_pass or not everyone_used_weapon_category_pass or not enemy_killed_pass or not everyone_killed_by_weapon_category_pass or not everyone_killed_by_projectile_pass or not killed_pass or not shots_by_weapon_pass or not killed_by_blueprint_pass or mutators_pass
								if all_pass and achievement_data.need_full_job and managers.job:has_active_job() then
									memory = managers.job:get_memory(achievement)
									if not managers.job:interupt_stage() then
										if not memory then
											memory = {}
											for i = 1, #managers.job:current_job_chain_data() do
												memory[i] = false
											end
										end
										stage = managers.job:current_stage()
										memory[stage] = not not (all_pass)
										managers.job:set_memory(achievement, memory)
										if managers.job:on_last_stage() then
											for stage,passed in pairs(memory) do
												if not passed then
													all_pass = false
												end
										else
											end
										end
									else
										all_pass = false
									end
								else
									if managers.job:on_last_stage() then
										if not memory then
											for stage,passed in pairs({}) do
											end
											if not passed then
												all_pass = false
											end
									else
										end
									end
								else
									all_pass = false
								end
								if achievement_data.need_full_stealth then
									local stealth_memory = managers.job:get_memory("stealth")
									if managers.groupai then
										local in_stealth = managers.groupai:state():whisper_mode()
									end
									if stealth_memory == nil then
										if in_stealth == nil then
											stealth_memory = true
										end
									else
										stealth_memory = in_stealth
									end
									if not in_stealth and stealth_memory then
										stealth_memory = false
										managers.job:set_memory("stealth", stealth_memory)
									end
								if managers.job:on_last_stage() and not stealth_memory then
									end
									all_pass = false
								end
								if all_pass then
									managers.achievment:_award_achievement(achievement_data, achievement)
								end
							end
						if managers.blackmarket:check_frog_1(managers.blackmarket) then
							end
						if managers.job:on_last_stage() then
							end
							managers.achievment:award("frog_1")
						end
						local masks_pass, level_pass, job_pass, jobs_pass, difficulty_pass, difficulties_pass, all_pass, memory, level_id, stage = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
						for achievement,achievement_data in pairs(tweak_data.achievement.four_mask_achievements) do
							level_id = managers.job:has_active_job() and managers.job:current_level_id() or ""
							masks_pass = not not achievement_data.masks
							level_pass = not achievement_data.level_id or achievement_data.level_id == level_id
							job_pass = not achievement_data.job or not managers.statistics:started_session_from_beginning() or not managers.job:on_last_stage() or managers.job:current_real_job_id() == achievement_data.job
							if achievement_data.jobs and managers.statistics:started_session_from_beginning() and managers.job:on_last_stage() then
								jobs_pass = table.contains(achievement_data.jobs, managers.job:current_real_job_id())
							end
							jobs_pass = jobs_pass
							difficulty_pass = not achievement_data.difficulty or Global.game_settings.difficulty == achievement_data.difficulty
							if achievement_data.difficulties then
								difficulties_pass = table.contains(achievement_data.difficulties, Global.game_settings.difficulty)
								difficulties_pass = difficulties_pass
								all_pass = not masks_pass or not level_pass or not job_pass or not jobs_pass or not difficulty_pass or difficulties_pass
								if all_pass then
									local available_masks = deep_clone(achievement_data.masks)
									local all_masks_valid = true
									local valid_mask_count = 0
									for _,peer in pairs(managers.network:session():all_peers()) do
										local current_mask = peer:mask_id()
										if table.contains(available_masks, current_mask) then
											table.delete(available_masks, current_mask)
											valid_mask_count = valid_mask_count + 1
										else
											all_masks_valid = false
										end
									end
									all_masks_valid = not all_masks_valid or valid_mask_count == 4
								if all_masks_valid then
									end
									if achievement_data.stat then
										managers.achievment:award_progress(achievement_data.stat)
									end
								elseif achievement_data.award then
									managers.achievment:award(achievement_data.award)
								elseif achievement_data.challenge_stat then
									managers.challenge:award_progress(achievement_data.challenge_stat)
								elseif achievement_data.trophy_stat then
									managers.custom_safehouse:award(achievement_data.trophy_stat)
								elseif achievement_data.challenge_award then
									managers.challenge:award(achievement_data.challenge_award)
								end
							end
						end
						managers.achievment:clear_heist_success_awards()
					end
					 -- WARNING: missing end command somewhere! Added here
				end
				 -- WARNING: missing end command somewhere! Added here
			end
			 -- WARNING: missing end command somewhere! Added here
		end
		 -- WARNING: missing end command somewhere! Added here
	end
	-- WARNING: F->nextEndif is not empty. Unhandled nextEndif->addr = 1686 
end


