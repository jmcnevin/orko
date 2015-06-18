defmodule Orko.Bot do
  use Slack
  use Timex

  @slack_api_token System.get_env("SLACK_API_TOKEN")

  def start_link() do
    Slack.start_link(__MODULE__, @slack_api_token, nil)
  end

  def init(initial_state, _socket) do
    {:ok, initial_state}
  end

  ## MESSAGE HANDLERS

  def handle_message({:type, "message", response}, slack, state) do
    spawn fn ->
      log "[message] #{response.text}"

      name_regex = ~r/^.?#{slack.me.name}\s*:?/i
      message = normalize(response.text, slack.me)

      if message =~ name_regex do
        message = Regex.replace(name_regex, message, "")
        reply_to_direct_message(message, response, slack)
      end
    end
    {:ok, state}
  end

  def handle_message({:type, "group_joined", response}, slack, state) do
    spawn fn ->
      message = "Miggle Maggle Muggle Mies, mystic globes, now arise!"
      Slack.send_message(message, response.channel.id, slack)
    end
    {:ok, state}
  end

  def handle_message({:type, "channel_joined", response}, slack, state) do
    spawn fn ->
      message = "Miggle Maggle Muggle Mies, mystic globes, now arise!"
      Slack.send_message(message, response.channel.id, slack)
    end
    {:ok, state}
  end

  def handle_message({:type, type, _response}, _slack, state) do
    log "No callback for #{type}"
    {:ok, state}
  end

  ## PRIVATE

  defp config(key) do
    Application.get_env(:orko, __MODULE__)[key]
  end

  defp reply_to_direct_message(message, response, slack) do
    reply = cond do
              message =~ ~r/weather/i ->
                fetch_weather()
              message =~ ~r/random/i ->
                fetch_random_number()
              message =~ ~r/chuck norris/i ->
                fetch_chuck_norris()
              message =~ ~r/sudo/i ->
                "OK, I've deleted your filesystem.  Happy now?"
              message =~ ~r/He\-Man/i ->
                "I don't even want to hear about that guy."
              message =~ ~r/She\-Ra/i ->
                "/me sighs"
              true ->
                random_reply(["No idea what you're talking about.",
                              "Umm, yes?",
                              "Shoo, fly, you bother me.",
                              "*Yawn*",
                              "...",
                              "Get back to work.",
                              "Can I just dance for you?  Would that make you happy?",
                              "I'm going to remember you said that.",
                              "Yeah, OK.  I'm just going to write your name on this list here...",
                              "WUT?",
                              ":confounded:",
                              "Let me get back to you about that.",
                              "Let's go see a movie."])
            end
    reply = "<@#{response.user}>: " <> reply
    log "  -> #{reply}"
    Slack.send_message(reply, response.channel, slack)
  end

  defp normalize(text, me) do
    String.replace(text, "<@#{me.id}>", me.name)
  end

  defp log(message) do
    date = Date.local
    date_string = DateFormat.format!(date, "{ISO}")
    IO.puts "#{date_string} -- #{message}"
  end

  defp fetch_json(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        JSX.decode(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "That service is broken."}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp fetch_chuck_norris() do
    case fetch_json(config(:chuck_norris_url)) do
      {:ok, json} ->
        json["value"]["joke"]
      {:error, reason} ->
        "Maybe later.  (#{reason})"
    end
  end

  defp fetch_random_number() do
    case fetch_json(config(:random_number_url)) do
      {:ok, json} ->
        [head|_] = json["data"]
        "Here's a truly random number, generated by quantum fluctuations in a vacuum. Or something. *#{head}*"
      {:error, reason} ->
        "Maybe later.  (#{reason})"
    end
  end

  defp fetch_weather() do
    case fetch_json(config(:weather_url)) do
      {:ok, json} ->
        currently = json["currently"]
        "It's looking #{String.downcase(currently["summary"])} out there.  About #{round(currently["temperature"])} degrees."
      {:error, %HTTPoison.Error{reason: reason}} ->
        "I'd tell you, but #{reason}."
    end
  end

  defp random_reply(list) do
    Random.init
    Random.pick_element(list)
  end
end