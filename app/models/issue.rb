# TODO update require 'ruby_bugzilla' once gem is available
# TODO require 'ruby_bugzilla'
require '/home/jvlcek/.rvm/gems/ruby-1.9.3-p392@cfme_bz/gems/ruby_bugzilla-0.1.0/lib/ruby_bugzilla'

class Issue < ActiveRecord::Base
  attr_accessible :assigned_to,  :bz_id, :status, :summary, :version,
    :version_ack, :devel_ack, :doc_ack, :pm_ack, :qa_ack

  VERSION_REGEX=/cfme-[0-9]\.?[0-9]?\.?z?/

  def self.update_from_bz

    RubyBugzilla.login!

    product = "CloudForms Management Engine"
    bug_status = "NEW, ASSIGNED, POST, MODIFIED, ON_DEV, ON_QA, VERIFIED, RELEASE_PENDING"
    flag = ""
    output_format = "BZ_ID: %{id} BZ_ID_END ASSIGNED_TO: %{assigned_to} ASSIGNED_TO_END "
    output_format << "SUMMARY: %{summary} SUMMARY_END "
    output_format << "BUG_STATUS: %{bug_status} BUG_STATUS_END "
    output_format << "VERSION: %{version} VERSION_END "
    output_format << "FLAGS: %{flags} FLAGS_END "
    output_format << "KEYWORDS: %{keywords} KEYWORDS_END"

    cmd, output = RubyBugzilla.query(product, flag, bug_status, output_format)
    self.recreate_all_issues(output)
    output

  end

  private
  def self.get_from_flags(str, regex)

    flags = self.get_token_values(str, "FLAGS").join
    match = regex.match(flags)

    if match
      return [match[0], match.post_match[0]]
    else
      return ["NONE", "NONE"]
    end
   
  end

  private
  def self.get_token_values(str, token)

    return [] if token.to_s.empty?

    token_values = str.scan(/(?<=#{token}:\s).*(?<=#{token}_END)/)

    # Because regexp lookahead and lookbehind must be a fixed length
    # removing the occasionally occuring trailing ->'<- character must
    # be done in a separate step.
    token_values.each do |x|
      x.sub!("#{token}_END", "")
      x.sub!(/'$/, '')
      x.strip!
    end

    token_values
  end

  private
  def self.recreate_all_issues(output)

    self.delete_all

    # create a new issue in the db for each bz.
    output.each_line do |bz_line|
      # create a new issue object in the db for each BZ.
      bz_id                    = self.get_token_values(bz_line, "BZ_ID").join
      assigned_to              = self.get_token_values(bz_line, "ASSIGNED_TO").join
      summary                  = self.get_token_values(bz_line, "SUMMARY").join
      status                   = self.get_token_values(bz_line, "BUG_STATUS").join

      pm_ack_str, pm_ack       = self.get_from_flags(bz_line, /pm_ack/)
      devel_ack_str, devel_ack = self.get_from_flags(bz_line, /devel_ack/)
      qa_ack_str, qa_ack       = self.get_from_flags(bz_line, /qa_ack/)
      doc_ack_str, doc_ack     = self.get_from_flags(bz_line, /doc_ack/)
      version_str, version_ack = self.get_from_flags(bz_line, VERSION_REGEX)

      self.create(:bz_id         => bz_id,
                  :assigned_to   => assigned_to,
                  :status        => status,
                  :summary       => summary,
                  :version       => version_str,
                  :version_ack   => version_ack,
                  :devel_ack     => devel_ack,
                  :doc_ack       => doc_ack,
                  :pm_ack        => pm_ack,
                  :qa_ack        => qa_ack)

    end
    
  end

end