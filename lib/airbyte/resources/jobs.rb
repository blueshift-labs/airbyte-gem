
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
      status = "in_progress"
      result["error_details"] = {}
      job = resp["job"]
      attempts = resp["attempts"]
      total_records = nil
      successful_records = nil
      bytes_synced = nil
      failed_records = nil

      if STATUSES_SUCCESS.include? job["status"]
        success_attempt = attempts.find{|i| i["attempt"]["status"] == "succeeded"}['attempt']
        
        stats = success_attempt["totalStats"]
        total_records = stats.fetch('recordsEmitted', nil)
        successful_records = success_attempt.fetch('recordsSynced', nil)
        bytes_synced = success_attempt.fetch('bytesSynced', nil)
        failed_records = 0
        status = "succeeded"
      elsif STATUSES_FAILED.include? job["status"]
        failed_attempt = attempts.find{|i| i["attempt"]["status"] == "failed"}['attempt']
        stats = failed_attempt["totalStats"]
        total_records = stats.fetch('recordsEmitted', nil)
        successful_records = failed_attempt.fetch('recordsSynced', nil)
        bytes_synced = failed_attempt.fetch('bytesSynced', nil)
        unless total_records.nil? && successful_records.nil?
          failed_records = total_records - successful_records
        end
        status = "failed"
        # fetch only first failure detail
        failure_details = failed_attempt["failureSummary"]["failures"][0]
        error_details = {}
        error_details['origin'] = failure_details['failureOrigin']
        error_details['type'] = failure_details['failureType']
        error_details['external_message'] = failure_details['externalMessage']
        error_details['internal_message'] = failure_details['internalMessage']
        error_details['timestamp'] = failure_details['timestamp']
        error_details['partial_success'] = failure_details['partialSuccess']
        result['error_details'] = error_details
      end
      result['total_records'] = total_records
      result['successful_records'] = successful_records
      result['bytes_synced'] = bytes_synced
      result['failed_records'] = failed_records
      result["status"] = status
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