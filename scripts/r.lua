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

local loots = workspace:FindFirstChild("Spawned Loot")

local nebula = {
    ui = nil,
    Settings = {},
    functions = {},
}

function nebula.functions:create(class, prop)
    local inst = typeof(class) == "string" and Instance.new(class) or class
    for property, val in prop do
        inst[property] = val
    end
    return inst
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

local types = {
    loots = "loots",
}

local objects_cache = {}
local drawing_objects = {}

for _, value in types do
	objects_cache[value] = {}
	drawing_objects[value] = {}
end




local world_holder = nebula.functions:create("ScreenGui", { Parent = gethui(), Name = "world_holder" })

local hash = http_service:GenerateGUID(false) -- sdfsdf-sdfsdf5-sdf6sd5f-s5df4s5d
getgenv().hash = hash

local _run_service
_run_service = run_service.RenderStepped:Connect(function()
    if hash ~= getgenv().hash then
        pcall(function()
			_run_service:Disconnect()
			world_holder:Destroy()

			for _,type in pairs(drawing_objects) do
				for _2,drawing in pairs(type) do
					drawing:die()
				end
			end
		end)
    end
end)

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
	text.Visible = true

	text.Font = Enum.Font.FredokaOne
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

function get_distance(obj)
    local distance = 0

    if obj:IsA("Model") then
        distance = math.floor((camera.CFrame.Position - obj.PrimaryPart.CFrame.Position).Magnitude)
    else
        distance = math.floor((camera.CFrame.Position - obj.CFrame.Position).Magnitude)
    end

    return distance
end

local function loots_esp(obj: Model)
    local value = true
	local color = Color3.fromRGB(255, 255, 255)


	if value then
        local _value = math.floor(tonumber(obj:GetAttribute('Value') or 0)) 

		local drawing = draw_instance(types.loots, obj, {
			Text = string.format("%s | %sm \n$%s", obj.Name, get_distance(obj), _value),
			TextColor3 = color,
		})

        drawing:add_connection(obj.AttributeChanged:Connect(function()
            local _value = math.floor(tonumber(obj:GetAttribute('Value') or 0))
            local inCert = obj:GetAttribute('InCart')

			drawing:set_text(string.format("%s | %sm \n$%s", obj.Name, get_distance(obj),_value))

            drawing.Billboard.Enabled = not inCert
		end))

        drawing:add_connection(camera:GetPropertyChangedSignal("CFrame"):Connect(function()
            local _value = math.floor(tonumber(obj:GetAttribute('Value') or 0)) 
			drawing:set_text(string.format("%s | %sm \n$%s", obj.Name,  get_distance(obj),_value))
		end))
	else
		add_cache(types.loots, obj)
	end
end

local enemies = workspace:FindFirstChild("Spawned Enemies")

local function enemyCham(enemy: Model)
    if enemy:FindFirstChild("Highlight") then
        enemy:FindFirstChild("Highlight"):Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = enemy
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true
    highlight.Adornee = enemy
end

for _,enemy in pairs(enemies:GetChildren()) do
    enemyCham(enemy)
end

enemies.ChildAdded:Connect(enemyCham)

if loots then
	for _, loot in loots:GetChildren() do
        loots_esp(loot)
    end
    
    loots.ChildAdded:Connect(loots_esp)
end
