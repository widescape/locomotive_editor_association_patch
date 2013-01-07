Dir[File.join(File.dirname(__FILE__), 'api', '*.rb')].each do |lib|
  require lib
end