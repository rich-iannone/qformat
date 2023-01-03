local interpolate = function(str, vars)
    -- Allow replace_vars{str, vars} syntax as well as replace_vars(str, {vars})
    if not vars then
        vars = str
        str = vars[1]
    end
    return (string.gsub(str, "({([^}]+)})",
        function(whole, i)
            return vars[i] or whole
        end))
end

local function isEmpty(s)
    return s == nil or s == ''
end

-- Function for checking membership of a supposed element value in a table
function table.contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
  end

function round_num(num)
    return math.floor(num + 0.5)
end

return {
    ["qformat"] = function(args, kwargs)

        checkArg = function(toCheck, key)
            value = pandoc.utils.stringify(toCheck[key])
            if not isEmpty(value) then
                return value
            else
                return nil
            end
        end

        -- Obtain the first argument, which might
        local fmt_type = args[1]
        
        -- If there is nothing there then return nil
        if fmt_type == nil then
            return nil
        end

        -- Define a set of valid subcommands for specialized formatting
        local subcommands = {"num", "int"}

        --[[
            Check whether this first argument is in the set of `subcommands`; if not then
            we assume that we will do simple number formatting with the number first
            and a Lua formatting string after that
        ]]
        if not table.contains(subcommands, fmt_type) then

            -- Check if there are at least two args, return warning statement and code if untrue
            if #args < 2 then
                return "[ qformat errcode #20: Need at least two args for simple formatting. ]"
            end

            local value = tonumber(pandoc.utils.stringify(args[1]))
            local fmt_str = pandoc.utils.stringify(args[2])

            local val_str = string.format(fmt_str, value)

            return tostring(val_str)
            
        end

        return fmt_type

    end
}
