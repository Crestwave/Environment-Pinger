

-- XOR cipher.
-- We can count up to 256
-- Valid interval: (32;255]

local function HashString(s,hash_length)
    local p1 = 5
    local p2 = 11
    local modulus = p1*p2
    hash_length = hash_length or 8
    local hash = 10^(hash_length-1)
    for i = 1, #s do
        local num = (string.byte(s:sub(i,i))^p1) % modulus
        hash = hash + num^hash_length
    end
    if hash > 10^hash_length or hash < 10^(hash_length-1) then
        hash = (hash % 10^(hash_length-1) + 10^(hash_length-1))
    end
    return hash
end

local function toBits(num,forced_size)
    local bits_reversed = {}
    
    while num > 0 do
        local bit = num%2
        bits_reversed[#bits_reversed+1] = bit
        num = math.floor(num/2)
    end
    
    local bits = {}
	for i = #bits_reversed,1,-1 do table.insert(bits,bits_reversed[i]) end
    if forced_size then
        while forced_size > #bits do
            table.insert(bits,1,"0") 
        end
    end
    return table.concat(bits)
end


local function toDec(bits)

    local bit_size = #bits
    local binary_map = {}
    for bin = bit_size-1,0,-1 do
        table.insert(binary_map,2^bin)
    end

    local dec = 0
    local counter = 1
	for bit in bits:gmatch(".") do
        if bit == "1" then
           dec = dec+binary_map[counter] 
        end
        counter = counter+1
    end

	return dec
end

local function xor(a,b)
    return bit.bxor(a,b)
end


--Encryption and Decryption Algorithm for XOR
local function E(str,cipher)
    cipher = tonumber(cipher) and cipher or "10010001"
    local byte_list = {}
    --Characters to bytes
    for char in str:gmatch(".") do
       table.insert(byte_list,string.byte(char))
    end
    local xor_list = {}
    for _,num in pairs(byte_list) do
    --Bytes to numbers
        local cipher_num = toDec(cipher)
    --Numbers to XOR
        local num_xor = xor(num,cipher_num)

       local char = string.char(num_xor)
       table.insert(xor_list,char)
    end
    return table.concat(xor_list,"")
end

return {
    E = E,
    toBits = toBits,
    toDec = toDec,
    HashString = HashString,
}