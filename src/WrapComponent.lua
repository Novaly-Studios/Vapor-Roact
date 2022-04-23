local Libs = script.Parent.Parent
    local Roact = require(Libs:WaitForChild("Roact"))
    local Vapor = require(Libs:WaitForChild("Vapor"))
        local StoreInterface = Vapor.StoreInterface

local Context = require(script.Parent:WaitForChild("Context"))

local element = Roact.createElement

local function defaultTransform(value, _oldValue, _interface)
    return value
end

local function merge(...)
    local result = {}
    local args = {...}

    for index = 1, #args do
        local arg = args[index]

        for key, value in pairs(arg) do
            result[key] = value
        end
    end

    return result
end

local function wrapComponent(component, path, transform, componentSpecificActions)
    path = path or {}
    transform = transform or defaultTransform
    componentSpecificActions = componentSpecificActions or {}

    local componentUID = tostring(component)

    -----------------------------------
        local Connection = Roact.Component:extend("Connection" .. componentUID)

        function Connection:init(props)
            local pathInterface = StoreInterface.new(props.storeObject, path)
            local wrappedComponentSpecificActions = {}

            for actionName, action in pairs(componentSpecificActions) do
                wrappedComponentSpecificActions[actionName] = function(...)
                    local result = action(pathInterface, ...)

                    if (not result) then
                        -- Should be optional to merge in an action
                        return
                    end

                    pathInterface:merge(result)
                end
            end

            -- Hook into changed for this path only
            -- Probably best not to use the store interface since this is only meant to read the data, not anything else
            self.changed = pathInterface:GetValueChangedSignal():Connect(function(value, oldValue)
                self:setState(function()
                    return merge(
                        self.state,
                        {
                            propsForChild = merge(
                                transform(value, oldValue, pathInterface),
                                wrappedComponentSpecificActions
                            );
                        }
                    )
                end)
            end)
        end

        function Connection:willUnmount()
            local changed = self.changed

            if (not changed) then
                return
            end

            changed:Disconnect()
            self.changed = nil
        end

        function Connection:render()
            return element(component, self.state.propsForChild)
        end
    -----------------------------------

    -----------------------------------
        local ConnectedComponent = Roact.Component:extend("ConnectedComponent" .. componentUID)

        function ConnectedComponent:render()
            return element(Context.Consumer, {
                render = function(storeObject)
                    return element(Connection, {
                        innerProps = self.props;
                        storeObject = storeObject;
                    })
                end
            })
        end
    -----------------------------------

    return ConnectedComponent
end

return wrapComponent