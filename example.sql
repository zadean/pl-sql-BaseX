-- example.sql
set serverout on
declare
  v_sess utl_tcp.connection;
  v_inpt varchar2(4000);
  v_outp clob;
begin
  v_sess := basex_client.open_session('localhost', 1984, 'admin', 'admin');

  dbms_output.put_line(basex_client.bx_execute(v_sess, 'info'));

  basex_client.close_session(v_sess);
end;
/
