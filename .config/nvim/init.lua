local ok, mod = pcall(require, "work-config")
if ok then
  -- ./lua/work-config.lua exists! use `mod` here
end

require("maxmckel")
require("custom-commands")
