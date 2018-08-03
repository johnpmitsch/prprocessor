require File.join(File.dirname(__FILE__), 'redmine_resource')

# Issue model on the client side
class Issue < RedmineResource

  NEW = 1
  READY_FOR_TESTING = 7
  FIELD_PULL_REQUEST = 7
  FIELD_TRIAGED = 5

  def base_path
    '/issues'
  end

  def project
    @raw_data['issue']['project']['id']
  end

  def subject
    @raw_data['issue']['subject']
  end

  def backlog?
    version_name =~ /backlog/i
  end

  def recycle_bin?
    version_name =~ /recycle bin/i
  end

  def version_name
    @raw_data['issue']['fixed_version']['name'] if @raw_data['issue']['fixed_version']
  end

  def version
    @raw_data['issue']['fixed_version']['id'] if @raw_data['issue']['fixed_version']
  end

  def assigned_to
    @raw_data['issue']['assigned_to']['name'] if @raw_data['issue']['assigned_to']
  end

  def set_version(version_id)
    @raw_data['issue']['fixed_version_id'] = version_id
    self
  end

  def closed?
    ['Closed', 'Resolved', 'Rejected', 'Duplicate'].include? @raw_data['issue']['status']['name']
  end

  def rejected?
    ['Rejected', 'Duplicate'].include? @raw_data['issue']['status']['name']
  end

  def triaged?
    field = @raw_data['issue']['custom_fields'].find { |f| f['id'] == FIELD_TRIAGED }
    field && field['value'] == "1"
  end

  def set_triaged(value = true)
    @raw_data['issue']['custom_field_values'] = { FIELD_TRIAGED.to_s => value ? '1' : '0' }
    self
  end

  def set_status(status)
    @raw_data['issue']['status_id'] = status
    self
  end

  def pull_requests
    field = @raw_data['issue']['custom_fields'].find { |f| f['id'] == FIELD_PULL_REQUEST }
    return nil if field.nil?
    field['value']
  end

  def set_pull_requests(url)
    @raw_data['issue']['custom_field_values'] = {FIELD_PULL_REQUEST.to_s => url}
    self
  end

  def add_pull_request(url)
    current_pull_requests = pull_requests
    set_pull_requests(current_pull_requests + [url]) unless current_pull_requests.nil?
  end

  def remove_pull_request(url)
    current_pull_requests = pull_requests
    set_pull_requests(current_pull_requests - [url]) unless current_pull_requests.nil?
  end

  def set_assigned(user_id)
    @raw_data['issue']['assigned_to_id'] = user_id
    self
  end

  def save!
    put(@raw_data['issue']['id'], @raw_data)
  end

  def to_s
    "#{project} ##{@raw_data['issue']['id']}"
  end

end
