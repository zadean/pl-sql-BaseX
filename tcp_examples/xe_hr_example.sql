-- xe_hr_example.sql
-- grant select on hr.employees to <user>;
-- grant select on hr.departments to <user>;
-- grant select on hr.jobs to <user>;
-- grant select on hr.locations to <user>;
-- grant select on hr.countries to <user>;
-- grant select on hr.regions to <user>;
set serverout on
declare
  v_sess utl_tcp.connection;
  v_inpt clob;
  v_outp clob;
begin
  v_sess := basex_client.open_session('localhost', 1984, 'admin', 'admin');

  -- create empty database
  v_outp := basex_client.bx_execute(v_sess, 'create db HR');
  dbms_output.put_line(basex_client.bx_info);

  for rec in (
    SELECT 
      e.employee_id as emp_id,
      xmlelement("employee", 
        xmlattributes(e.employee_id AS "id", 
                      e.job_id AS "jobId", 
                      e.manager_id AS "managerId"
                      ), 
        xmlelement("job",
          xmlattributes(e.job_id AS "id"), 
          j.job_title
        ),
        xmlelement("salary",
          xmlattributes(e.commission_pct AS "commissionPct"), 
          e.salary
        ),
        xmlelement("name",
          xmlelement("first", e.first_name),
          xmlelement("last", e.last_name)
        ),
        xmlelement("department", 
          xmlattributes(e.department_id AS "id", d.department_name as "name"),
          xmlelement("location", 
            xmlattributes(d.location_id AS "id"),
            xmlelement("region", r.region_name),
            xmlelement("country",
              xmlattributes(l.country_id as "id"),
              c.country_name
            ),
            xmlelement("stateProvince", l.state_province),
            xmlelement("city", l.city)
          )
        ) 
      ) AS xout
    FROM hr.employees e,
      hr.departments d,
      hr.jobs j,
      hr.locations l,
      hr.countries c,
      hr.regions r
    WHERE e.department_id = d.department_id
    AND d.location_id     = l.location_id
    AND l.country_id      = c.country_id
    AND c.region_id       = r.region_id
    AND j.job_id          = e.job_id
  ) loop
    -- define input stream
    v_inpt := rec.xout.getClobVal();
  
    -- add document
    basex_client.bx_add(v_sess, rec.emp_id || '.xml', v_inpt);
    dbms_output.put_line(basex_client.bx_info);
  end loop;

  -- run query on database
  dbms_output.put_line(basex_client.bx_execute(v_sess, 'xquery count(collection(''HR''))'));

  -- drop database
  v_outp := basex_client.bx_execute(v_sess, 'drop db HR');
  dbms_output.put_line(basex_client.bx_info);

  basex_client.close_session(v_sess);
end;
/
