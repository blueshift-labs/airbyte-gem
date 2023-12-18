
module Airbyte
  def self.job; Job.new; end
  class Job < ConfigAPIClient
    STATUSES = {pending: 'pending', running: 'running', incomplete: 'incomplete', failed: 'failed', succeeded: 'succeeded', cancelled: 'cancelled'}
    STATUSES_PROCESSING = [STATUSES[:pending], STATUSES[:running]]
    STATUSES_SUCCESS = [STATUSES[:succeeded]]
    STATUSES_FAILED = [STATUSES[:incomplete], STATUSES[:failed], STATUSES[:cancelled]]

    ERROR_KEY_ORIGIN = 'origin'
    ERROR_KEY_TYPE = 'type'
    ERROR_KEY_EXTERNAL_MSG = 'external_message'
    ERROR_KEY_INTERNAL_MSG = 'internal_message'
    ERROR_KEY_TIMESTAMP = 'timestamp'
    ERROR_KEY_PARTIAL_SUCCESS = 'partial_success'
    
    DEFAULT_EXTERNAL_MSG = "Sync Job Execution Failed"
    DEFAULT_INTERNAL_MSG = "Please verify credentials and privileges of source, destination and connection"
    DEFAULT_ORIGIN = 'source'
    DEFAULT_TYPE = 'internal_error'
    DEFAULT_PARTIAL_SUCCESS = 'false'

    JOB_TYPE_SYNC = "sync"
    def get(job_id)
      params = {
        id: job_id
      }
      handle_request("jobs/get", body: params)
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
        successful_records = stats.fetch('recordsCommitted', nil)
        bytes_synced = stats.fetch('bytesEmitted', nil)
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

        error_details = {
          ERROR_KEY_ORIGIN => DEFAULT_ORIGIN,
          ERROR_KEY_TYPE => DEFAULT_TYPE,
          ERROR_KEY_EXTERNAL_MSG => DEFAULT_EXTERNAL_MSG,
          ERROR_KEY_INTERNAL_MSG => DEFAULT_INTERNAL_MSG,
          ERROR_KEY_TIMESTAMP => DateTime.now.strftime('%Q'),
          ERROR_KEY_PARTIAL_SUCCESS => DEFAULT_PARTIAL_SUCCESS
        }
        unless failed_attempt['failureSummary'].nil? || failed_attempt['failureSummary'].empty?
          # fetch only first failure detail
          failure_details = failed_attempt['failureSummary']['failures'][0]
          error_details[ERROR_KEY_ORIGIN] = failure_details['failureOrigin']
          error_details[ERROR_KEY_TYPE] = failure_details['failureType']
          error_details[ERROR_KEY_EXTERNAL_MSG] = failure_details['externalMessage']
          error_details[ERROR_KEY_INTERNAL_MSG] = failure_details['internalMessage']
          error_details[ERROR_KEY_TIMESTAMP] = failure_details['timestamp']
          error_details[ERROR_KEY_PARTIAL_SUCCESS] = failed_attempt['failureSummary']['partialSuccess']
        end
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

      handle_request("jobs/list", body: params)
    end

    def get_debug_info(job_id)
      params = {
        id: job_id
      }
      handle_request("jobs/get_debug_info", body: params)
    end
  end 
end