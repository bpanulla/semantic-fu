In order to run the tests in this suite successfully you must grant the test
components access to the server's CFAdmin API. Several of the tests rely on
a test Derby datasource and will create the datasource at the start of the
test and remove it after completion of the test run. The Derby database files
themselves will be created in the server's temporary directory
(specifically the folder returned by the function getTempDirectory()).

To grant access to the Admin API create a file in the test folder called:

	cfadmin.txt
	
The file should contain a single line with your test server's CF Administrator
credentials, separated by a colon. For example:

	testuser:notmyrealpassword
	
If your server configuration does not require the username argument, leave the
username portion of the string empty and start with the colon delimiter:

	:notmyrealpassword