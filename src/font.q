/----------------- Public API-------------
/ reset functions
coloroff:{1 "\033[0m";}; / reset/switch off color
reset:{1 "\033c";}; / reset all styles
enableStyle:{se::1b}; / enable styling
disableStyle:{se::0b}; / disable styling

/using 8 color code
c8:{$[not se;y;csi8[x;y]]}; / set colour in message using 8 color code if color enabled option is true

/ using 256 color code
fg:{$[not se;y;csi256[x;y]]}; / set foreground colour in message using 256 color code if color enabled option is true
bg:{$[not se;y;csi256bg[x;y]]}; / set background colour in message using 256 color code if color enabled option is true

/ using rgb
fgp:{$[not se; y;csirgb[x;y]]}; / set foreground colour in message using rgb color code if color enabled option is true
bgp:{$[not se;y;csirgb_bg[x;y]]}; / set background colour in message using Rgb color code if color enabled option is true

/ print function
print:{$[se;1 x,"\r\n";show x];};

/ functions for standard colors - foreground
black:{fg[0;x]};
red:{fg[1;x]};
green:{fg[2;x]};
yellow:{fg[3;x]};
blue:{fg[4;x]};
magenta:{fg[5;x]};
cyan:{fg[6;x]};
white:{fg[7;x]};

/ functions for standard colors - background
blackbg:{bg[0;x]};
redbg:{bg[1;x]};
greenbg:{bg[2;x]};
yellowbg:{bg[3;x]};
bluebg:{bg[4;x]};
magentabg:{bg[5;x]};
cyanbg:{bg[6;x]};
whitebg:{bg[7;x]};

/functions for text style
bold:{c8[1;x]};
faint:{c8[2;x]};
italic:{c8[3;x]};
underline:{c8[4;x]};
dunderline:{c8[21;x]};
sblink:{c8[5;x]};
fblink:{c8[6;x]};
rev:{c8[7;x]};
crossed:{c8[9;x]};
framed:{c8[51;x]};
encircle:{c8[52;x]};
overline:{c8[53;x]};
blinkoff:{c8[25;x]};

/ -----------------Internal functions------------
se:1b ; /enable style

tostr:{$["\033" ~ first x;x;.Q.s1 x]}; / convert to str if its not a csi

/ base functions for colouring
csi8:{"\033[",string[x],"m",tostr[y],"\033[0m"}; /  csi using 8 color code
csi256:{"\033[38;5;",string[x],"m",tostr[y],"\033[0m"}; / foreground csi using 256 color code
csi256bg:{"\033[48;5;",string[x],"m",tostr[y],"\033[0m"}; / background csi using 256 color code
csirgb:{"\033[38;2;",(";" sv string x),"m",tostr[y],"\033[0m"}; / foreground csi using rgb color code
csirgb_bg:{"\033[48;2;",(";" sv string x),"m",tostr[y],"\033[0m"}; / background csi using rgb color code
