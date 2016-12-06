# pl-sql-BaseX
PL/SQL client for [BaseX](http://basex.org/).
It is a work in progress.

# Grants
```bash
grant create procedure to <user>;
grant create session to <user>;

grant execute on DBMS_CRYPTO to <user>;
grant execute on UTL_TCP to <user>;
begin
  dbms_network_acl_admin.create_acl (
    acl => 'basex_permissions.xml', -- or any other name
    description => 'Server Access',
    principal => '<user>', -- the user name trying to access the network resource
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
  principal => '<user>',
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
```
