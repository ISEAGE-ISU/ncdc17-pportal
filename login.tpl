<% (if (not cor) %>
<h1>You fucked it up!</h1>
<% ) %>

<form action="/do_login" method="GET">
	<label>Patient ID</label>
	<input type="text" name="pid"/>
	<label>PIN</label>
	<input type="password" name="pin"/>
	<input type="Submit" value="Log in"/>
</form>
