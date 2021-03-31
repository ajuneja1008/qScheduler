/ tradeConfigRT is a simple q process that stores the trading configuration of symbols into two tables.
/ It exposes some APIs to manipulate/fetch these configurations in the .api.tc namespace. 
/ It has a config file in qScheduler/config that initiates it at SOD and ensures savedown at EOD. 


/ Defining two tables that store ric metadata
/ Stores the primary and secondary listings of symbols 
priSecMapping: `primaryRic`secondaryRic xkey flip `primaryRic`secondaryRic`isEnabled`lastUpdated`updateUser!"ssbps"$\:();

/ Stores whether the trading configuration for symbols - wether autoQuoting or manual
tradingConfig: `ric xkey flip `ric`isAutoQuoting`lastUpdated`updateUser!"sbps"$\:();

upd:upsert;

//functions to load data into tables
.api.tc.loadPriSecMapping:{
 t: get `:./data/tradeConfigHDB/priSecMapping.q;
 upd[`priSecMapping;t];
 enlist "priSecMapping loaded successfully"}

.api.tc.loadTradingConfig:{
 t: get `:./data/tradeConfigHDB/tradingConfig.q;
 upd[`tradingConfig;t];
 enlist "tradingConfig loaded successfully"}
 
/ functions to save data to disk (as flat files) at EOD
.api.tc.savePriSecMapping:{
 `:./data/tradeConfigHDB/priSecMapping.q set priSecMapping;
 enlist "priSecMapping saved-down successfully into tradeConfigHDB"}

/ functions to save data to disk (as flat files) at EOD
.api.tc.saveTradingConfig:{
 `:./data/tradeConfigHDB/tradingConfig.q set tradingConfig;
 enlist "tradingConfig saved-down successfully into tradeConfigHDB"}
 
prisec:: exec secondaryRic by primaryRic from priSecMapping where isEnabled
.api.tc.sec:{prisec x}

ricQuoting:: exec isAutoQuoting by ric from tradingConfig
.api.tc.checkAutoQuoting:{first ricQuoting x}

/ function to enable autoquoting for a ric on tradingConfig
.api.tc.enableAutoQuoting:{
 upd[`tradingConfig;(x;1b;.z.P;.z.u)];
 enlist["Auto-quoting enabled for ",string x]}
 
/ function to disable autoquoting for a ric on tradingConfig
.api.tc.disableAutoQuoting:{
 upd[`tradingConfig;(x;0b;.z.P;.z.u)];
 enlist["Auto-quoting disabled for ",string x]}
 
/ function to disable a pri-sec mapping
.api.tc.disablePriSec:{
 upd[`priSecMapping;(x;y;0b;.z.P;.z.u)];
 enlist["Mapping disabled for the pair: ", string[x],"/",string[y]]}
 
 
0N!"Running tradeConfigRT, tables should be loaded in 1 minute";
 
 

 



