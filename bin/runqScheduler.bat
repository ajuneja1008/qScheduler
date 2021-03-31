call ..\config\config.bat

cd %BASE_DIR%


Rem start tradeConfigRT 
start %QHOME%\w32\q %BASE_DIR%\src\q\tradeConfig\tradeConfigRT.q -p 5005

Rem start eventsTP
start %QHOME%\w32\q %BASE_DIR%\src\q\events\eventsTP.q schema ./data/tpLogs -p 5000

Rem sleep 10 seconds
ping 127.0.0.1 -n 11 > nul
Rem start eventsRT
start %QHOME%\w32\q %BASE_DIR%\src\q\events\eventsRT.q localhost:5000 -p 5001

ping 127.0.0.1 -n 61 > nul
Rem start feed 1
start %QHOME%\w32\q %BASE_DIR%\src\q\feeds\feedAPIs.q -p 5003

ping 127.0.0.1 -n 71 > nul
Rem start feed 2
start %QHOME%\w32\q %BASE_DIR%\src\q\feeds\feedQueries.q -p 5004




