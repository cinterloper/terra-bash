--a great deal of the c and inspriration comes from https://github.com/masterkorp/LuaBash
terralib.includepath = terralib.includepath..";/usr/include/bash/;/usr/lib/llvm-3.8/terra/build/include/"

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
#include "luajit-2.1/lua.h"
#include "luajit-2.1/lauxlib.h"
#include "luajit-2.1/lualib.h"
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



 int inject_new_builtin (struct builtin* b)
{
  struct builtin* old_builtin;

  b->flags |= STATIC_BUILTIN;
  /*if (flags & SPECIAL)
    b->flags |= SPECIAL_BUILTIN;*/
   
  if ( (old_builtin = builtin_address_internal (b->name, 1)) != 0 ) {
    memcpy ((void*) old_builtin, b, sizeof (struct builtin));
  } else {
    int total = num_shell_builtins + 1;
    int size = (total + 1) * sizeof (struct builtin);

    struct builtin* new_shell_builtins = (struct builtin*) malloc (size);
    memcpy ((void*) new_shell_builtins, (void*) shell_builtins,
	    num_shell_builtins * sizeof (struct builtin));
    memcpy ((void*) &new_shell_builtins[num_shell_builtins], (void*)b, sizeof (struct builtin));
    new_shell_builtins[total].name = (char *)0;
    new_shell_builtins[total].function = (sh_builtin_func_t *)0;
    new_shell_builtins[total].flags = 0;
      
    if (shell_builtins != static_shell_builtins)
      free (shell_builtins);

    shell_builtins = new_shell_builtins;
    num_shell_builtins = total;
    initialize_shell_builtins ();
  }

  return EXECUTION_SUCCESS;
}

 int get_variable (lua_State *L)
{
  const char* vname = luaL_checkstring(L, 1);
  lua_pushstring(L, getvar(vname));
  return 1;
}

 int set_variable (lua_State *L)
{
  const char* vname = luaL_checkstring(L, 1);
  const char* vvalue = luaL_checkstring(L, 2);
  setvar(vname, vvalue);
  return 0;
}



typedef enum { bash_version_v2, bash_version_v3, bash_version_unknown } bash_flavor;
static bash_flavor current_flavor=bash_version_unknown;


SIMPLE_COM* newSimpleCom(WORD_LIST *words)
{
  SIMPLE_COM* ret=(SIMPLE_COM*) malloc(sizeof(SIMPLE_COM));
    ret->flags=0;
    ret->line=0;
    ret->redirects=NULL;
    ret->words=words;
  return ret;
}

 int call_bashfunction (lua_State *L)
{
  int no_args=lua_gettop(L);
  int retval=0;
  int i;

  WORD_LIST* list=0;
  WORD_LIST* start=0;

  for (i=0; i<no_args; i++) {
    const char* string=luaL_checkstring(L, i+1);
    if (list) {
      list->next=(WORD_LIST*) malloc(sizeof(WORD_LIST));
      list=list -> next;
    } else {
      list=(WORD_LIST*) malloc(sizeof(WORD_LIST));
      start=list;
    }
    list->word=make_word(string);
    list->next=0;
  }

  if (!list)
    retval=127;
  else {
    SIMPLE_COM* cmd=newSimpleCom(start);
    retval=execute_command(make_command(cm_simple, cmd));
  }
  lua_pushinteger(L,retval);
  return 1;
}

 int get_environment (lua_State *L)
{
  SHELL_VAR** list=all_shell_variables();
  int i=0;

  lua_newtable(L);
  while(list && list[i]) {
    const char* key=list[i]->name;
    const char* val=list[i]->value;
    lua_pushstring(L,val);
    lua_setfield(L,-2,key);
    i++;
  }

  return 1;
}



 int register_function (lua_State *L)
{
  const char* fnname = luaL_checkstring(L, 1);

  // old code using aliases
  //const char* fmt="luabash call %s ";
  //char* fullname=(char*) malloc(strlen(fmt)+strlen(fnname));
  //sprintf(fullname, fmt, fnname);
  //add_alias(fnname, fullname);

  WORD_LIST* wluabash=(WORD_LIST*) malloc(sizeof(WORD_LIST));
  WORD_LIST* wcall=(WORD_LIST*) malloc(sizeof(WORD_LIST));
  WORD_LIST* wfnname=(WORD_LIST*) malloc(sizeof(WORD_LIST));
  WORD_LIST* warguments=(WORD_LIST*) malloc(sizeof(WORD_LIST));
  wluabash->next = wcall;
  wcall->next=wfnname;
  wfnname->next=warguments;
  warguments->next=0;
  wluabash->word=make_word("luabash");
  wcall->word=make_word("call");
  wfnname->word=make_word(fnname);
  warguments->word=make_word("$@");

  SIMPLE_COM* call_luabash=newSimpleCom(wluabash);

  COMMAND* function_body=make_command(cm_simple, call_luabash);
  bind_function(fnname,function_body);

  return 0;
}



]])




local struct LUA {
  L : &C.lua_State;
}

local struct WORD_DESC {
  word : &int8,
  flags : int8
} 

local struct WORD_LIST {
  next : &WORD_LIST,
  word : &WORD_DESC
}


local LU = terralib.global(LUA) 

terra init_terrabash()
  LU.L=C.luaL_newstate()
  if LU.L == nil then
    C.printf("can't initialize luajit\n")
  end
  C.luaL_openlibs(LU.L)
  C.printf("made it past lua init\n")
  C.terra_init(LU.L)
  C.printf("made it past terra init\n")
end

terra load_tstring(s: &int8)
  C.terra_loadstring(LU.L, s)   
  C.lua_pushnumber(LU.L,1)
  C.lua_pcall(LU.L,1,1,0)
  C.luaL_checknumber(LU.L,-1)   
end


terra bash_getvar( name : &int8 )
  var SHELL_VAR : &C.variable = C.find_variable(name)
  return SHELL_VAR
end

terra bash_setvar( name : &int8, value : &int8)
  return C.bind_variable(name,value,0)
end

terra load_tfile(f: &int8)
  C.terra_loadfile(LU.L, f)
  C.lua_pcall(LU.L,0,0,0)
end

terra terrabash_builtin_p(list : &WORD_LIST)
  var bashlib : &C.luaL_Reg  = [&C.luaL_Reg](C.malloc(sizeof(C.luaL_Reg)*6))  
  var entry0 : C.luaL_Reg
  var entry1 : C.luaL_Reg
  var entry2 : C.luaL_Reg
  var entry3 : C.luaL_Reg
  var entry4 : C.luaL_Reg
  var entry5 : C.luaL_Reg
  entry0.name="register"
  entry0.func=C.register_function
  bashlib[0]=entry0
  entry1.name="getVariable"
  entry1.func=C.get_variable
  bashlib[1]=entry1
  entry2.name="setVariable"
  entry2.func=C.set_variable
  bashlib[2]=entry2
  entry3.name="getEnvironment"
  entry3.func=C.get_environment
  bashlib[3]=entry3
  entry4.name="call"
  entry4.func=C.call_bashfunction
  bashlib[4]=entry4
  entry5.name=nil
  entry5.func=nil
  bashlib[5]=entry5

  init_terrabash()
  C.printf("made it past init_terrabash\n")
  C.luaL_register(LU.L,"bash",bashlib)
  if list == nil then
    C.printf("you didnt pass any args\n")
    return(0)
  end
  C.printf("made it past assert\n")
  var cmd : &int8 = list.word.word
  C.printf("made it past cmd asgnment\n")
  if C.strcmp(cmd,"load_tfile") == 0 then
    list=list.next
    load_tfile(list.word.word)
  elseif C.strcmp(cmd,"load_tstring") == 0 then
    list=list.next
    load_tstring(list.word.word)
  end
  C.printf("made it past if block\n")

  return 0
end


local exports = {}
exports.terrabash_builtin_p=terrabash_builtin_p
exports.init_terrabash=init_terrabash
exports.load_tstring=load_tstring
exports.terrabash_struct=C.terrabash_struct
exports.LU=LU

terralib.saveobj("terrabash.so","sharedlibrary",exports,{"/usr/lib/llvm-3.8/terra/build/lib/", "-lluajit-5.1", "-lterra", "-lstdc++", "-lpthread" } )


