create or replace package basex_client
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
