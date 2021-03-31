
system"l ./src/q/events/",(src:first .z.x,enlist"schema"),".q"                                / Load the schema.q file


\l ./src/q/events/u.q
\d .u

ld:{if[not type key L::`$(-10_string L),string x; .[L;();:;()]];                              / if TP logfile doesn't exist (key check), then an empty log is initiated. 
  i::j::-11!(-2;L);
  if[0<=type i;(string L)," is a corrupt log. Truncate to length ",(string last i)," and restart";exit 1];
  hopen L};                                                                                   / Returns a handle to the TP log 

// Initiates a tickerplant 
tick:{
  init[];
  d::.z.D;
  if[l::count y; L::`$":",y,"/",x,10#"."; l::ld d]};

endofday:{end d;d+:1;if[l;hclose l;l::0(`.u.ld;d)]};

ts:{if[d<x;if[d<x-1;system"t 0";'"more than one day?"];endofday[]]};                          / d is the date of TP start. If next day; send endofday to subscribers and tp_log 

if[not system"t";system"t 1000";.z.ts:{ts .z.D}];                                             / ts set on timer

upd:{[t;x]
  ts"d"$a:.z.P;
  x: `jobID xcols update jobID:.events.getNewID'[i], isCompleted:0b from x;                   / populate the jobID based on the counter
  pub[t;x];                                                                                   / publish the record
  if[l;l enlist (`upd;t;x);i+:1];                                                             / if a handle is defined, insert to a tp_log
  exec distinct jobID from x}                                                                 / Return the jobID to the feed handlers and the upstream processes so they can track

updComplete:{[t;x]                                                                            / RT informs TP of completion/next iteration for mode=`repeat
  pub[t;x];                                                                                   / publish the record
  if[l;l enlist (`upd;t;x);i+:1];                                                             / if a handle is defined, insert to a tp_log
 }
  
\d .


.events.getNewID:{ :.events.id +:1}                                                           / increase the counter by 1 with every call 

.events.loadConfig:{
  t:("s*sv";enlist",") 0:`:./config/eventsConfig.csv;                                         / load the config csv
  t:update updateTime:.z.N, execTime:.z.P+00:01, isCompleted:0b from t;                       / adding jobID, isCompleted and a 10-minute buffer on all jobs to ensure all processes are up    
  t:`updateTime`jobType`command`execTime xcols t;                                             / re-order columns to match the schema
  .u.upd[`Events;t];                                                                               
  enlist[count [t]," job(s) loaded from the config file"]}

`jobID xkey `Events;                                                                          / Key the table Events on jobID

.u.tick[src;.z.x 1];

`.events.id set $[.u.i;exec last jobID from (last last get .u.L) where not isCompleted;0];     / At startup, set id to 0 if no msgs in TPLog else fetch the last ID 

.events.loadConfig[];

system "c 250 2500";

0N!"Running eventsTP service. Jobs from eventsConfig loaded successfully. Should trigger in 1 minute";
\
 globals used
 .u.w - dictionary of tables->(handle;syms)
 .u.i - msg count in log file
 .u.j - total msg count (log file plus those held in buffer)
 .u.t - table names
 .u.L - tp log filename, e.g. `:./sym2008.09.11
 .u.l - handle to tp log file
 .u.d - date
