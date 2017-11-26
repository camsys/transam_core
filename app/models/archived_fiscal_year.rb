class ArchivedFiscalYear < ActiveRecord::Base

  include FiscalYear

  belongs_to :organization

  validates_uniqueness_of :fy_year, :scope => :organization

  default_scope { order(:fy_year) }

  # if force update, will unarchive if FY Year is found to be already archived or vice versa
  def self.archive(organization_id, fy_year, force_update=false)
    archived = ArchivedFiscalYear.find_by(organization_id: organization_id, fy_year: fy_year)
    if archived.present? && force_update
      archived.destroy
    elsif archived.nil?
      ArchivedFiscalYear.create(organization_id: organization_id, fy_year: fy_year)
    else
      return nil
    end
  end

  def self.unarchive(organization_id, fy_year, force_update=false)
    archived = ArchivedFiscalYear.find_by(organization_id: organization_id, fy_year: fy_year)
    if archived.nil? && force_update
      ArchivedFiscalYear.create(organization_id: organization_id, fy_year: fy_year)
    elsif archived.present?
      archived.destroy
    else
      return nil
    end
  end

  def self.available_years
    years = self.pluck(:fy_year)
    ArchivedFiscalYear.new.get_past_fiscal_years.select{ |x| !(years.include? x[1]) }
  end
end
