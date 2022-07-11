
module Airbyte
  def self.jobs; Jobs.new; end
  class Jobs < BaseClient
    STATUSES = {pending: 'pending', running: 'running', incomplete: 'incomplete', failed: 'failed', succeeded: 'succeeded', cancelled: 'cancelled'}
    STATUSES_PROCESSING = [STATUSES[:pending], STATUSES[:running]]
    STATUSES_SUCCESS = [STATUSES[:succeeded]]
    STATUSES_FAILED = [STATUSES[:incomplete], STATUSES[:failed], STATUSES[:cancelled]]

    JOB_TYPE_SYNC = "sync"
    def get(job_id)
      params = {
        id: job_id
      }
      handle_request("/api/v1/jobs/get", body: params)
    end

    def get_job_state(job_id)
      resp = get(job_id)
      result = {}
      result["status"] = "in_progress"
      result["error_info"] = {}
      result["job_stats"] = {}
      job = resp["job"]
      attempts = resp["attempts"]
      if STATUSES_SUCCESS.include? job["status"]
        success_attempt = attempts.find{|i| i["attempt"]["status"] == "succeeded"}
        stats = success_attempt['attempt']["totalStats"]
        result["job_stats"] = stats
        result["status"] = "succeeded"
      elsif STATUSES_FAILED.include? job["status"]
        result["status"] = "failed"
        failed_attempt = attempts.find{|i| i["attempt"]["status"] == "failed"}
        result["error_info"] = failed_attempt['attempt']["failureSummary"]
      end
      result
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