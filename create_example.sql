-- create_example.sql
set serverout on
declare
  v_sess utl_tcp.connection;
  v_inpt varchar2(4000);
  v_outp clob;
begin
  v_sess := basex_client.open_session('localhost', 1984, 'admin', 'admin');

  -- define input stream
  v_inpt := '<xml>Hello World!</xml>';

  -- create new database
  basex_client.bx_create(v_sess, 'database', v_inpt);
  dbms_output.put_line(basex_client.bx_info);

  -- run query on database
  dbms_output.put_line(basex_client.bx_execute(v_sess, 'xquery doc(''database'')'));

  -- drop database
  v_outp := basex_client.bx_execute(v_sess, 'drop db database');
exception when others then
  basex_client.close_session(v_sess);
  dbms_output.put_line(sqlerrm);
end;
/
