local Roact = require(script.Parent.Parent:WaitForChild("Roact"))
local Context = require(script.Parent.Context)
local StoreProvider = Roact.Component:extend("StoreProvider")

local ERR_NO_STORE_PROVIDED = "Prop 'storeObject' not provided"

function StoreProvider.validateProps(props)
    if (not props.storeObject) then
        return false, ERR_NO_STORE_PROVIDED
    end

    return true
end

function StoreProvider:init(props)
    self.storeObject = props.storeObject
end

function StoreProvider:render()
    return Roact.createElement(Context.Provider, {
        value = self.storeObject,
    }, Roact.oneChild(
        self.props[Roact.Children]
    ))
end

return StoreProvider