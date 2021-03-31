/ Sanity testing on the Events tickerPlant

Events in tables `.

"jns psvb"~@[0!meta Events;`t]                             / schema check

0 = .events.id                                             / SOD TP should have events ID count as zero

/ Check to ensure functions loaded into memory
min {x ~ key x} each `.u.ld`.u.tick`.u.endofday`.u.ts`.u.upd`.u.updComplete`.events.getNewID`events.loadConfig`.u.del`.u.sel`.u.pub`.u.sub`.u.add`.u.init`.u.end

.u.i = 4                                                   / Check the config jobs loaded at startup

if[0<count .u.i;exit 0]                                    / Check the .events.id persists on TP restart
events.id > 0                                              / run after restarting the service intra-day

/ Updates on Tickerplant 
/ Check the jobID get propagated with each job and isCompleted populated, TP log
0 > .u.i
`jobID`isCompleted in cols (last last get .u.L)

/ Schedule a single job
.u.upd[`Events;]t:([] jobID:1; updateTime:(),.z.N; jobType:`fetch; command:enlist"1+1"; execTime:(),.z.P+"u"$20; mode:`once; interval:0Nv; isCompleted:0b)
.u.upd[`Events;]t:([] jobID:2; updateTime:(),.z.N; jobType:`fetch; command:enlist"2+2"; execTime:(),.z.P+"u"$50; mode:`repeat; interval:(),00:05:00; isCompleted:0b)


/Schedule multiple jobs at once
.u.upd[`Events;]t:(updateTime:2#.z.N; jobType:2#`fetch; command:("3+3";"4+4"); execTime:.z.P+"u"$(20;30); mode:`once`repeat;interval: (0Nv; 00:00:05))

/ Update an existing job (jobID=2), change mode to (`) -> client triggered
.u.upd[`Events;]t:([] jobID:2 ;updateTime:(),.z.N; jobType:`fetch; command:"2+2";execTime:(),.z.P+"u"$20; mode:`;interval:(),00:05:00 isCompleted:0b)

/ Update a garbage job to catch the error in logs
.u.upd[`Events;]t:([] jobID:5; updateTime:(),.z.N; jobType:`fetch; command:enlist["1+\"a\""]; execTime:(),.z.P+"u"$20; mode:`once; interval:0Nv; isCompleted:0b)


