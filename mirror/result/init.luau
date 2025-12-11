type Pack<T = any> = { n: number, [number]: T }

local Result = {}
Result.__index = Result

export type Result<T, E> = typeof(setmetatable({} :: { _ok: boolean, _value: T, _err: E }, Result))

function Result.ok<T>(value: T): Result<T, any>
	return table.freeze(setmetatable({ _ok = true, _value = value }, Result))
end

function Result.err<E>(value: E): Result<any, E>
	return table.freeze(setmetatable({ _ok = false, _err = value }, Result))
end

function Result.try<T, Args...>(failable: (Args...) -> T, ...: Args...): Result<T, any>
	local ok, value = pcall(failable, ...)
	return table.freeze(setmetatable({ _ok = ok, [ok and "_value" or "_err"] = value }, Result))
end

function Result.is(x: any)
	return type(x) == "table" and getmetatable(x) == Result
end

function Result.isOk(self: Result<any, any>)
	return self._ok
end

function Result.isOkAnd<T>(self: Result<T, any>, predicate: (T) -> boolean)
	return self._ok and predicate(self._value)
end

function Result.isErr(self: Result<any, any>)
	return not self._ok
end

function Result.isErrAnd<E>(self: Result<any, E>, predicate: (E) -> boolean)
	return not self._ok and predicate(self._err)
end

function Result.map<T, E, U>(self: Result<T, E>, map: (T) -> U): Result<U, E>
	return if self._ok then Result.ok(map(self._value)) else self :: any
end

function Result.mapOr<T, U>(self: Result<T, any>, fallback: U, map: (T) -> U): U
	return if self._ok then map(self._value) else fallback
end

function Result.mapOrElse<T, U>(self: Result<T, any>, fallback: () -> U, map: (T) -> U): U
	return if self._ok then map(self._value) else fallback()
end

function Result.mapErr<T, E, U>(self: Result<T, any>, map: (E) -> U): Result<T, U>
	return if self._ok then self else Result.err(map(self._err))
end

table.freeze(Result)
return Result
