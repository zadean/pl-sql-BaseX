create or replace package basex_client
as
  ---------------------------------------------------------------------------
  -- PL/SQL client for BaseX.
  --
  -- Limitations
  --  Only one client session can be handled at a time.
  --
  -- (C) 2016, Zachary N. Dean (contact[at]zadean[dot]com), BSD License
  ---------------------------------------------------------------------------
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
  --  password  - password  (admin)
  -- EXCEPTIONS
  --  java.io.IOException
  -- JAVA
  --  void open(java.lang.String, int, java.lang.String, java.lang.String) throws java.io.IOException
  ---------------------------------------------------------------------------
  procedure open_session(host      in varchar2 ,
                         port      in number   ,
                         username  in varchar2 ,
                         password  in varchar2 ) ;
  ---------------------------------------------------------------------------
  -- Closes the session. Sends 'exit' to server.
  --
  -- PARAMETERS
  --  None
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  None
  -- JAVA
  --  void close()
  ---------------------------------------------------------------------------
  procedure close_session;
  ---------------------------------------------------------------------------
  -- Executes a command and returns the result.
  --
  -- PARAMETERS
  --  command - the command to execute
  --  output  - the results
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  void execute(java.lang.String, java.sql.Clob) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  procedure bx_execute( command in   varchar2,
                        output       clob);
  ---------------------------------------------------------------------------
  -- Returns the information for the last run command.
  --
  -- PARAMETERS
  --  None
  -- RETURN
  --  info string
  -- EXCEPTIONS
  --  None
  -- JAVA
  --  java.lang.String info()
  ---------------------------------------------------------------------------
  function bx_info return varchar2;
  ---------------------------------------------------------------------------
  -- Creates a database.
  --
  -- PARAMETERS
  --  name  - name of the database
  --  input - xml input
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  void create(java.lang.String, java.sql.Clob) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  procedure bx_create(name  in varchar2,
                      input in clob);
  ---------------------------------------------------------------------------
  -- Adds a document to a database.
  --
  -- PARAMETERS
  --  path  - path to resource
  --  input - xml input
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  void add(java.lang.String, java.sql.Clob) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  procedure bx_add(path   in varchar2,
                   input  in clob);
  ---------------------------------------------------------------------------
  -- Replaces a document in a database.
  --
  -- PARAMETERS
  --  path  - path to resource
  --  input - xml input
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  void replace(java.lang.String, java.sql.Clob) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  procedure bx_replace(path   in varchar2,
                       input  in clob);
  ---------------------------------------------------------------------------
  -- Stores a binary resource in a database.
  --
  -- PARAMETERS
  --  path  - path to resource
  --  input - Binary input
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  void store(java.lang.String, java.sql.Blob) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  procedure bx_store(path   in varchar2,
                     input  in blob);
  ---------------------------------------------------------------------------
  -- Gets a binary resource from a database.
  --
  -- PARAMETERS
  --  path    - path to resource
  --  output  - Binary output
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  void retrieve(java.lang.String, java.sql.Blob) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  procedure bx_retrieve(path    in            varchar2,
                        output                blob);
  ---------------------------------------------------------------------------
  -- Deletes all documents from the currently opened database that start with the specified path.
  --
  -- PARAMETERS
  --  path    - path to resource
  --  output  - Output
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  void delete(java.lang.String, java.sql.Clob) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  procedure bx_delete(path    in            varchar2,
                      output                clob);
  ---------------------------------------------------------------------------
  --                          Query functions.                             --
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Registers a query and returns the query id.
  --
  -- PARAMETERS
  --  query - the query text
  -- RETURN
  --  query id
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  java.lang.String query(java.sql.Clob) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  function bx_query(query   clob) return varchar2;
  ---------------------------------------------------------------------------
  -- Checks for more items in the result cache. Fills the cache if empty.
  --
  -- PARAMETERS
  --  queryId   - the query id
  -- RETURN
  --  true if there are more results
  -- EXCEPTIONS
  --  java.io.IOException
  -- JAVA
  --  boolean more(java.lang.String) throws java.io.IOException
  ---------------------------------------------------------------------------
  function q_more(queryId  in varchar2) return boolean;
  ---------------------------------------------------------------------------
  -- Gets the next item in the result cache.
  --
  -- PARAMETERS
  --  queryId   - the query id
  --  output    - the next result
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  void next(java.lang.String, java.sql.Clob) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  procedure q_next(queryId  in varchar2,
                   output      clob);
  ---------------------------------------------------------------------------
  -- Executes this query and returns the entire result.
  --
  -- PARAMETERS
  --  queryId  - the query id
  --  output   - the results
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  void results(java.lang.String, java.sql.Clob) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  procedure q_results(queryId in            varchar2,
                      output                clob);
  ---------------------------------------------------------------------------
  -- Returns query info.
  --
  -- PARAMETERS
  --  queryId   - the query id
  -- RETURN
  --  The info
  -- EXCEPTIONS
  --  java.io.IOException
  -- JAVA
  --  java.lang.String info(java.lang.String) throws java.io.IOException
  ---------------------------------------------------------------------------
  function q_info(queryId  in varchar2) return varchar2;
  ---------------------------------------------------------------------------
  -- Returns serialization parameters.
  --
  -- PARAMETERS
  --  queryId  - the query id
  --  output   - the results
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  void options(java.lang.String, java.sql.Clob) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  procedure q_options(queryId in            varchar2,
                      output                clob);
  ---------------------------------------------------------------------------
  -- Binds a value to an external variable.
  --
  -- PARAMETERS
  --  queryId - the query id
  --  name    - name of the external variable
  --  value   - the value to bind
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  void bind(java.lang.String, java.lang.String, java.sql.Clob) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  procedure q_bind(queryId  in varchar2,
                   name     in varchar2,
                   value    in clob);
  ---------------------------------------------------------------------------
  -- Binds a value to an external variable with a specific type.
  --
  -- PARAMETERS
  --  queryId - the query id
  --  name    - name of the external variable
  --  value   - the value to bind
  --  type    - the type of the bound value
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  void bind(java.lang.String, java.lang.String, java.sql.Clob, java.lang.String) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  procedure q_bind(queryId  in varchar2,
                   name     in varchar2,
                   value    in clob,
                   type     in varchar2);
  ---------------------------------------------------------------------------
  -- Binds a value to the context item.
  --
  -- PARAMETERS
  --  queryId - the query id
  --  value   - the value to bind
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  void context(java.lang.String, java.sql.Clob) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  procedure q_context(queryId  in varchar2,
                      value    in clob);
  ---------------------------------------------------------------------------
  -- Binds a value to the context item with a specific type.
  --
  -- PARAMETERS
  --  queryId - the query id
  --  value   - the value to bind
  --  type    - the type of the bound value
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  java.io.IOException
  --  java.sql.SQLException
  -- JAVA
  --  void context(java.lang.String, java.sql.Clob, java.lang.String) throws java.io.IOException, java.sql.SQLException
  ---------------------------------------------------------------------------
  procedure q_context(queryId  in varchar2,
                      value    in clob,
                      type     in varchar2);
  ---------------------------------------------------------------------------
  -- Closes the query.
  --
  -- PARAMETERS
  --  queryId   - the query id
  -- RETURN
  --  None
  -- EXCEPTIONS
  --  java.io.IOException
  -- JAVA
  --  void close(java.lang.String) throws java.io.IOException
  ---------------------------------------------------------------------------
  procedure q_close(queryId  in varchar2);
end;
/
create or replace package body basex_client
as
  ---------------------------------------------------------------------------
  -- PL/SQL client for BaseX.
  --
  --
  -- (C) 2016, Zachary N. Dean (contact[at]zadean[dot]com), BSD License
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  --                        Session functions.                             --
  ---------------------------------------------------------------------------
  procedure open_session(host      in varchar2 ,
                         port      in number   ,
                         username  in varchar2 ,
                         password  in varchar2 )
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.open(java.lang.String, int, java.lang.String, java.lang.String)';
  ---------------------------------------------------------------------------
  procedure close_session
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.close()';
  ---------------------------------------------------------------------------
  procedure bx_execute( command in varchar2,
                        output     clob)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.execute(java.lang.String, java.sql.Clob)';
  ---------------------------------------------------------------------------
  function bx_info return varchar2
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.info() return java.lang.String';
  ---------------------------------------------------------------------------
  procedure bx_create(name  in varchar2,
                      input in clob)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.create(java.lang.String, java.sql.Clob)';
  ---------------------------------------------------------------------------
  procedure bx_add(path   in varchar2,
                   input  in clob)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.add(java.lang.String, java.sql.Clob)';
  ---------------------------------------------------------------------------
  procedure bx_replace(path   in varchar2,
                       input  in clob)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.replace(java.lang.String, java.sql.Clob)';
  ---------------------------------------------------------------------------
  procedure bx_store(path   in varchar2,
                     input  in blob)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.store(java.lang.String, java.sql.Blob)';
  ---------------------------------------------------------------------------
  procedure bx_retrieve(path    in            varchar2,
                        output                blob)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.retrieve(java.lang.String, java.sql.Blob)';
  ---------------------------------------------------------------------------
  procedure bx_delete(path    in            varchar2,
                      output                clob)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.delete(java.lang.String, java.sql.Clob)';
  ---------------------------------------------------------------------------
  --                          Query functions.                             --
  ---------------------------------------------------------------------------
  function bx_query(query   clob) return varchar2
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.query(java.sql.Clob) return java.lang.String';
  ---------------------------------------------------------------------------
  function q_more(queryId  in varchar2) return boolean
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.more(java.lang.String) return boolean';
  ---------------------------------------------------------------------------
  procedure q_next(queryId  in varchar2,
                   output      clob)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.next(java.lang.String, java.sql.Clob)';
  ---------------------------------------------------------------------------
  procedure q_results(queryId in            varchar2,
                      output                clob)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.results(java.lang.String, java.sql.Clob)';
  ---------------------------------------------------------------------------
  function q_info(queryId  in varchar2) return varchar2
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.info(java.lang.String) return java.lang.String';
  ---------------------------------------------------------------------------
  procedure q_options(queryId in            varchar2,
                      output                clob)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.options(java.lang.String, java.sql.Clob)';
  ---------------------------------------------------------------------------
  procedure q_bind(queryId  in varchar2,
                   name     in varchar2,
                   value    in clob)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.bind(java.lang.String, java.lang.String, java.sql.Clob)';
  ---------------------------------------------------------------------------
  procedure q_bind(queryId  in varchar2,
                   name     in varchar2,
                   value    in clob,
                   type     in varchar2)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.bind(java.lang.String, java.lang.String, java.sql.Clob, java.lang.String)';
  ---------------------------------------------------------------------------
  procedure q_context(queryId  in varchar2,
                      value    in clob)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.context(java.lang.String, java.sql.Clob)';
  ---------------------------------------------------------------------------
  procedure q_context(queryId  in varchar2,
                      value    in clob,
                      type     in varchar2)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.context(java.lang.String, java.sql.Clob, java.lang.String)';
  ---------------------------------------------------------------------------
  procedure q_close(queryId  in varchar2)
  as language java
  name 'com.zadean.oracle.basex.BaseXClient.close(java.lang.String)';
end;
/
show errors