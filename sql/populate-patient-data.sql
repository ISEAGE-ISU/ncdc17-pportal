DROP TABLE IF EXISTS pdata;
DROP TABLE IF EXISTS pdata_base;
DROP TABLE IF EXISTS allergies;
DROP TABLE IF EXISTS allergies_base;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS appointments_base;
DROP TABLE IF EXISTS medical_issues;
DROP TABLE IF EXISTS medical_issues_base;
DROP TABLE IF EXISTS medications;
DROP TABLE IF EXISTS medications_base;

CREATE TABLE pdata_base (id TEXT, fname TEXT, lname TEXT);
CREATE TABLE pdata (id TEXT, fname TEXT, lname TEXT, pin TEXT);

CREATE TABLE allergies_base (title TEXT, comments TEXT);
CREATE TABLE allergies (pid TEXT, title TEXT, comments TEXT);

CREATE TABLE appointments_base (pc_title TEXT, pc_eventDate TEXT, pc_comments TEXT,
	pc_startTime TEXT, pc_endTime TEXT);
CREATE TABLE appointments (pid TEXT, title TEXT, apptdate TEXT, comments TEXT,
	starttime TEXT, endtime TEXT);

CREATE TABLE medical_issues_base (title TEXT);
CREATE TABLE medical_issues (pid TEXT, title TEXT);

CREATE TABLE medications_base (title TEXT);
CREATE TABLE medications (pid TEXT, title TEXT);

CREATE OR REPLACE FUNCTION update_patient_data () RETURNS void AS $$
DECLARE
	upstream_data JSON;
	api_url TEXT;
	p TEXT;
BEGIN
	SELECT value::text INTO api_url FROM config WHERE key='api_url';

	SELECT content::json->'patients' INTO upstream_data
		FROM http_get(api_url || 'get_patient_data.php');

	DELETE FROM pdata;
	INSERT INTO pdata (id, fname, lname, pin)
		SELECT id, fname, lname, (((id::int * 197) % 9000) + 1000)::text 
			FROM json_populate_recordset(null::pdata_base, upstream_data);

	DELETE FROM allergies;
	FOR p IN SELECT id FROM pdata
	LOOP
		SELECT content::json->'allergies' INTO upstream_data
			FROM http_get(api_url || 'get_allergies.php?id=' || p::text);

		INSERT INTO allergies (pid, title, comments)
			SELECT p, title, comments 
			FROM json_populate_recordset(null::allergies_base, upstream_data);
	END LOOP;

	DELETE FROM appointments;
	FOR p IN SELECT id FROM pdata
	LOOP
		SELECT content::json->'appointments' INTO upstream_data
			FROM http_get(api_url || 'get_appointments.php?id=' || p::text);

			INSERT INTO appointments 
				(pid, title, apptdate, comments, starttime, endtime)
			SELECT 
				p, pc_title, pc_eventDate, 
				pc_comments, pc_startTime, pc_endTime
			FROM json_populate_recordset(null::appointments_base, upstream_data);
	END LOOP;

	DELETE FROM medications;
	FOR p IN SELECT id FROM pdata
	LOOP
		SELECT content::json->'medications' INTO upstream_data
			FROM http_get(api_url || 'get_medications.php?id=' || p::text);

		INSERT INTO medications (pid, title)
			SELECT p, title
			FROM json_populate_recordset(null::medications_base, upstream_data);
	END LOOP;

	DELETE FROM medical_issues;
	FOR p IN SELECT id FROM pdata
	LOOP
		SELECT content::json->'medical_issues' INTO upstream_data
			FROM http_get(api_url || 'get_medical_issues.php?id=' || p::text);

		INSERT INTO medical_issues (pid, title)
			SELECT p, title
			FROM json_populate_recordset(null::medical_issues_base, upstream_data);
	END LOOP;
END; $$
LANGUAGE plpgsql;
