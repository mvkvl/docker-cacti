<?php

/*
/* make sure these values reflect your actual database/host/user/password */

$database_type     = 'mysql';
$database_default  = '%DB_NAME%';
$database_hostname = '%DB_HOST%';
$database_username = '%DB_USER%';
$database_password = '%DB_PASSWORD%';
$database_port     = '3306';
$database_ssl      = false;

/* when the cacti server is a remote poller, then these entries point to
 * the main cacti server.  otherwise, these variables have no use.
 * and must remain commented out. */

#$rdatabase_type     = 'mysql';
#$rdatabase_default  = 'cacti';
#$rdatabase_hostname = 'localhost';
#$rdatabase_username = 'cactiuser';
#$rdatabase_password = 'cactiuser';
#$rdatabase_port     = '3306';
#$rdatabase_ssl      = false;

/* the poller_id of this system.  set to '1' for the main cacti
 * web server.  otherwise, you this value should be the poller_id
 * for the remote poller. */

$poller_id = 1;

/* set the $url_path to point to the default URL of your cacti
 * install ex: if your cacti install as at
 * http://serverip/cacti/ this would be set to /cacti/.
*/

$url_path = '/cacti/';

/* default session name - session name must contain alpha characters */

$cacti_session_name = 'Cacti';

/* save sessions to a database for load balancing */

$cacti_db_session = false;

/* optional parameters to define scripts and resource paths.  these
 * variables become important when using remote poller installs
 * when the scripts and resource files are not in the main cacti
 * web server path. */

//$scripts_path = '/var/www/html/cacti/scripts';
//$resource_path = '/var/www/html/cacti/resource/';
