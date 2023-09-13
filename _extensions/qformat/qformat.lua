-- Import the 'lpeg' module, required for the `gsub_lpeg()` function defined below 
local lpeg = require("lpeg")

-- Define lpeg-based function to effectively replace `string.gsub()`
local function gsub_lpeg(string, pattern, replacement)
  pattern = lpeg.P(pattern)
  pattern = lpeg.Cs((pattern / replacement + 1) ^ 0)
  return lpeg.match(pattern, string)
end

local function strsplit(string, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    for substr in string.gmatch(string, pattern) do
      table.insert(result, substr)
    end
    return result
  end

-- Function to detects a match in a string via a pattern
local function grepl(string, pattern)
  return string.match(string, pattern) ~= nil
end

-- Function for checking whether a particular value is nil or an empty string
local function is_empty(value)
    return value == nil or value == ''
end

-- Function for checking whether a particular value is an element within a table
local function in_table(val, table)
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

-- Function for arg-parsing; works with `args` or `kwargs`
local function parse_arg(to_check, key)
    value = pandoc.utils.stringify(to_check[key])
    if not is_empty(value) then
        return value
    else
        return nil
    end
end

-- Function for rounding a number
local function round_num(num)
    return math.floor(num + 0.5)
end

return {
    ["qformat"] = function(args, kwargs)

        local fmt_type = "auto"
        local formatted = ""
        local decimals = tonumber("2")

        -- Count the number of args
        n_args = #args

        -- If the number of args is greater than two then that's an error
        if n_args > 2 then
            return "[ qformat errcode #01: Can't have more than two args. ]"
        end

        -- If the number of args is zero then that's also an error
        if n_args == 0 then
            return "[ qformat errcode #02: You must provide some args (up to two). ]"
        end

        -- The last arg is assumed to be the value to format
        local value = parse_arg(args, n_args)

        -- If there are two args then set the `fmt_type`
        if n_args == 2 then
            first_arg = parse_arg(args, 1)

            is_valid_type = in_table(first_arg, {"num", "int", "sci", "auto"})

            if in_table(first_arg, {"num", "int", "sci", "auto"}) then
                fmt_type = tostring(first_arg)
            end

            print("format type is: " .. fmt_type)
        end

        -- Change `value` to a number (from a string)
        local value = tonumber(value)

        -- Determine if a format string is supplied
        local fmt_str = parse_arg(kwargs, "fmt")

        if fmt_type == "auto" then

            if fmt_str ~= nil then
                formatted = tostring(string.format(fmt_str, value))
            else
                formatted = tostring(value)
            end

        elseif fmt_type == "num" then

            dec_arg = parse_arg(kwargs, "dec")

            if dec_arg ~= nil then
                decimals = tonumber(parse_arg(kwargs, "dec"))
            end

            -- Generate a formatting string (using 'f' for floating point format)
            fmt_str = "%." .. decimals .. "f"
            
            -- Format the value and cast to a string
            formatted = tostring(string.format(fmt_str, value))

        elseif fmt_type == "int" then

            -- Round and truncate the value, then, cast to a string
            formatted = tostring(math.floor(round_num(value)))

        elseif fmt_type == "sci" then

            dec_arg = parse_arg(kwargs, "dec")

            if dec_arg ~= nil then
                decimals = tonumber(parse_arg(kwargs, "dec"))
            end

            -- Generate a formatting string (using 'e' for exponential format)
            fmt_str = "%." .. decimals .. "e"

            -- Format the value and cast to a string
            formatted = tostring(string.format(fmt_str, value))
            
            -- If the string 'e+00' appears in `formatted`, remove that portion of the formatted value
            if grepl(formatted, "e%+00$") then
                formatted = gsub_lpeg(formatted, "e+00", "")
            end

            -- Split the `formatted` string across the 'e' to get `num_val` and `exp_val` parts;
            -- This is eventually generated better formatting in scientific notation across different output
            splits = strsplit(formatted, "e")

            -- It may happen that we receive only a single element in `splits` (in the case where 'e+00'
            -- was present and then removed); in that case this portion of code is essentially disregarded
            -- since just having a number part will print just fine in HTML and LaTeX
            if splits[2] then

                num_val = splits[1]
                exp_val = splits[2]

                if quarto.doc.is_format("html:js") then
                  formatted = pandoc.RawInline("html", num_val .. " \u{00D7} " .. "10<sup style='font-size: 65%;'>" .. tonumber(exp_val) .. "</sup>")
                elseif quarto.doc.is_format("pdf") then
                  formatted = pandoc.RawInline("tex", num_val .. " \\times 10^{ " .. tonumber(exp_val) .. "}")
                end
            end
        end

        return formatted
    end
}
