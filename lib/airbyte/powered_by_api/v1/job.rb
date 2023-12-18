
module Airbyte
  module V1
    def self.job; Job.new; end
    class Job < APIClient
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
        Airbyte.job.get(job_id)
      end

      def get_job_state(job_id)
        Airbyte.job.get_job_state(job_id)
      end

      def list_sync_jobs_for_connection(job_params)
        Airbyte.job.list_sync_jobs_for_connection(job_params)
      end

      def get_debug_info(job_id)
        Airbyte.job.get_debug_info(job_id)
      end

      def trigger_sync(connection_id)    
        params = {
          jobType: "sync",
          connectionId: connection_id
        }
        handle_request(RESOURCE_PATH_JOBS, body: params)
      end
      def trigger_reset(connection_id)    
        params = {
          jobType: "reset",
          connectionId: connection_id
        }
        handle_request(RESOURCE_PATH_JOBS, body: params)
      end
    end
  end 
end