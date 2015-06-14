REGISTER '/usr/lib/pig/piggybank.jar' ;
REGISTER '/usr/lib/pig/lib/avro-*.jar';
REGISTER '/usr/lib/pig/lib/jackson-*.jar';
REGISTER '/usr/lib/pig/lib/json-*.jar';
REGISTER '/usr/lib/pig/lib/jython-*.jar';
REGISTER '/usr/lib/pig/lib/snappy-*.jar';

REGISTER '/usr/lib/pig/lib/elasticsearch-hadoop-*.jar';

REGISTER 'myudfs.py' using jython as myfuncs;

define EsStorage org.elasticsearch.hadoop.pig.EsStorage('es.nodes=http://aianalytics01.cern.ch:9200');


PAN = LOAD '/atlas/analytics/panda/JOBSARCHIVED/jobs.$INPD/part-m-00000.avro' USING AvroStorage();
DESCRIBE PAN;

--L = LIMIT PAN 1000; --dump L;

REC = FOREACH PAN GENERATE (long)PANDAID,(long)JOBDEFINITIONID,SCHEDULERID,PILOTID,CREATIONTIME,CREATIONHOST,MODIFICATIONTIME,MODIFICATIONHOST,ATLASRELEASE,TRANSFORMATION,HOMEPACKAGE,PRODSERIESLABEL,PRODSOURCELABEL,PRODUSERID,(int)ASSIGNEDPRIORITY,(int)CURRENTPRIORITY,(int)ATTEMPTNR,(int)MAXATTEMPT,JOBSTATUS,JOBNAME,(int)MAXCPUCOUNT,MAXCPUUNIT,(int)MAXDISKCOUNT,MAXDISKUNIT,IPCONNECTIVITY,(int)MINRAMCOUNT,MINRAMUNIT,STARTTIME,ENDTIME,(long)CPUCONSUMPTIONTIME,CPUCONSUMPTIONUNIT,COMMANDTOPILOT,(int)TRANSEXITCODE,(int)PILOTERRORCODE,PILOTERRORDIAG,(int)EXEERRORCODE,EXEERRORDIAG,(int)SUPERRORCODE,SUPERRORDIAG,(int)DDMERRORCODE,DDMERRORDIAG,(int)BROKERAGEERRORCODE,BROKERAGEERRORDIAG,(int)JOBDISPATCHERERRORCODE,JOBDISPATCHERERRORDIAG,(int)TASKBUFFERERRORCODE,TASKBUFFERERRORDIAG,COMPUTINGSITE,COMPUTINGELEMENT,PRODDBLOCK,DISPATCHDBLOCK,DESTINATIONDBLOCK,DESTINATIONSE,(long)NEVENTS,GRID,CLOUD,(int)CPUCONVERSION,SOURCESITE,DESTINATIONSITE,TRANSFERTYPE,(long)TASKID,CMTCONFIG,STATECHANGETIME,PRODDBUPDATETIME,LOCKEDBY,RELOCATIONFLAG,(long)JOBEXECUTIONID,VO,PILOTTIMING,WORKINGGROUP,PROCESSINGTYPE,PRODUSERNAME,(int)NINPUTFILES,COUNTRYGROUP,BATCHID,(long)PARENTID,SPECIALHANDLING,(long)JOBSETID,(int)CORECOUNT,(int)NINPUTDATAFILES,INPUTFILETYPE,INPUTFILEPROJECT,(long)INPUTFILEBYTES,(int)NOUTPUTDATAFILES,(long)OUTPUTFILEBYTES,JOBMETRICS,(long)WORKQUEUE_ID,(long)JEDITASKID,JOBSUBSTATUS,ACTUALCORECOUNT,FLATTEN(myfuncs.deriveDurationAndCPUeff(CREATIONTIME,STARTTIME,ENDTIME,CPUCONSUMPTIONTIME)) as (wall_time:int, cpu_eff:float, queue_time:int), FLATTEN(myfuncs.deriveTimes(PILOTTIMING)) as (timeGetJob:int, timeStageIn:int, timeExe:int, timeStageOut:int, timeSetup:int), myfuncs.Tstamp(MODIFICATIONTIME);

STORE REC INTO 'job_archive/jobdata-$INPD' USING EsStorage();
