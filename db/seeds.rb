puts "Adding the input and output types to the PortType Table"

["input", "output"].each do |pt|
  TavernaLite::PortType.find_or_create_by_name pt
end

puts "Adding features model for the POPMOD family"

TavernaLite::FeatureModel.create(:name=>"Population Modelling Family")

puts "Adding features model metadata for the POPMOD family"

TavernaLite::FeatureModelMetadatum.create(
  :feature_model_id => 1,
  :description => "Initial feature model for testing TL based on POPMOD V19 " +
    "ref: http://www.myexperiment.org/workflows/3684.html",
  :creator => "Abraham Nieva de la Hidalga",
  :email   => "a.nieva@cs.cardiff.ac.uk",
  :date    => DateTime.now,
  :department => "Computer Science and Informatics",
  :organisation => "Cardiff University",
  :address => "",
  :phone => "029 20 870 321",
  :website => "http://www.myexperiment.org/packs/516.html",
  :reference => "http://www.myexperiment.org/packs/516.html"
  )

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

puts "Adding example value types"

["string","integer","float","Census Table Text File","R Expression",
  "string vector", "R Matrix", "R Data Frame - Table", "Census Table CSV File",
  "Census Table Spreadsheet"].each do |et|
  TavernaLite::ExampleType.find_or_create_by_name et
end
