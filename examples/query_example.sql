-- query_example.sql
set serverout on
declare
  v_inpt clob;
  v_qyid varchar2(25);
  v_outp clob;
begin
  -- create the session
  basex_client.open_session('localhost', 1984, 'admin', 'admin');

  -- initialize output clobs
  dbms_lob.createTemporary(v_outp, true);

  -- set the query text
  v_inpt := 'for $i in 1 to 10 return <xml>Text { $i }</xml>';

  -- get the query ID
  v_qyid := basex_client.bx_query(v_inpt);

  -- loop query results
  while (basex_client.q_more(v_qyid)) loop
    basex_client.q_next(v_qyid, v_outp);
    dbms_output.put_line(v_outp);
  end loop;

  dbms_output.put_line(basex_client.q_info(v_qyid));

  -- close query
  basex_client.q_close(v_qyid);

  -- close session
  basex_client.close_session();
end;
/
