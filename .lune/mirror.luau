local process = require("@lune/process")
local fs = require("@lune/fs")

local DELIMITER = if process.os == "windows" then "\\" else "/"
local INPUT_DIR = table.concat({ process.cwd, "game", "src", "batteries" }, DELIMITER)
local OUTPUT_DIR = table.concat({ process.cwd, "mirror" }, DELIMITER)

print(fs.readDir(table.concat({ process.cwd, "game" }, DELIMITER)))

-- TODO: setup package managers
for _, dir in fs.readDir(INPUT_DIR) do
	local out = OUTPUT_DIR .. DELIMITER .. dir
	if fs.isDir(out) then
		fs.removeDir(out)
	end

	print("Mirroring", dir, "to", out)
	fs.copy(INPUT_DIR .. DELIMITER .. dir, out)
end
