/ Send (mode)`once and `repeat API requests to tradingConfigRT

f:`.api.tc.checkAutoQuoting`.api.tc.disableAutoQuoting`.api.tc.enableAutoQuoting`.api.tc.sec;        / domain of APIs to randomise from                
syms: `3AUL.L`3AUS.L`3CFL.L`3CFS.L`3CRL.L`3CRS.L`3CUL.L`3CUS.L`3NIL.L`ISF.L;                         / domain of symbols to randomise from 
cmd:{".events.exe[`::5005;](", .Q.s1[first 1?f], ";" .Q.s1[first 1?syms], ")"};                      / function to get the cmd 

/function to generate an event to send to eventsTP
getEvent:{([] updateTime:(),.z.N; jobType:`fetch; command:enlist cmd[]; execTime:(),.z.P+"u"$4+1?3; mode:1?`once`repeat; interval:(), "v"$1000+1?180)}

h:neg hopen `::5000;                                                                                 / handle to TP service

.z.ts:{h (`.u.upd;`Events;getEvent[]);}                                                              / setup the timer function to send feeds

0N!"Running feedAPIs";
system "t 60000";                                                                                   / timer set for 60 secs 
