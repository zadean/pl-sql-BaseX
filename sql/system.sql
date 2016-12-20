-- create the user that will run the client.
create user BASEX identified by "3xt3ns1bl3";
grant unlimited tablespace to BASEX; -- or whatever tablespace and quota
grant create procedure to BASEX;
grant create session to BASEX;
grant create table to BASEX;
-- enable the JVM to connect to BaseX (default host and port here).
begin
  dbms_java.grant_permission( 'BASEX', 'SYS:java.net.SocketPermission', 'localhost:1984', 'connect,resolve' );
end;
/
