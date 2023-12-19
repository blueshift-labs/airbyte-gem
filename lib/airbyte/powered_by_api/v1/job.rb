
module Airbyte
  module V1
    def self.job; Job.new; end
    class Job < APIClient
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
        handle_request(PATH_PREFIX_JOBS, body: params)
      end
      def trigger_reset(connection_id)    
        params = {
          jobType: "reset",
          connectionId: connection_id
        }
        handle_request(PATH_PREFIX_JOBS, body: params)
      end
    end
  end 
end