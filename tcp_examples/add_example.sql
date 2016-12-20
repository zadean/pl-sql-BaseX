-- add_example.sql
set serverout on
declare
  v_sess utl_tcp.connection;
  v_inpt varchar2(1000);
  v_outp clob;
begin
  v_sess := basex_client.open_session('localhost', 1984, 'admin', 'admin');

  -- create empty database
  v_outp := basex_client.bx_execute(v_sess, 'create db database');
  dbms_output.put_line(basex_client.bx_info);

  -- define input stream
  v_inpt := '<x>Hello World!</x>';

  -- add document
  basex_client.bx_add(v_sess, 'world/world.xml', v_inpt);
  dbms_output.put_line(basex_client.bx_info);

  -- define input stream
  v_inpt := '<x>Hello Universe!</x>';

  -- add document
  basex_client.bx_add(v_sess, 'universe.xml', v_inpt);
  dbms_output.put_line(basex_client.bx_info);

  -- run query on database
  dbms_output.put_line(basex_client.bx_execute(v_sess, 'xquery collection(''database'')'));

  -- define input stream
  v_inpt := '<x>Hello Replacement!</x>';

  -- add document
  basex_client.bx_replace(v_sess, 'universe.xml', v_inpt);
  dbms_output.put_line(basex_client.bx_info);

  -- run query on database
  dbms_output.put_line(basex_client.bx_execute(v_sess, 'xquery collection(''database'')'));

  -- drop database
  v_outp := basex_client.bx_execute(v_sess, 'drop db database');

  basex_client.close_session(v_sess);

end;
/
