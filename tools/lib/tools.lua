local tools = {}

function tools.test()
    return 4712
end

function tools.compressSlots()
    io.write("Compressing... ")
  
    local items = {}
    local empty = {}
    -- local items_count = {}
    -- local items_maxSize = {}
    -- local items_full = {}
    for slot = 1, 16 do
        local slot_info = component.inventory_controller.getStackInInternalSlot(slot)
        if not slot_info then
            table.insert(empty, slot)
        else
            local item = {maxCount = slot_info.maxSize, 
                          full={},
                          partial={},
                          }
            if not items[slot_info.label] then
                items[slot_info.label] = item
            else
                item = items[slot_info.label]
            end
            
            if (slot_info.maxSize - slot_info.size == 0) then
                table.insert(item.full, slot)
            else
                table.insert(item.partial, {slot=slot, count=slot_info.size})
            end
        end
    end
    -- print(serialization.serialize(items))

    for k, v in pairs(items) do
        while #v.partial > 1 do
            -- best first
            table.sort(v, function(a, b) return a.count > b.count end )
            local current = table.remove(v.partial, 1)
            

            
            local missing = v.maxCount - current.count
            -- print("missing", k, missing)
            
            table.sort(v, function(a, b) return a.count < b.count end ) -- small count first
            local other = table.remove(v.partial, 1)
            
            
            local transfer = math.min(missing, other.count)
            -- print("transfer"..k, current.slot, other.slot, missing)
            os.sleep(1)
            if not robot.select(other.slot) then error("select failed") end
            if not robot.transferTo(current.slot, transferr) then 
                error("transferTo failed: "..tostring(current.slot)) 
            end
            
            current.count = current.count + transfer
            other.count = other.count - transfer
            
            if current.count < v.maxCount then
                table.insert(v.partial, current)
            else
                table.insert(v.full, current.slot)
            end
            if other.count > 0 then
                table.insert(v.partial, other)
            end
            
        end
    end
    print("Done!")
    for k, v in pairs(items) do
        assert(#v.partial <= 1)
        v.partial = v.partial[1]
    end
    return {items=items, empty=empty}
end



return tools