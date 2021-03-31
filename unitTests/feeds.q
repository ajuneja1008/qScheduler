/ Test Cases for feeds coming into TP
/ Need to ensure that meta and lenghts are as expected

\l ./src/q/feeds/feedAPIS.q                                                / load the feedAPIs into the TP service
x:getEvent[]                                                               / generate an event using the randomiser  
x: `jobID xcols update jobID:.events.getNewID'[i], isCompleted:0b from x   / update the jobID to mimic the upd on TP
meta [x] ~ meta Events                                                     / Compare the meta

\l ./src/q/feeds/feedQueries.q                                             / load the feedQueries into the TP service
x:getEvent[]                                                               / generate an event using the randomiser  
x: `jobID xcols update jobID:.events.getNewID'[i], isCompleted:0b from x   / update the jobID to mimic the upd on TP
meta [x] ~ meta Events                                                     / Compare the meta


