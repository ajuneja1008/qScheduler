/ Send (mode)`once select and update queries to tradingConfigRT

queries:("\"update isEnabled:1b, updateTime:.z.P, updateUser:.z.u from `priSecMapping\"";            / domain of queries to choose from
         "\"update isAutoQuoting:1b, updateTime:.z.P, updateUser:.z.u from `tradingConfig\"";
		 "\"select from tradingConfig where isAutoQuoting\"")

cmd:{raze [".events.exe[`::5005;]",1?queries]}  		 

/function to generate an event to send to eventsTP
getEvent:{([] updateTime:(),.z.N; jobType:`update; command:enlist cmd[]; execTime:(),.z.P+"u"$4+1?3; mode:`once; interval:(), "v"$1000+1?180)}

h:neg hopen `::5000;                                                                                  / handle to TP service

.z.ts:{h (`.u.upd;`Events;getEvent[]);}                                                               / setup the timer function to send feeds
0N!"Running feedQueries";
system "t 60000";                                                                                     / timer set for 60 seconds