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

/ ************************************************************************************* \
/ ***** Internal functions and variables ****** \

ns:".qudec."  / namespace prefix
cns: `.qudec / current namesapce
/ error output  handlers
e2:{'"second argument can be -> symbol, symbol list, short,integer,long"}
e3:{'"wrong arguments for unwrapping"}
err:(!) . flip (("fname";"not a fully qualified function name");("type"; "Function type not supported"))
error:{'err[x]}

/
* Return function definition
* @param - symbol - function_name
* @return - function code|error
\
normalize:{$[-11h=t:type x;value x;100h=t;x;'"function type not supported"]}
/
 * Check function name format.
 * Currently support only fully qualified name which contains namespsce name.
 * @param - symbol - function_name
 * @return - boolean|error
\
chkName:{a:"_" sv "." vs string x;$[(3>count a)|(all "_"=3#a)|("_"<>a 0);error["fname"];1b]}
/
 * Creates function name by replacing '.' with '_'
 * @param - symbol - function_name
 * @return - string - converted function_name
\
getName:{ssr[string x;".";"_"]}
/
* get decorator list name to hold decorator functions for a decorated function
* @param - string - full internal function name(getName output)
* @return - symbol - dictionary name (appends 'w' at the end)
\
getDecN:{`$ns,x,"w"}
/
* Check if function is already decorated
* Only supports function type =100h with names (that means no lambda)
* @param - symbol - full qualified function_name
* @return - boolean | error(type)
\
isWrapped:{if[-11h=t:type x; chkName x; :(`$getName[x]) in system "f"]; error "type"}
/
* Checks if its a new function or decorated function
* @todo -  search for  alternative total safe  approach
* @param - lambda - function code
* @return - boolean
\
isNew:{not last[value x] like "*.qudec.*"}
/
* create the function in current namespace
* @param - string - function name (getName output)
* @param - lambda - function code
* @param - boolean - to create function or not
* @return - symbol - new function name
\
createFunc:{n:`$ns,x;if[z;set[n;y]];n}
/
* create decorator list to apply
* @param - string - function name (internal format)
* @param - symbol list - (function name to wrap ; decorator function)
* @param - boolean - is this first call to wrap a given function
* @return  - none
\
createDecLst:{n:getDecN x;if[z;n set y[0],()]; n set get[n],y 1;}
/
* wraps the function with decorator functions and return new code string for original function to set.
* @param - symbol - function name to decorate
* @param - symbol | symbol list - function list of functions to wrap original function
* @return - string - new code to set for original function
\
wrap:{[o;d] chkName@'/:(o;d);n:getName o;no:normalize o;
 c:isNew no;
 createDecLst[n;(createFunc[n;no;c];d);c];
 genDec[n;no]
  }
/
* Combine the wrapper functions fora given target function.
* param - string - target function name (internal format)
* param - string - function input arguments inside paranthesis
* return - string - output code after applying wrapper functions from target function decorator list.
   This will become part of final code string of a decorated function.
\
composeDec:{ssr[.Q.s1({y,enlist x}/)[-1;get getDecN x];"-1";y]}
/
* Generate final string for function after applying wrapper functions
* param - string - function name (internal format)
* param - lambda(100h) - function code with context
* return - string - function decorator code
\
genDec:{[n;o]
     p:value[o] 1;
     np:$[1=count p;"enlist ",r:string p;r:";" sv string p];
     raze "{[",r,"] (./)",composeDec[n;"(",np,")"],"}"
   }
/
* Remove decorator functions from decortor list.
* Helper function for deleteDec
* @param - string - original function name(internal format)
* @param - symbol | symbol list | integer | short | long - decorator function name to remove or
 total number of functions to remove(last added function will be deleted first)
\
deleteDec:{n:getDecN x;r:$[11=t:abs type y;get[n] except y;t in 5 6 7h;neg[y]_get n;e2[]];
    $[(1>count r)|not any r like "*.qudec.*";e3[];n set r];}
/
* Remove decorator functions for wrapped function
* @param - symbol - original wrapped function name
* @param - symbol | symbol list | integer | short | long - decorator functions name to remove or
 total number of functions to remove(last added function will be deleted first)
* @return - string - function decorator code
\
removeDec:{[o;d] chkName o;if[11=abs type d;chkName@'d];
    n:getName o;no:normalize o;
    deleteDec[n;d];
    genDec[n;no]}
/
* Reutrn the original function definition and deletes the temporary function and decorator deictionary variables.
* @param - symbol - orignal function name
* @return - lambda - function definition
\
restoreF:{chkName x;n:getName x; v:value `$ns,n;![cns;();0b;`$(n;n,"w")];v}
