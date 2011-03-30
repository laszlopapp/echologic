
run "rm #{release_path}/config/rpx_config.rb"
run "ln -nfs #{shared_path}/config/rpx_config.rb #{release_path}/config/rpx_config.rb"
