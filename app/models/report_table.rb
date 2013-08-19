class ReportTable < ActiveRecord::Base

  include ReportTablesHelper

  attr_accessible :horizontal, :vertical, :description, :name,
    :query_name, :query_id

  def run(report_table)

    logger.debug "report_table.query_name: #{report_table.query_name}<-"
    logger.debug "report_table.query_id: #{report_table.query_id}<-"
    logger.debug "horizontal: #{report_table.horizontal}"
    logger.debug "vertical: #{report_table.vertical}"

    bz_query_out = get_query_output(report_table)
    hori_up = report_table.horizontal.upcase
    vert_up = report_table.vertical.upcase
    hori_array = get_query_element(hori_up, report_table.query_id)
    vert_array = get_query_element(vert_up, report_table.query_id)

    @table = {}
    @table = Hash[*hori_array.uniq.sort.each.collect {|v| [v, {}]}.flatten]

    hori_array.uniq.sort.each do |h|
      @table[h] = Hash[*vert_array.uniq.sort.each.collect {|v| [v, 0]}.flatten]
    end

    set_table_bz_count!(@table, bz_query_out, hori_up, vert_up)

  end

end
