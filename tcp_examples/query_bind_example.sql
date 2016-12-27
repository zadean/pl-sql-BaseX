-- query_bind_example.sql
set serverout on
declare
  v_sess utl_tcp.connection;
  v_inpt varchar2(4000);
  v_qyid varchar2(25);
  v_outp clob;
begin
  v_sess := basex_client.open_session('localhost', 1984, 'admin', 'admin');

  v_inpt := 'declare variable $name external; for $i in 1 to 10 return element { $name } { $i }';

  v_qyid := basex_client.bx_query(v_sess, v_inpt);
  basex_client.q_bind(v_sess, v_qyid, '$name', 'number');

  dbms_output.put_line(basex_client.q_execute(v_sess, v_qyid));

  basex_client.close_session(v_sess);
end;
/
