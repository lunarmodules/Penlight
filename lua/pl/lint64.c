/*
* lint64.c
* int64 nummbers for Lua
* Luiz Henrique de Figueiredo <lhf@tecgraf.puc-rio.br>
* Thu Aug  1 22:56:17 BRT 2013
* This code is hereby placed in the public domain.
*/

#include <stdlib.h>

#define Int             long long

#include "lua.h"
#include "lauxlib.h"

#define MYNAME          "int64"
#define MYTYPE          MYNAME
#define MYVERSION       MYTYPE " library for " LUA_VERSION " / Aug 2013"

#define Z(i)            Pget(L,i)
#define O(i)            luaL_optnumber(L,i,0)

#define add(z,w)        ((z)+(w))
#define sub(z,w)        ((z)-(w))
#define mul(z,w)        ((z)*(w))
#define div(z,w)        ((z)/(w))
#define neg(z)          (-(z))
#define new(z)          (z)

static Int Pget(lua_State *L, int i)
{
 switch (lua_type(L,i))
 {
  case LUA_TNUMBER:
   return luaL_checkint(L,i);
  case LUA_TSTRING:
   return atoll(luaL_checkstring(L,i));
  default:
   return *((Int*)luaL_checkudata(L,i,MYTYPE));
 }
}

static int pushInt(lua_State *L, Int z)
{
 Int *p=lua_newuserdata(L,sizeof(Int));
 *p=z;
 luaL_setmetatable(L,MYTYPE);
 return 1;
}

static int Leq(lua_State *L)                    /** __eq(z,w) */
{
 lua_pushboolean(L,Z(1)==Z(2));
 return 1;
}

static int Llt(lua_State *L)                    /** __lt(z,w) */
{
 lua_pushboolean(L,Z(1)<Z(2));
 return 1;
}

static int Ltostring(lua_State *L)              /** __tostring(z) */
{
 char b[100];
 sprintf(b,"%lld",Z(1));
 lua_pushstring(L,b);
 return 1;
}

#define A(f,e)  static int L##f(lua_State *L) { return pushInt(L,e); }
#define B(f)    A(f,f(Z(1),Z(2)))
#define F(f)    A(f,f(Z(1)))

B(add)                  /** __add(z,w) */
B(div)                  /** __div(z,w) */
B(mul)                  /** __mul(z,w) */
B(sub)                  /** __sub(z,w) */
F(neg)                  /** __unm(z) */
F(new)                  /** new(z) */

static const luaL_Reg R[] =
{
        { "__add",      Ladd    },
        { "__div",      Ldiv    },
        { "__eq",       Leq     },
        { "__lt",       Llt     },
        { "__mul",      Lmul    },
        { "__sub",      Lsub    },
        { "__unm",      Lneg    },
        { "__tostring", Ltostring},
        { "new",        Lnew    },
        { NULL,         NULL    }
};

LUALIB_API int luaopen_int64(lua_State *L)
{
 if (sizeof(Int)!=8) luaL_error(L,"Int has %d bytes but expected 8",sizeof(Int));
 luaL_newmetatable(L,MYTYPE);
 luaL_setfuncs(L,R,0);
 lua_pushliteral(L,"version");                  /** version */
 lua_pushliteral(L,MYVERSION);
 lua_settable(L,-3);
 lua_pushliteral(L,"__index");
 lua_pushvalue(L,-2);
 lua_settable(L,-3);
 return 1;
}
