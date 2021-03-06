require 'xiaomi/push/services/messages/base'
require 'xiaomi/push/services/messages/ios'
require 'xiaomi/push/services/messages/android'

module Xiaomi
  module Push
    module Services
      # 单条消息类 API
      #
      # 允许向单个设备或多个设备发送同样的推送消息
      #
      # 设备的标识支持 reg_id/alias/user/topic/topics/all
      #
      # @attr [Client] context
      class Message
        # 消息类型模板
        MESSAGE_TYPE = {
          reg_id: {
            uri: 'regid',
            query: 'registration_id'
          },
          alias: {
            uri: 'alias',
            query: 'alias'
          },
          user: {
            uri: 'user_account',
            query: 'user_account'
          },
          topic: {
            uri: 'topic',
            query: 'topic'
          },
          topics: {
            uri: 'multi_topic',
            query: 'topics'
          },
          topic_op: {
            uri: 'multi_topic',
            query: 'topic_op'
          },
          all: {
            uri: 'all',
            query: 'all'
          },
        }

        attr_reader :context

        def initialize(context)
          @context = context
        end

        # 推送消息
        #
        # @see https://dev.mi.com/console/doc/detail?pId=1163#_0
        #
        # @param (see Xiaomi::Push::Message::Base#initialize)
        # @param [Hash, Message::IOS, Message::Android] options Hash 结构消息体 (详见 {Xiaomi::Push::Message::IOS}, {Message::Android})
        # @return [Hash] 小米返回数据结构
        #
        # @raise [RequestError] 推送消息不满足 reg_id/alias/user/topic/topics/all 会引发异常
        def send(**options)
          type, value = fetch_message_type(options)
          if type && value
            url = @context.build_uri("message/#{type[:uri]}")
            if options[:message].kind_of?Xiaomi::Push::Message::Base
              options[:message].type(type[:query], value)
              params = options[:message].to_params
            else
              params = options[:message]
              params[type[:query].to_sym] = value
            end

            @context.post(url, params)
          else
            raise Xiaomi::Push::RequestError, '无效的消息类型，请检查是否符合这些类型: reg_id/alias/topic/topics/all'
          end
        end

        # 获取消息的统计数据
        #
        # @example 获取 2017-09-01 到 2017-09-30 应用 com.icyleaf.app.helloworld 统计数据
        #   counters('20170901', '20170930', 'com.icyleaf.app.helloworld')
        #
        # @see https://dev.mi.com/console/doc/detail?pId=1163#_2
        #
        # @param [String] start_date 开始日期，格式 yyyyMMdd
        # @param [String] end_date 结束日期，必须小于 30 天。格式 yyyyMMdd
        # @param [String] package_name 包名，Android 为 package name，iOS 为 Bundle identifier
        # @return [Hash] 小米返回数据结构
        def counters(start_date, end_date, package_name)
          url = @context.build_uri('stats/message/counters')
          params = {
            start_date: start_date,
            end_date: end_date,
            restricted_package_name: package_name
          }

          @context.get(url, params)
        end

        private

        # 获取消息类型
        def fetch_message_type(data)
          type, value = nil
          MESSAGE_TYPE.select do |k,v|
            if data.has_key?(k)
              type = v
              value = data[k]
              break
            end
          end

          [type, value]
        end
      end
    end
  end
end
