

namespace :spec do
  desc 'Run the specs under stories/features/FEATURE (FEATURE defaults to *)'
  task :stories do
    Dir.glob(File.join(RAILS_ROOT, 'stories', 'features', ENV['FEATURE'] || '*', '*.rb')).each do |story|
      puts 
      sh %{ruby #{story}}
    end
  end
end