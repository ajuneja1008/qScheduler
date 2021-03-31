Overview:

A scheduler package based on kdb+tick, launches 6 processes:
eventsTP       : events TickerPlant that recieves new jobs to schedule (src/q/events/eventsTP.q)
eventsRT       : RDB that subscribes to the TP and executes jobs (src/q/events/eventsRT.q)
tradeConfigRT  : an ad-hoc q process hosting tables and APIs to facilitate some meaningful inter-process operations (src/q/tradeConfig)
feeds          : feed handlers for the events tickerplant (src/q/feed)

Directory Structure:

bin       : startup scripts for the processes
config    : env variables (QHOME, BASE_DIR) & eventsConfig.csv that contains jobs to be loaded into the tickerplant at startup
data      : HDB, tpLog directory. tradeConfigHDB stores two flat files to populate tables at SOD using qScheduler
src/q     : q binaries for the processes (discussed above)
unitTests : unit test cases for the scripts


Flow: 

 - eventsTP recieves an update using .u.upd. It assigns a unique jobID to each job. Also loads a certain set of jobs from config. 
 - eventsRT subscribes to updates on eventsTP and updates the Events table in-memory.
 - timer is set to run .events.run. This function picks up all jobs with mode `once`repeat that are past their execution times. 
 - jobs with mode `once are marked as completed. TP is updated via .u.updComplete
 - jobs with mode `repeat are re-added with the next execution time+: interval via the same .u.updComplete



Deployment Steps (Windows):

1. Download the package and place it in the desired deployment directory. 
2. Open qScheduler/config/config.bat and edit QHOME(source of q binaries) and BASE_DIR(deployment directory for the qScheduler)
3. cd to qScheduler home directory and run ./bin/startqScheduler.bat. This should open 5 windows sequentially(tradeConfigRT, eventsTP, eventsRT and 2 feeds)
** Note: All process assume their root directory as <your>/<deployment>/<dir>/qScheduler **
4. eventsRT would start looking for jobs to run and print "No jobs to run" if there aren't any.
   Meanwhile, feeds (after 70 secs) will start sending more jobs to the scheduler. Run .u.i to evidence the count of incoming messages.
   First jobs should kick in within the first 2 minutes (set as buffer for process startups) 
   These jobs populate priSecMapping and tradingConfig tables on tradeConfigRT. After a while these jobs would vanish from Events as they were set to mode once.


**Assumptions/Design Simplifications**

1. All updates to the events tickerplant use the .u.upd function passing tables matching the Events schema and take the following format:
   Single Run: .u.upd[`Events;]t:([] updateTime:(),.z.N; jobType:`fetch; command:enlist"1+1"; execTime:(),.z.P+"u"$20; mode:`once; interval:0Nv;)
   Repeated Run: .u.upd[`Events;]t:([] updateTime:(),.z.N; jobType:`fetch; command:enlist"1+1"; execTime:(),.z.P+"u"$20; mode:`repeat; interval:0Nv;)
   un-Scheduled (can be tiggered by .events.execEvent[jobID] on the eventsRT service)
   eventsTP returns the jobIDs for the jobs after they are added to the RDB. This ensures that clients are able to track the jobs they scheduled.

2. Since there are no actual upstream systems, eventsRT just retuns its output to the console upon completion of the tasks. 

3. Currently eventsRT handles all the load for the scheduled jobs, ideally we should connect it to a load balancer and gateways to complete the tasks. 

4. Since, the start times of the process are not scheduled. We control the execution times of the "config jobs" on the TP service. Ideally we'll have a fixed time in the csv. 

5. We consider 4 different kinds of job types hitting the qScheduler:
   trigger: triggers(/starts) another process/function (.api.tc.loadPriSecMapping[])
   fetch  : read operations from a single service expected to be quick (.api.tc.checkAutoQuoting `3AUL.L)
   aggr   : read operations from multiple services, include joins and/or long calculations (mocked by .events.aggrNotionals)
   update :  write operation on a single service/data imports (.api.tc.disableAutoQuoting `3AUL.L)
   Currently, we don't make use of this segregation but the long-term idea is that heavier operations (if not all) would be picked up by gateways so that the RDB has full uptime. 

6. tradeConfigRT is a simple q process that hosts 2 tables and some APIs that facilitate read/write operations on them. 
   Ideally it should have its own tickerplant to handle updates which has been kept out of scope for simplicity.
   priSecMapping: Symbols can be traded on multiple excahnges with different rics. This table maps those secondary listings to primaries.
   tradingConfig: This table stores the parameters that nesure if a given symbol will quote automatically or manually.
   Both these tables are loaded at startup and saved-down to their HDB every hour using the `repeat mode on the scheduler. 

7. All processes require the root/base directory to be <your>/<deployment>/<dir>/qScheduler. Its important to ensure this is the case at startup. 
   Can be quickly verified with a \cd

8. HDB process has been kept out of scope with the initial design as there's not much use we make of it at present. 
   See the discussion (2) on enhancements.txt on the persist column which would make the HDB process relevant.

9. Lastly its assumed that all process will be run on the same host. All inter-process connections as setup on localhosts.    


Events Schema:

All updates on the tickerplant for the new jobs are maintained real-time on the Events table which has the following schema
jobID        (long)   : A unique ID generated by the TP whenever a new job is received. In case of intra-day crashes, TP recovers the exisitng jobID count from the tpLog file.  
updateTime (timespan) : last updateTime for the job 
jobType     (symbol)  :`trigger`fetch`aggr`update (see Assumptions#4)
command      (list)   : command to be executed by the eventsRT at the (next) scheduled time  
execTime   (timestamp): stores the (next)execution time of the job. NULL for client-triggered jobs. Clients can trigger the job using .events.execEvent[jobID]
mode        (symbol)  : `once`repeat or (`). NULL symbol denotes that the process would be triggered ad-hoc using .events.execEvent[jobID]
interval    (second)  : For mode=`repeat, next execTime is calculated as the current time + interval
isCompleted (boolean) : mark the scehduled jobs as completed to be deleted from scheduler on completion

 
