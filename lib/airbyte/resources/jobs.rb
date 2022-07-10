
module Airbyte
  def self.jobs; Jobs.new; end
  class Jobs < BaseClient
    JOB_TYPE_SYNC = "sync"
    def get(job_id)
      params = {
        id: job_id
      }
      handle_request("/api/v1/jobs/get", body: params)
    end

    def list_sync_jobs_for_connection(job_params)
      params = {
        configTypes: [
          JOB_TYPE_SYNC
        ],
        configId: job_params[:connection_id]
      }

      if job_params.key?(:pagination)
        params[:pagination] = {
          pageSize: job_params[:pagination][:page_size],
          rowOffset: job_params[:pagination][:row_offset]
        }
      end

      handle_request("/api/v1/jobs/list", body: params)
    end

    def get_debug_info(job_id)
      params = {
        id: job_id
      }
      handle_request("/api/v1/jobs/get_debug_info", body: params)
    end
  end 
end