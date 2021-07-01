# PaaS
paas_app_environment       = "pen"
env_config                 = "pen"
paas_space_name            = "bat-staging"
paas_postgres_service_plan = "tiny-unencrypted-11"
paas_redis_service_plan    = "tiny-ha-5_x"
paas_app_start_timeout     = "180"
paas_web_app_hostname      = "pen"
paas_web_app_instances     = 2
paas_web_app_memory        = 1024
paas_worker_app_instances  = 1
paas_worker_app_memory     = 512
paas_worker_app_stopped    = false

#KeyVault
key_vault_resource_group = "s121t01-shared-rg"

#StatusCake
# statuscake_alerts = {
#   alert = {
#     website_name   = "register-pen"
#     website_url    = "https://pen.register-trainee-teachers.education.gov.uk/ping"
#     test_type      = "HTTP"
#     check_rate     = 60
#     contact_group  = [188603]
#     trigger_rate   = 0
#     node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
#   }
# }