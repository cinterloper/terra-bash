-- This top-level code is plain Lua code.
function printhello()
    -- This is a plain Lua function
    print("Hello, Lua!")
end
printhello()

-- Terra is backwards compatible with C, we'll use C's io library in our example.
C = terralib.includec("stdio.h")

-- The keyword 'terra' introduces a new Terra function.
terra hello(argc : int, argv : &rawstring)
    -- Here we call a C function from Terra
    C.printf("Hello, Terra!\n")
    return 0
end

-- You can call Terra functions directly from Lua, they are JIT compiled 
-- using LLVM to create machine code
hello(0,nil)

bash.call("echo"," hello bash terra")
