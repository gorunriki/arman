namespace :data do
  desc "Import vacancies from a JSON file (FILE=/path/to/file.json)"
  task import_vacancies: :environment do
    file_path = ENV["FILE"]
    abort "Set FILE to the JSON file path" if file_path.blank?

    VacancyImporter.import_from_json(file_path)
  end
end
