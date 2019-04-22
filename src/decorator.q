\d .qudec
/********* Public API ********/
/wrapper function
dec:{[o;d] f:wrap[o;d]; @[value ;string[o],":",f;{set[y;value z]}[;o;f]];}
/ remove decorator function/s
undec:{[o;d] f:removeDec[o;d]; @[value ;string[o],":",f;{set[y;value z]}[;o;f]];}
/ unwrap all- restore to original
restore:{[o] o set restoreF o;}
/ get original function definition
getOrigFD:{chkName x;value ns,ssr[string x;".";"_"]}
/ get original function
getOrigF:{r:({last x}/)[{not (first x 0) like ".qudec.*"};(x 0;x 1)]0;`$ssr[6_string r;"_";"."]}
/ get original function args
getOrigA:{$[2<>count x;x;-11h<>type x 0;x;x[0] like ".qudec.*";last x;.z.s last x]}
/ get Decorators
getDecs:{chkName x;1_value ns,ssr[string x;".";"_"],"w"}

// Internal functions and variables
ns:".qudec."  / namespace prefix
cns: `.qudec / current namesapce
/ normalize function
normalize:{$[-11h=t:type x;value x;100h=t;x;'"function type not supported"]}
/ error output  handlers
e2:{'"second argument can be -> symbol, symbol list, short,integer,long"}
e3:{'"wrong arguments for unwrapping"}
err:(!) . flip (("fname";"not a fully qualified function name");("type"; "Function type not supported"))
error:{'err[x]}
/
 Check function name format.
 Currently support only fully qualified name which contains namespsce name.
 @param - symbol function_name
 @return - boolean|error
\
chkName:{a:"_" sv "." vs string x;$[(3>count a)|(all "_"=3#a)|("_"<>a 0);error["fname"];1b]}

/
 Creates function name by replacing '.' with '_'
 @param - symbol - function_name
 @return - string - converted function_name
\
getName:{ssr[string x;".";"_"]}

/ get decorators dictionary name
getDecN:{`$ns,x,"w"}
/ is already wrapped
isWrapped:{$[100h=t:type x;0b;-11h=t; (`$getName[x]) in system "f"; error "type"]}
/ is new function
/ fix this. search for  alternative total safe  approach
isNew:{not last[value x] like "*.qudec.*"}
/ create function
createFunc:{n:`$ns,x;if[z;set[n;y]];n}
/ create decorators dictionary
createDecLst:{n:getDecN x; if[z;n set y[0],()]; n set get[n],y 1;}
/ delete decorator
deleteDecLst:{n:getDecN x;r:$[11=t:abs type y;get[n] except y;t in 5 6 7h;neg[y]_get n;e2[]];
  $[(1>count r)|not any r like "*.qudec.*";e3[];n set r];}
/ compose decorator
composeDec:{ssr[.Q.s1({y,enlist x}/)[-1;get getDecN x];"-1";y]}
/decorate
wrap:{[o;d] chkName@'/:(o;d);n:getName o;no:normalize o;
 c:isNew no;
 createDecLst[n;(createFunc[n;no;c];d);c];
 genDec[n;no]
  }
/ generate decorator function
genDec:{[n;o]
     p:value[o] 1;
     np:$[1=count p;"enlist ",r:string p;r:";" sv string p];
     raze "{[",r,"] (./)",composeDec[n;"(",np,")"],"}"
   }
removeDec:{[o;d] chkName o;if[11=abs type d;chkName@'d];
    n:getName o;no:normalize o;
    deleteDecLst[n;d];
    genDec[n;no]}

restoreF:{chkName x;n:getName x; v:value `$ns,n;![cns;();0b;enlist x] each `$(n;n,"w");v}
