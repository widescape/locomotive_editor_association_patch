module LocomotiveEditor
  module Api

    class ContentEntry

      include HTTMultiParty
      include Api::Helpers

      attr_accessor :content_type, :content_type_service, :content_assets_service

      def initialize(auth_token, options = {})
        # see https://github.com/jwagener/httmultiparty/issues/11
        self.options    = options
        self.auth_token = auth_token
      end

      def list
        self.class.get("/content_types/#{self.content_type.slug}/entries.json", :query => { :auth_token => self.auth_token })
      end

      def create(params = {})
        # puts "---> create #{self.content_type.slug} / #{params.inspect} [QUERY]"
        self.class.post(
          "/content_types/#{self.content_type.slug}/entries.json",
          :query => { :auth_token => self.auth_token, :content_entry => params }
        )
      end

      def update(id, params = {})
        # puts "---> update #{self.content_type.slug} / #{id} / #{params.inspect}"
        self.class.put(
          "/content_types/#{self.content_type.slug}/entries/#{id}.json",
          :query => { :auth_token => self.auth_token, :content_entry => params }
        )
      end

      def show(permalink, content_type_slug = nil)
        slug = content_type_slug || self.content_type.slug
        self.class.get("/content_types/#{slug}/entries/#{permalink}.json", :query => { :auth_token => self.auth_token })
      end

      protected

      def label_for(entry)
        entry._permalink
      end

      def compare_entries(remote_entry, local_entry)
        remote_entry._slug == local_entry._permalink.downcase
      end

      def build_params(entry)
        entry.to_hash.tap do |hash|
          self.content_type.ordered_fields.map do |field| # FIXED: Added .map to actually do something :-)
            case field.type.to_sym
            when :string, :text
              # TODO: To be tested
              self.push_content_assets!(hash[field.name]) # FIXED: Added exclamation mark to call the actual method push_content_assets!
            when :file
              # TODO: To be tested
              unless hash[field.name].nil? # FIXED: Only create a file if the field has a value
                hash[field.name] = File.new(hash[field.name])
              end
            when :belongs_to
              reference = entry.send(field.name.to_sym) # FIXED: Get the real reference object, not the string value.
              if reference
                entry_id = fetch_entry_id(reference.slug, field.target_content_type) # FIXED: Use the reference's slug, not the string value.
                
                if entry_id
                  hash["#{field.name}_id".to_sym] = entry_id
                end
              end
            when :many_to_many
              hash["#{field.name.singularize}_ids".to_sym] = (entry.send(field.name.to_sym) || []).map do |reference| # FIXED: Get the real reference object, not the string value.
                fetch_entry_id(reference.slug, field.target_content_type) # FIXED: Use the reference's slug, not the string value.
              end.compact
            end
          end
        end
      end

      def fetch_entry_id(permalink, content_type)
        self.show(permalink, content_type.slug)['_id']
      rescue
        nil
      end

      def push_content_assets!(text)
        (text || '').gsub!(/\/samples\/.*\.[a-zA-Z0-9]+/) do |match|
          asset = self.content_assets_service.push_entry match
          asset ? asset.parsed_response['url'] : match
        end
      end

    end

  end
end