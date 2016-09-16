# frozen_string_literal: true
# Copyright (C) 2015 Twitter, Inc.

module TwitterAds
  module Batch

    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods

      ENTITY_MAP = {
        'TwitterAds::LineItem' => 'LINE_ITEM'.freeze,
        'TwitterAds::Campaign' => 'CAMPAIGN'.freeze,
        'TwitterAds::TargetingCriteria' => 'TARGETING_CRITERION'.freeze
      }.freeze

      # Save a list of entities in an atomic batch operation
      #
      # @example
      #   Campaign.batch_save(campaign1, campaign2, campaign3)
      #
      # @return None
      #
      # @since 1.1.0

      def batch_save(account, objs)
        entity_type = ANALYTICS_MAP[name]
        resource = self::BATCH_RESOURCE_COLLECTION % { account_id: account.id }

        req_body = []

        for obj in objs
          obj_json = {'params': to_params}

          if not obj.id
            obj_json['operation_type'] = 'Create'
          elsif obj.to_delete 
            obj_json['operation_type'] = 'Delete'
            obj_json['params'][entity_type + '_id'] = obj.id
          else
            obj_json['operation_type'] = 'Update'
            obj_json['params'][entity_type + '_id'] = obj.id
          end

          req_body.push(obj_json)

        response = Request.new(account.client, :post, resource, body: body).perform
        response.body[:data]

        # persist each entity
      end

    end

  end
end
