class Key < ActiveRecord::Base
  KEY_TYPES = %w(rsa dsa)
  validates :value, :presence => true # FIXME Should probably be checked
  validates :keytype, :presence => true, :inclusion => { :in => KEY_TYPES,
        :message => "%{value} is not a valid key type" }
  belongs_to :user
  attr_accessible :value, :name, :type

  def ssh_key=(key)
    self.errors['ssh_key'] << "haaaaa"
    if key.kind_of? ActionDispatch::Http::UploadedFile
      key = key.read
    end
    key = key.split
    if key.length != 2 && key.length != 3
      self.errors['ssh_key'] << "Invalid format, the string is supposed to have two or three fields."
      return false
    end
    unless KEY_TYPES.map {|type| 'ssh-' + type }.include? key[0]
      self.errors['ssh_key'] << "Invalid key type."
      return false
    end
    self[:keytype] = key[0][4..-1]
    self[:value] = key[1]
    self[:name] = key[2]
    ssh_key
  end

  def ssh_key
    unless self[:keytype].nil? || self[:value].nil? || self[:name].nil?
      "ssh-#{self[:keytype]} #{self[:value]} #{self[:name]}"
    end
  end
end
