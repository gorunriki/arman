namespace :data do
  desc "Import vacancies from JSON (FILE=/path/file.json, optional PERIOD=YYYY-MM)"
  task import_vacancies: :environment do
    file_path = ENV["FILE"]
    abort "Set FILE to the JSON file path" if file_path.blank?

    VacancyImporter.import_from_json(file_path, expected_period: ENV["PERIOD"])
  end
end
