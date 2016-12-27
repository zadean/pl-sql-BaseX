-- add_example.sql
set serverout on
declare
  v_inpt clob;
  v_outp clob;
begin
  -- create the session
  basex_client.open_session('localhost', 1984, 'admin', 'admin');
  
  -- initialize output clob
  dbms_lob.createTemporary(v_outp, true);
  
  -- create empty database
  basex_client.bx_execute('create db database', v_outp);
  dbms_output.put_line(basex_client.bx_info);

  -- define input stream
  v_inpt := '<x>Hello World!</x>';

  -- add document
  basex_client.bx_add('world/world.xml', v_inpt);
  dbms_output.put_line(basex_client.bx_info);

  -- define input stream
  v_inpt := '<x>Hello Universe!</x>';

  -- add document
  basex_client.bx_add('universe.xml', v_inpt);
  dbms_output.put_line(basex_client.bx_info);

  -- run query on database
  basex_client.bx_execute('xquery collection(''database'')', v_outp);
  dbms_output.put_line(v_outp);

  -- define input stream
  v_inpt := '<x>Hello Replacement!</x>';

  -- add document
  basex_client.bx_replace('universe.xml', v_inpt);
  dbms_output.put_line(basex_client.bx_info);

  -- run query on database
  basex_client.bx_execute('xquery collection(''database'')', v_outp);
  dbms_output.put_line(v_outp);

  -- delete document
  basex_client.bx_delete('world/world.xml', v_inpt);
  dbms_output.put_line(basex_client.bx_info);

  -- run query on database
  basex_client.bx_execute('xquery collection(''database'')', v_outp);
  dbms_output.put_line(v_outp);

  -- drop database
  basex_client.bx_execute('drop db database', v_outp);
  dbms_output.put_line(basex_client.bx_info);

  -- close session
  basex_client.close_session;
end;
/
