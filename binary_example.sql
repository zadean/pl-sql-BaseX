-- binary_example.sql
set serverout on
declare
  v_sess utl_tcp.connection;
  v_inpt varchar2(4000);
  v_blobin  blob;
  v_blobout blob;
  v_outp clob;
begin
  v_sess := basex_client.open_session('localhost', 1984, 'admin', 'admin');

  -- create empty database
  v_outp := basex_client.bx_execute(v_sess, 'create db database');
  dbms_output.put_line(basex_client.bx_info);

  -- define input stream
  for i in 0 .. 255 loop
    v_inpt := v_inpt || i;
  end loop;
  v_blobin := utl_raw.cast_to_raw(v_inpt);

  -- add document
  basex_client.bx_store(v_sess, 'test.bin', v_blobin);
  dbms_output.put_line(basex_client.bx_info);

  -- receive data
  v_blobout := basex_client.bx_execute(v_sess, 'retrieve test.bin', true);
  
  if dbms_lob.compare(v_blobin, v_blobout) = 0 then
    dbms_output.put_line('Stored and retrieved bytes are equal.');
  else
    dbms_output.put_line('Stored and retrieved bytes differ!');
  end if;

  -- drop database
  v_outp := basex_client.bx_execute(v_sess, 'drop db database');
exception when others then
  basex_client.close_session(v_sess);
  dbms_output.put_line(sqlerrm);
end;
/
