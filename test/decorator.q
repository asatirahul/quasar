\l src/decorator.q
/ chnf@' (`.test.f;`..f;`...u;`f;`f.r;`.tt.ff.r)

.tst.desc[".qudec.chkName : Validates function naming style"]{
  should["Accept Fully qualified name"]{
   11b mustmatch .qudec.chkName@' `.test.f`..f;
    };
  should["Throw Error for non valid names-1"]{
    mustthrow["not a fully qualified function name"; (`.qudec.chkName;`f)];
    };
  should["Throw Error for non valid names-2"]{
    mustthrow["not a fully qualified function name"; (`.qudec.chkName;`...f)];
    };
  };

.tst.desc[".qudec.getName: Check if internal function name is correctly generated"]{
  should["Generate correct name"]{
    "_test_f" mustmatch .qudec.getName `.test.f;
    "__f" mustmatch .qudec.getName `..f;
   };
 };
 /should["Throw error for non supported function types"]{
  / mustthrow["Function type not supported";(`.qudec.getName;{x})]
  /};
