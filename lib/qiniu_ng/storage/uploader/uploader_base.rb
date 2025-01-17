# frozen_string_literal: true

module QiniuNg
  module Storage
    # 上传模块
    class Uploader
      Result = Struct.new(:hash, :key)
      DEFAULT_MIME = 'application/octet-stream'

      class ChecksumError < Faraday::Error
      end

      # 上传父类
      class UploaderBase
        def initialize(bucket, http_client)
          if self.class.name == UploaderBase.name
            raise NoMethodError, "undefined method `new` for #{UploaderBase.name}:Class"
          end

          @bucket = bucket
          @http_client = http_client
        end

        private

        def extract_key_from_upload_token(upload_token)
          upload_token = UploadToken.from_token(upload_token) if upload_token.is_a?(String)
          upload_policy = upload_token.policy
          raise ArgumentError, 'missing keyword: key' if upload_policy.save_key.nil? && upload_policy.prefixal_scope?

          upload_policy.save_key || upload_policy.key
        end

        def up_urls(https)
          https = Config.use_https if https.nil?
          @bucket.zone.up_urls(https).dup
        end

        def need_retry(status_code, headers, body, _error, upload_policy)
          ((500...600).to_a - [579] + [406, 996]).include?(status_code) ||
            status_code == 200 && body.is_a?(Hash) && !body['error'].nil? ||
            (200...500).include?(status_code) && headers['X-ReqId'].nil? &&
              !body.is_a?(Hash) && upload_policy.return_url.nil?
        end
      end
    end
  end
end
