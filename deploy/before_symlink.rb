
run "rm #{release_path}/config/rpx_config.rb"
run "ln -nfs #{shared_path}/config/rpx_config.rb #{release_path}/config/rpx_config.rb"
run "rm #{release_path}/config/smtp_config.rb"
run "ln -nfs #{shared_path}/config/smtp_config.rb #{release_path}/config/smtp_config.rb"
