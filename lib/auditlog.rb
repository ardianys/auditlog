module AuditLog

  mattr_accessor :who
  mattr_accessor :logger

  module Auditor
    extend ActiveSupport::Concern

    module ClassMethods
      def audit(fields, options = {})
        cattr_accessor :audited_fields
        self.audited_fields = fields.map(&:to_s)

        after_create :save_all_audits
        define_method :save_all_audits do

          from = {klass: self.class.name}
          to = Hash[audited_fields.map { |k| [k, send(k)] }]
          unchanged = {}

          AuditLog.logger.debug(
            from: from.to_json,
            to: to.to_json,
            unchanged: unchanged.to_json,
            who: AuditLog.who
          ) if AuditLog.logger
        end

        before_update :save_audits
        define_method :save_audits do
          changed_audited_fields = changes.slice(*audited_fields)

          if changed_audited_fields.present?

            from = Hash[changed_audited_fields.map { |k, v| [k, v[0]] }]
            to = Hash[changed_audited_fields.map { |k, v| [k, v[1]] }]
            unchanged = Hash[
              (audited_fields - changed_audited_fields.keys).map do |f|
                [f, send(f)]
              end
            ]

            from[:klass] = self.class.name

            AuditLog.logger.debug(
              from: from.to_json,
              to: to.to_json,
              unchanged: unchanged.to_json,
              who: AuditLog.who
            ) if AuditLog.logger
          end
        end
      end
    end
  end

  module Controller
    def self.included(controller)
      controller.before_action(
        :auditlog_user
      )
    end

    def auditlog_set_user
    end

    def auditlog_user
      if auditlog_set_user
        user = auditlog_set_user
        AuditLog.who = {
          klass: user.class.name,
          id: user.id,
          name: user.name,
          email: user.email,          
        }
      else
        AuditLog.who = nil
      end
      # AuditLog.logger ||= Logger.new("#{Rails.root}/log/audit.log")
      AuditLog.logger ||= RemoteSyslogLogger.new('logs3.papertrailapp.com', ENV['PAPERTRAIL_PORT'])
    end
  end

  ActiveRecord::Base.send :include, AuditLog::Auditor

  ActiveSupport.on_load(:action_controller) do
    include AuditLog::Controller
  end

end
