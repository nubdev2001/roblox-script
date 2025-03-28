if not LPH_OBFUSCATED then
	function LPH_NO_VIRTUALIZE(f)
		return f
	end
	function LPH_JIT(...)
		return ...
	end
	function LPH_JIT_MAX(...)
		return ...
	end
	function LPH_NO_UPVALUES(f)
		return function(...)
			return f(...)
		end
	end
	function LPH_ENCSTR(...)
		return ...
	end
	function LPH_ENCNUM(...)
		return ...
	end
	function LPH_CRASH()
		return print(debug.traceback())
	end
end

repeat
	task.wait()
until game:IsLoaded()

local clone_reference = cloneref or function(...) -- i need to cloneref stuf fso
	return ...
end

local players: Players = clone_reference(game:GetService("Players"))
local run_service: RunService = clone_reference(game:GetService("RunService"))
local replicated_storage: ReplicatedStorage = clone_reference(game:GetService("ReplicatedStorage"))
local user_input_service: UserInputService = clone_reference(game:GetService("UserInputService"))
local lighting: Lighting = clone_reference(game:GetService("Lighting"))
local core_gui: CoreGui = clone_reference(game:GetService("CoreGui"))
local http_service: HttpService = clone_reference(game:GetService("HttpService"))

local local_player = players.LocalPlayer

if game.PlaceId == 10228136016 then
	return local_player:Kick("execute ingame")
end

do
	local exploit_functions = {
		["cloneref"] = cloneref or false,
		["listfiles"] = listfiles or false,
		["Drawing"] = Drawing or false,
		["sethiddenproperty"] = sethiddenproperty or false,
		["run_on_actor"] = run_on_actor or false,
		["getactors"] = getactors or false,
		["gethui"] = gethui or false,
		["getcallingscript"] = getcallingscript or false,
		["hookfunction"] = hookfunction or false,
		["isfunctionhooked"] = isfunctionhooked or false,
		["create_comm_channel"] = create_comm_channel or false,
	}

	for i, v in exploit_functions do
		if v == false then
			return local_player:Kick(string.format("unsupported exploit! [%s]", i))
		end
	end
end

xpcall(function()
	local done = false
	local id, channel = create_comm_channel()
	channel.Event:Connect(function()
		done = true
	end)

	local module_bypassed = false
	local offsets = {
		[76] = function(func)
			hookfunction(func, function(detection)
				if tonumber(detection) then
					local skyyy = Instance.new("Sky")
					skyyy.Name = detection
					skyyy._ = 0
				end

				print("corescript", "module", detection)
			end)
			print("corescript", "bypassed module vector util")
			module_bypassed = true
		end,
	}
	for _, func in getgc(false) do
		if type(func) ~= "function" or (iscclosure(func)) or (isexecutorclosure(func)) then
			continue
		end

		local info = debug.getinfo(func)
		if not info.source:find("Modules.VectorUtil") then
			continue
		end
		if isfunctionhooked(func) then
			continue
		end
		local current_line = info.currentline

		local current_offset = offsets[current_line]
		if current_offset and type(current_offset) == "function" then
			xpcall(current_offset, function(err)
				print("corescript", err)
			end, func)
		end
	end

	if not module_bypassed then
		return local_player:Kick("PATCHED!")
	end

	local actors = getactors()
	if actors and actors[1] then
		local fallen_guard = actors[1]
		run_on_actor(
			fallen_guard,
			[[
			local id = ...

			if not id then
				return print('corescript', 'no id')
			end

			local replicated_storage = cloneref(game:GetService('ReplicatedStorage'))
			local starter_gui = cloneref(game:GetService('StarterGui'))
			local players = cloneref(game:GetService('Players'))

			local local_player = players.LocalPlayer

			local selection = cloneref(game:GetService("Selection"));
			local loading_screen = replicated_storage:WaitForChild('LoadingScreen')

			local admin_menu = Instance.new('ScreenGui')
			admin_menu.Name = "AdminMenu"
			admin_menu.Enabled = false
			local object = Instance.new('Frame')
			object.Name = 'AMain'
			object.Parent = admin_menu
			local ban_strings = {
				string.char(
					unpack(
						string.split("152/138/75/77/40/152/184/182/92/153/127/174/88/68/159/100/36/50/190/61/174/82/62/129/175/52/23/144/16/24", "/")
					)
				);
			}
			local console_bypassed = false
			local detection_up_function, debug_mode_function

			local ban_hook = function(_, str)
				return setmetatable({}, {
					__index = function()
						return function()
							print('corescript', 'waiter! waiter! a ban please!', str)
							return local_player:Kick('press F9, ban was triggered.')
						end
					end
				})
			end

			local offsets = {
				[698] = function(func) -- console detection
					hookfunction(func, function(...)
						return nil, nil, true
					end)
					console_bypassed = true
					print('corescript', 'bypassed actor console detections')
				end;
				[767] = function(func) -- detection upvalue, loading screen spawn function
					detection_up_function = func
					print('corescript', 'found detection stuff')
				end;
				[567] = function(func) -- fire remote
					local old_fire_remote
					old_fire_remote = hookfunction(func, function(...)
						local args = {...}
						if args[4] and type(args[4]) == 'table' then
							if table.find(args[4], '0x00') or table.find(args[4], "0x3A") then -- sanity checks
								return old_fire_remote(unpack(args))
							end
							if detection_up_function then
								local detection_value = debug.getupvalue(detection_up_function, 1) or 'ham / yuiz_'
								if table.find(args[4], detection_value) then
									print('corescript', 'prevented loop ban', detection_value)
									return "-/|"
								end
							end
							if table.find(args[4], '117') or table.find(args[4], '045') then
								print('corescript', 'prevented loop ban', table.concat(args[4], ' '))
								return "-/|"
							end
						end
						if typeof(args[2]) == 'Instance' and args[2].Name == string.char(147, 83, 68, 180, 43, 30, 48, 136, 61, 104, 122, 19, 122, 67, 181, 42, 75, 158, 121, 190, 172, 183, 120, 142, 52, 165, 9, 130, 129, 110) then
							print('corescript', 'actor ban attempt ezez', debug.traceback())
							return "-/|"
						end
						for i, sad in ban_strings do
							if table.find(args, sad) then
								print('corescript', 'sad', sad, i)
								return "-/|"
							end
						end
						return old_fire_remote(unpack(args))
					end)
					print('corescript', 'bypassed actor fire remote ban')
				end;
				[147] = function(func) -- error function
					local old_error_function
					old_error_function = hookfunction(func, function(detection)
						if detection == 'dumb mf' then
							return old_error_function(detection)
						end
						return print('corescript', detection)
					end)
					print('corescript', 'bypassed actor vector util error')
				end;
				[2434] = function(func)
					if rawequal(debug.getupvalue(func, 34), false) then
						debug.setupvalue(func, 34, true)
						print('corescript', '🥶')
					end
					local old
					old = hookfunction(func, function()
						return old(false)
					end)
					print('corescript', 'ban proxy bypassed')
				end;
				[2307] = function(func) -- debug mode
					debug_mode_function = func
					print('corescript', 'actor found')
				end;
				[2577] = function(func) -- expects concat function
					local proto = debug.getproto(func, 1)
					if proto and typeof(proto) == 'function' and (not isfunctionhooked(proto)) then
						hookfunction(proto, function()
							print('corescript', 'ban function triggered')
						end)

						print('corescript', 'ez')
					end
					hookfunction(func, ban_hook)
					print('corescript', 'hooked ban concat')
				end;
				[1405] = function(func) -- player gui ofc
					hookfunction(func, function() end) -- ezezezez
					admin_menu.Parent = local_player.PlayerGui
					print('corescript', 'playergui bypass')
				end;
				[315] = function(func)
					hookfunction(func, function()
						return math.huge
					end)
					print('corescript', "experimental")
				end,
				[3129] = function(func)
					hookfunction(func, function() end)
					print('corescript', 'kinky')
				end,
				[1330] = function(func)
					hookfunction(func, function() end)
					print('corescript', 'no ass')
				end,
				[1336] = function(func)
					hookfunction(func, function() end)
					print('corescript', 'fov changer')
				end
			}

			for _, func in getgc(false) do
				if type(func) ~= 'function' or (not islclosure(func)) or (isexecutorclosure(func)) then
					continue
				end

				local info = debug.getinfo(func)
				if not info.source:find('FallenGuard.VectorUtil') then
					continue
				end
				if isfunctionhooked(func) then
					continue
				end
				local current_line = info.currentline

				local current_offset = offsets[current_line]
				if current_offset and type(current_offset) == 'function' then
					xpcall(current_offset, function(err)
						print('corescript', err)
					end, func)
				end
			end
			if not console_bypassed then
				return local_player:Kick('console bypass IS NOT working.')
			end

			for _, v in getconnections(starter_gui.AttributeChanged) do
				local func = v.Function
				if func then
					hookfunction(func, function(attribute)
						local silly = starter_gui:GetAttribute(attribute)
						print('corescript', 'starter gui', attribute, silly)
					end)
					print('corescript', 'starter gui hooked')
				end
			end

			local old_task_defer
			old_task_defer = hookfunction(task.defer, newcclosure(function(...)
				local args = {...}

				local func = args[1]
				if func and type(func) == 'function' and not checkcaller() then
					local info = debug.getinfo(func)

					if info.currentline == 1760 then
						return print('corescript', 'content publisher ez')
					end
					if info.currentline == 2629 then
						return print('corescript', 'thanks u waiter!')
					end

					if info.currentline == 2681 then
						return print('corescript', 'bbc')
					end

					if info.currentline == 1480 then
						return print('corescript', 'bypassed instance checks')
					end
				end

				return old_task_defer(unpack(args))
			end))

			local old_namecall
			old_namecall = hookmetamethod(game, '__namecall', newcclosure(function(...)
				local args = {...}
				local method = getnamecallmethod()

				if args[1] == loading_screen then
					print('corescript', 'loading screen', args[2], args[3], getcallingscript().Name)
					return
				end

				if method == 'SendMessage' then
					return print('corescript', 'ban kill')
				end

				return old_namecall(unpack(args))
			end))
			local s = get_comm_channel(id)

			if isfunctionhooked(task.wait) then
				s:Fire('already hooked')
			else
				local old_task_wait
				old_task_wait = hookfunction(task.wait, function(...)
					local args = {...}

					if args[1] and args[1] == 10 and not checkcaller() then
						args[1] = 9e9
						s:Fire('bbc')
						print('corescript', 'raping')
					end

					return old_task_wait(unpack(args))
				end)
			end

			-- the above is just to prevent this below fucking up
			-- prevents ban table (full anticheat bypass)
			local kek
			for _, v in getconnections(selection.SelectionChanged) do
				if v.Function then
					kek = v.Function
				end
			end

			if kek and type(kek) == 'function' and debug.getupvalue(kek, 2) then
				print('corescript', 'grabbed ban table')
				task.spawn(function()
					while task.wait() do
						if debug_mode_function then
							debug.setupvalue(debug_mode_function, 1, true)
						end
						local ban_table = debug.getupvalue(kek, 2)
						local metatable = ban_table and getrawmetatable(ban_table)
						local concat_func = metatable and rawget(metatable, '__concat')
						if concat_func and (not isfunctionhooked(concat_func)) then
							print('corescript', 'hooking ban table')
							offsets[2581](concat_func)
						end
					end
				end)
			end
		]],
			id
		)

		repeat
			task.wait()
		until done
	end
end, function(err)
	print("corescript", err)
	local_player:Kick(err)
end)

local VMs = replicated_storage:FindFirstChild("VMs")
if not VMs then
	return local_player:Kick("no vms found!")
end

local modules = replicated_storage:FindFirstChild("Modules")
if not modules then
	return local_player:Kick("no modules found!")
end

local vfx_module = modules:FindFirstChild("VFXModule")
if not vfx_module then
	return local_player:Kick("no vfx module")
end
local sound_module = modules:FindFirstChild("SoundModule")
if not sound_module then
	return local_player:Kick("no sound module")
end
local raycast_module = modules:FindFirstChild("RaycastUtil")
if not raycast_module then
	return local_player:Kick("no raycast util")
end
local settings_module = modules:FindFirstChild("SettingsModule")
if not settings_module then
	return local_player:Kick("no settings module")
end

local raycast_table = require(raycast_module)
if not raycast_table then
	return local_player:Kick("no raycast table")
end

local vfx_table = require(vfx_module)
if not vfx_table then
	return local_player:Kick("no vfx table")
end

local sound_table = require(sound_module)
if not sound_table then
	return local_player:Kick("no sound table")
end

local settings_table = require(settings_module)
if not settings_table then
	return local_player:Kick("no settings table")
end

local nodes = workspace:FindFirstChild("Nodes")
local military = workspace:FindFirstChild("Military")
local drops = workspace:FindFirstChild("Drops")
local plants = workspace:FindFirstChild("Plants")
local vfx_folder = workspace:FindFirstChild("VFX")
local bases = workspace:FindFirstChild("Bases")
local animals = workspace:FindFirstChild("Animals")
local terrain = workspace:FindFirstChildOfClass("Terrain")
local events = workspace:FindFirstChild("Events")

if not (drops and plants and military and vfx_folder and bases and animals and terrain and events) then
	return local_player:Kick("i need that gyatt")
end

local vm_folder = vfx_folder:FindFirstChild("VMs")
if not vfx_folder then
	return local_player:Kick("no vm folder")
end
local cframe_look_at = CFrame.lookAt

local camera = workspace.CurrentCamera

local bindable_event = {
	Functions = {},
	Event = {},
}
bindable_event.Fire = function(_, ...)
	for _, func in bindable_event.Functions do
		func(...)
	end
end
bindable_event.Event.Connect = function(_, callback)
	table.insert(bindable_event.Functions, callback)
end

local mouse_location = user_input_service:GetMouseLocation()
local current_target: BasePart

local Library = loadstring(game:HttpGet("http://loadstring.org/library.lua"))()
local start_tick = tick()

local Window = Library:Window({
	Name = "fishy",
})

local watermark = Library:Watermark({
	Name = "  fishy dev",
})

do
	--// Window / Tabs

	local main_tab = Window:Tab({
		Name = "main",
	})

	local visuals_tab = Window:Tab({
		Name = "visuals",
	})

	local misc_tab = Window:Tab({
		Name = "misc",
	})

	local local_tab = Window:Tab({
		Name = "local",
	})

	-- keybind fix (p1000)
	Library:KeybindList()

	-- Most sections

	local silent_aim_section = main_tab:Section({
		Name = "silent aim",
		Side = "Left",
	})

	local player_esp_section = visuals_tab:Section({
		Name = "player esp",
		Side = "Left",
	})

	local exploits_section = misc_tab:Section({
		Name = "exploits",
		Side = "Left",
	})

	local melee_section = misc_tab:Section({
		Name = "melee",
		Side = "Right",
	})

	silent_aim_section:Toggle({
		Name = "silent aim",
		Flag = "silent aim",
		Default = false,
	})

	silent_aim_section:Dropdown({
		Name = "body parts",
		Flag = "body parts",
		Options = { "Head", "UpperTorso", "random", "closest" },
		Default = "UpperTorso",
	})

	silent_aim_section:Toggle({
		Name = "prediction",
		Flag = "prediction",
		Default = false,
	})

	silent_aim_section:Toggle({
		Name = "team check",
		Flag = "team check",
		Default = false,
	})

	silent_aim_section:Toggle({
		Name = "down check",
		Flag = "down check",
		Default = false,
	})

	silent_aim_section:Toggle({
		Name = "dead check",
		Flag = "dead check",
		Default = false,
	})

	silent_aim_section:Toggle({
		Name = "target npcs",
		Flag = "target npcs",
		Default = false,
	})

	silent_aim_section:Toggle({
		Name = "fov circle",
		Flag = "fov circle",
		Default = false,
	})

	silent_aim_section:Slider({
		Name = "fov circle size",
		Decimals = 1,
		Sub = "", -- slider retard fix AGAIN
		Flag = "fov circle size",
		Min = 0,
		Max = 350,
		Default = 100,
		Increment = 1,
	})

	silent_aim_section:Colorpicker({
		Name = "fov circle color",
		Flag = "fov circle color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	silent_aim_section:Toggle({
		Name = "snapline",
		Flag = "snapline",
		Default = false,
	})

	silent_aim_section:Colorpicker({
		Name = "snapline color",
		Flag = "snapline color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	silent_aim_section:Toggle({
		Name = "prediction dot",
		Flag = "prediction dot",
		Default = false,
	})

	silent_aim_section:Colorpicker({
		Name = "prediction dot color",
		Flag = "prediction dot color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	local gun_mods_section = main_tab:Section({
		Name = "gun mods",
		Side = "Right",
	})

	local old_recoil_start
	local old_recoil_finish

	gun_mods_section:Toggle({
		Name = "no recoil",
		Flag = "no recoil",
		Default = false,
		Callback = function()
			local value = Library.Flags["no recoil"]:Get()
			for _, tbl in getgc(true) do
				if type(tbl) ~= "table" then
					continue
				end

				local recoil_start = rawget(tbl, "RecoilStart")
				local recoil_finish = rawget(tbl, "RecoilFinish")

				if recoil_start and recoil_finish then
					if type(recoil_start) == "function" and type(recoil_finish) == "function" then
						if value then
							old_recoil_finish = recoil_finish
							old_recoil_start = recoil_start
							rawset(tbl, "RecoilStart", function(...)
								local x, y = recoil_start(...)

								return x * (Library.Flags["recoil percent"]:Get() / 100),
									y * (Library.Flags["recoil percent"]:Get() / 100)
							end)
							rawset(tbl, "RecoilFinish", function(...)
								local x, y = recoil_finish(...)

								return x * (Library.Flags["recoil percent"]:Get() / 100),
									y * (Library.Flags["recoil percent"]:Get() / 100)
							end)
						else
							if old_recoil_start then
								rawset(tbl, "RecoilStart", old_recoil_start)
							end
							if old_recoil_finish then
								rawset(tbl, "RecoilFinish", old_recoil_finish)
							end
							old_recoil_start = nil
							old_recoil_finish = nil
						end
					end
				end
			end
		end,
	})

	gun_mods_section:Slider({
		Name = "recoil percent",
		Decimals = 1,
		Sub = "%", -- slider retard fix AGAIN
		Flag = "recoil percent",
		Min = 0,
		Max = 100,
		Default = 0,
		Increment = 1,
	})

	local old_spread = {}

	local no_spread_callback = function()
		local value = Library.Flags["no spread"]:Get()

		for _, tbl in getgc(true) do
			if type(tbl) ~= "table" then
				continue
			end

			local spread_table = rawget(tbl, "Spread")
			if spread_table and typeof(spread_table) == "table" then
				for _, spread_stuff in spread_table do
					for i, v in spread_stuff do
						if type(v) == "number" then
							if not old_spread[spread_stuff] then
								old_spread[spread_stuff] = {}
							end

							if not old_spread[spread_stuff][i] then
								old_spread[spread_stuff][i] = v
							end

							if value then
								spread_stuff[i] = old_spread[spread_stuff][i]
									* (Library.Flags["spread percent"]:Get() / 100)
							else
								spread_stuff[i] = old_spread[spread_stuff][i]
							end
						end
					end
				end
			end
		end
	end

	gun_mods_section:Toggle({
		Name = "no spread",
		Flag = "no spread",
		Default = false,
		Callback = no_spread_callback,
	})

	gun_mods_section:Slider({
		Name = "spread percent",
		Decimals = 1,
		Sub = "%", -- slider retard fix AGAIN
		Flag = "spread percent",
		Min = 0,
		Max = 100,
		Default = 0,
		Increment = 1,
		Callback = no_spread_callback,
	})

	local old_firerates = {}

	local fast_fire_callback = function()
		local value = Library.Flags["fast firerate"]:Get()

		for _, tbl in getgc(true) do
			if type(tbl) ~= "table" then
				continue
			end

			local current_rpm = rawget(tbl, "RPM")

			if current_rpm then
				if not old_firerates[tbl] then
					old_firerates[tbl] = current_rpm
				end

				if value then
					tbl.RPM = old_firerates[tbl] * Library.Flags["fire rate"]:Get()
				else
					tbl.RPM = old_firerates[tbl]
				end
			end
		end
	end

	gun_mods_section:Toggle({
		Name = "fast firerate",
		Flag = "fast firerate",
		Default = false,
		Callback = fast_fire_callback,
	})

	gun_mods_section:Slider({
		Name = "fire rate",
		Decimals = 0.1,
		Sub = "x", -- slider retard fix AGAIN
		Flag = "fire rate",
		Min = 1,
		Max = 2,
		Default = 0,
		Increment = 0.1,
		Callback = fast_fire_callback,
	})

	local old_ranges = {}

	local melee_range_callback = function()
		local value = Library.Flags["extend melee range"]:Get()

		for _, tbl in getgc(true) do
			if type(tbl) ~= "table" then
				continue
			end

			local current_range = rawget(tbl, "Range")
			if current_range and rawget(tbl, "Offset") then
				if not old_ranges[tbl] then
					old_ranges[tbl] = current_range
				end

				if value then
					tbl.Range = old_ranges[tbl] * Library.Flags["melee range multiplier"]:Get()
				else
					tbl.Range = old_ranges[tbl]
				end
			end
		end
	end

	melee_section:Toggle({
		Name = "extend melee range",
		Flag = "extend melee range",
		Default = false,
		Callback = melee_range_callback,
	})

	melee_section:Slider({
		Name = "melee range multiplier",
		Decimals = 0.1,
		Sub = "x", -- slider retard fix AGAIN
		Flag = "melee range multiplier",
		Min = 1,
		Max = 4,
		Default = 0,
		Increment = 0.1,
		Callback = melee_range_callback,
	})

	local old_cooldowns = {}

	local cooldown_callback = function()
		local value = Library.Flags["tool cooldown"]:Get()

		for _, tbl in getgc(true) do
			if type(tbl) ~= "table" then
				continue
			end

			local current_cooldown = rawget(tbl, "Cooldown")
			if current_cooldown then
				if not old_cooldowns[tbl] then
					old_cooldowns[tbl] = current_cooldown
				end

				if value then
					tbl.Range = old_cooldowns[tbl] / Library.Flags["cooldown multiplier"]:Get()
				else
					tbl.Range = old_cooldowns[tbl]
				end
			end
		end
	end

	melee_section:Toggle({
		Name = "tool cooldown",
		Flag = "tool cooldown",
		Default = false,
		Callback = cooldown_callback,
	})

	melee_section:Slider({
		Name = "cooldown multiplier",
		Decimals = 0.1,
		Sub = "x", -- slider retard fix AGAIN
		Flag = "cooldown multiplier",
		Min = 1,
		Max = 1.4,
		Default = 0,
		Increment = 0.1,
		Callback = old_cooldowns,
	})

	local old_bullet_speeds = {}
	gun_mods_section:Toggle({
		Name = "fast bullet",
		Flag = "instant hit",
		Default = false,
		Callback = function()
			local value = Library.Flags["instant hit"]:Get()

			if value then
				for _, tbl in getgc(true) do
					if type(tbl) ~= "table" then
						continue
					end

					local bullet_table = rawget(tbl, "Bullet")
					if bullet_table and type(bullet_table) == "table" then
						if not old_bullet_speeds[bullet_table] then
							old_bullet_speeds[bullet_table] = bullet_table.Speed
						end
						bullet_table.Speed = 10000
					end
				end
			else
				for tbl, speed_value in old_bullet_speeds do
					tbl["Speed"] = speed_value
				end
			end
		end,
	})

	local old_vm_mults = {}
	exploits_section:Toggle({
		Name = "no viewmodel bob",
		Flag = "no viewmodel bob",
		Default = false,
		Callback = function()
			local value = Library.Flags["no viewmodel bob"]:Get()
			if value then
				for _, tbl in getgc(true) do
					if type(tbl) ~= "table" then
						continue
					end

					local vm_movement_mults = rawget(tbl, "VMMovementMults")
					if vm_movement_mults then
						for i, v in vm_movement_mults do
							if not old_vm_mults[vm_movement_mults] then
								old_vm_mults[vm_movement_mults] = {}
							end

							if not old_vm_mults[vm_movement_mults][i] then
								old_vm_mults[vm_movement_mults][i] = v
							end

							vm_movement_mults[i] = 0
						end
					end
				end
			else
				for tbl, values in old_vm_mults do
					for i, v in values do
						tbl[i] = v
					end
				end
			end
		end,
	})

	local old_slowdowns = {}
	gun_mods_section:Toggle({
		Name = "no gun slowdown",
		Flag = "no gun slowdown",
		Default = false,
		Callback = function()
			local value = Library.Flags["no slowdown"]:Get()

			if value then
				for _, tbl in getgc(true) do
					if type(tbl) ~= "table" then
						continue
					end

					local weapon_sreduction = rawget(tbl, "SReduction")

					if weapon_sreduction then
						if not old_slowdowns[tbl] then
							old_slowdowns[tbl] = weapon_sreduction
						end

						tbl.SReduction = 1
					end
				end
			else
				for tbl, v in old_slowdowns do
					tbl["SReduction"] = v
				end
			end
		end,
	})

	local old_tuahs = {}
	gun_mods_section:Toggle({
		Name = "no bullet drop",
		Flag = "no bullet drop",
		Default = false,
		Callback = function()
			local value = Library.Flags["no bullet drop"]:Get()

			if value then
				for _, tbl in getgc(true) do
					if type(tbl) ~= "table" then
						continue
					end

					local bullet_table = rawget(tbl, "Bullet")
					if bullet_table and type(bullet_table) == "table" then
						if not old_tuahs[bullet_table] then
							old_tuahs[bullet_table] = bullet_table.Gravity
						end

						bullet_table.Gravity = 0
					end
				end
			else
				for tbl, v in old_tuahs do
					tbl["Gravity"] = v
				end
			end
		end,
	})
	exploits_section:Toggle({
		Name = "no camera shake",
		Flag = "no camera shake",
		Default = false,
	})

	local old_equip_anims = {}
	exploits_section:Toggle({
		Name = "instant equip",
		Flag = "instant equip",
		Default = false,
		Callback = function()
			local value = Library.Flags["instant equip"]:Get()

			if value then
				for _, tbl in getgc(true) do
					if type(tbl) ~= "table" then
						continue
					end

					if rawget(tbl, "EquipAnimSpeed") then
						if not old_equip_anims[tbl] then
							old_equip_anims[tbl] = tbl.EquipAnimSpeed
						end
						tbl.EquipAnimSpeed = 100
					end
				end
			else
				for tbl, v in old_equip_anims do
					tbl["EquipAnimSpeed"] = v
				end
			end
		end,
	})

	local old_aim_down_speeds = {}
	gun_mods_section:Toggle({
		Name = "instant aim",
		Flag = "instant aim",
		Default = false,
		Callback = function()
			local value = Library.Flags["instant aim"]:Get()

			if value then
				for _, tbl in getgc(true) do
					if type(tbl) ~= "table" then
						continue
					end

					local aim_down_speeds = rawget(tbl, "AimDownSpeed")
					if aim_down_speeds and type(aim_down_speeds) == "table" then
						for i, v in aim_down_speeds do
							if not old_aim_down_speeds[aim_down_speeds] then
								old_aim_down_speeds[aim_down_speeds] = {}
							end

							if not old_aim_down_speeds[aim_down_speeds][i] then
								old_aim_down_speeds[aim_down_speeds][i] = v
							end
							aim_down_speeds[i] = 0
						end
					end
				end
			else
				for tbl, values in old_aim_down_speeds do
					for i, v in values do
						tbl[i] = v
					end
				end
			end
		end,
	})

	gun_mods_section:Toggle({
		Name = "instant bolt",
		Flag = "instant bolt",
		Default = false,
	})

	local old_autos = {}

	gun_mods_section:Toggle({
		Name = "always automatic",
		Flag = "always automatic",
		Default = false,
		Callback = function()
			local value = Library.Flags["always automatic"]:Get()

			if value then
				for _, tbl in getgc(true) do
					if type(tbl) ~= "table" then
						continue
					end

					local weapon_auto = rawget(tbl, "Auto")

					if weapon_auto ~= nil then
						if not old_autos[tbl] then
							old_autos[tbl] = weapon_auto
						end

						tbl.Auto = true
					end
				end
			else
				for tbl, v in old_autos do
					tbl["Auto"] = v
				end
			end
		end,
	})

	gun_mods_section:Toggle({
		Name = "always headshot",
		Flag = "always headshot",
		Default = false,
	})

	exploits_section:Toggle({
		Name = "sprint while attacking",
		Flag = "sprint while attacking",
		Default = false,
	})

	player_esp_section:Toggle({
		Name = "esp enabled",
		Flag = "esp enabled",
		Default = false,
	})

	player_esp_section:Toggle({
		Name = "team check",
		Flag = "esp team check",
		Default = false,
	})

	player_esp_section:Toggle({
		Name = "highlight enabled",
		Flag = "highlight enabled",
		Default = false,
	})

	player_esp_section:Colorpicker({
		Name = "highlight color",
		Flag = "highlight color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	player_esp_section:Toggle({
		Name = "box esp",
		Flag = "box esp",
		Default = false,
	})

	player_esp_section:Colorpicker({
		Name = "box esp color",
		Flag = "box esp color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	player_esp_section:Dropdown({
		Name = "box type",
		Flag = "box type",
		Options = { "full", "cornered" },
		Default = "full",
	})

	player_esp_section:Toggle({
		Name = "visible flag esp",
		Flag = "visible flag esp",
		Default = false,
	})

	player_esp_section:Colorpicker({
		Name = "visible flag color",
		Flag = "visible flag color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	player_esp_section:Colorpicker({
		Name = "non- color",
		Flag = "box esp color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	player_esp_section:Toggle({
		Name = "name esp",
		Flag = "name esp",
		Default = false,
	})

	player_esp_section:Colorpicker({
		Name = "name esp color",
		Flag = "name esp color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	player_esp_section:Toggle({
		Name = "distance esp",
		Flag = "distance esp",
		Default = false,
	})

	player_esp_section:Dropdown({
		Name = "distance measurement",
		Flag = "distance measurement",
		Options = { "meters", "studs" },
		Default = "studs",
	})

	player_esp_section:Colorpicker({
		Name = "distance esp color",
		Flag = "distance esp color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	player_esp_section:Toggle({
		Name = "weapon esp",
		Flag = "weapon esp",
		Default = false,
	})

	player_esp_section:Colorpicker({
		Name = "weapon esp color",
		Flag = "weapon esp color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	player_esp_section:Toggle({
		Name = "health bar",
		Flag = "health bar",
		Default = false,
	})

	player_esp_section:Slider({
		Name = "health bar thickness",
		Decimals = 0.1,
		Sub = "x", -- slider retard fix AGAIN
		Flag = "health bar thickness",
		Min = 0.1,
		Max = 3,
		Default = 1.5,
		Increment = 0.1,
	})

	player_esp_section:Dropdown({
		Name = "health bar position",
		Flag = "health bar position",
		Options = { "bottom", "left" },
		Default = "left",
	})

	player_esp_section:Toggle({
		Name = "health text",
		Flag = "health text",
		Default = false,
	})

	player_esp_section:Toggle({
		Name = "skeleton esp",
		Flag = "skeleton esp",
		Default = false,
	})

	player_esp_section:Colorpicker({
		Name = "skeleton esp color",
		Flag = "skeleton esp color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	player_esp_section:Slider({
		Name = "skeleton esp thickness",
		Decimals = 0.1,
		Sub = "", -- slider retard fix AGAIN
		Flag = "skeleton esp thickness",
		Min = 0,
		Max = 2,
		Default = 1.4,
		Increment = 0.1,
	})

	player_esp_section:Toggle({
		Name = "chams",
		Flag = "chams",
		Default = false,
	})

	player_esp_section:Slider({
		Name = "chams transparency",
		Decimals = 0.1,
		Sub = "", -- slider retard fix AGAIN
		Flag = "chams transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Increment = 0.1,
	})

	player_esp_section:Colorpicker({
		Name = "chams color",
		Flag = "chams color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	player_esp_section:Slider({
		Name = "chams outline transparency",
		Decimals = 0.1,
		Sub = "", -- slider retard fix AGAIN
		Flag = "chams outline transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Increment = 0.1,
	})

	player_esp_section:Colorpicker({
		Name = "chams outline color",
		Flag = "chams outline color",
		Default = Color3.fromRGB(255, 255, 255),
	})
	player_esp_section:Dropdown({
		Name = "chams mode",
		Flag = "chams mode",
		Options = { "visible only", "always on top" },
		Default = "always on top",
	})

	local objects_esp_section = visuals_tab:Section({
		Name = "objects esp",
		Side = "Right",
	})

	local animals_esp_toggle = objects_esp_section:Toggle({
		Name = "animals esp",
		Flag = "animals esp",
		Default = false,
		Callback = function()
			bindable_event:Fire()
		end,
	})

	animals_esp_toggle:Colorpicker({
		Name = "animals esp color",
		Flag = "animals esp color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function()
			bindable_event:Fire(true)
		end,
	})

	local drops_esp_toggle = objects_esp_section:Toggle({
		Name = "drops esp",
		Flag = "drops esp",
		Default = false,
		Callback = function()
			bindable_event:Fire()
		end,
	})

	drops_esp_toggle:Colorpicker({
		Name = "drops esp color",
		Flag = "drops esp color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function()
			bindable_event:Fire(true)
		end,
	})

	local plants_esp_toggle = objects_esp_section:Toggle({
		Name = "plants esp",
		Flag = "plants esp",
		Default = false,
		Callback = function()
			bindable_event:Fire()
		end,
	})

	plants_esp_toggle:Colorpicker({
		Name = "plants esp color",
		Flag = "plants esp color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function()
			bindable_event:Fire(true)
		end,
	})

	local soldiers_esp_toggle = objects_esp_section:Toggle({
		Name = "soldiers esp",
		Flag = "soldiers esp",
		Default = false,
		Callback = function()
			bindable_event:Fire()
		end,
	})

	soldiers_esp_toggle:Colorpicker({
		Name = "soldiers esp color",
		Flag = "soldiers esp color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function()
			bindable_event:Fire(true)
		end,
	})

	local body_bag_esp_toggle = objects_esp_section:Toggle({
		Name = "body bag esp",
		Flag = "body bag esp",
		Default = false,
		Callback = function()
			bindable_event:Fire()
		end,
	})

	body_bag_esp_toggle:Colorpicker({
		Name = "body bag esp color",
		Flag = "body bag esp color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function()
			bindable_event:Fire(true)
		end,
	})

	local crate_esp_toggle = objects_esp_section:Toggle({
		Name = "crates esp",
		Flag = "crates esp",
		Default = false,
		Callback = function()
			bindable_event:Fire()
		end,
	})

	crate_esp_toggle:Colorpicker({
		Name = "crates esp color",
		Flag = "crates esp color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function()
			bindable_event:Fire(true)
		end,
	})

	local timed_crate_esp_toggle = objects_esp_section:Toggle({
		Name = "timed crate esp",
		Flag = "timed crate esp",
		Default = false,
		Callback = function()
			bindable_event:Fire()
		end,
	})

	timed_crate_esp_toggle:Colorpicker({
		Name = "timed crate esp color",
		Flag = "timed crate esp color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function()
			bindable_event:Fire(true)
		end,
	})

	local btr_esp_toggle = objects_esp_section:Toggle({
		Name = "btr esp",
		Flag = "btr esp",
		Default = false,
		Callback = function()
			bindable_event:Fire()
		end,
	})

	btr_esp_toggle:Colorpicker({
		Name = "btr esp color",
		Flag = "btr esp color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function()
			bindable_event:Fire(true)
		end,
	})

	local nodes_esp_toggle = objects_esp_section:Toggle({
		Name = "nodes esp",
		Flag = "nodes esp",
		Default = false,
		Callback = function()
			bindable_event:Fire()
		end,
	})

	nodes_esp_toggle:Colorpicker({
		Name = "nodes esp color",
		Flag = "nodes esp color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function()
			bindable_event:Fire(true)
		end,
	})

	local visuals_misc_section = visuals_tab:Section({
		Name = "World",
		Side = "Right",
	})

	visuals_misc_section:Toggle({
		Name = "no fog",
		Flag = "no fog",
		Default = false,
	})

	visuals_misc_section:Toggle({
		Name = "fullbright",
		Flag = "fullbright",
		Default = false,
	})

	local old_ambient_color

	visuals_misc_section:Toggle({
		Name = "ambient",
		Flag = "ambient",
		Default = false,
		Callback = function()
			if not Library.Flags["ambient color"] then
				return
			end

			local value = Library.Flags["ambient"]:Get()
			local ambient_color = Library.Flags["ambient color"]:Get()

			if value and ambient_color then
				if not old_ambient_color then
					old_ambient_color = lighting.Ambient
				end
			elseif old_ambient_color then
				lighting.Ambient = old_ambient_color
			end
		end,
	})

	visuals_misc_section:Colorpicker({
		Name = "ambient color",
		Flag = "ambient color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function()
			if not Library.Flags["ambient color"] then
				return
			end

			local value = Library.Flags["ambient"]:Get()
			local ambient_color = Library.Flags["ambient color"]:Get()

			if value and ambient_color then
				if not old_ambient_color then
					old_ambient_color = lighting.Ambient
				end
			elseif old_ambient_color then
				lighting.Ambient = old_ambient_color
			end
		end,
	})

	local trace_section = visuals_tab:Section({
		Name = "Trace",
		Side = "Right",
	})

	trace_section:Toggle({
		Name = "hitmarkers",
		Flag = "hitmarkers",
		Default = false,
	})

	trace_section:Colorpicker({
		Name = "hitmarkers color",
		Flag = "hitmarkers color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	trace_section:Slider({
		Name = "hitmarkers lifetime",
		Decimals = 1,
		Sub = "", -- slider retard fix AGAIN
		Flag = "hitmarkers lifetime",
		Min = 0,
		Max = 15,
		Default = 5,
		Increment = 1,
	})

	trace_section:Toggle({
		Name = "melee tracers",
		Flag = "melee tracers",
		Default = false,
	})

	trace_section:Slider({
		Name = "melee tracers lifetime",
		Decimals = 1,
		Sub = "", -- slider retard fix AGAIN
		Flag = "melee tracers lifetime",
		Min = 0,
		Max = 15,
		Default = 5,
		Increment = 1,
	})

	trace_section:Colorpicker({
		Name = "melee tracers color",
		Flag = "melee tracers color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	trace_section:Toggle({
		Name = "bullet tracers",
		Flag = "bullet tracers",
		Default = false,
	})

	trace_section:Slider({
		Name = "bullet tracers lifetime",
		Decimals = 1,
		Sub = "", -- slider retard fix AGAIN
		Flag = "bullet tracers lifetime",
		Min = 0,
		Max = 15,
		Default = 5,
		Increment = 1,
	})

	trace_section:Colorpicker({
		Name = "bullet tracers color",
		Flag = "bullet tracers color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	visuals_misc_section:Toggle({
		Name = "no grass",
		Flag = "no grass",
		Default = false,
		Callback = function()
			sethiddenproperty(terrain, "Decoration", not Library.Flags["no grass"]:Get())
		end,
	})

	visuals_misc_section:Toggle({
		Name = "fov changer",
		Flag = "fov changer",
		Default = false,
	})

	visuals_misc_section:Slider({
		Name = "camera fov",
		Decimals = 1,
		Sub = "", -- slider retard fix AGAIN
		Flag = "camera fov",
		Min = 70,
		Max = 120,
		Default = 70,
		Increment = 1,
	})

	local zoom_toggle = visuals_misc_section:Toggle({
		Name = "zoom",
		Flag = "zoom",
		Default = false,
	})

	zoom_toggle:Keybind({
		Name = "zoom",
		Flag = "zoom key bind",
		Default = Enum.KeyCode.Z,
		Mode = "Hold",
	})

	visuals_misc_section:Slider({
		Name = "zoom fov",
		Decimals = 1,
		Sub = "", -- slider retard fix AGAIN
		Flag = "zoom fov",
		Min = 1,
		Max = 40,
		Default = 20,
		Increment = 1,
	})

	local movement_section = local_tab:Section({
		Name = "movement",
		Side = "Left",
	})

	local spiderman_button = movement_section:Toggle({
		Name = "spiderman",
		Flag = "spiderman",
		Default = false,
	})

	spiderman_button:Keybind({
		Name = "spiderman key bind",
		Flag = "spiderman key bind",
		Default = Enum.KeyCode.Space,
		Mode = "Hold",
	})

	local speed_toggle = movement_section:Toggle({
		Name = "speed enabled",
		Flag = "speed enabled",
		Default = false,
	})

	movement_section:Slider({
		Name = "speed",
		Decimals = 1,
		Sub = "", -- slider retard fix AGAIN
		Flag = "speed",
		Min = 1,
		Max = 40,
		Default = 35,
		Increment = 1,
	})

	speed_toggle:Keybind({
		Name = "speed key bind",
		Flag = "speed key bind",
		Default = Enum.KeyCode.V,
		Mode = "Toggle",
	})

	local local_chams_section = local_tab:Section({
		Name = "local chams",
		Side = "Right",
	})

	local_chams_section:Toggle({
		Name = "local chams material enabled",
		Flag = "local chams material enabled",
		Default = false,
	})
	local_chams_section:Dropdown({
		Name = "local chams material",
		Flag = "local chams material",
		Options = {
			"Neon",
			"ForceField",
			"SmoothPlastic",
		},
		Default = "ForceField",
	})

	local_chams_section:Toggle({
		Name = "local chams color enabled",
		Flag = "local chams color enabled",
		Default = false,
	})

	local_chams_section:Colorpicker({
		Name = "local chams color",
		Flag = "local chams color",
		Default = Color3.fromRGB(255, 255, 255),
	})

	exploits_section:Toggle({
		Name = "instant loot",
		Flag = "instant loot",
		Default = false,
	})

	exploits_section:Toggle({
		Name = "always perfect farm",
		Flag = "always perfect farm",
		Default = false,
	})

	exploits_section:Toggle({
		Name = "silent walk",
		Flag = "silent walk",
		Default = false,
	})

	exploits_section:Toggle({
		Name = "clapping cheeks",
		Flag = "clapping cheeks",
		Default = false,
	})

	local insert_part = function(tbl, part, data)
		tbl[part] = data
		local connection
		connection = part.Destroying:Connect(function()
			tbl[part] = nil
			connection:Disconnect()
		end)
	end

	local stored_damage_parts = {}

	exploits_section:Toggle({
		Name = "no trap damages",
		Flag = "no trap damages",
		Default = false,
		Callback = function()
			local value = Library.Flags["no trap damages"]:Get()

			if value then
				for _, v in workspace:GetDescendants() do
					if v:IsA("BasePart") and v.Name == "DamagePart" then
						insert_part(stored_damage_parts, v, v.Parent)
						v.Parent = core_gui
					end
				end
			else
				for part, old_parent in stored_damage_parts do
					part.Parent = old_parent
				end
				table.clear(stored_damage_parts)
			end
		end,
	})

	workspace.DescendantAdded:Connect(function(descendant)
		local value = Library.Flags["no trap damages"]:Get()
		if descendant:IsA("BasePart") and descendant.Name == "DamagePart" and value then
			insert_part(stored_damage_parts, descendant, descendant.Parent)
			descendant.Parent = core_gui
		end
	end)

	local stored_fire_parts = {}

	exploits_section:Toggle({
		Name = "no fire damages",
		Flag = "no fire damages",
		Default = false,
		Callback = function()
			local value = Library.Flags["no fire damages"]:Get()

			if value then
				for _, v in workspace:GetDescendants() do
					if v:IsA("BasePart") and v.Name == "Collision" and v.Parent.Name == "FirePart" then
						insert_part(stored_fire_parts, v, v.Parent)
						v.Parent = core_gui
					end
				end
			else
				for part, old_parent in stored_fire_parts do
					part.Parent = old_parent
				end
				table.clear(stored_fire_parts)
			end
		end,
	})

	workspace.DescendantAdded:Connect(function(descendant)
		local value = Library.Flags["no fire damages"]:Get()
		if
			descendant:IsA("BasePart")
			and descendant.Name == "Collision"
			and descendant.Parent.Name == "FirePart"
			and value
		then
			insert_part(stored_fire_parts, descendant, descendant.Parent)
			descendant.Parent = core_gui
		end
	end)

	local stored_trap_parts = {}

	exploits_section:Toggle({
		Name = "no trap touch parts",
		Flag = "no trap touch parts",
		Default = false,
		Callback = function()
			local value = Library.Flags["no trap touch parts"]:Get()

			if value then
				for _, v in workspace:GetDescendants() do
					if v:IsA("BasePart") and v.Name == "TouchCollision" then
						insert_part(stored_trap_parts, v, v.Parent)
						v.Parent = core_gui
					end
				end
			else
				for part, old_parent in stored_trap_parts do
					part.Parent = old_parent
				end
				table.clear(stored_trap_parts)
			end
		end,
	})

	workspace.DescendantAdded:Connect(function(descendant)
		local value = Library.Flags["no trap touch parts"]:Get()
		if descendant:IsA("BasePart") and descendant.Name == "TouchCollision" and value then
			insert_part(stored_trap_parts, descendant, descendant.Parent)
			descendant.Parent = core_gui
		end
	end)

	local misc_section = misc_tab:Section({
		Name = "misc",
		Side = "Right",
	})

	-- mod detector

	-- incase they rejoin, plus storing numbers aint that memory expensive..
	local ranks = {
		[0] = "not in group",
		[5] = "fan",
		[10] = "OG",
		[14] = "game tester",
		[15] = "game moderator",
		[25] = "developer",
		[30] = "lead developer",
		[254] = "co-founder",
		[255] = "founder",
	}
	local cached_ranks = {}

	local get_group_rank
	get_group_rank = function(player: Player, attempts: number): number
		attempts = attempts or 1

		if attempts > 5 then
			task.delay(30, get_group_rank, player)
			return -1
		end

		local cached_rank = cached_ranks[player.UserId]

		if cached_rank then
			return cached_rank
		end

		local s, rank = xpcall(player.GetRankInGroup, print, player, 1154360)

		if s and rank then
			if rank == -1 then
				return 0
			end

			cached_ranks[player.UserId] = rank
			return rank
		else
			-- for ratelimit stuff
			task.wait(attempts / 5)
			return get_group_rank(player, attempts + 1)
		end
	end

	local mod_detector = function(player: Player)
		if player == local_player then
			return
		end

		if not Library.Flags["mod detector"]:Get() then
			return
		end

		local group_rank = get_group_rank(player)
		print(group_rank)
		if group_rank >= 15 then
			if Library.Flags["detect options"]:Get() == "notify" then
				if player.DisplayName == player.Name then
					Library:Notify(
						string.format("[ 🎣 ] mod detected! @%s [%s]", player.Name, ranks[group_rank]),
						3,
						Library.Accent
					)
				else
					Library:Notify(
						string.format(
							"[ 🎣 ] mod detected! %s (@%s) [%s]",
							player.DisplayName,
							player.Name,
							ranks[group_rank]
						),
						3,
						Library.Accent
					)
				end
			else
				if player.DisplayName == player.Name then
					local_player:Kick(string.format("[ 🎣 ] mod detected! @%s [%s]", player.Name, ranks[group_rank]))
				else
					local_player:Kick(
						string.format(
							"[ 🎣 ] mod detected! %s (@%s) [%s]",
							player.DisplayName,
							player.Name,
							ranks[group_rank]
						)
					)
				end
			end
		end
	end

	misc_section:Toggle({
		Name = "mod detector",
		Flag = "mod detector",
		Default = false,
		Callback = function()
			local value = Library.Flags["mod detector"]

			if value then
				for _, player in players:GetPlayers() do
					task.spawn(mod_detector, player)
				end
			end
		end,
	})

	misc_section:Dropdown({
		Name = "detect options",
		Flag = "detect options",
		Options = { "kick", "notify" },
		Default = "notify",
	})

	players.PlayerAdded:Connect(mod_detector)

	local xray_toggle = misc_section:Toggle({
		Name = "xray",
		Flag = "xray",
		Default = false,
	})

	local stored_xray_parts = {}
	local valid_xray = {
		"Wall",
		"Foundation",
		"Floor",
		"Doorway",
		"^Window",
	}

	local function is_valid(part) -- retarded but i wanted to xray walls only 🐟
		for _, match in valid_xray do
			if string.match(part.Parent.Name, match) then
				return true
			end
		end

		return false
	end

	xray_toggle:Keybind({
		Name = "xray key bind",
		Flag = "xray key bind",
		Default = Enum.KeyCode.K,
		Mode = "Toggle",
		Callback = function()
			local value = Library.Flags["xray key bind"]:Get()

			if value and Library.Flags["xray"]:Get() then
				for _, v in bases:GetDescendants() do
					if not v:IsA("BasePart") then
						continue
					end

					local current_transparency = v.Transparency

					if current_transparency < 1 and is_valid(v) and not stored_xray_parts[v] then
						insert_part(stored_xray_parts, v, current_transparency)
						v.Transparency = Library.Flags["xray transparency"]:Get()
					end
				end
			else
				for part, old_transparency in stored_xray_parts do
					if part and old_transparency then
						part.Transparency = old_transparency
					else
						print(part, old_transparency, "xray error")
					end
				end
				table.clear(stored_xray_parts)
			end
		end,
	})

	bases.DescendantAdded:Connect(function(v)
		if not v:IsA("BasePart") then
			return
		end

		local value = Library.Flags["xray key bind"]:Get()

		local current_transparency = v.Transparency
		if
			current_transparency < 1
			and is_valid(v)
			and value
			and Library.Flags["xray"]:Get()
			and not stored_xray_parts[v]
		then
			insert_part(stored_xray_parts, v, current_transparency)
			v.Transparency = Library.Flags["xray transparency"]:Get()
		end
	end)

	misc_section:Slider({
		Name = "xray transparency",
		Decimals = 0.1,
		Sub = "", -- slider retard fix AGAIN
		Flag = "xray transparency",
		Min = 0,
		Max = 1,
		Default = 0.5,
		Increment = 0.1,
		Callback = function()
			local value = Library.Flags["xray transparency"]:Get()
			for part, _ in stored_xray_parts do
				if part then
					part.Transparency = value
				else
					print(part, "xray transparency error")
				end
			end
		end,
	})

	local loot_through_door_toggle = misc_section:Toggle({
		Name = "loot through door",
		Flag = "loot through door",
		Default = false,
	})

	local stored_doors = {}

	loot_through_door_toggle:Keybind({
		Name = "loot through door key bind",
		Flag = "loot through door key bind",
		Default = Enum.KeyCode.J,
		Mode = "Toggle",
		Callback = function()
			local value = Library.Flags["loot through door key bind"]:Get()

			if value and Library.Flags["loot through door"]:Get() then
				for _, v in bases:GetDescendants() do
					if v:IsA("Model") and v.Name:find("Door") and v.Name ~= "Doorway" and not stored_doors[v] then
						insert_part(stored_doors, v, v.Parent)
						v.Parent = lighting
					end
				end
			else
				for part, parent in stored_doors do
					if part and parent then
						part.Parent = parent
					end
				end
				table.clear(stored_doors)
			end
		end,
	})

	bases.DescendantAdded:Connect(function(v)
		local value = Library.Flags["loot through door key bind"]:Get()
		if
			v:IsA("Model")
			and v.Name:find("Door")
			and v.Name ~= "Doorway"
			and value
			and Library.Flags["loot through door"]:Get()
			and not stored_doors[v]
		then
			insert_part(stored_doors, v, v.Parent)
			v.Parent = lighting
		end
	end)
end
local settings_tab = Window:Tab({
	Name = "settings",
})

local settings_section = settings_tab:Section({
	Name = "Settings",
	Side = "Right",
})

do
	settings_section:Keybind({
		Name = "ui keybind",
		Flag = "ui keybind",
		Default = Enum.KeyCode.RightShift,
		Mode = "Toggle",
		Hidden = true,
		Callback = function()
			local keybind = Library.Flags["ui keybind"].Key
			Library.Key = keybind
		end,
	})

	settings_section:Toggle({
		Name = "ui watermark",
		Flag = "ui watermark",
		Default = true,
		Callback = function()
			watermark:SetVisiblity(Library.Flags["ui watermark"]:Get())
		end,
	})

	settings_section:Toggle({
		Name = "ui keybind list",
		Flag = "ui keybind list",
		Default = true,
		Callback = function()
			Library.KeybindList:SetVisibility(Library.Flags["ui keybind list"]:Get())
		end,
	})

	local Main = settings_tab:Section({
		Name = "Configs",
		Side = "Left",
	})

	local ConfigDropdown
	local refresh_configs = function()
		for Index, _ in ConfigDropdown.Options do
			ConfigDropdown:RemoveOption(Index)
		end

		local List = {}

		for _, File in listfiles(Library.FolderName .. "/Configs") do
			local FileName = File:gsub("^" .. Library.FolderName, "")
				:gsub("^/Configs", "")
				:gsub("^\\Configs", "")
				:gsub("^\\", "")
				:gsub("^/", "")
				:gsub(".json$", "")
			List[#List + 1] = FileName
		end

		for _, Value in List do
			ConfigDropdown:AddOption(Value)
		end
	end
	ConfigDropdown = Main:Listbox({ Flag = "SelectedConfig", Options = {} })
	Main:Textbox({
		Name = "Config Name",
		Flag = "ConfigName",
		Placeholder = "Type here...",
		Compact = true,
		Default = "",
	})
	Main:Button({
		Name = "Create",
		Callback = function()
			Library.Flags["ConfigName"]:Set(string.upper(Library.Flags["ConfigName"].Value))
			if
				Library.Flags["ConfigName"].Value == ""
				or Library.Flags["ConfigName"]:Get():find("/")
				or Library.Flags["ConfigName"]:Get():find("\\")
			then
				Library:Notify("invalid config name", 3, Color3.fromRGB(255, 0, 0))
				return
			end

			Library:SaveConfig(Library.Flags["ConfigName"].Value)
			Library:Notify("Created config " .. Library.Flags["ConfigName"].Value, 3, Color3.fromRGB(0, 255, 0))
			refresh_configs()
		end,
	}):Sub({
		Name = "Delete",
		Callback = function()
			Library.Flags["ConfigName"]:Set(string.upper(Library.Flags["ConfigName"].Value))
			Library:DeleteConfig(Library.Flags["SelectedConfig"].Value)
			Library:Notify(
				"deleted config " .. Library.Flags["SelectedConfig"].Value .. ", Refreshing list...",
				3,
				Color3.fromRGB(0, 255, 0)
			)
			task.wait(0.2)
			refresh_configs()
		end,
	})
	Main:Button({
		Name = "Load",
		Callback = function()
			Library.Flags["ConfigName"]:Set(string.upper(Library.Flags["ConfigName"].Value))
			Library:LoadConfig(
				readfile(Library.FolderName .. "/Configs/" .. Library.Flags["SelectedConfig"].Value .. ".json")
			)
			Library:Notify("loaded config " .. Library.Flags["ConfigName"].Value, 3, Color3.fromRGB(0, 255, 0))
		end,
	}):Sub({
		Name = "Save",
		Callback = function()
			Library.Flags["ConfigName"]:Set(string.upper(Library.Flags["ConfigName"].Value))
			Library:SaveConfig(Library.Flags["SelectedConfig"].Value)
			Library:Notify("saved config " .. Library.Flags["ConfigName"].Value, 3, Color3.fromRGB(0, 255, 0))
		end,
	})

	refresh_configs()
end

local is_down = function(humanoid)
	return humanoid:GetAttribute("Downed")
end

local is_dead = function(humanoid)
	return humanoid.Health <= 0
end

local is_team = function(player)
	if not player then
		return false
	end

	if player.Neutral then
		return getrenv().shared.cachedTeamModels[player.UserId]
	end

	return player.Team == local_player.Team
end

local insert_npc = function(tbl, npc)
	return table.insert(tbl, {
		Character = npc,
		Team = "NPC",
		Neutral = false,
	})
end

local get_target = function(fov_size)
	local closest, closest_distance, closest_screen_pos = nil, fov_size, nil

	local silly = players:GetPlayers()

	if Library.Flags["target npcs"]:Get() then
		for _, folder in military:GetChildren() do
			for _, model in folder:GetChildren() do
				if model:IsA("Model") then
					insert_npc(silly, model)
				end
			end
		end
	end

	local body_parts = Library.Flags["body parts"]:Get()
	if body_parts == "random" then
		local hawked_tuah = { "Head", "UpperTorso" }
		body_parts = hawked_tuah[math.random(1, #hawked_tuah)]
	end

	for _, player in next, silly do
		if player == local_player then
			continue
		end
		local character = player.Character
		if not character then
			continue
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then
			continue
		end

		if Library.Flags["team check"]:Get() and is_team(player) then
			continue
		end

		if Library.Flags["down check"]:Get() and is_down(humanoid) then
			continue
		end

		if Library.Flags["dead check"]:Get() and is_dead(humanoid) then
			continue
		end

		if body_parts == "closest" then
			for _, part in character:GetChildren() do
				if part:IsA("BasePart") then
					local screen_pos, on_screen = camera:WorldToViewportPoint(part:GetPivot().Position)

					if not on_screen then
						continue
					end

					local distance = (mouse_location - Vector2.new(screen_pos.X, screen_pos.Y)).Magnitude
					if distance < closest_distance then
						closest_distance = distance
						closest = part
						closest_screen_pos = screen_pos
					end
				end
			end
		else
			local body_part = character:FindFirstChild(body_parts)

			if not body_part then
				continue
			end

			local screen_pos, on_screen = camera:WorldToViewportPoint(body_part:GetPivot().Position)

			if not on_screen then
				continue
			end

			local distance = (mouse_location - Vector2.new(screen_pos.X, screen_pos.Y)).Magnitude
			if distance < closest_distance then
				closest_distance = distance
				closest = body_part
				closest_screen_pos = screen_pos
			end
		end
	end
	return closest, closest_screen_pos
end

local circle = Drawing.new("Circle")
circle.Visible = Library.Flags["fov circle"]:Get()
circle.Color = Library.Flags["fov circle color"]:Get()
circle.Position = mouse_location
circle.Radius = Library.Flags["fov circle size"]:Get()
circle.Thickness = 1
local dot = Drawing.new("Circle")
dot.Visible = false
dot.Filled = true
dot.Color = Color3.new(1, 1, 1)
dot.Position = mouse_location
dot.Radius = 3
local snapline = Drawing.new("Line")
snapline.Thickness = 1
snapline.Color = Library.Flags["snapline color"]:Get()
snapline.Visible = Library.Flags["snapline"]:Get()
snapline.From = mouse_location

local skibidi = function(draw, property, pos)
	local vec, visible = camera:worldToViewportPoint(pos.Position)

	if visible then
		draw[property] = Vector2.new(vec.X, vec.Y)
	end
	return visible
end

local draw_line_2 = function(from, to, color)
	local line = Drawing.new("Line")
	line.Visible = true
	line.Thickness = 1.5
	line.Color = color
	skibidi(line, "To", to)
	skibidi(line, "From", from)
	local connection
	connection = run_service.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
		local to_vis = skibidi(line, "To", to)
		local from_vis = skibidi(line, "From", from)
		if not to_vis or not from_vis then
			line.Visible = false
		end
	end))
	return function()
		line:Remove()
		connection:Disconnect()
	end
end

local fishy = {
	target = {
		entry = nil,
		part = nil,
		distance = math.huge,
	},

	fonts = {
		cache = {},
		options = { Graph_35 = {}, JuraLight = {}, Templeos = {}, ProggyTiny = {} },
	},

	bone_vec = {
		Head = Vector3.new(1, 1, 1),
		Torso = Vector3.new(2, 2, 1),
		Left_Arm = Vector3.new(1, 2, 1),
		Right_Arm = Vector3.new(1, 2, 1),
		Left_Leg = Vector3.new(1, 2, 1),
		Right_Leg = Vector3.new(1, 2, 1),
	},

	utilities = {},
	functions = {},
}

-- variables
local viewport_size = camera.ViewportSize

local raycast_params = RaycastParams.new()

raycast_params.FilterDescendantsInstances = { camera, local_player.Character }
raycast_params.FilterType = Enum.RaycastFilterType.Exclude
raycast_params.IgnoreWater = true

do -- functions
	function fishy.functions:create(class, prop)
		local inst = typeof(class) == "string" and Instance.new(class) or class
		for property, val in prop do
			inst[property] = val
		end
		return inst
	end

	function fishy.functions:is_visible(Destination)
		local part = Destination and Destination.PrimaryPart
		if not part then
			return false
		end
		local RaycastResult =
			workspace:Raycast(camera.CFrame.p, (part.Position - camera.CFrame.p).Unit * 10000, raycast_params)
		return RaycastResult and RaycastResult.Instance:IsDescendantOf(Destination)
	end

	local vertices = {
		{ -0.5, -0.5, -0.5 },
		{ -0.5, 0.5, -0.5 },
		{ 0.5, -0.5, -0.5 },
		{ 0.5, 0.5, -0.5 },
		{ -0.5, -0.5, 0.5 },
		{ -0.5, 0.5, 0.5 },
		{ 0.5, -0.5, 0.5 },
		{ 0.5, 0.5, 0.5 },
	}

	function fishy.functions:custom_bounds(model)
		local min_bound, max_bound =
			Vector3.new(math.huge, math.huge, math.huge), Vector3.new(-math.huge, -math.huge, -math.huge)
		local min_width = 2.5

		for _, part in model:GetChildren() do
			if part:IsA("BasePart") then
				local cframe, size = part.CFrame, part.Size
				for _, v in vertices do
					local world_space = cframe:PointToWorldSpace(
						Vector3.new(v[1] * size.X, (v[2] + 0.2) * (size.Y + 0.2), v[3] * size.Z)
					)
					min_bound = Vector3.new(
						math.min(min_bound.X, world_space.X),
						math.min(min_bound.Y, world_space.Y),
						math.min(min_bound.Z, world_space.Z)
					)
					max_bound = Vector3.new(
						math.max(max_bound.X, world_space.X),
						math.max(max_bound.Y, world_space.Y),
						math.max(max_bound.Z, world_space.Z)
					)
				end
			end
		end

		if min_bound == Vector3.new(math.huge, math.huge, math.huge) then
			return
		end

		local size = max_bound - min_bound
		size = Vector3.new(math.max(size.X, min_width), size.Y, size.Z)

		local center = (min_bound + max_bound) / 2
		return CFrame.new(center), size, center
	end
end

function fishy.functions:get_tool_name(character)
	for _, v in character:GetChildren() do
		if not v:IsA("Model") then
			continue
		end

		if v.Name == "Hair" or v.Name == "HolsterModel" then
			continue
		end

		if not v.PrimaryPart then
			continue
		end

		if
			v:FindFirstChild("Detail")
			or v:FindFirstChild("Main")
			or v:FindFirstChild("Handle")
			or v:FindFirstChild("Attachments")
			or v:FindFirstChild("ArrowAttach")
			or v:FindFirstChild("Attach")
		then
			return v.Name
		end
	end

	return "none"
end

do -- fonts
	function fishy.fonts.cache:Register_Font(Name, Weight, Style, Asset)
		if not isfolder("fishy") then
			makefolder("fishy")
		end
		local asset = "fishy/" .. Asset.Id
		local font = "fishy/" .. Name .. ".font"
		if not isfile(asset) then
			writefile(asset, Asset.Font)
		end
		writefile(
			font,
			http_service:JSONEncode({
				name = Name,
				faces = { { name = "Regular", weight = Weight, style = Style, assetId = getcustomasset(asset) } },
			})
		)
		return getcustomasset(font)
	end

	fishy.fonts.options = {
		Graph_35 = Font.new(
			fishy.fonts.cache:Register_Font(
				"Graph_35",
				400,
				"Regular",
				{
					Id = "Graph_35.ttf",
					Font = crypt.base64.decode(
						"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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAEAAF4dUW1fDzz1AAAEAAAAAADPMB8QAAAAAM8wHxAAAAAAA4ADgAAAAAgAAgABAAAAAAABAAADgAAAAAADAAAAAIADgAABAAAAAAAAAAAAAAAAAAABjgAAAAAAAAAAAQAAAAMAAAADAAEAAwAAgAMAAAADAAAAAwAAAAMAAAADAACAAwAAgAMAAIADAACAAwAAAAMAAIADAAAAAwAAgAMAAAADAAAAAwAAgAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAgAMAAIADAAAAAwAAAAMAAIADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAgAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAgAMAAAADAACAAwAAAAMAAAADAACAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAACAAwAAAAMAAAADAACAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwABAAMAAQADAAAAAwABAAMAAAADAAAAAwAAAAMAAAADAAEAAwAAAAMAAIADAAAAAwAAAAMAAAADAAAAAwAAgAMAAAADAAAAAwAAAAMAAAADAACAAwAAgAMAAQADAAAAAwAAAAMAAQACAAAAAwAAgAMAAIADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAgAMAAIADAACAAwAAgAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAACAAwAAgAMAAIADAACAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAoAAAAMAAAACgAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAACAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAgAMAAAACgAAAAwAAAAKAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAIADAAAAAwAAgAMAAAADAACAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAgAKAAIADAAAAAwAAAAIAAQACgACAAgABAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAgAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAKAAAACgAAAAwAAAAMAAAACgAAAAwAAgAMAAIADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAIADAACAAwAAAAMAAAADAACAAwAAAAMAAAADAACAAwAAgAMAAAADAAAAAAEAAAGOACwACwAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAiAZ4AAQAAAAAAAAAXAAAAAQAAAAAAAQANABcAAQAAAAAAAgAHACQAAQAAAAAAAwAYACsAAQAAAAAABAAVAEMAAQAAAAAABQALAFgAAQAAAAAABgANAGMAAQAAAAAABwA8AHAAAQAAAAAACAAVAKwAAQAAAAAACQAIAMEAAQAAAAAACgAuAMkAAQAAAAAACwAXAPcAAQAAAAAADAAw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AAABAAAAAAAAgAAA/4AAAACAAAD/gACAAIAAAP+AAAABAAAA/wAAgACAAAD/gAAAAIAAAP+AAIAAgAAA/4AAgACAAAD/gAAAAQAAAP8AAIAAgAAA/4AAgACAAAD/gAAAAAIAgAIAAYADgAADAAkAAAEBAQEBAQEBAQEAgAAAAIAAAAAAAAD/gAAAAQAAAAIAAIAAAP+AAIAAgAAAAIAAAP8AAAAABQCAAAACAAOAAAMABwALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBgAAAAIAAAP8AAAAAgAAA/wAAAACAAAAAAAAAAIAAAAAAAAAAgAAAAAAAgAAA/4AAgACAAAD/gACAAYAAAP6AAYAAgAAA/4AAgACAAAD/gAAAAAUAgAAAAgADgAADAAcACwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAACAAAAAAAAAAIAAAAAAAAAAgAAA/wAAAACAAAD/AAAAAIAAAAAAAIAAAP+AAIAAgAAA/4AAgAGAAAD+gAGAAIAAAP+AAIAAgAAA/4AAAAAFAIABgAIAAwAAAwAHAAsADwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAAAgAAAAIAAAACAAAD/AAAAAIAAAP8AAAAAgAAAAIAAAACAAAABgACAAAD/gAAAAIAAAP+AAIAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAAAAAQAAAIACgAMAAAsAAAEBAQEBAQEBAQEBAQEAAAD/AAAAAQAAAACAAAABAAAA/wAAAACAAQAAAACAAAABAAAA/wAAAP+AAAD/AAAAAAIAgAAAAYABgAADAAkAAAEBAQEBAQEBAQEAgAAAAIAAAAAAAAD/gAAAAQAAAAAAAIAAAP+AAIAAgAAAAIAAAP8AAAAAAQAAAYACgAIAAAMAAAEBAQEAAAAAAoAAAAGAAIAAAP+AAAAAAQCAAAABgAEAAAMAAAEBAQEAgAAAAQAAAAAAAQAAAP8AAAAABQAAAIACgAMAAAMABwALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAAAAAAAgAAAAAAAAACAAAAAAAAAAIAAAAAAAAAAgAAAAIAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAA/4AAgACAAAD/gAAAAAUAAAAAAoADgAADAAcADwAXABsAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP8AAAAAgAAA/oAAAACAAAAAgAAA/4AAAAGAAAD/gAAAAIAAAACAAAD+AAAAAYAAAAAAAIAAAP+AAYAAgAAA/4D/AAKAAAD+gAAA/4AAAP+AAAABgAAAAIAAAACAAAD9gAKAAIAAAP+AAAAAAQCAAAACAAOAAAsAAAEBAQEBAQEBAQEBAQCAAAAAgAAA/4AAAACAAAAAgAAAAIAAAAAAAIAAAAIAAAAAgAAAAIAAAP0AAAD/gAAAAAYAAAAAAoADgAAHAAsADwATABcAGwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAIAAAAGAAAD+gAAAAIAAAAAAAAAAgAAA/gAAAACAAAABgAAAAIAAAP4AAAABgAAAAAAAgAAAAIAAAP+AAAD/gAEAAIAAAP+AAIAAgAAA/4ABAACAAAD/gP+AAQAAAP8AAQAAgAAA/4AABgAAAAACgAOAAAMABwALAA8AEwAbAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAAAgAAA/wAAAACAAAD/AAAAAIAAAAAAAAD+gAAAAoAAAP+AAAAAAACAAAD/gACAAIAAAP+AAAABAAAA/wABAACAAAD/gACAAIAAAP+AAIAAgAAAAIAAAP+AAAD/gAACAAAAAAKAA4AAAwAVAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAACAAAAAgAAA/oAAAACAAAABAAAA/4AAAACAAAAAgAAAAIAAAP+AAAACAACAAAD/gP4AAQAAAAEAAAD/gAAAAQAAAACAAAAAgAAA/gAAAP+AAAD/AAAAAAQAAAAAAoADgAADAAcACwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAABgAAAAIAAAP2AAAACgAAA/gAAAAGAAAAAAACAAAD/gACAAIAAAP+AAAABgAAA/oABgAGAAAD/gAAA/4AAAP+AAAUAAAAAAoADgAADAAcADwATABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAAAAAAAACAAAD9gAAAAIAAAAGAAAD+gAAAAAAAAACAAAAAAAAAAQAAAAAAAIAAAP+AAIABAAAA/wAAAAIAAAD/gAAA/4AAAP8AAgAAgAAA/4AAgACAAAD/gAAAAAMAAAAAAoADgAADAAcADQAAAQEBAQEBAQEBAQEBAQEBAAAAAIAAAAAAAAAAgAAAAAAAAP4AAAACgAAAAAACAAAA/gACAACAAAD/gACAAIAAAACAAAD/AAAHAAAAAAKAA4AAAwAHAAsADwATABcAGwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAABgAAAAIAAAP4AAAABgAAA/gAAAACAAAABgAAAAIAAAP4AAAABgAAAAAAAgAAA/4AAgAEAAAD/AAAAAQAAAP8AAQAAgAAA/4AAgAEAAAD/AAAAAQAAAP8AAQAAgAAA/4AAAAAFAAAAAAKAA4AAAwAHAAsAEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAQAAAAAAAAAAgAAA/gAAAACAAAABgAAA/oAAAAGAAAAAgAAA/gAAAAGAAAAAAACAAAD/gACAAIAAAP+AAYABAAAA/wD/AACAAAAAgAAAAQAAAP4AAgAAgAAA/4AAAAACAIAAgAGAAwAAAwAHAAABAQEBAQEBAQCAAAABAAAA/wAAAAEAAAAAgAEAAAD/AAGAAQAAAP8AAAMAgAAAAYADAAADAAkADQAAAQEBAQEBAQEBAQEBAQEAgAAAAIAAAAAAAAD/gAAAAQAAAP8AAAABAAAAAAAAgAAA/4AAgACAAAAAgAAA/wABgAEAAAD/AAAHAAAAAAIAA4AAAwAHAAsADwATABcAGwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQGAAAAAgAAA/wAAAACAAAD/AAAAAIAAAP8AAAAAgAAAAAAAAACAAAAAAAAAAIAAAAAAAAAAgAAAAAAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAA/4AAAAACAAABAAKAAoAAAwAHAAABAQEBAQEBAQAAAAACgAAA/YAAAAKAAAABAACAAAD/gAEAAIAAAP+AAAcAgAAAAoADgAADAAcACwAPABMAFwAbAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAACAAAAAAAAAAIAAAAAAAAAAgAAAAAAAAACAAAD/AAAAAIAAAP8AAAAAgAAA/wAAAACAAAAAAACAAAD/gACAAIAAAP+AAIAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAA/4AAgACAAAD/gAAAAAYAAAAAAoADgAADAAcACwAPABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAACAAAD/gAAAAIAAAAAAAAAAgAAA/gAAAACAAAABgAAAAIAAAP4AAAABgAAAAAAAgAAA/4ABAACAAAD/gACAAIAAAP+AAQAAgAAA/4D/gAEAAAD/AAEAAIAAAP+AAAUAAAAAAoADgAADAA0AEQAVABkAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAAAAAAAAIAAAP+AAAABAAAAAIAAAP4AAAAAgAAAAYAAAACAAAD+AAAAAYAAAACAAQAAAP8A/4AAgAAAAQAAAACAAAD+gAAA/4ACgACAAAD/gP4AAoAAAP2AAoAAgAAA/4AAAgAAAAACgAOAAAsADwAAAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAACAAAD/gAAA/oAAAAAAAAABgAAAAAADAAAA/wAAAAEAAAD9AAAAAYAAAP6AAwAAgAAA/4AAAwAAAAACgAOAAAMABwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQIAAAAAgAAA/4AAAACAAAD9gAAAAgAAAP6AAAABgAAA/oAAAAGAAAAAgAEAAAD/AAGAAQAAAP8A/gADgAAA/4AAAP8AAAD/gAAA/wAAAP+AAAAABQAAAAACgAOAAAMABwALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAAAAAAAAgAAA/YAAAACAAAABgAAAAIAAAP4AAAABgAAAAAAAgAAA/4AAgACAAAD/gAAAAoAAAP2AAgAAgAAA/4AAgACAAAD/gAAAAAQAAAAAAoADgAADAAcACwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQGAAAAAgAAAAAAAAACAAAD/AAAAAIAAAP4AAAABgAAA/wAAAAEAAAAAgACAAAD/gACAAYAAAP6AAYAAgAAA/4D9gAOAAAD/gAAA/YAAAP+AAAEAAAAAAoADgAALAAABAQEBAQEBAQEBAQEAAAAAAoAAAP4AAAABgAAA/oAAAAIAAAAAAAOAAAD/gAAA/wAAAP+AAAD/AAAA/4AAAAABAAAAAAKAA4AACQAAAQEBAQEBAQEBAQAAAAACgAAA/gAAAAGAAAD+gAAAAAADgAAA/4AAAP8AAAD/gAAA/oAABAAAAAACgAOAAAcACwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD/AAAAAYAAAP2AAAAAgAAAAYAAAACAAAD+AAAAAYAAAAAAAIAAAAEAAAAAgAAA/gAAgAKAAAD9gAIAAIAAAP+AAIAAgAAA/4AAAQAAAAACgAOAAAsAAAEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAACAAAD/gAAA/oAAAAAAA4AAAP6AAAABgAAA/IAAAAGAAAD+gAAAAAEAgAAAAgADgAALAAABAQEBAQEBAQEBAQEAgAAAAIAAAP+AAAABgAAA/4AAAACAAAAAAACAAAACgAAAAIAAAP+AAAD9gAAA/4AAAAADAAAAAAKAA4AAAwAHAA8AAAEBAQEBAQEBAQEBAQEBAQEAgAAAAQAAAP6AAAAAgAAAAQAAAP+AAAABgAAA/4AAAAAAAIAAAP+AAIAAgAAA/4AAAAKAAAAAgAAA/4AAAP2AAAAABwAAAAACgAOAAAMABwALAA8AEwAbAB8AAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAgAAAACAAAD/AAAAAIAAAP8AAAAAgAAA/4AAAACAAAAAAAAAAIAAAP4AAAAAgAAAAIAAAP+AAAABgAAAAIAAAAAAAIAAAP+AAIAAgAAA/4AAgACAAAD/gAEAAIAAAP+AAIAAgAAA/4D9gAOAAAD+gAAA/4AAAP6AAwAAgAAA/4AAAAABAAAAAAKAA4AABQAAAQEBAQEBAAAAAACAAAACAAAAAAADgAAA/QAAAP+AAAMAAAAAAoADgAADAAsAEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAIAAAP6AAAAAgAAAAIAAAP+AAAABgAAA/4AAAACAAAAAgAAAAYABAAAA/wD+gAOAAAD/gAAA/4AAAP2AAAACgAAAAIAAAACAAAD8gAAAAAMAAAAAAoADgAADAAsAEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAIAAAP6AAAAAgAAAAIAAAP+AAAABgAAA/4AAAACAAAAAgAAAAYAAgAAA/4D+gAOAAAD/gAAA/wAAAP4AAAABAAAAAIAAAAIAAAD8gAAAAAQAAAAAAoADgAADAAcACwAPAAABAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAAAgAAA/gAAAAGAAAAAAACAAAD/gACAAoAAAP2AAAACgAAA/YACgACAAAD/gAACAAAAAAKAA4AAAwANAAABAQEBAQEBAQEBAQEBAQIAAAAAgAAA/YAAAAIAAAD+gAAAAYAAAP6AAAACAAEAAAD/AP4AA4AAAP+AAAD/AAAA/4AAAP6AAAAABwAAAAACgAOAAAMABwALAA8AEwAXABsAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAQAAAACAAAAAgAAA/wAAAACAAAD/AAAAAIAAAP6AAAAAgAAAAYAAAACAAAD+AAAAAYAAAAAAAIAAAP+AAAAAgAAA/4AAgACAAAD/gACAAIAAAP+A/4ACgAAA/YAAgAIAAAD+AAIAAIAAAP+AAAAABAAAAAACgAOAAAMABwALABkAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAgAAAACAAAD/AAAAAIAAAAAAAAAAgAAA/YAAAAIAAAD+gAAAAYAAAP+AAAD/gAAA/4AAAAAAAIAAAP+AAIAAgAAA/4ABgAEAAAD/AP4AA4AAAP+AAAD/AAAA/4AAAP+AAAAAgAAA/oAAAAAHAAAAAAKAA4AAAwAHAAsADwATABcAGwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAABgAAAAIAAAP4AAAABgAAA/gAAAACAAAABgAAAAIAAAP4AAAABgAAAAAAAgAAA/4AAgACAAAD/gAAAAQAAAP8AAQAAgAAA/4AAgAEAAAD/AACAAIAAAP+AAIAAgAAA/4AAAAABAAAAAAKAA4AABwAAAQEBAQEBAQEBAAAA/wAAAAKAAAD/AAAAAAADAAAAAIAAAP+AAAD9AAAAAAMAAAAAAoADgAADAAcACwAAAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAAAgAAAAAAAgAAA/4AAgAMAAAD9AAAAAwAAAP0AAAAABQAAAAACgAOAAAMABwALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAIAAAP8AAAAAgAAAAIAAAACAAAD+AAAAAIAAAAGAAAAAgAAAAAAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAIACgAAA/YAAAAKAAAD9gAAAAAUAAAAAAoADgAADAAcACwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAACAAAAAgAAAAIAAAP8AAAAAgAAA/oAAAACAAAABgAAAAIAAAAAAAIAAAP+AAAAAgAAA/4AAgAGAAAD+gAAAAwAAAP0AAAADAAAA/QAAAAAJAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAACAAAD+AAAAAIAAAACAAAAAgAAA/wAAAACAAAD/AAAAAIAAAACAAAAAgAAA/gAAAACAAAABgAAAAIAAAAAAAQAAAP8AAAABAAAA/wABAACAAAD/gAAAAIAAAP+AAIAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAIABAAAA/wAAAAEAAAD/AAAAAAUAAAAAAoADgAADAAcACwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAACAAAD/AAAAAIAAAACAAAAAgAAA/gAAAACAAAABgAAAAIAAAAAAAYAAAP6AAYAAgAAA/4AAAACAAAD/gACAAYAAAP6AAAABgAAA/oAAAAAFAAAAAAKAA4AABQAJAA0AEQAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAIAAAD+AAAAAIAAAAAAAAAAgAAAAAAAAACAAAAAAAAA/gAAAAKAAAAAAAEAAAD/gAAA/4ABAACAAAD/gACAAIAAAP+AAIAAgAAA/4AAgACAAAAAgAAA/wAAAAABAIAAAAIAA4AABwAAAQEBAQEBAQEAgAAAAYAAAP8AAAABAAAAAAADgAAA/4AAAP2AAAD/gAAAAAUAAACAAoADAAADAAcACwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAgAAAACAAAD/AAAAAIAAAP8AAAAAgAAA/wAAAACAAAD/AAAAAIAAAACAAIAAAP+AAIAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAA/4AAAAABAIAAAAIAA4AABwAAAQEBAQEBAQEAgAAAAQAAAP8AAAABgAAAAAAAgAAAAoAAAACAAAD8gAAAAAUAAAIAAoADgAADAAcACwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABgAAAAIAAAP4AAAAAgAAAAIAAAACAAAD/AAAAAIAAAAIAAIAAAP+AAAAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAIAAgAAA/4AAAAABAAAAAAKAAIAAAwAAAQEBAQAAAAACgAAAAAAAgAAA/4AAAAACAIACAAIAA4AAAwAJAAABAQEBAQEBAQEBAYAAAACAAAD/AAAA/4AAAAEAAAACAACAAAD/gACAAIAAAACAAAD/AAAAAAMAAAAAAoACgAADAA0AEQAAAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAAAAAAAAYAAAP6AAAABgAAAAIAAAP4AAAABgAAAAIAAgAAA/4D/gACAAAAAgAAAAIAAAACAAAD+AAIAAIAAAP+AAAMAAAAAAoADgAADAAcAEQAAAQEBAQEBAQEBAQEBAQEBAQEBAgAAAACAAAD+gAAAAQAAAP4AAAAAgAAAAIAAAP+AAAABgAAAAIABgAAA/oABgACAAAD/gP4AA4AAAP6AAAD/gAAA/wAAAP+AAAQAAAAAAoACgAADAAcACwAPAAABAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAAAAAAAAIAAAP2AAAAAgAAAAAAAAAGAAAAAAACAAAD/gACAAIAAAP+AAAABgAAA/oABgACAAAD/gAADAAAAAAKAA4AAAwAHABEAAAEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAAAAAAEAAAD/AAAAAYAAAP+AAAAAgAAAAIAAAACAAYAAAP6AAYAAgAAA/4D+AACAAAABAAAAAIAAAAGAAAD8gAADAAAAAAKAAoAAAwANABEAAAEBAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAABgAAAAIAAAP4AAAAAAAAAAYAAAAAAAIAAAP+AAIABgAAA/4AAAACAAAD/AAAA/4ABgACAAAD/gAACAAAAAAIAA4AACwAPAAABAQEBAQEBAQEBAQEBAQEBAIAAAP+AAAAAgAAAAIAAAACAAAD/gAAAAAAAAAEAAAAAAAIAAAAAgAAAAIAAAP+AAAD/gAAA/gADAACAAAD/gAADAAAAAAKAAoAAAwAHABEAAAEBAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAABgAAA/oAAAAGAAAD+gAAAAgAAAAAAAIAAAP+AAYAAgAAA/4D/AACAAAAAgAAAAIAAAACAAAD+AAADAAAAAAKAA4AAAwAHAA8AAAEBAQEBAQEBAQEBAQEBAQECAAAAAIAAAP6AAAABAAAA/gAAAACAAAAAgAAA/4AAAAAAAgAAAP4AAgAAgAAA/4D+AAOAAAD+gAAA/4AAAP6AAAAAAgCAAAACAAOAAAkADQAAAQEBAQEBAQEBAQEBAQEAgAAAAIAAAP+AAAABAAAAAIAAAP8AAAAAgAAAAAAAgAAAAYAAAACAAAD+AAAA/4ADAACAAAD/gAAAAAQAAAAAAgADgAADAAcADQARAAABAQEBAQEBAQEBAQEBAQEBAQEAgAAAAQAAAP6AAAAAgAAAAQAAAP+AAAABAAAA/4AAAACAAAAAAACAAAD/gACAAIAAAP+AAAABgAAAAIAAAP4AAoAAgAAA/4AAAAAFAAAAAAIAA4AAAwAHAAsADwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBgAAAAIAAAP8AAAAAgAAA/4AAAACAAAAAAAAAAIAAAP4AAAAAgAAAAIAAAP+AAAAAAACAAAD/gACAAIAAAP+AAQAAgAAA/4AAgACAAAD/gP4AA4AAAP4AAAD/gAAA/wAAAAABAIAAAAIAA4AACQAAAQEBAQEBAQEBAQCAAAAAgAAA/4AAAAEAAAAAgAAAAAAAgAAAAoAAAACAAAD9AAAA/4AABAAAAAACgAKAAAMABwANABEAAAEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAgAAAAIAAAACAAAD9gAAAAQAAAP+AAAABAAAAAIAAAAAAAgAAAP4AAAACAAAA/gAAAAKAAAD/gAAA/gACAACAAAD/gAAAAAMAAAAAAoACgAADAAsADwAAAQEBAQEBAQEBAQEBAQEBAQIAAAAAgAAA/YAAAACAAAAAgAAA/4AAAACAAAABAAAAAAACAAAA/gAAAAKAAAD/gAAA/4AAAP6AAgAAgAAA/4AAAAAEAAAAAAKAAoAAAwAHAAsADwAAAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAABgAAAAIAAAP4AAAABgAAAAAAAgAAA/4AAgAGAAAD+gAAAAYAAAP6AAYAAgAAA/4AAAgAAAAACgAKAAAMADQAAAQEBAQEBAQEBAQEBAQECAAAAAIAAAP2AAAACAAAA/oAAAAGAAAD+gAAAAYAAgAAA/4D+gAKAAAD/gAAA/4AAAP+AAAD/AAAAAAIAAAAAAoACgAADAA0AAAEBAQEBAQEBAQEBAQEBAAAAAACAAAABgAAA/oAAAAGAAAD+gAAAAgAAAAGAAIAAAP+A/oABAAAAAIAAAACAAAAAgAAA/YAAAAADAAAAAAKAAoAAAwALAA8AAAEBAQEBAQEBAQEBAQEBAQECAAAAAIAAAP2AAAAAgAAAAIAAAP+AAAAAgAAAAQAAAAGAAIAAAP+A/oACgAAA/4AAAP+AAAD+gAIAAIAAAP+AAAAABQAAAAACgAKAAAMABwALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAgAAAAAAAAAAgAAA/gAAAAGAAAD+AAAAAIAAAAAAAAACAAAAAAAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAA/4AAgACAAAD/gAAAAAMAAAAAAoADgAADAAcAEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAQAAAAAAAAAAgAAA/gAAAP+AAAAAgAAAAIAAAACAAAD/gAAAAAAAgAAA/4AAgACAAAD/gAAAAgAAAACAAAAAgAAA/4AAAP+AAAD+AAAAAAMAAAAAAoACgAADAAcADwAAAQEBAQEBAQEBAQEBAQEBAQCAAAABAAAA/oAAAACAAAABgAAA/4AAAACAAAAAgAAAAAAAgAAA/4AAgAIAAAD+AP+AAIAAAACAAAABgAAA/YAAAAAFAAAAAAKAAoAAAwAHAAsADwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAgAAA/wAAAACAAAAAgAAAAIAAAP4AAAAAgAAAAYAAAACAAAAAAACAAAD/gACAAQAAAP8AAAABAAAA/wABAAEAAAD/AAAAAQAAAP8AAAAABQAAAAACgAKAAAMABwALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAIAAAACAAAAAgAAA/wAAAACAAAD+gAAAAIAAAAGAAAAAgAAAAAAAgAAA/4AAAACAAAD/gACAAQAAAP8AAAACAAAA/gAAAAIAAAD+AAAAAAUAAAAAAoACgAADAAcADwATABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAQAAAAEAAAD+AAAAAIAAAAEAAAD/gAAA/oAAAAEAAAABAAAAAIAAAAAAAIAAAP+AAAAAgAAA/4AAgACAAAABAAAA/4AAAP8AAYAAgAAA/4AAAACAAAD/gAAAAAUAAAAAAoACgAADAAkADQARABUAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAQAAAAAAAAABAAAA/4AAAP8AAAAAgAAA/wAAAACAAAABgAAAAIAAAAAAAIAAAP+AAIABAAAA/4AAAP+AAQAAgAAA/4AAgACAAAD/gP+AAQAAAP8AAAMAAAAAAoACgAAHAAsAEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAACAAAABgAAA/oAAAACAAAAAAAAA/oAAAAKAAAD/gAAAAAAAgAAAAIAAAP+AAAD/gAEAAIAAAP+AAIAAgAAAAIAAAP+AAAD/gAAAAAUAAAAAAYADgAADAAcACwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAACAAAD/AAAAAIAAAP8AAAAAgAAAAAAAAACAAAAAAAAAAIAAAAAAAIAAAP+AAIABAAAA/wABAACAAAD/gACAAQAAAP8AAQAAgAAA/4AAAAABAQAAAAGAA4AAAwAAAQEBAQEAAAAAgAAAAAADgAAA/IAAAAAFAQAAAAKAA4AAAwAHAAsADwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAgAAAAAAAAACAAAAAAAAAAIAAAP8AAAAAgAAA/wAAAACAAAAAAACAAAD/gACAAQAAAP8AAQAAgAAA/4AAgAEAAAD/AAEAAIAAAP+AAAAABQAAAQACgAKAAAMABwALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBgAAAAIAAAP4AAAAAgAAAAIAAAACAAAD/AAAAAIAAAAEAAAAAgAAAAQAAgAAA/4AAAAEAAAD/AACAAIAAAP+AAIAAgAAA/4D/gAEAAAD/AAAAAAIBAAAAAYADgAADAAcAAAEBAQEBAQEBAQAAAACAAAD/gAAAAIAAAAAAAoAAAP2AAwAAgAAA/4AAAwAAAAACgAOAAAMABwAbAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABgAAAAIAAAP6AAAD/gAAAAIAAAP+AAAAAgAAAAIAAAACAAAD/gAAAAIAAAP+AAAABAAGAAAD+gAEAAIAAAP+A/gAAgAAAAIAAAAGAAAAAgAAAAIAAAP+AAAD/gAAA/oAAAP+AAAD/gAAAAAMAAAAAAoADgAAPABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAD/gAAAAIAAAACAAAAAgAAA/4AAAAGAAAD/gAAAAIAAAP6AAAABAAAAAAAAgAAAAQAAAACAAAABAAAA/wAAAP+AAAD/AAAA/4ACgACAAAD/gACAAIAAAP+AAAAABgAAAIACgAMAAAMABwALAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAGAAAAAgAAA/wAAAP+AAAD/gAAAAYAAAP4AAAAAgAAAAYAAAACAAAAAgACAAAD/gAAAAIAAAP+AAQAAgAAA/4D/gAGAAAD+gAGAAIAAAP+AAAAAgAAA/4AABQAAAAACgAOAABMAFwAbAB8AIwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAP8AAAABAAAA/wAAAAEAAAAAgAAAAQAAAP8AAAABAAAA/wAAAP8AAAAAgAAAAIAAAACAAAD+AAAAAIAAAAGAAAAAgAAAAAAAgAAAAIAAAACAAAAAgAAAAIAAAP+AAAD/gAAA/4AAAP+AAAD/gAKAAIAAAP+AAAAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAAAAAgEAAAABgAOAAAMABwAAAQEBAQEBAQEBAAAAAIAAAP+AAAAAgAAAAAABgAAA/oACAAGAAAD+gAAIAAAAAAKAA4AAAwAHAAsAEQAXABsAHwAjAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD+gAAAAIAAAACAAAD+gAAAAQAAAP+AAAD/AAAAAIAAAAGAAAAAgAAA/gAAAAGAAAAAAACAAAD/gACAAIAAAP+AAAAAgAAA/4AAgACAAAAAgAAA/wAAgAEAAAD/gAAA/4ABAACAAAD/gAAAAIAAAP+AAIAAgAAA/4AAAgCAAwACAAOAAAMABwAAAQEBAQEBAQEAgAAAAIAAAACAAAAAgAAAAwAAgAAA/4AAAACAAAD/gAACAAAAAAKAA4AAEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBgAAAAIAAAP+AAAD/gAAAAIAAAACAAAD/gAAA/4AAAP+AAAAAgAAA/wAAAAKAAAAAgACAAAAAgAAA/4AAAAGAAAD/gAAAAIAAAACAAAD/gAAA/oAAAP+A/4ADgAAA/IAABAAAAAACgAOAAAMABwARABUAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAoAAAP2AAAAAgAAAAAAAAAGAAAD+gAAAAYAAAACAAAD+AAAAAYAAAAAAAIAAAP+AAYAAgAAA/4D/gACAAAAAgAAAAIAAAACAAAD+AAIAAIAAAP+AAAAACgAAAIACgAOAAAMABwALAA8AEwAXABsAHwAjACcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAIAAAACAAAAAgAAA/gAAAACAAAAAgAAAAIAAAP4AAAAAgAAAAIAAAACAAAD/AAAAAIAAAACAAAAAgAAA/wAAAACAAAAAgAAAAIAAAACAAIAAAP+AAAAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAIABAAAA/wAAAAEAAAD/AAEAAIAAAP+AAAAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAAEAAAIAAoADAAAFAAABAQEBAQECAAAA/gAAAAKAAAACAACAAAAAgAAA/wAAAQCAAYACAAIAAAMAAAEBAQEAgAAAAYAAAAGAAIAAAP+AAAAAAwAAAAACgAOAAAMAEQAVAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAACAAAAAgAAA/4AAAACAAAD/gAAA/wAAAACAAAAAgAAA/oAAAAKAAAACAACAAAD/gP6AAQAAAACAAAAAgAAAAIAAAP2AAAABAAAA/wD/gAOAAAD8gAABAAADAAKAA4AAAwAAAQEBAQAAAAACgAAAAwAAgAAA/4AAAAAEAAABgAIAA4AAAwAHAAsADwAAAQEBAQEBAQEBAQEBAQEBAQCAAAABAAAA/oAAAACAAAABAAAAAIAAAP6AAAABAAAAAYAAgAAA/4AAgAEAAAD/AAAAAQAAAP8AAQAAgAAA/4AAAgAAAAACgAOAAAMADwAAAQEBAQEBAQEBAQEBAQEBAQAAAAACgAAA/oAAAP8AAAABAAAAAIAAAAEAAAD/AAAAAAAAgAAA/4ABAAEAAAAAgAAAAQAAAP8AAAD/gAAA/wAAAQCAAQACAAOAAAsAAAEBAQEBAQEBAQEBAQCAAAABAAAA/wAAAAGAAAD/AAAAAQAAAAEAAYAAAACAAAAAgAAA/oAAAP+AAAD/gAAAAAEAgAEAAgADgAALAAABAQEBAQEBAQEBAQEAgAAAAQAAAP8AAAABAAAA/wAAAAGAAAABAACAAAAAgAAAAIAAAACAAAAAgAAA/YAAAAACAQACAAKAA4AAAwAJAAABAQEBAQEBAQEBAQAAAACAAAAAAAAAAQAAAP+AAAACAACAAAD/gACAAQAAAP+AAAD/gAAAAAMAAAAAAoACgAADAAsADwAAAQEBAQEBAQEBAQEBAQEBAQIAAAAAgAAA/YAAAACAAAABAAAA/wAAAAEAAAAAgAAAAQAAgAAA/4D/AAKAAAD/AAAA/4AAAP8AAYABAAAA/wAAAAABAAAAAAKAA4AACQAAAQEBAQEBAQEBAQEAAAD/AAAAAoAAAP+AAAD/gAAAAAACAAAAAYAAAPyAAAADAAAA/QAAAQEAAYABgAIAAAMAAAEBAQEBAAAAAIAAAAGAAIAAAP+AAAAAAQAAAAABgAEAAAUAAAEBAQEBAQAAAAABAAAAAIAAAAAAAIAAAACAAAD/AAABAIABAAIAA4AACwAAAQEBAQEBAQEBAQEBAIAAAACAAAD/gAAAAIAAAACAAAAAgAAAAQAAgAAAAQAAAACAAAAAgAAA/gAAAP+AAAAAAgCAAQACAAOAAAMABwAAAQEBAQEBAQEBgAAA/4AAAP+AAAABgAAAAYABgAAA/oD/gAKAAAD9gAAKAAAAgAKAA4AAAwAHAAsADwATABcAGwAfACMAJwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAIAAAACAAAD/AAAAAIAAAACAAAAAgAAA/wAAAACAAAAAgAAAAIAAAP4AAAAAgAAAAIAAAACAAAD+AAAAAIAAAACAAAAAgAAAAIAAgAAA/4AAAACAAAD/gACAAIAAAP+AAAAAgAAA/4AAgAEAAAD/AAAAAQAAAP8AAQAAgAAA/4AAAACAAAD/gACAAIAAAP+AAAAAgAAA/4AABQAAAAACgAOAAAMAEQAVABkAIQAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAP8AAAD/gAAAAIAAAACAAAAAgAAAAIAAAP8AAAAAgAAAAAAAAACAAAD+AAAA/4AAAACAAAAAgAAAAIAAgAAA/4D/gACAAAAAgAAAAIAAAACAAAD/AAAAAIAAAP6AAgAAgAAA/4AAgACAAAD/gP+AAIAAAACAAAAAgAAA/oAABgAAAAACgAOAAAMACwAPABkAHQAlAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAIAAAACAAAAAgAAAAIAAAP+AAAAAgAAA/gAAAACAAAAAgAAAAIAAAP+AAAAAgAAAAIAAAP4AAAD/gAAAAIAAAACAAAAAgACAAAD/gP+AAIAAAACAAAD/gAAA/4ABAACAAAD/gAAAAIAAAACAAAAAgAAA/wAAAP+AAYAAgAAA/4D/gACAAAAAgAAAAIAAAP6AAAAABgAAAAACgAOAAAMABwALAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAAAAAAAAgAAA/YAAAACAAAAAAAAAAIAAAAAAAAAAgAAA/4AAAACAAAAAAACAAAD/gACAAIAAAP+AAAABAAAA/wABAACAAAD/gACAAIAAAP+AAQAAgAAA/4AAAwAAAAACgAOAAAsAEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAGAAAAAgAAA/4AAAP6AAAAAAAAAAIAAAACAAAAAgAAA/oAAAACAAAAAAAIAAAD/gAAAAIAAAP4AAAABAAAA/wACAACAAAAAgAAA/4AAAP+AAQAAgAAA/4AAAAADAAAAAAKAA4AACwATABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAACAAAD/gAAA/oAAAAAAAAAAgAAAAIAAAACAAAD/gAAAAIAAAAAAAgAAAP+AAAAAgAAA/gAAAAEAAAD/AAIAAIAAAACAAAD/gAAA/4ABAACAAAD/gAAAAAMAAAAAAoADgAALABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABgAAAAIAAAP+AAAD+gAAAAAAAAACAAAAAgAAAAIAAAP8AAAAAgAAAAAACAAAA/4AAAACAAAD+AAAAAQAAAP8AAgABAAAA/4AAAACAAAD/AAEAAIAAAP+AAAAABQAAAAACgAOAAAsADwAVABkAHQAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABgAAAAIAAAP+AAAD+gAAA/4AAAACAAAAAAAAAAIAAAAEAAAD+gAAAAIAAAAEAAAAAgAAAAAACAAAA/4AAAACAAAD+AAAAAQAAAP8AAoAAgAAA/4D/gACAAAAAgAAA/wABAACAAAD/gAAAAIAAAP+AAAQAAAAAAoADgAALAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAGAAAAAgAAA/4AAAP6AAAAAAAAAAYAAAP6AAAAAgAAAAIAAAACAAAAAAAIAAAD/gAAAAIAAAP4AAAABAAAA/wACAACAAAD/gAEAAIAAAP+AAAAAgAAA/4AAAwAAAAACgAOAAAsADwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAACAAAD/gAAA/oAAAAEAAAD/gAAA/4AAAAGAAAAAAAIAAAD/gAAAAIAAAP4AAAABAAAA/wACgACAAAD/gP+AAYAAAP6AAAAAAQAAAAACgAOAABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAIAAAP+AAAAAgAAAAYAAAP8AAAABAAAA/wAAAAEAAAD+gAAA/4AAAAAAAoAAAP8AAAABAAAAAIAAAACAAAD/gAAA/wAAAP+AAAD/AAAA/4AAAAEAAAD/AAAAAAMAAAAAAoADgAALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAQAAAP8AAAACAAAA/4AAAACAAAD9gAAAAIAAAAAAAAACAAAAAAAAgAAAAIAAAACAAAD/gAAA/4AAAP+AAYABgAAA/oABgACAAAD/gAAAAAIAAAAAAoADgAAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAAEAAAAAgAAAAQAAAP4AAAABgAAA/oAAAAIAAAD+AAAAAIAAAAAAAoAAAACAAAD/gAAA/4AAAP+AAAD/gAAA/4AAAP+AAwAAgAAA/4AAAgAAAAACgAOAAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAQAAAACAAAABAAAA/gAAAAGAAAD+gAAAAgAAAP8AAAAAgAAAAAACgAAAAIAAAP+AAAD/gAAA/4AAAP+AAAD/gAAA/4ADAACAAAD/gAACAAAAAAKAA4AAEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAACAAAAAgAAAAIAAAACAAAD+AAAAAYAAAP6AAAACAAAA/oAAAACAAAAAAAKAAAAAgAAA/4AAAACAAAD/gAAA/4AAAP+AAAD/gAAA/4AAAP+AAwAAgAAA/4AAAwAAAAACgAOAAAsADwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAACgAAA/gAAAAGAAAD+gAAAAgAAAP4AAAAAgAAAAIAAAACAAAAAAAKAAAD/gAAA/4AAAP+AAAD/gAAA/4ADAACAAAD/gAAAAIAAAP+AAAAAAgCAAAACAAOAAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAIAAAP+AAAAAgAAAAIAAAACAAAD/gAAAAIAAAP6AAAAAgAAAAAAAgAAAAYAAAACAAAAAgAAA/4AAAP+AAAD+gAAA/4ADAACAAAD/gAACAIAAAAIAA4AADwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAAAgAAA/4AAAACAAAAAgAAAAIAAAP+AAAAAgAAA/4AAAACAAAAAAACAAAABgAAAAIAAAACAAAD/gAAA/4AAAP6AAAD/gAMAAIAAAP+AAAIAgAAAAgADgAAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAACAAAD/gAAAAIAAAACAAAAAgAAA/4AAAACAAAD/AAAAAIAAAAAAAIAAAAGAAAABAAAA/4AAAACAAAD/AAAA/oAAAP+AAwAAgAAA/4AAAwCAAAACAAOAAAsADwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAAAgAAA/4AAAAGAAAD/gAAAAIAAAP6AAAAAgAAAAIAAAACAAAAAAACAAAABgAAAAIAAAP+AAAD+gAAA/4ADAACAAAD/gAAAAIAAAP+AAAAABAAAAAACgAOAAAMABwALABsAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBgAAAAIAAAAAAAAAAgAAA/wAAAACAAAD+gAAA/4AAAACAAAABAAAA/4AAAACAAAD/gAAAAIAAAACAAIAAAP+AAIABgAAA/oABgACAAAD/gP2AAYAAAACAAAABgAAA/4AAAP8AAAD/gAAA/wAAAP+AAAYAAAAAAoADgAADAAsAEwAXABsAHwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAIAAAACAAAD/gAAAAIAAAACAAAD9gAAAAIAAAACAAAD/gAAAAIAAAAEAAAD+gAAAAIAAAAEAAAAAgAAAAQAAgAAA/4D/AACAAAAAgAAAAYAAAP2AAAADAAAA/wAAAP+AAAD+gAKAAIAAAP+AAIAAgAAA/4AAAACAAAD/gAAFAAAAAAKAA4AAAwAHAAsAEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD+AAAAAIAAAACAAAAAgAAA/oAAAACAAAAAAACAAAD/gACAAYAAAP6AAAABgAAA/oABgACAAAAAgAAA/4AAAP+AAQAAgAAA/4AAAAAFAAAAAAKAA4AAAwAHAAsAEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD+AAAAAIAAAACAAAAAgAAA/4AAAACAAAAAAACAAAD/gACAAYAAAP6AAAABgAAA/oABgACAAAAAgAAA/4AAAP+AAQAAgAAA/4AAAAAFAAAAAAKAA4AAAwAHAAsAEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD+AAAAAIAAAACAAAAAgAAA/wAAAACAAAAAAACAAAD/gACAAYAAAP6AAAABgAAA/oABgAEAAAD/gAAAAIAAAP8AAQAAgAAA/4AAAAAHAAAAAAKAA4AAAwAHAAsADwAVABkAHQAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAAAgAAA/YAAAACAAAAAAAAAAIAAAAEAAAD+gAAAAIAAAAEAAAAAgAAAAAAAgAAA/4AAgAGAAAD+gAAAAYAAAP6AAgAAgAAA/4D/gACAAAAAgAAA/wABAACAAAD/gAAAAIAAAP+AAAYAAAAAAoADgAADAAcACwAPABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAAAgAAA/gAAAAGAAAD+gAAAAIAAAACAAAAAgAAAAAAAgAAA/4AAgAGAAAD+gAAAAYAAAP6AAYAAgAAA/4ABAACAAAD/gAAAAIAAAP+AAAkAAACAAoADAAADAAcACwAPABMAFwAbAB8AIwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABgAAAAIAAAP4AAAAAgAAAAIAAAACAAAD/AAAAAIAAAP8AAAAAgAAAAIAAAACAAAD+AAAAAIAAAAGAAAAAgAAAAIAAgAAA/4AAAACAAAD/gACAAIAAAP+AAAAAgAAA/4AAgACAAAD/gACAAIAAAP+AAAAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAAAAAwAAAAACgAOAAAMAFwAbAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAACAAAD/AAAA/4AAAACAAAAAgAAAAIAAAACAAAAAgAAA/4AAAP+AAAD/gAAAAAAAAACAAAAAAACAAAD/gACAAIAAAACAAAABgAAA/wAAAAEAAAD/gAAA/4AAAP6AAAABAAAA/wACgACAAAD/gAAAAAUAAAAAAoADgAADAAcACwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAAAgAAA/oAAAACAAAD/AAAAAIAAAAAAAIAAAP+AAIACAAAA/gAAAAIAAAD+AAIAAIAAAP+AAIAAgAAA/4AAAAAFAAAAAAKAA4AAAwAHAAsADwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAABgAAAAIAAAP6AAAAAgAAAAAAAAACAAAAAAACAAAD/gACAAgAAAP4AAAACAAAA/gACAACAAAD/gACAAIAAAP+AAAAABgAAAAACgAOAAAMABwALAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD+AAAAAIAAAACAAAAAgAAA/wAAAACAAAAAAACAAAD/gACAAgAAAP4AAAACAAAA/gACAACAAAD/gAAAAIAAAP+AAIAAgAAA/4AABQAAAAACgAOAAAMABwALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD+AAAAAIAAAACAAAAAgAAAAAAAgAAA/4AAgAIAAAD+AAAAAgAAAP4AAoAAgAAA/4AAAACAAAD/gAAAAAcAAAAAAoADgAADAAcACwAPABMAFwAbAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAACAAAD/AAAAAIAAAACAAAAAgAAA/gAAAACAAAABgAAAAIAAAP6AAAAAgAAAAAAAAACAAAAAAAGAAAD+gAGAAIAAAP+AAAAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAIAAgAAA/4AAgACAAAD/gAAAAAIAAAAAAoADgAADAA8AAAEBAQEBAQEBAQEBAQEBAQECAAAAAIAAAP2AAAAAgAAAAYAAAP6AAAABgAAA/oAAAAGAAQAAAP8A/oADgAAA/4AAAP+AAAD/AAAA/4AAAP8AAAYAAAAAAoADAAADAAcACwAVABkAHQAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABAAAAAIAAAAAAAAAAgAAA/gAAAACAAAABAAAA/wAAAACAAAAAgAAAAIAAAP6AAAABAAAAAAAAgAAA/4AAAACAAAD/gACAAQAAAP8AAAACAAAA/4AAAP+AAAD/gAAA/4ABgACAAAD/gACAAIAAAP+AAAAABAAAAAACgAOAAAMADQAVABkAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAAAAAAAAYAAAP6AAAABgAAAAIAAAP4AAAAAgAAAAIAAAACAAAD+gAAAAIAAAACAAIAAAP+A/4AAgAAAAIAAAACAAAAAgAAA/gACAACAAAAAgAAA/4AAAP+AAQAAgAAA/4AAAAAEAAAAAAKAA4AAAwANABUAGQAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAAAAAABgAAA/oAAAAGAAAAAgAAA/gAAAACAAAAAgAAAAIAAAP+AAAAAgAAAAIAAgAAA/4D/gACAAAAAgAAAAIAAAACAAAD+AAIAAIAAAACAAAD/gAAA/4ABAACAAAD/gAAAAAQAAAAAAoADgAADAA0AFQAZAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAAAAAAGAAAD+gAAAAYAAAACAAAD+AAAAAIAAAACAAAAAgAAA/wAAAACAAAAAgACAAAD/gP+AAIAAAACAAAAAgAAAAIAAAP4AAgABAAAA/4AAAACAAAD/AAEAAIAAAP+AAAAABgAAAAACgAOAAAMADQARABcAGwAfAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAAAAAAGAAAD+gAAAAYAAAACAAAD9gAAAAIAAAAAAAAAAgAAAAQAAAP6AAAAAgAAAAQAAAACAAAAAgACAAAD/gP+AAIAAAACAAAAAgAAAAIAAAP4AAoAAgAAA/4D/gACAAAAAgAAA/wABAACAAAD/gAAAAIAAAP+AAAUAAAAAAoADgAADAA0AEQAVABkAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAAAAAAAAYAAAP6AAAABgAAAAIAAAP4AAAABgAAA/oAAAACAAAAAgAAAAIAAAACAAIAAAP+A/4AAgAAAAIAAAACAAAAAgAAA/gACAACAAAD/gAEAAIAAAP+AAAAAgAAA/4AABAAAAAACgAOAAAMADQARABUAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAAAAAABgAAA/oAAAAGAAAAAgAAA/wAAAP+AAAD/gAAAAYAAAACAAIAAAP+A/4AAgAAAAIAAAACAAAAAgAAA/gACgACAAAD/gP+AAYAAAP6AAAAAAwAAAAACgAKAABMAFwAbAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAAAgAAA/4AAAACAAAAAgAAAAIAAAACAAAD/AAAAAQAAAP2AAAABAAAAAIAAAACAAAAAAAEAAAD/gAAAAIAAAACAAAAAgAAA/4AAAACAAAD/AAAA/4AAAP+AAgAAgAAA/4AAAACAAAD/gAAAAAMAAAAAAgADAAAJAA0AEQAAAQEBAQEBAQEBAQEBAQEBAQEBAAAAAAEAAAD/gAAAAYAAAP+AAAD+gAAAAIAAAAAAAAABgAAAAAAAgAAAAIAAAACAAAD/gAAA/wABgAEAAAD/AAEAAIAAAP+AAAQAAAAAAoADgAADAA0AFQAZAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAABgAAAAIAAAP4AAAAAAAAAAIAAAACAAAAAgAAA/oAAAACAAAAAAACAAAD/gACAAYAAAP+AAAAAgAAA/wAAAP+AAYAAgAAAAIAAAP+AAAD/gAEAAIAAAP+AAAAABAAAAAACgAOAAAMADQAVABkAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAAAgAAA/gAAAAAAAAAAgAAAAIAAAACAAAD/gAAAAIAAAAAAAIAAAP+AAIABgAAA/4AAAACAAAD/AAAA/4ABgACAAAAAgAAA/4AAAP+AAQAAgAAA/4AAAAAEAAAAAAKAA4AAAwANABUAGQAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD+AAAAAAAAAACAAAAAgAAAAIAAAP8AAAAAgAAAAAAAgAAA/4AAgAGAAAD/gAAAAIAAAP8AAAD/gAGAAQAAAP+AAAAAgAAA/wABAACAAAD/gAAAAAUAAAAAAoADgAADAA0AEQAVABkAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAAAgAAA/gAAAAAAAAABgAAA/oAAAACAAAAAgAAAAIAAAAAAAIAAAP+AAIABgAAA/4AAAACAAAD/AAAA/4ABgACAAAD/gAEAAIAAAP+AAAAAgAAA/4AAAwCAAAACAAOAAAkADQARAAABAQEBAQEBAQEBAQEBAQEBAQEAgAAAAIAAAP+AAAABAAAAAIAAAP8AAAAAgAAA/wAAAACAAAAAAACAAAABAAAAAIAAAP6AAAD/gAKAAIAAAP+AAIAAgAAA/4AAAwCAAAACAAOAAAkADQARAAABAQEBAQEBAQEBAQEBAQEBAQEAgAAAAIAAAP+AAAABAAAAAIAAAP8AAAAAgAAAAAAAAACAAAAAAACAAAABAAAAAIAAAP6AAAD/gAKAAIAAAP+AAIAAgAAA/4AABACAAAACAAOAAAkADQARABUAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAIAAAP+AAAABAAAAAIAAAP6AAAAAgAAAAIAAAACAAAD/AAAAAIAAAAAAAIAAAAEAAAAAgAAA/oAAAP+AAoAAgAAA/4AAAACAAAD/gACAAIAAAP+AAAAAAwCAAAACAAOAAAkADQARAAABAQEBAQEBAQEBAQEBAQEBAQEAgAAAAIAAAP+AAAABAAAAAIAAAP6AAAAAgAAAAIAAAACAAAAAAACAAAABAAAAAIAAAP6AAAD/gAMAAIAAAP+AAAAAgAAA/4AAAwAAAAACgAOAAAMABwAZAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAAAAAACAAAD/gAAAAQAAAP+AAAAAgAAA/4AAAACAAAAAgAAAAIAAAP+AAAAAgAEAAAD/AAEAAIAAAP+A/oAAgAAAAIAAAACAAAABAAAAAIAAAACAAAD/gAAA/4AAAP2AAAcAAAAAAoADgAADAAsADwATABcAGwAfAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQIAAAAAgAAA/YAAAACAAAAAgAAA/4AAAACAAAABAAAA/gAAAACAAAAAgAAAAQAAAP6AAAAAgAAAAQAAAACAAAAAAAGAAAD+gAAAAgAAAP+AAAD/gAAA/wABgACAAAD/gAEAAIAAAP+AAAAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAAAABgAAAAACgAOAAAMABwALAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD+AAAAAYAAAP8AAAAAgAAA/wAAAACAAAAAAACAAAD/gACAAQAAAP8AAAABAAAA/wABAACAAAD/gAEAAIAAAP+AAIAAgAAA/4AABgAAAAACgAOAAAMABwALAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD+AAAAAYAAAP8AAAAAgAAAAAAAAACAAAAAAACAAAD/gACAAQAAAP8AAAABAAAA/wABAACAAAD/gAEAAIAAAP+AAIAAgAAA/4AABwAAAAACgAOAAAMABwALAA8AEwAXABsAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD+AAAAAYAAAP6AAAAAgAAAAIAAAACAAAD/AAAAAIAAAAAAAIAAAP+AAIABAAAA/wAAAAEAAAD/AAEAAIAAAP+AAQAAgAAA/4AAAACAAAD/gACAAIAAAP+AAAAACAAAAAACgAOAAAMABwALAA8AEwAXABsAHwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD+AAAAAYAAAP4AAAAAgAAAAIAAAAEAAAD+gAAAAIAAAAEAAAAAgAAAAAAAgAAA/4AAgAEAAAD/AAAAAQAAAP8AAQAAgAAA/4ABAACAAAD/gAAAAIAAAP+AAIAAgAAA/4AAAACAAAD/gAAGAAAAAAKAA4AAAwAHAAsADwATABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAABgAAAAIAAAP4AAAABgAAA/oAAAACAAAAAgAAAAIAAAAAAAIAAAP+AAIABAAAA/wAAAAEAAAD/AAEAAIAAAP+AAYAAgAAA/4AAAACAAAD/gAADAAAAgAKAAwAAAwAHAAsAAAEBAQEBAQEBAQEBAQEAAAAAgAAA/oAAAAKAAAD+gAAAAIAAAACAAIAAAP+AAQAAgAAA/4ABAACAAAD/gAAAAAMAAAAAAoACgAADABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAACAAAD+gAAAAIAAAACAAAAAgAAAAQAAAP+AAAD/gAAA/4AAAAAAAAAAgAAAAAAAgAAA/4AAgACAAAABAAAA/4AAAACAAAD/gAAA/wAAAACAAAD/gAGAAIAAAP+AAAAABQAAAAACgAOAAAMABwAPABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAEAAAD+gAAAAIAAAAGAAAD/gAAAAIAAAACAAAD+gAAAAIAAAP8AAAAAgAAAAAAAgAAA/4AAgAGAAAD+gP+AAIAAAACAAAABAAAA/gACgACAAAD/gACAAIAAAP+AAAAABQAAAAACgAOAAAMABwAPABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAEAAAD+gAAAAIAAAAGAAAD/gAAAAIAAAACAAAD+gAAAAIAAAAAAAAAAgAAAAAAAgAAA/4AAgAGAAAD+gP+AAIAAAACAAAABAAAA/gACgACAAAD/gACAAIAAAP+AAAAABgAAAAACgAOAAAMABwAPABMAFwAbAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAEAAAD+gAAAAIAAAAGAAAD/gAAAAIAAAACAAAD+AAAAAIAAAACAAAAAgAAA/wAAAACAAAAAAACAAAD/gACAAYAAAP6A/4AAgAAAAIAAAAEAAAD+AAKAAIAAAP+AAAAAgAAA/4AAgACAAAD/gAAFAAAAAAKAA4AAAwAHAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAQAAAP6AAAAAgAAAAYAAAP+AAAAAgAAAAIAAAP4AAAAAgAAAAIAAAACAAAAAAACAAAD/gACAAYAAAP6A/4AAgAAAAIAAAAEAAAD+AAMAAIAAAP+AAAAAgAAA/4AAAAAHAAAAAAKAA4AAAwAJAA0AEQAVABkAHQAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAAEAAAAAAAAAAQAAAP+AAAD/AAAAAIAAAP8AAAAAgAAAAYAAAACAAAD+gAAAAIAAAAAAAAAAgAAAAAAAgAAA/4AAgAEAAAD/gAAA/4ABAACAAAD/gACAAIAAAP+A/4ABAAAA/wABAACAAAD/gACAAIAAAP+AAAIAAAAAAoADAAADAA8AAAEBAQEBAQEBAQEBAQEBAQECAAAAAIAAAP2AAAAAgAAAAYAAAP6AAAABgAAA/oAAAAGAAIAAAP+A/oADAAAA/4AAAP+AAAD/gAAA/4AAAP8AAAcAAAAAAoADgAADAAkADQARABUAGQAdAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAQAAAAAAAAABAAAA/4AAAP8AAAAAgAAA/wAAAACAAAABgAAAAIAAAP4AAAAAgAAAAIAAAACAAAAAAACAAAD/gACAAQAAAP+AAAD/gAEAAIAAAP+AAIAAgAAA/4D/gAEAAAD/AAGAAIAAAP+AAAAAgAAA/4AABAAAAAACgAOAAAsADwATABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAACAAAD/gAAA/oAAAAAAAAABgAAA/gAAAACAAAABgAAAAIAAAAAAAgAAAP+AAAAAgAAA/gAAAAEAAAD/AAIAAQAAAP8AAQAAgAAA/4AAAACAAAD/gAAFAAAAAAKAA4AAAwANABEAFQAZAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAAAAAAGAAAD+gAAAAYAAAACAAAD+AAAAAYAAAP4AAAAAgAAAAYAAAACAAAAAgACAAAD/gP+AAIAAAACAAAAAgAAAAIAAAP4AAgABAAAA/wABAACAAAD/gAAAAIAAAP+AAAMAAAAAAoADgAAFABEAFQAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQGAAAAAgAAAAIAAAP2AAAAAgAAAAYAAAACAAAD/gAAA/oAAAAAAAAABgAAAAAABAAAA/4AAAP+AAQACAAAA/4AAAACAAAD+AAAAAQAAAP8AAgAAgAAA/4AAAwAAAAACgAOAAAMAEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAEAAAD/AAAAAYAAAP6AAAABgAAAAIAAAP+AAAAAgAAA/gAAAAGAAAABgACAAAD/gP6AAQAAAACAAAAAgAAAAIAAAACAAAD+AAAA/4AAAP+AAwAAgAAA/4AAAAAEAAAAAAKAA4AAAwAHAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAgAAAP2AAAAAgAAAAAAAAACAAAAAgAAAAQAAAP8AAAAAgAAAAAAAgAAA/4AAgAGAAAD+gAGAAIAAAACAAAD/gAAA/4ABAACAAAD/gAAFAAAAAAIAA4AAAwAHAAsADwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAAAAAAAAYAAAP8AAAAAgAAAAAAAAACAAAAAAACAAAD/gACAAQAAAP8AAQAAgAAA/4ABAACAAAD/gACAAIAAAP+AAAAABQAAAAACgAOAAAMABwAPABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAIAAAD9gAAAAIAAAAAAAAAAgAAAAIAAAAEAAAD+AAAAAIAAAACAAAAAgAAAAAAAgAAA/4AAgAGAAAD+gAGAAIAAAACAAAD/gAAA/4ABAACAAAD/gAAAAIAAAP+AAAAABgAAAAACAAOAAAMABwALAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAAAAAAGAAAD/AAAAAIAAAP8AAAAAgAAAAIAAAACAAAAAAACAAAD/gACAAQAAAP8AAQAAgAAA/4ABAACAAAD/gACAAIAAAP+AAAAAgAAA/4AABAAAAAACgAOAAAMADwATABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQIAAAAAgAAA/YAAAAEAAAAAgAAAAIAAAP6AAAABgAAA/oAAAACAAAAAgAAAAIAAAACAAYAAAP6A/4ACgAAAAIAAAP+AAAD/gAAA/oAAAP+AAwAAgAAA/4AAAACAAAD/gAADAAAAAAKAA4AAAwANABEAAAEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAAAAAACAAAD/gAAAAIAAAACAAAAAgAAAAIAAAACAAQAAAP8A/4AAgAAAAQAAAACAAAABgAAA/IACgAEAAAD/AAADAAAAAAKAA4AAAwAHABkAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAAAAAAAAIAAAP+AAAABAAAA/4AAAACAAAD/gAAAAIAAAACAAAAAgAAA/4AAAACAAQAAAP8AAQAAgAAA/4D+gACAAAAAgAAAAIAAAAEAAAAAgAAAAIAAAP+AAAD/gAAA/YAAAQAAAAACgAOAABEAAAEBAQEBAQEBAQEBAQEBAQEBAQGAAAD+gAAAAoAAAP4AAAABgAAA/oAAAAIAAAD/gAAAAIAAAAAAAQAAAAKAAAD/gAAA/4AAAP+AAAD/gAAA/4AAAP+AAAD/gAADAAAAAAKAA4AABwARABUAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBgAAA/wAAAAGAAAAAgAAA/YAAAACAAAABgAAAAIAAAP4AAAAAAAAAAYAAAAAAAQAAAACAAAD/AAAA/4ABgAGAAAD/gAAAAIAAAP8AAAD/gAGAAIAAAP+AAAMAAAAAAoADgAAPABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAAEAAAAAgAAAAQAAAP4AAAABgAAA/oAAAAIAAAD+AAAAAIAAAACAAAAAgAAAAAACgAAAAIAAAP+AAAD/gAAA/4AAAP+AAAD/gAAA/4ADAACAAAD/gAAAAIAAAP+AAAAABQAAAAACgAOAAAMADQAVABkAHQAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAAAgAAA/gAAAAAAAAAAgAAAAIAAAACAAAD+gAAAAIAAAACAAAAAgAAAAAAAgAAA/4AAgAGAAAD/gAAAAIAAAP8AAAD/gAGAAIAAAACAAAD/gAAA/4ABAACAAAD/gAAAAIAAAP+AAAEAAAAAAoADgAANAAABAQEBAQEBAQEBAQEBAQCAAAD/gAAAAIAAAACAAAAAgAAA/4AAAAGAAAAAAAGAAAAAgAAAAYAAAP8AAAD/gAAA/oAAAP+AAAEAAAAAAYADgAARAAABAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAP+AAAAAgAAA/4AAAAEAAAAAgAAA/4AAAACAAAAAAACAAAABAAAAAIAAAAEAAAAAgAAA/wAAAP+AAAD+gAAA/4AABQAAAAACgAOAAAMACwATABcAGwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAgAAA/oAAAACAAAAAgAAA/4AAAAGAAAD/gAAAAIAAAACAAAD+gAAAAIAAAAAAAAAAgAAAAQAAgAAA/4D/AAKAAAD/gAAA/4AAAP6AAAAAgAAAAIAAAAGAAAD9gAKAAIAAAP+AAIAAgAAA/4AAAAAFAAAAAAKAA4AAAwALAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQECAAAAAIAAAP2AAAAAgAAAAIAAAP+AAAAAgAAAAQAAAP8AAAAAgAAAAAAAAACAAAAAAAGAAAD+gAAAAgAAAP+AAAD/gAAA/wABgACAAAD/gAEAAIAAAP+AAIAAgAAA/4AAAAAGAAAAAAKAA4AAAwALABMAFwAbAB8AAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAACAAAD+gAAAAIAAAACAAAD/gAAAAYAAAP+AAAAAgAAAAIAAAP6AAAAAgAAA/wAAAACAAAAAgAAAAIAAAAEAAIAAAP+A/wACgAAA/4AAAP+AAAD+gAAAAIAAAACAAAABgAAA/YACgACAAAD/gACAAIAAAP+AAAAAgAAA/4AABgAAAAACgAOAAAMACwAPABMAFwAbAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAgAAAACAAAD9gAAAAIAAAACAAAD/gAAAAIAAAAEAAAD/AAAAAIAAAP8AAAAAgAAAAIAAAACAAAAAAAGAAAD+gAAAAgAAAP+AAAD/gAAA/wABgACAAAD/gAEAAIAAAP+AAIAAgAAA/4AAAACAAAD/gAAHAAAAAAKAA4AAAwAHAAsADwAVABkAHQAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAAAgAAA/YAAAACAAAAAAAAAAQAAAACAAAD+gAAAAIAAAAEAAAAAgAAAAAAAgAAA/4AAgAGAAAD+gAAAAYAAAP6AAgAAgAAA/4D/gACAAAAAgAAA/wABAACAAAD/gAAAAIAAAP+AAAgAAAAAAoADgAADAAcACwAPABMAFwAbAB8AAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAAAgAAA/gAAAAGAAAD+AAAAAIAAAAEAAAAAgAAA/oAAAACAAAABAAAAAIAAAAAAAIAAAP+AAIABAAAA/wAAAAEAAAD/AAEAAIAAAP+AAQAAgAAA/4AAAACAAAD/gACAAIAAAP+AAAAAgAAA/4AAAgAAAAACgAOAAAMAEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAAAAAAAgAAA/4AAAAIAAAD/AAAAAQAAAP8AAAABAAAAAIACgAAA/YD/gACAAAACgAAAAIAAAP+AAAD/AAAA/4AAAP8AAAD/gAAGAAAAAAKAAoAAAwAHAAsAFQAZAB0AAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAAAgAAAAIAAAAEAAAD9gAAAAIAAAACAAAAAgAAAAIAAAACAAAD/AAAA/wAAAACAAAAAgAAAAIAAAAAAAIAAAP+AAAAAgAAA/4AAgAGAAAD+gAAAAYAAAP+AAAAAgAAA/wAAAP+AAYAAgAAA/4AAAACAAAD/gAAAAAUAAAAAAoADgAADAAcAFwAbAB8AAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAgAAAACAAAD/gAAAAIAAAP2AAAABAAAAAIAAAACAAAD+gAAAAYAAAP+AAAD/AAAAAAAAAACAAAAAgAAAAIAAAAAAAIAAAP+AAYAAgAAA/4D+gAKAAAAAgAAA/4AAAP+AAAD/gAAA/wAAAACAAAD/AAMAAIAAAP+AAAAAgAAA/4AAAAAFAIAAAAKAA4AABwALAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAIAAAACAAAD/gAAAAIAAAAEAAAD+gAAAAIAAAP8AAAAAgAAAAIAAAACAAAAAAAIAAAD/gAAA/4AAAP8AAYAAgAAA/4ABAACAAAD/gACAAIAAAP+AAAAAgAAA/4AAAAAGAAAAAAKAA4AAAwAHAAsADwAXABsAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAgAAAAAAAAAAgAAA/gAAAAGAAAD+AAAAAIAAAAAAAAAAgAAAAIAAAAEAAAD/AAAAAIAAAAAAAIAAAP+AAIAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAAAIAAAP+AAAD/gAEAAIAAAP+AAAYAAAAAAgADgAADAAcACwAPABcAGwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAABgAAAAAAAAACAAAD+gAAAAQAAAP6AAAAAgAAAAAAAAACAAAAAgAAAAIAAAP+AAAAAgAAAAAAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAA/4AAgACAAAAAgAAA/4AAAP+AAQAAgAAA/4AABwAAAAACgAOAAAMABwALAA8AFwAbAB8AAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAAIAAAAAAAAAAIAAAP4AAAABgAAA/gAAAACAAAAAAAAAAIAAAACAAAABAAAA/gAAAACAAAAAgAAAAIAAAAAAAIAAAP+AAIAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAAAIAAAP+AAAD/gAEAAIAAAP+AAAAAgAAA/4AAAAAHAAAAAAIAA4AAAwAHAAsADwAXABsAHwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAYAAAAAAAAAAgAAA/oAAAAEAAAD+gAAAAIAAAAAAAAAAgAAAAIAAAACAAAD+gAAAAIAAAACAAAAAgAAAAAAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAA/4AAgACAAAAAgAAA/4AAAP+AAQAAgAAA/4AAAACAAAD/gAAAAAMAAAAAAoADgAALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAA/wAAAAEAAAAAgAAAAQAAAP8AAAD/AAAAAIAAAACAAAAAgAAAAAACAAAAAIAAAACAAAD/gAAA/4AAAP4AAwAAgAAA/4AAAACAAAD/gAAAAAQAAAAAAoADgAADAAcAEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAIAAAAAAAAAAgAAA/oAAAP+AAAAAgAAAAIAAAACAAAD/gAAAAQAAAACAAAAAAACAAAD/gACAAIAAAP+AAAABgAAAAIAAAACAAAD/gAAA/4AAAP6AAgABAAAA/wAABQAAAAACgAOAAAMABwALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD/AAAA/4AAAP+AAAABgAAAAAAAgAAA/4AAgAGAAAD+gAAAAYAAAP6AAgAAgAAA/4D/gAGAAAD+gAAAAAUAAAAAAoADgAADAAcADwATABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAABAAAA/oAAAACAAAABgAAA/4AAAACAAAAAgAAA/wAAAP+AAAD/gAAAAYAAAAAAAIAAAP+AAIABgAAA/oD/gACAAAAAgAAAAQAAAP4AAoAAgAAA/4D/gAGAAAD+gAAAAAYAAAAAAoADgAADAAcACwAPABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAAAAAAAAIAAAP2AAAAAgAAAAQAAAACAAAD+gAAAAIAAAAEAAAAAgAAAAAAAgAAA/4AAgAIAAAD+AAAAAoAAAP2AAgAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAAcAAAAAAoADgAADAAcADwATABcAGwAfAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAABAAAA/oAAAACAAAABgAAA/4AAAACAAAAAgAAA/YAAAACAAAABAAAAAIAAAP6AAAAAgAAAAQAAAACAAAAAAACAAAD/gACAAYAAAP6A/4AAgAAAAIAAAAEAAAD+AAKAAIAAAP+AAAAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAAAABwAAAAACgAOAAAMABwALAA8AEwAXABsAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAIAAAP8AAAAAgAAAAIAAAACAAAD+AAAAAIAAAAGAAAAAgAAA/gAAAACAAAAAgAAAAIAAAAAAAYAAAP6AAYAAgAAA/4AAAACAAAD/gACAAIAAAP+AAAAAgAAA/4ABAACAAAD/gAAAAIAAAP+AAAAABAAAAAACgAOAAAcACwAXABsAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAACAAAABgAAA/oAAAACAAAAAAAAA/oAAAAEAAAAAgAAAAQAAAP+AAAD/gAAAAIAAAAAAAIAAAACAAAD/gAAA/4ABAACAAAD/gACAAIAAAACAAAAAgAAA/4AAAP+AAAD/gAGAAIAAAP+AAAQAgAAAAoADgAAHAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAIAAAACAAAABAAAA/wAAAP8AAAACAAAA/4AAAP8AAAAAgAAAAAAAAACAAAAAAACAAAAAgAAA/4AAAP+AAQAAgAAAAIAAAP+AAAD/gAGAAIAAAP+AAIAAgAAA/4AABAAAAAACgAOAAAcACwATABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAIAAAAGAAAD+gAAAAIAAAAAAAAD+gAAAAoAAAP+AAAD/AAAAAIAAAAAAAIAAAACAAAD/gAAA/4ABAACAAAD/gACAAIAAAACAAAD/gAAA/4ABgACAAAD/gAADAIAAAAKAA4AABwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAACAAAAAgAAAAQAAAP8AAAD/AAAAAgAAAP+AAAD/AAAAAIAAAAAAAIAAAACAAAD/gAAA/4ABAACAAAAAgAAA/4AAAP+AAgAAgAAA/4AAAAAFAAAAAAKAA4AABwALABcAGwAfAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAIAAAAGAAAD+gAAAAIAAAAAAAAD+gAAAAQAAAACAAAABAAAA/4AAAP6AAAAAgAAAAIAAAACAAAAAAACAAAAAgAAA/4AAAP+AAQAAgAAA/4AAgACAAAAAgAAAAIAAAP+AAAD/gAAA/4ABgACAAAD/gAAAAIAAAP+AAAAABQCAAAACgAOAAAcADwATABcAGwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAAAgAAAAIAAAAEAAAD/AAAA/wAAAAIAAAD/gAAA/wAAAACAAAD/AAAAAIAAAACAAAAAgAAAAAAAgAAAAIAAAP+AAAD/gAEAAIAAAACAAAD/gAAA/4ABgACAAAD/gACAAIAAAP+AAAAAgAAA/4AAAAACAAAAAAKAA4AAAwARAAABAQEBAQEBAQEBAQEBAQEBAQECAAAAAIAAAP2AAAACgAAA/4AAAP6AAAABgAAA/oAAAAGAAAAAgAEAAAD/AP+AA4AAAP8AAAAAgAAA/wAAAP+AAAD/AAAA/4AAAAAFAAAAAAKAA4AAAwAHAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAAAAAAAAgAAA/YAAAACAAAABgAAA/oAAAAAAAAABAAAAAAAAAACAAAAAAACAAAD/gACAAQAAAP8AAAACAAAA/4AAAP+AAAD/AAIAAIAAAP+AAIAAgAAA/4AAAAACAAAAAAKAA4AAAwANAAABAQEBAQEBAQEBAQEBAQIAAAAAgAAA/YAAAACAAAABgAAA/oAAAAGAAAAAgAEAAAD/AP+AA4AAAP6AAAD/gAAA/wAAAP+AAAAAAgAAAAACgAKAAAMADQAAAQEBAQEBAQEBAQEBAQECAAAAAIAAAP2AAAAAgAAAAYAAAP6AAAABgAAAAIAAgAAA/4D/gAKAAAD/AAAA/4AAAP+AAAD/gAAAAAQAAAAAAoADgAADAAcACwAbAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAYAAAACAAAAAAAAAAIAAAP8AAAAAgAAA/oAAAP+AAAAAgAAAAQAAAP+AAAAAgAAA/4AAAACAAAAAgACAAAD/gACAAYAAAP6AAYAAgAAA/4D9gAGAAAAAgAAAAYAAAP+AAAD/AAAA/4AAAP8AAAD/gAABAAAAAAKAA4AACwAAAQEBAQEBAQEBAQEBAAAAAAIAAAD+AAAAAgAAAP4AAAACgAAAAAAAgAAAAQAAAACAAAABAAAAAIAAAPyAAAAAAwCAAAACgAKAAAMABwALAAABAQEBAQEBAQEBAQEBAAAAAQAAAAAAAAAAgAAA/gAAAACAAAAAAACAAAD/gACAAIAAAP+AAAACAAAA/gAAAAABAIAAAAIAA4AAEQAAAQEBAQEBAQEBAQEBAQEBAQEBAIAAAACAAAD/gAAAAIAAAP+AAAABAAAAAIAAAP+AAAAAgAAAAAAAgAAAAQAAAACAAAABAAAAAIAAAP8AAAD/gAAA/oAAAP+AAAMAAAAAAoADgAADAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD/gAAA/oAAAAAAAAABgAAAAAAAgAAA/4AAgAKAAAD/AAAAAQAAAP2AAAABAAAA/wACgACAAAD/gAAAAAUAAAAAAoADgAAHAAsADwATABsAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAGAAAAAgAAA/gAAAACAAAAAAAAAAIAAAP8AAAAAgAAA/wAAAAKAAAD/gAAA/oAAAAAAAQAAAP+AAAAAgAAA/wABAACAAAD/gACAAIAAAP+AAIAAgAAA/4AAgAEAAAD/AAAAAIAAAP+AAAAAAQEAAAABgAOAAAMAAAEBAQEBAAAAAIAAAAAAA4AAAPyAAAAAAgCAAAACAAOAAAMABwAAAQEBAQEBAQEAgAAAAIAAAACAAAAAgAAAAAADgAAA/IAAAAOAAAD8gAACAQAAAAGAA4AAAwAHAAABAQEBAQEBAQEAAAAAgAAA/4AAAACAAAAAAACAAAD/gAEAAoAAAP2AAAQAAAAAAoADgAALAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAGAAAAAgAAA/4AAAP6AAAAAAAAAAYAAAP4AAAAAgAAAAYAAAACAAAAAAAIAAAD/gAAAAIAAAP4AAAABAAAA/wACAAEAAAD/AAEAAIAAAP+AAAAAgAAA/4AABQAAAAACgAOAAAMADQARABUAGQAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAAAAAABgAAA/oAAAAGAAAAAgAAA/gAAAAGAAAD+AAAAAIAAAAGAAAAAgAAAAIAAgAAA/4D/gACAAAAAgAAAAIAAAACAAAD+AAIAAQAAAP8AAQAAgAAA/4AAAACAAAD/gAADAAAAAAKAA4AACwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABgAAAAIAAAP+AAAD+gAAAAQAAAP+AAAD/gAAAAYAAAAAAAgAAAP+AAAAAgAAA/gAAAAEAAAD/AAKAAIAAAP+A/4ABgAAA/oAAAAACAAAAAAKAA4AADQAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAA/4AAAACAAAAAgAAAAIAAAAEAAAD+gAAAAIAAAP8AAAABgAAAAIAAAP+AAAAAAACAAAACAAAA/oAAAAEAAAD/AAAA/4AAAP+AAgAAgAAAAIAAAACAAAD/AAAA/4AAAQAAAAACgAOAAA0AAAEBAQEBAQEBAQEBAQEBAIAAAP+AAAAAgAAAAIAAAACAAAD/gAAAAYAAAAAAAYAAAACAAAABgAAA/wAAAP+AAAD+gAAA/4AABQAAAAACgAOAAAMABwALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAGAAAAAgAAA/gAAAACAAAAAgAAAAIAAAP8AAAAAgAAAAAACAAAA/gAAAAIAAAD+AAIAAQAAAP8AAAABAAAA/wABAACAAAD/gAAAAAIAAAAAAoADgAALAA8AAAEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAGAAAAAgAAA/4AAAP6AAAAAAAAAAYAAAAAAAwAAAP8AAAABAAAA/QAAAAGAAAD+gAMAAIAAAP+AAAMAAAAAAoADgAADAAcAEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQECAAAAAIAAAP+AAAAAgAAA/YAAAAIAAAD+gAAAAYAAAP6AAAABgAAAAIABAAAA/wABgAEAAAD/AP4AA4AAAP+AAAD/AAAA/4AAAP8AAAD/gAAAAAEAAAAAAoADgAAJAAABAQEBAQEBAQEBAIAAAP+AAAACgAAA/4AAAP8AAAAAAAMAAAAAgAAA/wAAAACAAAD9AAADAAAAAAKAAwAAAwAHABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAACAAAAAAAAAAIAAAP6AAAAAgAAAAYAAAP+AAAAAgAAAAIAAAAEAAIAAAP+AAIAAgAAA/4D+gAEAAAD/gAAAAYAAAACAAAAAgAAA/QAAAAABAAAAAAKAA4AACwAAAQEBAQEBAQEBAQEBAAAAAAKAAAD+AAAAAYAAAP6AAAACAAAAAAADgAAA/4AAAP8AAAD/gAAA/wAAAP+AAAAABQAAAAACgAOAAAUACQANABEAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAACAAAA/gAAAACAAAAAAAAAAIAAAAAAAAAAgAAAAAAAAP4AAAACgAAAAAABAAAA/4AAAP+AAQAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAAAIAAAP8AAAAAAQAAAAACgAOAAAsAAAEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAACAAAD/gAAA/oAAAAAAA4AAAP6AAAABgAAA/IAAAAGAAAD+gAAAAAMAAAAAAoADgAADAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD/gAAA/oAAAAAAAAABgAAAAAAAgAAA/4AAgAKAAAD/AAAAAQAAAP2AAAABAAAA/wACgACAAAD/gAAAAAEAgAAAAgADgAALAAABAQEBAQEBAQEBAQEAgAAAAIAAAP+AAAABgAAA/4AAAACAAAAAAACAAAACgAAAAIAAAP+AAAD9gAAA/4AAAAAHAAAAAAKAA4AAAwAHAAsADwATABsAHwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQECAAAAAIAAAP8AAAAAgAAA/wAAAACAAAD/gAAAAIAAAAAAAAAAgAAA/gAAAACAAAAAgAAA/4AAAAGAAAAAgAAAAAAAgAAA/4AAgACAAAD/gACAAIAAAP+AAQAAgAAA/4AAgACAAAD/gP2AA4AAAP6AAAD/gAAA/oADAACAAAD/gAAAAAUAAAAAAoADgAADAAcACwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABgAAAAIAAAP4AAAAAgAAAAIAAAACAAAD/AAAAAIAAAAAAAgAAAP4AAAACAAAA/gACAAEAAAD/AAAAAQAAAP8AAQAAgAAA/4AAAAADAAAAAAKAA4AAAwALABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAACAAAD+gAAAAIAAAACAAAD/gAAAAYAAAP+AAAAAgAAAAIAAAAGAAQAAAP8A/oADgAAA/4AAAP+AAAD9gAAAAoAAAACAAAAAgAAA/IAAAAADAAAAAAKAA4AAAwALABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAACAAAD+gAAAAIAAAACAAAD/gAAAAYAAAP+AAAAAgAAAAIAAAAGAAIAAAP+A/oADgAAA/wAAAP+AAAD+AAAAAQAAAACAAAACAAAA/IAAAAADAAAAAAKAA4AABwALABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABgAAAAIAAAP4AAAABgAAA/gAAAAKAAAD/gAAA/oAAAAAAAQAAAP+AAAAAgAAA/wABgACAAAD/gAEAAQAAAP8AAAAAgAAA/4AAAAAEAAAAAAKAA4AAAwAHAAsADwAAAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAABgAAAAIAAAP4AAAABgAAAAAAAgAAA/4AAgAKAAAD9gAAAAoAAAP2AAoAAgAAA/4AAAQAAAAACgAOAAAsAAAEBAQEBAQEBAQEBAQCAAAD/gAAAAoAAAP+AAAD/gAAA/4AAAAAAAwAAAACAAAD/gAAA/QAAAAMAAAD9AAAAAAIAAAAAAoADgAADAA0AAAEBAQEBAQEBAQEBAQEBAgAAAACAAAD9gAAAAgAAAP6AAAABgAAA/oAAAAIAAQAAAP8A/gADgAAA/4AAAP8AAAD/gAAA/oAAAAAFAAAAAAKAA4AABwALAA8AEwAbAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABgAAAAIAAAP4AAAAAgAAAAAAAAACAAAD/AAAAAIAAAP8AAAACgAAA/4AAAP6AAAAAAAEAAAD/gAAAAIAAAP8AAQAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIABAAAA/wAAAACAAAD/gAAAAAEAAAAAAoADgAAHAAABAQEBAQEBAQEAAAD/AAAAAoAAAP8AAAAAAAMAAAAAgAAA/4AAAP0AAAAABQAAAAACgAOAAAMABwALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAIAAAP8AAAAAgAAAAIAAAACAAAD+AAAAAIAAAAGAAAAAgAAAAAABgAAA/oABgACAAAD/gAAAAIAAAP+AAIABgAAA/oAAAAGAAAD+gAAAAAMAAAAAAoADgAADAAcAGwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAACAAAD+gAAA/4AAAACAAAD/gAAAAIAAAACAAAAAgAAA/4AAAACAAAD/gAAAAQABgAAA/oAAAAGAAAD+gP8AAIAAAACAAAABgAAAAIAAAACAAAD/gAAA/4AAAP6AAAD/gAAA/4AAAAAJAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAACAAAD+AAAAAIAAAACAAAAAgAAA/wAAAACAAAD/AAAAAIAAAACAAAAAgAAA/gAAAACAAAABgAAAAIAAAAAAAQAAAP8AAAABAAAA/wABAACAAAD/gAAAAIAAAP+AAIAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAIABAAAA/wAAAAEAAAD/AAAAAAMAAAAAAoADgAADAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAACAAAD/gAAAAIAAAACAAAAAgAAA/4AAAACAAAAAgAAAAgABgAAA/oD+AAGAAAAAgAAAAYAAAP6AAAD/gAAA/oACAAGAAAD+gAAAAAUAAAAAAoADgAAFAAsADwATABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAIAAAACAAAAAgAAAAIAAAP2AAAAAgAAAAYAAAACAAAD+AAAAAYAAAAAAAIAAAAEAAAD+gAAAAYAAAP8AAAD/gAGAAYAAAP6AAAABgAAA/oABgACAAAD/gAAAAAYAAAAAAoACgAADAAcACwAPABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAEAAAAAgAAAAIAAAP2AAAAAgAAAAQAAAACAAAD+gAAAAQAAAACAAAAAgAAAAAAAgAAA/4AAAACAAAD/gACAAYAAAP6AAAABgAAA/oABgACAAAD/gAAAAIAAAP+AAAYAAAAAAoADAAADAAcACwAVABkAHQAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABAAAAAIAAAAAAAAAAgAAA/gAAAACAAAABAAAA/wAAAACAAAAAgAAAAIAAAP6AAAABAAAAAAAAgAAA/4AAAACAAAD/gACAAQAAAP8AAAACAAAA/4AAAP+AAAD/gAAA/4ABgACAAAD/gACAAIAAAP+AAAAAAwAAAAACgAKAAAUACQANAAABAQEBAQEBAQEBAQEBAQEAAAABAAAA/4AAAP6AAAABAAAAAQAAAACAAAAAAAIAAAD/gAAA/oACAACAAAD/gAAAAIAAAP+AAAUAAAAAAgADAAADAAcACwARABUAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAQAAAP6AAAAAgAAAAQAAAACAAAD+gAAAAIAAAACAAAD/gAAAAQAAAAAAAIAAAP+AAIABAAAA/wAAAAEAAAD/AAEAAQAAAP+AAAD/gAEAAIAAAP+AAAUAAAAAAgACgAADAAcACwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAAAAAABgAAA/gAAAACAAAAAAAAAAYAAAAAAAIAAAP+AAIAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAA/4AAAAAJAAAAAAKAAwAAAwAHAAsADwATABcAGwAfACMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAABAAAA/oAAAACAAAAAAAAAAIAAAP6AAAAAgAAAAQAAAACAAAD+gAAAAIAAAAEAAAAAgAAA/YAAAACAAAAAgAAAAQAAAAAAAIAAAP+AAIAAgAAA/4AAgACAAAD/gACAAIAAAP+AAAAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAIAAgAAA/4AAAACAAAD/gAAAAAQAAAAAAoADAAADAAcACwAPAAABAQEBAQEBAQEBAQEBAQEBAIAAAACAAAABAAAAAIAAAP2AAAAAgAAAAIAAAAEAAAAAgAIAAAD+AP+AAoAAAP2AAoAAgAAA/4AAAACAAAD/gAADAAAAAAIAAwAAAwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAEAAAD+gAAAAIAAAAEAAAAAgAAA/4AAAP8AAAAAAAAAAQAAAAAAAIAAAP+AAIACAAAA/4AAAACAAAD+AAAAAQAAAP8AAgAAgAAA/4AAAAADAIAAAAKAAoAAAwAHAAsAAAEBAQEBAQEBAQEBAQEAAAABAAAAAAAAAACAAAD+AAAAAIAAAAAAAIAAAP+AAIAAgAAA/4AAAAIAAAD+AAAAAAUAgAAAAoACgAADAAcACwATABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQIAAAAAgAAA/wAAAACAAAD/gAAAAIAAAP6AAAAAgAAAAIAAAP+AAAABAAAAAIAAAAAAAIAAAP+AAIAAgAAA/4ABAACAAAD/gP6AAoAAAP8AAAD/gAAA/wACAACAAAD/gAAAAAYAAAAAAoADAAADAAcACwAPABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABgAAAAIAAAP4AAAAAgAAAAIAAAACAAAD/AAAAAIAAAP6AAAABAAAAAAAAgAAA/4AAAAEAAAD/AACAAQAAAP8AAIAAgAAA/4AAgAEAAAD/AAEAAIAAAP+AAAMAAAAAAoACgAADAAsADwAAAQEBAQEBAQEBAQEBAQEBAQIAAAAAgAAA/YAAAACAAAABAAAA/wAAAAEAAAAAgAAAAQAAgAAA/4D/AAKAAAD/AAAA/4AAAP8AAYABAAAA/wAAAAAEAAAAAAKAAoAAAwAHAA0AEQAAAQEBAQEBAQEBAQEBAQEBAQEBAQAAAACAAAAAAAAAAIAAAP4AAAAAgAAAAIAAAAEAAAAAgAAAAIAAgAAA/4AAgACAAAD/gP8AAoAAAP4AAAD/gAGAAQAAAP8AAAAABgAAAAACgAOAAAMABwALAA8AEwAbAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAAAAAAAAIAAAP6AAAABAAAA/oAAAACAAAAAAAAAAYAAAP4AAAD/gAAAAoAAAP6AAAAAAACAAAD/gACAAIAAAP+AAIAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAAAIAAAP+AAAD/gAAEAAAAAAKAAoAAAwAHAAsADwAAAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAABgAAAAIAAAP4AAAABgAAAAAAAgAAA/4AAgAGAAAD+gAAAAYAAAP6AAYAAgAAA/4AAAgAAAAACgAKAAAMAEQAAAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABAAAA/4AAAP+AAAD/gAAAAoAAAP+AAAAAgAAAAAAAgAAA/4AAAAIAAAD+gAAAAYAAAACAAAD/gAAA/oAAAP+AAAAABAAAAAACgAMAAAMACwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAAAAAAAAIAAAAEAAAD/AAAAAQAAAACAAAD+gAAAAQAAAAAAAIAAAP+AAIACAAAA/wAAAP+AAAD/gAEAAQAAAP8AAQAAgAAA/4AABgAAAAACgAMAAAMABwALAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAQAAAAAAAAAAgAAA/oAAAAEAAAD+gAAAAIAAAAGAAAAAgAAA/gAAAAGAAAAAAACAAAD/gACAAIAAAP+AAIAAgAAA/4AAgAEAAAD/AACAAIAAAP+AAIAAgAAA/4AABgAAAAACgAOAAAMABwALAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAQAAAP6AAAAAgAAAAQAAAACAAAD+gAAAAQAAAAAAAAAAgAAAAAAAAACAAAAAAACAAAD/gACAAYAAAP6AAAABgAAA/oABgACAAAD/gACAAIAAAP+AAIAAgAAA/4AABAAAAAACgAKAAAMABwALABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAEAAAAAAAAAAIAAAP4AAAAAgAAAAAAAAP8AAAACgAAA/wAAAAAAAIAAAP+AAIAAgAAA/4AAAAEAAAD/AAEAAIAAAACAAAD/gAAA/4AAAwAAAAACgAKAAAMABwALAAABAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAAAAACAAAD/gACAAgAAAP4AAAACAAAA/gAAAAADAAAAAAKAAwAAAwAHABsAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAGAAAAAgAAA/oAAAP+AAAAAgAAA/4AAAACAAAAAgAAAAIAAAP+AAAAAgAAA/4AAAAGAAIAAAP+AAAAAgAAA/4D+gAEAAAAAgAAAAIAAAACAAAAAgAAA/4AAAP+AAAD/gAAA/4AAAP8AAAAABwAAAAACgAKAAAMABwALAA8AFwAbAB8AAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABAAAAAIAAAAAAAAAAgAAA/YAAAACAAAAAAAAAAIAAAAEAAAD/gAAA/wAAAACAAAABAAAAAIAAAAAAAIAAAP+AAAAAgAAA/4AAgACAAAD/gAEAAIAAAP+A/wAAgAAAAQAAAP+AAAD/AAGAAIAAAP+AAAAAgAAA/4AAAAADAAAAAAKAAwAAAwAHABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAgAAAACAAAD9gAAAAIAAAACAAAD/gAAAAIAAAACAAAAAgAAA/4AAAAGAAIAAAP+AAAABAAAA/wD+gAEAAAAAgAAAAYAAAP6AAAD/gAAA/wAAAAAHAAAAAAKAAoAAAwAHAAsADwATABcAGwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAAAgAAAAIAAAACAAAD/AAAAAIAAAP6AAAAAgAAAAYAAAACAAAD+AAAAAIAAAACAAAAAgAAAAAAAgAAA/4AAAACAAAD/gACAAQAAAP8AAAABgAAA/oAAAAGAAAD+gAGAAIAAAP+AAAAAgAAA/4AAAAADAAAAAAKAA4AAAwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAAAgAAA/4AAAP6AAAAAAAAAAYAAAAAAAIAAAP+AAIACgAAA/wAAAAEAAAD9gAAAAQAAAP8AAoAAgAAA/4AAAAACAAAAAAKAA4AAAwAPAAABAQEBAQEBAQEBAQEBAQEBAgAAAACAAAD9gAAAAIAAAAGAAAD+gAAAAYAAAP6AAAABgAEAAAD/AP6AA4AAAP+AAAD/gAAA/wAAAP+AAAD/AAACAAAAAAKAAwAAAwAPAAABAQEBAQEBAQEBAQEBAQEBAgAAAACAAAD9gAAAAIAAAAGAAAD+gAAAAYAAAP6AAAABgACAAAD/gP6AAwAAAP+AAAD/gAAA/4AAAP+AAAD/AAACAAAAAAKAA4AADwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAABAAAAAIAAAAEAAAD+AAAAAYAAAP6AAAACAAAA/gAAAACAAAAAAAKAAAAAgAAA/4AAAP+AAAD/gAAA/4AAAP+AAAD/gAMAAIAAAP+AAAMAAAAAAoADgAALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAoAAAP4AAAABgAAA/oAAAAIAAAD+AAAAAIAAAACAAAAAgAAAAAACgAAA/4AAAP+AAAD/gAAA/4AAAP+AAwAAgAAA/4AAAACAAAD/gAAAAAcAAAAAAoADgAADAAcACwATABcAGwAfAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAABgAAA/gAAAACAAAABAAAAAIAAAP2AAAAAgAAAAQAAAP8AAAABAAAAAIAAAP6AAAAAgAAAAAAAAAGAAAAAAACAAAD/gACAAIAAAP+AAQAAgAAA/4D/gAGAAAD/gAAA/4AAAP+AAQAAgAAA/4AAgACAAAD/gACAAIAAAP+AAAAAAgAAAAACgAOAAAsADwAAAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAACAAAD/gAAA/oAAAAAAAAABgAAAAAADAAAA/wAAAAEAAAD9AAAAAYAAAP6AAwAAgAAA/4AAAgAAAAACgAOAAAMAEQAAAQEBAQEBAQEBAQEBAQEBAQEBAgAAAACAAAD9gAAAAoAAAP+AAAD+gAAAAYAAAP6AAAABgAAAAIABAAAA/wD/gAOAAAD/AAAAAIAAAP8AAAD/gAAA/wAAAP+AAAAAAwAAAAACgAOAAAMABwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQIAAAAAgAAA/4AAAACAAAD9gAAAAgAAAP6AAAABgAAA/oAAAAGAAAAAgAEAAAD/AAGAAQAAAP8A/gADgAAA/4AAAP8AAAD/gAAA/wAAAP+AAAAAAQAAAAACgAOAAAkAAAEBAQEBAQEBAQEAgAAA/4AAAAKAAAD/gAAA/wAAAAAAAwAAAACAAAD/AAAAAIAAAP0AAAEAAAAAAoADgAAVAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABAAAA/4AAAP+AAAD/gAAAAoAAAP+AAAAAgAAA/4AAAP6AAAAAAAGAAAD/gAAAAgAAAP6AAAABgAAAAIAAAP+AAAD+AAAA/wAAAACAAAD/gAABAAAAAAKAA4AACwAAAQEBAQEBAQEBAQEBAAAAAAKAAAD+AAAAAYAAAP6AAAACAAAAAAADgAAA/4AAAP8AAAD/gAAA/wAAAP+AAAAABQAAAAACgAOAAAMABwALABcAGwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAACAAAD9gAAAAIAAAACAAAD/gAAAAIAAAACAAAAAgAAA/4AAAACAAAAAgAAAAAABgAAA/oAAAAGAAAD+gAIAAYAAAP6A/gABgAAAAIAAAAGAAAD+gAAA/4AAAP6AAgABgAAA/oAAAAAFAAAAAAKAA4AAAwAHAAsADwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAACAAAAAAAAAACAAAD+AAAAAYAAAAAAAAAAgAAA/YAAAAIAAAAAAACAAAD/gACAAQAAAP8AAQAAgAAA/4AAgAEAAAD/AAEAAIAAAP+AAAAAAwAAAAACgAOAAAMACwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAgAAA/oAAAACAAAAAgAAA/4AAAAGAAAD/gAAAAIAAAACAAAABgACAAAD/gP6AA4AAAP4AAAD/gAAA/wAAAAIAAAAAgAAAAQAAAPyAAAAABAAAAAACgAOAAAMACwATABsAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAIAAAP6AAAAAgAAAAIAAAP+AAAABgAAA/4AAAACAAAAAgAAA/gAAAACAAAAAgAAAAIAAAAEAAIAAAP+A/wACgAAA/oAAAP+AAAD/gAAAAYAAAACAAAAAgAAA/YACgAEAAAD/gAAAAIAAAP8AAAcAAAAAAoADgAADAAcACwAPABMAGwAfAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQIAAAAAgAAA/wAAAACAAAD/AAAAAIAAAP+AAAAAgAAAAAAAAACAAAD+AAAAAIAAAACAAAD/gAAAAYAAAACAAAAAAACAAAD/gACAAIAAAP+AAIAAgAAA/4ABAACAAAD/gACAAIAAAP+A/YADgAAA/oAAAP+AAAD+gAMAAIAAAP+AAAAAAgAAAAACgAOAAAMAEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAACAAAAAgAAA/4AAAP+AAAD/gAAAAoAAAP+AAAAAgAAAAAAAgAAA/4AAAACAAAACgAAA/YAAAAKAAAAAgAAA/4AAAP2AAAD/gAADAAAAAAKAA4AAAwALABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAACAAAD+gAAAAIAAAACAAAD/gAAAAYAAAP+AAAAAgAAAAIAAAAGAAQAAAP8A/oADgAAA/4AAAP+AAAD9gAAAAoAAAACAAAAAgAAA/IAAAAABAAAAAAKAA4AACwAAAQEBAQEBAQEBAQEBAAAAAACAAAABgAAAAIAAAP+AAAD+gAAAAAADgAAA/oAAAAGAAAD8gAAAAYAAAP6AAAAABAAAAAACgAOAAAMABwALAA8AAAEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD+AAAAAYAAAAAAAIAAAP+AAIACgAAA/YAAAAKAAAD9gAKAAIAAAP+AAAEAAAAAAoADgAAHAAABAQEBAQEBAQAAAAACgAAA/4AAAP6AAAAAAAOAAAD8gAAAAwAAAP0AAAAAAgAAAAACgAOAAAMADQAAAQEBAQEBAQEBAQEBAQECAAAAAIAAAP2AAAACAAAA/oAAAAGAAAD+gAAAAgABAAAA/wD+AAOAAAD/gAAA/wAAAP+AAAD+gAAAAAUAAAAAAoADgAADAAcACwAPABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAAAAAAAAIAAAP2AAAAAgAAAAYAAAACAAAD+AAAAAYAAAAAAAIAAAP+AAIAAgAAA/4AAAAKAAAD9gAIAAIAAAP+AAIAAgAAA/4AAAAABAAAAAAKAA4AABwAAAQEBAQEBAQEBAAAA/wAAAAKAAAD/AAAAAAADAAAAAIAAAP+AAAD9AAAAAAcAAAAAAoADgAADAAcACwAPABMAFwAbAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAAAAAAAAIAAAAAAAAAAgAAA/wAAAACAAAAAgAAAAIAAAP4AAAAAgAAAAYAAAACAAAAAAACAAAD/gACAAIAAAP+AAIAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAIABgAAA/oAAAAGAAAD+gAAAAAMAAAAAAoADgAADAAcAIwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABgAAAAIAAAP4AAAAAgAAA/4AAAACAAAD/gAAAAIAAAP+AAAABgAAA/4AAAACAAAD/gAAAAIAAAP+AAAAAgAAAAYAAgAAA/4AAAACAAAD/gP6AAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAIAAAP+AAAD/gAAA/4AAAP+AAAD/gAAA/4AAAP+AAAAACQAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAGAAAAAgAAA/gAAAACAAAAAgAAAAIAAAP8AAAAAgAAA/wAAAACAAAAAgAAAAIAAAP4AAAAAgAAAAYAAAACAAAAAAAEAAAD/AAAAAQAAAP8AAQAAgAAA/4AAAACAAAD/gACAAIAAAP+AAIAAgAAA/4AAAACAAAD/gACAAQAAAP8AAAABAAAA/wAAAAABAAAAAAKAA4AACwAAAQEBAQEBAQEBAQEBAgAAAP4AAAAAgAAAAQAAAACAAAAAgAAAAAAAgAAAAwAAAP2AAAACgAAA/YAAAP8AAAAAAgAAAAACgAOAAAMACwAAAQEBAQEBAQEBAQEBAAAAAACAAAABgAAA/oAAAAGAAAAAgAAAAgABgAAA/oD+AAGAAAAAgAAAAYAAAPyAAAEAAAAAAoADgAALAAABAQEBAQEBAQEBAQEAAAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAOAAAD9AAAAAwAAAP0AAAADAAAA/IAAAAABAAAAAAKAA4AADQAAAQEBAQEBAQEBAQEBAQECAAAA/gAAAACAAAAAgAAAAIAAAACAAAAAgAAAAAAAgAAAAwAAAP2AAAACgAAA/YAAAAKAAAD8gAACAAAAAAKAA4AAAwARAAABAQEBAQEBAQEBAQEBAQEBAQECAAAAAIAAAP4AAAD/gAAAAYAAAP+AAAABAAAA/wAAAAEAAAAAgAEAAAD/AP+AAwAAAACAAAD/gAAA/wAAAP+AAAD/AAAA/4AAAAADAAAAAAKAA4AAAwANABEAAAEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAgAAA/oAAAACAAAAAgAAA/4AAAACAAAABAAAAAIAAAACAAYAAAP6A/4ADgAAA/wAAAP+AAAD+gAAA/4AAAAOAAAD8gAACAAAAAAKAA4AAAwANAAABAQEBAQEBAQEBAQEBAQIAAAAAgAAA/YAAAACAAAABgAAA/oAAAAGAAAAAgAEAAAD/AP+AA4AAAP6AAAD/gAAA/wAAAP+AAAAABwAAAAACgAOAAAMABwALAA8AFwAbAB8AAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAAGAAAAAAAAAAIAAAP4AAAAAgAAAAAAAAACAAAABAAAA/wAAAAEAAAAAgAAA/wAAAACAAAD+AAAAAYAAAAAAAIAAAP+AAIAAgAAA/4ABAACAAAD/gACAAIAAAP+A/wAAgAAAAIAAAACAAAD+gAGAAIAAAP+AAIAAgAAA/4AAAAAEAAAAAAKAA4AAAwAHABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAYAAAACAAAAAAAAAAIAAAP2AAAAAgAAAAIAAAACAAAD/gAAA/4AAAAEAAAAAgAAAAAAAgAAA/4AAgAKAAAD9gP+AA4AAAP6AAAABAAAA/YAAAAEAAAD+gAMAAIAAAP+AAAQAAAAAAoADgAADAAcACwAZAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAAAAAACAAAD/AAAAAIAAAAGAAAD/gAAA/4AAAP+AAAABgAAA/oAAAAIAAAAAAACAAAD/gACAAIAAAP+AAYABAAAA/wD+AAGAAAD/gAAAAIAAAACAAAABAAAAAIAAAPyAAAAAAwAAAAACgAKAAAMADQARAAABAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAAAAAABgAAA/oAAAAGAAAAAgAAA/gAAAAGAAAAAgACAAAD/gP+AAIAAAACAAAAAgAAAAIAAAP4AAgAAgAAA/4AABQAAAAACgAOAAAMABwAPABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAAAAAAAAIAAAP2AAAAAgAAAAYAAAP6AAAAAAAAAAQAAAAAAAAAAgAAAAAAAgAAA/4AAgAEAAAD/AAAAAgAAAP+AAAD/gAAA/wACAACAAAD/gACAAIAAAP+AAAAAAwAAAAACgAKAAAMABwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQIAAAAAgAAA/4AAAACAAAD9gAAAAgAAAP6AAAABgAAA/oAAAAGAAAAAgACAAAD/gAEAAIAAAP+A/oACgAAA/4AAAP+AAAD/gAAA/4AAAP+AAAAAAQAAAAACgAKAAAkAAAEBAQEBAQEBAQEAgAAA/4AAAAKAAAD/gAAA/wAAAAAAAgAAAACAAAD/AAAAAIAAAP4AAAIAAAAAAoACgAADABEAAAEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAP6AAAAAgAAAAQAAAP+AAAD/gAAAAYAAAAAAAIAAAP+AAAAAgAAAAQAAAP+AAAABAAAA/4AAAAEAAAD9gAAAAAMAAAAAAoACgAADAA0AEQAAAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAAAgAAA/gAAAAAAAAABgAAAAAAAgAAA/4AAgAGAAAD/gAAAAIAAAP8AAAD/gAGAAIAAAP+AAAUAAAAAAoACgAADAAcACwAXABsAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAGAAAAAgAAA/YAAAACAAAAAgAAA/4AAAACAAAAAgAAAAIAAAP+AAAAAgAAAAIAAAAAAAQAAAP8AAAABAAAA/wABgAEAAAD/AP6AAQAAAACAAAABAAAA/wAAAP+AAAD/AAGAAQAAAP8AAAAABgAAAAACgAKAAAMABwALAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD+gAAAAQAAAAAAAAAAgAAA/YAAAAIAAAAAAACAAAD/gACAAIAAAP+AAAAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAA/4AAAwAAAAACgAKAAAMACwATAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAgAAA/oAAAACAAAAAgAAA/4AAAAGAAAD/gAAAAIAAAACAAAABAACAAAD/gP8AAoAAAP6AAAD/gAAA/4AAAAGAAAAAgAAAAIAAAP2AAAAABAAAAAACgAOAAAMACwATABsAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAIAAAP6AAAAAgAAAAIAAAP+AAAABgAAA/4AAAACAAAAAgAAA/gAAAACAAAAAgAAAAIAAAAEAAIAAAP+A/wACgAAA/oAAAP+AAAD/gAAAAYAAAACAAAAAgAAA/YACgAEAAAD/gAAAAIAAAP8AAAUAAAAAAoACgAADAAcACwATABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQIAAAAAgAAA/wAAAACAAAD/gAAAAIAAAP4AAAAAgAAAAQAAAP8AAAABgAAAAIAAAAAAAIAAAP+AAIAAgAAA/4ABAACAAAD/gP6AAoAAAP8AAAD/gAAA/wACAACAAAD/gAAAAAIAAAAAAoACgAADAA8AAAEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAEAAAD/gAAA/4AAAP+AAAACgAAA/4AAAAAAAIAAAP+AAAACAAAA/oAAAAGAAAAAgAAA/4AAAP4AAAMAAAAAAoACgAADAAsAEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAIAAAP6AAAAAgAAAAIAAAP+AAAABgAAA/4AAAACAAAAAgAAAAQAAgAAA/4D/AAKAAAD/gAAA/4AAAP6AAAABgAAAAIAAAACAAAD9gAAAAAEAAAAAAoACgAALAAABAQEBAQEBAQEBAQEAAAAAAIAAAAGAAAAAgAAA/4AAAP6AAAAAAAKAAAD/AAAAAQAAAP2AAAABAAAA/wAAAAAEAAAAAAKAAoAAAwAHAAsADwAAAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAABgAAAAIAAAP4AAAABgAAAAAAAgAAA/4AAgAGAAAD+gAAAAYAAAP6AAYAAgAAA/4AAAQAAAAACgAKAAAcAAAEBAQEBAQEBAAAAAAKAAAD/gAAA/oAAAAAAAoAAAP2AAAACAAAA/gAAAAACAAAAAAKAAoAAAwANAAABAQEBAQEBAQEBAQEBAQIAAAAAgAAA/YAAAAIAAAD+gAAAAYAAAP6AAAABgACAAAD/gP6AAoAAAP+AAAD/gAAA/4AAAP8AAAAABAAAAAACgAKAAAMABwALAA8AAAEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAAAAAAAAgAAA/YAAAACAAAAAAAAAAYAAAAAAAIAAAP+AAIAAgAAA/4AAAAGAAAD+gAGAAIAAAP+AAAEAAAAAAoACgAAHAAABAQEBAQEBAQEAAAD/AAAAAoAAAP8AAAAAAAIAAAAAgAAA/4AAAP4AAAAAAwAAAAACgAKAAAMABwAPAAABAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAD+gAAAAYAAAACAAAAAAACAAAD/gAGAAQAAAP8A/wAAgAAAAIAAAAEAAAD+AAAAAAMAAAAAAoACgAADAAcAGwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAACAAAD+gAAA/4AAAACAAAD/gAAAAIAAAACAAAAAgAAA/4AAAACAAAD/gAAAAQAAgAAA/4AAAACAAAD/gP8AAIAAAACAAAAAgAAAAIAAAACAAAD/gAAA/4AAAP+AAAD/gAAA/4AAAAAJAAAAAAKAAoAAAwAHAAsADwATABcAGwAfACMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAYAAAACAAAD+AAAAAIAAAACAAAAAgAAA/wAAAACAAAD/AAAAAIAAAACAAAAAgAAA/gAAAACAAAABgAAAAIAAAAAAAIAAAP+AAAAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAIAAgAAA/4AAgACAAAD/gAAAAIAAAP+AAIAAgAAA/4AAAACAAAD/gAAAAAEAAAAAAoACgAALAAABAQEBAQEBAQEBAQECAAAA/gAAAACAAAABAAAAAIAAAACAAAAAAACAAAACAAAA/oAAAAGAAAD+gAAA/wAAAAACAAAAAAKAAoAAAwALAAABAQEBAQEBAQEBAQEAAAAAAIAAAAGAAAD+gAAAAYAAAACAAAABgAEAAAD/AP6AAQAAAACAAAABAAAA/YAAAQAAAAACgAKAAAsAAAEBAQEBAQEBAQEBAQAAAAAAgAAAAIAAAACAAAAAgAAAAIAAAAAAAoAAAP4AAAACAAAA/gAAAAIAAAD9gAAAAAEAAAAAAoACgAANAAABAQEBAQEBAQEBAQEBAQIAAAD+AAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAACAAAACAAAA/oAAAAGAAAD+gAAAAYAAAP2AAAIAAAAAAoACgAADABEAAAEBAQEBAQEBAQEBAQEBAQEBAQIAAAAAgAAA/gAAAP+AAAABgAAA/4AAAAEAAAD/AAAAAQAAAACAAIAAAP+A/4ACAAAAAIAAAP+AAAD/gAAA/4AAAP+AAAD/gAAAAAMAAAAAAoACgAADAA0AEQAAAQEBAQEBAQEBAQEBAQEBAQEBAQAAAACAAAD+gAAAAIAAAACAAAD/gAAAAIAAAAEAAAAAgAAAAIAAgAAA/4D/gAKAAAD/AAAA/4AAAP+AAAD/gAAAAoAAAP2AAAIAAAAAAoACgAADAA0AAAEBAQEBAQEBAQEBAQEBAgAAAACAAAD9gAAAAIAAAAGAAAD+gAAAAYAAAACAAIAAAP+A/4ACgAAA/wAAAP+AAAD/gAAA/4AAAAADAAAAAAKAAoAAAwALAA8AAAEBAQEBAQEBAQEBAQEBAQEAAAAAAgAAAAAAAAD+gAAAAYAAAACAAAD9gAAAAgAAAAAAAIAAAP+AAIAAgAAAAIAAAACAAAD+gAGAAIAAAP+AAAAABAAAAAACgAKAAAMABwATABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQGAAAAAgAAAAAAAAACAAAD9gAAAAIAAAACAAAAAgAAA/4AAAP+AAAABAAAAAIAAAAAAAIAAAP+AAIABgAAA/oD/gAKAAAD/AAAAAIAAAP6AAAAAgAAA/wACAACAAAD/gAADAAAAAAKAAoAAAwAHABMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAD/gAAAAIAAAAGAAAD/AAAA/4AAAAGAAAD+gAAAAgAAAAAAAIAAAP+AAYAAgAAA/4D+gAEAAAD/gAAAAQAAAACAAAAAgAAA/YAAAAAEAAAAAAKAA4AAAwANABUAGQAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAYAAAP4AAAAAgAAAAYAAAACAAAD+AAAAAAAAAACAAAAAgAAAAIAAAP6AAAAAgAAAAAAAgAAA/4AAgAGAAAD/gAAAAIAAAP8AAAD/gAGAAIAAAACAAAD/gAAA/4ABAACAAAD/gAAAAAUAAAAAAoADgAADAA0AEQAVABkAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAAGAAAD+AAAAAIAAAAGAAAAAgAAA/gAAAAAAAAABgAAA/oAAAACAAAAAgAAAAIAAAAAAAIAAAP+AAIABgAAA/4AAAACAAAD/AAAA/4ABgACAAAD/gAEAAIAAAP+AAAAAgAAA/4AABQAAAAACgAKAAAMABwALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAgAAAAgAAAP2AAAAAgAAAAAAAAAGAAAD+AAAAAIAAAAAAAAACAAAAAAAAgAAA/4AAgACAAAD/gACAAIAAAP+AAIAAgAAA/4AAgACAAAD/gAAAAAcAAAAAAoACgAADAAcACwAPABMAFwAbAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIAAAACAAAAAgAAAAIAAAP8AAAAAgAAA/oAAAACAAAABgAAAAIAAAP4AAAAAgAAAAIAAAACAAAAAAACAAAD/gAAAAIAAAP+AAIABAAAA/wAAAAGAAAD+gAAAAYAAAP6AAYAAgAAA/4AAAACAAAD/gAAAAAQAAAAAAoADgAALAA8AEwAXAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAGAAAAAgAAA/4AAAP6AAAAAAAAAAYAAAP4AAAAAgAAAAYAAAACAAAAAAAIAAAD/gAAAAIAAAP4AAAABAAAA/wACAAEAAAD/AAEAAIAAAP+AAAAAgAAA/4AABQAAAAACgAOAAAMADQARABUAGQAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAAAAAABgAAA/oAAAAGAAAAAgAAA/gAAAAGAAAD+AAAAAIAAAAGAAAAAgAAAAIAAgAAA/4D/gACAAAAAgAAAAIAAAACAAAD+AAIAAQAAAP8AAQAAgAAA/4AAAACAAAD/gAAEAAAAAAKAA4AACwAPABMAFwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAABgAAAAIAAAP+AAAD+gAAAAAAAAAGAAAD+gAAAAIAAAACAAAAAgAAAAAACAAAA/4AAAACAAAD+AAAAAQAAAP8AAgAAgAAA/4ABAACAAAD/gAAAAIAAAP+AAAUAAAAAAoADgAADAA0AEQAVABkAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAACAAAAAAAAAAYAAAP6AAAABgAAAAIAAAP4AAAABgAAA/oAAAACAAAAAgAAAAIAAAACAAIAAAP+A/4AAgAAAAIAAAACAAAAAgAAA/gACAACAAAD/gAEAAIAAAP+AAAAAgAAA/4AAAQAAAAACgAOAABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAIAAAP+AAAAAgAAAAYAAAP8AAAABAAAA/wAAAAEAAAD+gAAA/4AAAAAAAoAAAP8AAAABAAAAAIAAAACAAAD/gAAA/wAAAP+AAAD/AAAA/4AAAAEAAAD/AAAAAAMAAAAAAoACgAATABcAGwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAgAAAAIAAAP+AAAAAgAAAAIAAAACAAAAAgAAA/wAAAAEAAAD9gAAAAQAAAACAAAAAgAAAAAABAAAA/4AAAACAAAAAgAAAAIAAAP+AAAAAgAAA/wAAAP+AAAD/gAIAAIAAAP+AAAAAgAAA/4AAAAAGAAAAAAKAA4AAAwAHAAsADwATABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAABgAAAAIAAAP4AAAABgAAA/oAAAACAAAAAgAAAAIAAAAAAAIAAAP+AAIABgAAA/oAAAAGAAAD+gAGAAIAAAP+AAQAAgAAA/4AAAACAAAD/gAAGAAAAAAKAAwAAAwAHAAsADwATABcAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCAAAABgAAA/gAAAACAAAABgAAAAIAAAP4AAAABgAAA/oAAAACAAAAAgAAAAIAAAAAAAIAAAP+AAIABAAAA/wAAAAEAAAD/AAEAAIAAAP+AAQAAgAAA/4AAAACAAAD/gAAGAAAAAAKAA4AAAwAHAAsAEwAXABsAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAAAAAQAAAAAAAAAAgAAA/oAAAAEAAAD+AAAAAIAAAACAAAD/gAAAAYAAAACAAAD+AAAAAYAAAAAAAIAAAP+AAIABgAAA/oABgACAAAD/gP4AAwAAAP4AAAD/gAAA/4ACgACAAAD/gACAAIAAAP+AAAIAgAIAAYADgAAFAAkAAAEBAQEBAQEBAQEAgAAAAIAAAACAAAD/gAAAAIAAAAIAAQAAAP+AAAD/gAEAAIAAAP+AAAAAAgCAAgABgAOAAAMACQAAAQEBAQEBAQEBAQCAAAAAgAAAAAAAAP+AAAABAAAAAgAAgAAA/4AAgACAAAAAgAAA/wAAAAAEAAACAAKAA4AABQALAA8AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAACAAAAAgAAAAIAAAACAAAD+AAAAAIAAAAEAAAAAgAAAAgABAAAA/4AAAP+AAAABAAAA/4AAAP+AAQAAgAAA/4AAAACAAAD/gAAEAAACAAKAA4AAAwAHAA0AEwAAAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAIAAAAEAAAAAgAAA/oAAAP+AAAABAAAAAQAAAP+AAAABAAAAAgAAgAAA/4AAAACAAAD/gACAAIAAAACAAAD/AAAAAIAAAACAAAD/AAABAIAAAAIAA4AACwAAAQEBAQEBAQEBAQEBAQAAAP+AAAAAgAAAAIAAAACAAAD/gAAAAAACAAAAAIAAAAEAAAD/AAAA/4AAAP4AAAAAAQAAAIACgAMAAAsAAAEBAQEBAQEBAQEBAQCAAAD/gAAAAIAAAAGAAAAAgAAA/4AAAACAAIAAAAGAAAAAgAAA/4AAAP6AAAD/gAAAAAMAAAAAAoAAgAADAAcACwAAAQEBAQEBAQEBAQEBAAAAAACAAAAAgAAAAIAAAACAAAAAgAAAAAAAgAAA/4AAAACAAAD/gAAAAIAAAP+AAAAAAwCAAQABgAKAAAMABwALAAABAQEBAQEBAQEBAQEBAAAAAIAAAP8AAAAAgAAAAAAAAACAAAABAACAAAD/gACAAIAAAP+AAIAAgAAA/4AAAAADAIABAAGAAoAAAwAHAAsAAAEBAQEBAQEBAQEBAQCAAAAAgAAAAAAAAACAAAD/AAAAAIAAAAEAAIAAAP+AAIAAgAAA/4AAgACAAAD/gAAAAAUAAAAAAoADgAADAAcAGwAfACMAAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAABAAAAAAAAAACAAAD+AAAA/4AAAACAAAD/gAAAAIAAAACAAAAAgAAA/4AAAACAAAD/gAAAAQAAAACAAAD+gAAAAQAAAAAA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"
					),
				}
			)
		),
		JuraLight = Font.new(
			fishy.fonts.cache:Register_Font(
				"JuraLight",
				400,
				"Regular",
				{
					Id = "JuraLight.ttf",
					Font = crypt.base64.decode(
						"AAEAAAAPAIAAAwBwRkZUTVC6fp4AAOMoAAAAHE9TLzJ6BGhNAAABeAAAAFZjbWFwzO5xbAAADTgAAARmY3Z0IAULAe8AABN8AAAACmZwZ22AwcZfAAARoAAAAbBnYXNw//8AAwAA4yAAAAAIZ2x5Zv7NasAAABlAAACuiGhlYWTr8mLBAAAA/AAAADZoaGVhBRcFrgAAATQAAAAkaG10eO0alGYAAAHQAAALaGxvY2GBFFUaAAATiAAABbZtYXhwA/oA9wAAAVgAAAAgbmFtZfXwTNEAAMfIAAADtHBvc3SzvkkqAADLfAAAF6JwcmVwnMcqZAAAE1AAAAArAAEAAAACZmYxsLHEXw889QALBAAAAAAAxa1cdQAAAADFrVx1/e//MwOIA0EAAAAIAAIAAAAAAAAAAQAAA0H/MwBcA8797//SA4gAAQAAAAAAAAAAAAAAAAAAAtoAAQAAAtoAWgAHAGkABAACAAEAAAAQAAABAAAuAAMABAABAgQBLAAFAAACmQLMAAAAjwKZAswAAAHrADMBCQAAAgADAwAAAAAAAKAAAu9QACBLAAAAAAAAAABQZkVkAAAAIPsCAzP/MwBcA0EAzSAAAJ8AAAAAAAABdgAiAAAAAAFVAAABmQAAANIAOwEQAEEB+AAAAmYAVQHiACgCSgBVAKsAQQENAFUBDQBBAYIAQQIyAEEAuQA2Aa0AQQDdAEEBSgAiAmYAVQEmADYCZgBVAmYAVQJmAFMCZgBXAmYAVQJmAF4CZgBVAmYAVQDdAEEA3QBBAiIAQQGtAEECIgBBAmYAVAJmAFsCQgAYAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQDTAFUCSgBVAi8AVQIuAFUCegBVAmYAVQJmAFUCJgBVAmYAVQI3AFUCSgBVAgMANgJmAFUCQgAYA8cAPwJ8AFUCUwBBAmYAVQENAFUBSgAiAQ0AVQG7AFUB2wAAANQAIgJmAFUCZgBVAmYAVQJmAFUCZgBVAXQANgJmAFUCZgBVANIAPADQ/40B3gBVAQAAVQNEAFUCZgBVAmYAVQJmAFUCZgBVAaYAVQJmAFUBeQAxAmYAVQI9AEEDMgA2AjgATgJmAFUCTwBVAQ0AJQDTAFUBDQAlAZEAQQDSADsCFwBXAhkAVQHeAEECUwBBAKsAQQJmAIABbwBBAmYAVQFxAEECBABBAeIAQQGtAEECZgBVAa0AQQHIAFUCMgBBATcAKwErACsA1AAiAkkAVQHoAFMA3QBBANEAKgEmAEIBcQBBAgQAQQJwAD8CfQA/AnAAMAJmAFQCQgAYAkIAGAJCABgCQgAYAkIAGAJCABgDSwAAAmYAVQJmAFUCZgBVAmYAVQJmAFUA0wAFANMAVQDT/+MA0//0AmYAMgJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQHeAEECZgBVAmYAVQJmAFUCZgBVAmYAVQJTAEECJgBVAh0AVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQPOAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQDS/+4A0gBVANL/4gDS//MCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAa0AQQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAkIAGAJmAFUCQgAYAmYAVQJCABgCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAo8AVQJmADICZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAGwJmADwA0//iANL/4gDT/9QA0v/UANMAEwDSABEA0wA8ANIAVQJKAFUA0P+NAi8AVQHeAFUB+ABVAi4AVQEAAFUCLgBVAQAAVQIuAFUBAABVAm8APwFWACECZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUC1wBBAt4AQQI3AFUBpgBVAjcAVQGmAEECNwBVAaYAVQJKAFUCZgBVAkoAVQJmAFUCSgBVAmYAVQJKAFUCZgBVAgMANgF5ADECAwA2AXkAMQIDADYBeQAxAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVA8cAPwMyADYCUwBBAmYAVQJTAEECZgBVAk8AVQJmAFUCTwBVAmYAVQJPAFUBmP/UAoUAVQKGAFUCoABVApYAVQJKAFUCZgBVAgMANgF5ADEA0P+NAZIAQQF1ADcBrABjAN0AQQEaAEEA6gAtAZEAQQFNACIAAP6OAAD+jgAA/koAAP5RAAD+PQAA/l0AAP6fAAD+VQAA/sgAAP6BAAD+ZgAA/k8AAP76ANP/wgAA/p8AAP6kAAD+6QGR/hIAAP49AAD+YgEAAFUA3QBBAO8ASwF1ADUCQgAYAN0AQQJm/+8CZv/xANP/+QJmABUCU//ZAmYAEwEA//MCQgAYAmYAVQJYAFUCLgAYAmYAVQJmAFUCZgBVAmYAVQDTAFUCLwBVAkIAGAJ6AFUCZgBVAmYAQQJmAFUCWABTAiYAVQJmAEECAwA2AlMAQQJmAFUCfABVAmYAVQJmAFUA0//0AlMAQQJ3AFMCZgBVAmYAVQEAAFUCZgBVAncAUwIdAHQCZgA2AmYAUwJmAFUCZgBTAmYAVQIgAFUBAABVAfgAVQKvAFUCSQBVAj0AQQJaAFMCZgBVAmYANgJmAFUCZgB0ApAAVQIDADYCZgBVAkwANQKvAJ4CZgBVAocAPwEA//MCZgBVAmYAVQJmAFUChwA/AmYAVQJmAFUCtgANAlgAVQJmAFUCSgBVANMAVQDT//QCSgBVA8IAUwO+AFMCtgANAlgAVQJmAFUCZgBBAlgAUwJCABgCJgBVAmYAVQJYAFUCmgBTAmYAVQK4AD8CZgBVAmYAVQJmAFUCWABVAmYAUwJ6AFUCZgBVAmYAVQJYAFMCJgBVAmYAVQIDADYCZgBBAmYAVQJ8AFUCWABTAmYAVQJ4AD8CsgA/AnYAIQKZAFUCJgBVAmYAVQLRAFUCWAA/AmYAVQJmAFUCZgBVAhsAVQKaAFMCZgBVArgAPwJmAFUCWABTAlgAUwJVAFMCZgBTAnoAVQJYAFMCZgBVAlgAUwJmAFUCZgBVAgMANgJmAFUDBgBJAjgATgJYAFMCZgBVAlAAPwKKAD8CawA7AqcAUwI8AFMCZgBVAr4AVQJYAFMCZgBVAmYAVQJmADwCGwBVAmYAVQJmAFUA0gA8ANL/8wDQ/40DOABTAzgAUwJmADwCVQBTAlgAUwJmAFUCWABTAtIASgK6ACsCZgBVAlgAVQJYAFUCGwBVAmYAVQJmAFUCZgBVAmYAVQJmAFUBdAA2AnoAVQNEAFUCJgBVAmYAVQJKAFUCZgBVAgMANgF5ADEDxwA/AzIANgPHAD8DMgA2A8cAPwMyADYCQgAYAmYAVQJCABgCZgBVAkIAGAJmAFUCQgAYAmYAUAJCABgCZgBVAkIAGAJmAFUCQgAYAmYAVQJCABgCZgBVAkIAGAJmAFUCQgAYAmYAVQJCABgCZgBVAkIAGAJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVANMAVQDSAFUA0wA7ANIAOwJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAoUAVQKGAFUChQBVAoYAVQKFAFUChgBVAoUAVQKGAFUChQBVAoYAVQJmAFUCZgBVAmYAVQJmAFUCoABVApYAVQKgAFUClgBVAqAAVQKWAFUCoABVApYAVQKgAFUClgBVAlMAQQJmAFUCUwBBAmYAVQJTAEECZgBVAlMAQQJmAFUB8QBBAmYAQQJ5AEEAuQA2AL8ANgC/ADYBOgA2AToANgE6ADYBVABBAVQAQQG4AFUB0gBBAoUAKAFqAEEBagBBAiIALQFCACsCZgBVA1gAPwJmAFUCaAA2AmYAVQIBAFMCLgAYAlgANgJmAEECFAA/Az8AIQDU/9QBwQAmAa0AQQHuACoB7gAqAj0AQQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVwJmACoCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAmYAVQJmAFUCZgBVAAD+nwAA/hgAAP4cAAD+PAAA/jwAAP6fAAD97wAA/e8CZgBVANMAVQGwAC0BsQAtAawALQFrAC0BQAAtAUAALQFAAC0BagAtAkIAGAJmAFUA0wBVAmYAVQG1ADYCBgA2AAAAAwAAAAMAAAAcAAEAAAAAAlwAAwABAAAAHAAEAkAAAACMAIAABgAMAH4BEwErATEBPgFIAU0BfgGSAaEBsAIbAjcCxwLdAwQDDAMSAxsDIwMoAzUDNwN6A34DigOMA6EDzgRfBGMEcwSRHgMeCx4fHkEeVx5hHmsehR75IBUgGiAeICIgJiAwIDogRCB0IKwhFyEiISYiAiIGIg8iESIaIh4iKyJIImAiZSXKqS/gy/sC//8AAAAgAKEBFgEuATQBQQFKAVABkgGgAa8CGAI3AsYC2AMA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HCYcMhw+HEocVhxiHG4cehyGHJIczB0QHRwdKB00HUAdeh3IHdQd4B3sHfgeBB4QHhweKB40HkAeTB5YHpAeyB7UHuAe7B74HyAfVB9gH2gfdB+AH4wfmB+gH6wfuB/EH9Af3B/oIBggSiBWIGIgbiB6IIYgkiDAIPghBCEQIRwhKCFoIbohxiHSId4h6iH2IgIiDiIaIiYiMiKUIugi9CMAIzIjdiOCI44jtiPuI/okBiQSJB4kKiQ2JEIkTiRaJGYkniTeJOok9iUCJQ4lGiUmJTIlPiVKJVYlYiWSJcomFiZGJoAmjCaYJqQmsCbOJtgm4ib6JwQnDicuJzYnQidgJ3wnnieoJ7InvCfEJ84n5igEKBAoLihKKGAoaih0KH4ooCiqKMYo4CjoKQIpECkcKSQpMCk8KUgpVClgKWwpeCmAKYgpkCmyKbopwinKKf4qBioOKiwqNCo8KmgqcCp4KoAqriq2Kr4qxirOKv4rQitKK1IrXitqK3YrgiuOK8QsBiw0LHQsuiz4LSQtTC1mLZAtwC3ILdAuHi4mLlAugi62Lu4vEC86L4gvyi/6MD4wSjBWMGIwbjB6MIIwijDAMMwxDjEWMR4xJjEuMWYxmjHKMdYx4jHuMgwyFDI8MkQyYDKMMpQy8jM6M14zajOkM8oz0jPaM+Iz+jQCNAo0EjRENIA0iDSoNNQ08jUaNUI1TjV0NbY16jYgNig2bDaYNrQ23DbkNzw3fjecN6g35DgKODY4WDhgOHg4gDiIOKI4qjkGOQ45LjlYOXY5njnEOdA59Do2Ong6tDq8OsQ7AjsOO1A7WDtgO2g7cDumO9g8EDwcPCg8NDxSPIQ8tjz2PUg9aD2GPZI9nj2qPbY9wj3OPdo95j3yPf4+Cj4WPiI+Lj46PkY+Uj5ePmo+dj6CPo4+mj6mPrI+vj7KPtY+4j7uPvo/Bj8SPx4/Kj82P0I/Tj9aP2Y/cj9+P4o/lj+iP64/uj/GP9I/3j/qP/ZAAkAOQBpAJkAyQD5ASkBWQGJAbkB6QIZAkkCeQKpAtkDCQM5A2kDmQPJA/kEKQRZBIkEuQXpB3EIoQopC0kMuQ5JEDERQRKhEtETARMxE2EUeRW5FtEYERkZGkkbuR1ZHkkfYR+RH8Ef8SAhIFEggSCxIOEhKSFxIbkiCSJhIokiuSLpIxkjmSRJJJEk0SaJJwEne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KBEICBctNhsHBxs2LW8tNhsHBxs2LSQXKBEICf71RmlvaUZGaW9pRgABAFX/+QIDAuwAEwAAASEiBhURFCMiNRE0NjMhNTQzMhUCA/64IhoWFCg3ASUWFAJSHiP+Bh4eAelGNlIeHgAAAQBV//kBxgI9ABMAABMiBhURFCMiNRE0NjsBNTQzMh0BuyIaFhQoN+gWFAGjHiP+tR4eATpGNlIeHnz//wBVAAACEQMKECcBQgCuAHASBgAlAAD//wBV//kCEQKDECcBQgDE/7gSBgBFAAD//wBVAAACEQMKECcBQgCuAHASBgAnAAD//wBV//kCEQKDECcBQgDE/7gSBgBHAAD//wBV//kCEQMKECcBQgC/AHASBgApAAD//wA2//kBRALuECYBQlhUEgYASQAAAAD//wBV//kCJgLEECcBQgDOACoSBgAwAAD//wBV//kC8AJZECcBQgE1/78SBgBQAAD//wBV//kB5wMKECcBQgCTAHASBgAzAAD//wBV/0oCEQJZECcBQgDV/78SBgBTAAD//wBV//gCEwMKECcBQgDKAHASBgA2AAD//wBVAAACEwJSECcBQgDS/7gSBgBWAAD//wA2//kBzQMKECcBQgCSAHASBgA3AAD//wAxAAABPgLeECYBQvZEEgYAVwAAAAD//wA/AAADiAMzECcBRwLwALwSBgA6AAD//wA2AAAC/AKnECcAQwD4AAESBgBaAAD//wA/AAADiAMzECcBSANBALwSBgA6AAD//wA2AAAC/AKmECcAdQFrAAASBgBaAAD//wA/AAADiAMRECcAaQEsAHcSBgA6AAD//wA2AAAC/AJZECcAaQDh/78SBgBaAAD//wAY/3QCDgJ8ECcBVQJG//oSBgAkAAD//wBV/3QB5wHNECcBVQJP//oSBgBEAAD//wAY//ACDgMzECcBTwI4ALESBgAkAAD//wBV//kB5wKcECcBTwJNABoSBgBEAAD//wAY//kCDgMMECYCzF0AEAYC1AAAAAD//wBV//kB7ALfECYCzGnTEAYARAAAAAD//wAY//kCDgMEECYCzRf4EAYC1AAAAAD//wBQ//kB5wLfECYCzSPTEAYARAAAAAD//wAY//kCDgMzECYCzl0AEAYC1AAAAAD//wBV//kB6AMGECYCzmnTEAYARAAAAAD//wAY//kCDgMzECYCz10AEAYC1AAAAAD//wBV//kB5wMGECYCz2nTEAYARAAAAAD//wAY/3QCDgMzECcBPwBKAI0SBgIfAAD//wBV/3QB5wKuECYBP2UIEgYCIAAAAAD//wAY//kCDgMgECYC0HIAEAYC1AAAAAD//wBV//kB5wLnECYC0H7HEAYARAAAAAD//wAY//kCDgMgECYC0XIAEAYC1AAAAAD//wBV//kB5wLnECYC0X7HEAYARAAAAAD//wAY//kCDgM0ECYC0nIAEAYC1AAAAAD//wBV//kB5wL7ECYC0n7HEAYARAAAAAD//wAY//kCDgMzECYC018AEAYC1AAAAAD//wBV//kB5wL6ECYC037HEAYARAAAAAD//wAY/3QCDgMzECYBQT1aEgYCHwAAAAD//wBV/3QB5wKDECYBQUiqEgYCIAAAAAD//wBV/3sCEQJ8ECcBVQJhAAESBgAoAAD//wBV/3sCEQHNECcBVQJmAAESBgBIAAD//wBVAAACEQMzECcBTwJUALESBgAoAAD//wBVAAACEQKcECcBTwJZABoSBgBIAAD//wBVAAACEQMaECcBRQBlAgwSBgAoAAD//wBVAAACEQJiECcBRQBqAVQSBgBIAAD//wBVAAACEQMgECYCzHEUEAYC1QAAAAD//wBVAAACEQLfECYCzH3TEAYASAAAAAD//wBVAAACEQMYECYCzSsMEAYC1QAAAAD//wBVAAACEQLfECYCzTfTEAYASAAAAAD//wBVAAACEQMzECYCznEAEAYC1QAAAAD//wBVAAACEQMGECYCzn3TEAYASAAAAAD//wBVAAACEQMzECYCz3EAEAYC1QAAAAD//wBVAAACEQMGECYCz33TEAYASAAAAAD//wBV/3sCEQMzECcBPwBkAI0SBgI3AAD//wBV/3sCEQKyECYBP2oMEgYCOAAAAAD//wBV//kArwMzECcBTwGQALESBgAsAAD//wBV//kArgKjECcBTwGPACESBgDuAAD//wA7/3QAlwKDECcBVQGc//oSBgAsAAD//wA7/3QAmAJ9ECcBVQGc//oSBgBMAAD//wBV/3ICEQKFECcBVQJm//gSBgAyAAD//wBV/3sCEQHNECcBVQJmAAESBgBSAAD//wBV//cCEQMzECcBTwJYALESBgAyAAD//wBVAAACEQKcECcBTwJZABoSBgBSAAD//wBV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ACUAJgAnACgAKQAqACsALAAtAC4ALwAwADEAMgAzADQANQA2ADcAOAA5ADoAOwA8AD0APgA/AEAAQQBCAEMARABFAEYARwBIAEkASgBLAEwATQBOAE8AUABRAFIAUwBUAFUAVgBXAFgAWQBaAFsAXABdAF4AXwBgAGEAowCEAIUAvQCWAOgAhgCOAIsAnQCpAKQBAgCKANoAgwCTAPIA8wCNAQMAiADDAN4A8QCeAKoA9QD0APYAogCtAMkAxwCuAGIAYwCQAGQAywBlAMgAygDPAMwAzQDOAOkAZgDTANAA0QCvAGcA8ACRANYA1ADVAGgA6wDtAIkAagBpAGsAbQBsAG4AoABvAHEAcAByAHMAdQB0AHYAdwDqAHgAegB5AHsAfQB8ALgAoQB/AH4AgACBAOwA7gC6AQQBBQEGAQcBCAEJAP0A/gEKAQsBDAENAP8BAAEOAQ8BEAEBAREBEgETARQBFQEWARcBGAEZARoA+AD5ARsBHAEdAR4BHwEgASEBIgEjASQBJQEmAScBKAD6ANcBKQEqASsBLAEtAS4BLwEwATEBMgEzAOIA4wE0ATUBNgE3ATgBOQE6ATsBPAE9AT4BPwCwALEBQAFBAUIBQwFEAUUBRgFHAUgBSQD7APwA5ADlAUoBSwFMAU0BTgFPAVABUQFSAVMBVAFVAVYBVwFYAVkBWgFbAVwBXQFeAV8AuwFgAWEBYgFjAOYA5wCmAWQBZQFmAWcBaAFpAWoBawFsANgA4QDbANwA3QDgANkA3wFtAW4BbwFwAXEBcgFzAXQBdQF2AXcBeAF5AXoBewF8AX0BfgF/AYABgQGCAYMBhAGFAYYBhwGIAYkBigGLAYwBjQGOAY8BkACoAZEBkgGTAZQBlQGWAZcBmAGZAZoBmwGcAZ0BngGfAaABoQGiAaMAnwGkAaUBpgGnAagBqQGqAasBrAGtAa4BrwGwAbEBsgGzAbQBtQCXAbYBtwG4AJsBuQG6AbsBvAG9Ab4BvwHAAcEBwgHDAcQBxQHGAccByAHJAcoBywHMAc0BzgHPAdAB0QHSAdMB1AHVAdYB1wHYAdkB2gHbAdwB3QHeAd8B4AHhAeIB4wHkAeUB5gHnAegB6QHqAesB7AHtAe4B7wHwAfEB8gHzAfQB9QH2AfcB+AH5AfoB+wH8Af0B/gH/AgACAQICAgMCBAIFAgYCBwIIAgkCCgILAgwCDQIOAg8CEAIRAhICEwIUAhUCFgIXAhgCGQIaAhsCHAIdAh4CHwIgAiECIgIjAiQCJQImAicCKAIpAioCKwIsAi0CLgIvAjACMQIyAjMCNAI1AjYCNwI4AjkCOgI7AjwCPQI+Aj8CQAJBAkICQwJEAkUCRgJHAkgCSQJKAksCTAJNAk4CTwJQAlECUgJTAlQCVQJWAlcCWAJZAloCWwJcAl0CXgJfAmACYQJiAmMCZAJlAmYCZwJoAmkCagJrAmwCbQJuAm8CcAJxAnICcwJ0AnUCdgJ3AngCeQJ6AnsCfAJ9An4CfwKAAoECggKDAoQChQKGAocCiAKJAooCiwKMAo0CjgKPApACkQKSApMClAKVApYClwKYApkCmgCyALMCmwC2ALcAxAC0ALUAxQCCAMIAhwCrAMYAvgC/ALwCnAKdAp4CnwCMAqAAmAKhAJoAmQClAJIAnACnAI8AlACVALkCogKjAqQCpQKmAqcCqAKpAqoCqwKsAq0CrgKvArACsQKyArMCtAK1ArYCtwK4ArkCugK7ArwCvQK+Ar8CwALBAsICwwLEAsUCxgLHAsgCyQLKAssCzALNAs4CzwLQAtEC0gLTAtQC1QLWAtcC2ALZAtoC2wLcAt0AwADBB3VuaTAwQUQHdW5pMDBCNQdBbWFjcm9uB2FtYWNyb24GQWJyZXZlBmFicmV2ZQdBb2dvbmVrB2FvZ29uZWsLQ2NpcmN1bWZsZXgLY2NpcmN1bWZsZXgKQ2RvdGFjY2VudApjZG90YWNjZW50BkRjYXJvbgZkY2Fyb24GRGNyb2F0B0VtYWNyb24HZW1hY3JvbgpFZG90YWNjZW50CmVkb3RhY2NlbnQHRW9nb25lawdlb2dvbmVrBkVjYXJvbgZlY2Fyb24LR2NpcmN1bWZsZXgLZ2NpcmN1bWZsZXgKR2RvdGFjY2VudApnZG90YWNjZW50DEdjb21tYWFjY2VudAxnY29tbWFhY2NlbnQLSGNpcmN1bWZsZXgLaGNpcmN1bWZsZXgESGJhcgRoYmFyBkl0aWxkZQZpdGlsZGUHSW1hY3JvbgdpbWFjcm9uB0lvZ29uZWsHaW9nb25lawtKY2lyY3VtZmxleAtqY2lyY3VtZmxleAxLY29tbWFhY2NlbnQMa2NvbW1hYWNjZW50DGtncmVlbmxhbmRpYwZMYWN1dGUGbGFjdXRlDExjb21tYWFjY2VudAxsY29tbWFhY2NlbnQGTGNhcm9uBmxjYXJvbgZOYWN1dGUGbmFjdXRlDE5jb21tYWFjY2VudAxuY29tbWFhY2NlbnQGTmNhcm9uBm5jYXJvbgNFbmcDZW5nB09tYWNyb24Hb21hY3Jvbg1PaHVuZ2FydW1sYXV0DW9odW5nYXJ1bWxhdXQGUmFjdXRlBnJhY3V0ZQxSY29tbWFhY2NlbnQMcmNvbW1hYWNjZW50BlJjYXJvbgZyY2Fyb24GU2FjdXRlBnNhY3V0ZQtTY2lyY3VtZmxleAtzY2lyY3VtZmxleAxUY29tbWFhY2NlbnQMdGNvbW1hYWNjZW50BlRjYXJvbgZ0Y2Fyb24EVGJhcgR0YmFyBlV0aWxkZQZ1dGlsZGUHVW1hY3Jvbgd1bWFjcm9uBlVicmV2ZQZ1YnJldmUFVXJpbmcFdXJpbmcNVWh1bmdhcnVtbGF1dA11aHVuZ2FydW1sYXV0B1VvZ29uZWsHdW9nb25lawtXY2lyY3VtZmxleAt3Y2lyY3VtZmxleAtZY2lyY3VtZmxleAt5Y2lyY3VtZmxleAZaYWN1dGUGemFjdXRlClpkb3RhY2NlbnQKemRvdGFjY2VudAVPaG9ybgVvaG9ybgVVaG9ybgV1aG9ybgxTY29tbWFhY2NlbnQMc2NvbW1hYWNjZW50B3VuaTAyMUEHdW5pMDIxQgd1bmkwMjM3CWdyYXZlY29tYglhY3V0ZWNvbWIHdW5pMDMwMgl0aWxkZWNvbWIHdW5pMDMwNAd1bmkwMzA2B3VuaTAzMDcHdW5pMDMwOA1ob29rYWJvdmVjb21iB3VuaTAzMEEHdW5pMDMwQgd1bmkwMzBDE2NvbW1hdHVybmVkYWJvdmVjbWIHdW5pMDMxQgxkb3RiZWxvd2NvbWIHdW5pMDMyNwd1bmkwMzI4B3VuaTAzMzQHdW5pMDMzNQd1bmkwMzM3B3VuaTAzN0ENcXVlc3Rpb25ncmVlawV0b25vcw1kaWVyZXNpc3Rvbm9zCkFscGhhdG9ub3MJYW5vdGVsZWlhDEVwc2lsb250b25vcwhFdGF0b25vcwlJb3RhdG9ub3MMT21pY3JvbnRvbm9zDFVwc2lsb250b25vcwpPbWVnYXRvbm9zEWlvdGFkaWVyZXNpc3Rvbm9zBUFscGhhBEJldGEFR2FtbWEHRXBzaWxvbgRaZXRhA0V0YQVUaGV0YQRJb3RhBUthcHBhBkxhbWJkYQJNdQJOdQJYaQdPbWljcm9uAlBpA1JobwVTaWdtYQNUYXUHVXBzaWxvbgNQaGkDQ2hpA1BzaQxJb3RhZGllcmVzaXMPVXBzaWxvbmRpZXJlc2lzCmFscGhhdG9ub3MMZXBzaWxvbnRvbm9zCGV0YXRvbm9zCWlvdGF0b25vcxR1cHNpbG9uZGllcmVzaXN0b25vcwVhbHBoYQRiZXRhBWdhbW1hBWRlbHRhB2Vwc2lsb24EemV0YQNldGEFdGhldGEEaW90YQVrYXBwYQZsYW1iZGECbnUCeGkHb21pY3JvbgNyaG8Gc2lnbWExBXNpZ21hA3RhdQd1cHNpbG9uA3BoaQNjaGkDcHNpBW9tZWdhDGlvdGFkaWVyZXNpcw91cHNpbG9uZGllcmVzaXMMb21pY3JvbnRvbm9zDHVwc2lsb250b25vcwpvbWVnYXRvbm9zB3VuaTA0MDAKSW9jeXJpbGxpYwtEamVjeXJpbGxpYwtHamVjeXJpbGxpYwhJZS51a3JhbgtEemVjeXJpbGxpYwlJY3lyaWxsaWMKWWljeXJpbGxpYwpKZWN5cmlsbGljC0xqZWN5cmlsbGljC05qZWN5cmlsbGljDFRzaGVjeXJpbGxpYwtLamVjeXJpbGxpYxBJaWN5cmlsbGljX2dyYXZlDlVzaG9ydGN5cmlsbGljDER6aGVjeXJpbGxpYwlBY3lyaWxsaWMKQmVjeXJpbGxpYwpWZWN5cmlsbGljCkdlY3lyaWxsaWMKRGVjeXJpbGxpYwpJZWN5cmlsbGljC1poZWN5cmlsbGljClplY3lyaWxsaWMKSWljeXJpbGxpYw9JaXNob3J0Y3lyaWxsaWMKS2FjeXJpbGxpYwpFbGN5cmlsbGljCkVtY3lyaWxsaWMKRW5jeXJpbGxpYwlPY3lyaWxsaWMKUGVjeXJpbGxpYwpFcmN5cmlsbGljCkVzY3lyaWxsaWMKVGVjeXJpbGxpYwlVY3lyaWxsaWMKRWZjeXJpbGxpYwtLaGFjeXJpbGxpYwtUc2VjeXJpbGxpYwtDaGVjeXJpbGxpYwtTaGFjeXJpbGxpYw1TaGNoYWN5cmlsbGljEEhhcmRzaWduY3lyaWxsaWMMWWVyaWN5cmlsbGljEFNvZnRzaWduY3lyaWxsaWMRRXJldmVyc2VkY3lyaWxsaWMKSVVjeXJpbGxpYwpJQWN5cmlsbGljCWFjeXJpbGxpYwpiZWN5cmlsbGljCnZlY3lyaWxsaWMKZ2VjeXJpbGxpYwpkZWN5cmlsbGljCmllY3lyaWxsaWMLemhlY3lyaWxsaWMKemVjeXJpbGxpYwppaWN5cmlsbGljD2lpc2hvcnRjeXJpbGxpYwprYWN5cmlsbGljCmVsY3lyaWxsaWMKZW1jeXJpbGxpYwplbmN5cmlsbGljCW9jeXJpbGxpYwpwZWN5cmlsbGljCmVyY3lyaWxsaWMKZXNjeXJpbGxpYwp0ZWN5cmlsbGljCXVjeXJpbGxpYwplZmN5cmlsbGljC2toYWN5cmlsbGljC3RzZWN5cmlsbGljC2NoZWN5cmlsbGljC3NoYWN5cmlsbGljDXNoY2hhY3lyaWxsaWMQaGFyZHNpZ25jeXJpbGxpYwx5ZXJpY3lyaWxsaWMQc29mdHNpZ25jeXJpbGxpYxFlcmV2ZXJzZWRjeXJpbGxpYwppdWN5cmlsbGljCmlhY3lyaWxsaWMHdW5pMDQ1MAppb2N5cmlsbGljC2RqZWN5cmlsbGljC2dqZWN5cmlsbGljCWVjeXJpbGxpYwtkemVjeXJpbGxpYwlpY3lyaWxsaWMKeWljeXJpbGxpYwpqZWN5cmlsbGljC2xqZWN5cmlsbGljC25qZWN5cmlsbGljDHRzaGVjeXJpbGxpYwtramVjeXJpbGxpYxBpaWN5cmlsbGljX2dyYXZlDnVzaG9ydGN5cmlsbGljDGR6aGVjeXJpbGxpYwtZYXRjeXJpbGxpYwt5YXRjeXJpbGxpYwxGaXRhY3lyaWxsaWMMZml0YWN5cmlsbGljEUdoZXVwdHVybmN5cmlsbGljEWdoZXVwdHVybmN5cmlsbGljB3VuaTFFMDIHdW5pMUUwMwd1bmkxRTBBB3VuaTFFMEIHdW5pMUUxRQd1bmkxRTFGB3VuaTFFNDAHdW5pMUU0MQd1bmkxRTU2B3VuaTFFNTcHdW5pMUU2MAd1bmkxRTYxB3VuaTFFNkEHdW5pMUU2QgZXZ3JhdmUGd2dyYXZlBldhY3V0ZQZ3YWN1dGUJV2RpZXJlc2lzCXdkaWVyZXNpcwd1bmkxRUEwB3VuaTFFQTEHdW5pMUVBMgd1bmkxRUEzB3VuaTFFQTQHdW5pMUVBNQd1bmkxRUE2B3VuaTFFQTcHdW5pMUVBOAd1bmkxRUE5B3VuaTFFQUEHdW5pMUVBQgd1bmkxRUFDB3VuaTFFQUQHdW5pMUVBRQd1bmkxRUFGB3VuaTFFQjAHdW5pMUVCMQd1bmkxRUIyB3VuaTFFQjMHdW5pMUVCNAd1bmkxRUI1B3VuaTFFQjYHdW5pMUVCNwd1bmkxRUI4B3VuaTFFQjkHdW5pMUVCQQd1bmkxRUJCB3VuaTFFQkMHdW5pMUVCRAd1bmkxRUJFB3VuaTFFQkYHdW5pMUVDMAd1bmkxRUMxB3VuaTFFQzIHdW5pMUVDMwd1bmkxRUM0B3VuaTFFQzUHdW5pMUVDNgd1bmkxRUM3B3VuaTFFQzgHdW5pMUVDOQd1bmkxRUNBB3VuaTFFQ0IHdW5pMUVDQwd1bmkxRUNEB3VuaTFFQ0UHdW5pMUVDRgd1bmkxRUQwB3VuaTFFRDEHdW5pMUVEMgd1bmkxRUQzB3VuaTFFRDQHdW5pMUVENQd1bmkxRUQ2B3VuaTFFRDcHdW5pMUVEOAd1bmkxRUQ5B3VuaTFFREEHdW5pMUVEQgd1bmkxRURDB3VuaTFFREQHdW5pMUVERQd1bmkxRURGB3VuaTFFRTAHdW5pMUVFMQd1bmkxRUUyB3VuaTFFRTMHdW5pMUVFNAd1bmkxRUU1B3VuaTFFRTYHdW5pMUVFNwd1bmkxRUU4B3VuaTFFRTkHdW5pMUVFQQd1bmkxRUVCB3VuaTFFRUMHdW5pMUVFRAd1bmkxRUVFB3VuaTFFRUYHdW5pMUVGMAd1bmkxRUYxBllncmF2ZQZ5Z3JhdmUHdW5pMUVGNAd1bmkxRUY1B3VuaTFFRjYHdW5pMUVGNwd1bmkxRUY4B3VuaTFFRjkJYWZpaTAwMjA4DGZvdXJzdXBlcmlvcgRFdXJvBm51bWVybwd1bmkyMTE3B3VuaTIxMjYHdW5pMjIwNgt6ZXJva2F5YWhsaQpvbmVrYXlhaGxpCnR3b2theWFobGkMdGhyZWVrYXlhaGxpC2ZvdXJrYXlhaGxpC2ZpdmVrYXlhaGxpCnNpeGtheWFobGkMc2V2ZW5rYXlhaGxpDGVpZ2h0a2F5YWhsaQtuaW5la2F5YWhsaQlrYWtheWFobGkKa2hha2F5YWhsaQlnYWtheWFobGkKbmdha2F5YWhsaQlzYWtheWFobGkKc2hha2F5YWhsaQl6YWtheWFobGkKbnlha2F5YWhsaQl0YWtheWFobGkKaHRha2F5YWhsaQluYWtheWFobGkJcGFrYXlhaGxpCnBoYWtheWFobGkJbWFrYXlhaGxpCWRha2F5YWhsaQliYWtheWFobGkJcmFrYXlhaGxpCXlha2F5YWhsaQlsYWtheWFobGkJd2FrYXlhaGxpCnRoYWtheWFobGkJaGFrYXlhaGxpCXZha2F5YWhsaQljYWtheWFobGkIYWtheWFobGkJb2VrYXlhaGxpCGlrYXlhaGxpCW9va2F5YWhsaQl1ZWtheWFobGkIZWtheWFobGkIdWtheWFobGkJZWVrYXlhaGxpCG9rYXlhaGxpDXBsb3BodWtheWFobGkMY2FseWFrYXlhaGxpEmNhbHlhcGxvcGh1a2F5YWhsaQpjd2lrYXlhaGxpC3NoeWFrYXlhaGxpEGNpcmN1bWZsZXguYWN1dGUQY2lyY3VtZmxleC5ncmF2ZQ9jaXJjdW1mbGV4Lmhvb2sQY2lyY3VtZmxleC50aWxkZQticmV2ZS5hY3V0ZQticmV2ZS5ncmF2ZQpicmV2ZS5ob29rC2JyZXZlLnRpbGRlCkEuc21hbGxjYXAKRS5zbWFsbGNhcApJLnNtYWxsY2FwCk8uc21hbGxjYXAAAAAAAAH//wACAAAAAQAAAADFeA+eAAAAAMWVEv0AAAAAxa1cAg=="
					),
				}
			)
		),
		Templeos = Font.new(
			fishy.fonts.cache:Register_Font(
				"Templeos",
				400,
				"normal",
				{
					Id = "Templeos.ttf",
					Font = crypt.base64.decode(
						"AAEAAAAKAIAAAwAgT1MvMp4t7h4AAAEoAAAAZGNtYXAm9O+4AAAGlAAABuxnbHlmHgoliQAAEowAAHWsaGVhZBfxx9oAAACsAAAANmhoZWEF3gP/AAAA5AAAACRobXR45OBLZAAAAYwAAAUIbG9jYQBJk6wAAA2AAAAFDG1heHABYwCCAAABCAAAACBuYW1lOGOLGAAAiDgAAAPicG9zdPzl6lkAAIwcAAAIcwABAAAAAQAAa/CQll8PPPUAAwMgAAAAANreQrIAAAAA2t5CsgAA/5wDIAK8AAAACAAAAAEAAAAAAAEAAAK8/5wAAAMgAAAAAAMgAAEAAAAAAAAAAAAAAAAAAAFCAAEAAAFCAIAAIAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAABQMgAfQABQAAAyADIAAAAZADIAMgAAABkABkAV4AAAIAAAkAAAAAAACAAAKPEgAYeAIAAAAAAAAAS0JuUADAACD//wK8/5wAAAK8AGQAAAAAAAAAAAH0ArwAAAAgAAAAAP//AAAAAAAAAAAAAAAAAyAAAAMgAMgDIABkAyAAZAMgAGQDIABkAyAAZAMgASwDIADIAyAAyAMgAGQDIABkAyAAyAMgAGQDIAEsAyAAZAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIAEsAyAAyAMgAGQDIABkAyAAyAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAMgDIABkAyAAAAMgAMgDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAMgDIABkAyAAZAMgAMgDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIABkAyAAZAMgAGQDIAEsAyAAyAMgAGQDIADIAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAZAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAZAMgAAADIAAAAyAAAAMgAGQDIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIABkAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAZAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAGQDIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIABkAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAZAMgAAADIAAAAyAAAAMgASwDIAEsAyAAAAMgASwDIAAAAyABLAMgAAADIAAAAyAAAAMgAAADIAAAAyAAyAMgASwDIADIAyAAyAMgAAADIAAAAyAAAAMgASwDIADIAyAAyAMgAAADIAAAAyAAAAMgASwDIADIAyAAyAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIABkAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAGQAyAAyAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAGQDIABkAyAAAAMgAAADIAAAAyAAAAMgASwDIAAAAyAAZAMgASwDIABkAyAAyAMgASwDIAAAAyAAAAMgAAADIAAAAyAAAAMgAMgDIADIAyAAZAMgAGQDIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIADIAyAAZAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAAAAyAAAAMgAAADIAEsAyAAyAMgAAADIAAAAyAAAAAAAAMAAAADAAAC1AADAAEAAAAcAAMACgAAAtQABAK4AAAAqgCAAAYAKgB+AKMApQCnAKsAsgC2AL8AxADGAMkA1gDcAOIA5ADvAPQA9wD8AP8BMwInA5MDowOmA6kDsgO1A7gDvAPAA8QEAQQUBBkEGwQfBCQEKwQvBDQEOAQ9BD8EQgREBE8EUSAeIRYhUyFhIZEhkyIaIh4iSCJhImUlACUCJQwlECUUJRglHCUkJSwlNCU8JWwlgCWEJYgljCWTK3ArcuAS4B/gKeA14DngQP//AAAAIAChAKUApwCrALEAtgC7AMQAxgDJANYA3ADgAOQA5gDyAPYA+QD/ATMCJgOTA6MDpgOpA7EDtAO4A7wDwAPDBAEEEgQWBBsEHwQjBCYELQQxBDYEOgQ/BEIERARHBFEgHSEWIVMhYCGRIZMiGiIeIkgiYSJkJQAlAiUMJRAlFCUYJRwlJCUsJTQlPCVQJYAlhCWIJYwlkCtwK3LgAeAU4CHgK+A34ED////j/8H/wP+//7z/t/+0/7D/rP+r/6n/nf+Y/5X/lP+T/5H/kP+P/43/Wv5o/P387vzs/Or84/zi/OD83fza/Nj8nPyM/Iv8ivyH/IT8g/yC/IH8gPx//H78fPx7/Hn8eOCt37bfet9u3z/fPt643rXejN503nLb2NvX287by9vI28Xbwtu727Tbrdum25PbgNt923rbd9t01ZjVlyEJIQghByEGIQUg/wABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAAAAAEGAAAAAAAAABWAAAAIAAAAH4AAAADAAAAoQAAAKMAAABiAAAApQAAAKUAAABlAAAApwAAAKcAAABmAAAAqwAAAKsAAABnAAAAsQAAALIAAABoAAAAtgAAALYAAABqAAAAuwAAAL8AAABrAAAAxAAAAMQAAABwAAAAxgAAAMYAAABxAAAAyQAAAMkAAAByAAAA1gAAANYAAABzAAAA3AAAANwAAAB0AAAA4AAAAOIAAAB1AAAA5AAAAOQAAAB4AAAA5gAAAO8AAAB5AAAA8gAAAPQAAACDAAAA9gAAAPcAAACGAAAA+QAAAPwAAACIAAAA/wAAAP8AAACMAAABMwAAATMAAACNAAACJgAAAicAAACOAAADkwAAA5MAAACQAAADowAAA6MAAACRAAADpgAAA6YAAACSAAADqQAAA6kAAACTAAADsQAAA7IAAACUAAADtAAAA7UAAACWAAADuAAAA7gAAACYAAADvAAAA7wAAACZAAADwAAAA8AAAACaAAADwwAAA8QAAACbAAAEAQAABAEAAACdAAAEEgAABBQAAACeAAAEFgAABBkAAAChAAAEGwAABBsAAAClAAAEHwAABB8AAACmAAAEIwAABCQAAACnAAAEJgAABCsAAACpAAAELQAABC8AAACvAAAEMQAABDQAAACyAAAENgAABDgAAAC2AAAEOgAABD0AAAC5AAAEPwAABD8AAAC9AAAEQgAABEIAAAC+AAAERAAABEQAAAC/AAAERwAABE8AAADAAAAEUQAABFEAAADJAAAgHQAAIB4AAADKAAAhFgAAIRYAAADMAAAhUwAAIVMAAADNAAAhYAAAIWEAAADOAAAhkQAAIZEAAADQAAAhkwAAIZMAAADRAAAiGgAAIhoAAADSAAAiHgAAIh4AAADTAAAiSAAAIkgAAADUAAAiYQAAImEAAADVAAAiZAAAImUAAADWAAAlAAAAJQAAAADYAAAlAgAAJQIAAADZAAAlDAAAJQwAAADaAAAlEAAAJRAAAADbAAAlFAAAJRQAAADcAAAlGAAAJRgAAADdAAAlHAAAJRwAAADeAAAlJAAAJSQAAADfAAAlLAAAJSwAAADgAAAlNAAAJTQAAADhAAAlPAAAJTwAAADiAAAlUAAAJWwAAADjAAAlgAAAJYAAAAEAAAAlhAAAJYQAAAEBAAAliAAAJYgAAAECAAAljAAAJYwAAAEDAAAlkAAAJZMAAAEEAAArcAAAK3AAAAEIAAArcgAAK3IAAAEJAADgAQAA4BIAAAEKAADgFAAA4B8AAAEcAADgIQAA4CkAAAEoAADgKwAA4DUAAAExAADgNwAA4DkAAAE8AADgQAAA4EAAAAE/AAHUUwAB1FMAAAFAAAH1FAAB9RQAAAFBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABUAAAAiAAAARwAAAHAAAACRAAAAvgAAAMYAAADeAAAA9gAAAQ4AAAEeAAABKgAAATIAAAE6AAABUgAAAW8AAAF/AAABnwAAAb8AAAHYAAAB8AAAAg0AAAIjAAACRAAAAmEAAAJuAAACfwAAAp8AAAKsAAACzAAAAukAAAMEAAADGQAAAzIAAANKAAADYwAAA3MAAAOBAAADmwAAA6sAAAO7AAADzwAAA+8AAAP5AAAEEQAABCUAAAQ6AAAETQAABG4AAASHAAAEpwAABLMAAATDAAAE1wAABO8AAAUPAAAFIwAABT8AAAVLAAAFYwAABW8AAAV/AAAFhwAABZcAAAWuAAAFwQAABdkAAAXsAAAGAwAABhcAAAYuAAAGPgAABlEAAAZkAAAGgAAABo4AAAamAAAGtAAABskAAAbcAAAG8QAABwYAAAceAAAHMgAAB0AAAAdUAAAHbAAAB4wAAAegAAAHuAAAB9AAAAfYAAAH8AAACA0AAAgiAAAIOgAACFwAAAh8AAAIrQAACNoAAAjvAAAJBQAACSAAAAlNAAAJegAACasAAAnGAAAJ4wAACgUAAAokAAAKOQAACl8AAAp4AAAKlQAACq4AAArTAAAK9QAACxIAAAs0AAALTwAAC2oAAAuNAAALrQAAC8AAAAvTAAAL7gAADAUAAAweAAAMNwAADFgAAAx2AAAMhwAADJwAAAyxAAAMzgAADOcAAA0CAAANHAAADTUAAA1SAAANXgAADYIAAA2nAAANywAADewAAA4JAAAOKAAADkQAAA5tAAAOgQAADpEAAA6mAAAOvAAADtUAAA7sAAAO+AAADxMAAA81AAAPTwAAD2gAAA+PAAAPpgAAD7IAAA/VAAAP9gAAEAQAABAVAAAQJQAAEDcAABBMAAAQYwAAEIEAABCfAAAQvwAAEN0AABD2AAARAgAAER0AABE/AAARWQAAEX4AABGcAAARswAAEcwAABHcAAAR6AAAEfQAABIVAAASJgAAEjYAABJIAAASXQAAEnQAABKHAAASpQAAEsMAABLeAAAS/gAAExgAABMyAAATTwAAE3UAABOFAAATmgAAE7MAABPMAAAT4AAAE/kAABQgAAAUMQAAFE4AABRrAAAUcwAAFHsAABSFAAAUjwAAFJkAABSjAAAUrwAAFLsAABTHAAAU0wAAFOMAABTwAAAU/QAAFQsAABUZAAAVKgAAFTgAABVGAAAVVwAAFWUAABVzAAAVhAAAFZIAABWgAAAVsQAAFcEAABXSAAAV5wAAFfcAABYIAAAWHQAAFi4AABY+AAAWUwAAFmQAABZ0AAAWiQAAFp4AABazAAAW0QAAFtkAABbhAAAW6QAAFvEAABb5AAAXMwAAF8cAABgSAAAYKgAAGEIAABhCAAAYWgAAGH0AABiQAAAYqQAAGMAAABjZAAAY4wAAGO0AABkUAAAZJAAAGTQAABlEAAAZWQAAGWEAABlvAAAZdwAAGX8AABmnAAAZzwAAGe4AABoHAAAaIgAAGioAABoyAAAaQwAAGlkAABqBAAAaoQAAGtIAABrqAAAbDQAAGyIAABsvAAAbPAAAG1IAABtyAAAbkQAAG6cAABvQAAAb+QAAHBIAABwjAAAcRgAAHF4AAByCAAAcqQAAHMEAABzhAAAdAwAAHQsAAB0TAAAdGwAAHTcAAB1XAAAdawAAgDIAAACWAK8AAsADwAACQ8AyAAAAGQAAADIAAAAZAAA/5wAAP84AAAAAAAAAMgAAAGQAMgAAABkAAD/nAAA/zgAAP84AAAAyP5wAGQAAP+cAAAAAgBkAZACWAK8AAMABwAACQcBkAAAAMgAAP4MAAAAyAAAAZABLAAA/tQAAAEsAAD+1AAAAAIAZAAAAyACvAAbAB8AAAkfAMj/nAAAAGQAAP+cAAAAZAAAAMgAAABkAAAAyAAAAGQAAP+cAAAAZAAA/5wAAP84AAD/nAAA/zgAyAAAAGQAAADIAAAAZAAAAGQAAABkAAAAyAAA/zgAAADIAAD/OAAA/5wAAP+cAAD/nAAA/zgAAADIAAD/OAAAAZD/nAAAAGQAAAADAGQAAAMgArwAGwAfACMAAAkjAMgAAADIAAAAyAAAAMgAAP7UAAAAyAAAAGQAAP+cAAD/OAAA/zgAAP84AAABLAAA/zgAAP+cAAABLP+cAAAAZADIAAD/nAAAAfQAZAAAAGQAAP+cAAD/nAAA/5wAAP+cAAD/nAAA/5wAAP+cAAAAZAAAAGQAAABkAAAAZAAAAGQAAAAA/5wAAP84AGQAAP+cAAMAZAAAArwCvAATABcAGwAACRsAyAAAAGQAAABkAAAAZAAAAMgAAP+cAAD/nAAA/5wAAP+cAAD/OAAAAAAAAADIAAAAyADIAAD/OADIAGQAAABkAAAAZAAAAGQAAP+cAAD/nAAA/5wAAP+cAAD/nAAAAGQBLADIAAD/OP7UAAD/OAAAAAMAZAAAAyACvAAfACMAJwAACScAyP+cAAAAZAAA/5wAAABkAAABLAAAAGQAAP+cAAAAZAAAAGQAAABkAAD/OAAA/5wAAP+cAAD/nAAAAMgAAP7UAMgAAP+cAAAB9P+cAAAAZABkAAAAyAAAAGQAAADIAAAAZAAA/5wAAP84AAD/nAAA/5wAAP+cAAD/nAAAAGQAAABkAAAAZAAA/zgAAP+cAAABkADIAAD/OP84AAAAZAAAAAEBLAGQAfQCvAADAAAJAwH0/zgAAADIAZAAAAEsAAAAAQDIAAACWAK8ABMAAAkTAMgAAABkAAAAZAAAAMgAAP+cAAD/nAAAAGQAAABkAAD/OAAA/5wAAADIASwAAABkAAAAZAAA/5wAAP+cAAD+1AAA/5wAAP+cAAAAZAAAAGQAAQDIAAACWAK8ABMAAAkTAMgAAABkAAAAZAAA/5wAAP+cAAAAyAAAAGQAAABkAAD/nAAA/5wAAAAAAGQAAABkAAABLAAAAGQAAABkAAD/nAAA/5wAAP7UAAD/nAAA/5wAAQBkAGQCvAJYABMAAAkTAGQAAABkAAD/nAAAAMgAAADIAAAAyAAA/5wAAABkAAD/OAAA/zgAAADIAGQAAABkAAAAZAAAAGQAAP+cAAD/nAAA/5wAAP+cAAD/nAAAAGQAAQBkAGQCvAJYAAsAAAkLAfT/OAAA/zgAAADIAAAAyAAAAMgAAP84AGQAAADIAAAAZAAAAMgAAP84AAD/nAAAAAEAyP+cAfQAyAAHAAAJBwGQAAD/OAAAAGQAAADIAAAAAP+cAAAAZAAAAMgAAP84AAEAZAEsArwBkAADAAAJAwBkAAACWAAAASwAZAAA/5wAAQEsAAAB9ADIAAMAAAkDAfQAAP84AAAAyP84AAAAyAABAGQAZAK8AlgAEwAACRMAZAAAAGQAAABkAAAAZAAAAGQAAADIAAD/nAAA/5wAAP+cAAD/nAAAAGQAZAAAAGQAAABkAAAAZAAAAGQAAP+cAAD/nAAA/5wAAP+cAAD/nAADAGQAAAK8ArwACwARABcAAAkXAGQAAABkAAABkAAAAGQAAP+cAAD+cAAAAGQAAADIAAD/nAAA/5wAZAAAAGQAAP84AGQB9AAAAGQAAP+cAAD+DAAA/5wAAABkAGT/nAAAAMgAAP+cAMgAAABkAAAAZAAAAAEAZAAAArwCvAALAAAJCwBkAAAAyAAA/5wAAABkAAAAyAAAAMgAAAAAAGQAAAGQAAAAZAAAAGQAAP2oAAD/nAABAGQAAAK8ArwAGwAACRsAyAAAAGQAAABkAAAAZAAA/zgAAP84AAAAZAAAAZAAAABkAAD/nAAA/5wAAP+cAAABLAAA/agAAABkAGQAAABkAAAAZAAAAMgAAP+cAAAAZAAAAGQAAP+cAAD/OAAA/5wAAP+cAAD/nAAA/5wAAABkAAEAZAAAArwCvAAbAAAJGwDI/5wAAADIAAAAyAAA/zgAAADIAAD/OAAA/zgAAABkAAABkAAAAGQAAP+cAAAAZAAA/5wAAP5wAGQAAABkAAD/nAAAAMgAAABkAAAAyAAA/5wAAABkAAAAZAAA/5wAAP84AAD/nAAA/zgAAP+cAAAAAgBkAAACvAK8AA8AEwAACRMAZAAAAGQAAABkAAAAZAAAAMgAAABkAAD/nAAA/zgAAP+cAAAAZAAAAMgAyAAAAGQAAABkAAAAZAAA/nAAAP+cAAD/OAAAAMgAyP+cAAAAZAAAAAEAZAAAArwCvAATAAAJEwBkAAAAyAAAAMgAAP5wAAACWAAA/nAAAAEsAAAAZAAA/5wAAP5wAAAAZABkAAD/nAAAASwAAAEsAAD/nAAA/5wAAP+cAAD+1AAA/5wAAABkAAIAZAAAArwCvAATABcAAAkXAGQAAABkAAAAZAAAASwAAP84AAD/nAAAASwAAABkAAD/nAAA/nAAAABkAMgAAP84AGQBkAAAAGQAAABkAAD/nAAA/5wAAP+cAAD/nAAA/zgAAP+cAAAAZAAAAAAAyAAAAAAAAQBkAAACvAK8ABEAAAkRAGQAAAJYAAD/nAAA/5wAAP+cAAD/OAAAAGQAAABkAAAAZAAAAlgAZAAA/zgAAP+cAAD/nAAA/tQAAAEsAAAAZAAAAGQAAABkAAMAZAAAArwCvAATABcAGwAACRsAyP+cAAAAZAAA/5wAAABkAAABkAAAAGQAAP+cAAAAZAAA/5wAAP5wAGQAyAAA/zgAAADIAAD/OABkAAAAyAAAAGQAAADIAAAAZAAA/5wAAP84AAD/nAAA/zgAAP+cAAAAZAAAAMgAAABkAAAAyAAAAAIAZAAAArwCvAATABcAAAkXAGQAAABkAAABkAAAAGQAAP+cAAD/nAAA/tQAAADIAAAAZAAA/tQAAABkAMgAAP84AZAAyAAAAGQAAP+cAAD+cAAA/5wAAP+cAAAAZAAAAGQAAABkAAAAZAAAAAAAyAAAAAAAAgEsAAAB9AH0AAMABwAACQcB9AAA/zgAAADIAAD/OAAAAMj/OAAAAMgBLP84AAAAyAAAAAIAyP+cAfQB9AAHAAsAAAkLAZAAAP84AAAAZAAAAMgAAAAAAAD/OAAAAAD/nAAAAGQAAADIAAD/OAH0/zgAAADIAAAAAQBkAAACWAK8ABsAAAkbAMgAAP+cAAAAZAAAAGQAAABkAAAAyAAA/5wAAP+cAAD/nAAAAGQAAABkAAAAZAAA/zgAAP+cAAAAyABkAAAAZAAAAGQAAABkAAAAZAAA/5wAAP+cAAD/nAAA/5wAAP+cAAD/nAAA/5wAAABkAAAAZAACAGQAyAK8AfQAAwAHAAAJBwBkAAACWAAA/agAAAJYAAAAyABkAAD/nADIAGQAAP+cAAAAAQDIAAACvAK8ABsAAAkbAMgAAABkAAAAZAAAAGQAAP+cAAD/nAAA/5wAAADIAAAAZAAAAGQAAABkAAD/nAAA/5wAAP+cAAAAAABkAAAAZAAAAGQAAABkAAAAZAAAAGQAAABkAAD/nAAA/5wAAP+cAAD/nAAA/5wAAP+cAAD/nAACAGQAAAK8ArwAEwAXAAAJFwBkAAAAZAAAAZAAAABkAAD/nAAA/5wAAP84AAAAZAAAAGQAAP84AAAAAAAAAMgAAAH0AGQAAABkAAD/nAAA/5wAAP+cAAD/OAAAAMgAAABkAAAAZAAA/5z+DABkAAD/nAAAAAIAZAAAArwCvAARABUAAAkVAGQAAABkAAABkAAAAGQAAP7UAAAAZAAA/zgAAAEsAAD+cAAAASwAAABkAAAAZAH0AAAAZAAA/5wAAP5wAAABLAAAAGQAAP4MAAD/nAAAAGQBLP+cAAAAZAAAAAIAZAAAArwCvAALAA8AAAkPAGQAAABkAAABkAAAAGQAAP84AAD/OAAAAAAAyAAA/zgAAAJYAAAAZAAA/5wAAP2oAAABLAAA/tQBkAAAAMgAAAAAAAMAZAAAArwCvAALAA8AEwAACRMAZAAAAfQAAABkAAD/nAAAAGQAAP+cAAD+1ADIAAD/OAAAAMgAAP84AAACvAAA/5wAAP84AAD/nAAA/zgAAP+cAGQAAADIAAAAZAAAAMgAAAABAGQAAAK8ArwAEwAACRMAZAAAAGQAAAGQAAAAZAAA/zgAAP84AAAAyAAAAMgAAP+cAAD+cAAAAGQB9AAAAGQAAP+cAAD/nAAAAGQAAP4MAAAAZAAA/5wAAP+cAAAAZAACAGQAAAK8ArwACwATAAAJEwBkAAABkAAAAGQAAABkAAD/nAAA/5wAAP84AGQAAABkAAD/nAAA/5wAAAK8AAD/nAAA/5wAAP7UAAD/nAAA/5wAZAAAAGQAAAEsAAAAZAAAAAAAAQBkAAACvAK8AAsAAAkLAGQAAAJYAAD+cAAAASwAAP7UAAABkAAAAAACvAAA/5wAAP84AAD/nAAA/zgAAP+cAAEAZAAAArwCvAAJAAAJCQBkAAACWAAA/nAAAAEsAAD+1AAAAAACvAAA/5wAAP84AAD/nAAA/tQAAQBkAAACvAK8ABUAAAkVAGQAAABkAAABkAAAAGQAAP84AAD/OAAAAMgAAP+cAAABLAAA/5wAAP5wAAAAZAH0AAAAZAAA/5wAAP+cAAAAZAAA/gwAAADIAAAAZAAA/tQAAP+cAAAAZAABAGQAAAK8ArwACwAACQsAZAAAAMgAAADIAAAAyAAA/zgAAP84AAAAAAK8AAD+1AAAASwAAP1EAAABLAAA/tQAAQBkAAACvAK8AAsAAAkLAGQAAADIAAD/OAAAAlgAAP84AAAAyAAAAAAAZAAAAfQAAABkAAD/nAAA/gwAAP+cAAEAZAAAArwCvAAPAAAJDwBkAAAAyAAAAGQAAP84AAAB9AAA/5wAAP+cAAD+1AAAAGQAZAAA/5wAAAH0AAAAZAAA/5wAAP4MAAD/nAAAAGQAAQBkAAACvAK8ABsAAAkbAZD/nAAA/zgAAADIAAAAZAAAAGQAAADIAAD/nAAA/5wAAP+cAAAAZAAAAGQAAABkAAD/OAAA/5wAyAAA/zgAAAK8AAD/OAAAAGQAAABkAAD/nAAA/5wAAP+cAAD/nAAA/5wAAP+cAAD/nAAAAGQAAAABAGQAAAK8ArwABQAACQUAZAAAAMgAAAGQAAAAAAK8AAD9qAAA/5wAAQBkAAADIAK8ABMAAAkTAyD/OAAA/5wAAP+cAAD/nAAA/zgAAADIAAAAZAAAAGQAAABkAAAAyAAAAAABkAAA/zgAAADIAAD+cAAAArwAAP+cAAD/nAAAAGQAAABkAAAAAQBkAAACvAK8AA8AAAkPAGQAAADIAAAAZAAAAGQAAADIAAD/OAAA/5wAAP+cAAAAAAK8AAD/OAAA/5wAAAEsAAD9RAAAAMgAAABkAAD+1AACAGQAAAK8ArwACwAPAAAJDwBkAAAAZAAAAZAAAABkAAD/nAAA/nAAAABkAMgAAP84AGQB9AAAAGQAAP+cAAD+DAAA/5wAAABkAAAAAAH0AAAAAAACAGQAAAK8ArwACQANAAAJDQBkAAAB9AAAAGQAAP+cAAD+1AAAAAAAyAAA/zgAAAK8AAD/nAAA/zgAAP+cAAD+1AGQAAAAyAAAAAAAAgBkAAACvAK8ABEAGwAACRsAyP+cAAAAZAAAAZAAAABkAAD/nAAA/5wAAP84AAAAZAAA/zgAyAAAAGQAAABkAAAAZAAA/zgAAABkAAAB9AAAAGQAAP+cAAD+cAAAAGQAAAEsAAD+DAAA/5wAAABkAMgAAP+cAAD/nAAA/5wAAABkAAAAAgBkAAACvAK8AA8AEwAACRMAZAAAAfQAAABkAAD/nAAAAGQAAP84AAD/nAAA/5wAAAAAAMgAAP84AAACvAAA/5wAAP84AAD/OAAA/zgAAADIAAAAZAAA/tQBkAAAAMgAAAAAAAEAZAAAArwCvAAbAAAJGwDI/5wAAADIAAAAyAAA/tQAAP+cAAAAZAAAAZAAAABkAAD/OAAA/zgAAAEsAAAAZAAA/5wAAP5wAGQAAABkAAD/nAAAAMgAAABkAAAAyAAAAGQAAP+cAAD/nAAAAGQAAP84AAD/nAAA/zgAAP+cAAAAAQBkAAACvAK8AAcAAAkHAfT/OAAA/zgAAAJYAAD/OAAAAAACWAAAAGQAAP+cAAAAAQBkAAACvAK8AAsAAAkLAGQAAADIAAAAyAAAAMgAAP+cAAD+cAAAAGQCWAAA/agAAAJYAAD9qAAA/5wAAABkAAEAZAAAArwCvAAPAAAJDwBkAAAAyAAAAMgAAADIAAD/nAAA/5wAAP84AAD/nAAAAMgB9AAA/gwAAAH0AAD+DAAA/5wAAP+cAAAAZAAAAGQAAQBkAAADIAK8ABMAAAkTAyD/OAAA/5wAAP+cAAD/nAAA/zgAAADIAAAAZAAAAGQAAABkAAAAyAAAAAAAZAAAAGQAAP+cAAD/nAAAArwAAP5wAAAAyAAA/zgAAAGQAAAAAQBkAAACvAK8ABsAAAkbAMgAAABkAAD/nAAA/5wAAADIAAAAyAAAAMgAAP+cAAD/nAAAAGQAAABkAAD/OAAA/zgAAP84AAAAyABkAAAAZAAAAGQAAADIAAD/OAAAAMgAAP84AAD/nAAA/5wAAP+cAAD/OAAAAMgAAP84AAAAyAABAGQAAAK8ArwADwAACQ8AZAAAAMgAAADIAAAAyAAA/5wAAP+cAAD/OAAA/5wAAAGQASwAAP7UAAABLAAA/tQAAP+cAAD+1AAAASwAAABkAAEAZAAAArwCvAAXAAAJFwBkAGQAAABkAAAAZAAAAGQAAP5wAAACWAAA/5wAAP+cAAD/nAAA/5wAAAGQAAD9qADIAAAAZAAAAGQAAABkAAAAZAAAAGQAAP84AAD/nAAA/5wAAP+cAAD/nAAA/5wAAAABAGQAAAJYArwABwAACQcAZAAAAfQAAP7UAAABLAAAAAACvAAA/5wAAP4MAAD/nAABAGQAZAK8AlgAEwAACRMAZAAAAMgAAABkAAAAZAAAAGQAAABkAAD/OAAA/5wAAP+cAAD/nAAAAfQAZAAA/5wAAP+cAAD/nAAA/5wAAP+cAAAAZAAAAGQAAABkAAAAZAABAMgAAAK8ArwABwAACQcB9AAA/tQAAAH0AAD+DAAAAGQB9AAAAGQAAP1EAAAAZAABAGQB9AK8ArwACwAACQsAZAAAAGQAAAGQAAAAZAAA/zgAAP84AAAB9ABkAAAAZAAA/5wAAP+cAAAAZAAA/5wAAQAA/5wDIABkAAMAAAkDAAADIAAA/OAAZAAA/zgAAAABAMgBkAJYArwACwAACQsBkP+cAAD/nAAAAMgAAABkAAAAZAAA/zgB9AAAAGQAAABkAAD/nAAA/5wAAP+cAAAAAgBkAAACvAH0AA0AEQAACREAZAAAAGQAAAEsAAD+1AAAAZAAAABkAAD+DAAAAGQAAADIAAAAZABkAAAAZAAAAGQAAABkAAD/nAAA/nAAAABkAGT/nAAAAGQAAAACAGQAAAK8ArwACQANAAAJDQBkAAAAyAAAASwAAABkAAD/nAAA/tQAyAAA/zgAAAK8AAD/OAAA/5wAAP7UAAD/nABkAAABLAAAAAAAAQBkAAACvAH0ABMAAAkTAGQAAABkAAABkAAAAGQAAP84AAD/OAAAAMgAAADIAAD/nAAA/nAAAABkASwAAABkAAD/nAAA/5wAAABkAAD+1AAAAGQAAP+cAAD/nAAAAGQAAgBkAAACvAK8AAkADQAACQ0AZAAAAGQAAAEsAAAAyAAA/gwAAABkAMgAAP84AGQBLAAAAGQAAADIAAD9RAAAAGQAAAAAASwAAAAAAAIAZAAAArwB9AANABEAAAkRAGQAAABkAAABkAAAAGQAAP5wAAABLAAA/nAAAABkAAAAyAAAAGQBLAAAAGQAAP+cAAD/OAAA/5wAAP+cAAAAZAEs/5wAAABkAAAAAQBkAAACWAK8AA8AAAkPAGQAAABkAAAAZAAAASwAAP84AAAAyAAA/zgAAP84AAABLABkAAAAyAAAAGQAAP+cAAD/OAAA/5wAAP7UAAABLAACAGT/nAK8AfQADQARAAAJEQBkAAAAZAAAAfQAAP+cAAD+cAAAASwAAP7UAAAAZADIAAD/OADIAMgAAABkAAD+DAAA/5wAAABkAAAAZAAAAGQAAAAAAMgAAAAAAAEAZAAAArwCvAALAAAJCwBkAAAAyAAAASwAAABkAAD/OAAA/zgAAAAAArwAAP84AAD/nAAA/nAAAAGQAAD+cAACAMgAAAJYArwACQANAAAJDQDIAAAAZAAA/5wAAAEsAAAAZAAA/tQAAADIAAAAAABkAAABLAAAAGQAAP5wAAD/nAJYAGQAAP+cAAAAAgBk/5wB9AK8AAkADQAACQ0AZAAAAMgAAP+cAAABLAAA/5wAAP+cAAAAyAAA/5wAZAAAAZAAAABkAAD+DAAA/5wCvABkAAD/nAAAAAEAZAAAArwCvAAXAAAJFwBkAAAAyAAAAGQAAABkAAAAyAAA/5wAAP+cAAAAZAAAAGQAAP84AAD/nAAA/5wAAAAAArwAAP5wAAAAZAAAAGQAAP+cAAD/nAAA/5wAAP+cAAD/nAAAAGQAAABkAAD/OAABAMgAAAJYArwACQAACQkB9ABkAAD+cAAAAGQAAP+cAAABLABkAAD/nAAAAGQAAAH0AAAAZAAAAAEAZAAAAyAB9AATAAAJEwMg/zgAAP+cAAD/nAAA/5wAAP84AAAAZAAAAMgAAABkAAAAyAAAAGQAAAAAASwAAP84AAAAyAAA/tQAAAGQAAAAZAAA/5wAAABkAAD/nAAAAAEAZAAAArwB9AAJAAAJCQBkAAAB9AAAAGQAAP84AAD/OAAAAAAB9AAA/5wAAP5wAAABkAAA/nAAAgBkAAACvAH0AAsADwAACQ8AZAAAAGQAAAGQAAAAZAAA/5wAAP5wAAAAZADIAAD/OABkASwAAABkAAD/nAAA/tQAAP+cAAAAZAAAAAABLAAAAAAAAgBk/5wCvAH0AAkADQAACQ0AZAAAAfQAAABkAAD/nAAA/tQAAAAAAMgAAP84/5wCWAAA/5wAAP84AAD/nAAA/zgBLAAAAMgAAAAAAAIAZP+cAyAB9AALAA8AAAkPAyAAAP7UAAD+1AAA/5wAAABkAAAB9AAA/nAAyAAA/zgAAP+cAAAAyAAAAGQAAADIAAAAZAAA/gwAyAAAAMgAAAAAAAIAZAAAArwB9AAHAA8AAAkPAGQAAADIAAAAZAAA/5wAAABkAAAAyAAAAGQAAP84AAAAAAH0AAD/nAAA/5wAAP7UAZAAZAAA/5wAAP+cAAAAZAAAAAEAZAAAArwB9AATAAAJEwBkAAABkAAA/tQAAP+cAAAAZAAAAfQAAP5wAAABLAAAAGQAAP+cAAAAAABkAAAAZAAAAGQAAABkAAAAZAAA/5wAAP+cAAD/nAAA/5wAAP+cAAEAZAAAAlgCvAAPAAAJDwBkAAAAZAAAAMgAAADIAAD/OAAAAMgAAP7UAAD/nAAAAZAAZAAAAMgAAP84AAD/nAAA/tQAAP+cAAAAZAAAASwAAQBkAAACvAH0AAkAAAkJAGQAAADIAAAAyAAAAMgAAP4MAAAAZAGQAAD+cAAAAZAAAP4MAAAAZAABAGQAAAK8AfQADwAACQ8AZAAAAMgAAADIAAAAyAAA/5wAAP+cAAD/OAAA/5wAAADIASwAAP7UAAABLAAA/tQAAP+cAAD/nAAAAGQAAABkAAEAZAAAAyAB9AATAAAJEwMg/5wAAP84AAD/nAAA/zgAAP+cAAAAyAAAAGQAAABkAAAAZAAAAMgAZAAA/5wAAABkAAD/nAAAAGQAAAGQAAD+1AAAAMgAAP84AAABLAAAAAEAZAAAArwB9AAbAAAJGwDIAAAAZAAA/5wAAP+cAAAAyAAAAMgAAADIAAD/nAAA/5wAAABkAAAAZAAA/zgAAP84AAD/OAAAAGQAZAAAAGQAAABkAAAAZAAA/5wAAABkAAD/nAAA/5wAAP+cAAD/nAAA/5wAAABkAAD/nAAAAGQAAQBk/5wCvAH0AA8AAAkPAGQAAADIAAAAyAAAAMgAAP+cAAD+cAAAASwAAP7UAAAAyAEsAAD+1AAAASwAAP4MAAD/nAAAAGQAAABkAAAAZAABAGQAAAK8AfQAEwAACRMAZAAAAGQAAABkAAAAZAAA/tQAAAJYAAD/nAAA/5wAAP+cAAABLAAAAAAAZAAAAGQAAABkAAAAZAAAAGQAAP+cAAD/nAAA/5wAAP+cAAD/nAABAGQAAAJYArwAEwAACRMAZAAAAMgAAABkAAAAyAAA/5wAAP+cAAAAZAAAAGQAAP84AAD/nAAAASwAZAAAAMgAAABkAAD/nAAA/zgAAP+cAAD/OAAA/5wAAABkAAAAyAABASwAAAH0ArwAAwAACQMB9P84AAAAyAAAAAACvAAAAAEAyAAAArwCvAATAAAJEwDIAAAAZAAAAGQAAP+cAAD/nAAAAMgAAABkAAAAyAAA/zgAAP+cAAAAAABkAAAAyAAAAGQAAADIAAAAZAAA/5wAAP84AAD/nAAA/zgAAP+cAAMAZAGQAyACvAAJABMAFwAACRcDIP+cAAD/OAAAAGQAAABkAAAAZP1EAAAAZAAAAMgAAP+cAAD/nAAAAMgAAABkAAAB9AAA/5wAAABkAAAAZAAAAGQAAP7UAMgAAABkAAD/nAAA/5wAAP+cAGQAZAAA/5wAAgDI/5wCWAJYAAsADwAACQ8AyABkAAAAyAAAAGQAAP+cAAD/OAAA/5wAZAAAAMgAAADIAAAAyAAA/zgAAP84AAD/nAAAAGQAAAH0AGQAAP+cAAAAAQAA/5wCvAK8ABMAAAkTAAAAAABkAAAAyAAAAMgAAADIAAD+DAAAAfQAAP84AAD/OAAA/zgAAADIAMgAAABkAAAAyAAA/zgAAP+cAAD/OAAA/5wAAP84AAAAyAAAAGQAAQAAAAACvAK8AB0AAAkdAAAAZAAA/5wAAABkAAAAZAAAASwAAABkAAD/nAAA/5wAAP+cAAAAZAAA/5wAAADIAAAAyAAA/5wAAP2oAMgAAABkAAAAZAAAAMgAAABkAAD/nAAA/zgAAABkAAAAZAAA/zgAAP+cAAD/OAAAAGQAAP+cAAD/nAAAAAEAAAAAAlgCvAAbAAAJGwAAAAAAyAAA/zgAAABkAAD/nAAAAMgAAADIAAAAyAAA/5wAAABkAAD/OAAAAMgAAP84AAD/OAAAAGQAZAAAAGQAAABkAAAAZAAAAMgAAP84AAAAyAAA/zgAAP+cAAD/nAAA/5wAAP+cAAD/nAAAAGQACgAA/5wB9AK8AAMABwALAA8AEwAXABsAHwAjACcAAAknAAAAAABkAAAAZP+cAAAAZAAAAAAAZAAA/5z/nAAAAGQAAAAAAGQAAP+cAAAAyAAAAAD/nAAAAGQAAAAA/5wAAABkAAAAZAAA/nAAyAAA/zgAAABkAAD/nADIAAAAyAAA/tQAZAAA/5wBkAAAAGQAAP84AGQAAP+cAMgAZAAA/5z+cAAAAMgAAP7U/5wAAABkAZAAZAAA/5z+DAAA/5wAAAAAAAIAAABkAyACWAATACcAAAknAAAAAABkAAAAZAAAAMgAAP+cAAD/nAAAAGQAAABkAAD/OAAA/5wAAAEsAAAAZAAAAGQAAADIAAD/nAAA/5wAAABkAAAAZAAA/zgAAP+cAAABLABkAAAAZAAAAGQAAP+cAAD/nAAA/5wAAP+cAAD/nAAAAGQAAABkAAAAZAAAAGQAAABkAAD/nAAA/5wAAP+cAAD/nAAA/5wAAABkAAAAZAAAAAIAAAAAAlgCvAADAA8AAAkPAAAAAAJYAAD9qAAAAMgAAADIAAAAyAAA/zgAAP84AAAAAABkAAD/nAGQAGQAAADIAAD/OAAA/5wAAP84AAAAyAAAAAEAZADIAlgCvAARAAAJEQBkAAAAZAAAAMgAAP7UAAABkAAAAGQAAP+cAAD/OAAAASwAAADIAMgAAABkAAAAZAAAAGQAAP+cAAD/nAAA/5wAAP+cAAD/nAADAAAAAAH0ArwAAwARABUAAAkVAAAAAABkAAAAAABkAAD/nAAAAZAAAP+cAAD/nAAA/5wAAP+cAMgAZAAA/5wBkADIAAD/OAAAAAAAyAAAAGQAAP1EAAABLAAA/tQAAAEsAAAAZAAAAMgAAAACAAAAZAMgAlgAEwAnAAAJJwAAAAAAZAAAAGQAAP+cAAD/nAAAAMgAAABkAAAAZAAA/5wAAP+cAAAAyAAAAGQAAABkAAD/nAAA/5wAAADIAAAAZAAAAGQAAP+cAAD/nAAAAGQAZAAAAGQAAABkAAAAZAAAAGQAAP+cAAD/nAAA/5wAAP+cAAD/nAAAAGQAAABkAAAAZAAAAGQAAABkAAD/nAAA/5wAAP+cAAD/nAAA/5wAAAACAAD/nAMgArwAGwAnAAAJJwAAAGQAAP+cAAAAyAAAAGQAAABkAAAAZAAAAMgAAP+cAAD/nAAA/5wAAP+cAAD/nAAA/5wAAP+cAZAAAABkAAAAZAAAAMgAAP84AAD+1AAAAMgAAABkAAABkAAA/tQAAABkAAAAZAAAAGQAAP+cAAD/nAAA/5wAAP+cAAD/nAAA/5wAAP+cAAAAZABkAAAAZAAAAGQAAP4MAAAAZAAAAGQAAAACAAD/nAMgArwAJwArAAAJKwAAAGQAAABkAAAAZAAAAGQAAABkAAAAyAAA/5wAAP+cAAAAyAAAAGQAAP+cAAD/OAAAASwAAP4MAAAAZAAAAMgAAP7UAAD/nAAA/5wAAP+cAAAAAADIAAAAyAAAAGQAAABkAAAAZAAAAGQAAABkAAD/nAAA/5wAAP+cAAD/nAAA/5wAAP+cAAD/nAAA/5wAAADIAAAAZAAAAGQAAP+cAAD/nAAA/5wAAAGQASwAAP7UAAAAAgAA/5wB9AK8AAsAFQAACRUAAAAAAGQAAP+cAAAAZAAA/5wAAADIAAAAAABkAAAAZAAAAGQAAP+cAAD/OADIAGQAAABkAAAAZAAAAGQAAABkAAD+DAAAAAAAZAAAAGQAAP4MAAAAyAAAAAAAAgAAAAACWAK8ABMAFwAACRcAAAAAAGQAAABkAAAAyAAA/5wAAP+cAAAAyAAAAMgAAP+cAAD+cAAAAGQAAADIAAAAZADIAAAAZAAAAGQAAP+cAAD/nAAA/zgAAABkAAD/nAAA/5wAAABkAfQAZAAA/5wAAAAEAAAAAAJYArwADwATABcAGwAACRsAAAAAAGQAAABkAAAAyAAAAGQAAABkAAD/OAAA/zgAAP84AAAAyAAAAAAAyAAA/zgAyAAAAMgAAAAAAZAAAABkAAAAZAAA/5wAAP+cAAD+cAAAAGQAAP+cAlgAZAAA/5z+cAAAAMgAAADIAGQAAP+cAAAAAgAAAAACvAK8ABMAGQAACRkAAAAAAGQAAABkAAAB9AAA/5wAAABkAAD/nAAAAGQAAP7UAAD/OAAAAAAAAADIAAD/nAAAAAAB9AAAAGQAAABkAAD/nAAA/zgAAP+cAAD/OAAA/5wAAAEsAAD+1AH0/5wAAADIAAD/nAAAAAIAZAAAAlgCvAALAA8AAAkPAGQAAAH0AAD+1AAAAMgAAP84AAABLAAA/tQAAAEsAAAAAAH0AAD/nAAA/5wAAP+cAAD/nAAA/5wCWABkAAD/nAAAAAQAAAAAArwCvAATABcAGwAfAAAJHwAAAAAAZAAAAGQAAAEsAAAAZAAAAGQAAP+cAAD/nAAA/tQAAP+cAAD/nAAAAMgAAAAAASwAAP7UASwAAADIAAAAyADIAAAAZAAAAGQAAP+cAAD/nAAA/zgAAP+cAAD/nAAAAGQAAABkAZAAZAAA/5z+cAAAAMgAAADIAGQAAP+cAAAAAwAAAAACWAK8AAsADwATAAAJEwAAAAAAyAAAAMgAAADIAAD/nAAA/nAAAP+cAAAAyAAAAMgAAADIAAAAZAGQAAD+cAAAAZAAAP5wAAD/nAAAAGQB9ABkAAD/nAAAAGQAAP+cAAMAAAAAArwCvAAPABMAFwAACRcAAAAAAGQAAAEsAAD+1AAAAZAAAABkAAAAZAAA/agAAP+cAAABLAAA/5wAAADIAAAAZABkAAAAZAAAAGQAAABkAAD/nAAA/tQAAP+cAAAAZAH0AGQAAP+c/nD/nAAAAGQAAwBkAAACvAK8AAsADwATAAAJEwBkAAABLAAA/tQAAAGQAAAAZAAAAGQAAP4MAAAAyAAA/5wAAAEsAAAAAAEsAAAAZAAAAGQAAP+cAAD+1AAA/5wAyP+cAAAAZAGQAGQAAP+cAAMAAAAAAyACvAALABsAHwAACR8AAAAAAGQAAAJYAAAAZAAA/zgAAP5wAAAAAAAAASwAAP7UAAABkAAAAGQAAABkAAD9qAAA/5wAAADIAAAAyAAAAfQAZAAAAGQAAP+cAAD/nAAAAGQAAP+c/tQAZAAAAGQAAABkAAD/nAAA/tQAAP+cAAAAZAAAAGQAAP+cAAAAZAAEAAAAAAK8ArwADwATABcAGwAACRsAAAAAAGQAAAEsAAD+1AAAAZAAAABkAAAAZAAA/agAAP+cAAAAyAAAAAAAAADIAAAAAAAAAMgAAABkAGQAAABkAAAAZAAAAGQAAP+cAAD+1AAA/5wAAABkAfQAZAAA/5z+cP+cAAAAZAGQAGQAAP+cAAAAAgAAAAADIAH0ABMAFwAACRcAAAAAAGQAAAEsAAD+1AAAArwAAP84AAAAyAAA/zgAAADIAAD9RAAAAGQAAADIAAAAZABkAAAAZAAAAGQAAABkAAD/nAAA/5wAAP+cAAD/nAAA/5wAAABkAGT/nAAAAGQAAAABAAD/nAJYArwAHQAACR0AAAAAAGQAAAGQAAAAZAAA/zgAAP84AAAAyAAAAMgAAP+cAAAAZAAA/5wAAP5wAAABLAAA/5wAAP84AAABLAEsAAAAZAAA/5wAAP+cAAAAZAAA/tQAAABkAAD/nAAA/zgAAP+cAAD/nAAAAGQAAABkAAAAZAAAAGQAAwAAAAACWAK8AA0AEQAVAAAJFQAAAAAAZAAAAZAAAABkAAD+cAAAASwAAP5wAAD/nAAAASwAAP+cAAAAyAAAAGQBLAAAAGQAAP+cAAD/OAAA/5wAAP+cAAAAZAH0AGQAAP+c/zj/nAAAAGQAAwAAAAACWAK8AA0AEQAVAAAJFQAAAAAAZAAAAZAAAABkAAD+cAAAASwAAP5wAAAAZAAAAMgAAP+cAAABLAAAAGQBLAAAAGQAAP+cAAD/OAAA/5wAAP+cAAAAZAEs/5wAAABkAMgAZAAA/5wAAwAAAAADIAK8AAsAGQAdAAAJHQAAAAAAZAAAAlgAAABkAAD/OAAA/nAAAAAA/5wAAABkAAABkAAAAGQAAP5wAAABLAAA/nAAZAAAAMgAAAH0AGQAAABkAAD/nAAA/5wAAABkAAD/nP5wAAABLAAAAGQAAP+cAAD/OAAA/5wAAP+cAAABkP+cAAAAZAAEAAAAAAJYArwADQARABUAGQAACRkAAAAAAGQAAAGQAAAAZAAA/nAAAAEsAAD+cAAA/5wAAADIAAAAAAAAAMgAAAAAAAAAyAAAAGQBLAAAAGQAAP+cAAD/OAAA/5wAAP+cAAAAZAH0AGQAAP+c/zj/nAAAAGQAyABkAAD/nAAAAAIAAAAAAfQCvAADAA0AAAkNAAAAAAEsAAD/OAAAAGQAAP+cAAABLAAAAGQAAAJYAGQAAP+c/agAZAAAASwAAABkAAD+cAAA/5wAAAACAGQAAAH0ArwACQANAAAJDQBkAAAAZAAA/5wAAAEsAAAAZAAA/tQAAAEsAAAAAABkAAABLAAAAGQAAP5wAAD/nAJYAGQAAP+cAAAAAgAAAAACvAK8AAsAFQAACRUAAAAAAGQAAAH0AAAAZAAA/zgAAP7UAAAAAAAAAGQAAP+cAAABLAAAAGQAAAH0AGQAAABkAAD/nAAA/5wAAABkAAD/nP4MAGQAAAEsAAAAZAAA/nAAAP+cAAAAAwAAAAACWAK8AAMADQARAAAJEQAAAAAAyAAA/5wAAABkAAD/nAAAASwAAABkAAD/nAAAAMgAAAJYAGQAAP+c/agAZAAAASwAAABkAAD+cAAA/5wCWABkAAD/nAADAAAAAAJYAlgACwAPABMAAAkTAAAAAABkAAABkAAAAGQAAP+cAAD+cAAA/5wAAAEsAAD/nADIAAD/OABkAMgAAABkAAD/nAAA/zgAAP+cAAAAZAGQAGQAAP+c/nAAAADIAAAAAwAAAAACWAJYAAsADwATAAAJEwAAAAAAZAAAAZAAAABkAAD/nAAA/nAAAABkAMgAAP84AGQAAAEsAAAAZADIAAAAZAAA/5wAAP84AAD/nAAAAGQAAAAAAMgAAADIAGQAAP+cAAMAAAAAAlgCvAALABcAGwAACRsAAAAAAGQAAAGQAAAAZAAA/5wAAP5wAAD/nAAAAGQAAAGQAAAAZAAA/zgAAP84AAAAAADIAAD/OABkAMgAAABkAAD/nAAA/zgAAP+cAAAAZAGQAGQAAABkAAD/nAAA/5wAAABkAAD/nP5wAAAAyAAAAAQAAAAAAlgCWAALAA8AEwAXAAAJFwAAAAAAZAAAAZAAAABkAAD/nAAA/nAAAP+cAAAAyAAAAAAAyAAA/zgAyAAAAMgAAABkAMgAAABkAAD/nAAA/zgAAP+cAAAAZAGQAGQAAP+c/nAAAADIAAAAyABkAAD/nAAAAAMAAAAAAlgCvAADAAcACwAACQsBkAAA/zgAAP84AAACWAAA/zj/OAAAAMgAyP84AAAAyABkAGQAAP+cAMgAAADIAAAAAgAAAAACvAJYAAsADwAACQ8AAAAAAMgAAADIAAAAyAAAAGQAAP2oAAD/nAAAASwAAABkASwAAP7UAAABLAAA/tQAAP+cAAAAZAGQAGQAAP+cAAAAAgAAAAACvAJYAAsADwAACQ8AAAAAAMgAAADIAAAAyAAAAGQAAP2oAAAAyAAAASwAAABkASwAAP7UAAABLAAA/tQAAP+cAAAAZAGQAGQAAP+cAAAAAgAAAAACvAK8AAsAFwAACRcAAAAAAMgAAADIAAAAyAAAAGQAAP2oAAD/nAAAAGQAAAGQAAAAZAAA/zgAAP84AAAAZAEsAAD+1AAAASwAAP7UAAD/nAAAAGQBkABkAAAAZAAA/5wAAP+cAAAAZAAA/5wAAAADAAAAAAK8AlgACwAPABMAAAkTAAAAAADIAAAAyAAAAMgAAABkAAD9qAAA/5wAAADIAAAAyAAAAMgAAABkASwAAP7UAAABLAAA/tQAAP+cAAAAZAGQAGQAAP+cAAAAZAAA/5wAAwAA/5wCWAJYAA0AEQAVAAAJFQAAAAABkAAA/nAAAADIAAAAyAAAAMgAAP+cAAD+DAAAAMgAAADIAAAAyAAA/5wAZAAAAGQAAAEsAAD/OAAAAMgAAP5wAAD/nAJYAGQAAP+cAAAAZAAA/5wABQBkAAABkAK8AAMABwALAA8AEwAACRMAZAAAAMgAAP84AAAAZAAA/5wAAABkAAAAZAAAAGQAAP+cAAAAZAAAAAAAZAAA/5wAyAEsAAD+1AGQAGQAAP+c/gwBkAAA/nAB9ABkAAD/nAADAAAAAAJYArwACwAPABMAAAkTAAAAAABkAAABkAAAAGQAAP84AAD/OAAAAAAAyAAA/zgAAAAAAMgAAAAAASwAAABkAAD/nAAA/tQAAABkAAD/nADIAAAAZAAAAMgAyAAA/zgAAgAAAAACvAK8ABMAFwAACRcAAAAAAGQAAAEsAAD+1AAAAGQAAADIAAAAZAAAAGQAAABkAAD9qAAAAGQAAADIAAAAZABkAAAAZAAAAGQAAABkAAAAyAAA/zgAAP+cAAD+1AAA/5wAAABkAGT/nAAAAGQAAAABAAAAAAK8AlgABwAACQcAAAAAArwAAP84AAD+1AAAAAACWAAA/zgAAABkAAD+DAABAAAAAAK8ArwAHwAACR8AAAAAAGQAAABkAAAAZAAA/5wAAP+cAAD/nAAAArwAAP84AAD/OAAAAGQAAABkAAD/nAAA/5wAAADIAAAAyAAAAAAAZAAAAGQAAABkAAAAZAAAAGQAAABkAAAAZAAA/zgAAABkAAD/nAAA/5wAAP+cAAD/nAAA/5wAAABkAAD/OAACAAD/nAJYArwAGwAfAAAJHwAAAAAAyAAA/5wAAP+cAAAAZAAAAGQAAP84AAACWAAA/zgAAABkAAAAZAAA/5wAAP+cAAAAyAAA/nAAyAAA/zj/nABkAAAAZAAAAGQAAADIAAAAZAAAAGQAAABkAAD/nAAA/5wAAP+cAAD/OAAA/5wAAP+cAAD/nAEsAAAAyAAAAAAAAQAAAAACvAK8AB8AAAkfAAAAAABkAAD/nAAAAGQAAABkAAABLAAAAGQAAABkAAD/nAAAAGQAAP7UAAAAZAAA/5wAAP+cAAD/nAAAAGQAAAAAAGQAAADIAAAAyAAAAGQAAABkAAD/nAAA/5wAAP84AAD/OAAA/5wAAAEsAAAAyAAAAGQAAP+cAAD/OAAA/tQAAgBkAAACvAH0AAcAGwAACRsAyABkAAAAZAAA/5wAAP+cAMgAAP7UAAABLAAAAGQAAADIAAD/nAAA/5wAAABkAAAAZAAA/zgAAABkAAAAZAAAAGQAAABkAAD+1P+cAAAB9AAA/5wAAABkAAD/nAAA/5wAAP+cAAD/nAAA/5wAAABkAAAAAwAA/5wCWAJYAA8AEwAXAAAJFwAAAAAAZAAAAZAAAABkAAD/nAAAAGQAAP+cAAD+1AAAAAAAyAAA/zgAAAAAAMgAAP+cAlgAAABkAAD/nAAA/5wAAP+cAAD/nAAA/5wAAP84ASwAAABkAAAAyP+cAAAAZAACAAAAAAJYArwAFQAZAAAJGQAAAAAAZAAAAMgAAP+cAAAAZAAAASwAAP84AAAAZAAAAGQAAP+cAAD+cAAAAGQAyAAA/zgAZADIAAAAZAAAAGQAAABkAAAAZAAA/5wAAP+cAAD/nAAA/tQAAP+cAAAAZAAAAAAAyAAAAAAAAQAAAAACWAK8ABcAAAkXAAAAAABkAAAAZAAAAZAAAP7UAAD/nAAAAZAAAP5wAAAAZAAAASwAAP5wAAD/nAAAAMgBLAAAAGQAAABkAAD/nAAA/5wAAP+cAAD/nAAA/5wAAP+cAAD/nAAAAGQAAABkAAMAAAAAArwCvAATABsAIwAACSMAAAAAAGQAAABkAAABLAAAAGQAAABkAAD/nAAA/5wAAP7UAAD/nAAAAGQAZAAAAGQAAABkAAD+1AAAAAABLAAA/5wAAP+cAAAAyAEsAAAAZAAAAGQAAP+cAAD/nAAA/tQAAP+cAAD/nAAAAGQAAABkAAAAAP+cAAAAZAAAAGQAAADI/5wAAABkAAAAZAAA/5wAAQAA/5wCvAJYAA8AAAkPAAAAAABkAAAAyAAAAMgAAADIAAD/nAAA/tQAAP+cAAD/nABkAAACWAAA/nAAAAGQAAD+cAAA/5wAAP+cAAD/nAABAAAAAAK8AlgACwAACQsBkAAA/5wAAP84AAD/nAAAArwAAP+cAAAAAAH0AAD+DAAAAfQAAABkAAD/nAAA/gwAAgAAAAACvAH0AAsADwAACQ8AAAAAAGQAAAJYAAD/nAAA/5wAAP5wAAAAZADIAAD/OABkASwAAABkAAD/nAAA/tQAAP+cAAAAZAAAAAABLAAAAAAAAQAAAAACvAJYABEAAAkRAAAAAABkAAABLAAAAGQAAADIAAD/nAAA/5wAAP84AAD/nAAAAZAAZAAAAGQAAP+cAAAAZAAA/5wAAP+cAAD+cAAAAfQAAP+cAAMAAAAAAZACvAALAA8AEwAACRMAAAAAAZAAAP7UAAAAyAAA/zgAAAEsAAD+1AAAAGQAAABkAAAAZAAAAAAB9AAA/5wAAP+cAAD/nAAA/5wAAP+cAlgAZAAA/5wAAABkAAD/nAACAAAAAAH0ArwADQARAAAJEQAAAAAB9AAA/5wAAP7UAAABLAAA/tQAAAEsAAAAAAAAAGQAAAAAArwAAP84AAAAZAAA/zgAAP+cAAD/OAAA/5wAZADIAAD/OAAAAAEAAAAAAfQCvAAHAAAJBwAAAAAB9AAA/5wAAP7UAAAAAAK8AAD/OAAAAGQAAP2oAAIAAP+cAfQCvAARABUAAAkVAAAAZAAAASwAAP+cAAD/nAAA/5wAAAGQAAD/nAAA/tQAAP+cAGQAAABkAAAAyAAA/5wAAAH0AAD+1AAAASwAAABkAAD84AAAAGQAAP+cAAABLABkAAD/nAAAAAUAAAAAAfQCvAADAAcAEwAXABsAAAkbAAAAAABkAAD/nAAAAGQAAAAAAGQAAABkAAAAZAAA/5wAAP+cAAD/nAEsAAAAZAAA/5wAAABkAAAAAAEsAAD+1AGQASwAAP7UAAAAAAEsAAD+1AAA/5wAAP7UAAABLAAA/tQBLAAA/tQBkAEsAAD+1AAFAAAAAAH0ArwAAwAHAAsADwATAAAJEwAAAAABkAAA/nAAAAGQAAD+1AAAASwAAAAAAAAAZAAA/5wAAABkAAAAAABkAAD/nAJYAGQAAP+c/tQAZAAA/5z/OADIAAD/OAEsAMgAAP84AAMAAAAAAfQCvAAHAAsAEwAACRMAAAAAAGQAAABkAAD/nAAAAGQAAABkAAAAAAAAAGQAAABkAAD/nAAAAAACvAAA/nAAAP+cAAD/OAEsAGQAAP+cAGQAZAAAAMgAAP1EAAABkAAGAAAAAAH0ArwABwALAA8AEwAbAB8AAAkfAAAAAABkAAAAZAAA/5wAAABkAAAAZAAA/5wAAABkAAD/nAAA/5wAAAEsAAD/nAAAAGQAAABkAAD/nAAA/5wAAAAAAfQAAP7UAAD/nAAA/5wAyABkAAD/nAEsAGQAAP+cAMj/nAAAAGT9RAEsAAAAZAAAAGQAAP4MArz/nAAAAGQAAAADAAAAAAH0ArwAAwAHABEAAAkRAAAAAABkAAAAAABkAAD/nAAAAAABkAAA/5wAAP+cAAD/nAAAAGQAZAAA/5wAAAAA/5wAAAJYAGQAAP1EAAACWAAA/gwAAAH0AAEAAAAAAfQCvAAHAAAJBwAAAAAB9AAA/5wAAP7UAAAAAAK8AAD9RAAAAlgAAP2oAAcAAAAAAfQCvAADAAcACwAPABMAFwAbAAAJGwAAAAAAZAAA/5wAAABkAAAAAAAAAGQAAP+cAGQAAP+cAGQAAABkAAAAAAAAAGQAAAAAAAAAZAAAAAAAZAAA/5wBkAEsAAD+1P7UAGQAAP+cASwAAP+cAAD/nABkAAD/nABkAGQAAP+cAGQBLAAA/tQAAwAAAAAB9AK8AAMAFwAbAAAJGwAAAAAAZAAAAAAAZAAA/5wAAABkAAAAZAAAAGQAAP+cAAAAZAAA/5wAAP+cAAD/nAEsAAAAZAAAAMgBLAAA/tQAAAAAASwAAABkAAAAZAAA/5wAAP+cAAD+1AAA/5wAAP+cAAAAZAAAAGQBLAAA/tQAAQAA/5wB9AK8AAkAAAkJAAAAAABkAAABLAAAAGQAAP+cAAAAAAK8AAD9qAAAAlgAAPzgAAAAZAACAAAAAAH0ArwABwALAAAJCwGQAAD+1AAAASwAAABkAAD+DAAAAGQAAAAAASwAAABkAAABLAAA/UQBkAEsAAD+1AAAAAEAAAAAAfQCvAALAAAJCwAAAAAAZAAAAGQAAABkAAAAZAAAAGQAAAAAArwAAP2oAAACWAAA/agAAAJYAAD9RAABAAD/nAH0ArwADQAACQ0AAAAAAGQAAABkAAAAZAAAAGQAAABkAAD/nAAAAAACvAAA/agAAAJYAAD9qAAAAlgAAPzgAAAAZAACAAAAAAH0ArwACwAPAAAJDwAAAAAAyAAAAMgAAP84AAAAyAAA/tQAAAEsAAAAZAAAAlgAZAAA/tQAAP+cAAD/OAAA/5wAAAJY/gwAyAAA/zgAAAADAAAAAAH0ArwACQANABEAAAkRAAAAAABkAAAAZAAA/5wAAABkAAAAAAAAAGQAAABkAAAAZAAAAAACvAAA/tQAAP+cAAD/OAAA/5wAZADIAAD/OP+cArwAAP1EAAUAAAAAAfQCvAADAAcACwAPABcAAAkXAAAAAABkAAD/nAAAAGQAAAAAASwAAP7UAAAAAAEsAAD/OAAAAMgAAABkAAD/nAAAAGQAZAAA/5wBkABkAAD/nP5wAAD/nAAAAlgAZAAA/5z+1ABkAAAAyAAA/gwAAADIAAQAAAAAAfQCvAALAA8AEwAXAAAJFwAAAAAAZAAAAGQAAABkAAD/nAAA/5wAAADIAGQAAP+cAAAAAABkAAAAAAAAAGQAAAAAArwAAP7UAAAAyAAA/gwAAADIAAD+1ABkAAD/nAAAAlgAZAAA/5z+DAH0AAD+DAAAAAQAAAAAAfQCvAADAAcACwAZAAAJGQAAAAAAZAAA/5wAAABkAAAAAAAAAGQAAP+cASwAAP7UAAABkAAA/5wAAP+cAAD/nAAA/5wAAABkAAD/nAGQAMgAAP84/tQAZAAA/5wBLAAAAMgAAABkAAD9RAAAASwAAP+cAAAAZAAAAAAABQAAAAAB9AK8AAcACwAPABMAFwAACRcAAAAAAGQAAAEsAAD+1AAAAAABLAAA/tQAAAAAAMgAAAAAAAAAyAAA/5wAAABkAAAAZAGQAAD/nAAA/5wAAP84AAAAAP+cAAAB9ABkAAD/nABkAGQAAP+c/gwAyAAA/zgAAwAAAAABkAH0AAsADwATAAAJEwAAAAABLAAA/zgAAADIAAD/OAAAAMgAAAAAAGQAAP+cAAAAZAAA/5wAAAH0AAD/nAAA/5wAAP+cAAD/nAAA/5wAyAAA/5wAAAEsAAD/nAAAAAEAAAAAAfQB9AAHAAAJBwAAAAAB9AAA/5wAAP7UAAAAAAH0AAD/OAAAAGQAAP5wAAIAAP+cAfQB9AARABUAAAkVAAAAZAAAASwAAP+cAAD/nAAA/5wAAAGQAAD/nAAA/tQAAP+cAGQAAABkAAAAyAAA/5wAAAEsAAD/nAAAAGQAAABkAAD9qAAAAGQAAP+cAAABLABkAAD/nAAAAAUAAAAAAfQB9AADAAcAEwAXABsAAAkbAAAAZAAA/5wAAABkAAD/nABkAAAAZAAAAGQAAABkAAD/nAAA/5wAAADIAGQAAP+cAAAAZAAA/5wAyAAA/zgAAAH0AAD/OAAA/5wAZAAAAMgAAP84AAD/nAAA/zgAAADIAAAAAP84AAAB9AAA/zgAAAAFAAAAAAH0AfQAAwAHAAsADwATAAAJEwAAAAABkAAA/nAAAAGQAAD/OAAAAMgAAAAAAGQAAP+cAAAAZAAA/5wAAABkAAD/nAGQAGQAAP+c/zgAZAAA/5wAAAAA/5wAAAEsAAD/nAAAAAYAAAAAAfQCWAAFAAkADQARABkAHQAACR0AAAAAAGQAAABkAAAAAAAAAGQAAP+c/5wAAABkAAAAAABkAAAAZP+cAAAAZAAAAGQAAP+cAAD/nAAAAGQAAAGQAAD+1AAA/5wAZABkAAD/nAGQAAAAZAAA/zgAZAAA/5z/OAAAAGQAAABkAAD+cAAAAfQAAABkAAAAAAAFAAAAAAGQAfQABwALAA8AEwAXAAAJFwAAAAAAZAAAAGQAAP+cAAAAZABkAAD/nAAAAAAAZAAAAAAAZAAA/5wAAAAAAGQAAAAAAfQAAP84AAD/nAAA/zgAyAAA/5wAAADIAGQAAP+c/zgAAP+cAAABkABkAAD/nAADAAAAAAH0AfQAAwAHABEAAAkRAAAAAABkAAAAAABkAAD/nAAAAAABkAAA/5wAAP+cAAD/nAAAAGQAZAAA/5wAAAAA/5wAAAGQAGQAAP4MAAABkAAA/tQAAAEsAAMAAAAAAfQB9AAHAAsAEwAACRMAAAAAAGQAAABkAAD/nAAAAGQAAABkAAAAAAAAAGQAAABkAAD/nAAAAAAB9AAA/5wAAP+cAAD+1ADIAGQAAP+cAGQAZAAAAGQAAP4MAAABLAABAAAAAAH0AfQACwAACQsAAAAAAGQAAAEsAAAAZAAA/5wAAP7UAAAAAAH0AAD/OAAAAMgAAP4MAAAAyAAA/zgAAQAAAAAB9AH0AAcAAAkHAAAAAAH0AAD/nAAA/tQAAAAAAfQAAP4MAAABkAAA/nAAAQAAAAAB9AH0AAcAAAkHAAAAAAH0AAD/OAAA/5wAAAGQAGQAAP+cAAD+cAAAAZAAAwAA/5wB9AJYAAMAFwAbAAAJGwAAAAAAZAAAAAAAZAAA/5wAAABkAAAAZAAAAGQAAP+cAAAAZAAA/5wAAP+cAAD/nAEsAAAAZAAAAGQAyAAA/zgAAAAAAMgAAABkAAAAyAAA/zgAAP+cAAD/OAAA/5wAAP+cAAAAZAAAAGQAyAAA/zgAAgAAAAAB9AH0AAcACwAACQsBkP7UAAABLAAAAGQAAP+c/nAAZAAA/5wAyAAAAGQAAADIAAD+DAAAAfQAAP84AAAAAAABAAAAAAH0AfQACwAACQsAAAAAAGQAAABkAAAAZAAAAGQAAABkAAAAAAH0AAD+cAAAAZAAAP5wAAABkAAA/gwAAQAA/5wB9AH0AA0AAAkNAAAAAABkAAAAZAAAAGQAAABkAAAAZAAA/5wAAAAAAfQAAP5wAAABkAAA/nAAAAGQAAD9qAAAAGQAAgAAAAAB9AH0AAsADwAACQ8AAAAAAMgAAADIAAD/OAAAAMgAAP7UAAABLABkAAD/nAGQAGQAAP84AAD/nAAA/5wAAP+cAAABkP84AAD/nAAAAAAAAwAAAAAB9AH0AAkADQARAAAJEQAAAAAAZAAAAGQAAP+cAAAAZAAAAAAAZAAA/5wAyAAAAGQAAAAAAfQAAP84AAD/nAAA/5wAAP+cAMgAAP+cAAD/nAH0AAD+DAACAAAAAAGQAfQACQANAAAJDQAAAAAAZAAAAMgAAP84AAAAyAAAAGQAAP+cAAAAAAH0AAD/OAAA/5wAAP+cAAD/nADI/5wAAABkAAAABQAAAAAB9AH0AAMABwALAA8AFwAACRcAAAAAAGQAAP+cAAAAZAAAAAABLAAA/tQAAAAAASwAAP84AAAAyAAAAGQAAP+cAAAAZABkAAD/nADIAGQAAP+c/zgAAP+cAAABkABkAAD/nP84AGQAAABkAAD+1AAAAGQABAAAAAAB9AH0AAsADwATABcAAAkXAAAAAABkAAAAZAAAAGQAAP+cAAD/nAAAAMgAZAAA/5wAAAAAAGQAAAAAAAAAZAAAAAAB9AAA/zgAAABkAAD+1AAAAGQAAP84AGQAAP+cAAABkABkAAD/nP7UASwAAP7UAAAAAwAAAAAB9AH0AAMAEQAVAAAJFQAAAAAAZAAAAAAAAAEsAAD+1AAAAZAAAP+cAAD/nAAA/5wAAP+cAAAAZAAAASwAZAAA/5z/nABkAAAAZAAAAGQAAP4MAAAAyAAA/5wAAABk/zgAZAAA/5wABQAAAAAB9AK8AAkADQARABUAGQAACRkAAAAAAGQAAAEsAAAAZAAA/nAAAAAAASwAAP7UAAAAAAEsAAD+1AAAAGQAAABkAAAAZAAAAGQBLAAA/5wAAABkAAD/OAAA/5wAAAAA/5wAAAGQAGQAAP+cAMgAZAAA/5wAAABkAAD/nAAEAAABkAH0ArwAAwAJAA0AEwAACRMAAAAAAGQAAP+cAAAAyAAA/5wAAADIAAAAZAAA/5wAAADIAAD/nAAAAZAAZAAA/5wAyABkAAD/OAAAAGT/OABkAAD/nADIAGQAAP84AAAAZAAAAAQAAAAAAfQBLAAFAAkADwATAAAJEwAAAGQAAABkAAD/OABkAAAAZAAAAGQAZAAAAGQAAP84AGQAAABkAAAAyAAA/5wAAP+cAAAAyABkAAD/nAAAAAD/nAAA/5wAAADIAGQAAP+cAAAAAwAAAAAB9AK8AAcAEwAXAAAJFwAAAAAAZAAAAGQAAP+cAAAAZAAAAGQAAP+cAAAAZAAAAGQAAABkAAD/OAAAAGQAAAEsAZAAAP+cAAD/nAAA/zj+1AEsAAAAZAAAAGQAAADIAAD+cAAA/tQAyP+cAAAAZAAFAAAAAAH0ArwAAwAHABcAGwAfAAAJHwAAAAAAZAAA/5wAAABkAAAAZAAAAMgAAP+cAAAAZAAA/zgAAABkAAAAZAAAAGQAAP7UAAD/nAAAASwAAABkAAAAyABkAAD/nADIASwAAP7U/nAAZAAAAGQAAABkAAAAZAAAAGQAAABkAAD/nAAA/gwBkP+cAAAAZADIAGQAAP+cAAEAZABkAZACvAALAAAJCwGQAAD+1AAAAGQAAP+cAAABLAAA/5wAAADI/5wAAABkAAABkAAAAGQAAP+cAAD+cAACAAAAZAH0ArwACwAPAAAJDwAAAAAAZAAA/5wAAAH0AAD/nAAAAGQAAP7UAGQAAP+cAGQAZAAAAZAAAABkAAD/nAAA/nAAAP+cAGQAAAGQAAAAAAADAAAAAAH0ArwAAwAPABMAAAkTAAAAAABkAAAAAAAAAGQAAABkAAAAZAAA/5wAAP+cAAAAyABkAAD/nAGQAGQAAP+cAGQAZAAAAGQAAP+cAAD/nAAA/gwAAAH0AAAAAP+cAAAAAwAAAAAB9AK8AAMADwATAAAJEwAAAAAAZAAAAAAAZAAAAGQAAABkAAD/nAAA/5wAAP+cASwAAABkAAAAyABkAAD/nAAAAAAB9AAA/gwAAP+cAAD/nAAAAGQAAABkAGQAAP+cAAEAAP+cAyACvAAPAAAJDwAAAAABLAAAAGQAAAGQAAD/OAAA/tQAAP+cAAD/nAAAAMgAZAAA/zgAAAJYAAD/nAAA/UQAAABkAAAAZAAAAGQAAwAAAGQDIAH0AAsADwATAAAJEwAAAAAAZAAAAlgAAABkAAD/nAAA/agAAABkAGQAAP+cASwAZAAA/5wAyADIAAAAZAAA/5wAAP84AAD/nAAAAGQAAAAAAMgAAP84AAAAyAAAAAYAAABkArwCWAADAAcADwAXABsAHwAACR8AAAAAAGQAAP+cAAAAZAAAASwAyAAA/tQAAP84AAABLAAAAMgAAP7UAAD/OAAAASwAyAAAAGQAAP+cAAAAZAAAAGQAZAAA/5wBLABkAAD/nP84AAD/nAAAAGQAAABkAAAAyAAA/5wAAABkAAAAZAAA/nAAZAAA/5wBLABkAAD/nAAAAAMAZABkAlgCWAADAAcACwAACQsAZAAAAfQAAP4MAAAB9AAA/gwAAAH0AAAAZABkAAD/nAGQAGQAAP+c/zgAZAAA/5wAAgAAAAACWAK8AAMAFwAACRcAAAAAAlgAAP4MAAAAZAAAAGQAAADIAAD/nAAA/5wAAABkAAAAZAAA/zgAAP+cAAAAAABkAAD/nAGQAGQAAABkAAAAZAAA/5wAAP+cAAD/nAAA/5wAAP+cAAAAZAAAAGQAAAACAAAAAAJYArwAAwAXAAAJFwAAAAACWAAA/gwAAABkAAAAZAAA/5wAAP+cAAAAyAAAAGQAAABkAAD/nAAA/5wAAAAAAGQAAP+cAMgAZAAAAGQAAABkAAAAZAAAAGQAAP+cAAD/nAAA/5wAAP+cAAD/nAAAAAEAAADIAyABLAADAAAJAwAAAAADIAAAAMgAZAAA/5wAAQEs/5wB9AK8AAMAAAkDAfT/OAAAAMj/nAAAAyAAAAABASz/nAMgASwABQAACQUDIP7UAAD/OAAAAfQAyAAA/tQAAAGQAAAAAQAA/5wB9AEsAAUAAAkFAAAAAAH0AAD/OAAAAMgAZAAA/nAAAAEsAAEBLADIAyACvAAFAAAJBQMg/gwAAADIAAABLADIAAAB9AAA/nAAAAABAAAAyAH0ArwABQAACQUAAAAAASwAAADIAAAAyABkAAABkAAA/gwAAQEs/5wDIAK8AAcAAAkHAyD+1AAA/zgAAADIAAABLADIAAD+1AAAAyAAAP5wAAAAAQAA/5wB9AK8AAcAAAkHAAAAAAEsAAAAyAAA/zgAAADIAGQAAAGQAAD84AAAASwAAQAA/5wDIAEsAAcAAAkHAAAAAAMgAAD+1AAA/zgAAADIAGQAAP+cAAD+1AAAASwAAQAAAMgDIAK8AAcAAAkHAAAAAAEsAAAAyAAAASwAAADIAGQAAAGQAAD+cAAA/5wAAQAA/5wDIAK8AAsAAAkLAAAAAAEsAAAAyAAAASwAAP7UAAD/OAAAAMgAZAAAAZAAAP5wAAD/nAAA/tQAAAEsAAIAAADIAyAB9AADAAcAAAkHAAAAAAMgAAD84AAAAyAAAADIAGQAAP+cAMgAZAAA/5wAAAACAMj/nAK8ArwAAwAHAAAJBwGQ/zgAAADIAGQAAADIAAD/nAAAAyAAAPzgAyAAAPzgAAAAAQEs/5wDIAH0AAkAAAkJAyD+1AAA/zgAAAH0AAD+1AAAASwAyAAA/tQAAAJYAAD/nAAA/5wAAAABAMj/nAMgASwACQAACQkBkAAA/zgAAAJYAAD/nAAA/zgAAADI/tQAAAGQAAD/nAAA/tQAAAEsAAIAyP+cAyAB9AAFAAsAAAkLAZD/OAAAAlgAAP5wAZD/nAAA/zgAAAEs/5wAAAJYAAD/nAAA/zgAAP7UAAABkAAAAAAAAQAA/5wB9AH0AAkAAAkJAAAAAAEsAAD+1AAAAfQAAP84AAAAyABkAAAAZAAAAGQAAP2oAAABLAABAAD/nAK8ASwACQAACQkAAAAAArwAAP84AAD/nAAA/zgAAADIAGQAAP5wAAABLAAA/tQAAAEsAAIAAP+cArwB9AAFAAsAAAkLAAAAAAGQAAD/OAAA/zgAAAK8AAD/OAAAAMgAZAAA/nAAAAEsAMgAZAAA/agAAAH0AAAAAQEsAMgDIAK8AAkAAAkJAyD+DAAAAMgAAAEsAAD+1AAAASwAyAAAAfQAAP84AAD/nAAA/5wAAAABAMgAyAMgArwACQAACQkDIP2oAAAAyAAAAGQAAADIAAAAZADIAAAB9AAA/nAAAAGQAAD+cAAAAAIAyADIAyACvAAFAAsAAAkLAyD9qAAAAMgAAAGQAAAAAP7UAAAAyAAAAMgAAAH0AAD+cAAAAMj/nAAAASwAAP84AAAAAQAAAMgB9AK8AAkAAAkJAAAAAAEsAAD+1AAAASwAAADIAAAAyABkAAAAZAAAAGQAAADIAAD+DAABAAAAyAK8ArwACQAACQkAAAAAAMgAAADIAAAAZAAAAMgAAADIAGQAAAGQAAD+cAAAAZAAAP4MAAIAAADIArwCvAAFAAsAAAkLAAAAAAH0AAAAyAAA/UQAAADIAAAAyAAAAMgAZAAAAZAAAP4MAMgAZAAAAMgAAP7UAAAAAQEs/5wDIAK8AAsAAAkLAyD+1AAA/zgAAADIAAABLAAA/tQAAAEsAMgAAP7UAAADIAAA/zgAAP+cAAD/nAAAAAIAyP+cAyACvAADAAsAAAkLAZD/OAAAAMgBkP+cAAD/OAAAAMgAAABk/5wAAAMgAAD+DAAA/tQAAAMgAAD+cAAAAAAAAwDI/5wDIAK8AAUACwAPAAAJDwMg/5wAAP84AAABLAAAAAD+1AAAAMgAAP4MAAAAyAAAAMgAAP7UAAABkAAAAMj/nAAAASwAAP84/agDIAAA/OAAAQAA/5wB9AK8AAsAAAkLAAAAAAEsAAD+1AAAASwAAADIAAD/OAAAAMgAZAAAAGQAAABkAAAAyAAA/OAAAAEsAAIAAP+cArwCvAAHAAsAAAkLAAAAAADIAAAAyAAA/zgAAAEsAAAAyAAAAMgAZAAAAZAAAPzgAAABLP7UAyAAAPzgAAAAAwAA/5wCvAK8AAUACwAPAAAJDwAAAAABkAAA/zgAAP84AAAAyAAAAMgAAABkAAAAyAAAAMgAZAAA/nAAAAEsAMgAZAAAAMgAAP7U/gwDIAAA/OAAAgAA/5wDIAH0AAcACwAACQsAAAAAAyAAAP7UAAD/OAAA/tQAAAMgAAAAyABkAAD/nAAA/tQAAAEsAMgAZAAA/5wAAAABAAD/nAMgASwACwAACQsAAAAAAyAAAP+cAAD/OAAA/5wAAP84AAAAyABkAAD/nAAA/tQAAAEsAAD+1AAAASwAAwAA/5wDIAH0AAUACwAPAAAJDwAAAAABkAAA/zgAAAJY/5wAAP84AAABLPzgAAADIAAAAMgAZAAA/nAAAAEsAAAAAP7UAAABkAAAAGQAZAAA/5wAAgAAAMgDIAK8AAMACwAACQsAAAAAAyAAAPzgAAABLAAAAMgAAAEsAAAAyABkAAD/nADIAGQAAADIAAD/OAAA/5wAAAABAGQAyAMgArwACwAACQsDIP1EAAAAZAAAAMgAAABkAAAAyAAAAGQAyAAAAGQAAAGQAAD+cAAAAZAAAP5wAAAAAwAAAMgDIAK8AAMACQAPAAAJDwAAAAADIAAA/OAAAADIAAAAyAAAAZAAAP7UAAAAyAAAAMgAZAAA/5wAyABkAAAAyAAA/tQAZP+cAAABLAAA/zgAAgAA/5wDIAK8AAcADwAACQ8AAAAAAyAAAP7UAAD/OAAA/tQAAAEsAAAAyAAAASwAAADIAGQAAP+cAAD+1AAAASwAyABkAAAAyAAA/zgAAP+cAAAAAgAA/5wDIAK8AAcADwAACQ8AAAAAAMgAAADIAAD/OAAAAlj/nAAA/zgAAADIAAAAZADIAGQAAAGQAAD84AAAASwAAAAA/tQAAAMgAAD+cAAAAAAABAAA/5wDIAK8AAUACwARABcAAAkXAAAAAAGQAAD/OAAAAlj/nAAA/zgAAAEs/OAAAADIAAAAyAAAAZAAAP7UAAAAyAAAAMgAZAAA/nAAAAEsAAAAAP7UAAABkAAAAGQAZAAAAMgAAP7UAGT/nAAAASwAAP84AAAAAQAAASwDIAK8AAMAAAkDAAAAAAMgAAABLAGQAAD+cAABAAD/nAMgASwAAwAACQMAAAAAAyAAAP+cAZAAAP5wAAEAAP+cAyACvAADAAAJAwAAAAADIAAA/5wDIAAA/OAAAQAA/5wBkAK8AAMAAAkDAAAAAAGQAAD/nAMgAAD84AABAZD/nAMgArwAAwAACQMBkAAAAZAAAP+cAyAAAPzgAAwAyP+cArwCvAADAAcACwAPABMAFwAbAB8AIwAnACsALwAACS8AyAAAAGQAAP+cAAAAZAAA/5wAAABkAAD/nAAAAGQAAABkAAAAZAAA/5wAAABkAAD/nAAAAGQAAP+cAAAAZAAAAGQAAABkAAD/nAAAAGQAAP+cAAAAZAAA/5wAAABkAAAAyABkAAD/nP84AGQAAP+cAZAAZAAA/5wAyABkAAD/nP4MAGQAAP+c/zgAZAAA/5wCWABkAAD/nP84AGQAAP+c/5wAZAAA/5z/OABkAAD/nAGQAGQAAP+cAMgAZAAA/5wAAAAgAAD/nAMgArwAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAEcASwBPAFMAVwBbAF8AYwBnAGsAbwBzAHcAewB/AAAJfwAAAAAAZAAA/5wAAABkAAD/nAAAAGQAAP+cAAAAZAAAASwAZAAA/5wAAAAA/5wAAABkAGQAAP+cAAAAAP+cAAAAZABkAAD/nAAAAAD/nAAAAGQAAP+cAAAAZABkAAD/nAGQ/5wAAABkAAAAAP+cAAAAZAAA/5wAAABkAAD/nAAA/nAAAP+cAAAAZAAA/5wAAABk/5wAAABkAAAAAP+cAAAB9AAA/5wAAABkAAD/nAAAAGT/nAAAAGQAAAAA/5wAAP5w/5wAAABkAAAAAP+cAAAAZAAA/5wAAABkAAD/nAAAAfT/nAAAAGQAAAAA/5wAAABkAAD/nAAAAGQAAP+cAAAAZABkAAD/nP84AGQAAP+cAlgAZAAA/5z/OABkAAD/nP+cAAD/nAAAAAD/nAAAAGT/nAAA/5wAAAJY/5wAAABk/5wAAP+cAAAAAP+cAAAAZAGQ/5wAAABk/5wAAP+cAAD+1AAAAGQAAP84/5wAAABkAZD/nAAAAGQAyP+cAAAAZP4M/5wAAABk/zj/nAAAAGQB9AAAAGQAAP84/5wAAABk/zj/nAAAAGT/OP+cAAAAZAH0AAAAZAAA/zj/nAAAAGT/OAAAAGQAAP84/5wAAABkAZD/nAAAAGQAyP+cAAAAZP4MAAAAZAAA/zj/nAAAAGQBkP+cAAAAZADI/5wAAABkAAAACgAA/5wDIAK8AB0AIQAlACkALQAxADUAOQA9AEEAAAlBAAAAAABkAAD/nAAAAGQAAP+cAAAAyAAAAGQAAAEsAAAAZAAAAGQAAP7UAAD/nAAA/tQAAP+cAAAAZAAAASwAAABkAAD/nABkAAD/nAAAAAAAZAAA/zgAAP+cAAAAZP+cAAAAZAAA/5wAAABkAZAAAP+cAAAAZP+cAAAAZAAA/5wAAABkAMgAZAAAAGQAAABkAAAAZAAAAGQAAP+cAAAAZAAA/5wAAABkAAD84AAAAGQAAP+cAAAAZAAAAGQAAABkAAD/nAAAAGQBLAAAAGQAAP84/5wAAABk/zgAZAAA/5z/nAAA/5wAAAH0AAD/nAAA/zgAZAAA/5z/nAAA/5wAAAH0AAD/nAAAAAAAAQAAAAAB9AK8ABMAAAkTAAAAAABkAAAAZAAAAGQAAABkAAAAZAAA/5wAAP+cAAD/nAAA/5wAAAAAArwAAP7UAAAAZAAAAGQAAP84AAD/nAAA/zgAAABkAAAAZAAA/tQAAQAAAAAB9AK8ABMAAAkTAAAAAABkAAAAZAAAAGQAAABkAAAAZAAA/5wAAP+cAAD/nAAA/5wAAAEsAGQAAADIAAD/nAAA/5wAAAEsAAD9RAAAASwAAP+cAAD/nAAAAMgAAQAA/5wCvAH0ABMAAAkTAAAAAABkAAAB9AAA/nAAAAGQAAAAZAAA/5wAAP5wAAABLAAA/nAAAADIAMgAAABkAAD/nAAA/zgAAP+cAAD/nAAA/5wAAABkAAAAZAAAAGQAAwAA/5wCvAK8AAkADQAdAAAJHQAAAAABkAAAAGQAAP+cAAD/OAAAAAAAZAAA/5wAyAAAAGQAAABkAAAAZAAA/5wAAABkAAD+1AAA/5wAAAAAArwAAP+cAAD/OAAA/5wAAP7UAZAAAADIAAD+cABkAAAAZAAA/zgAAP+cAAD/nAAA/5wAAADIAAAAZAACAAAAAAJYAlgACQANAAAJDQAAAAAB9AAAAGQAAP84AAD/OAAA/zgAAAH0AAAAAAGQAAD/nAAA/tQAAAEsAAD+1AH0AGQAAP+cAAAAAgAAAAACWAK8AA8AEwAACRMAAAAAAMgAAABkAAAAZAAAAMgAAP84AAD/nAAA/5wAAP84AAACWAAAAAAB9AAA/5wAAP+cAAAAyAAA/gwAAABkAAAAZAAA/zgCWABkAAD/nAAAAAMAZABkArwCvAADAA0AEQAACREAZAAAAlgAAP2oAAAAZAAAAZAAAABkAAD+DAAAAGQAZAAA/5wAZABkAAD/nAEsAMgAAABkAAD+1AAA/5wAAABkAAAAAADIAAAAAwBkAGQCvAK8AAMADwATAAAJEwBkAAACWAAA/agAAABkAAABkAAAAGQAAP+cAAD+cAAAAGQAyAAA/zgAZABkAAD/nAEsAMgAAABkAAD/nAAA/zgAAP+cAAAAZAAAAAAAyAAAAAEAAABkAlgBkAAFAAAJBQAAAAACWAAA/nAAAABkASwAAP+cAAD/OAABAAAAZAJYAZAABQAACQUBkAAA/nAAAAJYAAAAZADIAAAAZAAA/tQAAwAA/5wDIAK8ABkAHQAhAAAJIQAAAAAAZAAA/5wAAABkAAABLAAAAGQAAADIAAD/nAAAAGQAAABkAAD/nAAA/nAAAP+cAAAAAABkAAD/nAGQAAD/nAAA/5wAZAAAAMgAAADIAAAAZAAAAGQAAABkAAD/nAAA/5wAAP+cAAD/OAAA/5wAAP+cAAD/nAEsAAAAyAAA/zgAyAAA/zgAAQAAAAACWAK8AAsAAAkLAAAAAABkAAABkAAAAGQAAP84AAD/OAAAAAACWAAAAGQAAP+cAAD9qAAAAlgAAP2oAAEBLP+cAyACvAALAAAJCwMg/zgAAP+cAAD/OAAAAGQAAAEsAAAAZAGQAAAAyAAA/UQAAAK8AAAAZAAA/5wAAAABAAD/nAH0ArwACwAACQsAAADIAAAAZAAAAMgAAP+cAAD+1AAA/5wAyAAA/zgAAAK8AAD9RAAA/5wAAABkAAAAAgBkASwCWAK8AAsADwAACQ8AZAAAAGQAAAEsAAAAZAAA/5wAAP7UAAAAZABkAAD/nAGQAMgAAABkAAD/nAAA/zgAAP+cAAAAZAAAAAAAyAAAAAAAAQEsAMgB9AGQAAMAAAkDAfT/OAAAAMgAyAAAAMgAAAABAGQAyAJYArwACQAACQkBkAAA/5wAAP84AAABkAAAAGQAAADIAZAAAP5wAAAB9AAA/5wAAP5wAAEAyABkAlgB9AADAAAJAwDIAAABkAAAAGQBkAAA/nAAAQEsAAABkABkAAMAAAkDAZAAAP+cAAAAZP+cAAAAZAAIAAAAAAH0AfQAAwAHAAsADwATABcAGwAfAAAJHwAAAAAAZAAAAGQAAP+cAAAAZABkAAD/nAAAAAAAZAAA/5z/nAAAAGQAyABkAAD/nAAAAAD/nAAAAGQAZAAA/5wAyABkAAD/nAAA/5wAAABk/5wAAP+cAAABkABkAAD/nP+cAAAAZAAA/zgAAP+cAAAAyP+cAAAAZABkAAD/nAAAAAAACAAAAAAB9AH0AAMABwALAA8AEwAXABsAHwAACR8AAAAAAGQAAP+cAAAAZAAAAGT/nAAAAGQAAAAAAGQAAP+cAAAAZAAAAGQAAP+cAAAAZAAA/5wAAABkAGQAAP+cAGQAZAAA/5wAyABkAAD/nP+cAAAAZAAA/tQAZAAA/5wBkABkAAD/nP84/5wAAABkAMj/nAAAAGT/nAAA/5wAAAAAAAYAAAAAAfQCvAADAAcACwAPABMAFwAACRcAAAAAAGQAAAAAASwAAP7UAAAAAABkAAAAAAAAAGQAAP+cAAAAZAAAAGQAAABkAAAAZADIAAD/OAAAAAD/nAAAASwAZAAA/5wAZABkAAD/nADIAGQAAP+c/gwAZAAA/5wAAAADAAAAAAH0ArwAAwAPABMAAAkTAAAAAADIAAD/nAAAAGQAAABkAAAAZAAA/5wAAP+cAAAAZAAAAMgAAAAAAGQAAP+cASwAZAAAAMgAAP84AAD/nAAA/zgAAADIASwAZAAA/5wAAwAAAAAB9AK8AA0AEQAVAAAJFQAAAAAAZAAAAGQAAADIAAD/OAAAASwAAP5wAAAAZAAAAGQAAAAAAAAAZAAAASwAZAAAAMgAAP84AAD/nAAA/zgAAP+cAAABLAEsAGQAAP+c/5wAZAAA/5wAAQDIAAABLADIAAMAAAkDAMgAZAAA/5wAyAAA/zgAAAABAMgAAAEsAZAAAwAACQMAyAAAAGQAAAAAAZAAAP5wAAMAZAAAAZAB9AADAAcACwAACQsBkP+cAAAAZAAAAAD+1AAAAAAAAABkAAAAyAAAASwAAP5w/5wAAABkAGQBLAAA/tQABABkAAABkAH0AAMABwALAA8AAAkPAGQAAABkAAD/nAAAAGQAAABkAAAAZAAA/5wAAABkAAAAAABkAAD/nADIASwAAP7U/zgAZAAA/5wAyAEsAAD+1AAAAAgAAAAAAfQCvAADAAcACwAPABMAFwAbAB8AAAkfAAAAAABkAAD/nAAAASwAAP7UAAAAZAAAAGQAAP+cAAAAZABkAAD/nAAAAAAAZAAAAGQAAABkAAD/nP+cAAAAZAAAAGQAAP+cAZAAZAAA/5wAyABkAAD/nP5w/5wAAABkAGQAAP+cAAABkABkAAD/nP84AGQAAP+c/5wAAABkAAAAAAABAAAAZAH0AlgAGwAACRsAAAAAAGQAAABkAAD/nAAA/5wAAADIAAAAZAAAAMgAAP+cAAD/nAAAAGQAAABkAAD/OAAA/5wAAABkAGQAAABkAAAAZAAAAGQAAABkAAD/nAAAAGQAAP+cAAD/nAAA/5wAAP+cAAD/nAAAAGQAAP+cAAoAAAAAAfQCvAADAAcACwAPABMAFwAbAB8AIwAnAAAJJwAAAAAAZAAA/5wAAABkAAD/nAAAAGQAAABkAAD/nAAAAGT/nAAAAGQAAAAAAGQAAP+cAGQAAP+cAAAAAABkAAAAZAAAAGQAAP+c/5wAAABkAAAAZAAA/5wBkABkAAD/nADIAGQAAP+c/nD/nAAAAGQBLAAAAGQAAP84AGQAAP+c/5wAAP+cAAABkABkAAD/nP84AGQAAP+c/5wAAABkAAAAAAABAAAAAAH0ArwAEwAACRMAAAAAAGQAAABkAAAAZAAAAGQAAABkAAD/nAAA/5wAAP+cAAD/nAAAAAACvAAA/tQAAABkAAD/nAAAAMgAAP4MAAAAyAAA/5wAAABkAAD+1AAGAAAAAAH0ArwAAwALAA8AEwAXABsAAAkbAAAAAABkAAD/nAAAAGQAAADIAAD/OAAAAAAAAABkAAAAAAAAAGQAAAAAAAAAZAAAAAAAAABkAAAAAABkAAD/nAGQASwAAP+cAAD/nAAA/5z+1ABkAAD/nABkAGQAAP+cAGQAZAAA/5wAZABkAAD/nAAAAAMAAP+cAfQB9AADAAcADwAACQ8AAAAAAGQAAAAAAGQAAP+cAMgAAABkAAAAZAAA/5wAAABkAZAAAP5wAAAAAP+cAAAAAABkAAABkAAA/agAAABkAAIAyAH0AZACvAADAAcAAAkHAZAAAP+cAAD/nAAAAGQAAAK8/5wAAABk/zgAZAAA/5wAAAACAGQCWAGQArwAAwAHAAAJBwGQAAD/nAAA/zgAAABkAAACvP+cAAAAZP+cAGQAAP+cAAAABAAAAfQB9AK8AAMABwALAA8AAAkPAAAAAABkAAAAAAAAAGQAAAAAAAAAyAAAAAAAAABkAAAB9ABkAAD/nABkAGQAAP+c/5wAZAAA/5wAZABkAAD/nAAAAAQAAAAAAfQCvAAJAA0AFQAZAAAJGQAAAAAAZAAAASwAAABkAAD+cAAAAAABLAAA/tQAAAAAAGQAAABkAAAAZAAA/5wAAABkAAAAZAEsAAD/nAAAAGQAAP84AAD/nAAAAAD/nAAAAZAAZAAAAGQAAP+cAAD/nADIAGQAAP+cAAAABgAAAGQB9AJYAAMABwALAA8AEwAXAAAJFwAAAAAAZAAAAAAAAABkAAD/nAAAAGQAAABkAAAAZAAA/5wAAABkAAAAAAAAAGQAAAEsAGQAAP+c/zgAZAAA/5wBkABkAAD/nP5wAGQAAP+cAZAAZAAA/5z/OABkAAD/nAAAAAQAAABkAfQCWAADAAcACwAPAAAJDwAAAAAAZAAAASwAAP7UAAABLABkAAD/nAAAAAD+1AAAAMgBLAAA/tQAAP+cAAAAZAEsAAD+1AAAAZD/nAAAAGQAAAAHAAAAAAH0ArwAAwAHABEAFQAZAB0AIQAACSEAAAAAAGQAAP+cAAAAZAAAAGQAAABkAAAAZAAAAGQAAP+cAAD/OAAAAGQAAP+c/5wAAABkAMj/nAAAAGQAAAAAAGQAAADIAGQAAP+cAMgBLAAA/tT/OABkAAAAZAAAAGQAAP4MAAAAyADIAGQAAP+c/5wAAABkAAAAZAAAAGQAAAAAAGQAAP+cAAYAAAAAAfQCvAADAAcADQAZAB0AIQAACSEAAAAAAGQAAP+cAAAAZAAAAGQAZAAAAMgAAP7UAAAAAABkAAAAZAAAAGQAAP84AAAAZAAA/zj/nAAAAGQAyAAAAGQAAADIAGQAAP+cAMgBLAAA/tT/OAAA/5wAAP+cAAABkABkAAAAZAAA/5wAAP7UAAAAZAAAAGT/nAAAAGQAAADIAGQAAP+cAAAAAwAAAAAB9AK8AAsADwATAAAJEwAAAAAAZAAAASwAAABkAAD/nAAA/tQAAAAAASwAAP7UAAAAAAEsAAAAAAK8AAD/nAAAAGQAAP1EAAAAZAAA/5wAyAAAAGQAAADI/5wAAABkAAMAAADIAfQCvAADAAcACwAACQsAAAAAAMgAAP+cAAAAyAAAAMgAAP84AAACWABkAAD/nP5wAGQAAP+cASz/nAAAAGQAAwAA/5wB9AK8AAsAGQAdAAAJHQAAAAAAZAAAAGQAAABkAAD/nAAA/5wAAABkAAAAZAAAAGQAAABkAAD/OAAA/5wAAP+cAAAAZAAA/5wAAAEsASwAAP+cAAAAZAAA/tQAAABkAAD/nP84AGQAAP+cAAABLAAA/nAAAP+cAAAAZAAAAGQCWP+cAAAAZAABAAD/nAH0ArwAEwAACRMAAAAAAGQAAABkAAAAyAAA/zgAAAEsAAD+1AAAAMgAAP84AAAAZAAA/5wAZAAAArwAAP+cAAD/nAAA/5wAAP+cAAD/nAAA/5wAAP+cAAD/nAABAAD/nAH0ArwAHwAACR8AAAAAAMgAAP+cAAAAZAAAAGQAAABkAAD/nAAAAMgAAP84AAAAZAAA/5wAAABkAAD+1AAAAGQAAP+cAAAAZAAAASwAZAAAAGQAAABkAAAAZAAA/5wAAP+cAAD/nAAA/5wAAP+cAAD/nAAA/5wAAP+cAAAAZAAAAGQAAABkAAAAZAAHAAD/nAH0AlgAAwALAA8AEwAXABsAHwAACR8AAAAAASwAAP+cAAAAZAAAAGQAAABkAAD/nAAAAGQAAP+cAAAAZAAA/5wAAABkAAD+cAAAAMgAAP84AAAAyAAAASwAZAAA/5z+cABkAAAAZAAA/5wAAP+cAMgAZAAA/5wBkABkAAD/nP84AGQAAP+c/zgAZAAA/5wBkABkAAD/nAABAAD/nAH0ArwAEwAACRMAAAAAASwAAP84AAAAyAAAAGQAAABkAAD+1AAAAGQAAP84AAAAyAAAASwAZAAAAGQAAABkAAAAZAAA/UQAAP+cAAAAZAAAAGQAAABkAAAAZAABAAAAAAH0ArwAGwAACRsAAAAAAMgAAP+cAAAAZAAAAGQAAABkAAD/nAAAAMgAAP84AAAAZAAA/5wAAP+cAAD/nAAAAGQAAAEsAGQAAABkAAAAZAAAAGQAAP+cAAD/nAAA/5wAAP+cAAD/nAAA/5wAAP+cAAAAZAAAAGQAAABkAAUAAP+cAfQCvAADAAcACwAPABsAAAkbAAAAAABkAAD/nAAAAGQAAAAAAAAAZAAA/5wAZAAA/5wAZAAAAGQAAP+cAAAAZAAAAGQAAABkAAAAZABkAAD/nAGQAGQAAP+c/tQAZAAA/5wBLAAA/5wAAP4MAGQAAAEsAAAAZAAAASwAAP1EAAD/nAABAAD/nAMgArwAAwAACQMAAAAAAyAAAP+cAyAAAPzgAAEBLADIAfQBLAADAAAJAwH0/zgAAADIAMgAAABkAAAAAQDIASwBkAH0AAMAAAkDAZAAAP84AAAB9P84AAAAyAAEAAD/nAH0AfQAAwANABEAFQAACRUAAAAAAGQAAAAAASwAAP+cAAD/OAAAAGQAAP+cAAAAAAEsAAAAAAAAAGQAAADIAMgAAP84AAAAAP+cAAD/OAAAAGQAAABkAAABLABkAAD/nP84AGQAAP+cAAAAAQAA/5wDIAK8ABsAAAkbAAAAAADIAAAAZAAA/zgAAADIAAAAZAAAASwAAABkAAD/OAAA/5wAAADIAAD/OAAA/5wAAP7UAAAAAABkAAD/nAAAASwAAABkAAAAyAAAAGQAAP+cAAD/nAAAAGQAAP84AAD/nAAA/tQAAP+cAAAAZAABAAAAZAH0ArwADwAACQ8AAAAAAGQAAABkAAAAZAAAAGQAAABkAAD/OAAA/5wAAADIAGQAAAEsAAAAZAAA/5wAAP7UAAD/nAAA/5wAAABkAAAAGAEmAAAAAwAAAAEAEAAAAAAAAwAAAAIADgAQAAAAAwAAAAMALgAeAAAAAwAAAAQAEABMAAAAAwAAAAUABgBcAAAAAwAAAAYAEABiAAAAAwAAAAgARgByAAAAAwAAAAsAYAC4AAEAAAAAAAEACAEYAAEAAAAAAAIABwEgAAEAAAAAAAMAFwEnAAEAAAAAAAQACAE+AAEAAAAAAAUAAwFGAAEAAAAAAAYACAFJAAEAAAAAAAgAIwFRAAEAAAAAAAsAMAF0AAMAAQQJAAEAEAGkAAMAAQQJAAIADgG0AAMAAQQJAAMALgHCAAMAAQQJAAQAEAHwAAMAAQQJAAUABgIAAAMAAQQJAAYAEAIGAAMAAQQJAAgARgIWAAMAAQQJAAsAYAJcAFQAZQBtAHAAbABlAE8AUwBSAGUAZwB1AGwAYQByAFQAZQBtAHAAbABlAE8AUwAgAGMAbwBuAHYAZQByAHMAaQBvAG4AIAAxAC4AMABUAGUAbQBwAGwAZQBPAFMAMQAuADAAVQBuAHQAaQB0AGwAZQBkAE0AYQBkAGUAIABiAHkAIABSAGUAbgBkAGUAbABsAG8AIAB3AGkAdABoACAAQgBpAHQAcwAgAG4AJwAgAFAAaQBjAGEAcwBoAHQAdABwADoALwAvAHcAdwB3AC4AawByAGUAYQB0AGkAdgBlAGsAbwByAHAALgBjAG8AbQAvAHMAbwBmAHQAdwBhAHIAZQAvAGIAaQB0AHMAbgBwAGkAYwBhAHMAL1RlbXBsZU9TUmVndWxhclRlbXBsZU9TIGNvbnZlcnNpb24gMS4wVGVtcGxlT1MxLjBVbnRpdGxlZE1hZGUgYnkgUmVuZGVsbG8gd2l0aCBCaXRzIG4nIFBpY2FzaHR0cDovL3d3dy5rcmVhdGl2ZWtvcnAuY29tL3NvZnR3YXJlL2JpdHNucGljYXMvAFQAZQBtAHAAbABlAE8AUwBSAGUAZwB1AGwAYQByAFQAZQBtAHAAbABlAE8AUwAgAGMAbwBuAHYAZQByAHMAaQBvAG4AIAAxAC4AMABUAGUAbQBwAGwAZQBPAFMAMQAuADAAVQBuAHQAaQB0AGwAZQBkAE0AYQBkAGUAIABiAHkAIABSAGUAbgBkAGUAbABsAG8AIAB3AGkAdABoACAAQgBpAHQAcwAgAG4AJwAgAFAAaQBjAGEAcwBoAHQAdABwADoALwAvAHcAdwB3AC4AawByAGUAYQB0AGkAdgBlAGsAbwByAHAALgBjAG8AbQAvAHMAbwBmAHQAdwBhAHIAZQAvAGIAaQB0AHMAbgBwAGkAYwBhAHMALwAAAAIAAAAAAAD/nABkAAAAAAAAAAAAAAAAAAAAAAAAAAABQgAAAAEAAgADAAQABQAGAAcACAAJAAoACwAMAA0ADgAPABAAEQASABMAFAAVABYAFwAYABkAGgAbABwAHQAeAB8AIAAhACIAIwAkACUAJgAnACgAKQAqACsALAAtAC4ALwAwADEAMgAzADQANQA2ADcAOAA5ADoAOwA8AD0APgA/AEAAQQBCAEMARABFAEYARwBIAEkASgBLAEwATQBOAE8AUABRAFIAUwBUAFUAVgBXAFgAWQBaAFsAXABdAF4AXwBgAGEAowCEAIUAlgCGAKkAkwDyAIgAqgD1APQA9gCiAGIAkABlAGcAaABqAGkAawBsAKAAbwBxAHAAcgBzAHUAdAB2AHcAegB5AHsAfAC4AH8AfgCAAIEAugECAQMBBAEFAQYBBwEIAQkBCgELAQwBDQEOAJsBDwEQAREBEgETARQBFQEWARcBGAEZARoBGwEcAR0BHgEfASABIQEiASMBJAElASYBJwEoASkBKgErASwBLQEuAS8BMAExATIBMwE0ATUBNgE3ATgBOQE6ATsBPAE9ALUAxQE+AT8BQAFBAUIBQwClAJIApwFEAJQAlQFFAUYBRwFIAUkBSgFLAUwBTQFOAU8BUAFRAVIBUwFUAVUBVgFXAVgBWQFaAVsBXAFdAV4BXwFgAWEBYgFjAWQBZQFmAWcBaAFpAWoBawFsAW0BbgFvAXABcQFyAXMBdAF1AXYBdwF4AXkBegF7AXwBfQF+AX8BgAGBAYIBgwGEAYUBhgGHAYgBiQGKAYsBjAGNAY4BjwGQAZEBkgGTAZQBlQGWAZcBmAGZAZoBmwGcAZ0BngGfAaABoQGiAaMBpAGlAaYBpwGoAakBqgGrAawBrQGuAmlqB3VuaTAyMjYHdW5pMDIyNwVHYW1tYQVTaWdtYQNQaGkFT21lZ2EFYWxwaGEEYmV0YQVkZWx0YQdlcHNpbG9uBXRoZXRhAm11BXNpZ21hA3RhdQlhZmlpMTAwMjMJYWZpaTEwMDE5CWFmaWkxMDAyMAlhZmlpMTAwMjEJYWZpaTEwMDI0CWFmaWkxMDAyNQlhZmlpMTAwMjYJYWZpaTEwMDI3CWFmaWkxMDAyOQlhZmlpMTAwMzMJYWZpaTEwMDM3CWFmaWkxMDAzOAlhZmlpMTAwNDAJYWZpaTEwMDQxCWFmaWkxMDA0MglhZmlpMTAwNDMJYWZpaTEwMDQ0CWFmaWkxMDA0NQlhZmlpMTAwNDcJYWZpaTEwMDQ4CWFmaWkxMDA0OQlhZmlpMTAwNjYJYWZpaTEwMDY3CWFmaWkxMDA2OAlhZmlpMTAwNjkJYWZpaTEwMDcyCWFmaWkxMDA3MwlhZmlpMTAwNzQJYWZpaTEwMDc2CWFmaWkxMDA3NwlhZmlpMTAwNzgJYWZpaTEwMDc5CWFmaWkxMDA4MQlhZmlpMTAwODQJYWZpaTEwMDg2CWFmaWkxMDA4OQlhZmlpMTAwOTAJYWZpaTEwMDkxCWFmaWkxMDA5MglhZmlpMTAwOTMJYWZpaTEwMDk0CWFmaWkxMDA5NQlhZmlpMTAwOTYJYWZpaTEwMDk3CWFmaWkxMDA3MQlhZmlpNjEzNTIHdW5pMjE1Mwd1bmkyMTYwB3VuaTIxNjEHYXJyb3d1cAlhcnJvd2Rvd24LZXF1aXZhbGVuY2UIU0YxMDAwMDAIU0YxMTAwMDAIU0YwMTAwMDAIU0YwMzAwMDAIU0YwMjAwMDAIU0YwNDAwMDAIU0YwODAwMDAIU0YwOTAwMDAIU0YwNjAwMDAIU0YwNzAwMDAIU0YwNTAwMDAIU0Y0MzAwMDAIU0YyNDAwMDAIU0Y1MTAwMDAIU0Y1MjAwMDAIU0YzOTAwMDAIU0YyMjAwMDAIU0YyMTAwMDAIU0YyNTAwMDAIU0Y1MDAwMDAIU0Y0OTAwMDAIU0YzODAwMDAIU0YyODAwMDAIU0YyNzAwMDAIU0YyNjAwMDAIU0YzNjAwMDAIU0YzNzAwMDAIU0Y0MjAwMDAIU0YxOTAwMDAIU0YyMDAwMDAIU0YyMzAwMDAIU0Y0NzAwMDAIU0Y0ODAwMDAIU0Y0MTAwMDAIU0Y0NTAwMDAIU0Y0NjAwMDAIU0Y0MDAwMDAIU0Y1NDAwMDAIU0Y1MzAwMDAIU0Y0NDAwMDAHdXBibG9jawdkbmJsb2NrBWJsb2NrB2xmYmxvY2sHcnRibG9jawdsdHNoYWRlBXNoYWRlB2Rrc2hhZGUHdW5pMkI3MAd1bmkyQjcyB3VuaUUwMDEHdW5pRTAwMgd1bmlFMDAzB3VuaUUwMDQHdW5pRTAwNQd1bmlFMDA2B3VuaUUwMDcHdW5pRTAwOAd1bmlFMDA5B3VuaUUwMEEHdW5pRTAwQgd1bmlFMDBDB3VuaUUwMEQHdW5pRTAwRQd1bmlFMDBGB3VuaUUwMTAHdW5pRTAxMQd1bmlFMDEyB3VuaUUwMTQHdW5pRTAxNQd1bmlFMDE2B3VuaUUwMTcHdW5pRTAxOAd1bmlFMDE5B3VuaUUwMUEHdW5pRTAxQgd1bmlFMDFDB3VuaUUwMUQHdW5pRTAxRQd1bmlFMDFGB3VuaUUwMjEHdW5pRTAyMgd1bmlFMDIzB3VuaUUwMjQHdW5pRTAyNQd1bmlFMDI2B3VuaUUwMjcHdW5pRTAyOAd1bmlFMDI5B3VuaUUwMkIHdW5pRTAyQwd1bmlFMDJEB3VuaUUwMkUHdW5pRTAyRgd1bmlFMDMwB3VuaUUwMzEHdW5pRTAzMgd1bmlFMDMzB3VuaUUwMzQHdW5pRTAzNQd1bmlFMDM3B3VuaUUwMzgHdW5pRTAzOQd1bmlFMDQwCHVuaTFENDUzCHVuaTFGNTE0AA=="
					),
				}
			)
		),
		ProggyTiny = Font.new(
			fishy.fonts.cache:Register_Font(
				"ProggyTiny",
				400,
				"Regular",
				{
					Id = "ProggyTiny.ttf",
					Font = crypt.base64.decode(
						"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/wADAAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwBHAEsATwBTAFcAWwBfAGMAZwBrAG8AABE1MxUxNTMVMTUzFTE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUxNTMVMTUzFTE1MxWAgICAgID9AIACAID9AIACAID9AIACAID9AIACAID9AIACAID9AIACAID9AIACAID9AIACAID9AICAgICAgAOAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAABgEAAAABgAOAAAMABwALAA8AEwAXAAABNTMVBzUzFQc1MxUHNTMVBzUzFQM1MxUBAICAgICAgICAgICAAwCAgICAgICAgICAgICAgP8AgIAAAAAABgCAAoACAAQAAAMABwALAA8AEwAXAAATNTMVMzUzFQU1MxUzNTMVBTUzFTM1MxWAgICA/oCAgID+gICAgAOAgICAgICAgICAgICAgIAAAAASAAAAAAKAAwAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAEcAABM1MxUzNTMVBTUzFTE1MxUxNTMVMTUzFTE1MxUFNTMVMzUzFQU1MxUzNTMVBTUzFTE1MxUxNTMVMTUzFTE1MxUFNTMVMzUzFYCAgID+AICAgICA/gCAgID+gICAgP4AgICAgID+AICAgAKAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAEQAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwAAATUzFQU1MxUxNTMVMTUzFTE1MxUFNTMVMzUzFQU1MxUxNTMVMTUzFQU1MxUzNTMVBTUzFTE1MxUxNTMVMTUzFQU1MxUBAID/AICAgID9gICAgP8AgICA/wCAgID9gICAgID/AIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAADgAAAAADAAMAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwAAEzUzFSE1MxUFNTMVMzUzFTM1MxUFNTMVMzUzFQU1MxUzNTMVBTUzFTM1MxUzNTMVBTUzFSE1MxWAgAGAgP0AgICAgID+AICAgP8AgICA/gCAgICAgP0AgAGAgAKAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAAEQAAAAADAAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwAAEzUzFTE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUFNTMVITUzFTM1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTM1MxWAgID+gIABAID+AIABAID+gICA/oCAAQCAgID9AIABgID+AICAgICAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAMBAAKAAYAEAAADAAcACwAAATUzFQc1MxUHNTMVAQCAgICAgAOAgICAgICAgIAAAAkAgP+AAgAEAAADAAcACwAPABMAFwAbAB8AIwAAATUzFQU1MxUFNTMVBzUzFQc1MxUHNTMVBzUzHQE1Mx0BNTMVAYCA/wCA/wCAgICAgICAgICAgAOAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAACQCA/4ACAAQAAAMABwALAA8AEwAXABsAHwAjAAATNTMdATUzHQE1MxUHNTMVBzUzFQc1MxUHNTMVBTUzFQU1MxWAgICAgICAgICAgID/AID/AIADgICAgICAgICAgICAgICAgICAgICAgICAgICAAAsAAACAAoADAAADAAcACwAPABMAFwAbAB8AIwAnACsAAAE1MxUFNTMVMzUzFTM1MxUFNTMVMTUzFTE1MxUFNTMVMzUzFTM1MxUFNTMVAQCA/oCAgICAgP4AgICA/gCAgICAgP6AgAKAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAkAAACAAoADAAADAAcACwAPABMAFwAbAB8AIwAAATUzFQc1MxUFNTMVMTUzFTE1MxUxNTMVMTUzFQU1MxUHNTMVAQCAgID+gICAgICA/oCAgIACgICAgICAgICAgICAgICAgICAgICAgIAAAAIAgP+AAYAAgAADAAcAACE1MxUFNTMVAQCA/wCAgICAgIAAAAUAAAGAAoACAAADAAcACwAPABMAABE1MxUxNTMVMTUzFTE1MxUxNTMVgICAgIABgICAgICAgICAgIAAAAEBAAAAAYAAgAADAAAhNTMVAQCAgIAAAAkAAP+AAoAEAAADAAcACwAPABMAFwAbAB8AIwAAATUzFQc1MxUFNTMVBzUzFQU1MxUHNTMVBTUzFQc1MxUFNTMVAgCAgID/AICAgP8AgICA/wCAgID/AIADgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAAABEAAAAAAoADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMAABM1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMzUzFTM1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVgICAgP4AgAGAgP2AgAGAgP2AgICAgID9gIABgID9gIABgID+AICAgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAKAIAAAAIAA4AAAwAHAAsADwATABcAGwAfACMAJwAAATUzFQU1MxUxNTMVBzUzFQc1MxUHNTMVBzUzFQU1MxUxNTMVMTUzFQEAgP8AgICAgICAgICAgP8AgICAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgAAPAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAABM1MxUxNTMVMTUzFQU1MxUhNTMVBzUzFQU1MxUxNTMVBTUzFQU1MxUHNTMVMTUzFTE1MxUxNTMVMTUzFYCAgID+AIABgICAgP6AgID+gID/AICAgICAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAOAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3AAATNTMVMTUzFTE1MxUFNTMVITUzFQc1MxUFNTMVMTUzHQE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFYCAgID+AIABgICAgP6AgICA/YCAAYCA/gCAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAADgAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwAAATUzFQU1MxUxNTMVBTUzFTM1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTE1MxUxNTMVBTUzFQc1MxUBgID/AICA/oCAgID+AIABAID+AICAgICA/wCAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAARAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAAARNTMVMTUzFTE1MxUxNTMVMTUzFQU1MxUHNTMVBzUzFTE1MxUxNTMVMTUzHQE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFYCAgICA/YCAgICAgICAgID9gIABgID+AICAgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAADwAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AAABNTMVMTUzFQU1MxUFNTMVBzUzFTE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUBAICA/oCA/wCAgICAgID+AIABgID9gIABgID+AICAgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAsAAAAAAoADgAADAAcACwAPABMAFwAbAB8AIwAnACsAABE1MxUxNTMVMTUzFTE1MxUxNTMVBzUzFQU1MxUHNTMVBTUzFQc1MxUFNTMVgICAgICAgP8AgICA/wCAgID/AIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAEQAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwAAEzUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxWAgICA/gCAAYCA/YCAAYCA/gCAgID+AIABgID9gIABgID+AICAgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAA8AAAAAAoADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwAAEzUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTE1MxUHNTMVBTUzFQU1MxUxNTMVgICAgP4AgAGAgP2AgAGAgP4AgICAgICA/wCA/oCAgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAACAQAAgAGAAoAAAwAHAAABNTMVAzUzFQEAgICAAgCAgP6AgIAAAAAAAwCAAAABgAKAAAMABwALAAABNTMVAzUzFQU1MxUBAICAgP8AgAIAgID+gICAgICAAAAAAAgAAACAAoADAAADAAcACwAPABMAFwAbAB8AAAE1MxUFNTMVMTUzFQU1MxUxNTMdATUzFTE1Mx0BNTMVAgCA/oCAgP4AgICAgIACgICAgICAgICAgICAgICAgICAgICAAAoAAAEAAoACgAADAAcACwAPABMAFwAbAB8AIwAnAAARNTMVMTUzFTE1MxUxNTMVMTUzFQE1MxUxNTMVMTUzFTE1MxUxNTMVgICAgID9gICAgICAAgCAgICAgICAgICA/wCAgICAgICAgICAAAgAAACAAoADAAADAAcACwAPABMAFwAbAB8AABE1Mx0BNTMVMTUzHQE1MxUxNTMVBTUzFTE1MxUFNTMVgICAgID+AICA/oCAAoCAgICAgICAgICAgICAgICAgICAgAAAAAkAAAAAAoADgAADAAcACwAPABMAFwAbAB8AIwAAEzUzFTE1MxUxNTMVBTUzFSE1MxUHNTMVBTUzFQU1MxUDNTMVgICAgP4AgAGAgICA/wCA/wCAgIADAICAgICAgICAgICAgICAgICAgICA/wCAgAAZAAAAAAMAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAEcASwBPAFMAVwBbAF8AYwAAEzUzFTE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFTM1MxUxNTMVMzUzFQU1MxUzNTMVMTUzFTM1MxUFNTMVMzUzFTE1MxUxNTMVMTUzFQU1Mx0BNTMVMTUzFTE1MxUxNTMVMTUzFYCAgICA/YCAAgCA/QCAgICAgID9AICAgICAgP0AgICAgICA/QCAgICAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAANAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwAAATUzFQc1MxUFNTMVMzUzFQU1MxUzNTMVBTUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQEAgICA/wCAgID+gICAgP6AgICA/gCAAYCA/YCAAYCAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAUAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAEcASwBPAAARNTMVMTUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVMTUzFYCAgID+AIABgID9gIABgID9gICAgID+AIABgID9gIABgID9gICAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAADQAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMAABM1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFQc1MxUHNTMVBzUzFSE1MxUFNTMVMTUzFTE1MxWAgICA/gCAAYCA/YCAgICAgICAAYCA/gCAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAQAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwAAETUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFYCAgP6AgAEAgP4AgAGAgP2AgAGAgP2AgAGAgP2AgAEAgP4AgICAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAABIAAAAAAoADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMARwAAETUzFTE1MxUxNTMVMTUzFTE1MxUFNTMVBzUzFQc1MxUxNTMVMTUzFTE1MxUFNTMVBzUzFQc1MxUxNTMVMTUzFTE1MxUxNTMVgICAgID9gICAgICAgICA/gCAgICAgICAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAA4AAAAAAoADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAABE1MxUxNTMVMTUzFTE1MxUxNTMVBTUzFQc1MxUHNTMVMTUzFTE1MxUxNTMVBTUzFQc1MxUHNTMVgICAgID9gICAgICAgICA/gCAgICAgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAABEAAAAAAoADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMAABM1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFQc1MxUhNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUxNTMVgICAgP4AgAGAgP2AgICAAQCAgP2AgAGAgP2AgAGAgP4AgICAgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAAARAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAAARNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFYABgID9gIABgID9gIABgID9gICAgICA/YCAAYCA/YCAAYCA/YCAAYCAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAAAAsAgAAAAgADgAADAAcACwAPABMAFwAbAB8AIwAnACsAABM1MxUxNTMVMTUzFQU1MxUHNTMVBzUzFQc1MxUHNTMVBTUzFTE1MxUxNTMVgICAgP8AgICAgICAgICA/wCAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgIAADAAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvAAABNTMVMTUzFTE1MxUHNTMVBzUzFQc1MxUHNTMVBzUzFQU1MxUxNTMVMTUzFTE1MxUBAICAgICAgICAgICAgID9gICAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAAAOAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3AAARNTMVITUzFQU1MxUhNTMVBTUzFTM1MxUFNTMVMTUzFQU1MxUzNTMVBTUzFSE1MxUFNTMVITUzFYABgID9gIABAID+AICAgP6AgID/AICAgP6AgAEAgP4AgAGAgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAALAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAAARNTMVBzUzFQc1MxUHNTMVBzUzFQc1MxUHNTMVMTUzFTE1MxUxNTMVMTUzFYCAgICAgICAgICAgICAgICAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAAABQAAAAAAoADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMARwBLAE8AABE1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTM1MxUxNTMVBTUzFTE1MxUzNTMVMTUzFQU1MxUzNTMVMzUzFQU1MxUzNTMVMzUzFQU1MxUhNTMVgAGAgP2AgAGAgP2AgICAgID9gICAgICA/YCAgICAgP2AgICAgID9gIABgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAFQAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwBHAEsATwBTAAARNTMVMTUzFSE1MxUFNTMVMTUzFSE1MxUFNTMVMzUzFTM1MxUFNTMVMzUzFTM1MxUFNTMVMzUzFTM1MxUFNTMVITUzFTE1MxUFNTMVITUzFTE1MxWAgAEAgP2AgIABAID9gICAgICA/YCAgICAgP2AgICAgID9gIABAICA/YCAAQCAgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAQAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwAAEzUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFYCAgID+AIABgID9gIABgID9gIABgID9gIABgID9gIABgID+AICAgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAA8AAAAAAoADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwAAETUzFTE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUxNTMVBTUzFQc1MxUHNTMVgICAgP4AgAGAgP2AgAGAgP2AgICAgP4AgICAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAAASAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAEcAABM1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUxNTMVBTUzFTE1MxUxNTMVMTUzFYCAgID+AIABgID9gIABgID9gIABgID9gIABgID9gIABAICA/gCAgICAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAAEgAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwBHAAARNTMVMTUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxWAgICA/gCAAYCA/YCAAYCA/YCAgICA/gCAAYCA/YCAAYCA/YCAAYCAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAADwAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AAATNTMVMTUzFTE1MxUFNTMVITUzFQU1Mx0BNTMVMTUzFTE1Mx0BNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxWAgICA/gCAAYCA/YCAgICAgP2AgAGAgP4AgICAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAACwAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAAETUzFTE1MxUxNTMVMTUzFTE1MxUFNTMVBzUzFQc1MxUHNTMVBzUzFQc1MxWAgICAgP6AgICAgICAgICAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAPAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAABE1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFYABgID9gIABgID9gIABgID9gIABgID9gIABgID9gIABgID+AICAgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAMAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AABE1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUzNTMVBTUzFTM1MxUFNTMVBzUzFYABgID9gIABgID9gIABgID+AICAgP6AgICA/wCAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAEQAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwAAETUzFSE1MxUFNTMVMzUzFTM1MxUFNTMVMzUzFTM1MxUFNTMVMzUzFTM1MxUFNTMVMzUzFQU1MxUzNTMVBTUzFTM1MxWAAYCA/YCAgICAgP2AgICAgID9gICAgICA/gCAgID+gICAgP6AgICAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAA0AAAAAAoADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzAAARNTMVITUzFQU1MxUhNTMVBTUzFTM1MxUFNTMVBTUzFTM1MxUFNTMVITUzFQU1MxUhNTMVgAGAgP2AgAGAgP4AgICA/wCA/wCAgID+AIABgID9gIABgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAMAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AABE1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFQU1MxUHNTMVBzUzFYABgID9gIABgID9gIABgID+AICAgP8AgICAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAPAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAABE1MxUxNTMVMTUzFTE1MxUxNTMVBzUzFQU1MxUFNTMVBTUzFQU1MxUHNTMVMTUzFTE1MxUxNTMVMTUzFYCAgICAgID/AID/AID/AID/AICAgICAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAAANAID/gAIABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwAAEzUzFTE1MxUxNTMVBTUzFQc1MxUHNTMVBzUzFQc1MxUHNTMVBzUzFQc1MxUxNTMVMTUzFYCAgID+gICAgICAgICAgICAgICAgICAA4CAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAAAAkAAP+AAoAEAAADAAcACwAPABMAFwAbAB8AIwAAETUzFQc1Mx0BNTMVBzUzHQE1MxUHNTMdATUzFQc1Mx0BNTMVgICAgICAgICAgICAgAOAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAA0AgP+AAgAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzAAATNTMVMTUzFTE1MxUHNTMVBzUzFQc1MxUHNTMVBzUzFQc1MxUHNTMVBTUzFTE1MxUxNTMVgICAgICAgICAgICAgICAgICA/oCAgIADgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAABQAAAgACgAOAAAMABwALAA8AEwAAATUzFQU1MxUzNTMVBTUzFSE1MxUBAID/AICAgP4AgAGAgAMAgICAgICAgICAgICAAAAABgAA/4ADAAAAAAMABwALAA8AEwAXAAAVNTMVMTUzFTE1MxUxNTMVMTUzFTE1MxWAgICAgICAgICAgICAgICAgICAAAACAQACgAIAA4AAAwAHAAABNTMdATUzFQEAgIADAICAgICAAAAOAAAAAAKAAoAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3AAATNTMVMTUzFTE1Mx0BNTMVBTUzFTE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVMTUzFYCAgICA/gCAgICA/YCAAYCA/gCAgICAAgCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAAARAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAAARNTMVBzUzFQc1MxUHNTMVMTUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVMTUzFYCAgICAgICAgID+AIABgID9gIABgID9gIABgID9gICAgIADgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAALAAAAAAKAAoAAAwAHAAsADwATABcAGwAfACMAJwArAAATNTMVMTUzFTE1MxUxNTMVBTUzFQc1MxUHNTMdATUzFTE1MxUxNTMVMTUzFYCAgICA/YCAgICAgICAgIACAICAgICAgICAgICAgICAgICAgICAgICAgICAAAAAEQAAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwAAATUzFQc1MxUHNTMVBTUzFTE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTE1MxUCAICAgICA/gCAgICA/YCAAYCA/YCAAYCA/YCAAYCA/gCAgICAA4CAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAA8AAAAAAoACgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwAAEzUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUxNTMVMTUzFQU1Mx0BNTMVMTUzFTE1MxUxNTMVgICAgP4AgAGAgP2AgICAgID9gICAgICAAgCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAADQAAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMAAAE1MxUxNTMVMTUzFQU1MxUHNTMVBTUzFTE1MxUxNTMVMTUzFQU1MxUHNTMVBzUzFQc1MxUBAICAgP4AgICA/wCAgICA/oCAgICAgICAA4CAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAARAAD/AAKAAoAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAAATNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUxNTMVBzUzFQU1MxUxNTMVMTUzFYCAgID+AIABgID9gIABgID9gIABgID+AICAgICAgP4AgICAAgCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAPAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAABE1MxUHNTMVBzUzFQc1MxUxNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFYCAgICAgICAgID+AIABgID9gIABgID9gIABgID9gIABgIADgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAcAgAAAAYADgAADAAcACwAPABMAFwAbAAABNTMVATUzFTE1MxUHNTMVBzUzFQc1MxUHNTMVAQCA/wCAgICAgICAgICAAwCAgP8AgICAgICAgICAgICAgICAgAAACwAA/wACAAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAAATUzFQE1MxUxNTMVBzUzFQc1MxUHNTMVBzUzFQc1MxUFNTMVMTUzFTE1MxUBgID/AICAgICAgICAgICAgP4AgICAAwCAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgIAADQCAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMAABM1MxUHNTMVBzUzFQc1MxUhNTMVBTUzFTM1MxUFNTMVMTUzFQU1MxUzNTMVBTUzFSE1MxWAgICAgICAgAEAgP4AgICA/oCAgP8AgICA/oCAAQCAA4CAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAACQCAAAABgAQAAAMABwALAA8AEwAXABsAHwAjAAATNTMVMTUzFQc1MxUHNTMVBzUzFQc1MxUHNTMVBzUzFQc1MxWAgICAgICAgICAgICAgICAgAOAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAA8AAAAAAoACgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwAAETUzFTE1MxUzNTMVBTUzFTM1MxUzNTMVBTUzFTM1MxUzNTMVBTUzFTM1MxUzNTMVBTUzFTM1MxUzNTMVgICAgP4AgICAgID9gICAgICA/YCAgICAgP2AgICAgIACAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAMAAAAAAKAAoAAAwAHAAsADwATABcAGwAfACMAJwArAC8AABE1MxUxNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFYCAgID+AIABgID9gIABgID9gIABgID9gIABgIACAICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAMAAAAAAKAAoAAAwAHAAsADwATABcAGwAfACMAJwArAC8AABM1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFYCAgID+AIABgID9gIABgID9gIABgID+AICAgAIAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAAAQAAD/AAKAAoAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwAAETUzFTE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTE1MxUFNTMVBzUzFYCAgID+AIABgID9gIABgID9gIABgID9gICAgID+AICAgAIAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAAEAAA/wACgAKAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AABM1MxUxNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUxNTMVBzUzFQc1MxWAgICAgP2AgAGAgP2AgAGAgP2AgAGAgP4AgICAgICAgIACAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAAAAkAAAAAAoACgAADAAcACwAPABMAFwAbAB8AIwAAETUzFTM1MxUxNTMVBTUzFTE1MxUhNTMVBTUzFQc1MxUHNTMVgICAgP4AgIABAID9gICAgICAAgCAgICAgICAgICAgICAgICAgICAgICAAA0AAAAAAoACgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzAAATNTMVMTUzFTE1MxUxNTMVBTUzHQE1MxUxNTMVMTUzHQE1MxUFNTMVMTUzFTE1MxUxNTMVgICAgID9gICAgICA/YCAgICAAgCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAACwCAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAAEzUzFQc1MxUHNTMVMTUzFTE1MxUFNTMVBzUzFQc1Mx0BNTMVMTUzFTE1MxWAgICAgICAgP6AgICAgICAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAMAAAAAAKAAoAAAwAHAAsADwATABcAGwAfACMAJwArAC8AABE1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVMTUzFYABgID9gIABgID9gIABgID9gIABgID+AICAgIACAICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAJAAAAAAKAAoAAAwAHAAsADwATABcAGwAfACMAABE1MxUhNTMVBTUzFSE1MxUFNTMVMzUzFQU1MxUzNTMVBTUzFYABgID9gIABgID+AICAgP6AgICA/wCAAgCAgICAgICAgICAgICAgICAgICAgICAAAAAAAwAAAAAAoACgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAAETUzFSE1MxUFNTMVMzUzFTM1MxUFNTMVMzUzFTM1MxUFNTMVMzUzFQU1MxUzNTMVgAGAgP2AgICAgID9gICAgICA/gCAgID+gICAgAIAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAAkAAAAAAoACgAADAAcACwAPABMAFwAbAB8AIwAAETUzFSE1MxUFNTMVMzUzFQU1MxUFNTMVMzUzFQU1MxUhNTMVgAGAgP4AgICA/wCA/wCAgID+AIABgIACAICAgICAgICAgICAgICAgICAgICAgIAAAAAAEAAA/wACgAKAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AABE1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVMTUzFQc1MxUFNTMVMTUzFTE1MxWAAYCA/YCAAYCA/YCAAYCA/YCAAYCA/gCAgICAgID+AICAgAIAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAA0AAAAAAoACgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzAAARNTMVMTUzFTE1MxUxNTMVMTUzFQU1MxUFNTMVBTUzFQU1MxUxNTMVMTUzFTE1MxUxNTMVgICAgID/AID/AID/AID/AICAgICAAgCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAkAgP+AAgAEAAADAAcACwAPABMAFwAbAB8AIwAAATUzFQU1MxUHNTMVBzUzFQU1Mx0BNTMVBzUzFQc1Mx0BNTMVAYCA/wCAgICAgP8AgICAgICAgAOAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAACQEA/4ABgAQAAAMABwALAA8AEwAXABsAHwAjAAABNTMVBzUzFQc1MxUHNTMVBzUzFQc1MxUHNTMVBzUzFQc1MxUBAICAgICAgICAgICAgICAgICAA4CAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAAAJAID/gAIABAAAAwAHAAsADwATABcAGwAfACMAABM1Mx0BNTMVBzUzFQc1Mx0BNTMVBTUzFQc1MxUHNTMVBTUzFYCAgICAgICA/wCAgICAgP8AgAOAgICAgICAgICAgICAgICAgICAgICAgICAgIAABgAAAQADAAIAAAMABwALAA8AEwAXAAATNTMVMTUzFSE1MxUFNTMVITUzFTE1MxWAgIABAID9AIABAICAAYCAgICAgICAgICAgICAABMAAAAAAwADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMARwBLAAABNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTE1MxUFNTMVBTUzFTE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVAQCAgID+AIABgID9AICAgID+gID/AICAgID+gIABgID+AICAgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAAAgEA/4ACAACAAAMABwAAITUzFQU1MxUBgID/AICAgICAgAAADQCA/wACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMAAAE1MxUxNTMVBTUzFQc1MxUFNTMVMTUzFTE1MxUFNTMVBzUzFQc1MxUHNTMVBzUzFQU1MxUBgICA/oCAgID/AICAgP8AgICAgICAgICA/wCAA4CAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAABACA/4ACAACAAAMABwALAA8AADM1MxUzNTMVBTUzFTM1MxWAgICA/oCAgICAgICAgICAgIAAAAADAAAAAAKAAIAAAwAHAAsAADE1MxUzNTMVMzUzFYCAgICAgICAgICAAAAAAA0AAP+AAoAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzAAABNTMVBzUzFQU1MxUxNTMVMTUzFTE1MxUxNTMVBTUzFQc1MxUHNTMVBzUzFQc1MxUHNTMVAQCAgID+gICAgICA/oCAgICAgICAgICAgAOAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAEQAA/4ACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwAAATUzFQc1MxUFNTMVMTUzFTE1MxUxNTMVMTUzFQU1MxUFNTMVMTUzFTE1MxUxNTMVMTUzFQU1MxUHNTMVBzUzFQc1MxUBAICAgP6AgICAgID+gID+gICAgICA/oCAgICAgICAA4CAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAAAwCAAwACAAQAAAMABwALAAABNTMVBTUzFTM1MxUBAID/AICAgAOAgICAgICAgAAACwAAAIADAAMAAAMABwALAA8AEwAXABsAHwAjACcAKwAAEzUzFSE1MxUFNTMVMzUzFQU1MxUFNTMVMzUzFTM1MxUFNTMVITUzFTM1MxWAgAEAgP4AgICA/wCA/wCAgICAgP0AgAEAgICAAoCAgICAgICAgICAgICAgICAgICAgICAgICAgAAAABIAAAAAAoAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMARwAAEzUzFTM1MxUFNTMVATUzFTE1MxUxNTMVMTUzFQU1MxUHNTMVMTUzFTE1MxUxNTMVMTUzFQc1MxUFNTMVMTUzFTE1MxUxNTMVgICAgP8AgP8AgICAgP2AgICAgICAgICA/YCAgICAA4CAgICAgICA/wCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAFAIAAAAIAAoAAAwAHAAsADwATAAABNTMVBTUzFQU1Mx0BNTMdATUzFQGAgP8AgP8AgICAAgCAgICAgICAgICAgICAgAAAAAATAAAAAAMAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAEcASwAAEzUzFTE1MxUzNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFTE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUzNTMVMTUzFYCAgICAgP0AgAEAgP4AgAEAgP4AgAEAgID9gIABAID+AIABAID+gICAgICAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAQAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwAAEzUzFTM1MxUFNTMVATUzFTE1MxUxNTMVMTUzFTE1MxUFNTMVBTUzFQU1MxUFNTMVMTUzFTE1MxUxNTMVMTUzFYCAgID/AID+gICAgICA/wCA/wCA/wCA/wCAgICAgAOAgICAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAADAQACgAIABAAAAwAHAAsAAAE1MxUHNTMdATUzFQEAgICAgAOAgICAgICAgIAAAAADAQACgAIABAAAAwAHAAsAAAE1MxUHNTMVBTUzFQGAgICA/wCAA4CAgICAgICAgAAGAIACgAKABAAAAwAHAAsADwATABcAABM1MxUzNTMVBTUzFTM1MxUFNTMVMzUzFYCAgID+gICAgP8AgICAA4CAgICAgICAgICAgICAgAAAAAYAgAKAAoAEAAADAAcACwAPABMAFwAAATUzFTM1MxUFNTMVMzUzFQU1MxUzNTMVAQCAgID+gICAgP4AgICAA4CAgICAgICAgICAgICAgAAABAEAAQACAAIAAAMABwALAA8AAAE1MxUxNTMVBTUzFTE1MxUBAICA/wCAgAGAgICAgICAgICAAAAFAAABAAKAAYAAAwAHAAsADwATAAARNTMVMTUzFTE1MxUxNTMVMTUzFYCAgICAAQCAgICAgICAgICAAAAGAAABAAMAAYAAAwAHAAsADwATABcAABE1MxUxNTMVMTUzFTE1MxUxNTMVMTUzFYCAgICAgAEAgICAgICAgICAgICAAAQAgAEAAoACAAADAAcACwAPAAABNTMVMzUzFQU1MxUzNTMVAQCAgID+AICAgAGAgICAgICAgICAAAAAABAAAACAAwACgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AAARNTMVMTUzFTE1MxUxNTMVMTUzFTE1MxUFNTMVMzUzFTE1MxUxNTMVBTUzFTM1MxUzNTMVBTUzFTM1MxUzNTMVgICAgICA/YCAgICAgP2AgICAgID9gICAgICAAgCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAQAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwAAEzUzFTM1MxUFNTMVATUzFTE1MxUxNTMVMTUzFQU1Mx0BNTMVMTUzFTE1Mx0BNTMVBTUzFTE1MxUxNTMVMTUzFYCAgID/AID/AICAgID9gICAgICA/YCAgICAA4CAgICAgICA/wCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAUBAAAAAoACgAADAAcACwAPABMAAAE1Mx0BNTMdATUzFQU1MxUFNTMVAQCAgID/AID/AIACAICAgICAgICAgICAgICAAAAAAA8AAAAAAwACgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwAAEzUzFTE1MxUzNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUxNTMVBTUzFSE1MxUFNTMVMTUzFTM1MxUxNTMVgICAgICA/QCAAQCA/gCAAQCAgP2AgAEAgP6AgICAgIACAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAQAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwAAEzUzFTM1MxUFNTMVATUzFTE1MxUxNTMVMTUzFTE1MxUFNTMVBTUzFQU1MxUFNTMVMTUzFTE1MxUxNTMVMTUzFYCAgID/AID+gICAgICA/wCA/wCA/wCA/wCAgICAgAOAgICAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAANAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwAAEzUzFTM1MxUBNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUFNTMVBzUzFYCAgID+AIABgID9gIABgID9gIABgID+AICAgP8AgICAA4CAgICA/wCAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAABgEAAAABgAOAAAMABwALAA8AEwAXAAABNTMVAzUzFQc1MxUHNTMVBzUzFQc1MxUBAICAgICAgICAgICAAwCAgP8AgICAgICAgICAgICAgIAAAAAADACAAAACgAMAAAMABwALAA8AEwAXABsAHwAjACcAKwAvAAABNTMVBTUzFTE1MxUxNTMVBTUzFTM1MxUFNTMVMzUzFQU1MxUxNTMVMTUzFQU1MxUBgID/AICAgP4AgICA/oCAgID/AICAgP8AgAKAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAAEAAAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AAAE1MxUxNTMVBTUzFQc1MxUFNTMVMTUzFTE1MxUxNTMVBTUzFQU1MxUFNTMVBzUzFTE1MxUxNTMVMTUzFTE1MxUBgICA/oCAgID/AICAgID+gID/AID/AICAgICAgIADgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAEAAAAAADAAMAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AABE1MxUhNTMVBTUzFTE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUxNTMVBTUzFSE1MxWAAgCA/YCAgICA/gCAAQCA/gCAAQCA/gCAgICA/YCAAgCAAoCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAAAA8AAAAAAoADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwAAETUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFQU1MxUFNTMVMTUzFTE1MxUxNTMVMTUzFQU1MxUHNTMVgAGAgP2AgAGAgP4AgICA/wCA/oCAgICAgP6AgICAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAIAQD/gAGABAAAAwAHAAsADwATABcAGwAfAAABNTMVBzUzFQc1MxUHNTMVAzUzFQc1MxUHNTMVBzUzFQEAgICAgICAgICAgICAgICAA4CAgICAgICAgICAgP8AgICAgICAgICAgIAAABIAAP8AAoAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMARwAAATUzFTE1MxUFNTMVBzUzFQU1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUFNTMVBzUzFQU1MxUxNTMVAYCAgP6AgICA/wCAgID+AIABgID9gIABgID+AICAgP8AgICA/oCAgAOAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAACAIADAAIAA4AAAwAHAAATNTMVMzUzFYCAgIADAICAgIAAAAAXAAAAAAMAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAEcASwBPAFMAVwBbAAATNTMVMTUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVMzUzFTE1MxUzNTMVBTUzFTM1MxUhNTMVBTUzFTM1MxUxNTMVMzUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVMTUzFYCAgICA/YCAAgCA/QCAgICAgID9AICAgAEAgP0AgICAgICA/QCAAgCA/YCAgICAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAIAIABgAIABAAAAwAHAAsADwATABcAGwAfAAABNTMdATUzFQU1MxUxNTMVBTUzFTM1MxUFNTMVMTUzFQEAgID/AICA/oCAgID/AICAA4CAgICAgICAgICAgICAgICAgICAgAAACgAAAAADAAKAAAMABwALAA8AEwAXABsAHwAjACcAAAE1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUBAIABAID9gIABAID9gIABAID+gIABAID+gIABAIACAICAgICAgICAgICAgICAgICAgICAgICAgAAHAIAAAAKAAgAAAwAHAAsADwATABcAGwAAEzUzFTE1MxUxNTMVMTUzFQc1MxUHNTMVBzUzFYCAgICAgICAgICAAYCAgICAgICAgICAgICAgICAgAAVAAAAAAMAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAEcASwBPAFMAABM1MxUxNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUhNTMVMzUzFQU1MxUzNTMVITUzFQU1MxUzNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVMTUzFYCAgICA/YCAAgCA/QCAAQCAgID9AICAgAEAgP0AgICAAQCA/QCAAgCA/YCAgICAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAUAAAMAAoADgAADAAcACwAPABMAABE1MxUxNTMVMTUzFTE1MxUxNTMVgICAgIADAICAgICAgICAgIAAAAQAgAIAAgADgAADAAcACwAPAAABNTMVBTUzFTM1MxUFNTMVAQCA/wCAgID/AIADAICAgICAgICAgIAAAA4AAAAAAoADAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAAAE1MxUHNTMVBTUzFTE1MxUxNTMVMTUzFTE1MxUFNTMVBzUzFQU1MxUxNTMVMTUzFTE1MxUxNTMVAQCAgID+gICAgICA/oCAgID+gICAgICAAoCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAgAgAGAAgAEAAADAAcACwAPABMAFwAbAB8AABM1MxUxNTMdATUzFQU1MxUFNTMVBzUzFTE1MxUxNTMVgICAgP8AgP8AgICAgIADgICAgICAgICAgICAgICAgICAgICAAAgAgAGAAgAEAAADAAcACwAPABMAFwAbAB8AABM1MxUxNTMdATUzFQU1MxUxNTMdATUzFQU1MxUxNTMVgICAgP6AgICA/oCAgAOAgICAgICAgICAgICAgICAgICAgIAAAAIBAAMAAgAEAAADAAcAAAE1MxUFNTMVAYCA/wCAA4CAgICAgAAAAAAOAAD/AAMAAoAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3AAATNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTM1MxUFNTMVBTUzFYCAAQCA/gCAAQCA/gCAAQCA/gCAAQCA/gCAgICAgP2AgP8AgAIAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAaAAD/AAMAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAEcASwBPAFMAVwBbAF8AYwBnAAATNTMVMTUzFTE1MxUxNTMVMTUzFQU1MxUxNTMVMTUzFTM1MxUFNTMVMTUzFTE1MxUzNTMVBTUzFTE1MxUzNTMVBTUzFTM1MxUFNTMVMzUzFQU1MxUzNTMVBTUzFTM1MxUFNTMVMzUzFYCAgICAgP0AgICAgID9gICAgICA/gCAgICA/oCAgID+gICAgP6AgICA/oCAgID+gICAgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAAAAEBAAGAAYACAAADAAABNTMVAQCAAYCAgAAAAAAEAQD/AAIAAIAAAwAHAAsADwAAITUzFTE1MxUHNTMVBTUzFQEAgICAgP8AgICAgICAgICAgIAAAAgAgAGAAgAEAAADAAcACwAPABMAFwAbAB8AAAE1MxUFNTMVMTUzFQc1MxUHNTMVBTUzFTE1MxUxNTMVAQCA/wCAgICAgID/AICAgAOAgICAgICAgICAgICAgICAgICAgIAAAAAGAIACAAIABAAAAwAHAAsADwATABcAAAE1MxUFNTMVMzUzFQU1MxUzNTMVBTUzFQEAgP8AgICA/oCAgID/AIADgICAgICAgICAgICAgICAgAAAAAAKAAAAAAMAAoAAAwAHAAsADwATABcAGwAfACMAJwAAETUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFYABAID+gIABAID+gIABAID9gIABAID9gIABAIACAICAgICAgICAgICAgICAgICAgICAgICAgAAAABMAAP+AAwAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMARwBLAAABNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMzUzFTE1MxUFNTMVMzUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVAgCA/YCAAYCA/YCAAQCA/gCAAQCA/wCAAQCA/gCAgICA/YCAgICAgP2AgAGAgP0AgAOAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAEgAA/4ADAAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwBHAAABNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTM1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVMTUzFQU1MxUCAID9gIABgID9gIABAID+AIABAID/AICAgID+AIABAID9gIABAID+AIABAICA/QCAA4CAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAFgAA/4ADAAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwBHAEsATwBTAFcAABE1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTM1MxUFNTMVMzUzFQU1MxUzNTMVITUzFQU1MxUzNTMVMTUzFQU1MxUzNTMVMTUzFTE1MxUFNTMVITUzFQU1MxWAAYCA/gCAAQCA/YCAgICA/oCAgID+AICAgAEAgP4AgICAgP2AgICAgID9gIABgID9AIADgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAACQAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjAAABNTMVAzUzHQE1Mx0BNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUBAICAgICA/YCAAYCA/gCAgIADAICA/wCAgICAgICAgICAgICAgICAgICAgAAAAAwAAAAAAoAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAAEzUzHQE1MxUDNTMVBTUzFTM1MxUFNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUhNTMVgICAgID/AICAgP6AgICA/gCAAYCA/YCAAYCAA4CAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAAAwAAAAAAoAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAAATUzFQU1MxURNTMVBTUzFTM1MxUFNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUhNTMVAQCA/wCAgP8AgICA/oCAgID+AIABgID9gIABgIADgICAgICA/wCAgICAgICAgICAgICAgICAgICAgICAgIAAAAANAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwAAATUzFQU1MxUzNTMVATUzFQU1MxUzNTMVBTUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQEAgP8AgICA/wCA/wCAgID+gICAgP4AgAGAgP2AgAGAgAOAgICAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAAAAADgAAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwAAATUzFTM1MxUFNTMVMzUzFQE1MxUFNTMVMzUzFQU1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUBAICAgP4AgICA/wCA/wCAgID+gICAgP4AgAGAgP2AgAGAgAOAgICAgICAgICA/wCAgICAgICAgICAgICAgICAgICAgICAgIAADAAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvAAATNTMVMzUzFQE1MxUFNTMVMzUzFQU1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxWAgICA/wCA/wCAgID+gICAgP4AgAGAgP2AgAGAgAMAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAAAAAAA4AAAAAAoAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAAAE1MxUFNTMVMzUzFQU1MxUHNTMVBTUzFTM1MxUFNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUhNTMVAQCA/wCAgID/AICAgP8AgICA/oCAgID+AIABgID9gIABgIADgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAABQAAAAAAwADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMARwBLAE8AAAE1MxUxNTMVMTUzFTE1MxUFNTMVMzUzFQU1MxUzNTMVBTUzFTE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFTE1MxUxNTMVAQCAgICA/YCAgID+gICAgP6AgICAgP2AgAEAgP4AgAEAgP4AgAEAgICAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAADwAA/wACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AAATNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUHNTMVBzUzFQc1MxUhNTMVBTUzFTE1MxUxNTMVBTUzFQU1MxWAgICA/gCAAYCA/YCAgICAgICAAYCA/gCAgID/AID/AIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAASAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAEcAABM1Mx0BNTMVATUzFTE1MxUxNTMVMTUzFTE1MxUFNTMVBzUzFTE1MxUxNTMVMTUzFQU1MxUHNTMVMTUzFTE1MxUxNTMVMTUzFYCAgP6AgICAgID9gICAgICAgP4AgICAgICAgAOAgICAgID/AICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAASAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAEcAAAE1MxUFNTMVATUzFTE1MxUxNTMVMTUzFTE1MxUFNTMVBzUzFTE1MxUxNTMVMTUzFQU1MxUHNTMVMTUzFTE1MxUxNTMVMTUzFQEAgP8AgP8AgICAgID9gICAgICAgP4AgICAgICAgAOAgICAgID/AICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAEwAAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwBHAEsAAAE1MxUFNTMVMzUzFQE1MxUxNTMVMTUzFTE1MxUxNTMVBTUzFQc1MxUxNTMVMTUzFTE1MxUFNTMVBzUzFTE1MxUxNTMVMTUzFTE1MxUBAID/AICAgP4AgICAgID9gICAgICAgP4AgICAgICAgAOAgICAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAAABIAAAAAAoADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMARwAAEzUzFTM1MxUBNTMVMTUzFTE1MxUxNTMVMTUzFQU1MxUHNTMVMTUzFTE1MxUxNTMVBTUzFQc1MxUxNTMVMTUzFTE1MxUxNTMVgICAgP4AgICAgID9gICAgICAgP4AgICAgICAgAMAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAsAgAAAAgAEAAADAAcACwAPABMAFwAbAB8AIwAnACsAABM1Mx0BNTMVATUzFTE1MxUxNTMVBTUzFQc1MxUHNTMVBTUzFTE1MxUxNTMVgICA/wCAgID/AICAgICA/wCAgIADgICAgICA/wCAgICAgICAgICAgICAgICAgICAgICAAAAAAAsAgAAAAgAEAAADAAcACwAPABMAFwAbAB8AIwAnACsAAAE1MxUFNTMVAzUzFTE1MxUxNTMVBTUzFQc1MxUHNTMVBTUzFTE1MxUxNTMVAQCA/wCAgICAgP8AgICAgID/AICAgAOAgICAgID/AICAgICAgICAgICAgICAgICAgICAgIAAAAwAgAAAAgAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAAATUzFQU1MxUzNTMVATUzFTE1MxUxNTMVBTUzFQc1MxUHNTMVBTUzFTE1MxUxNTMVAQCA/wCAgID+gICAgP8AgICAgID/AICAgAOAgICAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgAAAAAsAgAAAAgADgAADAAcACwAPABMAFwAbAB8AIwAnACsAABM1MxUzNTMVATUzFTE1MxUxNTMVBTUzFQc1MxUHNTMVBTUzFTE1MxUxNTMVgICAgP6AgICA/wCAgICAgP8AgICAAwCAgICA/wCAgICAgICAgICAgICAgICAgICAgICAAAAAABMAAAAAAwADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMARwBLAAATNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVMTUzFTM1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVgICAgP6AgAEAgP4AgAGAgP0AgICAgICA/YCAAYCA/YCAAQCA/gCAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAAABMAAAAAAoAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMARwBLAAABNTMVMzUzFQU1MxUzNTMVATUzFTE1MxUhNTMVBTUzFTM1MxUzNTMVBTUzFTM1MxUzNTMVBTUzFSE1MxUxNTMVBTUzFSE1MxUxNTMVAQCAgID+AICAgP4AgIABAID9gICAgICA/YCAgICAgP2AgAEAgID9gIABAICAA4CAgICAgICAgID/AICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAOAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3AAATNTMdATUzFQE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFYCAgP8AgICA/gCAAYCA/YCAAYCA/YCAAYCA/gCAgIADgICAgICA/wCAgICAgICAgICAgICAgICAgICAgICAgICAgICAAA4AAAAAAoAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAAAE1MxUFNTMVAzUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVAQCA/wCAgICAgP4AgAGAgP2AgAGAgP2AgAGAgP4AgICAA4CAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAA8AAAAAAoAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwAAATUzFQU1MxUzNTMVATUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVAQCA/wCAgID+gICAgP4AgAGAgP2AgAGAgP2AgAGAgP4AgICAA4CAgICAgICA/wCAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAAABAAAAAAAoAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AAABNTMVMzUzFQU1MxUzNTMVATUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVAQCAgID+AICAgP6AgICA/gCAAYCA/YCAAYCA/YCAAYCA/gCAgIADgICAgICAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAADgAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwAAEzUzFTM1MxUBNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxWAgICA/oCAgID+AIABgID9gIABgID9gIABgID+AICAgAMAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAJAAAAgAKAAwAAAwAHAAsADwATABcAGwAfACMAABE1MxUhNTMVBTUzFTM1MxUFNTMVBTUzFTM1MxUFNTMVITUzFYABgID+AICAgP8AgP8AgICA/gCAAYCAAoCAgICAgICAgICAgICAgICAgICAgICAAAAAABAAAAAAAwADAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AAABNTMVMTUzFTM1MxUFNTMVITUzFQU1MxUzNTMVMTUzFQU1MxUxNTMVMzUzFQU1MxUhNTMVBTUzFTM1MxUxNTMVAQCAgICA/YCAAQCA/gCAgICA/gCAgICA/gCAAQCA/YCAgICAAoCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAANAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwAAEzUzHQE1MxUBNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFYCAgP6AgAGAgP2AgAGAgP2AgAGAgP2AgAGAgP4AgICAA4CAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAADQAAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMAAAE1MxUFNTMVATUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUBAID/AID/AIABgID9gIABgID9gIABgID9gIABgID+AICAgAOAgICAgID/AICAgICAgICAgICAgICAgICAgICAgICAgICAAA4AAAAAAoAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAAAE1MxUFNTMVMzUzFQE1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVAQCA/wCAgID+AIABgID9gIABgID9gIABgID9gIABgID+AICAgAOAgICAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAANAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwAAEzUzFTM1MxUBNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFYCAgID+AIABgID9gIABgID9gIABgID9gIABgID+AICAgAMAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAADQAAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMAAAE1MxUFNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVBTUzFQc1MxUBgID/AID+gIABgID9gIABgID9gIABgID+AICAgP8AgICAA4CAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAA4AgP+AAoADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAABM1MxUHNTMVBzUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFQU1MxUHNTMVgICAgICAgID+gIABAID+AIABAID+AICAgP6AgICAAwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAEgAA/4ACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwBHAAATNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFQU1MxWAgICA/oCAAQCA/gCAAQCA/gCAgID+gIABAID+AIABAID+AICAgP4AgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAABAAAAAAAoAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AAATNTMdATUzFQE1MxUxNTMVMTUzHQE1MxUFNTMVMTUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUxNTMVgICA/wCAgICA/gCAgICA/YCAAYCA/gCAgICAA4CAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAEAAAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AAAE1MxUFNTMVAzUzFTE1MxUxNTMdATUzFQU1MxUxNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTE1MxUBAID/AICAgICAgP4AgICAgP2AgAGAgP4AgICAgAOAgICAgID/AICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAAEQAAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwAAATUzFQU1MxUzNTMVATUzFTE1MxUxNTMdATUzFQU1MxUxNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTE1MxUBAID/AICAgP6AgICAgP4AgICAgP2AgAGAgP4AgICAgAOAgICAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAAEgAAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwBHAAABNTMVMzUzFQU1MxUzNTMVATUzFTE1MxUxNTMdATUzFQU1MxUxNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTE1MxUBAICAgP4AgICA/oCAgICA/gCAgICA/YCAAYCA/gCAgICAA4CAgICAgICAgID/AICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAQAAAAAAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwAAEzUzFTM1MxUBNTMVMTUzFTE1Mx0BNTMVBTUzFTE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVMTUzFYCAgID+gICAgID+AICAgID9gIABgID+AICAgIADAICAgID/AICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAABIAAAAAAoAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMARwAAATUzFQU1MxUzNTMVBTUzFQU1MxUxNTMVMTUzHQE1MxUFNTMVMTUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUxNTMVAQCA/wCAgID/AID/AICAgID+AICAgID9gIABgID+AICAgIADgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAADwAAAAADAAKAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AAATNTMVMTUzFTM1MxUFNTMVMzUzFQU1MxUxNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUxNTMVMzUzFTE1MxWAgICAgP8AgICA/YCAgICA/YCAAQCA/oCAgICAgAIAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAADQAA/wACgAKAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMAABM1MxUxNTMVMTUzFTE1MxUFNTMVBzUzFQc1Mx0BNTMVMTUzFTE1MxUxNTMVBTUzFQU1MxWAgICAgP2AgICAgICAgICA/oCA/wCAAgCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAABEAAAAAAoAEAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMAABM1Mx0BNTMVATUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUxNTMVMTUzFQU1Mx0BNTMVMTUzFTE1MxUxNTMVgICA/wCAgID+AIABgID9gICAgICA/YCAgICAgAOAgICAgID/AICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAAEQAAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwAAATUzFQU1MxUDNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTE1MxUxNTMVBTUzHQE1MxUxNTMVMTUzFTE1MxUBAID/AICAgICA/gCAAYCA/YCAgICAgP2AgICAgIADgICAgICA/wCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAASAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAEcAAAE1MxUFNTMVMzUzFQE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVMTUzFTE1MxUFNTMdATUzFTE1MxUxNTMVMTUzFQEAgP8AgICA/oCAgID+AIABgID9gICAgICA/YCAgICAgAOAgICAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAABEAAAAAAoADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AEMAABM1MxUzNTMVATUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUxNTMVMTUzFQU1Mx0BNTMVMTUzFTE1MxUxNTMVgICAgP6AgICA/gCAAYCA/YCAgICAgP2AgICAgIADAICAgID/AICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAACACAAAABgAQAAAMABwALAA8AEwAXABsAHwAAEzUzHQE1MxUBNTMVMTUzFQc1MxUHNTMVBzUzFQc1MxWAgID/AICAgICAgICAgIADgICAgICA/wCAgICAgICAgICAgICAgICAAAgAgAAAAYAEAAADAAcACwAPABMAFwAbAB8AAAE1MxUFNTMVAzUzFTE1MxUHNTMVBzUzFQc1MxUHNTMVAQCA/wCAgICAgICAgICAgIADgICAgICA/wCAgICAgICAgICAgICAgICAAAAACQCAAAACAAQAAAMABwALAA8AEwAXABsAHwAjAAABNTMVBTUzFTM1MxUBNTMVMTUzFQc1MxUHNTMVBzUzFQc1MxUBAID/AICAgP6AgICAgICAgICAgAOAgICAgICAgP8AgICAgICAgICAgICAgICAgAAAAAAIAIAAAAIAA4AAAwAHAAsADwATABcAGwAfAAATNTMVMzUzFQE1MxUxNTMVBzUzFQc1MxUHNTMVBzUzFYCAgID+gICAgICAgICAgIADAICAgID/AICAgICAgICAgICAgICAgIAAEAAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AABM1MxUxNTMVMzUzFQU1Mx0BNTMVBTUzFTE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxWAgICAgP8AgID+AICAgID9gIABgID9gIABgID+AICAgAMAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAEAAAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AAAE1MxUzNTMVBTUzFTM1MxUBNTMVMTUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUBAICAgP4AgICA/gCAgICA/gCAAYCA/YCAAYCA/YCAAYCA/YCAAYCAA4CAgICAgICAgID/AICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAADgAAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwAAEzUzHQE1MxUBNTMVMTUzFTE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxWAgID/AICAgP4AgAGAgP2AgAGAgP2AgAGAgP4AgICAA4CAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAOAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3AAABNTMVBTUzFQM1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFQEAgP8AgICAgID+AIABgID9gIABgID9gIABgID+AICAgAOAgICAgID/AICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAPAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAAAE1MxUFNTMVMzUzFQE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFQEAgP8AgICA/oCAgID+AIABgID9gIABgID9gIABgID+AICAgAOAgICAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAAAQAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwAAEzUzFTM1MxUFNTMVMzUzFQE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFYCAgID+AICAgP8AgICA/gCAAYCA/YCAAYCA/YCAAYCA/gCAgIADgICAgICAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAA4AAAAAAoADgAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAABM1MxUzNTMVATUzFTE1MxUxNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVgICAgP6AgICA/gCAAYCA/YCAAYCA/YCAAYCA/gCAgIADAICAgID/AICAgICAgICAgICAgICAgICAgICAgICAgICAgIAABwAAAIACgAMAAAMABwALAA8AEwAXABsAAAE1MxUBNTMVMTUzFTE1MxUxNTMVMTUzFQE1MxUBAID+gICAgICA/oCAAoCAgP8AgICAgICAgICAgP8AgIAAABAAAAAAAwADAAADAAcACwAPABMAFwAbAB8AIwAnACsALwAzADcAOwA/AAABNTMVMTUzFTM1MxUFNTMVITUzFQU1MxUzNTMVMTUzFQU1MxUxNTMVMzUzFQU1MxUhNTMVBTUzFTM1MxUxNTMVAQCAgICA/YCAAQCA/gCAgICA/gCAgICA/gCAAQCA/YCAgICAAoCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAOAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3AAATNTMdATUzFQE1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVMTUzFYCAgP6AgAGAgP2AgAGAgP2AgAGAgP2AgAGAgP4AgICAgAOAgICAgID/AICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAOAAAAAAKABAAAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3AAABNTMVBTUzFQE1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVMTUzFQEAgP8AgP8AgAGAgP2AgAGAgP2AgAGAgP2AgAGAgP4AgICAgAOAgICAgID/AICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAAADwAAAAACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AAABNTMVBTUzFTM1MxUBNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTE1MxUBAID/AICAgP4AgAGAgP2AgAGAgP2AgAGAgP2AgAGAgP4AgICAgAOAgICAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAADgAAAAACgAOAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwAAEzUzFTM1MxUBNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTE1MxWAgICA/gCAAYCA/YCAAYCA/YCAAYCA/YCAAYCA/gCAgICAAwCAgICA/wCAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAAAEgAA/wACgAQAAAMABwALAA8AEwAXABsAHwAjACcAKwAvADMANwA7AD8AQwBHAAABNTMVBTUzFQE1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFTE1MxUxNTMVMTUzFQc1MxUFNTMVMTUzFTE1MxUBAID/AID/AIABgID9gIABgID9gIABgID9gIABgID+AICAgICAgP4AgICAA4CAgICAgP8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAAAAASAAD/AAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAEcAABE1MxUHNTMVBzUzFTE1MxUxNTMVMTUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVITUzFQU1MxUxNTMVMTUzFTE1MxUFNTMVBzUzFYCAgICAgICA/gCAAYCA/YCAAYCA/YCAAYCA/YCAgICA/gCAgIADAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAAAASAAD/AAKAA4AAAwAHAAsADwATABcAGwAfACMAJwArAC8AMwA3ADsAPwBDAEcAABM1MxUzNTMVATUzFSE1MxUFNTMVITUzFQU1MxUhNTMVBTUzFSE1MxUFNTMVMTUzFTE1MxUxNTMVBzUzFQU1MxUxNTMVMTUzFYCAgID+AIABgID9gIABgID9gIABgID9gIABgID+AICAgICAgP4AgICAAwCAgICA/wCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAAAVAQIAAAAAAAAAAAAkAEcAAAAAAAAAAQAYAIEAAAAAAAAAAgAOAGsAAAAAAAAAAwAYAIEAAAAAAAAABAAYAIEAAAAAAAAABQAUAAAAAAAAAAAABgAYAIEAAQAAAAAAAAASABQAAQAAAAAAAQAMADEAAQAAAAAAAgAHACYAAQAAAAAAAwAQAC0AAQAAAAAABAAMADEAAQAAAAAABQAKAD0AAQAAAAAABgAMADEAAwABBAkAAAAkAEcAAwABBAkAAQAYAIEAAwABBAkAAgAOAGsAAwABBAkAAwAgAHkAAwABBAkABAAYAIEAAwABBAkABQAUAAAAAwABBAkABgAYAIEAMgAwADAANAAvADAANAAvADEANWJ5IFRyaXN0YW4gR3JpbW1lclJlZ3VsYXJUVFggUHJvZ2d5VGlueVRUMjAwNC8wNC8xNQBiAHkAIABUAHIAaQBzAHQAYQBuACAARwByAGkAbQBtAGUAcgBSAGUAZwB1AGwAYQByAFQAVABYACAAUAByAG8AZwBnAHkAVABpAG4AeQBUAFQAAAIAAAAAAAAAAAAUAAAAAQAAAAAAAAAAAAAAAAAAAAABAQAAAAEBAgEDAQQBBQEGAQcBCAEJAQoBCwEMAQ0BDgEPARABEQESARMBFAEVARYBFwEYARkBGgEbARwBHQEeAR8BIAADAAQABQAGAAcACAAJAAoACwAMAA0ADgAPABAAEQASABMAFAAVABYAFwAYABkAGgAbABwAHQAeAB8AIAAhACIAIwAkACUAJgAnACgAKQAqACsALAAtAC4ALwAwADEAMgAzADQANQA2ADcAOAA5ADoAOwA8AD0APgA/AEAAQQBCAEMARABFAEYARwBIAEkASgBLAEwATQBOAE8AUABRAFIAUwBUAFUAVgBXAFgAWQBaAFsAXABdAF4AXwBgAGEBIQEiASMBJAElASYBJwEoASkBKgErASwBLQEuAS8BMAExATIBMwE0ATUBNgE3ATgBOQE6ATsBPAE9AT4BPwFAAUEArACjAIQAhQC9AJYA6ACGAI4AiwCdAKkApADvAIoA2gCDAJMA8gDzAI0AlwCIAMMA3gDxAJ4AqgD1APQA9gCiAK0AyQDHAK4AYgBjAJAAZADLAGUAyADKAM8AzADNAM4A6QBmANMA0ADRAK8AZwDwAJEA1gDUANUAaADrAO0AiQBqAGkAawBtAGwAbgCgAG8AcQBwAHIAcwB1AHQAdgB3AOoAeAB6AHkAewB9AHwAuAChAH8AfgCAAIEA7ADuALoOdW5pY29kZSMweDAwMDEOdW5pY29kZSMweDAwMDIOdW5pY29kZSMweDAwMDMOdW5pY29kZSMweDAwMDQOdW5pY29kZSMweDAwMDUOdW5pY29kZSMweDAwMDYOdW5pY29kZSMweDAwMDcOdW5pY29kZSMweDAwMDgOdW5pY29kZSMweDAwMDkOdW5pY29kZSMweDAwMGEOdW5pY29kZSMweDAwMGIOdW5pY29kZSMweDAwMGMOdW5pY29kZSMweDAwMGQOdW5pY29kZSMweDAwMGUOdW5pY29kZSMweDAwMGYOdW5pY29kZSMweDAwMTAOdW5pY29kZSMweDAwMTEOdW5pY29kZSMweDAwMTIOdW5pY29kZSMweDAwMTMOdW5pY29kZSMweDAwMTQOdW5pY29kZSMweDAwMTUOdW5pY29kZSMweDAwMTYOdW5pY29kZSMweDAwMTcOdW5pY29kZSMweDAwMTgOdW5pY29kZSMweDAwMTkOdW5pY29kZSMweDAwMWEOdW5pY29kZSMweDAwMWIOdW5pY29kZSMweDAwMWMOdW5pY29kZSMweDAwMWQOdW5pY29kZSMweDAwMWUOdW5pY29kZSMweDAwMWYGZGVsZXRlBEV1cm8OdW5pY29kZSMweDAwODEOdW5pY29kZSMweDAwODIOdW5pY29kZSMweDAwODMOdW5pY29kZSMweDAwODQOdW5pY29kZSMweDAwODUOdW5pY29kZSMweDAwODYOdW5pY29kZSMweDAwODcOdW5pY29kZSMweDAwODgOdW5pY29kZSMweDAwODkOdW5pY29kZSMweDAwOGEOdW5pY29kZSMweDAwOGIOdW5pY29kZSMweDAwOGMOdW5pY29kZSMweDAwOGQOdW5pY29kZSMweDAwOGUOdW5pY29kZSMweDAwOGYOdW5pY29kZSMweDAwOTAOdW5pY29kZSMweDAwOTEOdW5pY29kZSMweDAwOTIOdW5pY29kZSMweDAwOTMOdW5pY29kZSMweDAwOTQOdW5pY29kZSMweDAwOTUOdW5pY29kZSMweDAwOTYOdW5pY29kZSMweDAwOTcOdW5pY29kZSMweDAwOTgOdW5pY29kZSMweDAwOTkOdW5pY29kZSMweDAwOWEOdW5pY29kZSMweDAwOWIOdW5pY29kZSMweDAwOWMOdW5pY29kZSMweDAwOWQOdW5pY29kZSMweDAwOWUOdW5pY29kZSMweDAwOWYAAA=="
					),
				}
			)
		),
	}
end

local part_points = {
	torso = { "UpperTorso", "LowerTorso" },
	larm = { "LeftUpperArm", "LeftLowerArm", "LeftHand" },
	rarm = { "RightUpperArm", "RightLowerArm", "RightHand" },
	lleg = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" },
	rleg = { "RightUpperLeg", "RightLowerLeg", "RightFoot" },
	head = "Head",
}

local vector3_to_vector2 = function(vector)
	return Vector2.new(vector.X, vector.Y)
end

local draw_line = function(frame, from, to)
	local netVector = to - from

	local length = math.sqrt(netVector.X ^ 2 + netVector.Y ^ 2)
	local midpoint = Vector2.new((from.X + to.X) / 2, (from.Y + to.Y) / 2)
	local theta = math.deg(math.atan2(from.Y - to.Y, from.X - to.X))

	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
	frame.Rotation = theta
	frame.Size = UDim2.new(0, length, 0, Library.Flags["skeleton esp thickness"]:Get())
end

local ESP = function(model)
	local esp_connection
	local esp_holder = fishy.functions:create("ScreenGui", { Parent = gethui(), Name = "esp_holder" })

	local drawings = {
		name = fishy.functions:create(
			"TextLabel",
			{
				Parent = esp_holder,
				BackgroundTransparency = 1,
				TextStrokeTransparency = 0,
				TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
				FontFace = fishy.fonts.options.ProggyTiny,
				TextSize = 9,
				Text = model.Name,
			}
		),
		distance = fishy.functions:create(
			"TextLabel",
			{
				Parent = esp_holder,
				BackgroundTransparency = 1,
				TextStrokeTransparency = 0,
				TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
				FontFace = fishy.fonts.options.ProggyTiny,
				TextSize = 9,
			}
		),
		weapon = fishy.functions:create(
			"TextLabel",
			{
				Parent = esp_holder,
				BackgroundTransparency = 1,
				TextStrokeTransparency = 0,
				TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
				FontFace = fishy.fonts.options.ProggyTiny,
				TextSize = 9,
			}
		),
		HealthText = fishy.functions:create(
			"TextLabel",
			{
				Parent = esp_holder,
				TextXAlignment = Enum.TextXAlignment.Center,
				FontFace = fishy.fonts.options.ProggyTiny,
				TextSize = 9,
				BackgroundTransparency = 1,
				TextStrokeTransparency = 0,
				ZIndex = 999,
				TextStrokeColor3 = Color3.new(0, 0, 0),
			}
		),
		Flag1 = fishy.functions:create(
			"TextLabel",
			{
				Parent = esp_holder,
				Text = "",
				TextColor3 = Color3.new(0, 0.85, 0),
				FontFace = fishy.fonts.options.ProggyTiny,
				TextSize = 9,
				BackgroundTransparency = 1,
				TextStrokeTransparency = 0,
				ZIndex = 999,
				TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Right,
			}
		),
		Flag2 = fishy.functions:create(
			"TextLabel",
			{
				Parent = esp_holder,
				Text = "",
				FontFace = fishy.fonts.options.JuraLight,
				TextSize = 9,
				BackgroundTransparency = 1,
				TextStrokeTransparency = 0,
				ZIndex = 999,
				TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Right,
			}
		),

		BehindHealthbar = fishy.functions:create(
			"Frame",
			{
				Parent = esp_holder,
				ZIndex = -1,
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0,
				BorderSizePixel = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
			}
		),
		Healthbar = fishy.functions:create(
			"Frame",
			{
				Parent = esp_holder,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
			}
		),
		HealthbarGradient = fishy.functions:create("UIGradient", { Enabled = true, Rotation = -90 }),

		Box = fishy.functions:create(
			"Frame",
			{ Parent = esp_holder, BackgroundTransparency = 1, BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = -999 }
		),
		Box2 = fishy.functions:create(
			"Frame",
			{ Parent = esp_holder, BackgroundTransparency = 1, BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 999 }
		),
		Outline = fishy.functions:create(
			"UIStroke",
			{
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 3,
				Transparency = 0,
				LineJoinMode = Enum.LineJoinMode.Miter,
				Enabled = true,
			}
		),
		Outline2 = fishy.functions:create(
			"UIStroke",
			{ Thickness = 1, Enabled = true, LineJoinMode = Enum.LineJoinMode.Miter }
		),

		LeftTopFix = fishy.functions:create(
			"Frame",
			{ Parent = esp_holder, Size = UDim2.new(0, 1, 0, 6), ZIndex = 999 }
		),
		RightTopFix = fishy.functions:create(
			"Frame",
			{ Parent = esp_holder, Size = UDim2.new(0, 1, 0, 6), ZIndex = 999 }
		),
		BottomSideFix = fishy.functions:create(
			"Frame",
			{ Parent = esp_holder, Size = UDim2.new(0, 1, 0, 6), ZIndex = 999 }
		),
		BottomRightSideFix = fishy.functions:create(
			"Frame",
			{ Parent = esp_holder, Size = UDim2.new(0, 1, 0, 6), ZIndex = 999 }
		),
		LeftTop = fishy.functions:create("Frame", { Parent = esp_holder, ZIndex = 3 }),
		LeftSide = fishy.functions:create("Frame", { Parent = esp_holder }),
		RightTop = fishy.functions:create("Frame", { Parent = esp_holder, ZIndex = 3 }),
		RightSide = fishy.functions:create("Frame", { Parent = esp_holder }),
		BottomSide = fishy.functions:create("Frame", { Parent = esp_holder }),
		BottomDown = fishy.functions:create("Frame", { Parent = esp_holder }),
		BottomRightSide = fishy.functions:create("Frame", { Parent = esp_holder }),
		BottomRightDown = fishy.functions:create("Frame", { Parent = esp_holder }),
		skeleton = fishy.functions:create("Frame", {
			Parent = esp_holder,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}),
	}

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "head",
		BorderSizePixel = 0,
	})

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "torso1",
		BorderSizePixel = 0,
	})

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "torso2",
		BorderSizePixel = 0,
	})

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "larm1",
		BorderSizePixel = 0,
	})

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "larm2",
		BorderSizePixel = 0,
	})

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "larm3",
		BorderSizePixel = 0,
	})

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "rarm1",
		BorderSizePixel = 0,
	})

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "rarm2",
		BorderSizePixel = 0,
	})

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "rarm3",
		BorderSizePixel = 0,
	})

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "lleg1",
		BorderSizePixel = 0,
	})

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "lleg2",
		BorderSizePixel = 0,
	})

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "lleg3",
		BorderSizePixel = 0,
	})

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "rleg1",
		BorderSizePixel = 0,
	})

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "rleg2",
		BorderSizePixel = 0,
	})

	fishy.functions:create("Frame", {
		Parent = drawings.skeleton,
		Name = "rleg3",
		BorderSizePixel = 0,
	})

	-- parenting
	drawings.HealthbarGradient.Parent = drawings.Healthbar
	drawings.Outline.Parent = drawings.Box
	drawings.Outline2.Parent = drawings.Box2

	local update = function()
		local health_start = 0
		local health_transition_start = 0
		local health_transition_old = 0
		local current_health = 0

		local function hide_esp()
			for _, name in
				{
					"name",
					"distance",
					"weapon",
					"BehindHealthbar",
					"Healthbar",
					"HealthText",
					"Box",
					"Box2",
					"Flag1",
					"Flag2",
					"LeftTopFix",
					"RightTopFix",
					"BottomSideFix",
					"BottomRightSideFix",
					"LeftTop",
					"LeftSide",
					"RightTop",
					"RightSide",
					"BottomSide",
					"BottomDown",
					"BottomRightSide",
					"BottomRightDown",
				}
			do
				drawings[name].Visible = false
			end
		end

		local function clear_esp()
			for _, v in drawings do
				v:Destroy()
			end

			if esp_connection then
				esp_connection:Disconnect()
			end

			esp_holder:Destroy()
		end

		model.Destroying:Connect(clear_esp)

		esp_connection = run_service.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
			local char_model = model and model.Character
			if char_model then
				local root = char_model and char_model:FindFirstChild("HumanoidRootPart")
				local humanoid = char_model and char_model:WaitForChild("Humanoid")
				if humanoid.Health > 0 then
					local _, size, position = fishy.functions:custom_bounds(char_model)
					local max_distance

					local measurement_type = Library.Flags["distance measurement"]:Get()

					if position and typeof(position) == "Vector3" then
						if measurement_type == "studs" then
							max_distance = (camera.CFrame.Position - position).Magnitude
						elseif measurement_type == "meters" then
							max_distance = (camera.CFrame.Position - position).Magnitude / 3.5714285714
						end
					end

					if
						Library.Flags["esp enabled"]:Get()
						and max_distance
						and typeof(max_distance) == "number"
						and char_model
						and root
						and humanoid
					then
						local team_check = Library.Flags["esp team check"]:Get()

						if team_check and is_team(model) then
							return hide_esp()
						end

						local pos, on_screen = camera:WorldToScreenPoint(position)

						if not on_screen then
							return hide_esp()
						end

						local height = math.tan(math.rad(camera.FieldOfView / 2)) * 2 * pos.Z
						local scale =
							Vector2.new((viewport_size.Y / height) * size.X, (viewport_size.Y / height) * size.Y)

						local box_esp = Library.Flags["box esp"]:Get()
						local box_esp_color = Library.Flags["box esp color"]:Get()
						local box_type = Library.Flags["box type"]:Get()

						local name_esp = Library.Flags["name esp"]:Get()
						local name_esp_color = Library.Flags["name esp color"]:Get()

						local distance_esp = Library.Flags["distance esp"]:Get()
						local distance_esp_color = Library.Flags["distance esp color"]:Get()

						local weapon_esp = Library.Flags["weapon esp"]:Get()
						local weapon_esp_color = Library.Flags["weapon esp color"]:Get()

						local health_bar_esp = Library.Flags["health bar"]:Get()
						local health_text_esp = Library.Flags["health text"]:Get()
						local health_bar_thickness = Library.Flags["health bar thickness"]:Get()
						local health_bar_position = Library.Flags["health bar position"]:Get()
						local visible_flag_esp = Library.Flags["visible flag esp"]:Get()

						local highlight_esp = Library.Flags["highlight enabled"]:Get()
						local highlight_esp_color = Library.Flags["highlight color"]:Get()

						local skeleton_esp = Library.Flags["skeleton esp"]:Get()
						local skeleton_esp_color = Library.Flags["skeleton esp color"]:Get()

						if box_esp and box_type == "full" then
							drawings.Box.Size = UDim2.new(0, scale.X - 1, 0, scale.Y - 1)
							drawings.Box2.Size = UDim2.new(0, scale.X + 1, 0, scale.Y + 1)

							drawings.Box.Position = UDim2.new(0, pos.X - (scale.X / 2), 0, pos.Y - (scale.Y / 2))
							drawings.Box2.Position =
								UDim2.new(0, pos.X - (scale.X / 2) - 1, 0, pos.Y - (scale.Y / 2) - 1)

							drawings.Box.Visible = true
							drawings.Box2.Visible = true
							drawings.Outline2.Color = drawings.Outline2.Color:Lerp(
								(
									highlight_esp
									and current_target
									and current_target:IsDescendantOf(char_model)
									and highlight_esp_color
								)
										and highlight_esp_color
									or box_esp_color,
								0.04
							)
						else
							drawings.Box.Visible = false
							drawings.Box2.Visible = false
						end

						if box_esp and box_type == "cornered" then
							local positions = {
								{ "LeftTopFix", pos.X - scale.X / 2, pos.Y - scale.Y / 2, 1, 12 },
								{ "RightTopFix", pos.X + scale.X / 2 - 1, pos.Y - scale.Y / 2, 1, 12 },
								{ "BottomSideFix", pos.X - scale.X / 2, pos.Y + scale.Y / 2 - 6 },
								{ "BottomRightSideFix", pos.X + scale.X / 2 - 1, pos.Y + scale.Y / 2 - 6 },
								{
									"LeftTop",
									pos.X - scale.X / 2,
									pos.Y - scale.Y / 2,
									scale.X / 3,
									1,
									Vector2.new(0, 0),
								},
								{
									"LeftSide",
									pos.X - scale.X / 2,
									pos.Y - scale.Y / 2,
									1,
									scale.Y / 4,
									Vector2.new(0, 0),
								},
								{
									"RightTop",
									pos.X + scale.X / 2,
									pos.Y - scale.Y / 2,
									scale.X / 3,
									1,
									Vector2.new(1, 0),
								},
								{
									"RightSide",
									pos.X + scale.X / 2 - 1,
									pos.Y - scale.Y / 2,
									1,
									scale.Y / 4,
									Vector2.new(0, 0),
								},
								{
									"BottomSide",
									pos.X - scale.X / 2,
									pos.Y + scale.Y / 2,
									1,
									scale.Y / 4,
									Vector2.new(0, 3),
								},
								{
									"BottomDown",
									pos.X - scale.X / 2,
									pos.Y + scale.Y / 2,
									scale.X / 3,
									1,
									Vector2.new(0, 1),
								},
								{
									"BottomRightSide",
									pos.X + scale.X / 2,
									pos.Y + scale.Y / 2,
									1,
									scale.Y / 4,
									Vector2.new(1, 1),
								},
								{
									"BottomRightDown",
									pos.X + scale.X / 2,
									pos.Y + scale.Y / 2,
									scale.X / 3,
									1,
									Vector2.new(1, 1),
								},
							}

							for _, v in positions do
								local name, x_pos, y_pos, width, height, anchor = unpack(v)
								local drawing = drawings[name]

								drawing.Position = UDim2.new(0, x_pos, 0, y_pos)

								if not name:find("Fix") then
									drawing.Size = UDim2.new(0, width, 0, height)
									drawing.AnchorPoint = anchor
									drawing.BorderSizePixel = 1
								else
									drawing.BorderSizePixel = 0
								end

								drawing.Visible = true
								drawing.BackgroundColor3 = drawing.BackgroundColor3:Lerp(
									(
										highlight_esp
										and current_target
										and current_target:IsDescendantOf(char_model)
										and highlight_esp_color
									)
											and highlight_esp_color
										or box_esp_color,
									0.04
								)
							end
						else
							for _, name in
								{
									"LeftTopFix",
									"RightTopFix",
									"BottomSideFix",
									"BottomRightSideFix",
									"LeftTop",
									"LeftSide",
									"BottomSide",
									"BottomDown",
									"RightTop",
									"RightSide",
									"BottomRightSide",
									"BottomRightDown",
								}
							do
								drawings[name].Visible = false
							end
						end

						if name_esp then
							drawings.name.Visible = true
							drawings.name.TextColor3 = drawings.name.TextColor3:Lerp(
								(
									highlight_esp
									and current_target
									and current_target:IsDescendantOf(char_model)
									and highlight_esp_color
								)
										and highlight_esp_color
									or name_esp_color,
								0.04
							)
							drawings.name.Position = UDim2.new(0, pos.X - 2, 0, pos.Y - scale.Y / 2 - 10)
						else
							drawings.name.Visible = false
						end

						if distance_esp then
							drawings.distance.TextColor3 = drawings.distance.TextColor3:Lerp(
								(
									highlight_esp
									and current_target
									and current_target:IsDescendantOf(char_model)
									and highlight_esp_color
								)
										and highlight_esp_color
									or distance_esp_color,
								0.04
							)
							if measurement_type == "studs" then
								drawings.distance.Text = string.format("%ds", math.floor(max_distance))
							elseif measurement_type == "meters" then
								drawings.distance.Text = string.format("%dm", math.floor(max_distance))
							end
							drawings.distance.Visible = true
						else
							drawings.distance.Visible = false
						end

						if weapon_esp then
							drawings.weapon.Visible = true
							drawings.weapon.TextColor3 = drawings.weapon.TextColor3:Lerp(
								(
									highlight_esp
									and current_target
									and current_target:IsDescendantOf(char_model)
									and highlight_esp_color
								)
										and highlight_esp_color
									or weapon_esp_color,
								0.04
							)
							drawings.weapon.Text = fishy.functions:get_tool_name(char_model)
						else
							drawings.weapon.Visible = false
						end

						local bottom_offset = (health_bar_esp and health_bar_position == "bottom") and 7 or 0

						if distance_esp and weapon_esp then
							drawings.distance.Position =
								UDim2.new(0, pos.X, 0, pos.Y + scale.Y / 2 + 17 + bottom_offset)
							drawings.weapon.Position = UDim2.new(0, pos.X, 0, pos.Y + scale.Y / 2 + 6 + bottom_offset)
						elseif distance_esp then
							drawings.distance.Position = UDim2.new(0, pos.X, 0, pos.Y + scale.Y / 2 + 7 + bottom_offset)
						elseif weapon_esp then
							drawings.weapon.Position = UDim2.new(0, pos.X, 0, pos.Y + scale.Y / 2 + 6 + bottom_offset)
						end

						if health_bar_esp then
							local health, max_health = math.floor(humanoid.Health), humanoid.MaxHealth
							local health_color = Color3.new(1, 0, 0)
								:Lerp(Color3.new(0.7, 0.8, 0), math.clamp(health / max_health, 0, 1))
							health_color = health_color:Lerp(
								Color3.new(0, 1, 0),
								math.clamp((health / max_health - 0.5) * 2, 0, 1)
							)
							local health_offset = math.floor((max_health - health) / 10) * 0.1

							do -- healthbar animation
								health_start = health_start or 0
								health_transition_start = health_transition_start or health
								health_transition_old = health_transition_old or health
								current_health = current_health or health

								if health ~= health_transition_start then
									health_transition_old, health_transition_start, health_start =
										current_health, health, tick()
								end
							end

							local progress = math.clamp((tick() - health_start) / 0.2, 0, 1)
							current_health = health_transition_old
								+ (health_transition_start - health_transition_old) * progress

							if progress >= 1 then
								current_health, health_transition_old, health_transition_start, health_start =
									health, health, health, 0
							end

							do -- health text
								if health_text_esp and health < max_health then
									drawings.HealthText.Text, drawings.HealthText.Visible =
										tostring(math.floor(current_health)), true
								else
									drawings.HealthText.Visible = false
								end
								drawings.HealthText.TextColor3 = health_color
							end

							drawings.Healthbar.Visible = true
							drawings.BehindHealthbar.Visible = true

							local bar_offset, bar_width = 0, health_bar_thickness
							local bar_height_adjust = (box_esp == "full") and 3 or 0
							local position_adjust = bar_height_adjust / 2
							local target_height = scale.Y * (current_health / max_health) + bar_height_adjust
							local target_width = scale.X * (current_health / max_health) + bar_height_adjust

							if health_bar_position == "left" then
								bar_offset = 7
								drawings.HealthbarGradient.Rotation = -90
								drawings.Healthbar.Position = UDim2.new(
									0,
									pos.X - scale.X / 2 - bar_offset,
									0,
									pos.Y - scale.Y / 2 - position_adjust + scale.Y * (1 - current_health / max_health)
								)
								drawings.BehindHealthbar.Position = UDim2.new(
									0,
									pos.X - scale.X / 2 - bar_offset,
									0,
									pos.Y - scale.Y / 2 - position_adjust
								)
								drawings.Healthbar.Size = UDim2.new(0, bar_width, 0, target_height)
								drawings.BehindHealthbar.Size = UDim2.new(0, bar_width, 0, scale.Y + bar_height_adjust)
								health_offset = math.clamp(health_offset, 0, 1)
								drawings.HealthbarGradient.Offset = Vector2.new(0, -health_offset)
								local target_text_pos = health_bar_position == "left"
										and UDim2.new(
											0,
											pos.X - scale.X / 2 - 17,
											0,
											pos.Y - scale.Y / 2 + scale.Y * (1 - current_health / max_health)
										)
									or UDim2.new(
										0,
										pos.X - scale.X / 2 + scale.X * (current_health / max_health),
										0,
										pos.Y + scale.Y / 2
									)
								drawings.HealthText.Position =
									drawings.HealthText.Position:Lerp(target_text_pos, progress)
							elseif health_bar_position == "bottom" then
								bar_offset = 4
								local bottom_y = pos.Y + scale.Y / 2 + bar_offset
								drawings.HealthbarGradient.Rotation = 0
								drawings.Healthbar.Position =
									UDim2.new(0, pos.X - scale.X / 2 - position_adjust, 0, bottom_y)
								drawings.BehindHealthbar.Position =
									UDim2.new(0, pos.X - scale.X / 2 - position_adjust, 0, bottom_y)
								drawings.Healthbar.Size = UDim2.new(0, target_width, 0, bar_width)
								drawings.BehindHealthbar.Size = UDim2.new(0, scale.X + bar_height_adjust, 0, bar_width)
								health_offset = math.clamp(health_offset, 0, 1)
								drawings.HealthbarGradient.Offset = Vector2.new(health_offset, 0)
								local target_text_pos = health_bar_position == "left"
										and UDim2.new(
											0,
											pos.X - scale.X / 2 - 17,
											0,
											pos.Y - scale.Y / 2 + scale.Y * (1 - current_health / max_health)
										)
									or UDim2.new(
										0,
										pos.X - scale.X / 2 + scale.X * (current_health / max_health),
										0,
										pos.Y + scale.Y / 2 + 5
									)
								drawings.HealthText.Position =
									drawings.HealthText.Position:Lerp(target_text_pos, progress)
							end

							drawings.HealthbarGradient.Color = ColorSequence.new(health_color)
						else
							drawings.Healthbar.Visible, drawings.HealthText.Visible, drawings.BehindHealthbar.Visible =
								false, false, false
						end

						if visible_flag_esp then
							drawings.Flag1.Visible = true
							drawings.Flag2.Visible = true

							if fishy.functions:is_visible(char_model) then
								drawings.Flag1.Visible = true
								drawings.Flag1.Text = "Vis"
							else
								drawings.Flag1.Text = ""
								drawings.Flag1.Visible = false
							end

							local box_side = pos.X + (scale.X / 2)
							local box_top = pos.Y - (scale.Y / 2)

							if box_type == "cornered" then
								drawings.Flag1.Position = UDim2.new(0, box_side + 4, 0, box_top + 2)
								drawings.Flag2.Position =
									UDim2.new(0, box_side + 4, 0, box_top + 2 + drawings.Flag1.TextBounds.Y)
							elseif box_type == "full" then
								drawings.Flag1.Position = UDim2.new(0, box_side + 4, 0, box_top)
								drawings.Flag2.Position =
									UDim2.new(0, box_side + 4, 0, box_top + drawings.Flag1.TextBounds.Y)
							end

							drawings.Flag1.Position = drawings.Flag1.Position
								+ UDim2.new(0, drawings.Flag1.TextBounds.X, 0, 0)
							drawings.Flag2.Position = drawings.Flag2.Position
								+ UDim2.new(0, drawings.Flag2.TextBounds.X, 0, 0)
						else
							drawings.Flag1.Visible = false
							drawings.Flag2.Visible = false
						end

						for _, body_part in part_points do
							if type(body_part) == "table" then
								for _, point in body_part do
									if not char_model:FindFirstChild(point) then
										return
									end
								end
							end
							if type(body_part) == "string" then
								if not char_model:FindFirstChild(body_part) then
									return
								end
							end
						end
						local points = {
							torso = {
								vector3_to_vector2(
									camera:WorldToScreenPoint(char_model[part_points.torso[1]].Position)
								),
								vector3_to_vector2(
									camera:WorldToScreenPoint(char_model[part_points.torso[2]].Position)
								),
							},
							larm = {
								vector3_to_vector2(camera:WorldToScreenPoint(char_model[part_points.larm[1]].Position)),
								vector3_to_vector2(camera:WorldToScreenPoint(char_model[part_points.larm[2]].Position)),
								vector3_to_vector2(camera:WorldToScreenPoint(char_model[part_points.larm[3]].Position)),
							},
							rarm = {
								vector3_to_vector2(camera:WorldToScreenPoint(char_model[part_points.rarm[1]].Position)),
								vector3_to_vector2(camera:WorldToScreenPoint(char_model[part_points.rarm[2]].Position)),
								vector3_to_vector2(camera:WorldToScreenPoint(char_model[part_points.rarm[3]].Position)),
							},
							lleg = {
								vector3_to_vector2(camera:WorldToScreenPoint(char_model[part_points.lleg[1]].Position)),
								vector3_to_vector2(camera:WorldToScreenPoint(char_model[part_points.lleg[2]].Position)),
								vector3_to_vector2(camera:WorldToScreenPoint(char_model[part_points.lleg[3]].Position)),
							},
							rleg = {
								vector3_to_vector2(camera:WorldToScreenPoint(char_model[part_points.rleg[1]].Position)),
								vector3_to_vector2(camera:WorldToScreenPoint(char_model[part_points.rleg[2]].Position)),
								vector3_to_vector2(camera:WorldToScreenPoint(char_model[part_points.rleg[3]].Position)),
							},
							head = vector3_to_vector2(camera:WorldToScreenPoint(char_model[part_points.head].Position)),
						}

						if points and skeleton_esp then
							drawings.skeleton.Visible = true

							for _, bone in drawings.skeleton:GetChildren() do
								bone.BackgroundColor3 = skeleton_esp_color
							end

							draw_line(drawings.skeleton.head, points.head, points.torso[1])
							draw_line(drawings.skeleton.torso1, points.torso[1], points.torso[2])

							draw_line(drawings.skeleton.larm1, points.torso[1], points.larm[1])
							draw_line(drawings.skeleton.larm2, points.larm[1], points.larm[2])
							draw_line(drawings.skeleton.larm3, points.larm[2], points.larm[3])

							draw_line(drawings.skeleton.rarm1, points.torso[1], points.rarm[1])
							draw_line(drawings.skeleton.rarm2, points.rarm[1], points.rarm[2])
							draw_line(drawings.skeleton.rarm3, points.rarm[2], points.rarm[3])

							draw_line(drawings.skeleton.lleg1, points.torso[2], points.lleg[1])
							draw_line(drawings.skeleton.lleg2, points.lleg[1], points.lleg[2])
							draw_line(drawings.skeleton.lleg3, points.lleg[2], points.lleg[3])

							draw_line(drawings.skeleton.rleg1, points.torso[2], points.rleg[1])
							draw_line(drawings.skeleton.rleg2, points.rleg[1], points.rleg[2])
							draw_line(drawings.skeleton.rleg3, points.rleg[2], points.rleg[3])
						else
							drawings.skeleton.Visible = false
						end
					else
						hide_esp()
					end
				else
					hide_esp()
				end
			else
				hide_esp()
			end
		end))
	end
	coroutine.wrap(update)()
end
do -- Update ESP
	for _, player in players:GetPlayers() do
		if player ~= local_player then
			coroutine.wrap(ESP)(player)
		end
	end
	--
	players.PlayerAdded:Connect(function(v)
		task.delay(1, function()
			coroutine.wrap(ESP)(v)
		end)
	end)
end

local quick_stack_funcs = setmetatable({}, {
	__mode = "v",
})

local scan_gc = function()
	local stuff = getgc(false)

	for _, v in getreg() do
		if type(v) == "function" then
			table.insert(stuff, v)
		end
	end

	for _, func in stuff do
		if type(func) ~= "function" or isexecutorclosure(func) or iscclosure(func) or isfunctionhooked(func) then
			continue
		end

		local info = debug.getinfo(func)

		local func_name = info.name

		if func_name == "PlayAnimation" then
			print(func_name)
			local old_play_animation
			old_play_animation = hookfunction(
				func,
				LPH_NO_UPVALUES(function(animation_name, ...)
					local output = { old_play_animation(animation_name, ...) }

					if (animation_name == "Bolt") and Library.Flags["instant bolt"]:Get() then
						return {
							Length = 0.015,
						}
					end

					return unpack(output)
				end)
			)
			continue
		end
		if func_name == "QuickStackItem" then
			print(func_name)
			table.insert(quick_stack_funcs, func)
			continue
		end

		if func_name == "CameraShake" then
			print(func_name)
			local old_camera_shake_func
			old_camera_shake_func = hookfunction(
				func,
				LPH_NO_UPVALUES(function(...)
					if Library.Flags["no camera shake"]:Get() then
						return
					end

					return old_camera_shake_func(...)
				end)
			)
		end
		if func_name == "LocalHitFunction" then
			print(func_name)
			local old_local_hit_function
			old_local_hit_function = hookfunction(
				func,
				LPH_NO_UPVALUES(function(hit_data, ...)
					if hit_data and type(hit_data) == "table" then
						local hit_part = hit_data[1]
						local hit_pos = hit_data[2]

						if hit_part and typeof(hit_part) == "Instance" and hit_pos and typeof(hit_pos) == "Vector3" then
							local model = hit_part.Parent

							if model then
								local head = model:FindFirstChild("Head")

								if head then
									if Library.Flags["always headshot"]:Get() then
										hit_data[1] = hit_data[1].Parent:FindFirstChild("Head")
										hit_data[2] = hit_data[1]:GetClosestPointOnSurface(camera.CFrame.Position)
									end

									if Library.Flags["bullet tracers"]:Get() and not hit_data[8] then
										local bs = draw_line_2(
											camera.CFrame * CFrame.new(0, 0, -5),
											CFrame.new(hit_data[2]),
											Library.Flags["bullet tracers color"]:Get()
										)
										task.delay(Library.Flags["bullet tracers lifetime"]:Get(), bs)
									end
								end
							end
						end
					end

					return old_local_hit_function(hit_data, ...)
				end)
			)
		end
	end
end

settings_section:Button({
	Name = "rescan game",
	Flag = "rescan game",
	Callback = scan_gc,
})

local check_child = function(child: Instance)
	if not child:IsA("LocalScript") then
		return
	end

	if child.Name == "InventoryController" then
		local initated = child:GetAttribute("Initiated")

		if not initated then
			child:GetAttributeChangedSignal("Initiated"):Wait()
		end

		task.delay(1, scan_gc)
	end
	if child.Name == "ViewmodelController" then
		local connection
		connection = run_service.RenderStepped:Connect(function()
			if not child then
				return connection:Disconnect()
			end

			if Library.Flags["sprint while attacking"]:Get() then
				child:SetAttribute("CanUse", true)
			end
		end)
	end
end

local_player.CharacterAdded:Connect(function(character)
	for _, child in character:GetChildren() do
		check_child(child)
	end
	character.ChildAdded:Connect(check_child)
end)

task.spawn(function()
	local character = local_player.Character
	if character then
		for _, child in character:GetChildren() do
			check_child(child)
		end
	end
end)

local old_toggle_footstep = sound_table.ToggleFootstep
sound_table.ToggleFootstep = function(_, character, sound, playback_speed)
	if Library.Flags["silent walk"]:Get() and sound then
		return sound_table:StopSound(sound)
	end
	return old_toggle_footstep(_, character, sound, playback_speed)
end

local old_play_sound = sound_table.PlaySound
sound_table.PlaySound = function(_, sound, is_duplicate, playback_speed)
	if sound and sound.Name == "WalkWater" and Library.Flags["silent walk"]:Get() then
		return sound_table:StopSound(sound)
	end

	return old_play_sound(_, sound, is_duplicate, playback_speed)
end

user_input_service.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		mouse_location = user_input_service:GetMouseLocation()
	end
end)

-- game shituals

local metatable = {}
metatable.__index = metatable

function metatable:set_text(new_text)
	if not self then
		return
	end

	local text_label = self.Text

	if not text_label then
		return
	end

	self.current_text = new_text
	text_label.Text = new_text
end

function metatable:die()
	if not self then
		return
	end

	local connections = self.connections
	local text_label = self.Text
	local billboard = self.Billboard

	if connections then
		for _, connection in connections do
			connection:Disconnect()
		end
	end

	if text_label then
		text_label:Destroy()
	end

	if billboard then
		billboard:Destroy()
	end

	table.clear(self)
	self = nil
end

function metatable:add_connection(event)
	if not (self and self.connections and event) then
		return
	end

	table.insert(self.connections, event)
end

local add_instance = function(object, data)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = object.Name
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(300, 100)
	billboard.Adornee = object

	billboard.Parent = core_gui

	local text = Instance.new("TextLabel")

	text.Size = UDim2.fromScale(1, 1)

	-- sigma
	text.TextTruncate = Enum.TextTruncate.None
	text.TextWrapped = false
	text.BackgroundTransparency = 1
	text.TextTransparency = 0
	text.TextSize = 9
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeColor3 = Color3.new(0, 0, 0)
	text.TextStrokeTransparency = 0.8
	--Font.fromId(12187371840)
	text.FontFace = fishy.fonts.options.ProggyTiny
	text.Parent = billboard

	local draw = setmetatable({
		Text = text,
		Billboard = billboard,
		Model = object,
		enabled = true,
		connections = {},
		current_text = "",
	}, metatable)

	for index, value in data do
		if index == "Text" then
			draw:set_text(value)
			continue
		end
		text[index] = value
	end

	draw:add_connection(object.Destroying:Connect(function() -- silly syntax
		draw:die()
	end))

	return draw
end

local types = {
	nodes = "nodes",
	drops = "drops",
	plants = "plants",
	soldiers = "soldiers",
	animals = "animals",
	body_bags = "body bag",
	crates = "crates",
	timed_crate = "timed crate",
	btr = "btr",
}

local objects_cache = {}
local drawing_objects = {}

for _, value in types do
	objects_cache[value] = {}
	drawing_objects[value] = {}
end

local draw_instance = function(esp_type, obj, data)
	local drawing_objects_table = drawing_objects[esp_type]

	assert(drawing_objects_table, string.format("no type called %s", esp_type))
	local drawing = add_instance(obj, data)

	if not drawing_objects_table[obj] then
		drawing_objects_table[obj] = drawing
	else
		task.defer(drawing.die, drawing)
	end

	function drawing:real_die()
		drawing_objects_table[obj] = nil
		return drawing:die()
	end

	return drawing
end

local add_cache = function(esp_type, obj)
	local objects_cache_tbl = objects_cache[esp_type]

	assert(objects_cache_tbl, string.format("no type called %s", esp_type))

	-- duplicate check
	if table.find(objects_cache_tbl, obj) then
		return
	end

	table.insert(objects_cache_tbl, obj)
end

local node_esp = function(obj)
	local value = Library.Flags["nodes esp"]:Get()
	local color = Library.Flags["nodes esp color"]:Get()

	if value then
		draw_instance(types.nodes, obj, {
			Text = string.gsub(obj.Name, "_Node$", ""),
			TextColor3 = color,
		})
	else
		add_cache(types.nodes, obj)
	end
end

local read_json = function(input) -- i dont trust fallen survival
	local s, output = xpcall(http_service.JSONDecode, print, http_service, input)

	if s then
		return output
	else
		return false
	end
end

local drops_esp = function(obj)
	local value = Library.Flags["drops esp"]:Get()
	local color = Library.Flags["drops esp color"]:Get()

	local item = obj:FindFirstChild("Item")

	if value then
		if item and item:IsA("StringValue") then
			local drawing = draw_instance(types.drops, obj, {
				TextColor3 = color,
			})

			local function update_text()
				local data = read_json(item.Value)

				if data and data.Amount > 1 then
					drawing:set_text(string.format("%s (x%s)", obj.Name, data.Amount))
				else
					drawing:set_text(obj.Name)
				end
			end

			update_text()
			item.Changed:Connect(update_text)
		end
	else
		add_cache(types.drops, obj)
	end
end

local plant_esp = function(obj)
	local value = Library.Flags["plants esp"]:Get()
	local color = Library.Flags["plants esp color"]:Get()

	if value then
		draw_instance(types.plants, obj, {
			Text = string.gsub(obj.Name, " Plant", ""),
			TextColor3 = color,
		})
	else
		add_cache(types.plants, obj)
	end
end

local military_esp = function(obj)
	if not obj:IsA("Model") or obj.Name == "Contents" then
		return
	end

	local value = Library.Flags["soldiers esp"]:Get()
	local color = Library.Flags["soldiers esp color"]:Get()

	if value then
		local drawing = draw_instance(types.soldiers, obj, {
			Text = obj.Name,
			TextColor3 = color,
		})

		drawing:add_connection(obj:GetPropertyChangedSignal("Name"):Connect(function()
			if obj.Name == "Contents" then
				drawing:real_die()
			end
		end))
	else
		add_cache(types.soldiers, obj)
	end
end

local body_bag_esp = function(obj)
	local value = Library.Flags["body bag esp"]:Get()
	local color = Library.Flags["body bag esp color"]:Get()

	if value then
		draw_instance(types.body_bags, obj, {
			Text = string.format("%s\n(%s)", obj.Name, obj:GetAttribute("OwnerName")),
			TextColor3 = color,
		})
	else
		add_cache(types.body_bags, obj)
	end
end

local get_bench_health = function(obj)
	if obj then
		return obj:GetAttribute("Health"), obj:GetAttribute("MaxHealth"), obj:GetAttribute("DesiredHealth")
	end

	return math.huge, math.huge, nil
end

local crate_esp = function(obj)
	local value = Library.Flags["crates esp"]:Get()
	local color = Library.Flags["crates esp color"]:Get()

	if value then
		local current_health, max_health, desired_health = get_bench_health(obj)
		local drawing = draw_instance(types.crates, obj, {
			Text = string.format("%s\n(%s / %s)", obj.Name, current_health, max_health),
			TextColor3 = color,
			Visible = tonumber(desired_health) == nil,
		})

		if current_health <= 0 then
			drawing:set_text(obj.Name)
		end

		drawing:add_connection(obj:GetAttributeChangedSignal("DesiredHealth"):Connect(function()
			current_health, max_health, desired_health = get_bench_health(obj)
			drawing.Text.Visible = tonumber(desired_health) == nil
		end))

		drawing:add_connection(obj:GetAttributeChangedSignal("Health"):Connect(function()
			current_health, max_health, desired_health = get_bench_health(obj)

			if current_health > 0 then
				drawing:set_text(string.format("%s\n(%s / %s)", obj.Name, current_health, max_health))
			else
				drawing:set_text(obj.Name)
			end
		end))
	else
		add_cache(types.crates, obj)
	end
end

local timed_crate_esp = function(obj)
	local timer_label: TextLabel = obj:FindFirstChild("TextLabel", true)

	if not timer_label then
		return
	end

	local value = Library.Flags["timed crate esp"]:Get()
	local color = Library.Flags["timed crate esp color"]:Get()

	if value then
		local drawing = draw_instance(types.timed_crate, obj, {
			Text = string.format("%s\n(%s)", obj.Name, timer_label.Text),
			TextColor3 = color,
		})

		drawing:add_connection(timer_label:GetPropertyChangedSignal("Text"):Connect(function()
			drawing:set_text(string.format("%s\n(%s)", obj.Name, timer_label.Text))
		end))
	else
		add_cache(types.timed_crate, obj)
	end
end

local btr_esp = function(obj: Model)
	local value = Library.Flags["btr esp"]:Get()
	local color = Library.Flags["btr esp color"]:Get()

	local root_part = obj:FindFirstChild("HumanoidRootPart")

	if value and root_part then
		local health, max_health = get_bench_health(obj)

		local drawing = draw_instance(types.btr, root_part, {
			Text = string.format("%s\n(%sHP / %sHP)", obj.Name, health, max_health),
			TextColor3 = color,
		})

		drawing:add_connection(obj.AttributeChanged:Connect(function()
			health, max_health = get_bench_health(obj)
			drawing:set_text(string.format("%s\n(%sHP / %sHP)", obj.Name, health, max_health))
		end))
	else
		add_cache(types.btr, obj)
	end
end

local objects_functions = {
	["Body Bag"] = body_bag_esp,
	-- crates
	["Locked Wooden Crate"] = crate_esp,
	["Locked Metal Crate"] = crate_esp,
	["Locked Steel Crate"] = crate_esp,
	["Wooden Crate"] = crate_esp,
	["Food Crate"] = crate_esp,
	["Timed Crate"] = timed_crate_esp,
}

local object_handler = function(obj)
	if not obj:IsA("Model") then
		return
	end

	local esp_function = objects_functions[obj.Name]

	if esp_function then
		esp_function(obj)
	end
end

local animal_esp = function(obj)
	local value = Library.Flags["animals esp"]:Get()
	local color = Library.Flags["animals esp color"]:Get()

	if value then
		local drawing = draw_instance(types.animals, obj, {
			Visible = obj.PrimaryPart ~= nil,
			Text = string.gsub(obj.Name, "PREFAB_ANIMAL_", ""):lower():gsub("^%l", function(char)
				return string.upper(char)
			end),
			TextColor3 = color,
		})
		drawing:add_connection(obj:GetPropertyChangedSignal("PrimaryPart"):Connect(function()
			drawing.Text.Visible = obj.PrimaryPart ~= nil
		end))
	else
		add_cache(types.animals, obj)
	end
end

local handle_cache = function(value, esp_function, esp_type)
	local objects_cache_tbl = objects_cache[esp_type]
	local drawing_objects_tbl = drawing_objects[esp_type]

	assert(objects_cache_tbl, string.format("no cache called %s", esp_type))
	assert(drawing_objects_tbl, string.format("no drawing objects called %s", esp_type))

	if value then
		for _, obj in objects_cache_tbl do
			esp_function(obj)
		end
		table.clear(objects_cache_tbl)
	else
		for model, drawing in drawing_objects_tbl do
			if model then
				add_cache(esp_type, model)
			end
			if drawing and drawing.die then
				drawing:die()
			end
		end
		table.clear(drawing_objects_tbl)
	end
end

local cache_functions = {
	[types.nodes] = node_esp,
	[types.drops] = drops_esp,
	[types.plants] = plant_esp,
	[types.soldiers] = military_esp,
	[types.animals] = animal_esp,
	[types.btr] = btr_esp,
	-- bases object
	[types.body_bags] = object_handler,
	[types.crates] = object_handler,
	[types.timed_crate] = object_handler,
}

local update_cache = function() -- this handles the turning off / on
	for type_name, type_func in cache_functions do
		local flag_name = string.format("%s esp", type_name)
		local flag_value = Library.Flags[flag_name]
		assert(flag_value, string.format("no flag called %s", flag_name))

		handle_cache(flag_value:Get(), type_func, type_name)
	end
end

local handle_color = function(value, esp_type)
	local drawing_objects_tbl = drawing_objects[esp_type]

	assert(drawing_objects_tbl, string.format("no drawing objects called %s", esp_type))

	for _, drawing in drawing_objects_tbl do
		local text_label = drawing.Text

		if text_label then
			text_label.TextColor3 = value
		end
	end
end

local update_color = function()
	for _, type_name in types do
		handle_color(Library.Flags[string.format("%s esp color", type_name)]:Get(), type_name)
	end
end

bindable_event.Event:Connect(function(color_flag)
	if color_flag then
		update_color()
	else
		update_cache()
	end
end)

for _, drop in drops:GetChildren() do
	drops_esp(drop)
end
drops.ChildAdded:Connect(drops_esp)

for _, node in nodes:GetChildren() do
	node_esp(node)
end

nodes.ChildAdded:Connect(node_esp)

for _, plant in plants:GetChildren() do
	plant_esp(plant)
end
plants.ChildAdded:Connect(plant_esp)

for _, animal in animals:GetChildren() do
	animal_esp(animal)
end
animals.ChildAdded:Connect(animal_esp)

for _, btr in events:GetChildren() do
	btr_esp(btr)
end

events.ChildAdded:Connect(btr_esp)

for _, soldiers_location in military:GetChildren() do
	for _, soldier in soldiers_location:GetChildren() do
		military_esp(soldier)
	end
	soldiers_location.ChildAdded:Connect(military_esp)
end

local base_folder_handler = function(objects_folder)
	for _, object in objects_folder:GetChildren() do
		object_handler(object)
	end
	objects_folder.ChildAdded:Connect(object_handler)
end

for _, base_folder in bases:GetChildren() do
	for _, objects_folder in base_folder:GetChildren() do
		base_folder_handler(objects_folder)
	end

	base_folder.ChildAdded:Connect(base_folder_handler)
end

-- local chams
local old_materials = {}
local old_colors = {}

local revert = function()
	for child, material in old_materials do
		child.Material = material
	end

	for child, color in old_colors do
		child.Color = color
	end

	table.clear(old_materials)
	table.clear(old_colors)
end

local chams
chams = function(folder)
	for _, child in folder:GetChildren() do
		if child:IsA("BasePart") then
			old_materials[child] = child.Material
			old_colors[child] = child.Color

			if Library.Flags["local chams color enabled"]:Get() then
				child.Color = Library.Flags["local chams color"]:Get()
			end

			if Library.Flags["local chams material enabled"]:Get() then
				child.Material = Enum.Material[Library.Flags["local chams material"]:Get()]
			end
		end

		if child:IsA("Model") then
			chams(child)
		end

		if child.Name == "Attachments" then
			chams(child)
			child.ChildAdded:Connect(function()
				chams(child)
			end)
		end
	end
end

local chams_handler = function(model)
	revert()
	for _, folder in model:GetChildren() do
		if folder.Name == "Weapon" or folder.Name == "Arms" then
			chams(folder)
			folder.ChildAdded:Connect(function()
				chams(folder)
			end)
		end
	end
end

vm_folder.ChildAdded:Connect(function(model)
	model.ChildAdded:Connect(function()
		chams_handler(model)
	end)
	chams_handler(model)
end)

-- combine two methods into a sigma silent aim realreal

local old_raycast = raycast_table.Raycast
raycast_table.Raycast = function(...)
	local traceback = debug.traceback()

	if traceback:find("MouseRaycast") and current_target then
		print("found heh..")
		return current_target, current_target.Position, Vector3.new(0, 0, 1), current_target.Material
	end

	return old_raycast(...)
end

local old_create_projectile = vfx_table.CreateProjectile
vfx_table.CreateProjectile = LPH_NO_UPVALUES(function(self, data, ...)
	local traceback = debug.traceback()

	if
		current_target
		and data
		and type(data) == "table"
		and Library.Flags["silent aim"]:Get()
		and data.HitFunction
		and traceback:find("ViewmodelController")
	then
		local silly = CFrame.lookAt(data.Position, current_target.Position).LookVector

		data.DirectionFirst = silly
		data.Direction = silly
	end

	return old_create_projectile(self, data, ...)
end)

local old_raycast_util_raycast = raycast_table.Raycast
raycast_table.Raycast = function(
	self,
	origin,
	direction,
	filter_type,
	ignore_list,
	debug_ray,
	filter_function,
	ignore_water,
	depth
)
	local traceback = debug.traceback()
	local is_viewmodel_controller = traceback:find("ViewmodelController")

	local output = {
		old_raycast_util_raycast(
			self,
			origin,
			direction,
			filter_type,
			ignore_list,
			debug_ray,
			filter_function,
			ignore_water,
			depth
		),
	}

	local hit_instance: Instance = output[1]
	local hit_pos: Vector3 = output[2]

	if not hit_instance or typeof(hit_instance) ~= "Instance" then
		return unpack(output)
	end

	if not hit_pos or typeof(hit_pos) ~= "Vector3" then
		return unpack(output)
	end

	local model = hit_instance.Parent

	if not model or (not model:IsA("Model")) then
		return unpack(output)
	end

	local folder = model.Parent

	if
		folder
		and (folder.Name == "Trees" or folder.Name == "Nodes")
		and folder:IsA("Folder")
		and Library.Flags["always perfect farm"]:Get()
	then
		local perfect = model:FindFirstChild("NodeSpark") or model:FindFirstChild("TreeX") or "ham / yuiz_"
		if perfect and typeof(perfect) == "Instance" and perfect:IsA("Model") and perfect.PrimaryPart then
			output[1] = perfect.PrimaryPart
		end
	end

	local head: BasePart = model:FindFirstChild("Head")

	if head and is_viewmodel_controller then
		if Library.Flags["melee tracers"]:Get() then
			local bs = draw_line_2(
				camera.CFrame * CFrame.new(0, 0, -5),
				CFrame.new(hit_pos),
				Library.Flags["melee tracers color"]:Get()
			)
			task.delay(Library.Flags["melee tracers lifetime"]:Get(), bs)
		end
	end

	return unpack(output)
end
local old_get_setting = settings_table.GetSetting
settings_table.GetSetting = function(category, setting, ...)
	if setting == "Field Of View" then
		local zoom_toggle = Library.Flags["zoom"]:Get()
		local zoom_keybind = Library.Flags["zoom key bind"]:Get()

		if Library.Flags["fov changer"]:Get() and not (zoom_toggle and zoom_keybind) then
			return Library.Flags["camera fov"]:Get()
		elseif zoom_toggle and zoom_keybind then
			return Library.Flags["zoom fov"]:Get()
		end
	end

	return old_get_setting(category, setting, ...)
end

run_service.RenderStepped:Connect(function()
	do
		local fov_circle_size = Library.Flags["fov circle size"]:Get()

		local head, pos = get_target(fov_circle_size)
		current_target = head
		if pos then
			local head_vec = Vector2.new(pos.X, pos.Y)

			dot.Visible = Library.Flags["prediction dot"]:Get()
			snapline.Visible = Library.Flags["snapline"]:Get()
			snapline.From = mouse_location
			snapline.To = head_vec
			dot.Position = head_vec
		else
			dot.Visible = false
			snapline.Visible = false
		end
		snapline.Color = Library.Flags["snapline color"]:Get()
		dot.Color = Library.Flags["prediction dot color"]:Get()

		circle.Radius = fov_circle_size
		circle.Color = Library.Flags["fov circle color"]:Get()
		circle.Visible = Library.Flags["fov circle"]:Get()
		circle.Position = mouse_location
	end
	-- other stuff
	do
		local character = local_player.Character

		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			local root = character:FindFirstChild("HumanoidRootPart")

			if humanoid and Library.Flags["speed enabled"]:Get() and root and Library.Flags["speed key bind"]:Get() then
				local dir, vel = humanoid.MoveDirection.Unit, root.Velocity
				local spd = Library.Flags["speed"]:Get()

				if dir.Magnitude > 0 then
					root.Velocity = Vector3.new(dir.X * spd, vel.Y, dir.Z * spd)
				end
			end

			if current_target and Library.Flags["silent aim"]:Get() then
				local character_pos = character:GetPivot().Position
				local hawk = cframe_look_at(character_pos, current_target.Position)
				local _, y, z = hawk:ToOrientation()

				character:PivotTo(CFrame.new(character_pos) * CFrame.fromOrientation(0, y, z))
			end

			if Library.Flags["spiderman"]:Get() and Library.Flags["spiderman key bind"]:Get() then
				if root then
					root.Velocity = Vector3.new(root.Velocity.X, 18, root.Velocity.Z)
				end
				task.wait()
			end
		end

		if quick_stack_funcs and #quick_stack_funcs > 0 then
			for _, func in quick_stack_funcs do
				local instant_loot = Library.Flags["instant loot"]:Get()

				debug.setconstant(func, 18, instant_loot and 0 or 0.3)
				debug.setconstant(func, 19, instant_loot and 0 or 0.1)
			end
		end

		if Library.Flags["no fog"]:Get() then
			local atmosphere = lighting:FindFirstChild("Atmosphere")

			if atmosphere then
				atmosphere.Density = 0
			end
		end

		if Library.Flags["ambient"]:Get() then
			local ambient_color = Library.Flags["ambient color"]:Get()
			lighting.Ambient = ambient_color
		end

		if Library.Flags["fullbright"]:Get() then
			lighting.ClockTime = 12
		end
	end

	watermark:SetText(
		string.format("  fishy | ingame time: %s | %s", lighting:GetAttribute("Stage"), os.date("%a %b %d"))
	)
end)

Library:Notify(string.format("[ 🐟 ] loaded in %.1f", tick() - start_tick), 3, Library.Accent)