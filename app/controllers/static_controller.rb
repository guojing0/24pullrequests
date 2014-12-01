class StaticController < ApplicationController
  def homepage
    @projects = Project.includes(:labels).active.limit(200).sample(6)
    @users = User.order('pull_requests_count desc').includes(:pull_requests).limit(200).sample(24)
    @orgs = Organisation.with_user_counts.order_by_pull_requests.limit(200).sample(24)
    @pull_requests = PullRequest.year(current_year).order('created_at desc').limit(5)

    render layout: "homepage"
  end

  def about
    @contributors = User.contributors
  end

  def humans
    @contributors = Rails.cache.read("contributors")

    unless @contributors
      @contributors = load_contributors
      Rails.cache.write("contributors", @contributors, expires_in: 1.day)
    end

    render "static/humans.txt.erb", content_type: "text/plain"
  end

  private

  def load_contributors
    Rails.application.config.contributors.map(&:login).map do |login|
      Rails.application.config.octokit_client.user(login)
    end
  end
end
