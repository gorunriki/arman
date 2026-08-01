# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'json'

# Path ke file JSON (Sesuaikan nama dan lokasinya)
json_path = Rails.root.join('db', 'data', 'vacancies.json')

unless File.exist?(json_path)
  puts "❌ File JSON tidak ditemukan di #{json_path}"
  exit
end

puts "🚀 Membaca file JSON dari #{json_path}..."
file_content = File.read(json_path)
data = JSON.parse(file_content)

# Jika JSON berupa array, gunakan data langsung. Jika single object, bungkus jadi array.
vacancies_list = data.is_a?(Array) ? data : [ data ]

puts "📦 Memproses #{vacancies_list.size} data vacancy..."

ActiveRecord::Base.transaction do
  vacancies_list.each_with_index do |item, index|
    # ----------------------------------------------------
    # 1. PROVINCE & CITY
    # ----------------------------------------------------
    city_data = item['city'] || item.dig('organizer', 'city')
    city = nil

    if city_data.present?
      # Buat Province jika ada provinceId
      province = nil
      if city_data['provinceId'].present?
        province = Province.find_or_create_by!(id: city_data['provinceId']) do |p|
          p.name = city_data['provinceName'] || "Province #{city_data['provinceId'][0..7]}"
        end
      end

      # Buat/Temukan City
      city = City.find_or_create_by!(id: city_data['id']) do |c|
        c.province = province
        c.name = city_data['name']
        c.city_type = city_data['type']
        c.postal_code = city_data['postalCode']
      end
    end

    # ----------------------------------------------------
    # 2. ORGANIZER
    # ----------------------------------------------------
    organizer = nil
    if item['organizer'].present?
      org_data = item['organizer']
      organizer = Organizer.find_or_create_by!(id: org_data['id']) do |o|
        o.city = city
        o.name = org_data['name']
        o.email = org_data['email']
        o.phone = org_data['phone']
        o.address = org_data['address']
        o.organizable_type = org_data['organizableType']
        o.description = org_data['description']
        o.logo_url = org_data['logoUrl']
      end
    end

    # ----------------------------------------------------
    # 3. MAIN STUDY PROGRAM (Single)
    # ----------------------------------------------------
    main_study_program = nil
    if item['studyProgram'].present?
      sp_data = item['studyProgram']
      main_study_program = StudyProgram.find_or_create_by!(id: sp_data['id']) do |sp|
        sp.name = sp_data['name']
      end
    end

    # ----------------------------------------------------
    # 4. VACANCY
    # ----------------------------------------------------
    vacancy = Vacancy.find_or_initialize_by(id: item['id'])
    vacancy.assign_attributes(
      organizer: organizer,
      city: city,
      primary_study_program: main_study_program,
      position_name: item['positionName'],
      quantity_needed: item['quantityNeeded'] || 0,
      approved_quantity: item['approvedQuantity'] || 0,
      total_applications: item['totalApplications'] || 0,
      competitive_score: item['competitiveScore'],
      opportunity_score: item['opportunityScore'],
      task_description: item['taskDescription'],
      working_days_per_week: item['workingDaysPerWeek'],
      education_levels: item['educationLevels'] || [],
      days_off: item['daysOff'] || [],
      latitude: item['latitude'],
      longitude: item['longitude'],
      address: item['address'],
      published_at: item['publishedAt'],
      created_at: item['createdAt'] || Time.current,
      updated_at: item['updatedAt'] || Time.current
    )
    vacancy.save!

    # ----------------------------------------------------
    # 5. JOIN TABLE STUDY PROGRAMS (Multiple Has-Many)
    # ----------------------------------------------------
    if item['studyPrograms'].is_a?(Array)
      item['studyPrograms'].each do |sp_item|
        sp = StudyProgram.find_or_create_by!(id: sp_item['id']) do |s|
          s.name = sp_item['name']
        end

        # Hubungkan ke Vacancy lewat Join Table (jika belum terhubung)
        vacancy.study_programs << sp unless vacancy.study_programs.exists?(sp.id)
      end
    end
    vacancy.study_programs << main_study_program if main_study_program && !vacancy.study_programs.exists?(main_study_program.id)

    puts "  [#{index + 1}/#{vacancies_list.size}] ✅ Imported: #{vacancy.position_name} (#{organizer&.name})"
  end
end

puts "🎉 Impor data selesai sepenuhnya!"
