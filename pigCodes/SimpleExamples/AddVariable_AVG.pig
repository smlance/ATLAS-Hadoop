-- this simple example filters records to select only onese between to dates
-- subtracts values of two columns
-- calculates average of the difference.

-- running in the following way gives much nicer error reports:
-- pig -x mapreduce script.pig

-- output will be in a lot of very small files. to get output localy download it like this
-- hdfs dfs -getmerge waitGperDay.csv waitGperDay.csv


rmf waitGperDay.csv; 
register '/usr/lib/pig/piggybank.jar' ;
DEFINE CSVLoader org.apache.pig.piggybank.storage.CSVLoader();
DEFINE CSVExcelStorage org.apache.pig.piggybank.storage.CSVExcelStorage();
PAN = LOAD '/user/ivukotic/Panda' USING CSVLoader as (
PANDAID:long, MODIFICATIONTIME:long, JOBDEFINITIONID:long, SCHEDULERID:chararray, PILOTID:chararray, CREATIONTIME:long, CREATIONHOST:chararray, 
MODIFICATIONHOST:chararray, ATLASRELEASE:chararray, TRANSFORMATION:chararray, HOMEPACKAGE:chararray, PRODSERIESLABEL:chararray, 
PRODSOURCELABEL:chararray, PRODUSERID:chararray, ASSIGNEDPRIORITY:long, CURRENTPRIORITY:long, ATTEMPTNR:int, MAXATTEMPT:int, JOBSTATUS:chararray, 
JOBNAME:chararray, MAXCPUCOUNT:long, MAXCPUUNIT:chararray, MAXDISKCOUNT:long, MAXDISKUNIT:chararray, IPCONNECTIVITY:chararray, MINRAMCOUNT:long, 
MINRAMUNIT:chararray, STARTTIME:long, ENDTIME:long, CPUCONSUMPTIONTIME:long, CPUCONSUMPTIONUNIT:chararray, COMMANDTOPILOT:chararray, 
TRANSEXITCODE:chararray, PILOTERRORCODE::int, PILOTERRORDIAG:chararray, EXEERRORCODE:int, EXEERRORDIAG:chararray, SUPERRORCODE:int, 
SUPERRORDIAG:chararray, DDMERRORCODE:int, DDMERRORDIAG:chararray, BROKERAGEERRORCODE:int, BROKERAGEERRORDIAG:chararray, JOBDISPATCHERERRORCODE:int, 
JOBDISPATCHERERRORDIAG:chararray, TASKBUFFERERRORCODE:int, TASKBUFFERERRORDIAG:chararray, COMPUTINGSITE:chararray, COMPUTINGELEMENT:chararray, 
PRODDBLOCK:chararray, DISPATCHDBLOCK:chararray, DESTINATIONDBLOCK:chararray, DESTINATIONSE:chararray, NEVENTS:long, GRID:chararray, CLOUD:chararray, 
CPUCONVERSION:float, SOURCESITE:chararray, DESTINATIONSITE:chararray, TRANSFERTYPE:chararray, TASKID:long, CMTCONFIG:chararray, STATECHANGETIME:long, 
PRODDBUPDATETIME:long, LOCKEDBY:chararray, RELOCATIONFLAG:int, JOBEXECUTIONID:long, VO:chararray, PILOTTIMING:chararray, WORKINGGROUP:chararray, 
PROCESSINGTYPE:chararray, PRODUSERNAME:chararray, NINPUTFILES:int, COUNTRYGROUP:chararray, BATCHID:chararray, PARENTID:long, SPECIALHANDLING:chararray, 
JOBSETID:long,CORECOUNT:int, NINPUTDATAFILES:int, INPUTFILETYPE:chararray, INPUTFILEPROJECT:chararray, INPUTFILEBYTES:long, NOUTPUTDATAFILES:int,OUTPUTFILEBYTES:long);

 
-- select only entries from 15th Sep
F1 = filter PAN by MODIFICATIONTIME>1410739200 and MODIFICATIONTIME<1410825600;

-- selects only a few variables
F2 = foreach F1 generate STARTTIME,CREATIONTIME, STARTTIME - CREATIONTIME as DIFF;

grouped = group F2 all;
res = foreach grouped generate AVG(F2.DIFF);
dump res;


-- grouping per day 
CLEAN = FILTER PAN BY MODIFICATIONTIME is not null;
F3 = foreach CLEAN generate DaysBetween(ToDate(MODIFICATIONTIME*1000),ToDate(1388534400000L)) as day, STARTTIME,CREATIONTIME, STARTTIME - CREATIONTIME as DIFF;
GperDay = group F3 by day;
waitGperDay = foreach GperDay generate group, AVG(F3.DIFF) as avgwait;
dump waitGperDay;
store waitGperDay into 'waitGperDay.csv' USING CSVExcelStorage(',', 'NO_MULTILINE');

