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
	
WARNING: This is obviously *not* an ideal situation. At this point I recommend
that you do everything possible to keep this file from getting to deployed
to your actual production Web sites. I almost never run my unit tests on an
actual server; I'm generally testing code on a development workstation
where the risk of malicious manipulation is relatively low, as is the potential
damage from a compromise.

This could become more of a problem in cases Continuous Integration (CI)
server deployments, which by definition need to be able to run the testing
suite. If you are in this type of situation and would like to help develop a
solution to this problem please let me know.