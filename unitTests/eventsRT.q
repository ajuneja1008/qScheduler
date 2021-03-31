// Unit Tests for functions in .events

// .events.exe
.events.exe[`::5000;"1+1"]
.events.exe[`::5000;({x+y};3;4)] 
.events.exe[`::5000;(`f;3;4)]    // Define f as f:{x+y} on the TP service (Port:5000)

// .events.run[]
1 < count select from Events where isCompleted


