module Xiaomi
  module Push
    module Message
      # iOS 数据消息体
      # @attr [String] title 标题（仅适用于 iOS 10 以上设备）
      # @attr [String] subtitle 副标题（仅适用于 iOS 10 以上设备）
      # @attr [String] body 描述（仅适用于 iOS 10 以上设备）
      # @attr [String] description 描述（如果设置了 title 或 subtitle 将会启用变为 {#body}）
      # @attr [String] badge 角标, 默认 1
      # @attr [String] sound 声音，默认 default
      # @attr [String] category iOS 8 以上可设置推送消息快速回复类别
      class IOS < Base
        attr_accessor :title, :subtitle, :body
        attr_accessor :description, :badge, :sound, :category

        def initialize(**params)
          @title = params[:title]
          @subtitle = params[:subtitle]
          @description = params[:description]
          @body = params[:body] || @description
          @badge = params[:badge] || 1
          @sound = params[:sound] || 'default'
          @category = params[:category]
          @extras = params[:extras] || {}
        end
      end
    end
  end
end
