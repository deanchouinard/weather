defmodule Weather.CLI do
  @default_count 4

  require Logger
  
  def run() do
    process()
  end

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  #  def process({user, project, count}) do
  def process() do
    xml_doc = Weather.WeatherData.fetch()
    Logger.info "after fetch"
    {:ok, state, _} = Saxy.parse_doc(xml_doc)
    #    state = :erlsom.parse_sax(xml_doc, nil, &Saxy.sax_event_handler/2 )
    IO.puts "#{state.location}"
    Logger.info "after parse_sax"
    # inspect(xml_doc)
    #    |> decode_response
    # |> convert_to_list_of_maps
    # |> sort_into_ascending_order
    # |> Enum.take(count)
    # |> Issues.TableFormatter.print_table_for_columns(["number", "created_at", "title"])
  end

  def sort_into_ascending_order(list_of_issues) do
    Enum.sort list_of_issues,
      fn i1, i2 -> i1["created_at"] <= i2["created_at"] end
  end

  def convert_to_list_of_maps(list) do
    list
    |> Enum.map(&Enum.into(&1, Map.new))
  end


  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    {_, message} = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from Github: #{message}"
    System.halt(2)
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                                    aliases: [ h:   :help])
                                    # IO.puts parse

    case parse do
      { [ help: true ], _, _ }
        -> :help

      { _, [ user, project, count ], _ }
        -> { user, project, String.to_integer(count) }

      { _, [ user, project ], _ }
        -> { user, project, @default_count }

      _ -> :help

    end
  end
end

