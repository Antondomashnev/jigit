module Jigit
  class JiraAPIClientError < StandardError
  end

  class NetworkError < StandardError
  end

  class JiraInvalidIssueKeyError < StandardError
  end
end
