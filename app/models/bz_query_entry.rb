class BzQueryEntry < ActiveRecord::Base
  attr_accessible :bz_id, :status,
    :pm_ack, :devel_ack, :qa_ack, :doc_ack,
    :version, :version_ack 

end
