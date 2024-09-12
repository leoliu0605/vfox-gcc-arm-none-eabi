local util = require("util")

--- Return all available versions provided by this plugin
--- @param ctx table Empty table used as context, for future extension
--- @return table Descriptions of available versions and accompanying tool descriptions
function PLUGIN:Available(ctx)
    local cacheArg = util:hasValue(ctx.args, "--no-cache")
    if cacheArg then
        util:clearCache()
    end
    return util:fetchAvailable()
end
