module Alipay
  module App
    module Service
      GATEWAY_URL = 'https://openapi.alipay.com/gateway.do'

      ALIPAY_PREPARE_PARAMS_REQUIRED_PARAMS = %w( method )
      def self.prepare_params(params, options = {})
        params = Utils.stringify_keys(params)
        Alipay::Service.check_required_params(params, ALIPAY_PREPARE_PARAMS_REQUIRED_PARAMS)
        key = options[:key] || Alipay.key
        sign_type = (options[:sign_type] || :rsa2).to_s.upcase
        params = {
            'method'         => params['method'],
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
      end

      # APP支付
      ALIPAY_TRADE_APP_PAY_REQUIRED_PARAMS = %w( app_id biz_content notify_url )
      def self.alipay_trade_app_pay(params, options = {})
        params = Utils.stringify_keys(params)
        Alipay::Service.check_required_params(params, ALIPAY_TRADE_APP_PAY_REQUIRED_PARAMS)
        params = params.merge('method' => 'alipay.trade.app.pay')
        params = prepare_params(params, options)
        Alipay::App::Sign.params_to_encoded_string params
      end

      # 退款
      # 参考文档：https://docs.open.alipay.com/api_1/alipay.trade.refund/
      ALIPAY_TRADE_REFUND_REQUIRED_PARAMS = %w( app_id biz_content )
      def self.alipay_trade_refund_url(params, options = {})
        params = Utils.stringify_keys(params)
        Alipay::Service.check_required_params(params, ALIPAY_TRADE_REFUND_REQUIRED_PARAMS)
        params = params.merge('method' => 'alipay.trade.refund')
        params = prepare_params(params, options)
        request_uri(params)
      end

      # 退款查询
      # 参考文档：https://docs.open.alipay.com/api_1/alipay.trade.fastpay.refund.query/
      ALIPAY_TRADE_REFUND_QUERY_REQUIRED_PARAMS = %w( app_id biz_content )
      def self.alipay_trade_refund_query_url(params, options = {})
        params = Utils.stringify_keys(params)
        Alipay::Service.check_required_params(params, ALIPAY_TRADE_REFUND_QUERY_REQUIRED_PARAMS)
        params = params.merge('method' => 'alipay.trade.fastpay.refund.query')
        params = prepare_params(params, options)
        request_uri(params)
      end

      def self.request_uri(params)
        uri = URI(GATEWAY_URL)
        uri.query = URI.encode_www_form(params)
        uri
      end
    end
  end
end
