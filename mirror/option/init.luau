--!strict
--!optimize 2

--[[
    ▄ █ ▀█▀ █ ▄  Welcome To Hell @ wthrblx.com
     █▀█ █ █▀█   (c) Team Fireworks 2024-2026.

    This Source Code Form is subject to the terms of the Mozilla Public License,
    v. 2.0. If a copy of the MPL was not distributed with this file, You can
    obtain one at https://mozilla.org/MPL/2.0/.
]]

-- API is based on Rust: https://doc.rust-lang.org/std/option/enum.Option.html

local unpack: (any, number?, number?) -> ...any = table.unpack

local Option = {}
Option.__index = Option

export type Option<T...> = typeof(setmetatable(
	{} :: {
		n: number,
		-- This function doesn't exist at runtime and is only used for typings
		_innerType: (DO_NOT_USE_THIS_FUNCTION: never) -> T...,
	},
	Option
))

type AnyOption = Option<...any>

Option.None = table.freeze(setmetatable({ n = 0 }, Option)) :: AnyOption

function Option.Some<T...>(...: T...): Option<T...>
	local self = table.pack(...)
	return if self.n == 0 then error("`Option.Some` requires a value") else setmetatable(self :: any, Option)
end

function Option.is(x: any)
	return type(x) == "table" and getmetatable(x) == Option
end

function Option.isSome(self: AnyOption)
	return self.n ~= 0
end

function Option.isSomeAnd<T...>(self: Option<T...>, predicate: (T...) -> boolean)
	return self.n ~= 0 and predicate(unpack(self, 1, self.n))
end

function Option.isNone(self: AnyOption)
	return self.n == 0
end

function Option.isNoneOr<T...>(self: Option<T...>, predicate: (T...) -> boolean)
	return self.n == 0 or predicate(unpack(self, 1, self.n))
end

function Option.unwrap<T...>(self: Option<T...>): T...
	if self.n == 0 then
		error("Cannot unwrap an `Option.None`")
	end
	return unpack(self, 1, self.n)
end

function Option.unwrapOr<T...>(self: Option<T...>, ...: T...): T...
	if self.n == 0 then
		return ...
	end
	return unpack(self, 1, self.n)
end

function Option.unwrapOrElse<T...>(self: Option<T...>, fallback: () -> T...): T...
	if self.n == 0 then
		return fallback()
	end
	return unpack(self, 1, self.n)
end

function Option.unwrapOrNil<T>(self: Option<T>): T?
	return self[1] :: any
end

function Option.inspect<T...>(self: Option<T...>, inspector: (T...) -> ())
	if self.n ~= 0 then
		inspector(unpack(self, 1, self.n))
	end
	return self
end

function Option.map<T..., U...>(self: Option<T...>, map: (T...) -> U...): Option<U...>
	if self.n == 0 then
		return Option.None
	end
	return Option.Some(map(unpack(self, 1, self.n))) :: any
end

function Option.mapOr<T..., U...>(self: Option<T...>, map: (T...) -> U..., ...: U...): U...
	if self.n == 0 then
		return ...
	end
	return map(unpack(self, 1, self.n))
end

function Option.mapOrElse<T..., U...>(self: Option<T...>, map: (T...) -> U..., fallback: () -> U...): U...
	if self.n == 0 then
		return fallback()
	end
	return map(unpack(self, 1, self.n))
end

function Option.andOption<T...>(self: Option<T...>, other: Option<T...>): Option<T...>
	return if self.n == 0 or other.n == 0 then Option.None else other
end

function Option.andThen<T..., U...>(self: Option<T...>, map: (T...) -> Option<U...>): Option<U...>
	return if self.n == 0 then Option.None else map(unpack(self, 1, self.n))
end

function Option.filter<T..., U...>(self: Option<T...>, predicate: (T...) -> boolean): Option<T...>
	return if self.n ~= 0 and predicate(unpack(self, 1, self.n)) then self else Option.None
end

function Option.orOption<T...>(self: Option<T...>, other: Option<T...>): Option<T...>
	return if self.n == 0 then other else self
end

function Option.orElse<T...>(self: Option<T...>, fallback: () -> Option<T...>): Option<T...>
	return if self.n == 0 then fallback() else self
end

function Option.xor<T...>(self: Option<T...>, other: Option<T...>): Option<T...>
	return if self.n == 0 then other elseif other.n == 0 then self else Option.None
end

-- TODO: Option.set
-- TODO: Option.getOrSet
-- TODO: Option.push
-- TODO: Option.getOrPush
-- TODO: Option.pop
-- TODO: Option.remove
-- TODO: Option.take
-- TODO: Option.takeIf
-- TODO: Option.replace
-- TODO: Option.flatten
-- The above methods will almost certainly require None being a constructor </3
-- This may need to be abstracted into an OptionMut class

local function noop() end

function Option.__tostring(self: AnyOption)
	if self.n == 0 then
		return "Option.None"
	end

	-- TODO: format the inner values
	return `Option.Some`
end

function Option.__eq<T>(self: Option<T>, other: Option<T>)
	if Option.is(other) then
		if self.n == 0 and other.n == 0 then
			return true
		elseif self.n == 1 and other.n == 1 then
			return self[1] == other[1]
		elseif self.n == other.n then
			for i = 1, self.n do
				if self[i] ~= other[i] then
					return false
				end
			end
			return true
		end
	end
	return false
end

function Option.__iter<T>(self: Option<T>): () -> T?
	if self.n == 0 then
		return noop
	end

	local i = 0
	return function()
		i += 1
		if i <= self.n then
			return self[i]
		end
		return
	end
end

table.freeze(Option)
return Option
