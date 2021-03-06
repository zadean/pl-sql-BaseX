create or replace package basex_client_tcp
as
  ---------------------------------------------------------------------------
  -- PL/SQL client for BaseX.
  --
  -- Limitations
  --  Only one client session can be handled at a time if result caching is 
  --  used.
  -- 
  -- (C) 2016, Zachary N. Dean (contact[at]zadean[dot]com), BSD License
  ---------------------------------------------------------------------------
  g_info clob;
  ---------------------------------------------------------------------------
  --                        Session functions.                             --
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Creates a client session with the given credentials.
  --
  -- PARAMETERS
  --  host      - hostname  (localhost)
  --  port      - port      (1984)
  --  username  - user name (admin)
  --  pass      - password  (admin)
  -- RETURN
  --  TCP/IP connection handle
  -- EXCEPTIONS
  --  application_error - Access denied
  --  network_error
  ---------------------------------------------------------------------------
  function open_session(host      in varchar2 default 'localhost', 
                        port      in number   default 1984, 
                        username  in varchar2 default 'admin', 
                        pass      in varchar2 default 'admin') 
                        return utl_tcp.connection;
  ---------------------------------------------------------------------------
  -- Closes all open sessions.
  --
  -- PARAMETERS
  --  None
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  None
  ---------------------------------------------------------------------------
  procedure close_all_sessions;
  ---------------------------------------------------------------------------
  -- Closes the session. Sends 'exit' to server.
  --
  -- PARAMETERS
  --  p_conn  - connection to close
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  network_error
  ---------------------------------------------------------------------------
  procedure close_session(p_conn in out nocopy utl_tcp.connection);
  ---------------------------------------------------------------------------
  -- Executes a command and returns the result.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  com     - the command to execute
  -- RETURN
  --  clob containing results
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  function bx_execute(p_conn  in out nocopy utl_tcp.connection, 
                      com                   varchar2) 
                      return clob;
  function bx_execute(p_conn  in out nocopy utl_tcp.connection, 
                      com                   varchar2,
                      is_binary             boolean) 
                      return blob;
  ---------------------------------------------------------------------------
  -- Returns the information for the last run command.
  --
  -- PARAMETERS
  --  None
  -- RETURN
  --  clob containing results
  -- EXCEPTIONS
  --  None
  ---------------------------------------------------------------------------
  function bx_info return clob;
  ---------------------------------------------------------------------------
  -- Creates a database.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_path  - name of the database
  --  p_input - xml input
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  procedure bx_create(p_conn  in out nocopy utl_tcp.connection, 
                      p_path                varchar2, 
                      p_input               clob);
  ---------------------------------------------------------------------------
  -- Adds a document to a database.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_path  - path to resource
  --  p_input - xml input
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  procedure bx_add(p_conn in out nocopy utl_tcp.connection, 
                   p_path               varchar2, 
                   p_input              clob);
  ---------------------------------------------------------------------------
  -- Replaces a document in a database.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_path  - path to resource
  --  p_input - xml input
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  procedure bx_replace(p_conn in out nocopy utl_tcp.connection, 
                       p_path               varchar2, 
                       p_input              clob);
  ---------------------------------------------------------------------------
  -- Stores a binary resource in a database.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_path  - path to resource
  --  p_input - xml input
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  procedure bx_store(p_conn in out nocopy utl_tcp.connection, 
                     p_path               varchar2, 
                     p_input              blob);
  
  ---------------------------------------------------------------------------
  --                          Query functions.                             --
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Registers a query and returns the query id.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_query - the query text
  -- RETURN
  --  query id
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  function bx_query(p_conn in out nocopy utl_tcp.connection, 
                    p_query              clob) 
                    return varchar2;
  ---------------------------------------------------------------------------
  -- Checks for more items in the result cache.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_qid   - the query id
  -- RETURN
  --  true if there are more results
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  function q_more(p_conn in out nocopy utl_tcp.connection, 
                  p_qid  in out nocopy varchar2) 
                  return boolean;
  ---------------------------------------------------------------------------
  -- Gets the next item in the result cache.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_qid   - the query id
  -- RETURN
  --  The next result
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  function q_next(p_conn in out nocopy utl_tcp.connection, 
                  p_qid  in out nocopy varchar2) 
                  return clob;
  ---------------------------------------------------------------------------
  -- Executes this query and returns the entire result.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_qid   - the query id
  -- RETURN
  --  The results
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  function q_execute(p_conn in out nocopy utl_tcp.connection, 
                     p_qid  in out nocopy varchar2) 
                     return clob;
  ---------------------------------------------------------------------------
  -- Returns query info in a string.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_qid   - the query id
  -- RETURN
  --  The info
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  function q_info(p_conn in out nocopy utl_tcp.connection, 
                  p_qid  in out nocopy varchar2) 
                  return clob;
  ---------------------------------------------------------------------------
  -- Returns serialization parameters in a string.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_qid   - the query id
  -- RETURN
  --  clob
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  function q_options(p_conn in out nocopy utl_tcp.connection, 
                     p_qid  in out nocopy varchar2) 
                     return clob;
  ---------------------------------------------------------------------------
  -- Binds a value to an external variable.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_qid   - the query id
  --  p_name  - name of the external variable
  --  p_value - the value to bind
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  procedure q_bind(p_conn in out nocopy utl_tcp.connection, 
                   p_qid  in out nocopy varchar2, 
                   p_name               varchar2, 
                   p_value              clob);
  ---------------------------------------------------------------------------
  -- Binds a value to an external variable with a specific type.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_qid   - the query id
  --  p_name  - name of the external variable
  --  p_value - the value to bind
  --  p_type  - the type of the bound value
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  procedure q_bind(p_conn in out nocopy utl_tcp.connection, 
                   p_qid  in out nocopy varchar2, 
                   p_name               varchar2, 
                   p_value              clob, 
                   p_type               varchar2);
  ---------------------------------------------------------------------------
  -- Binds a value to the context item.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_qid   - the query id
  --  p_value - the context item
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  procedure q_context(p_conn in out nocopy utl_tcp.connection, 
                      p_qid  in out nocopy varchar2, 
                      p_value              clob);
  ---------------------------------------------------------------------------
  -- Binds a value to the context item with a specific type.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_qid   - the query id
  --  p_value - the context item
  --  p_type  - the type of the context item
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  procedure q_context(p_conn in out nocopy utl_tcp.connection, 
                      p_qid  in out nocopy varchar2, 
                      p_value              clob, 
                      p_type               varchar2);
  ---------------------------------------------------------------------------
  -- Closes the query.
  --
  -- PARAMETERS
  --  p_conn  - connection to use
  --  p_qid   - the query id
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  network_error
  --  application_error when result not ok
  ---------------------------------------------------------------------------
  procedure q_close(p_conn in out nocopy utl_tcp.connection, 
                    p_qid  in out nocopy varchar2);
end;
/
create or replace package body basex_client_tcp
is
  ---------------------------------------------------------------------------
  -- Global query and result cache for iterating results.
  -- If more than one session is open, the query ids can collide and
  -- give unexpected results.
  ---------------------------------------------------------------------------
  type t_cache is table of clob index by pls_integer;
  type r_query is record
  (
    pos       number,
    res_cache t_cache
  );
  -- index by query id
  type t_query is table of r_query index by varchar2(25);
  g_query t_query;
  --
  C_0        constant char := chr(0);  
  C_QUERY    constant char := chr(0);
  C_CLOSE    constant char := chr(2);
  C_BIND     constant char := chr(3);
  C_RESULTS  constant char := chr(4);
  C_EXEC     constant char := chr(5);
  C_INFO     constant char := chr(6);
  C_OPTIONS  constant char := chr(7);
  C_CREATE   constant char := chr(8);
  C_ADD      constant char := chr(9);
  C_REPLACE  constant char := chr(12);
  C_STORE    constant char := chr(13);
  C_CONTEXT  constant char := chr(14);
  C_UPDATING constant char := chr(30);
  C_FULL     constant char := chr(31);
  ---------------------------------------------------------------------------
  -- PRIVATE 
  ---------------------------------------------------------------------------
  function md5(str varchar2) return varchar2
  as
  begin
    return 
      lower(
        rawtohex(
          dbms_crypto.hash(utl_raw.cast_to_raw(str), dbms_crypto.HASH_MD5)
        )
      );
    exception
    when others then
      dbms_output.put_line(sqlerrm);
      raise;
  end;
  ---------------------------------------------------------------------------
  procedure write_to_wire(p_conn in out nocopy utl_tcp.connection, p_text clob)
  as
    l_dummy pls_integer;
    v_len   pls_integer;
    buffer varchar2(4000);
    head   pls_integer := 1;
    chunk  pls_integer := 4000;
  begin
    v_len := dbms_lob.getLength(p_text);
    while (head <= v_len) loop
      dbms_lob.read(p_text, chunk, head, buffer);
      l_dummy := utl_tcp.write_text(p_conn, buffer);
      head := head + chunk;
    end loop;
    l_dummy := utl_tcp.write_line(p_conn);
    utl_tcp.flush(p_conn);
  end;
  ---------------------------------------------------------------------------
  procedure write_to_wire(p_conn in out nocopy utl_tcp.connection, p_bin blob)
  as
    l_dummy pls_integer;
    v_len   pls_integer;
    buffer  raw(1000);
    head    pls_integer := 1;
    chunk   pls_integer := 1000;
  begin
    v_len := dbms_lob.getLength(p_bin);
    while (head <= v_len) loop
      dbms_lob.read(p_bin, chunk, head, buffer);
      l_dummy := utl_tcp.write_raw(p_conn, buffer);
      head := head + chunk;
    end loop;
    l_dummy := utl_tcp.write_line(p_conn);
    utl_tcp.flush(p_conn);
  end;
  ---------------------------------------------------------------------------
  function read_string(p_conn in out nocopy utl_tcp.connection) return clob
  as
    v_tmp clob;
    b     varchar2(1);
    buff  varchar2(32000);
    sz    pls_integer := 0;
  begin
    -- success?
    b := utl_tcp.get_text(c => p_conn, len => 1, peek => false);
    if b = C_0 then
      return null;
    else
      buff := b;
      sz := 1;
    end if;
    dbms_lob.createtemporary(v_tmp, true);
    -- wait until data is there, or timeout
    while (utl_tcp.available(p_conn, 1) > 0 and utl_tcp.get_text(c => p_conn, len => 1, peek => true) != C_0)
    loop
      if sz = 32000 then
        sz := 0;
        dbms_lob.append(v_tmp, buff);
        buff := '';
      end if;
      buff := buff || utl_tcp.get_text(c => p_conn, len => 1, peek => false);
      sz := sz + 1;
    end loop;
    dbms_lob.append(v_tmp, buff);
    -- remove the 0 that kicked us out
    b := utl_tcp.get_text(c => p_conn, len => 1, peek => false);
    return v_tmp;
  end;
  ---------------------------------------------------------------------------
  function read_binary(p_conn in out nocopy utl_tcp.connection) return blob
  as
    b         varchar2(1);
    blob_buff blob := null;
  begin
    dbms_lob.createtemporary(blob_buff,true);
    -- wait until data is there, or timeout
    while (utl_tcp.get_text(c => p_conn, len => 1, peek => true) != C_0)
    loop
      dbms_lob.writeappend(blob_buff, 1, utl_tcp.get_raw(p_conn));
    end loop;
    -- remove the 0 that kicked us out
    b := utl_tcp.get_text(c => p_conn, len => 1, peek => false);
    return blob_buff;
  end;
  ---------------------------------------------------------------------------
  function ok(p_conn in out nocopy utl_tcp.connection) return boolean
  as
  begin
    return read_string(p_conn) is null;
  exception when others then
    return false;
  end;
  ---------------------------------------------------------------------------
  procedure send_command(p_conn in out nocopy utl_tcp.connection, code char, arg varchar2, input clob)
  as
  begin
    write_to_wire(p_conn, code || arg);
    write_to_wire(p_conn, input);
    g_info  := read_string(p_conn);
    if ok(p_conn) then
      null;
    else
      raise_application_error (-20002, 'Could not execute command.');
    end if;
  end;
  ---------------------------------------------------------------------------
  procedure send_command(p_conn in out nocopy utl_tcp.connection, code char, arg varchar2, input blob)
  as
  begin
    write_to_wire(p_conn, code || arg);
    write_to_wire(p_conn, input);
    g_info  := read_string(p_conn);
    if ok(p_conn) then
      null;
    else
      raise_application_error (-20002, 'Could not execute command.');
    end if;
  end;
  ---------------------------------------------------------------------------
  procedure send_void_command(p_conn in out nocopy utl_tcp.connection, p_command char, p_arg clob)
  as
    v_tmp clob;
  begin
    dbms_lob.createtemporary(v_tmp, true);
    dbms_lob.append(v_tmp, p_command);
    dbms_lob.append(v_tmp, p_arg);
    write_to_wire(p_conn, v_tmp);
  end;
  ---------------------------------------------------------------------------
  -- PUBLIC 
  ---------------------------------------------------------------------------
  function open_session(host varchar2, port number, username varchar2, pass varchar2) return utl_tcp.connection
  as
    v_conn   utl_tcp.connection;
    response varchar2(200);
    nonce    varchar2(16);
    code     varchar2(150);
    pos      binary_integer;
  begin
    -- get the connection
    v_conn    := utl_tcp.open_connection(remote_host => host, remote_port => port, charset => 'UTF8', newline => C_0, tx_timeout => 1 ); 
    response  := read_string(v_conn);
    pos       := instr(response,':');
    -- digest
    if pos    > -1 then
      code  := username || ':' || substr(response, 1, pos - 1) || ':' || pass;
      nonce := substr(response, pos + 1);
    -- md5
    else
      code  := pass;
      nonce := response;
    end if;
    -- send username and hashed password/timestamp
    write_to_wire(v_conn, username || C_0 || md5(md5(code) || nonce));
    -- receive success flag
    if ok(v_conn) then
      return v_conn;
    else
      raise_application_error (-20001, 'Access denied.');
    end if;
  end;
  ---------------------------------------------------------------------------
  function bx_execute(p_conn  in out nocopy utl_tcp.connection, 
                      com                   varchar2) 
                      return clob
  as
    l_result clob;
  begin
    write_to_wire(p_conn, com);
    l_result  := read_string(p_conn);
    g_info := read_string(p_conn);
    if ok(p_conn) then
      return l_result;
    else
      raise_application_error (-20002, 'Could not execute command. ' || g_info);
    end if;
  end;
  ---------------------------------------------------------------------------
  function bx_execute(p_conn  in out nocopy utl_tcp.connection, 
                      com                   varchar2,
                      is_binary             boolean) 
                      return blob
  as
    l_result blob;
  begin
    write_to_wire(p_conn, com);
    l_result  := read_binary(p_conn);
    g_info := read_string(p_conn);
    if ok(p_conn) then
      return l_result;
    else
      raise_application_error (-20002, 'Could not execute command. ' || g_info);
    end if;
  end;
  ---------------------------------------------------------------------------
  procedure bx_create(p_conn  in out nocopy utl_tcp.connection, 
                      p_path                varchar2, 
                      p_input               clob)
  as
  begin
    send_command(p_conn, C_CREATE, p_path, p_input);
  end;
  ---------------------------------------------------------------------------
  procedure bx_add(p_conn in out nocopy utl_tcp.connection, 
                   p_path               varchar2, 
                   p_input              clob)
  as
  begin
    send_command(p_conn, C_ADD, p_path, p_input);
  end;
  ---------------------------------------------------------------------------
  procedure bx_replace(p_conn in out nocopy utl_tcp.connection, 
                       p_path               varchar2, 
                       p_input              clob)
  as
  begin
    send_command(p_conn, C_REPLACE, p_path, p_input);
  end;
  ---------------------------------------------------------------------------
  procedure bx_store(p_conn in out nocopy utl_tcp.connection, 
                     p_path               varchar2, 
                     p_input              blob)
  as
  begin
    send_command(p_conn, C_STORE, p_path, p_input);
  end;
  ---------------------------------------------------------------------------
  function bx_info return clob
  as
  begin
    return g_info;
  end;
  ---------------------------------------------------------------------------
  procedure close_all_sessions
  as
  begin
    utl_tcp.close_all_connections;
  end;
  ---------------------------------------------------------------------------
  procedure close_session(p_conn in out nocopy utl_tcp.connection)
  as
  begin
    write_to_wire(p_conn, 'exit');  
    utl_tcp.close_connection(p_conn);
  end;
  ---------------------------------------------------------------------------
  -- PRIVATE Query functions
  ---------------------------------------------------------------------------
  function q_exec(p_conn in out nocopy utl_tcp.connection, p_command char, p_arg clob) return clob
  as
    retval clob;
  begin
    send_void_command(p_conn, p_command, p_arg);
    retval := read_string(p_conn);
    if ok(p_conn) then
      return retval;
    else
      raise_application_error (-20003, 'Unexpected result. ' || read_string(p_conn));
    end if;
  end;
  ---------------------------------------------------------------------------
  function q_exec(p_conn in out nocopy utl_tcp.connection, p_qid varchar2, p_command char, p_arg clob) return clob
  as
  begin
    return q_exec(p_conn, p_command, p_arg);
  end;
  ---------------------------------------------------------------------------
  procedure q_exec(p_conn in out nocopy utl_tcp.connection, p_command char, p_arg clob)
  as
    dummy clob;
  begin
    dummy := q_exec(p_conn, p_command, p_arg);
  end;
  ---------------------------------------------------------------------------
  procedure q_exec(p_conn in out nocopy utl_tcp.connection, p_qid varchar2, p_command char, p_arg clob)
  as
    dummy clob;
  begin
    dummy := q_exec(p_conn, p_command, p_arg);
  end;
  ---------------------------------------------------------------------------
  -- PUBLIC Query functions
  ---------------------------------------------------------------------------
  function bx_query(p_conn in out nocopy utl_tcp.connection, 
                    p_query              clob) 
                    return varchar2
  as
    l_id varchar2(25);
  begin
    l_id                    := q_exec(p_conn, C_QUERY, p_query);
    g_query(l_id).pos       := 0;
    g_query(l_id).res_cache.delete;
    return l_id;
  end;
  ---------------------------------------------------------------------------
  function q_more(p_conn in out nocopy utl_tcp.connection, 
                  p_qid  in out nocopy varchar2) 
                  return boolean
  as
  begin
    if g_query(p_qid).res_cache.count = 0 then
      send_void_command(p_conn, C_RESULTS, p_qid);
      while (utl_tcp.get_text(c => p_conn, len => 1, peek => false) != C_0)
      loop
        g_query(p_qid).res_cache(g_query(p_qid).res_cache.count + 1 ) := read_string(p_conn);
      end loop;
      if ok(p_conn) then
        null;
      else
        raise_application_error (-20003, read_string(p_conn));
      end if;
      g_query(p_qid).pos := 1;
    end if;
    if g_query(p_qid).pos <= g_query(p_qid).res_cache.count then
      return true;
    end if;
    g_query(p_qid).res_cache.delete;
    return false;
  end;
  ---------------------------------------------------------------------------
  function q_next(p_conn in out nocopy utl_tcp.connection, 
                  p_qid  in out nocopy varchar2) 
                  return clob
  as
    retval clob;
  begin
    if q_more(p_conn, p_qid) then
      retval := g_query(p_qid).res_cache(g_query(p_qid).pos);
      g_query(p_qid).res_cache(g_query(p_qid).pos) := null;
      g_query(p_qid).pos := g_query(p_qid).pos +1;
      return retval;
    else
      return null;
    end if;
  end;
  ---------------------------------------------------------------------------
  function q_execute(p_conn in out nocopy utl_tcp.connection, 
                     p_qid  in out nocopy varchar2) 
                     return clob
  as
  begin
    return q_exec(p_conn, p_qid, C_EXEC, p_qid);
  end;
  ---------------------------------------------------------------------------
  function q_info(p_conn in out nocopy utl_tcp.connection, 
                  p_qid  in out nocopy varchar2) 
                  return clob
  as
  begin
    return q_exec(p_conn, p_qid, C_INFO, p_qid);
  end;
  ---------------------------------------------------------------------------
  function q_options(p_conn in out nocopy utl_tcp.connection, 
                     p_qid  in out nocopy varchar2) 
                     return clob
  as
  begin
    return q_exec(p_conn, p_qid, C_OPTIONS, p_qid);
  end;
  ---------------------------------------------------------------------------
  procedure q_bind(p_conn in out nocopy utl_tcp.connection, 
                   p_qid  in out nocopy varchar2, 
                   p_name               varchar2, 
                   p_value              clob)
  as
  begin
    q_bind(p_conn, p_qid, p_name, p_value, '');
  end;
  ---------------------------------------------------------------------------
  procedure q_bind(p_conn in out nocopy utl_tcp.connection, 
                   p_qid  in out nocopy varchar2, 
                   p_name               varchar2, 
                   p_value              clob, 
                   p_type               varchar2)
  as
    v_tmp clob;
  begin
    dbms_lob.createtemporary(v_tmp, true);
    dbms_lob.append(v_tmp, p_qid || C_0);
    dbms_lob.append(v_tmp, p_name || C_0);
    dbms_lob.append(v_tmp, p_value);
    dbms_lob.append(v_tmp, C_0);
    if p_type is not null then
      dbms_lob.append(v_tmp, p_type);
    end if;
    g_query(p_qid).res_cache.delete;
    q_exec(p_conn, p_qid, C_BIND, v_tmp);
  end;
  ---------------------------------------------------------------------------
  procedure q_context(p_conn in out nocopy utl_tcp.connection, 
                      p_qid  in out nocopy varchar2, 
                      p_value              clob)
  as
  begin
    q_context(p_conn, p_qid, p_value, '');
  end;
  ---------------------------------------------------------------------------
  procedure q_context(p_conn in out nocopy utl_tcp.connection, 
                      p_qid  in out nocopy varchar2, 
                      p_value              clob, 
                      p_type               varchar2)
  as
    v_tmp clob;
  begin
    dbms_lob.createtemporary(v_tmp, true);
    dbms_lob.append(v_tmp, p_qid || C_0);
    dbms_lob.append(v_tmp, p_value);
    dbms_lob.append(v_tmp, C_0);
    if p_type is not null then
      dbms_lob.append(v_tmp, p_type);
    end if;
    g_query(p_qid).res_cache.delete;
    q_exec(p_conn, p_qid, C_CONTEXT, v_tmp);
  end;
  ---------------------------------------------------------------------------
  procedure q_close(p_conn in out nocopy utl_tcp.connection, 
                    p_qid  in out nocopy varchar2)
  as
  begin
    q_exec(p_conn, p_qid, C_CLOSE, p_qid);
  end;
  ---------------------------------------------------------------------------
end;
/
show errors