class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  include Pagy::Method

  before_action :set_archive_period
  helper_method :archive_period, :archive_periods, :archive_period_label, :archive_period_notice, :archive_query

  private

  def set_archive_period
    @archive_periods = Vacancy.archive_periods
    requested_period = params[:period].to_s
    @archive_period = @archive_periods.include?(requested_period) ? requested_period : @archive_periods.first
  end

  def archive_period
    @archive_period
  end

  def archive_periods
    @archive_periods
  end

  def archive_vacancies
    archive_period ? Vacancy.published_in(archive_period) : Vacancy.none
  end

  def archive_period_label(period = archive_period)
    return "Belum ada periode" if period.blank?

    date = Date.strptime(period, "%Y-%m")
    months = %w[Januari Februari Maret April Mei Juni Juli Agustus September Oktober November Desember]
    "#{months.fetch(date.month - 1)} #{date.year}"
  end

  def archive_period_notice
    {
      "2026-09" => "Arsip September 2026 memuat data yang berhasil diselamatkan sebelum sumber Maganghub direset. Jumlahnya mungkin tidak mencakup seluruh lowongan yang pernah dipublikasikan."
    }[archive_period]
  end

  def archive_query
    archive_period.present? && archive_periods.many? ? { period: archive_period } : {}
  end
end
