-- example.sql
set serverout on
declare
  v_inpt clob;
  v_outp clob;
begin
  -- create the session
  basex_client.open_session('localhost', 1984, 'admin', 'admin');

  -- initialize output clobs
  dbms_lob.createTemporary(v_outp, true);

  -- perform command
  basex_client.bx_execute('info', v_outp);
  dbms_output.put_line(v_outp);

  -- close session
  basex_client.close_session();
end;
/
