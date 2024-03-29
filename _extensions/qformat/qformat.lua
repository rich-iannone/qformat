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
    local value = pandoc.utils.stringify(to_check[key])
    if not is_empty(value) then
        return value
    else
        return nil
    end
end

local function parse_boolean_kwarg(kwargs, key)

    local kwarg_val = parse_arg(kwargs, key)

    if kwarg_val == nil then
        return nil
    end

    kwarg_val = string.lower(kwarg_val)

    if in_table(kwarg_val, {"yes", "true"}) then
        return true
    else
        return false
    end
end

-- Function for rounding a number
local function round_num(num)
    return math.floor(num + 0.5)
end

local function format_number_with_separators(number, sep)
    local formatted_number = tostring(number)
    local dp = (string.find(formatted_number, "%.") or #formatted_number + 1) - 1
    for i = dp - 3, 1, -3 do
        formatted_number = formatted_number:sub(1, i) .. sep .. formatted_number:sub(i + 1)
    end
    return formatted_number
end

return {
    ["qformat"] = function(args, kwargs)

        local fmt_type = "auto"
        local formatted = ""

        -- Count the number of args
        local n_args = #args

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
            local first_arg = parse_arg(args, 1)
            if in_table(first_arg, {"num", "int", "sci", "auto"}) then
                fmt_type = tostring(first_arg)
            end
        end

        -- Change `value` to a number (from a string)
        local value = tonumber(value)
        local is_negative = value < 0

        if is_negative and type(value) == "number" then
            value = math.abs(value)
        end

        -- Parse kwargs for `use_seps`
        local use_seps = parse_boolean_kwarg(kwargs, "use_seps")
        if use_seps == nil then
            use_seps = true
        end

        -- Parse kwargs for `decimals`
        local decimals = parse_arg(kwargs, "decimals")
        if decimals == nil then
            decimals = 2
        else
            decimals = tonumber(decimals)
        end

        -- Parse kwargs for `sep_mark`
        local sep_mark = parse_arg(kwargs, "sep_mark")
        if sep_mark == nil then
            sep_mark = ","
        end

        -- Parse kwargs for `dec_mark`
        local dec_mark = parse_arg(kwargs, "dec_mark")
        if dec_mark == nil then
            dec_mark = "."
        end

        -- Parse kwargs for `pattern`
        local pattern = parse_arg(kwargs, "pattern")

        -- Determine if a format string is supplied
        local fmt_str = parse_arg(kwargs, "fmt")

        if fmt_type == "auto" then

            if fmt_str ~= nil then
                formatted = tostring(string.format(fmt_str, value))
            else
                formatted = tostring(value)
            end

        elseif fmt_type == "num" then

            -- Generate a formatting string (using 'f' for floating point format)
            fmt_str = "%." .. decimals .. "f"

            -- Format the value and cast to a string
            formatted = tostring(string.format(fmt_str, value))

            -- Ensure that digit-grouping separators are included as placeholders
            if use_seps then
                formatted = format_number_with_separators(formatted, "|")
            end

            -- Replace the decimal mark if required
            if dec_mark ~= "." then
                formatted = gsub_lpeg(formatted, ".", dec_mark)
            end

            -- Replace digit-grouping separator placeholders with `sep_mark`
            if (sep_mark == "space") then
                formatted = gsub_lpeg(formatted, "|", " ")
            else
                formatted = gsub_lpeg(formatted, "|", sep_mark)
            end

            -- Use the negative sign appropriate to the output context
            if is_negative then
                if quarto.doc.is_format("html:js") then
                    formatted = pandoc.RawInline("html", "\u{2212}" .. formatted)
                end
            end

        elseif fmt_type == "int" then

            -- Round and truncate the value, then, cast to a string
            formatted = tostring(math.floor(round_num(value)))

            -- Ensure that digit-grouping separators are included as placeholders
            if use_seps then
                formatted = format_number_with_separators(formatted, "|")
            end

            -- Replace digit-grouping separator placeholders with `sep_mark`
            if (sep_mark == "space") then
                formatted = gsub_lpeg(formatted, "|", " ")
            else
                formatted = gsub_lpeg(formatted, "|", sep_mark)
            end

            -- Use the negative sign appropriate to the output context
            if is_negative then
                if quarto.doc.is_format("html:js") then
                    formatted = pandoc.RawInline("html", "\u{2212}" .. formatted)
                end
            end

        elseif fmt_type == "sci" then

            -- Generate a formatting string (using 'e' for exponential format)
            fmt_str = "%." .. decimals .. "e"

            -- Format the value and cast to a string
            formatted = tostring(string.format(fmt_str, value))

            -- If the string 'e+00' appears in `formatted`, remove that portion of the formatted value
            if grepl(formatted, "e%+00$") then
                formatted = gsub_lpeg(formatted, "e+00", "")
            end

            -- Replace the decimal mark if required
            if dec_mark ~= "." then
                formatted = gsub_lpeg(formatted, ".", dec_mark)
            end

            -- Split the `formatted` string across the 'e' to get `num_val` and `exp_val` parts;
            -- This is eventually generated better formatting in scientific notation across different output
            local splits = strsplit(formatted, "e")

            -- It may happen that we receive only a single element in `splits` (in the case where 'e+00'
            -- was present and then removed); in that case this portion of code is essentially disregarded
            -- since just having a number part will print just fine in HTML and LaTeX
            if splits[2] then

                local num_val = splits[1]
                local exp_val = splits[2]

                if quarto.doc.is_format("html:js") then
                  formatted = pandoc.RawInline("html", num_val .. " \u{00D7} " .. "10<sup style='font-size: 65%;'>" .. tonumber(exp_val) .. "</sup>")
                elseif quarto.doc.is_format("pdf") then
                  formatted = pandoc.RawInline("tex", num_val .. " \\times 10^{ " .. tonumber(exp_val) .. "}")
                end
            end
        end

        -- If a `pattern` value was provided then substitute the '{x}' in the
        -- pattern with the `formatted` value with `gsub_lpeg()`
        if pattern then
            formatted = gsub_lpeg(pattern, "{x}", formatted)
        end

        return formatted
    end
}
