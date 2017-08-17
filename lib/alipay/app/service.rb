module Alipay
  module App
    module Service
      GATEWAY_URL = 'https://openapi.alipay.com/gateway.do'

      ALIPAY_TRADE_APP_PAY_REQUIRED_PARAMS = %w( app_id biz_content notify_url )
      def self.alipay_trade_app_pay(params, options = {})
        params = Utils.stringify_keys(params)
        Alipay::Service.check_required_params(params, ALIPAY_TRADE_APP_PAY_REQUIRED_PARAMS)
        key = options[:key] || Alipay.key

        sign_type = (options[:sign_type] || :rsa2).to_s.upcase

        params = {
          'method'         => 'alipay.trade.app.pay',
          'charset'        => 'utf-8',
          'version'        => '1.0',
          'timestamp'      => Time.now.utc.strftime('%Y-%m-%d %H:%M:%S').to_s,
          'sign_type'      => sign_type
        }.merge(params)

        string = Alipay::App::Sign.params_to_sorted_string(params)
        sign = case sign_type
        when 'RSA'
          ::Alipay::Sign::RSA.sign(key, string)
        when 'RSA2'
          ::Alipay::Sign::RSA2.sign(key, string)
        else
          raise ArgumentError, "invalid sign_type #{sign_type}, allow value: 'RSA', 'RSA2'"
        end

        Alipay::App::Sign.params_to_encoded_string params.merge('sign' => sign)
      end

      ALIPAY_TRADE_REFUND_REQUIRED_PARAMS = %w( app_id biz_content )
      def self.alipay_trade_refund(params, options = {})
        params = Utils.stringify_keys(params)
        Alipay::Service.check_required_params(params, ALIPAY_TRADE_REFUND_REQUIRED_PARAMS)
        key = options[:key] || Alipay.key
        sign_type = (options[:sign_type] || :rsa2).to_s.upcase
        params = {
            'method'         => 'alipay.trade.refund',
            'charset'        => 'utf-8',
            'version'        => '1.0',
            'timestamp'      => Time.now.utc.strftime('%Y-%m-%d %H:%M:%S').to_s,
            'sign_type'      => sign_type
        }.merge(params)

        string = Alipay::App::Sign.params_to_sorted_string(params)
        sign = case sign_type
                 when 'RSA'
                   ::Alipay::Sign::RSA.sign(key, string)
                 when 'RSA2'
                   ::Alipay::Sign::RSA2.sign(key, string)
                 else
                   raise ArgumentError, "invalid sign_type #{sign_type}, allow value: 'RSA', 'RSA2'"
               end
        params.merge('sign' => sign)
        request_uri(params, options)
      end


      def self.request_uri(params, options = {})
        uri = URI(GATEWAY_URL)
        uri.query = URI.encode_www_form(sign_params(params, options))
        uri
      end
    end
  end
end
