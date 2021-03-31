\l cd %BASE_DIR%;

// Defining two tables that store symbol metadata

/ Stores the primary and secondary listings of symbols 
priSecMapping: `primarySym xkey flip `primarySym`secondarySym`isEnabled`lastUpdated`updateUser!"ssb"$\:();

/ Stores whether the trading configuration for symbols - wether autoQuoting or not
tradingConfig: `sym xkey flip `sym`isAutoQuoting`lastUpdated`updateUser!"sbps"$\:();

upd:upsert;

loadPriSecMapping:{
 t: get `:priSecMapping.q;
 upd[`prisecMapping;t]
 enlist "priSecMapping loaded successfully"}

loadPriSecMapping:{
 t: get `:autoQuoting.q;
 upd[`auotQuoting;t]
 enlist "auotQuoting loaded successfully"}
 
prisec:: exec secondarySym by primarySym from priSecMapping where isEnabled
.api.sec:{prisec x}

symQuoting:: exec isAutoQuoting by sym from tradingConfig
.api.checkAutoQuoting:{symQuoting x}

/ function to enable autoquoting for a symbol on tradingConfig
.api.enableAutoQuoting:{
 upd[`tradingConfig;(x;1b;.z.P;.z.u)];
 enlist["Auto-quoting enabled for ",string x]}
 
/ function to disable autoquoting for a symbol on tradingConfig
.api.disableAutoQuoting:{
 upd[`tradingConfig;(x;0b;.z.P;.z.u)];
 enlist["Auto-quoting disabled for ",string x]}
 
/ function to disable a pri-sec mapping
.api.disablePriSec:{
 upd[`prisecMapping;(x;y;0b;.z.P;.z.u)];
 enlist["Mapping disabled for the pr", string[x],"/",string[y]]}
 
 
`3AUL.L`3AUS.L`3CFL.L`3CFS.L`3CRL.L`3CRS.L`3CUL.L`3CUS.L`3NIL.L`ISF.L`ISF.L`ISF.L`ISF.L`ISF.L
`3AUL.MI`AUS.MI`3CFL.MI`3CFS.MI`3CRL.MI`3CRS.MI`3CUL.MI`3CUS.MI`3NIL.MI`ISF.MI`ISF.S`ISFU.L`ISF.DE`ISF.AS
 



