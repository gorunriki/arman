class Vacancy < ApplicationRecord
  ARCHIVE_TIME_ZONE = "Asia/Jakarta"

  belongs_to :organizer, counter_cache: true
  belongs_to :city, optional: true
  belongs_to :primary_study_program, class_name: "StudyProgram", optional: true
  has_and_belongs_to_many :study_programs
  validates :position_name, presence: true

  scope :published_in, ->(period) {
    zone = ActiveSupport::TimeZone[ARCHIVE_TIME_ZONE]
    start_at = zone.strptime(period, "%Y-%m").beginning_of_month
    where(published_at: start_at...start_at.next_month)
  }

  def self.archive_periods
    period_sql = "TO_CHAR((published_at AT TIME ZONE 'UTC') AT TIME ZONE '#{ARCHIVE_TIME_ZONE}', 'YYYY-MM')"

    where.not(published_at: nil)
      .group(Arel.sql(period_sql))
      .order(Arel.sql("#{period_sql} DESC"))
      .pluck(Arel.sql(period_sql))
  end

  def archive_period
    published_at&.in_time_zone(ARCHIVE_TIME_ZONE)&.strftime("%Y-%m")
  end
end
