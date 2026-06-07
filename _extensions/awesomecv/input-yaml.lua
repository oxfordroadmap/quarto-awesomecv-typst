local function parse_yaml(content)
    local data = {}
    local item = {}
    local in_details = false
    
    for line in content:gmatch("[^\r\n]+") do
        local line_trimmed = line:gsub("^%s+", ""):gsub("%s+$", "") -- trim whitespace
        local indent_level = #(line:match("^%s*") or "")
        
        if line_trimmed == "" then
            -- Skip empty lines
        elseif indent_level == 0 and line_trimmed:match("^[%w_-]+:$") then
            -- New entry starts, save the previous one if it exists
            if next(item) then
                table.insert(data, item)
            end
            item = {}
            in_details = false
        -- ==========================================
        -- ADDED: Explicitly catch the proportion field 
        -- ==========================================
        elseif indent_level > 0 and line_trimmed:match("^proportion:%s*(.+)") then
            item.proportion = line_trimmed:match("^proportion:%s*(.+)")
        elseif indent_level > 0 and line_trimmed:match("^title:%s*(.+)") then
            item.title = line_trimmed:match("^title:%s*(.+)")
        elseif indent_level > 0 and line_trimmed:match("^location:%s*(.+)") then
            item.location = line_trimmed:match("^location:%s*(.+)")
        elseif indent_level > 0 and line_trimmed:match("^date:%s*(.+)") then
            item.date = line_trimmed:match("^date:%s*(.+)")
        elseif indent_level > 0 and line_trimmed:match("^description:%s*(.+)") then
            item.description = line_trimmed:match("^description:%s*(.+)")
        -- ==========================================
        -- SAFE INSERT: Explicitly catch the DOI field 
        -- ==========================================
        elseif indent_level > 0 and line_trimmed:match("^doi:%s*(.+)") then
            item.doi = line_trimmed:match("^doi:%s*(.+)")
        -- ==========================================
        elseif indent_level > 0 and line_trimmed:match("^details:%s*$") then
            item.details = {}
            in_details = true
        elseif in_details and line:match("^%s*-%s*(.+)") then
            local detail = line:match("^%s*-%s*(.+)")
            table.insert(item.details, detail)
        elseif in_details and indent_level > 0 and not line:match("^%s*-%s*") then
            in_details = false
        end
    end
    
    -- Add the last item
    if next(item) then
        table.insert(data, item)
    end
    
    return data
end

local function construct_entry(data)
    local typst_code = {}

    local entries = data or {}
    
    for _, item in ipairs(entries) do
        local entry_parts = {}
        table.insert(entry_parts, "#resume-entry(")

        -- ==========================================
        -- ADDED: Forward proportion if it exists, else let Typst default handle it
        -- ==========================================
        if item.proportion then
            table.insert(entry_parts, '  proportion: ' .. tostring(item.proportion) .. ',')
        end
        -- ==========================================-- Add title
        if item.title then
            table.insert(entry_parts, '  title: [' .. tostring(item.title).. '],')
        else
            table.insert(entry_parts, '  title: none,')
        end
        
        -- Add location
        if item.location then
            table.insert(entry_parts, '  location: [' .. tostring(item.location).. '],')
        else
            table.insert(entry_parts, '  location: none,')
        end
        
        -- Add date
        if item.date then
            table.insert(entry_parts, '  date: [' .. tostring(item.date).. '],')
        else
            table.insert(entry_parts, '  date: none,')
        end
        
        -- Add description
        if item.description then
            table.insert(entry_parts, '  description: [' .. tostring(item.description).. '],')
        else
            table.insert(entry_parts, '  description: none,')
        end
        
        -- ADDED: Append doi explicitly into the Typst function argument list
        if item.doi then
            -- Strips accidental quotes if present in raw yaml string mapping
            local clean_doi = tostring(item.doi):gsub('^"', ''):gsub('"$', ''):gsub("^'", ""):gsub("'$", "")
            table.insert(entry_parts, '  doi: "' .. clean_doi .. '",')
        else
            table.insert(entry_parts, '  doi: none,')
        end

        table.insert(entry_parts, ")")
        
        -- Add details if present
        if item.details and type(item.details) == "table" then
            table.insert(entry_parts, "#resume-item[")
            if #item.details > 0 then
                -- Array
                for _, detail in ipairs(item.details) do
                    table.insert(entry_parts, "  - " .. tostring(detail))
                end
            else
                -- Dictionary
                for _, detail in pairs(item.details) do
                    table.insert(entry_parts, "  - " .. tostring(detail))
                end
            end
            table.insert(entry_parts, "]")
        end
        
        table.insert(typst_code, table.concat(entry_parts, "\n"))
    end
    
    return table.concat(typst_code, "\n\n")
end

function yaml(args)
    local file_path = args[1]
    if not file_path then
        error("yaml shortcode requires a file path argument")
    end

    -- Read YAML file
    local file = io.open(file_path, "r")
    if not file then
        error("Could not open file: " .. file_path)
    end
    local text_yaml = file:read("*all")
    file:close()
    
    -- Convert YAML to Typst
    local data = parse_yaml(text_yaml)
    local code_typst = construct_entry(data)
    return pandoc.RawInline('typst', code_typst)
end