repeat
	task.wait()
until game:IsLoaded()

local clone_reference = cloneref or function(...)
	return ...
end

local players: Players = clone_reference(game:GetService("Players"))
local run_service: RunService = clone_reference(game:GetService("RunService"))
local user_input_service: UserInputService = clone_reference(game:GetService("UserInputService"))
local core_gui: CoreGui = clone_reference(game:GetService("CoreGui"))
local http_service: HttpService = clone_reference(game:GetService("HttpService"))
local gui_service: GuiService = clone_reference(game:GetService("GuiService"))

local local_player = players.LocalPlayer
local camera = workspace.CurrentCamera
local viewport_size = camera.ViewportSize
local mouse_location = user_input_service:GetMouseLocation()
local current_target: BasePart
local viewportOffset = gui_service:GetGuiInset() -- Offset from the top bar

local raycast_params = RaycastParams.new()


raycast_params.FilterDescendantsInstances = { camera, local_player.Character }
raycast_params.FilterType = Enum.RaycastFilterType.Exclude
raycast_params.IgnoreWater = true

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


local nebula = {
    ui = nil,
    Settings = {},
    functions = {},
}

nebula.ui = loadstring(game:HttpGet("http://localhost:8080/scripts/ui.lua"))()

nebula.ui:Notification({Title = "Text",Description = "Text",Duration = 10}) -- Duration can be nil for "x" to pop up
nebula.ui:Notification2({Title = "Text",Duration = 10})

-- see source code for more hidden things i forgot to add in this example
local Window = nebula.ui:Window({Name = "Nebula",Enabled = true,Color = Color3.new(1,0.5,0.25),Size = UDim2.new(0,496,0,496),Position = UDim2.new(0.5,-248,0.5,-248)}) do

    local Watermark = Window:Watermark({
        Title = "Nebula V1.0",
        Flag = "UI/Watermark/Position",
        Enabled = true,
    })

    local Tab = Window:Tab({Name = "Aimbot"}) do

		local Section = Tab:Section({Name = "Aimbot",Side = "Left"}) do

			Section:Toggle({Name = "Enable",Flag = "aimbot enable",Side = "Left",Value = false})
			-- Section:Toggle({Name = "Visibility Check",Flag = "visibility check",Side = "Left",Value = false})

			Section:Slider({Name = "Smoothness",Flag = "aimbot smoothness",Side = "Left",Min = 0,Max = 1,Value = 0.5,Precise = 1})
			Section:Dropdown({Name = "Aim Part",Flag = "body parts",Side = "Left",List = {
				{
					Name = "Head",
					Mode = "Button", -- Button or Toggle
					Value = false,
				},
				{
					Name = "UpperTorso",
					Mode = "Button",
					Value = true
				},
				{
					Name = "random",
					Mode = "Button",
					Value = true
				},
				{
					Name = "closest",
					Mode = "Button",
					Value = true
				},
			}})

			local Section = Tab:Section({Name = "FOV",Side = "Right"}) do
				-- Section:Divider({Text = "Aimbit",Side = "Left"})
	
				Section:Toggle({Name = "Enable",Flag = "fov enable",Side = "Left",Value = false})
				:Colorpicker({Flag = "fov color",Side = "Left",Value = {0,0,1,0,false} })
	
				Section:Slider({Name = "Size",Flag = "fov size",Side = "Left",Min = 10,Max = 300,Value = 100,Precise = 1,Unit = ""})
				Section:Slider({Name = "Thickness",Flag = "fov thickness",Side = "Left",Min = 0,Max = 10,Value = 1,Precise = 1,Unit = ""})
				Section:Slider({Name = "Transparency",Flag = "fov transparency",Side = "Left",Min = 0,Max = 1,Value = 0,Precise = 1,Unit = ""})


				
			end

			local Section = Tab:Section({Name = "Prediction dot",Side = "Right"}) do
				Section:Toggle({Name = "Enable",Flag = "prediction dot enable",Side = "Left",Value = false})
				:Colorpicker({Flag = "prediction dot color",Side = "Left",Value = {0,1,1,0,false} })
	
				Section:Slider({Name = "size",Flag = "prediction dot size",Side = "Left",Min = 1,Max = 10,Value = 3,Precise = 1,Unit = ""})
				Section:Slider({Name = "Transparency",Flag = "prediction dot transparency",Side = "Left",Min = 1,Max = 10,Value = 1,Precise = 1,Unit = ""})
			end

			local Section = Tab:Section({Name = "Snapline",Side = "Right"}) do
				Section:Toggle({Name = "Enable",Flag = "snapline enable",Side = "Left",Value = false})
				:Colorpicker({Flag = "snapline color",Side = "Left",Value = {0,0,1,0,false} })


				Section:Slider({Name = "Transparency",Flag = "snapline transparency",Side = "Left",Min = 0,Max = 1,Value = 0.5,Precise = 1,Unit = ""})
				
				Section:Slider({Name = "Thickness",Flag = "snapline thickness",Side = "Left",Min = 1,Max = 10,Value = 1,Precise = 1,Unit = ""})
			end
	
	
			

							-- Crosshair
			local Section = Tab:Section({Name = "Crosshair",Side = "Right"}) do
				Section:Toggle({Name = "Enable",Flag = "crosshair enable",Side = "Left",Value = false})
				:Colorpicker({Flag = "crosshair color",Side = "Left",Value = {0,0,1,0,false} })
					
				Section:Slider({Name = "size",Flag = "crosshair size",Side = "Left",Min = 1,Max = 10,Value = 1,Precise = 1,Unit = ""})
				Section:Slider({Name = "thickness",Flag = "crosshair thickness",Side = "Left",Min = 1,Max = 10,Value = 5,Precise = 1,Unit = ""})
					
			end
		end

    end

	local VisualTab = Window:Tab({Name = "Visual"}) do
        --Side might be "Left", "Right" or nil for auto side choose
        --Tab:AddConfigSection("FolderName","Side")
        --Tab.Name = "Name"

		local Section = VisualTab:Section({Name = "ESP",Side = "Left"}) do
			-- Section:Divider({Text = "Aimbit",Side = "Left"})

			Section:Toggle({Name = "Enable",Flag = "esp enable",Side = "Left",Value = false})

			Section:Toggle({Name = "Box",Flag = "esp box",Side = "Left",Value = false})
			:Colorpicker({Flag = "esp box color",Side = "Left",Value = {0,0,1,0,false} })

			Section:Toggle({Name = "Name",Flag = "esp name",Side = "Left",Value = false})
			:Colorpicker({Flag = "esp name color",Side = "Left",Value = {0,0,1,0,false} })

			Section:Toggle({Name = "Distance",Flag = "esp distance",Side = "Left",Value = false})
			:Colorpicker({Flag = "esp distance color",Side = "Left",Value = {0,0,1,0,false} })

			Section:Toggle({Name = "Weapon",Flag = "esp weapon",Side = "Left",Value = false})
			:Colorpicker({Flag = "esp weapon color",Side = "Left",Value = {0,0,1,0,false} })

			Section:Toggle({Name = "Skeleton",Flag = "esp skeleton",Side = "Left",Value = false})
			:Colorpicker({Flag = "esp skeleton color",Side = "Left",Value = {0,0,1,0,false} })

			Section:Toggle({Name = "Highlight",Flag = "esp highlight",Side = "Left",Value = false})
			:Colorpicker({Flag = "esp highlight color",Side = "Left",Value = {0,1,1,0,false} })

			Section:Toggle({Name = "Visible",Flag = "esp visible",Side = "Left",Value = false})
			
			

			Section:Toggle({Name = "Health Bar",Flag = "esp health bar",Side = "Left",Value = false})
			Section:Toggle({Name = "Health Text",Flag = "esp health text",Side = "Left",Value = false})

			

			

			-- :Colorpicker({Flag = "health bar",Side = "Left",Value = {0,0,1,0,false} })
		end

		local esp_options = VisualTab:Section({Name = "ESP Options",Side = "Right"}) do
			esp_options:Slider({Name = "HealthBar thickness",Flag = "health bar thickness",Side = "Left",Min = 1,Max = 10,Value = 1,Precise = 1,Unit = ""})
			esp_options:Slider({Name = "Skeleton thickness",Flag = "esp skeleton thickness",Side = "Left",Min = 1,Max = 10,Value = 1,Precise = 1,Unit = ""})
			esp_options:Dropdown({Name = "HealthBar Position",Flag = "health bar position",Side = "Left",List = {
				{
					Name = "bottom",
					Mode = "Button", 
					Value = false,
				},
				{
					Name = "left",
					Mode = "Button",
					Value = true
				},
			}})
			esp_options:Dropdown({Name = "Box Type",Flag = "box type",Side = "Right",List = {
				{
					Name = "full",
					Mode = "Button", 
					Value = false,
				},
				{
					Name = "cornered",
					Mode = "Button",
					Value = true
				},
			}})

			
		end

		local esp_check = VisualTab:Section({Name = "ESP Checker",Side = "Right"}) do
			esp_check:Toggle({Name = "Team Check",Flag = "team check",Side = "Left",Value = false})
			esp_check:Toggle({Name = "Dead Check",Flag = "dead check",Side = "Left",Value = false})
		end
		

		local Section = VisualTab:Section({Name = "Custom",Side = "Left"}) do
			Section:Dropdown({Name = "Font Face",Flag = "font face",Side = "Left",List = {
				{
					Name = "FredokaOne",
					mode = "Button", -- Button or Toggle
					Value = true
				},
				{
					Name = "SciFi",
					mode = "Button", -- Button or Toggle
					Value = false
				},
				{
					Name = "GrenzeGotisch",
					mode = "Button", -- Button or Toggle
					Value = false
				},
			}})
			Section:Slider({Name = "Font Size",Flag = "font size",Side = "Left",Min = 8,Max = 20,Value = 8,Precise = 1,Unit = ""})

		end


		

					
	end
	
    local OptionsTab = Window:Tab({Name = "Options"}) do
        local MenuSection = OptionsTab:Section({Name = "Menu",Side = "Left"}) do
            local UIToggle = MenuSection:Toggle({Name = "UI Enabled",Flag = "UI/Enabled",IgnoreFlag = true,
            Value = Window.Enabled,Callback = function(Bool) Window.Enabled = Bool end})
            UIToggle:Keybind({Value = "RightShift",Flag = "UI/Keybind",DoNotClear = true})
            UIToggle:Colorpicker({Flag = "UI/Color",Value = {1,0.25,1,0,true},
            Callback = function(HSVAR,Color) Window.Color = Color end})

            MenuSection:Toggle({Name = "Open On Load",Flag = "UI/OOL",Value = true})
            MenuSection:Toggle({Name = "Blur Gameplay",Flag = "UI/Blur",Value = false,
            Callback = function(Bool) Window.Blur = Bool end})

            MenuSection:Toggle({Name = "Watermark",Flag = "UI/Watermark/Enabled",Value = true,
            Callback = function(Bool) Window.Watermark.Enabled = Bool end}):Keybind({Flag = "UI/Watermark/Keybind"})
        end

        OptionsTab:AddConfigSection("Bracket_Example","Left")

        local BackgroundSection = OptionsTab:Section({Name = "Background",Side = "Right"}) do
            BackgroundSection:Colorpicker({Name = "Color",Flag = "Background/Color",Value = {1,1,0,0,false},
            Callback = function(HSVAR,Color) Window.Background.ImageColor3 = Color Window.Background.ImageTransparency = HSVAR[4] end})
            BackgroundSection:Textbox({HideName = true,Flag = "Background/CustomImage",Placeholder = "rbxassetid://ImageId",
            Callback = function(String,EnterPressed) if EnterPressed then Window.Background.Image = String end end})
            BackgroundSection:Dropdown({HideName = true,Flag = "Background/Image",List = {
                {Name = "Legacy",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://2151741365"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Hearts",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073763717"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Abstract",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073743871"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Hexagon",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073628839"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Circles",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6071579801"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Lace With Flowers",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6071575925"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Floral",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://5553946656"
                    Window.Flags["Background/CustomImage"] = ""
                end,Value = true},
                {Name = "Halloween",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://11113209821"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Christmas",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://11711560928"
                    Window.Flags["Background/CustomImage"] = ""
                end}
            }})
            BackgroundSection:Slider({Name = "Tile Offset",Flag = "Background/Offset",Wide = true,Min = 74,Max = 296,Value = 74,
            Callback = function(Number) Window.Background.TileSize = UDim2.fromOffset(Number,Number) end})
        end
    end
end

Window:SetValue("Background/Offset",74)
Window:AutoLoadConfig("Bracket_Example")
Window:SetValue("UI/Enabled",Window.Flags["UI/OOL"])

local flags = Window.Flags

-- local flags = {
--     ["fov enable"] = false,
--     ["fov size"] = 100,
--     ["snapline enable"] = false,
--     ["prediction dot enable"] = false,
--     ["prediction dot size"] = 3,
--     ["snaplines enable"] = false,

--     ["crosshair enable"] = false,
--     ["crosshair size"] = 5,
--     ["aimbot enable"] = false,
--     ["aimbot smoothness"] = 0.8,
-- 	["target npcs"] = true,
-- 	["radar enable"] = true,

--     ["esp enable"] = true,
--     ["esp box"] = true,
-- 	["esp box 3d"] = false,
--     ["box type"] = "cornered",
--     ["esp name"] = true,
--     ["esp distance"] = true,
--     ["esp skeleton"] = true,
--     ["esp highlight"] = true,
--     ["esp displayname"] = true,
--     ["esp visible"] = false,
--     ["esp health bar"] = true,
--     ["esp health text"] = true,

-- 	["esp nodes"] = true,
-- 	["esp btr"] = true,
	
-- 	["esp nodes keybind"] = Enum.KeyCode.V,
    
--     ["team check"] = false,
--     ["dead check"] = true,
--     ["down check"] = true,
--     ["font face"] = "FredokaOne",
--     ["wall check"] = false,
    
--     ["health bar position"] = "left",
-- 	["snaplines position"] = "top", --  center , top , mouse

--     ["weapon esp"] = false,

--     ["esp name color"] = Color3.fromRGB(255, 255, 255),
--     ["esp skeleton color"] = Color3.fromRGB(255, 255, 255),
--     ["esp highligh color"] = Color3.fromRGB(233, 144, 255),
--     ["esp distance color"] = Color3.fromRGB(0, 247, 255),
--     ["esp weapon color"] = Color3.fromRGB(255, 255, 255),
--     ["esp box color"] = Color3.fromRGB(255, 255, 255),
--     ["snapline color"] = Color3.fromRGB(255, 255, 255),
--     ["prediction dot color"] = Color3.fromRGB(255, 69, 69),
--     ["fov color"] = Color3.fromRGB(255, 255, 255),
--     ["crosshair color"] = Color3.fromRGB(2, 255, 15),
-- 	["snaplines color"] = Color3.fromRGB(255, 255, 255),
-- 	["esp box 3d color"] = Color3.fromRGB(255, 255, 255),

-- 	["esp nodes color"] = Color3.fromRGB(255, 253, 110),
-- 	["esp btr color"] = Color3.fromRGB(255, 70, 70),

-- 	["esp nodes list"] = {"Stone","Metal","Phosphate","Part"}, -- Stone, Metal, Phosphate

--     ["snapline transparency"] = 0.8,
--     ["fov transparency"] = 0.8,
-- 	["esp box 3d transparency"] = 0,

--     ["body parts"] = "Head",
--     ["fov thickness"] = 1,
--     ["snapline thickness"] = 1,
--     ["crosshair thickness"] = 2,
--     ["health bar thickness"] = 2,
--     ["esp skeleton thickness"] = 1,
-- 	["snaplines thickness"] = 1,
-- 	["esp box 3d thickness"] = 1,

-- 	["radar size"] = 200,
-- 	["radar map scale"] = 100,
-- 	["radar position"] = "topright"
	
-- }

local hash = http_service:GenerateGUID(true) -- sdfsdf-sdfsdf5-sdf6sd5f-s5df4s5d
getgenv().hash = hash

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

do
    function nebula.functions:create(class, prop)
        local inst = typeof(class) == "string" and Instance.new(class) or class
        for property, val in prop do
            inst[property] = val
        end
        return inst
    end

    function nebula.functions:is_visible(Destination)
		local part = Destination and Destination.PrimaryPart
		if not part then
			return false
		end
		local RaycastResult =
			workspace:Raycast(camera.CFrame.p, (part.Position - camera.CFrame.p).Unit * 10000, raycast_params)
		return RaycastResult and RaycastResult.Instance:IsDescendantOf(Destination)
	end

    function nebula.functions:get_tool_name(character)
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

    function nebula.functions:custom_bounds(model)
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

user_input_service.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		mouse_location = user_input_service:GetMouseLocation()
	end
end)

local aiming = false
local world_visible = false

local inputBegan = user_input_service.InputBegan:Connect(function(input, gameProcessedEvent)
    if (gameProcessedEvent) then return end

    if (input.UserInputType == Enum.UserInputType.MouseButton2) then
        aiming = true
    end

	if (input.KeyCode == flags["esp nodes keybind"]) then
		world_visible = true
		bindable_event:Fire(true)
	end
end)

local inputEnded = user_input_service.InputEnded:Connect(function(input, gameProcessedEvent)
    if (gameProcessedEvent) then return end

    if (input.UserInputType == Enum.UserInputType.MouseButton2) then
        aiming = false
    end

	if (input.KeyCode == flags["esp nodes keybind"]) then
		world_visible = false
		bindable_event:Fire(true)
	end
end)

local is_team = function(player)
	if not player then
		return false
	end

	if player.Neutral and getrenv().shared and getrenv().shared.cachedTeamModels then
		return getrenv().shared.cachedTeamModels[player.UserId]
	end

	return player.Team == local_player.Team
    -- return false
end

local is_down = function(humanoid)
	return humanoid:GetAttribute("Downed")
end

local is_dead = function(humanoid)
	return humanoid.Health <= 0
end

local vector3_to_vector2 = function(vector)
	return Vector2.new(vector.X, vector.Y)
end

local draw_line = function(frame, from, to,thickness)
    local netVector = to - from

		local length = math.sqrt(netVector.X ^ 2 + netVector.Y ^ 2) + 1
		local midpoint = Vector2.new((from.X + to.X) / 2, (from.Y + to.Y) / 2)
		local theta = math.deg(math.atan2(from.Y - to.Y, from.X - to.X))

		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
		frame.Rotation = theta
		frame.Size = UDim2.new(0, length, 0, thickness)
		-- frame.zIndex = -999
end

function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end

local get_target = function(fov_size)
	local closest, closest_distance, closest_screen_pos = nil, fov_size, nil

	local silly = players:GetPlayers()

	local body_parts = flags["body parts"][1]

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

		if flags["team check"] and is_team(player) then
			continue
		end
		if flags["dead check"] and is_dead(humanoid) then
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

local get_bench_health = function(obj)
	if obj then
		return obj:GetAttribute("Health"), obj:GetAttribute("MaxHealth"), obj:GetAttribute("DesiredHealth")
	end

	return math.huge, math.huge, nil
end

function predict_target(bullet_speed)
    if not current_target or not aiming then return Vector2.new(0, 0) end
    
    local target_pos = current_target.Position
    local target_vel = current_target.Velocity or Vector2.new(0, 0)  -- Fallback to zero if no velocity
    
    local my_pos = camera.CFrame.Position
    
    local distance = (target_pos - my_pos).Magnitude
    
    local time_to_target = distance / bullet_speed
    
    -- Predict future position
    local predicted_pos = target_pos + (target_vel * time_to_target)
    
    -- Return the predicted position relative to your current aim
    return predicted_pos - my_pos
end





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

local world_holder = nebula.functions:create("ScreenGui", { Parent = gethui(), Name = "world_holder" })

local add_instance = function(object, data)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = object.Name
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(300, 100)
	billboard.Adornee = object

	billboard.Parent = world_holder

	local text = Instance.new("TextLabel")

	text.Size = UDim2.fromScale(1, 1)

	-- sigma
	text.TextTruncate = Enum.TextTruncate.None
	text.TextWrapped = false
	text.BackgroundTransparency = 1
	text.TextTransparency = 0
	text.TextSize = 9
	text.TextColor3 = Color3.new(1, 1, 1)
	text.Visible = false
	-- text.TextStrokeColor3 = Color3.new(0, 0, 0)
	-- text.TextStrokeTransparency = 0.8
	-- text.TextS
	--Font.fromId(12187371840)
	text.Font = flags["font face"]
	text.Parent = billboard

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Color = Color3.new(0, 0, 0)
	uiStroke.Parent = text


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


local function contains(list, value)
    for _, v in ipairs(list) do
        if v == value then return true end
    end
    return false
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
	local value = flags["esp nodes"]
	local color = flags["esp nodes color"]
	local nodes_list = flags["esp nodes list"]
	if value then

		local node_name = string.gsub(obj.Name, "_Node$", "")

		if #nodes_list > 0 and not contains(nodes_list, node_name) then
            return
        end

		draw_instance(types.nodes, obj, {
			Text = node_name,
			TextColor3 = color,
		})
	else
		add_cache(types.nodes, obj)
	end
end

local btr_esp = function(obj: Model)
	local value = flags["esp btr"]
	local color = flags["esp btr color"]

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

-- local nodes = workspace:FindFirstChild("Nodes")
local nodes = workspace
local events = workspace:FindFirstChild("Events")

if nodes then
	pcall(function()
		
		for _, node in nodes:GetChildren() do
			node_esp(node)
		end
		
		nodes.ChildAdded:Connect(node_esp)
	end)
end

if events then
	pcall(function()
		for _, btr in events:GetChildren() do
			btr_esp(btr)
		end
		
		events.ChildAdded:Connect(btr_esp)
	end)
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
	-- [types.drops] = drops_esp,
	-- [types.plants] = plant_esp,
	-- [types.soldiers] = military_esp,
	-- [types.animals] = animal_esp,
	[types.btr] = btr_esp,
	-- bases object
	-- [types.body_bags] = object_handler,
	-- [types.crates] = object_handler,
	-- [types.timed_crate] = object_handler,
}

local update_cache = function() -- this handles the turning off / on
	for type_name, type_func in cache_functions do
		local flag_name = string.format("esp %s", type_name)
		local flag_value =flags[flag_name]
		assert(flag_value, string.format("no flag called %s", flag_name))

		handle_cache(flag_value, type_func, type_name)
	end
end

local handle_flag = function(value, esp_type)
	local drawing_objects_tbl = drawing_objects[esp_type]
	
	assert(drawing_objects_tbl, string.format("no drawing objects called %s", esp_type))

	for _, drawing: BillboardGui in drawing_objects_tbl do
		local text_label = drawing.Text

		if text_label then
			text_label.TextColor3 = value
			text_label.Visible = world_visible
		end
	end
end

function table_to_color(Table)
	if type(Table) ~= "table" then return Table end
		return Color3.fromHSV(Table[1], Table[2], Table[3])
end

local update_flag = function()

	for _, type_name in types do
		handle_flag(flags[string.format("esp %s color", type_name)], type_name)
	end
end

bindable_event.Event:Connect(function(color)
	if color then
		update_flag()
	else
		update_cache()
	end
end)

local gui_holder = nebula.functions:create("ScreenGui", { Parent = gethui(), Name = "main_holder" })

local circle = nebula.functions:create("Frame",{
	Name = "Fov",
	Size = UDim2.new(0, flags["fov size"], 0, flags["fov size"]),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	-- AnchorPoint = Vector2.new(0,0.5),
	Parent = gui_holder
})

-- Create UICorner for round edges
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = circle


-- Create UIStroke for border
local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 2
uiStroke.Color = table_to_color(flags["fov color"]) 
uiStroke.Parent = circle

-- local gradient = Instance.new("UIGradient")
-- gradient.Parent = circle
-- gradient.Rotation = 45  -- You can set any rotation for the gradient
-- gradient.Color = ColorSequence.new({
--     ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 109)),  -- Start color (red)
--     ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 161, 234))   -- End color (blue)
-- })
-- gradient.Parent = uiStroke

local snapline = Drawing.new("Line")
snapline.Thickness = flags["snapline thickness"]
snapline.Color = table_to_color(flags["snapline color"]) 
snapline.Visible = flags["snapline enable"]
snapline.From = mouse_location
snapline.Transparency = flags["snapline transparency"]

local dot = Drawing.new("Circle")
dot.Visible = flags["prediction dot enable"]
dot.Filled = true
dot.Color = table_to_color(flags["prediction dot color"]) 
dot.Position = mouse_location
dot.Radius = flags["prediction dot size"]

local part_points = {
	torso = { "UpperTorso", "LowerTorso" },
	larm = { "LeftUpperArm", "LeftLowerArm", "LeftHand" },
	rarm = { "RightUpperArm", "RightLowerArm", "RightHand" },
	lleg = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" },
	rleg = { "RightUpperLeg", "RightLowerLeg", "RightFoot" },
	head = "Head",
}

local crosshair_vertical = Drawing.new("Line")
crosshair_vertical.Thickness = flags["crosshair thickness"]
crosshair_vertical.Color = table_to_color(flags["crosshair color"])
crosshair_vertical.Visible = flags["crosshair enable"]

local crosshair_horizontal = Drawing.new("Line")
crosshair_horizontal.Thickness = flags["crosshair thickness"]
crosshair_horizontal.Color = table_to_color(flags["crosshair color"])
crosshair_horizontal.Visible = flags["crosshair enable"]

local ESP = function(model)
    local esp_holder = nebula.functions:create("ScreenGui", { Parent = gethui(), Name = "esp_holder" })
    local esp_connection

	local font = flags["font face"][1]


    local drawings = {
        name = nebula.functions:create("TextLabel",{
			Parent = esp_holder,
			BackgroundTransparency = 1,
			TextStrokeTransparency = 0,
			TextStrokeColor3 = Color3.fromRGB(1, 1, 1),
            TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = font,
			TextSize = 9,
			Text = model.DisplayName or model.Name,
		}),
        distance = nebula.functions:create("TextLabel",{
			Parent = esp_holder,
			BackgroundTransparency = 1,
			TextStrokeTransparency = 0,
			TextStrokeColor3 = Color3.fromRGB(1, 1, 1),
            TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = font,
			TextSize = 9,
			ZIndex = 999,
		}),
        weapon = nebula.functions:create("TextLabel",{
			Parent = esp_holder,
			BackgroundTransparency = 1,
			TextStrokeTransparency = 0,
			TextStrokeColor3 = Color3.fromRGB(1, 1, 1),
            TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = font,
			TextSize = 9,
		}),
        health_text = nebula.functions:create(
			"TextLabel",
			{
				Parent = esp_holder,
				TextXAlignment = Enum.TextXAlignment.Center,
				Font = font,
				TextSize = 9,
				BackgroundTransparency = 1,
				TextStrokeTransparency = 0,
				ZIndex = 999,
				TextStrokeColor3 = Color3.new(0, 0, 0),
			}
		),
        box = nebula.functions:create("Frame",{ 
            Parent = esp_holder,
            BackgroundTransparency = 0.8,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = -999
        }),
        box2 = nebula.functions:create(
			"Frame",
			{ Parent = esp_holder, BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255,255,255), ZIndex = 999 }
		),
        healthbar = nebula.functions:create("Frame",{
            Parent = esp_holder,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
        }),
        behind_healthbar = nebula.functions:create("Frame", {
			Parent = esp_holder,
			ZIndex = -1,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0,
			BorderSizePixel = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
		}),
        healthbar_gradient = nebula.functions:create("UIGradient", { Enabled = true, Rotation = -90 }),
        outline = nebula.functions:create(
			"UIStroke",
			{
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 1,
				Transparency = 1,
				LineJoinMode = Enum.LineJoinMode.Miter,
				Enabled = true,
			}
		),
        outline2 = nebula.functions:create("UIStroke", { Thickness = 1, Enabled = true, LineJoinMode = Enum.LineJoinMode.Miter }),
        flag1 = nebula.functions:create("TextLabel",{Parent = esp_holder,Text = "",TextColor3 = Color3.new(0, 0.85, 0),Font = font,TextSize = 9,BackgroundTransparency = 1,TextStrokeTransparency = 0,ZIndex = 999,TextStrokeColor3 = Color3.fromRGB(0, 0, 0),TextXAlignment = Enum.TextXAlignment.Right,}),
		left_top_fix = nebula.functions:create("Frame",{ Parent = esp_holder, Size = UDim2.new(0, 1, 0, 6), ZIndex = 999 }),
		right_top_fix = nebula.functions:create("Frame",{ Parent = esp_holder, Size = UDim2.new(0, 1, 0, 6), ZIndex = 999 }),
		bottom_side_fix = nebula.functions:create("Frame",{ Parent = esp_holder, Size = UDim2.new(0, 1, 0, 6), ZIndex = 999 }),
		bottom_right_side_fix = nebula.functions:create("Frame",{ Parent = esp_holder, Size = UDim2.new(0, 1, 0, 6), ZIndex = 999 }),
		left_top = nebula.functions:create("Frame", { Parent = esp_holder, ZIndex = 3 }),
		left_side = nebula.functions:create("Frame", { Parent = esp_holder }),
		right_top = nebula.functions:create("Frame", { Parent = esp_holder, ZIndex = 3 }),
		right_side = nebula.functions:create("Frame", { Parent = esp_holder }),
		bottom_side = nebula.functions:create("Frame", { Parent = esp_holder }),
		bottom_down = nebula.functions:create("Frame", { Parent = esp_holder }),
		bottom_right_side = nebula.functions:create("Frame", { Parent = esp_holder }),
		bottom_right_down = nebula.functions:create("Frame", { Parent = esp_holder }),
        flag2 = nebula.functions:create(
			"TextLabel",
			{
				Parent = esp_holder,
				Text = "",
				Font = font,
				TextSize = 9,
				BackgroundTransparency = 1,
				TextStrokeTransparency = 0,
				ZIndex = 999,
				TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Right,
			}
		),

        skeleton = nebula.functions:create("Frame", {
			Parent = esp_holder,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}),

		snapline = nebula.functions:create("Frame", {
			Parent = esp_holder,
			Name = "snapline",
			BorderSizePixel = 0
			-- BackgroundTransparency = 1,
		}),

		box_3d = nebula.functions:create("Frame", {
			Parent = esp_holder,
			Name = "box_3d",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0)
		}),

		-- radar_player_dot = nebula.functions:create("Frame", {
		-- 	Name = "radar_player_dot",
		-- 	Parent = radar,
		-- 	Size = UDim2.new(0, 8, 0, 8),
		-- 	-- BackgroundTransparency = 1,
		-- 	BackgroundColor3 = Color3.new(1, 0, 0),
        --     BorderSizePixel = 0
		-- }),
		-- arrow = nebula.functions:create("ImageLabel", {
		-- 	Parent = esp_holder,
		-- 	Size = UDim2.new(0, 20, 0, 20),
		-- 	-- BackgroundTransparency = 1,
		-- 	Image = "rbxassetid://YOUR_IMAGE_ID",
		-- 	AnchorPoint = Vector2.new(0.5, 0.5)
		-- }),
    }

    -- local radar_player = Instance.new("UICorner")
    -- radar_player.CornerRadius = UDim.new(1, 0)
    -- radar_player.Parent = drawings.radar_player_dot
	-- wait(1)

	for _,bone in {"head","torso1","torso2","larm1","larm2","larm3","rarm1","rarm2","rarm3","lleg1","lleg2","lleg3","rleg1","rleg2","rleg3"} do
		nebula.functions:create("Frame", {
			Parent = drawings.skeleton,
			Name = bone,
			BorderSizePixel = 0,
		})
	end

	for i = 1, 12 do
		nebula.functions:create("Frame", {
			Parent = drawings.box_3d,
			Name = "line_" .. i,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Transparency = 0,
		})
	end

    drawings.healthbar_gradient.Parent = drawings.healthbar
    drawings.outline.Parent = drawings.box
    drawings.outline2.Parent = drawings.box2

    local function hide_esp()
        for _, name in { "box_3d","name", "distance", "weapon", "behind_healthbar", "healthbar", "health_text", "box", "box2", "skeleton", "flag1", "flag2", "left_top_fix", "right_top_fix", "bottom_side_fix", "bottom_right_side_fix", "left_top", "left_side", "right_top", "right_side", "bottom_side", "bottom_down", "bottom_right_side", "bottom_right_down","snapline" } do
            drawings[name].Visible = false
        end
    end

    local function clear_esp()
        for _, drawing in drawings do
            drawing:Destroy()
        end

        if esp_connection then
            esp_connection:Disconnect()
        end

        esp_holder:Destroy()
		-- print("esp ",model.Name," is being destroyed")
    end

    

    local update = function()
        local health_start = 0
		local health_transition_start = 0
		local health_transition_old = 0
		local current_health = 0

		model.Destroying:Connect(function()
			
		end)

        esp_connection = run_service.RenderStepped:Connect(function(deltaTime)
            if getgenv().hash ~= hash then
                clear_esp()
            end

			local success = pcall(function()
				players:GetUserIdFromNameAsync(model.Name)
			end)

			if not success then
				clear_esp()
			end

            local char_model = model and model.Character
            if char_model then
                local hrp = char_model and char_model:FindFirstChild("HumanoidRootPart")
				local humanoid = char_model and char_model:WaitForChild("Humanoid")

                if humanoid.Health > 0 and hrp then 
                    local _, size, position = nebula.functions:custom_bounds(char_model)
                    local position = hrp.Position

                    local size = Vector2.new(4, 6)

                    if not position then
                        return
                    end
					
					
					-- if flags["radar enable"] then
					-- 	local relativePos = (hrp.Position - camera.CFrame.Position) / flags["radar map scale"]
					-- 	local x = math.clamp(0.5 + relativePos.X / flags["radar size"], 0, 1)
					-- 	local y = math.clamp(0.5 - relativePos.Z / flags["radar size"], 0, 1)
						
					-- 	drawings.radar_player_dot.Position = UDim2.new(x, -3, y, -3)							
					-- end

                    local max_distance = (camera.CFrame.Position - position).Magnitude / 3.5714285714
                    local esp_enable =  flags["esp enable"]
					-- print(esp_enable)

                    if max_distance and char_model and humanoid and hrp and esp_enable then
                        local team_check = flags["team check"]
						local dead_check = flags["dead check"]

                        if team_check and is_team(model) then
							return hide_esp()
						end

						if dead_check and is_dead(humanoid) then
							return hide_esp()
						end

                        local pos, on_screen = camera:WorldToScreenPoint(position)

						if not on_screen then
							return hide_esp()
						end

                        local height = math.tan(math.rad(camera.FieldOfView / 2)) * 2 * pos.Z
						local scale = Vector2.new((viewport_size.Y / height) * size.X, (viewport_size.Y / height) * size.Y)
                        
                        local box_esp = flags["esp box"]
                        local name_esp = flags["esp name"]
						local box_3d_esp = flags["esp box 3d"]
						
						local box_3d_esp_thickness = flags["esp box 3d thickness"]
						local box_3d_esp_transparency = flags["esp box 3d transparency"]

                        local distance_esp = flags["esp distance"]
                        local health_bar_position = flags["health bar position"][1]
                        local health_bar_esp = flags["esp health bar"]


                        local weapon_esp = flags["weapon esp"]
                        local health_text_esp = flags["esp health text"]
                        local skeleton_esp = flags["esp skeleton"]
                        local highlight_esp = flags["esp highlight"]
                        local displayname_esp = flags["esp displayname"]
                        local visible_flag_esp = flags["esp visible"]
                        local box_type = flags["box type"][1]

                        local name_esp_color = table_to_color(flags["esp name color"])
                        local highlight_esp_color = table_to_color(flags["esp highlight color"])
                        local skeleton_esp_color = table_to_color(flags["esp skeleton color"])
                        local distance_esp_color = table_to_color(flags["esp distance color"])
                        local weapon_esp_color = table_to_color(flags["esp weapon color"])
                        local box_esp_color = table_to_color(flags["esp box color"])
						local box_3d_esp_color = table_to_color(flags["esp box 3d color"])

                        local health_bar_thickness = flags["health bar thickness"]

                        if displayname_esp then
                            drawings.name.Text = model.DisplayName or char_model.Name
                        else
                            drawings.name.Text = char_model.Name
                        end


						for _, name in { "name", "distance", "weapon", "health_text", "flag1", "flag2", } do
							drawings[name].Font = flags["font face"][1]
							drawings[name].TextSize = flags["font size"]
						end
			
                        if box_esp  and box_type == "full" then
                            drawings.box.Size = UDim2.new(0, scale.X - 1, 0, scale.Y - 1)
							drawings.box2.Size = UDim2.new(0, scale.X + 1, 0, scale.Y + 1)

							drawings.box.Position = UDim2.new(0, pos.X - (scale.X / 2), 0, pos.Y - (scale.Y / 2))
							drawings.box2.Position = UDim2.new(0, pos.X - (scale.X / 2) - 1, 0, pos.Y - (scale.Y / 2) - 1)

							drawings.box.Visible = true
							drawings.box2.Visible = true

                            drawings.outline2.Color = drawings.outline2.Color:Lerp(
								(
									highlight_esp
									and current_target
									and current_target:IsDescendantOf(char_model)
									and highlight_esp_color
									and flags["fov enable"]
								)
										and highlight_esp_color
									or box_esp_color,
								0.04
							)
                        else
                            drawings.box.Visible = false
							drawings.box2.Visible = false
                        end

						if box_esp and box_type == "cornered" then
							local positions = {
								{ "left_top_fix", pos.X - scale.X / 2, pos.Y - scale.Y / 2, 1, 12 },
								{ "right_top_fix", pos.X + scale.X / 2 - 1, pos.Y - scale.Y / 2, 1, 12 },
								{ "bottom_side_fix", pos.X - scale.X / 2, pos.Y + scale.Y / 2 - 6 },
								{ "bottom_right_side_fix", pos.X + scale.X / 2 - 1, pos.Y + scale.Y / 2 - 6 },
								{ "left_top", pos.X - scale.X / 2, pos.Y - scale.Y / 2, scale.X / 3, 1, Vector2.new(0, 0), },
								{ "left_side", pos.X - scale.X / 2, pos.Y - scale.Y / 2, 1, scale.Y / 4, Vector2.new(0, 0), },
								{ "right_top", pos.X + scale.X / 2, pos.Y - scale.Y / 2, scale.X / 3, 1, Vector2.new(1, 0), },
								{ "right_side", pos.X + scale.X / 2 - 1, pos.Y - scale.Y / 2, 1, scale.Y / 4, Vector2.new(0, 0), },
								{ "bottom_side", pos.X - scale.X / 2, pos.Y + scale.Y / 2, 1, scale.Y / 4, Vector2.new(0, 3), },
								{ "bottom_down", pos.X - scale.X / 2, pos.Y + scale.Y / 2, scale.X / 3, 1, Vector2.new(0, 1), },
								{ "bottom_right_side", pos.X + scale.X / 2, pos.Y + scale.Y / 2, 1, scale.Y / 4, Vector2.new(1, 1), },
								{ "bottom_right_down", pos.X + scale.X / 2, pos.Y + scale.Y / 2, scale.X / 3, 1, Vector2.new(1, 1), },
							}

							for _, v in positions do
								local name, x_pos, y_pos, width, height, anchor = unpack(v)
								local drawing = drawings[name]

								drawing.Position = UDim2.new(0, x_pos, 0, y_pos)

								if not name:find("fix") then
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
										and flags["fov enable"]
									)
											and highlight_esp_color
										or box_esp_color,
									0.04
								)
							end
						else
							for _, name in { "left_top_fix", "right_top_fix", "bottom_side_fix", "bottom_right_side_fix", "left_top", "left_side", "right_top", "right_side", "bottom_down", "bottom_side", "bottom_right_side", "bottom_right_down", } do
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
									and flags["fov enable"]
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
									and flags["fov enable"]
								)
										and highlight_esp_color
									or distance_esp_color,
								0.04
							)
							drawings.distance.Text = string.format("%dm", math.floor(max_distance))

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
									and flags["fov enable"]
								)
										and highlight_esp_color
									or weapon_esp_color,
								0.04
							)
							drawings.weapon.Text = nebula.functions:get_tool_name(char_model)
						else
							drawings.weapon.Visible = false
						end

                        local bottom_offset = (health_bar_esp and health_bar_position == "bottom") and 7 or 0
                        
						if distance_esp and weapon_esp then
							drawings.distance.Position = UDim2.new(0, pos.X, 0, pos.Y + scale.Y / 2 + 17 + bottom_offset)
							drawings.weapon.Position = UDim2.new(0, pos.X, 0, pos.Y + scale.Y / 2 + 6 + bottom_offset)
						elseif distance_esp then
							drawings.distance.Position = UDim2.new(0, pos.X, 0, pos.Y + scale.Y / 2 + 7 + bottom_offset)
						elseif weapon_esp then
							drawings.weapon.Position = UDim2.new(0, pos.X, 0, pos.Y + scale.Y / 2 + 6 + bottom_offset)
						end


                        if health_bar_esp then
							local health, max_health = math.floor(humanoid.Health), humanoid.MaxHealth
							local health_color = Color3.new(1, 0, 0):Lerp(Color3.new(0.7, 0.8, 0), math.clamp(health / max_health, 0, 1))
							health_color = health_color:Lerp(Color3.new(0, 1, 0),math.clamp((health / max_health - 0.5) * 2, 0, 1))
							local health_offset = math.floor((max_health - health) / 10) * 0.1
                            
							do -- healthbar animation
								health_start = health_start or 0
								health_transition_start = health_transition_start or health
								health_transition_old = health_transition_old or health
								current_health = current_health or health

								if health ~= health_transition_start then
									health_transition_old, health_transition_start, health_start = current_health, health, tick()
								end
							end

							local progress = math.clamp((tick() - health_start) / 0.5, 0, 1)
							current_health = health_transition_old + (health_transition_start - health_transition_old) * progress

							if progress >= 1 then
								current_health, health_transition_old, health_transition_start, health_start = health, health, health, 0
							end

							do
								drawings.health_text.Text, drawings.health_text.Visible = tostring(math.floor(current_health)), true
								if health_text_esp then
									drawings.health_text.Text, drawings.health_text.Visible = tostring(math.floor(current_health)), true
								else
									drawings.health_text.Visible = false
								end
								drawings.health_text.TextColor3 = health_color
							end

							drawings.healthbar.Visible = true
							drawings.behind_healthbar.Visible = true

							local bar_offset, bar_width = 0, health_bar_thickness
							local bar_height_adjust = (box_esp == "full") and 3 or 0
							local position_adjust = bar_height_adjust / 2
							local target_height = scale.Y * (current_health / max_health) + bar_height_adjust
							local target_width = scale.X * (current_health / max_health) + bar_height_adjust

							if health_bar_position == "left" then
								bar_offset = 7
								drawings.healthbar_gradient.Rotation = -90
								drawings.healthbar.Position = UDim2.new(0, pos.X - scale.X / 2 - bar_offset, 0, pos.Y - scale.Y / 2 - position_adjust + scale.Y * (1 - current_health / max_health))
								drawings.behind_healthbar.Position = UDim2.new(0, pos.X - scale.X / 2 - bar_offset, 0, pos.Y - scale.Y / 2 - position_adjust )
								drawings.healthbar.Size = UDim2.new(0, bar_width, 0, target_height)
								drawings.behind_healthbar.Size = UDim2.new(0, bar_width, 0, scale.Y + bar_height_adjust)
								health_offset = math.clamp(health_offset, 0, 1)
								drawings.healthbar_gradient.Offset = Vector2.new(0, -health_offset)
								
                                local target_text_pos = health_bar_position == "left" and UDim2.new( 0, pos.X - scale.X / 2 - 17, 0, pos.Y - scale.Y / 2 + scale.Y * (1 - current_health / max_health)) or UDim2.new( 0, pos.X - scale.X / 2 + scale.X * (current_health / max_health), 0, pos.Y + scale.Y / 2 )
								drawings.health_text.Position = drawings.health_text.Position:Lerp(target_text_pos, progress)
							elseif health_bar_position == "bottom" then
								bar_offset = 4
								local bottom_y = pos.Y + scale.Y / 2 + bar_offset
								drawings.healthbar_gradient.Rotation = 0
								drawings.healthbar.Position = UDim2.new(0, pos.X - scale.X / 2 - position_adjust, 0, bottom_y)
								drawings.behind_healthbar.Position = UDim2.new(0, pos.X - scale.X / 2 - position_adjust, 0, bottom_y)
								drawings.healthbar.Size = UDim2.new(0, target_width, 0, bar_width)
								drawings.behind_healthbar.Size = UDim2.new(0, scale.X + bar_height_adjust, 0, bar_width)
								health_offset = math.clamp(health_offset, 0, 1)
								drawings.healthbar_gradient.Offset = Vector2.new(health_offset, 0)
								local target_text_pos = health_bar_position == "left" and UDim2.new(0,pos.X - scale.X / 2 - 17,0,pos.Y - scale.Y / 2 + scale.Y * (1 - current_health / max_health)) or UDim2.new( 0, pos.X - scale.X / 2 + scale.X * (current_health / max_health), 0, pos.Y + scale.Y / 2 + 5 )
								drawings.health_text.Position =
								drawings.health_text.Position:Lerp(target_text_pos, progress)
							end
                            
							drawings.healthbar_gradient.Color = ColorSequence.new(health_color)
						else
							drawings.healthbar.Visible, drawings.health_text.Visible, drawings.behind_healthbar.Visible = false, false, false
						end

                        if visible_flag_esp then
							drawings.flag1.Visible = true
							drawings.flag2.Visible = true

							if nebula.functions:is_visible(char_model) then
								drawings.flag1.Visible = true
								drawings.flag1.Text = "Vis"
							else
								drawings.flag1.Text = ""
								drawings.flag1.Visible = false
							end

							local box_side = pos.X + (scale.X / 2)
							local box_top = pos.Y - (scale.Y / 2)

							if box_type == "cornered" then
								drawings.flag1.Position = UDim2.new(0, box_side + 4, 0, box_top + 2)
								drawings.flag2.Position = UDim2.new(0, box_side + 4, 0, box_top + 2 + drawings.flag1.TextBounds.Y)
							elseif box_type == "full" then
								drawings.flag1.Position = UDim2.new(0, box_side + 4, 0, box_top)
								drawings.flag2.Position = UDim2.new(0, box_side + 4, 0, box_top + drawings.flag1.TextBounds.Y)
							end

							drawings.flag1.Position = drawings.flag1.Position
								+ UDim2.new(0, drawings.flag1.TextBounds.X, 0, 0)
							drawings.flag2.Position = drawings.flag2.Position
								+ UDim2.new(0, drawings.flag2.TextBounds.X, 0, 0)
						else
							drawings.flag1.Visible = false
							drawings.flag2.Visible = false
						end

						if flags["snaplines enable"] then
							drawings.snapline.Visible = true
							drawings.snapline.BackgroundColor3 = flags["snaplines color"]
							local position = Vector2.new(viewport_size.X / 2,-viewportOffset.Y + 5)

							if flags["snaplines position"] == "top" then
								position = Vector2.new(viewport_size.X / 2,-viewportOffset.Y + 5)
							end

							if flags["snaplines position"] == "center" then
								position = Vector2.new(viewport_size.X / 2,(viewport_size.Y / 2) - viewportOffset.Y)
							end

							if flags["snaplines position"] == "mouse" then
								position = Vector2.new(mouse_location.X, mouse_location.Y - viewportOffset.Y)
							end

							local boxTopCenter = Vector2.new(pos.X, pos.Y - scale.Y / 2)

							draw_line(drawings.snapline,
							position,
							boxTopCenter,
							flags["snaplines thickness"])
						else
							drawings.snapline.Visible = false
						end

						if box_3d_esp then
							local _size = Vector3.new(size.X / 2, size.Y / 2, size.X / 2)

							local points = {}
							local corners = {
								Vector3.new(-_size.X, -_size.Y, -_size.Z),
								Vector3.new(_size.X, -_size.Y, -_size.Z),
								Vector3.new(_size.X, _size.Y, -_size.Z),
								Vector3.new(-_size.X, _size.Y, -_size.Z),
								Vector3.new(-_size.X, -_size.Y, _size.Z),
								Vector3.new(_size.X, -_size.Y, _size.Z),
								Vector3.new(_size.X, _size.Y, _size.Z),
								Vector3.new(-_size.X, _size.Y, _size.Z)
							}
							
							-- Transform each corner to world space then to screen space
							for i, corner in ipairs(corners) do
								local worldPoint = hrp.CFrame:PointToWorldSpace(corner)
								local screenPoint = camera:WorldToScreenPoint(worldPoint)
								points[i] = vector3_to_vector2(screenPoint)
							end

							local edges = {
								{1, 2}, {2, 3}, {3, 4}, {4, 1}, -- Bottom face
								{5, 6}, {6, 7}, {7, 8}, {8, 5}, -- Top face
								{1, 5}, {2, 6}, {3, 7}, {4, 8}  -- Connecting edges
							}
							
							-- Make sure the box container is visible
							drawings.box_3d.Visible = true
							
							-- Get existing line frames
							local lineFrames = drawings.box_3d:GetChildren()

							for _,line in pairs(lineFrames) do
								line.BackgroundTransparency = box_3d_esp_transparency
								line.BackgroundColor3 = box_3d_esp_color

							end
							
							-- Draw each edge
							for i, edge in ipairs(edges) do

								
								local line = lineFrames[i]
								draw_line(line, points[edge[1]], points[edge[2]], box_3d_esp_thickness)
							end
						else
							drawings.box_3d.Visible = false
						end
						

						--------------------

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
							
							local thickness = flags["esp skeleton thickness"]
							-- pcall(function()
								draw_line(drawings.skeleton.head, points.head, points.torso[1],thickness)
								draw_line(drawings.skeleton.torso1, points.torso[1], points.torso[2],thickness)

								draw_line(drawings.skeleton.larm1, points.torso[1], points.larm[1],thickness)
								draw_line(drawings.skeleton.larm2, points.larm[1], points.larm[2],thickness)
								draw_line(drawings.skeleton.larm3, points.larm[2], points.larm[3],thickness)

								draw_line(drawings.skeleton.rarm1, points.torso[1], points.rarm[1],thickness)
								draw_line(drawings.skeleton.rarm2, points.rarm[1], points.rarm[2],thickness)
								draw_line(drawings.skeleton.rarm3, points.rarm[2], points.rarm[3],thickness)

								draw_line(drawings.skeleton.lleg1, points.torso[2], points.lleg[1],thickness)
								draw_line(drawings.skeleton.lleg2, points.lleg[1], points.lleg[2],thickness)
								draw_line(drawings.skeleton.lleg3, points.lleg[2], points.lleg[3],thickness)

								draw_line(drawings.skeleton.rleg1, points.torso[2], points.rleg[1],thickness)
								draw_line(drawings.skeleton.rleg2, points.rleg[1], points.rleg[2],thickness)
								draw_line(drawings.skeleton.rleg3, points.rleg[2], points.rleg[3],thickness)
							-- end)
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
        end)
    end
    
    -- pcall(function()
		coroutine.wrap(update)()
	-- end)
end

local _run_service

_run_service = run_service.RenderStepped:Connect(function()
    if hash ~= getgenv().hash then
        pcall(function()
			_run_service:Disconnect()

			circle:Destroy()

			gui_holder:Destroy()
			snapline:Destroy()
			crosshair_vertical:Destroy()
			crosshair_horizontal:Destroy()
			dot:Destroy()

			inputEnded:Disconnect()
			inputBegan:Disconnect()
			world_holder:Destroy()

			for _,type in pairs(drawing_objects) do
				for _2,drawing in pairs(type) do
					drawing:die()
				end
			end
		end)
    end
    

    -- pcall(function()
		local head_vec;

		do
			local fov_circle_size = flags["fov size"]

			-- print(fov_circle_size)
	
			local head, pos = get_target(fov_circle_size)
			current_target = head
	
			if pos then
				head_vec = Vector2.new(pos.X, pos.Y)

				dot.Visible = flags["prediction dot enable"]
				snapline.Visible = flags["snapline enable"]

				snapline.From = mouse_location
				snapline.To = head_vec
				dot.Position = head_vec
			else
				dot.Visible = false
				snapline.Visible = false
			end
	
			snapline.Color = table_to_color(flags["snapline color"])
			snapline.Transparency = flags["snapline transparency"]
			snapline.Thickness = flags["snapline thickness"]

			
			dot.Color = table_to_color(flags["prediction dot color"])
			dot.FillTransparency = flags["prediction dot transparency"]
			dot.Radius = flags["prediction dot size"]

	
			-- circle.Radius = fov_circle_size
			-- circle.Color = flags["fov color"]
	
			circle.Size = UDim2.new(0, fov_circle_size * 2, 0, fov_circle_size * 2)
			circle.Position  = UDim2.new(0, mouse_location.X - circle.Size.X.Offset / 2 - viewportOffset.X, 0, mouse_location.Y - circle.Size.Y.Offset / 2 - viewportOffset.Y)
			circle.BackgroundTransparency = 1

			circle.UIStroke.Transparency = flags["fov transparency"]
			circle.UIStroke.Color = table_to_color(flags["fov color"])
			circle.Visible = flags["fov enable"]

			circle.UIStroke.Thickness = flags["fov thickness"]
	
	
			local center = Vector2.new(mouse_location.X, mouse_location.Y)
			crosshair_vertical.From = Vector2.new(center.X, center.Y - flags["crosshair size"])
			crosshair_vertical.To = Vector2.new(center.X, center.Y + flags["crosshair size"])
			crosshair_horizontal.From = Vector2.new(center.X - flags["crosshair size"], center.Y)
			crosshair_horizontal.To = Vector2.new(center.X + flags["crosshair size"], center.Y)
		end

		
		-- if flags["visibility check"] and current_target then
		-- 	if not nebula.functions:is_visible(current_target) then
		-- 		return
		-- 	end
		-- end
	
		if flags["aimbot enable"] and current_target and aiming and head_vec then
			local smoothness = flags["aimbot smoothness"]
			smoothness = math.max(0.1, math.min(smoothness, 1.0))  -- Clamp smoothness between 0.1 and 1
		
			-- Calculate relative movement vector
			local rel_x = head_vec.x - mouse_location.x
			local rel_y = head_vec.y - mouse_location.y
			
			-- Apply smoothing interpolation
			local smooth_factor = 1 - smoothness
			local move_x = rel_x * smooth_factor
			local move_y = rel_y * smooth_factor
	
			if smoothness == 0 then
				move_x, move_y = rel_x, rel_y
			end

			mousemoverel(move_x, move_y)
		end
	-- end)
end)

do
    for _,player in pairs(players:GetPlayers()) do
		if getgenv().hash ~= hash then
			return
		end

		if player ~= local_player then
            -- pcall(function()
				coroutine.wrap(ESP)(player)
			-- end)
        end
	end
    
    players.PlayerAdded:Connect(function(player)
		if getgenv().hash ~= hash then
			return
		end

        task.delay(1, function()	
            pcall(function()
				coroutine.wrap(ESP)(player)
			end)
        end)
    end)
end