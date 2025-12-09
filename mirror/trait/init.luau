--!strict
--!optimize 2

--[[
    ▄ █ ▀█▀ █ ▄  Welcome To Hell @ wthrblx.com
     █▀█ █ █▀█   (c) Team Fireworks 2024-2026.

    This Source Code Form is subject to the terms of the Mozilla Public License,
    v. 2.0. If a copy of the MPL was not distributed with this file, You can
    obtain one at https://mozilla.org/MPL/2.0/.
]]

--[=[
    @class Trait
    @since 1.0.0

    Represents a function that can be implemented by other objects.
    In Welcome To Hell, this is used to implement Mechanic methods.

    @example

    A `Trait` for Mechanics:

    ```luau
    wth.implementMechanicLoaded(Damager, function(self, tower)
        self:logger():info("Hello Welcome To Hell!")
    end)
    ```

    @example

    Constructing your own `Implementable`s:

    ```luau
    -- FIXME: Luau doesn't have sufficient types to represent implementors </3
    local onHello: wth.Trait<(any, string)> = wth.Trait.new("OnHello")
    -- In future Luau releases, you can use explicit type instantiation:
    -- local onHello = wth.Trait.new<<(any, string)>>("OnHello")

    local function implementOnHello<T>(
        self: T,
        implementation: (self: T, person: string) -> void
    )
        onHello:implement(self, implementation)
    end

    local myObject = {}
    myObject.name = "myObject"
    implementOnHello(myObject, function(self, person)
        print("Hello", person, "from", myObject.name)
    end)
    ```
]=]
local Trait = {}
Trait.__index = Trait

export type Trait<Parameters..., Returns...> = typeof(setmetatable(
	{} :: {
		name: string,
		implementations: { [unknown]: ((Parameters...) -> Returns...)? },
	},
	Trait
))

export type AnyTrait = Trait<(...any), (...any)>

--[=[
    @function new
    @since 1.0.0

    Constructs and returns a new Trait.

    @param name string -- The name to use for `tostring` and error messages.
    @return Trait<Parameters..., Returns...> -- The constructed trait.
]=]
function Trait.new<Parameters..., Returns...>(name: string): Trait<Parameters..., Returns...>
	return table.freeze(setmetatable({ name = name, implementations = {} }, Trait))
end

--[=[
    @function isTrait
    @since 1.0.0

    Returns if the given object is a Trait.

    @param x any -- The object to check.
    @return boolean -- If the object is a Trait.
]=]
function Trait.isTrait(x: any)
	return type(x) == "table" and getmetatable(x) == Trait
end

--[=[
    @method implement
    @since 1.0.0

    Assigns a Trait implementation for an object, which can be consumed with
    the `Trait.get` and `Trait.call` methods.

    This will override any existing implementation.

    @param self Trait<Parameters..., Returns...> -- The trait for the object to implement.
    @param object unknown -- The object to implement.
    @param implementation: (Parameters...) -> Returns... -- The trait implementation for said object.
]=]
function Trait.implement<Parameters..., Returns...>(
	self: Trait<Parameters..., Returns...>,
	object: unknown,
	implementation: (Parameters...) -> Returns...
)
	self.implementations[object] = implementation
end

function Trait.unimplement<Parameters..., Returns...>(self: Trait<Parameters..., Returns...>, object: unknown): ((Parameters...) -> Returns...)?
	local old = self.implementations[object]
	self.implementations[object] = nil
	return old
end

function Trait.unimplementAll<Parameters..., Returns...>(self: Trait<Parameters..., Returns...>)
	table.clear(self.implementations)
end

function Trait.isImplemented<Parameters..., Returns...>(self: Trait<Parameters..., Returns...>, object: unknown)
	return self.implementations[object] ~= nil
end

function Trait.get<Parameters..., Returns...>(self: Trait<Parameters..., Returns...>, object: unknown)
	return self.implementations[object] or error(`Trait {self.name} unimplemented for {object}`, 2)
end

function Trait.tryGet<Parameters..., Returns...>(self: Trait<Parameters..., Returns...>, object: unknown)
	return self.implementations[object]
end

function Trait.call<Parameters..., Returns...>(self: Trait<Parameters..., Returns...>, object: unknown, ...: Parameters...)
	local implementation = self.implementations[object]
	if implementation then
		return implementation(...)
	end
	error(`Trait {self.name} unimplemented for {object}`, 2)
end

function Trait.tryCall<Parameters..., Returns...>(self: Trait<Parameters..., Returns...>, object: unknown, ...: Parameters...): (boolean, ...any)
	local implementation = self.implementations[object]
	if implementation then
		return true, implementation(...)
	end
	return false
end

function Trait.__tostring(trait: AnyTrait)
	return `Trait("{trait.name}")`
end

return Trait
