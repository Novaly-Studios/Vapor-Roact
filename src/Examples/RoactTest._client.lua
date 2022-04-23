local Libs = script.Parent.Parent.Parent
    local Vapor = require(Libs:WaitForChild("Vapor"))
    local Roact = require(Libs:WaitForChild("Roact"))

local VaporRoact = script.Parent.Parent
    local WrapComponent = require(VaporRoact:WaitForChild("WrapComponent"))
    local StoreProvider = require(VaporRoact:WaitForChild("StoreProvider"))

local TestStore = Vapor.GeneralStore.new(function(callback)
    task.delay(1, callback) -- Queue updates between 1 second intervals
end)

local function DisplayComponent(props)
    return Roact.createElement("ScreenGui", {}, {
        Roact.createElement("TextButton", {
            Text = props.text;
            TextWrapped = true;
            Size = UDim2.fromScale(0.2, 0.2);
            Position = UDim2.fromScale(0.5, 0.5);
            AnchorPoint = Vector2.new(0.5, 0.5);

            [Roact.Event.Activated] = function()
                props.onActivated()
                props.universalActionExample()
            end;
            [Roact.Event.MouseEnter] = props.onMouseOver;
        })
    })
end

local function AppendSomeText(interface, text)
    interface:merge({
        append = (interface:get().append or "") .. "[" .. text .. "]";
    })
end

local DisplayWrapped = WrapComponent(DisplayComponent, {"stuff"}, function(data, _, interface)
    return {
        text = (data.count or "") .. "/" .. (data.append or "");

        onActivated = function()
            AppendSomeText(interface, "click")
        end;

        onMouseOver = function()
            AppendSomeText(interface, "hover")
        end;
    }
end, {
    universalActionExample = function(interface)
        AppendSomeText(interface, "extra")
    end;
})

local App = Roact.createElement(StoreProvider, {
    storeObject = TestStore;
}, {
    Main = Roact.createElement(DisplayWrapped);
})

Roact.mount(App, game.Players.LocalPlayer:WaitForChild("PlayerGui"), "Test")

TestStore:merge({
    stuff = {
        count = 0;
        append = "";
    }
})

local path = {"stuff", "count"}

game:GetService("RunService").Heartbeat:Connect(function()
    for _ = 1, 100 do
        TestStore:merge({
            stuff = {
                count = TestStore:get(path) + 1;
            }
        })
    end
end)