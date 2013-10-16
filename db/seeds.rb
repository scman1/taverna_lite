puts "seed data goes here"

["input", "output"].each do |pt|
  TavernaLite::PortType.find_or_create_by_name pt
end
