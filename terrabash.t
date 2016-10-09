
terralib.includepath = terralib.includepath..";/usr/include/bash/;/opt/terra-Linux-x86_64-332a506/include/"

local C = terralib.includecstring([[
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
#include "luajit-2.0/lua.h"
#include "luajit-2.0/lauxlib.h"
#include "luajit-2.0/lualib.h"
#include "terra/terra.h"
int terrabash_builtin_p (WORD_LIST*);


char *terrabash_doc[] = {
        "terra runtime enviornment and compiler.",
        "",
        "this builtin embeds terra, lua, and clang in your bash session",
        (char *)NULL
};


struct builtin terrabash_struct = {
        "terrabash",                /* builtin name */
        terrabash_builtin_p,        /* function implementing the builtin */
        BUILTIN_ENABLED,        /* initial flags for builtin */
        terrabash_doc,              /* array of long documentation strings. */
        "terrabash",                /* usage synopsis; becomes short_doc */
        0                       /* reserved for internal use */
};


]])




local struct LUA {
  L : &C.lua_State;
}

local LU = terralib.global(LUA) 

terra init_terrabash()
  LU.L=C.luaL_newstate()
  if LU.L == nil then
    C.printf("can't initialize luajit\n")
  end
  C.luaL_openlibs(LU.L)
  C.terra_init(LU.L)
end

terra do_tstring(s: &int8)
  C.terra_loadstring(LU.L, s)   
  C.lua_pushnumber(LU.L,1)
  C.lua_call(LU.L,1,1)
  C.luaL_checknumber(LU.L,-1)   
end

terra terrabash_builtin_p(list : &C.WORD_LIST)
  var cmd = list.word.word
  C.printf("word list: \n%s\n",cmd )
  init_terrabash()
  do_tstring([[ a = ...; C = terralib.includec("stdio.h"); terra foo () C.printf("new terra %d\n",a) return a end; return foo() ]])
  C.printf("terrabash terra/lua!")
  return 0
end


local exports = {}
exports.terrabash_builtin_p=terrabash_builtin_p
exports.init_terrabash=init_terrabash
exports.do_tstring=do_tstring
exports.terrabash_struct=C.terrabash_struct
exports.LU=LU

terralib.saveobj("terrabash.so","sharedlibrary",exports,{"-L/opt/terra-Linux-x86_64-332a506/lib/", "-lluajit-5.1", "-lterra", "-lstdc++", "-lpthread" } )


