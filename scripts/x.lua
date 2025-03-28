repeat
	task.wait()
until game:IsLoaded()

local clone_reference = cloneref or function(...) return ... end

local players = clone_reference(game:GetService("Players"))
local user_input_service = clone_reference(game:GetService("UserInputService"))
local run_service = clone_reference(game:GetService("RunService"))
local http_service = clone_reference(game:GetService("HttpService"))

local local_player = players.LocalPlayer
local drawings = { ["esp"] = {} }
local size = Vector2.new(5, 8)

local configs = {
	["fov"] = {
	  ["eneble"] = true,
	  ["radius"] = 100,
	  ["color"] = Color3.new(1, 1, 1),
	  ["thickness"] = 1
	},
	["crosshair"] = {
	  ["size"] = 5,
	  ["color"] = Color3.new(0.270588, 1, 0.270588),
	  ["thickness"] = 2
	},
	["esp"] = {
	  ["box"] = {
		["eneble"] = true,
		["color"] = Color3.new(1, 1, 1),
		["thickness"] = 1
	  },
	  ["name"] = {
		["eneble"] = true,
		["color"] = Color3.new(1, 1, 1)
	  },
	  ["distance"] = {
		["eneble"] = true,
		["color"] = Color3.new(1, 1, 1)
	  },
	  ["healthBar"] = {
		["eneble"] = true,
		["color"] = Color3.new(0, 1, 0),
		["thickness"] = 1
	  },
	  ["maxDistance"] = 50000,
	  ["team_check"] = true,
	  ["down_check"] = true,
	  ["dead_dead"] = true
	},
	["aimbot"] = {
	  ["enable"] = true,
	  ["target_npcs"] = true,
	  ["part"] = "UpperTorso",
	  ["team_check"] = false,
	  ["down_check"] = true,
	  ["dead_dead"] = true,
	  ["smoothness"] = 2
	},
	["snapline"] = {
	  ["enable"] = true,
	  ["color"] = Color3.new(1, 1, 1),
	  ["thickness"] = 1
	}
}

local events = {}

local camera = workspace.CurrentCamera
local mouse_location = user_input_service:GetMouseLocation()

local hash = http_service:GenerateGUID(true)
getgenv().hash = hash

local readConfig = function()
   	pcall(function()
        while hash == getgenv().hash do
            if isfile("configs.lua") then
                -- Safely load the Lua config file
                local success, configData = pcall(readfile, "configs.lua")
                if success then
                    configs = loadstring(configData)()
                end
            end

            wait(0)
        end
    end)
end


-- task.spawn(function()
-- 	readConfig()
-- end)

-- task.wait(1)

table.insert(events, user_input_service.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		mouse_location = user_input_service:GetMouseLocation()
	end
end))

local aiming = false

table.insert(events, user_input_service.InputBegan:Connect(function(input, gameProcessedEvent)
    if (gameProcessedEvent) then return end

    if (input.UserInputType == Enum.UserInputType.MouseButton2) then
        aiming = true
    end
end))

table.insert(events, user_input_service.InputEnded:Connect(function(input, gameProcessedEvent)
    if (gameProcessedEvent) then return end

    if (input.UserInputType == Enum.UserInputType.MouseButton2) then
        aiming = false
		-- current_target = nil
    end
end))

local fov = Drawing.new("Circle")
fov.Visible = false
fov.Visible = configs["fov"]["eneble"]
fov.Color = configs["fov"]["color"]
fov.Position = mouse_location
fov.Radius = configs["fov"]["radius"]
fov.Thickness = configs["fov"]["thickness"]
	
table.insert(events, fov)

local snapline = Drawing.new("Line")
snapline.Thickness = configs["snapline"]["thickness"]
snapline.Color = configs["snapline"]["color"]
snapline.Visible = false
snapline.From = mouse_location
table.insert(events, snapline)

local prediction_dot = Drawing.new("Circle")
prediction_dot.Radius = 3
prediction_dot.Color = Color3.new(1,0,0)
prediction_dot.Filled = true
prediction_dot.Visible = false
prediction_dot.Transparency = 0.5
table.insert(events, prediction_dot)


local crosshair_size = configs["crosshair"]["size"] or 5
local crosshair_color = configs["crosshair"]["color"] or Color3.new(1, 0, 0)
local crosshair_thickness = configs["crosshair"]["thickness"] or 2

local crosshair_vertical = Drawing.new("Line")
crosshair_vertical.Thickness = crosshair_thickness
crosshair_vertical.Color = crosshair_color
crosshair_vertical.Visible = true
table.insert(events,crosshair_vertical)


local crosshair_horizontal = Drawing.new("Line")
crosshair_horizontal.Thickness = crosshair_thickness
crosshair_horizontal.Color = crosshair_color
crosshair_horizontal.Visible = true
table.insert(events,crosshair_horizontal)


local ESP = function (model)
	local char_model = model.Character
	
	if char_model then
		local box = {
			line_top = Drawing.new("Line"),
			line_right = Drawing.new("Line"),
			line_bottom = Drawing.new("Line"),
			line_left = Drawing.new("Line")
		}

		for _,line in pairs(box) do
			line.Visible = configs["esp"]["box"]["eneble"]
			line.Color = configs["esp"]["box"]["color"]
			line.Thickness = configs["esp"]["box"]["thickness"]
			table.insert(events, line)
		end

		---
		-- local skeleton = {
		-- 	head = Drawing.new("Line"),

		-- 	torso = Drawing.new("Line"),

		-- 	larm1 = Drawing.new("Line"),
		-- 	larm2 = Drawing.new("Line"),
		-- 	larm3 = Drawing.new("Line"),

		-- 	rarm1 = Drawing.new("Line"),
		-- 	rarm2 = Drawing.new("Line"),
		-- 	rarm3 = Drawing.new("Line"),

		-- 	lleg1 = Drawing.new("Line"),
		-- 	lleg2 = Drawing.new("Line"),
		-- 	lleg3 = Drawing.new("Line"),

		-- 	rleg1 = Drawing.new("Line"),
		-- 	rleg2 = Drawing.new("Line"),
		-- 	rleg3 = Drawing.new("Line"),
		-- }

		-- for _,line in pairs(skeleton) do
		-- 	table.insert(events,line)
		-- end

		-----------------------------------------
		local text = {
			nameTag = Drawing.new("Text"),
			distanceTag = Drawing.new("Text"),
			weaponTag = Drawing.new("Text")
		}

		for _,text in pairs(text) do
			table.insert(events,text)
		end

		local healthBar = Drawing.new("Line")
		table.insert(events, healthBar)

		table.insert(drawings['esp'], {
			char_model = char_model,
			box = box,
			text = text,
			healthBar = healthBar,
			-- skeleton = skeleton
		})
	end
end

local function getTextWidth(text, textSize)
    return #text * (textSize * 0.4) -- Approximate width per character
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

local get_tool_name = function(character)
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
local vector3_to_vector2 = function(vector)
	return Vector2.new(vector.X, vector.Y)
end


local get_target = function(fov_size)
	local closest,closest_char, closest_distance, closest_screen_pos = nil,nil, fov_size, nil

	local silly = players:GetPlayers()

	local body_parts = configs["aimbot"]["part"]

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
						closest_char = character
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
				closest_char = character
			end
		end
	end
	return closest, closest_screen_pos ,closest_char
end

local DRAWING_BOX = function(line_top,line_right,line_bottom,line_left  ,topLeft,topRight,bottomRight,bottomLeft)
	line_top.Visible = true
	line_top.From = topLeft
	line_top.To = topRight

	line_right.Visible = true
	line_right.From = topRight
	line_right.To = bottomRight

	line_bottom.Visible = true
	line_bottom.From = bottomLeft
	line_bottom.To = bottomRight

	line_left.Visible = true
	line_left.From = topLeft
	line_left.To = bottomLeft
end

local DRAWING_NAMETAG = function(nameTag,char_model,topLeft,nameWidth,screenPos,scaledTextSize)
	local get_tool = get_tool_name(char_model)

	nameTag.Visible = true
	nameTag.Position = Vector2.new(screenPos.X - nameWidth / 2, topLeft.Y - scaledTextSize - 12)
	nameTag.Text = char_model.Name.."\n"..get_tool
	nameTag.Color = Color3.new(1, 1, 1)
	nameTag.Size = scaledTextSize
	nameTag.Outline = true
end

local DRAWING_WEAPON = function(weaponTag,name,topLeft,nameWidth,screenPos,scaledTextSize)
	weaponTag.Visible = true
	weaponTag.Position = Vector2.new(screenPos.X - nameWidth / 2, topLeft.Y - scaledTextSize + 2)
	weaponTag.Text = name
	weaponTag.Color = Color3.new(1, 1, 1)
	weaponTag.Size = scaledTextSize
	weaponTag.Outline = true
end

local DRAWING_DISTANCETAG = function(distanceTag,distance,scaledTextSize,screenPos,bottomLeft)
	local distanceText = string.format("%.1f m", distance)
	local distanceWidth = getTextWidth(distanceText, scaledTextSize * 0.8)

	distanceTag.Visible = true
	distanceTag.Position = Vector2.new(screenPos.X - distanceWidth / 2, bottomLeft.Y + 5)
	distanceTag.Text = distanceText
	distanceTag.Color = Color3.new(0, 1, 1)
	distanceTag.Size = math.max(12, scaledTextSize * 0.8)
	distanceTag.Outline = true
end

local DRAWING_HEALTHBAR = function(healthBar,humanoid,topRight,bottomRight,boxHeight)
	local healthPercent = humanoid.Health / humanoid.MaxHealth
	local healthHeight = boxHeight * healthPercent

	healthBar.Visible = true
	healthBar.From = Vector2.new(topRight.X + 2, bottomRight.Y)
	healthBar.To = Vector2.new(topRight.X + 2, bottomRight.Y - healthHeight)
	healthBar.Color = Color3.new(0, 1, 0)
	healthBar.Thickness = 3
end

local part_points = {
	torso = { "UpperTorso", "LowerTorso" },
	larm = { "LeftUpperArm", "LeftLowerArm", "LeftHand" },
	rarm = { "RightUpperArm", "RightLowerArm", "RightHand" },
	lleg = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" },
	rleg = { "RightUpperLeg", "RightLowerLeg", "RightFoot" },
	head = "Head",
}

local function is_part_valid(part)
	return part and part.Position
end

local function get_part_position(char_model, part_name)
	local part = char_model:FindFirstChild(part_name)
	if is_part_valid(part) then
		return vector3_to_vector2(part.Position)
	end
	return nil, false
end


local DRAWING_SKELETON = function(skeleton,char_model)
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

	-- for part, segments in pairs(part_points) do
	-- 	if type(segments) == "table" then
	-- 		points[part] = {}
	-- 		for _, segment in ipairs(segments) do
	-- 			local pos, visible = get_part_position(char_model, segment)
	-- 			if visible then
	-- 				table.insert(points[part], pos)
	-- 			else
	-- 				visible_parts = false
	-- 			end
	-- 		end
	-- 	else
	-- 		points[part], visible_parts = get_part_position(char_model, segments)
	-- 	end
	-- end

	local line_config = { enabled = configs["esp"]["skeleton"]["enabled"], color = configs["esp"]["skeleton"]["color"], thickness = configs["esp"]["skeleton"]["thickness"] }

	local function draw_line(parent,start_pos, end_pos, line_config)
		parent.Visible = true
		parent.Color = Color3.new(1,0,0)
		parent.Thickness = 1
		parent.From = start_pos
		parent.To = end_pos
	end

	draw_line(skeleton.head, points.head, points.torso[1])
	draw_line(skeleton.torso1, points.torso[1], points.torso[2])

	draw_line(skeleton.larm1, points.torso[1], points.larm[1])
	draw_line(skeleton.larm2, points.larm[1], points.larm[2])
	draw_line(skeleton.larm3, points.larm[2], points.larm[3])

	draw_line(skeleton.rarm1, points.torso[1], points.rarm[1])
	draw_line(skeleton.rarm2, points.rarm[1], points.rarm[2])
	draw_line(skeleton.rarm3, points.rarm[2], points.rarm[3])

	draw_line(skeleton.lleg1, points.torso[2], points.lleg[1])
	draw_line(skeleton.lleg2, points.lleg[1], points.lleg[2])
	draw_line(skeleton.lleg3, points.lleg[2], points.lleg[3])

	draw_line(skeleton.rleg1, points.torso[2], points.rleg[1])
	draw_line(skeleton.rleg2, points.rleg[1], points.rleg[2])
	draw_line(skeleton.rleg3, points.rleg[2], points.rleg[3])

	-- Head
	draw_line(skeleton.head,points.torso[1], points.head, line_config)

end

local UPDATE_ESP = function()
	
	for _,esp in pairs(drawings['esp']) do
		local box = esp.box
		local text = esp.text
		
		local char_model = esp.char_model
		local line_top = box.line_top
		local line_right = box.line_right
		local line_left = box.line_left
		local line_bottom = box.line_bottom
		local nameTag = text.nameTag
		local distanceTag = text.distanceTag
		local healthBar = esp.healthBar
		local weaponTag = text.weaponTag
		-- local skeleton = esp.skeleton

		local elements = {line_top, line_right, line_bottom, line_left, nameTag, distanceTag, healthBar}

		-- for _,v in pairs(skeleton) do
		-- 	table.insert(elements,v)
		-- end

		function hide_esp()
			for _, element in pairs(elements) do
				element.Visible = false
			end
		end

		function clear_esp()
			for _, element in pairs(elements) do
				element:Destroy()
			end
			table.remove(drawings['esp'],_)
		end

		-- char_model.Destroying:Connect(clear_esp)
		
		if char_model then
			local hrp = char_model:FindFirstChild("HumanoidRootPart")
			local humanoid = char_model:WaitForChild("Humanoid")

			if humanoid.Health > 0 and hrp then

				local position = hrp.Position
			
				local screenPos, onScreen = camera:WorldToViewportPoint(position)

				if not onScreen then
					hide_esp()
					continue
				end
			
				local distance = (camera.CFrame.Position - position).Magnitude

				if (distance > configs["esp"]["maxDistance"]) then
					hide_esp()
					continue
				end

				local scaleFactor = 500 / distance

				local boxWidth = size.X * scaleFactor
				local boxHeight = size.Y * scaleFactor

				local topLeft = Vector2.new(screenPos.X - boxWidth / 2, screenPos.Y - boxHeight / 2)
				local topRight = Vector2.new(screenPos.X + boxWidth / 2, screenPos.Y - boxHeight / 2)
				local bottomLeft = Vector2.new(screenPos.X - boxWidth / 2, screenPos.Y + boxHeight / 2)
				local bottomRight = Vector2.new(screenPos.X + boxWidth / 2, screenPos.Y + boxHeight / 2)

				local scaledTextSize = math.clamp(math.floor(20 * (1 / distance * 10)), 12, 24)
				local nameWidth = getTextWidth(char_model.Name, scaledTextSize)
				
				if configs.esp.box.eneble then
					DRAWING_BOX(line_top,line_right,line_bottom,line_left  ,topLeft,topRight,bottomRight,bottomLeft)
				end

				if configs.esp.name.eneble then
					DRAWING_NAMETAG(nameTag,char_model,topLeft,nameWidth,screenPos,scaledTextSize)
				end
				
				if configs.esp.distance.eneble then
					DRAWING_DISTANCETAG(distanceTag,distance,scaledTextSize,screenPos,bottomLeft)
				end
				
				if configs.esp.healthBar.eneble then
					DRAWING_HEALTHBAR(healthBar,humanoid,topRight,bottomRight,boxHeight)
				end


				-- DRAWING_SKELETON(skeleton,char_model)
			else
				hide_esp()
			end
		else
			hide_esp()
		end
	end
end

current_target = nil
current_taret_part = nil

local AIMBOT = function()
    local target_part, pos, target_char = get_target(configs["fov"]["radius"])

    -- Get target if none is selected
    if current_target == nil and current_taret_part == nil then
        current_target = target_char
		current_taret_part = target_part
    end

    if current_target and is_dead(current_target.Humanoid) and is_down(current_target.Humanoid) then
        current_target = nil
		current_taret_part = nil
		return
    end

    -- Check if target is valid and within range
    if pos and current_taret_part then
        local distance = (camera.CFrame.Position - current_taret_part.Position).Magnitude
        if distance > configs["esp"]["maxDistance"] then
            -- current_target = nil
            return
        end

        -- Set visuals
        local target_part_vec = Vector2.new(pos.X, pos.Y)
        snapline.Color = configs["snapline"]["color"]
        snapline.Thickness = configs["snapline"]["thickness"]
        snapline.From = mouse_location
        snapline.To = target_part_vec
		snapline.Visible = configs["snapline"]["enable"]

        prediction_dot.Visible = true
        prediction_dot.Position = target_part_vec

        -- Smooth and accurate aiming
        if aiming and configs["aimbot"]["enable"] then
            local rel = target_part_vec - mouse_location
            local smoothness = configs["aimbot"]["smoothness"] or 5

            -- Apply clamped, smooth movement
            local moveX = math.clamp(rel.X / smoothness, -10, 10)
            local moveY = math.clamp(rel.Y / smoothness, -10, 10)
            
            mousemoverel(moveX, moveY)
        end
    else
        -- Hide visuals if no target
        snapline.Visible = false
        prediction_dot.Visible = false
    end
end


for _,player in pairs(players:GetPlayers()) do
    if player ~= local_player then
		pcall(function()
			coroutine.wrap(ESP)(player)
		end)
	end
end

players.PlayerAdded:Connect(function(player)
	task.delay(1, function()
		pcall(function()
			player.CharacterAdded:Wait()

			coroutine.wrap(ESP)(player)
		end)
	end)
end)

local run_service_event = run_service.RenderStepped:Connect(function()
	pcall(function()
		fov.Position = mouse_location
		local center = Vector2.new(mouse_location.X, mouse_location.Y)
		crosshair_vertical.From = Vector2.new(center.X, center.Y - crosshair_size)
		crosshair_vertical.To = Vector2.new(center.X, center.Y + crosshair_size)
		crosshair_horizontal.From = Vector2.new(center.X - crosshair_size, center.Y)
		crosshair_horizontal.To = Vector2.new(center.X + crosshair_size, center.Y)
	end)
	pcall(UPDATE_ESP)
	pcall(AIMBOT)
end)

table.insert(events, run_service_event)


local run_service_event
run_service_event = run_service.RenderStepped:Connect(function()
	if hash ~= getgenv().hash then
		run_service_event:Disconnect()
		for _, v in pairs(events) do
			pcall(function()
				v:Destroy()
			end)
			pcall(function()
				v:Disconnect()
			end)
		end
	end
end)