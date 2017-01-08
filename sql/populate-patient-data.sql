CREATE TABLE base (id TEXT, fname TEXT, lname TEXT);
CREATE TABLE pdata (id TEXT, fname TEXT, lname TEXT, pin TEXT);

CREATE FUNCTION update_patient_data () RETURNS void AS $$
DECLARE
	upstream_pdata JSON;
	api_url TEXT;
BEGIN
	SELECT value::text || 'get_patient_data.php' INTO api_url
		FROM config WHERE key='api_url';

	SELECT content::json->'patients' INTO upstream_pdata
		FROM http_get(api_url);

	DELETE FROM pdata;
	INSERT INTO pdata (id, fname, lname, pin)
		SELECT id, fname, lname, (((id::int * 197) % 9000) + 1000)::text 
			FROM json_populate_recordset(null::base, upstream_pdata);
END; $$
LANGUAGE plpgsql;
