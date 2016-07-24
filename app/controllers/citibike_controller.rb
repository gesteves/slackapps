class CitibikeController < ApplicationController

  def slash
    if params[:token] == ENV['CITIBIKE_VERIFICATION_TOKEN'] || Rails.env.development?
      query = params[:text].sub(/^\s*(in|for|at)\s+/, '').strip
      if query == '' || query == 'help'
        response = { text: 'Enter an address to get the closest Capital Bikeshare dock with bikes. For example, `/cabi near 1600 Pennsylvania Avenue NW, Washington, DC`', response_type: 'ephemeral' }
      else
        response = Citibike.new.search(query)
      end
      render json: response, status: 200
    else
      render text: 'Unauthorized', status: 401
    end
  end

  def auth
    if params[:code].present?
      token = get_slack_access_token(params[:code], ENV['CITIBIKE_CLIENT_ID'], ENV['CITIBIKE_CLIENT_SECRET'], citibike_auth_url)
      notice = token['ok'].present? ? 'The /citibike command has been added to your Slack. Yay!' : 'Authentication failed. Try again!'
    else
      notice = 'Authentication failed. Try again!'
    end
    redirect_to root_url, notice: notice
  end

end