<% (if (not cor) %>
<h1>You fucked it up!</h1>
<% ) %>

<form action="/do_login" method="GET">
	<label>Username</label>
	<input type="text" name="uname"/>
	<label>PIN</label>
	<input type="password" name="pin"/>
	<input type="Submit" value="Log in"/>
</form>
