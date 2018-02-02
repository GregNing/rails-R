require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsRecipes
  class Application < Rails::Application
    #配置中文語系
    #其实，翻译档档名叫 events.yml、zh-TW.yml、en.yml 什么都无所谓，重要的是 YAML 结构中第一层要对应
    #locale的名称，也就是 zh-CN，Rails 会加载 config/locales 下所有的YAML词汇档案。
    config.i18n.default_locale = "zh-TW"
    #抓取台北時間
    config.time_zone = "Taipei"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    Time::DATE_FORMATS.merge!(:default => '%Y/%m/%d %I:%M %p', :ymd => '%Y/%m/%d')
  config.action_view.sanitized_allowed_tags = Rails::Html::WhiteListSanitizer.allowed_tags + %w(table tr td) 
  config.action_view.sanitized_allowed_attributes = Rails::Html::WhiteListSanitizer.allowed_attributes + %w(style border) 
  end
end
