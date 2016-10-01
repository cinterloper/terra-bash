terralib.includepath = terralib.includepath..";/usr/include/bash/;/opt/terra-Linux-x86_64-332a506/include/"

local C = terralib.includecstring([[

#ifndef _WIN32
#include <pthread.h>
#endif

#include <config.h>

#if defined (HAVE_UNISTD_H)
#  include <unistd.h>
#endif

#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "builtins.h"
#include "shell.h"
#include "builtins/bashgetopt.h"

int hello_builtin_p (WORD_LIST*);

char *hello_doc[] = {
        "Sample builtin.",
        "",
        "this is the long doc for the sample hello builtin",
        (char *)NULL
};

struct builtin hello_struct = {
        "hello",                /* builtin name */
        hello_builtin_p,        /* function implementing the builtin */
        BUILTIN_ENABLED,        /* initial flags for builtin */
        hello_doc,              /* array of long documentation strings. */
        "hello",                /* usage synopsis; becomes short_doc */
        0                       /* reserved for internal use */
};




#include "luajit-2.0/lua.h"
#include "luajit-2.0/lauxlib.h"
#include "luajit-2.0/lualib.h"
#include "terra/terra.h"

]])



terra hello_builtin_p(list : C.WORD_LIST)
    -- Here we create a new terra instance and execute a code snippet
  var L = C.luaL_newstate();
  if L == nil then
    C.printf("can't initialize luajit\n")
  end
  
  C.luaL_openlibs(L)
  C.terra_init(L)
  C.terra_loadstring(L, [[ a = ...; C = terralib.includec("stdio.h"); terra foo () C.printf("new terra %d\n",a) return a end; return foo() ]])
  C.lua_pushnumber(L,1)
  C.lua_call(L,1,1)
  C.luaL_checknumber(L,-1)
  C.lua_close(L)
  C.printf("hello terra/lua!")
  return 0
end
terralib.saveobj("hello-mt.so","sharedlibrary",{ hello_builtin_p = hello_builtin_p,  hello_struct=C.hello_struct }, {"-L/opt/terra-Linux-x86_64-332a506/lib/", "-lluajit-5.1", "-lterra", "-lstdc++", "-lpthread" } )

