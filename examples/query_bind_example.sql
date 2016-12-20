-- query_bind_example.sql
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
  v_inpt := 'declare variable $name external; for $i in 1 to 10 return element { $name } { $i }';

  -- get the query ID
  v_qyid := basex_client.bx_query(v_inpt);

  -- bind a value
  basex_client.q_bind(v_qyid, '$name', 'number');

  -- get the query results
  basex_client.q_results(v_qyid, v_outp);
  dbms_output.put_line(v_outp);

  -- close query
  basex_client.q_close(v_qyid);
  
  -- close session
  basex_client.close_session();
end;
/
