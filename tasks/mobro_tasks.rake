# desc "Explaining what the task does"
# task :mobro do
#   # Task goes here
# end

namespace :mobro do
  desc "Installs mobro.css in your public/stylesheets directory"
  task :install do
    require 'ftools'
    File.copy(File.join(RAILS_ROOT, 'vendor', 'plugins', 'mobro', 'lib', 'public', 'stylesheets', 'mobro.css'),
              File.join(RAILS_ROOT, 'public', 'stylesheets'))
  end
  
  desc "Removes mobro.css from your public/stylesheets directory"
  task :uninstall do
    File.delete(File.join(RAILS_ROOT, 'public', 'stylesheets', 'mobro.css'))
  end
end