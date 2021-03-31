// table to store the events and recieve 
Events:( []
         jobID       : `long$();               // keyed column, provides a unique ID to a job
         updateTime  : `timespan$();           // updateTime for the job
         jobType	 : `symbol$();	           // `trigger`fetch`aggr`update
         command     : "*"$();                 // command(function) to be executed. Use .events.exe to run on other processes
         execTime    : `timestamp$();          // stores the (next)execution time of the job. NULL for client-triggered jobs  
         mode        : `symbol$();             //  ``once`repeat (`) denotes that the process would be triggered ad-hoc)
         interval    : `second$();             // For mode=`repeat, next execTime = .z.P+interval
         isCompleted : `boolean$()		       // mark the scehduled jobs as completed to be deleted from scheduler on completion
  )
  
  
