class User < ActiveRecord::Base
  include Aloha::LoggedModel

  belongs_to :team
  has_many :deliveries, dependent: :destroy
  validates :username, presence: true
  validates :slack_id, presence: true
  validates :im_channel_id, presence: true
  before_validation :fetch_im_channel_id, on: :create
  after_create :send_to_analytics

  def ready_for?(message)
    return true if message.delay.blank?
    self.created_at + message.delay < Time.now
  end

  def should_receive?(message)
    return message.admin_only == self.is_admin
  end

  def received?(message)
    Delivery.where(user: self, message: message).exists?
  end

  def self.find_create_or_update_by_slack_id!(client, slack_id, team=nil)
    team ||= client.owner
    instance = User.where(team: team, slack_id: slack_id).first
    instance_info = Hashie::Mash.new(client.web_client.users_info(user: slack_id)).user
    instance.update_attributes!(username: instance_info.name) if instance && instance.username != instance_info.name
    instance ||= User.create!(team: team, slack_id: slack_id, username: instance_info.name)
    instance
  end

  private
  def fetch_im_channel_id
    client = Slack::RealTime::Client.new(token: self.team.token)
    response = client.web_client.im_open(user: self.slack_id)
    self.im_channel_id = response.channel.id
  end

  def send_to_analytics
    Aloha::Helpers::Analytics.increment('users.total', 1)
  end

end