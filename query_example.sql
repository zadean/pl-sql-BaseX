-- query_example.sql
set serverout on
declare
  v_sess utl_tcp.connection;
  v_inpt varchar2(4000);
  v_qyid varchar2(25);
  v_outp clob;
begin
  v_sess := basex_client.open_session('localhost', 1984, 'admin', 'admin');

  v_inpt := 'for $i in 1 to 10 return <xml>Text { $i }</xml>';

  v_qyid := basex_client.bx_query(v_sess, v_inpt);

  while (basex_client.q_more(v_sess, v_qyid)) loop
    dbms_output.put_line(basex_client.q_next(v_sess, v_qyid));
  end loop;

  dbms_output.put_line(basex_client.q_info(v_sess, v_qyid));

  basex_client.close_session(v_sess);
end;
/
