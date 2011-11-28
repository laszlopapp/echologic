
# SMTP data should be set as environmental variables in development mode (ECHO_SMTP_HOST, etc.)
SMTP_DOMAIN ||= 'secret_smtp_domain'
SMTP_HOST ||= 'secret_smtp_host'
SMTP_USER ||= 'secret_smtp_user'
SMTP_PASS ||= 'secret_smtp_pass'