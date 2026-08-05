# app/services/vacancy_importer.rb
class VacancyImporter
  def self.import_from_json(file_path)
    unless File.exist?(file_path)
      puts "❌ File tidak ditemukan: #{file_path}"
      return
    end

    raw_data = File.read(file_path)
    vacancies_data = JSON.parse(raw_data)

    puts "🚀 Memulai impor #{vacancies_data.size} lowongan..."

    success_count = 0
    error_count = 0

    vacancies_data.each_with_index do |data, index|
      ActiveRecord::Base.transaction do
        # 1. Province (opsional)
        province = nil
        if data.dig("city", "provinceId").present?
          province = Province.find_or_create_by!(id: data.dig("city", "provinceId")) do |p|
            p.name = data.dig("city", "provinceName") || "Unknown Province"
          end
        end

        # 2. City (opsional)
        city = nil
        if data["cityId"].present?
          city = City.find_or_create_by!(id: data["cityId"]) do |c|
            c.name = data.dig("city", "name") || "Unknown City"
            c.province = province
            c.city_type = data.dig("city", "type")
            c.postal_code = data.dig("city", "postalCode")
          end
        end

        # 3. Organizer (Wajib)
        organizer_data = data["organizer"]
        organizer = Organizer.find_or_initialize_by(id: organizer_data["id"])
        organizer.assign_attributes(
          name: organizer_data["name"],
          email: organizer_data["email"],
          phone: organizer_data["phone"],
          address: organizer_data["address"],
          organizable_type: organizer_data["organizableType"]&.downcase,
          description: organizer_data["description"],
          logo_url: organizer_data["logoUrl"],
          city: city
        )
        organizer.save!

        # 4. Primary Study Program (opsional)
        primary_sp = nil
        if data["studyProgramId"].present?
          primary_sp = StudyProgram.find_or_create_by!(id: data["studyProgramId"]) do |sp|
            sp.name = data.dig("studyProgram", "name") || "Unknown Program"
          end
        end

        # 5. Study Programs (HABTM / Many-to-Many)
        study_program_ids = []
        data["studyPrograms"]&.each do |sp_data|
          sp = StudyProgram.find_or_create_by!(id: sp_data["id"]) do |s|
            s.name = sp_data["name"]
          end
          study_program_ids << sp.id
        end
        study_program_ids << primary_sp.id if primary_sp

        # 6. Vacancy (Upsert)
        vacancy = Vacancy.find_or_initialize_by(id: data["id"])
        vacancy.assign_attributes(
          organizer: organizer,
          city: city,
          primary_study_program: primary_sp,
          position_name: data["positionName"],
          quantity_needed: data["quantityNeeded"] || 0,
          approved_quantity: data["approvedQuantity"] || 0,
          total_applications: data["totalApplications"] || 0,
          competitive_score: data["competitiveScore"],
          opportunity_score: data["opportunityScore"],
          task_description: data["taskDescription"],
          education_levels: data["educationLevels"] || [],
          working_days_per_week: data["workingDaysPerWeek"],
          days_off: data["daysOff"] || [],
          latitude: data["latitude"],
          longitude: data["longitude"],
          address: data["address"],
          published_at: data["publishedAt"]
        )

        vacancy.save!
        # Set relasi Many-to-Many untuk daftar studyPrograms
        vacancy.study_program_ids = study_program_ids.uniq

        success_count += 1
      end
    rescue => e
      error_count += 1
      puts "\n⚠️ Gagal mengimpor item index #{index} (ID: #{data['id']}): #{e.message}"
    end

    puts "\n=========================================="
    puts "✅ Impor selesai!"
    puts "Sukses : #{success_count}"
    puts "Gagal  : #{error_count}"
    puts "=========================================="
  end
end
