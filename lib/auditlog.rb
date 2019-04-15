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

          from = {}
          to = Hash[audited_fields.map { |k| [k, send(k)] }]
          unchanged = {}

          AuditLog.logger.debug(
            from: from.to_json,
            to: to.to_json,
            unchanged: unchanged.to_json,
            who_class: AuditLog.who.class.name,
            who_id: AuditLog.who.id,
            who_name: AuditLog.who.name,
            who_email: AuditLog.who.email,
          )
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

            AuditLog.logger.debug(
              from: from.to_json,
              to: to.to_json,
              unchanged: unchanged.to_json,
              who_class: AuditLog.who.class.name,
              who_id: AuditLog.who.id,
              who_name: AuditLog.who.name,
              who_email: AuditLog.who.email,
            )
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
      AuditLog.who = auditlog_set_user
      AuditLog.logger = Rails.logger
    end
  end

  ActiveRecord::Base.send :include, AuditLog::Auditor

  ActiveSupport.on_load(:action_controller) do
    include AuditLog::Controller
  end

end
