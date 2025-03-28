
local Bracket = loadstring(game:HttpGet("https://4b60-2405-9800-b961-2fd1-70ff-74e0-1305-e025.ngrok-free.app/ui.lua"))()

Bracket:Notification({Title = "Text",Description = "Text",Duration = 10}) -- Duration can be nil for "x" to pop up
Bracket:Notification2({Title = "Text",Duration = 10})

-- see source code for more hidden things i forgot to add in this example
local Window = Bracket:Window({Name = "Fallen Survival",Enabled = true,Color = Color3.new(1,0.5,0.25),Size = UDim2.new(0,496,0,496),Position = UDim2.new(0.5,-248,0.5,-248)}) do

    local Watermark = Window:Watermark({
        Title = "Bracket V3.2 | Example",
        Flag = "UI/Watermark/Position",
        Enabled = true,
    })

    local Tab = Window:Tab({Name = "Aimbot"}) do
        --Side might be "Left", "Right" or nil for auto side choose
        --Tab:AddConfigSection("FolderName","Side")
        --Tab.Name = "Name"

		local Section = Tab:Section({Name = "Aimbot",Side = "Left"}) do

			Section:Toggle({Name = "Enable",Flag = "aimbot enable",Side = "Left",Value = false})
			Section:Toggle({Name = "Wall Check",Flag = "aimbot enable",Side = "Left",Value = false})

			Section:Slider({Name = "Smoothness",Flag = "aimbot smoothness",Side = "Left",Min = 0,Max = 1,Value = 1,Precise = 1,Unit = ""})
			Section:Dropdown({Name = "Aim Part",Flag = "Dropdown",Side = "Left",List = {
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

			Section:Toggle({Name = "Distance",Flag = "distance enable",Side = "Left",Value = false})
			:Colorpicker({Flag = "esp distance color",Side = "Left",Value = {0,0,1,0,false} })

			Section:Toggle({Name = "Weapon",Flag = "esp weapon",Side = "Left",Value = false})
			:Colorpicker({Flag = "esp weapon color",Side = "Left",Value = {0,0,1,0,false} })

			Section:Toggle({Name = "Skeleton",Flag = "esp skeleton",Side = "Left",Value = false})
			:Colorpicker({Flag = "esp skeleton color",Side = "Left",Value = {0,0,1,0,false} })
			Section:Slider({Name = "thickness",Flag = "esp skeleton thickness",Side = "Left",Min = 1,Max = 10,Value = 1,Precise = 1,Unit = ""})


			Section:Toggle({Name = "HealthBar",Flag = "esp health bar",Side = "Left",Value = false})
			Section:Slider({Name = "thickness",Flag = "health bar thickness",Side = "Left",Min = 1,Max = 10,Value = 1,Precise = 1,Unit = ""})

			Section:Dropdown({Name = "Position",Flag = "health bar position",Side = "Left",List = {
				{
					Name = "Bottom",
					Mode = "Button", 
					Value = false,
				},
				{
					Name = "Left",
					Mode = "Button",
					Value = true
				},
			}})

			-- :Colorpicker({Flag = "health bar",Side = "Left",Value = {0,0,1,0,false} })
		end

		local Section = VisualTab:Section({Name = "Custom",Side = "Left"}) do
			Section:Dropdown({Name = "Font",Flag = "font face",Side = "Left",List = {
				{
					Name = "FredokaOne",
					Mode = "Button",
					Value = true
				},
			}})
		end


		local Section = VisualTab:Section({Name = "FOV",Side = "Right"}) do
			-- Section:Divider({Text = "Aimbit",Side = "Left"})

			Section:Toggle({Name = "Enable",Flag = "fov enable",Side = "Left",Value = false})
			:Colorpicker({Flag = "fov color",Side = "Left",Value = {0,0,1,0,false} })

			Section:Slider({Name = "Size",Flag = "fov size",Side = "Left",Min = 10,Max = 300,Value = 100,Precise = 1,Unit = ""})
			Section:Slider({Name = "Thickness",Flag = "fov thickness",Side = "Left",Min = 1,Max = 10,Value = 1,Precise = 1,Unit = ""})

			Section:Divider({Text = "crosshair",Side = "Right"})

			Section:Toggle({Name = "Enable",Flag = "enable",Side = "Left",Value = false})
			:Colorpicker({Flag = "crosshair color",Side = "Left",Value = {0,0,1,0,false} })

			Section:Slider({Name = "size",Flag = "crosshair size",Side = "Left",Min = 1,Max = 10,Value = 1,Precise = 1,Unit = ""})
			Section:Slider({Name = "thickness",Flag = "crosshair thickness",Side = "Left",Min = 1,Max = 10,Value = 5,Precise = 1,Unit = ""})

			Section:Divider({Text = "Prediction dot",Side = "Right"})


			Section:Toggle({Name = "Enable",Flag = "prediction dot enable",Side = "Left",Value = false})
			:Colorpicker({Flag = "prediction dot color",Side = "Left",Value = {0,0,1,0,false} })

			Section:Slider({Name = "size",Flag = "prediction dot size",Side = "Left",Min = 1,Max = 10,Value = 1,Precise = 1,Unit = ""})

			Section:Divider({Text = "Snapline",Side = "Right"})


			Section:Toggle({Name = "Enable",Flag = "snapline enable",Side = "Left",Value = false})
			:Colorpicker({Flag = "snapline enable color",Side = "Left",Value = {0,0,1,0,false} })

			Section:Slider({Name = "thickness",Flag = "snapline thickness",Side = "Left",Min = 1,Max = 10,Value = 1,Precise = 1,Unit = ""})

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


print(Window.Flags[""])