defmodule Weather.WeatherData do

  require Logger

  @user_agent [ {"User-agent", "Elixir deanchouinard@gmail.com"} ]
  @weather_data_url Application.get_env(:weather, :weather_data_url)

  def fetch() do
    Logger.info "Fetching weather data"
    {:ok, response} = HTTPoison.get(weather_data_url, @user_agent)
    response.body
    # |> handle_response
  end

  def weather_data_url() do
    "#{@weather_data_url}"
  end

  def handle_response({ :ok, %{status_code: 200, body: body}}) do
    Logger.info "Successful response"
    Logger.debug fn -> inspect(body) end
    { :ok, Poison.Parser.parse!(body) }
  end

  def handle_response({ _, %{status_code: status, body: body}}) do
    Logger.error "Error #{status} returned"
    { :error, Poison.Parser.parse!(body) }
  end

end


