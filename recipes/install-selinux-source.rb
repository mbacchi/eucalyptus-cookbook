
# only run this recipe if source installation is also being performed
if node['eucalyptus']['install-type'] == 'sources'

  ############################
  # Install eucalyptus-selinux
  ############################

  source_directory = "#{node['eucalyptus']["home-directory"]}/source"

  build_selinux_command = "make all && make reload && make relabel"
  execute "Build and install eucalyptus-selinux" do
    command build_selinux_command
    cwd "#{node['eucalyptus']["home-directory"]}/source/eucalyptus-selinux"
    action :nothing
  end

  reload_relabel_selinux_command = "make reload && make relabel"
  execute "Reload and relabel selinux source repo" do
    command reload_relabel_selinux_command
    cwd "#{node['eucalyptus']["home-directory"]}/source/eucalyptus-selinux"
    action :nothing
  end

  git "#{source_directory}/eucalyptus-selinux" do
    repository node['eucalyptus']['selinux-repo']
    revision node['eucalyptus']['selinux-branch']
    action :sync
    notifies :run, 'execute[Build and install eucalyptus-selinux]', :immediately
  end

end
