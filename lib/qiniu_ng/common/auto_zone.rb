# frozen_string_literal: true

require 'faraday'

module QiniuNg
  module Common
    # 该类主要用来根据用户提供的 AccessKey 和 Bucket 来自动获取有效的 Zone 实例
    class AutoZone
      API_SERVER = 'https://uc.qbox.me'
      def initialize(api_server: API_SERVER)
        @api_server = api_server
        @client = HTTP.client
        @infer_domains_map = {
          'http://up.qiniu.com' => Zone.zone0,
          'http://up-z1.qiniu.com' => Zone.zone1,
          'http://up-z2.qiniu.com' => Zone.zone2,
          'http://up-na0.qiniu.com' => Zone.zone_na0,
          'http://up-as0.qiniu.com' => Zone.zone_as0
        }
      end

      def query(access_key:, bucket:, **options)
        resp = @client.get("#{@api_server}/v1/query", params: { ak: access_key, bucket: bucket }, **options)
        up_http = resp.body.dig('http', 'up', 0)
        up_backup_http = resp.body.dig('http', 'up', 1)
        up_ip_http = resp.body.dig('http', 'up', 2)&.split(' ')&.dig(2)&.split('//')&.dig(1)
        io_http = resp.body.dig('http', 'io', 0)
        up_https = resp.body.dig('https', 'up', 0)
        up_backup_https = resp.body.dig('https', 'up', 1)
        up_ip_https = resp.body.dig('https', 'up', 2)&.split(' ')&.dig(2)&.split('//')&.dig(1)
        io_https = resp.body.dig('https', 'io', 0)
        rs_http = @infer_domains_map[up_http]&.rs_http
        rs_https = @infer_domains_map[up_http]&.rs_https
        rsf_http = @infer_domains_map[up_http]&.rsf_http
        rsf_https = @infer_domains_map[up_http]&.rsf_https
        api_http = @infer_domains_map[up_http]&.api_http
        api_https = @infer_domains_map[up_http]&.api_https
        Zone.new(region: 'auto',
                 up_http: up_http&.freeze,
                 up_https: up_https&.freeze,
                 up_backup_http: up_backup_http&.freeze,
                 up_backup_https: up_backup_https&.freeze,
                 up_ip_http: up_ip_http&.freeze,
                 up_ip_https: up_ip_https&.freeze,
                 io_vip_http: io_http&.freeze,
                 io_vip_https: io_https&.freeze,
                 rs_http: rs_http&.freeze,
                 rs_https: rs_https&.freeze,
                 rsf_http: rsf_http&.freeze,
                 rsf_https: rsf_https&.freeze,
                 api_http: api_http&.freeze,
                 api_https: api_https&.freeze).freeze
      end
    end
  end
end