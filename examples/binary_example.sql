-- binary_example.sql
set serverout on
declare
  v_inpt clob;
  v_blobin  blob;
  v_blobout blob;
  v_outp clob;
begin
  -- create the session
  basex_client.open_session('localhost', 1984, 'admin', 'admin');

  -- initialize output clobs
  dbms_lob.createTemporary(v_outp, true);
  dbms_lob.createTemporary(v_blobout, true);

  -- create empty database
  basex_client.bx_execute('create db database', v_outp);
  dbms_output.put_line(basex_client.bx_info);

  -- define input stream
  for i in 0 .. 255 loop
    v_inpt := v_inpt || i;
  end loop;
  v_blobin := utl_raw.cast_to_raw(v_inpt);

  -- add document
  basex_client.bx_store('test.bin', v_blobin);
  dbms_output.put_line(basex_client.bx_info);

  -- receive data
  basex_client.bx_retrieve('test.bin', v_blobout);
  
  -- check if equal
  if dbms_lob.compare(v_blobin, v_blobout) = 0 then
    dbms_output.put_line('Stored and retrieved bytes are equal.');
  else
    dbms_output.put_line('Stored and retrieved bytes differ!');
  end if;

  -- drop database
  basex_client.bx_execute('drop db database', v_outp);

  -- close session
  basex_client.close_session();
end;
/
