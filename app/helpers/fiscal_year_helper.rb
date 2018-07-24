module FiscalYearHelper
  def get_fy_label
    SystemConfig.instance.default_fiscal_year_formatter ? 'Year' : 'FY'
  end

  def get_fiscal_year_label
    SystemConfig.instance.default_fiscal_year_formatter ? 'Year' : 'Fiscal Year'
  end

  module_function :get_fy_label
  module_function :get_fiscal_year_label
end
  