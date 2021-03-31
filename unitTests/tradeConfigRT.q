/ Unit tests for the service tradeConfigRT

/ Check if tables defined in memory
`priSecMapping`tradingConfig in tables `.                      / 11b


/Schema Check
"ssbps"~@[;`t]0!meta priSecMapping                             / 1b

"sbps"~@[;`t]0!meta priSecMapping                              / 1b


/ Check if All the functions defined in memory
min {x ~ key x} each `.api.tc.loadPriSecMapping`.api.tc.loadTradingConfig`.api.tc.savePriSecMapping`.api.tc.saveTradingConfig`.api.tc.sec`.api.tc.enableAutoQuoting`.api.tc.disableAutoQuoting`.api.tc.disablePriSec / 1b

// Unit tests for each functions
.api.tc.disablePriSec[`ISF.L;`ISF.MI]                          / "Mapping disabled for the pair: ISF.L/ISF.MI"
.api.tc.checkAutoQuoting `3AUL.L                               / 0b
.api.tc.disableAutoQuoting `3AUL.L                             / "Auto-quoting disabled for 3AUL.L"
.api.tc.enableAutoQuoting `3AUL.L                              / "Auto-quoting enabled for 3AUL.L"
.api.tc.loadTradingConfig[]                                    / "tradingConfig loaded successfully"
.api.tc.loadPriSecMapping[]                                    / "priSecMapping loaded successfully"
.api.tc.savePriSecMapping[]                                    / "priSecMapping saved-down successfully into tradeConfigHDB"
.api.tc.saveTradingConfig[]                                    / "tradingConfig saved-down successfully into tradeConfigHDB"
.api.tc.sec `ISF.L                                             / `ISF.S`ISFU.L`ISF.DE`ISF.AS
