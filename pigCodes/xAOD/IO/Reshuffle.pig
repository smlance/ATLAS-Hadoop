-- this code reads from /user/rucio01/nongrid_traces/
-- parses json, calculates averages of readsize readcalls and cachesize

rmf tmp.csv
REGISTER '/usr/lib/pig/piggybank.jar' ;
REGISTER xAODparser-*.jar
REGISTER json.jar

RECS = LOAD '/user/rucio01/nongrid_traces/2015-08-14.json'  using PigStorage as (Rec:chararray);
--RECS = LOAD '/atlas/analytics/xAODcollector/test.json'  using PigStorage as (Rec:chararray);
--dump RECS;

B = FOREACH RECS GENERATE FLATTEN(xAODparser.Parser(Rec));
describe B;
-- dump B;


F = filter B BY PandaID > 0L;

-- here one needs to fix CacheSize as it has meaning encoded:
-- negative value is number of bytes, positive number is number of events to cache.

D = foreach F generate line::ReadCalls as RC, line::ReadSize as RS, line::CacheSize as CS, SIZE(line::accessedFiles) as AF, SIZE(line::AccessedBranches) as AB, SIZE(line::AccessedContainers) as AC ;

STORE D INTO 'tmp.csv' USING org.apache.pig.piggybank.storage.CSVExcelStorage(',','NO_MULTILINE');

G = GROUP D ALL;
S = FOREACH G GENERATE COUNT(D), AVG(D.RC), AVG(D.RS), AVG(D.CS), AVG(D.AF), AVG(D.AB), AVG(D.AC);
dump S;