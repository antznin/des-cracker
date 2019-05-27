USER = godard

doc:
	doxygen cracker_doc.conf

send_doc:
	scp -r /tmp/doxygen/html/* $(USER)@ssh.eurecom.fr:~/htdocs/
