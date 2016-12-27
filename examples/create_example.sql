-- create_example.sql
set serverout on
declare
  v_inpt clob;
  v_outp clob;
begin
  -- create the session
  basex_client.open_session('localhost', 1984, 'admin', 'admin');

  -- initialize output clobs
  dbms_lob.createTemporary(v_outp, true);

  -- define input stream
  v_inpt := '<xml>Hello World!</xml>';

  -- create new database
  basex_client.bx_create('database', v_inpt);
  dbms_output.put_line(basex_client.bx_info);

  -- run query on database
  basex_client.bx_execute('xquery doc(''database'')', v_outp);
  dbms_output.put_line(v_outp);

  -- drop database
  basex_client.bx_execute('drop db database', v_outp);
  dbms_output.put_line(basex_client.bx_info);

  -- close session
  basex_client.close_session();
end;
/
