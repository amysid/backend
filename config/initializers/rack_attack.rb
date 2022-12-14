class Rack::Attack

  ### Add localhost to safelist
  safelist("localhost") { |req| req.ip == '127.0.0.1' }

  ### Safelist particular controller actions ()
  # safelist('unlimited requests') do |request|
  #   safelist = [
  #     'controller#action',
  #     'another_controller#another_action'
  #   ]
  #   route = (Rails.application.routes.recognize_path request.url rescue {}) || {}
  #   action = "#{route[:controller]}##{route[:action]}"
  #   safelist.any? { |safe| action == safe }
  # end

  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  # Use either this OR the exponential backoff way
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  # throttle('req/ip', limit: 300, period: 5.minutes) do |req|
  #   req.ip unless req.path.start_with?('/assets')
  # end

  # Exponential Backoff
  # (0...5).each do |level|
  #   throttle("req/ip/#{level}", limit: 300 + (20 * level), period: 5.minutes + (8**level).seconds) do |req|
  #     req.ip unless req.path.start_with?('/assets')
  #   end
  # end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  # Use either this OR the exponential backoff way
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  # throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
  #   if req.path == '/login' and req.post?
  #     req.ip
  #   end
  # end

  # # Exponential Backoff
  # (1..5).each do |level|
  #   throttle("logins/ip/#{level}", limit: (20 * level), period: (8**level).seconds) do |req|
  #     req.ip if req.path == '/login' and req.post?
  #   end
  # end

  # # Throttle POST requests to /login by email param
  # #
  # # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
  # #
  # # Note: This creates a problem where a malicious user could intentionally
  # # throttle logins for another user and force their login requests to be
  # # denied, but that's not very common and shouldn't happen to you. (Knock
  # # on wood!)
  # throttle("logins/email", limit: 5, period: 20.seconds) do |req|
  #   if req.path == '/login' and req.post?
  #     # return the email if present, nil otherwise
  #     req.params['email'].presence
  #   end
  # end

  blocklist('allow2ban login scrapers') do |req|
    # `filter` returns false value if request is to your login page (but still
    # increments the count) so request below the limit are not blocked until
    # they hit the limit.  At that point, filter will return true and block.
    Allow2Ban.filter(req.ip, maxretry: 3, findtime: 1.minute, bantime: 10.minutes) do
      # The count for the IP is incremented if the return value is truthy.
      req.path.start_with?("/api/login") and req.post?
    end
  end

  # below blocklist will prevent the user with same user email to make multiple attempts
  blocklist('allow2ban for a username') do |req|
    Allow2Ban.filter("admin/email", maxretry: 3, findtime: 1.minute, bantime: 10.minutes) do
      req.params.dig("admin_user", "email") if req.path.start_with?("/api/login") and req.post?
    end
  end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  # self.throttled_response = lambda do |env|
  #  [ 503,  # status
  #    {},   # headers
  #    ['']] # body
  # end

  ### Block Referer Spam
  spammers = ENV['RACK_ATTACK_BLOCKED_REFERERS'].to_s.split(/,\s*/)
  spammers_regexp = Regexp.union(spammers)
  blocklist("block referer spam") do |request|
    request.referer =~ spammers_regexp
  end

end
