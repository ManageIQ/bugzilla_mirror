class ErrataReportsController < ApplicationController

  # GET /errata_reports
  # GET /errata_reports.json
  def index
    @errata_report_need_acks, @errata_report_have_acks = Issue.errata_report
    respond_to do |format|
      format.html
      format.json { head :no_content }
    end
  end

end
