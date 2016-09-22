
terralib.includepath = terralib.includepath..";/usr/include/bash/"

C = terralib.includecstring [[
#include <config.h>

#if defined (HAVE_UNISTD_H)
#  include <unistd.h>
#endif

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
	"hello",		/* builtin name */
	hello_builtin_p,	/* function implementing the builtin */
	BUILTIN_ENABLED,	/* initial flags for builtin */
	hello_doc,		/* array of long documentation strings. */
	"hello",		/* usage synopsis; becomes short_doc */
	0			/* reserved for internal use */
};

]]





terra hello_builtin(list : C.WORD_LIST)
    -- Here we call a C function from Terra
    C.printf("Hello, Terra!\n")
    return 0
end



C.hello_builtin_p=hello_builtin --this dosent hurt, but it still works for me if this is not here

terralib.saveobj("hello.so","sharedlibrary",{ hello_builtin_p = hello_builtin, hello_struct=C.hello_struct }, {})
