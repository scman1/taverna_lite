puts "Adding the input and output types to the PortType Table"

["input", "output"].each do |pt|
  TavernaLite::PortType.find_or_create_by_name pt
end

puts "Adding features for the POPMOD family"

seed_file = File.join(Rails.root, 'db', 'seed_features.yml')

feature_data = YAML::load_file(seed_file)

feature_data.each { |ft_k, ft_v|
  unless ft_v["component_id"]=="nil"
    # search for component by name and then verify igf it can be used
    # as instance
    wf_comps = TavernaLite::WorkflowComponent.find_all_by_name(ft_v["name"])
    wf_comps.each {
      |wfcomp|
      # The Component could be used to instantiate this feature
      if TavernaLite::Feature.find_by_component_id(wfcomp.id) .nil?
        # Component can be used to instantiate this feature
        ft_v["component_id"] = wfcomp.id
        break
      end
    }
  end
  TavernaLite::Feature.create(ft_v)
}
