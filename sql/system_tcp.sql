-- create the user that will run the client.
create user BASEX identified by "3xt3ns1bl3";
grant create procedure to BASEX;
grant create session to BASEX;
grant execute on DBMS_CRYPTO to BASEX;
grant execute on UTL_TCP to BASEX;
begin
  dbms_network_acl_admin.create_acl (
    acl => 'basex_permissions.xml', -- or any other name
    description => 'Server Access',
    principal => 'BASEX', -- the user name trying to access the network resource
    is_grant => TRUE,
    privilege => 'connect',
    start_date => null,
    end_date => null
  );
end;
/
commit;

begin
DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
  acl => 'basex_permissions.xml',
  principal => 'BASEX',
  is_grant => true,
  privilege => 'resolve'
);
end;
/
commit;

begin
dbms_network_acl_admin.assign_acl (
  acl => 'basex_permissions.xml',
  host => 'localhost',
  lower_port => 1984,
  upper_port => 1984
);
end;
/