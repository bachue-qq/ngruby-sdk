# frozen_string_literal: true

require 'forwardable'
require 'qiniu_ng/processing/pfop_status'

module QiniuNg
  module Processing
    # 七牛文件处理持久化 ID
    class PersistentID
      extend Forwardable

      def initialize(persistent_id, http_client_v1, entry)
        @persistent_id = persistent_id
        @entry = entry
        @http_client_v1 = http_client_v1
      end

      def get(api_zone: nil, https: nil, **options)
        resp_body = @http_client_v1.get('/status/get/prefop', get_api_url(@entry, api_zone, https),
                                        params: { id: @persistent_id }, **options).body
        PfopResults.new(resp_body)
      end
      def_delegators :get, :done?, *PfopStatus.keys.map { |k| "#{k}?" }

      def inspect
        "#<#{self.class.name} @persistent_id=#{@persistent_id.inspect}>"
      end

      def to_s
        @persistent_id
      end

      private

      def get_api_url(entry, api_zone, https)
        https = Config.use_https if https.nil?
        api_zone ||= entry.bucket.zone
        api_zone.api_url(https)
      end
    end
  end
end
