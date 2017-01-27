# verify prereqs are installed
prereqs = %w{git make createrepo_c}
prereqs.each do |item|
  yum_package item do
    options node['eucalyptus']['yum-options']
    action :install
  end
end

git "docker-yumrepo" do
  destination "#{node['eucalyptus']['home-directory']}/docker-yumrepo/"
  repository "https://github.com/mbacchi/docker-yumrepo.git"
  action :sync
end

docker_installation 'default' do
  action :create
end

docker_service_manager 'default' do
  action :start
end

# make src directory to place rpms into
execute "make src in docker-yumrepo" do
  command "make src"
  cwd "#{node['eucalyptus']['home-directory']}/docker-yumrepo/"
end

rpmlist = %w{http://builds.qa1.eucalyptus-systems.com/packages/tags/eucalyptus-4.4/rhel/7/x86_64/qemu-kvm-ev-2.3.0-31.el7_2.21.1.x86_64.rpm 
              http://builds.qa1.eucalyptus-systems.com/packages/tags/eucalyptus-4.4/rhel/7/x86_64/qemu-kvm-common-ev-2.3.0-31.el7_2.21.1.x86_64.rpm
              http://builds.qa1.eucalyptus-systems.com/packages/tags/eucalyptus-4.4/rhel/7/x86_64/qemu-img-ev-2.3.0-31.el7_2.21.1.x86_64.rpm}

rpmlist.each do |item|
  execute "wget rpms" do
    command "wget #{item}"
    cwd "#{node['eucalyptus']['home-directory']}/docker-yumrepo/src/"
  end
end

# eventually try to integrate docker_image resource from 
# https://github.com/chef-cookbooks/docker#docker_image
# but for now lets use the Makefile rules

# build docker image
execute "make build in docker-yumrepo" do
  command "make build"
  cwd "#{node['eucalyptus']['home-directory']}/docker-yumrepo/"
end

# run docker image
execute "make run in docker-yumrepo" do
  command "make run"
  cwd "#{node['eucalyptus']['home-directory']}/docker-yumrepo/"
end
