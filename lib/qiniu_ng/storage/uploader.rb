# frozen_string_literal: true

module QiniuNg
  module Storage
    # 上传控制器
    class Uploader
      def initialize(bucket, http_client, block_size: Config.default_upload_block_size)
        @form_uploader = FormUploader.new(bucket, http_client)
        @resumable_uploader = ResumableUploader.new(bucket, http_client, block_size: block_size)
      end

      def upload(filepath: nil, stream: nil, key: nil, upload_token:, params: {}, meta: {},
                 recorder: Recorder::FileRecorder.new, mime_type: DEFAULT_MIME, disable_checksum: false,
                 resumable_policy: :auto, https: nil, **options)
        if !filepath || resumable_policy == :always ||
           resumable_policy != :never && File.size(filepath) > Config.upload_threshold
          if filepath
            @resumable_uploader.sync_upload_file(filepath, key: key, upload_token: upload_token, params: params,
                                                           meta: meta, recorder: recorder, mime_type: mime_type,
                                                           disable_checksum: disable_checksum, https: https, **options)
          else
            @resumable_uploader.sync_upload_stream(stream, key: key, upload_token: upload_token, params: params,
                                                           meta: meta, recorder: recorder, mime_type: mime_type,
                                                           disable_checksum: disable_checksum, https: https, **options)
          end
        else
          @form_uploader.sync_upload_file(filepath, key: key, upload_token: upload_token, params: params, meta: meta,
                                                    mime_type: mime_type, disable_checksum: disable_checksum,
                                                    https: https, **options)
        end
      end
    end
  end
end
