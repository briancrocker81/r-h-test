class EmailTemplate < ApplicationRecord
  ALLOWED_TEMPLATE_NAMES = %w[send_mail_to_account send_dashboard_link].freeze

  validates :template_name, uniqueness: true, inclusion: { in: ALLOWED_TEMPLATE_NAMES }
  validates :content, presence: true, length: { minimum: 1 }
  after_initialize :set_default_content

  class << self
    def build_or_initialize_templates
      output = []
      ALLOWED_TEMPLATE_NAMES.each do |name|
        output << find_or_initialize_by(template_name: name)
      end
      output
    end
  end

  def available_tags
    case template_name
    when 'send_mail_to_account'
      %w[first_name room_number property_name guarantor_name_or_email]
    when 'send_dashboard_link'
      %w[first_name tenancy_dashboard_link]
    else
      %w[]
    end
  end

  def subbed_content(input_hash)
    output = content
    input_hash.each do |k,v|
      output.gsub!(/\{\{ ?#{k} ?\}\}/, v.to_s)
    end
    output
  end

  private

  def set_default_content
    return if content.present?

    self.content = File.read("app/templates/email/#{template_name}.txt")
  end
end
