class AuthToken
  attr_reader :access_token, :refresh_token, :expires_at

  def initialize(access_token, refresh_token, expires_at)
    @access_token = access_token
    @refresh_token = refresh_token
    @expires_at = expires_at.to_i
  end

  def self.null
    from_hash({})
  end

  def self.from_hash(hash)
    hash ||= {}

    AuthToken.new(*hash.values_at('access_token', 'refresh_token', 'expires_at'))
  end

  def expired?
    Time.zone.now >= Time.zone.at(expires_at) - 1.minute
  end


  def self.load(string)
    from_hash(JSON.parse(string)) rescue null
  end

  def self.dump(token)
    token.to_h.to_json
  end

  def to_h
    {
      access_token: access_token,
      refresh_token: refresh_token,
      expires_at: expires_at
    }
  end
end
