
if[not "w"=first string .z.o;system "sleep 1"];

/ Customise the upd for updates and log replay. 
upd:upsert

/ get the ticker plant and history ports, defaults are 5010,5012
.u.x:.z.x,(count .z.x)_(":5000";":5012");

/ end of day: save, clear, hdb reload
.u.end:{
  t:tables`.;
  .Q.hdpf[`$":",.u.x 1;`:.;x;`jobID];
  };

/ init schema and sync up from log file;cd to hdb(so client save can run)
/ (x) -> (`tables; Empty schema), (y) -> (n;`:TPLog)  - Gets supplied by TP upon subscription 
.u.rep:{(.[;();:;].)each x;                                           / initialise the tables in the namespace
  if[null first y;:()];                                               / early exit if no messages on the TPLog
  -11!last y;}                                                             / Replay tp log
/  system "cd ./data/tpLogs/",1_-10_string first reverse y};          / Change the RDB working directory to HDB 

// .u.sub[`;`] returns a list of pairs: (tables;Empty schema) 
// `.u `i`L returns the count of messages and the handle to the TPLog
// Finally, hopen `$":",.u.x 0 opens a handle to the TP looking for the schemas and the TPLog information: (schema;(logcount;log))
.u.rep .(hopen `$":",.u.x 0)"(.u.sub[`;`];`.u `i`L)";

// Key the table Events on jobID
`jobID xkey `Events;


system "c 250 2500";                                                  / increasing column width to read logs better


//-----------------------------Scheduler Functions -------------------------------------------------------------//  


/ (`)    -> job is not scheduled. Can be triggered using the API .events.execEvent[ID]
/ once   -> job is flushed from Events after successful execution
/ repeat -> job is set for its next iteration (.z.P + interval) after successful execution. 

.events.mode: ``once`repeat;

/ 4 jobTypes that define the different types of operations scheduled (to load balance in future)
/ trigger -> triggers(/starts) another process/function 
/ fetch   -> read operations from a single service (quick)
/ aggr    -> read operations from multiple services, include joins or long calculations (strenous)
/ update  -> write operation on a single service: data imports

.events.jobType: `trigger`fetch`aggr`update;

.events.remove:{delete from `Events where jobID in x}

/ Function to execute InterProcess Communication
/ x -> handle, y -> query/function 
.events.exe:{h:hopen x; res:h y; hclose h;res}

/ protected evaluation for all Events. Print Error whenever execution fails. 
.events.execEvent:{[ids] {[cmd] @[value;cmd;{enlist["Failed to execute job. Error:",x]}]} each Events[([]jobID:(),ids);`command]}

/Run all jobs past their exec time, mark them as completed(schedule next in case of repeat) and update TP  
.events.run:{
 ids:exec distinct jobID from Events where execTime <= .z.P, not isCompleted;                       
 if[not count ids;:enlist[.Q.s1[.z.P]," No jobs to run"]];                                          / early exit if no jobs found
 result: .events.execEvent ids;                                                                     / execute all ids
 t: update isCompleted:1b from select from Events where jobID in ids, mode=`once;                   / isCompleted:1b for once jobs
 t,: update execTime: .z.P + interval from select from Events where jobID in ids, mode=`repeat;     / new execTime for repeat jobs
 .events.exe[`::5000;(`.u.updComplete;`Events;0!t)];                                                / send update to tickerplant
 result}

.z.ts:{delete from `Events where isCompleted; 0N!.events.run[]}
0N!"Running eventsRT, config jobs scheduled on Events";
system "t 15000";                                                                                   /set the timer function to run .events.run every 10 second



