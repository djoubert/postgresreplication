# postgresreplication

Experiment to setup postgres replication using docker containers.

Submission notes
-----------------
Configuring a VM through an install script is acceptable for quick work, but should really be done through a configuration framework such as ansible.

Postgres containers are launched with no password checking, which is obviously a bad idea but for the purpose of the experiment it's just easier.

Usage of the term master should be phased out in favour of primary or other such terms to be in-line with accepted practices.

This submission is admittedly a bit rough and can be cleaned up in the following ways:
- Setting up the pg_hba.conf on the master-db to accept all incoming connections was necessary because postgres wasn't accepting docker hostnames.
- Setting up the configuration using psql alter statements should be replaces with configuring the conf files directly.
