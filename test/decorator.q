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
    "__test__f" mustmatch .qudec.getName `.test.f;
    "____f" mustmatch .qudec.getName `..f;
   };
 };

.tst.desc[".qudec.DecN: Creates decorator dictionary name for a function"]{
 should["Generate correct name"]{
   (`$".qudec.__test__fw") mustmatch .qudec.getDecN "__test__f";
  };
 };

.tst.desc[".qudec.isWrapped: Checks if function is already decorated"]{
 should["Return false for non decorated function"]{
  0b mustmatch .qudec.isWrapped `.test.f;
   };
 alt{
   before {`.qudec.test.f mock {1}};
   should["Return true for  decorated function"]{
    0b mustmatch .qudec.isWrapped `.test.f;
     };
  };
  should["Return error for non supported types"]{
    mustthrow[.qudec.err["type"];(`.qudec.isWrapped;{x})];
  }
 };

.tst.desc[".qudec.normalize: Return function code"]{
  alt{
    before {`.test.f mock {1}};
    should["Return code for defined function"]{
      {1} mustmatch .qudec.normalize `.test.f;
     };
    };
  should["Supports lambda a function"]{
    {x+1} mustmatch .qudec.normalize {x+1};
  };
  should["Return error for undefined function"]{
     mustthrow[".test.f";(`.qudec.normalize;`.test.f)];
    };
  };

.tst.desc[".qudec.isNew: Checks if function code is new or decorated code"]{
  should["Return true for new function"]{
    1b mustmatch .qudec.isNew {x+1};
  };
  should["Return false for decorated function"]{
     0b mustmatch .qudec.isNew {`.qudec.__test__f 1};
  };
 };

.tst.desc[".qudec.createFunc: Create Function in qudec namespace"]{
 alt{
   after {![`.qudec;();0b;enlist `$"__test__f"]};
   should["Create function"]{
    `.qudec.__test__f mustmatch .qudec.createFunc["__test__f";{x+1};1b];
    1b mustmatch (`$"__test__f") in system "f .qudec";
    };
  };
  should["Do not create function"]{
   `.qudec.__test__f mustmatch .qudec.createFunc["__test__f";{x+1};0b];
   0b mustmatch (`$"__test__f") in system "f .qudec";
   };
 };

.tst.desc[".qudec.createDecLst: Create decorator functions list to apply"]{
  after {![`.qudec;();0b;enlist `$"__test__fw"]};
  should["Create decorator list for first call"]{
    .qudec.createDecLst["__test__f";(`.qudec.__test__f;`.test.dec);1b];
    `.qudec.__test__f`.test.dec mustmatch .qudec.__test__fw;
  };
  alt{
    before {`.qudec.__test__fw set `.qudec.__test__f`.test.dec1};
    should["Create decorator list for already wrapped function call"]{
    .qudec.createDecLst["__test__f";(`.qudec.__test__f;`.test.dec2);0b];
    `.qudec.__test__f`.test.dec1`.test.dec2 mustmatch .qudec.__test__fw;
    };
  };
 };

.tst.desc[".qudec.wrap: wrap original function and create required state"]{
  alt{
    before {`.test.f set {x+1}; `.test.g set {x . y}};
    after {![`.test;();0b; `g`f];![`.qudec;();0b; `$("__test__f";"__test__fw")];};
    should["Wrap orignal function with single wrapper function"]{
      // check conditions
      0b mustmatch (`$"__test__f") in system "f .qudec";
      0b mustmatch (`$"__test__fw") in key .qudec;
      // call function
      res: .qudec.wrap[`.test.f;`.test.g];
      expected:"{[x] (./)(`.test.g;(`.qudec.__test__f;(enlist x)))}";
      // check conditions
      res mustmatch expected
      1b mustmatch (`$"__test__f") in system "f .qudec";
      1b mustmatch (`$"__test__fw") in key .qudec;
      `.qudec.__test__f`.test.g mustmatch .qudec.__test__fw;
    };
   };
   alt{
     before {`.test.f set {[a;b]a+b}; `.test.g set {x . y};`.test.r set {x . y}};
     after {![`.test;();0b; `g`f];![`.qudec;();0b; `$("__test__f";"__test__fw")];};
     should["Wrap orignal function with multiple wrapper function and multiple input arguments"]{
       // check conditions
       0b mustmatch (`$"__test__f") in system "f .qudec";
       0b mustmatch (`$"__test__fw") in key .qudec;
       // call function
       res: .qudec.wrap[`.test.f;`.test.g`.test.r];
       expected:"{[a;b] (./)(`.test.r;(`.test.g;(`.qudec.__test__f;(a;b))))}";
       // check conditions
       res mustmatch expected
       1b mustmatch (`$"__test__f") in system "f .qudec";
       1b mustmatch (`$"__test__fw") in key .qudec;
       `.qudec.__test__f`.test.g`.test.r mustmatch .qudec.__test__fw;
     };
    };
 };

.tst.desc[".qudec.composeDec: combine wrapper functions for given target function"]{
  after {![`.qudec;();0b;enlist `$"__test__fw"]};
  alt{
   before {`.qudec.__test__fw set `.qudec.__test__f`.test.dec1};
   should["One wrapper function and one argument"]{
     expected : "(`.test.dec1;(`.qudec.__test__f;(enlist x)))";
     expected mustmatch .qudec.composeDec["__test__f";"(enlist x)"];
   };
  };
  alt{
   before {`.qudec.__test__fw set `.qudec.__test__f`.test.dec1`.test.dec2};
   should["Two wrapper functions and more than one arguments"]{
     expected : "(`.test.dec2;(`.test.dec1;(`.qudec.__test__f;(x;y))))";
     expected mustmatch .qudec.composeDec["__test__f";"(x;y)"];
   };
  };
 };

.tst.desc[".qudec.genDec: generate decorator code string for given function"]{
  before {`.qudec.__test__fw set `.qudec.__test__f`.test.dec1};
  after {![`.qudec;();0b;enlist `$"__test__fw"]};
  alt{
    before {`.qudec.__test__fw set `.qudec.__test__f`.test.dec1};
    should["Decorate with one function and inbuilt parameter"]{
      expected : "{[x] (./)(`.test.dec1;(`.qudec.__test__f;(enlist x)))}";
      expected mustmatch .qudec.genDec["__test__f";{x+1}];
    };
    should["Decorate with one function and external parameters"]{
      expected : "{[a;b;c] (./)(`.test.dec1;(`.qudec.__test__f;(a;b;c)))}";
      expected mustmatch .qudec.genDec["__test__f";{[a;b;c]a+b+c}];
    };
  };
  alt{
    before {`.qudec.__test__fw set `.qudec.__test__f`.test.dec1`.test.dec2};
    should["Decorate with two functions"]{
      expected : "{[x;y] (./)(`.test.dec2;(`.test.dec1;(`.qudec.__test__f;(x;y))))}";
      expected mustmatch .qudec.genDec["__test__f";{x+y}];
    };
  };
  should["Add default parameter `x` to function with no parameters"]{
    expected : "{[x] (./)(`.test.dec1;(`.qudec.__test__f;(enlist x)))}";
    expected mustmatch .qudec.genDec["__test__f";{2}];
  };
 };

.tst.desc[".qudec.deleteDec: Delete decorator function from list (Helper Function)"]{
  before {`.qudec.__test__fw set `.qudec.__test__f`.test.dec1`.test.dec2`.test.dec3};
  after {![`.qudec;();0b;enlist `$"__test__fw"]};
   should["Delete a wrapper function by name"]{
     .qudec.deleteDec["__test__f"; `.test.dec2];
     `.qudec.__test__f`.test.dec1`.test.dec3 mustmatch .qudec.__test__fw;
   };
   should["Delete multiple wrapper functions by name"]{
     .qudec.deleteDec["__test__f"; `.test.dec2`.test.dec3];
     `.qudec.__test__f`.test.dec1 mustmatch .qudec.__test__fw;
   };
   should["Delete last n wrapper functions"]{
     .qudec.deleteDec["__test__f"; 2];
     `.qudec.__test__f`.test.dec1 mustmatch .qudec.__test__fw;
   };
  };

.tst.desc[".qudec.removeDec: generate function code after deleting wrapper function"]{
  before {`.qudec.__test__fw set `.qudec.__test__f`.test.dec1`.test.dec2`.test.dec3};
  after {![`.qudec;();0b;enlist `$"__test__fw"]};
  should["Delete a wrapper function by name"]{
    expected : "{[x;y] (./)(`.test.dec2;(`.test.dec1;(`.qudec.__test__f;(x;y))))}";
    .qudec.deleteDec["__test__f"; `.test.dec2];
    `.qudec.__test__f`.test.dec1`.test.dec3 mustmatch .qudec.__test__fw;
  };
  should["Delete multiple decorator functions by name"]{
    .qudec.deleteDec["__test__f"; `.test.dec2`.test.dec3];
    `.qudec.__test__f`.test.dec1 mustmatch .qudec.__test__fw;
  };
  should["Delete last n decorator functions"]{
    .qudec.deleteDec["__test__f"; 2];
    `.qudec.__test__f`.test.dec1 mustmatch .qudec.__test__fw;
  };
 };

.tst.desc[".qudec.restoreF: restore original function"]{
  before {`.test.f set {x+1}; `.test.g set {x . y}; .qudec.dec[`.test.f;`.test.g]};
  after {![`.test;();0b; `g`f]};
  should["Restore orignal function and perform cleanup"]{
    // check if correct state is created
    1b mustmatch (`$"__test__f") in system "f .qudec";
    1b mustmatch (`$"g") in system "f .test";
    `.qudec.__test__f`.test.g mustmatch .qudec.__test__fw;
    // call function
    res: .qudec.restoreF[`.test.f];
    // check if function is rstored and state is cleared
    res mustmatch {x+1};
    0b mustmatch (`$"__test__f") in system "f .qudec";
    0b mustmatch (`$"__test__fw") in key .qudec;
   };
 };
