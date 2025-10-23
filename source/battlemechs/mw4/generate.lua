require("lfs")

local cd = lfs.currentdir()
local template = [[// Not created by Crowbar

$modelname "battlemechs/mw4/$folder/$file.mdl"

$body "$file" "$file.smd" scale 25
$sequence reference "$file.smd"

$cdmaterials "models/battlemechs/mw4/$folder"
]]

local function generate_file(start, dir, path)
	if string.sub(path, 1, 1) == "." or string.sub(path, -3) ~= "smd" then
		return
	end

	local filename = string.sub(path, 1, -5)
	local qc_path = start .. "\\" .. filename .. ".qc"

	if lfs.attributes(qc_path, "mode") == nil then
		local contents = template

		contents = string.gsub(contents, "$file", filename)
		contents = string.gsub(contents, "$folder", dir)

		local handle = io.open(qc_path, "w")
		handle:write(contents)
		handle:close()

		print(filename)
	end
end

local function iterate_folder(dir)
	if string.sub(dir, 1, 1) == "." then
		return
	end

	local sub_directory = cd .. "\\" .. dir

	for path in lfs.dir(sub_directory) do
		generate_file(sub_directory, dir, path)
	end
end

for dir in lfs.dir(cd) do
	iterate_folder(dir)
end
