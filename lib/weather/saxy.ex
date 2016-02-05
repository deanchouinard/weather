defmodule Saxy do

  require Logger

  defmodule SaxState do
    defstruct title: "", text: "", element_acc: "", location: ""
  end

  @chunk 10000

  def run(path) do
    {:ok, handle} = File.open(path, [:binary])

    position = 0
    c_state = {handle, position, @chunk}

    :erlsom.parse_sax("",
                      nil,
                      &sax_event_handler/2,
                      [{:continuation_function, &continue_file/2, c_state}])
    :ok = File.close(handle)
  end

  def continue_file(tail, {handle, offset, chunk}) do
    case :file.pread(handle, offset, chunk) do
      {:ok, data} ->
        {<<tail :: binary, data::binary>>, {handle, offset + chunk, chunk}}
      :eof ->
        {tail, {handle, offset, chunk}}
    end
  end

  def parse_doc(xml_doc) do
    :erlsom.parse_sax(xml_doc, nil, &sax_event_handler/2 )
  end

    

  def sax_event_handler({:startElement, _, 'location', _, _}, _state) do
    %SaxState{}
  end

  def sax_event_handler({:startElement, _, 'text', _, _}, state) do
    %{state | element_acc: ""}
  end

  def sax_event_handler({:characters, value}, %SaxState{element_acc:
    element_acc} = state) do
    %{state | element_acc: element_acc <> to_string(value)}
  end

  def sax_event_handler({:endElement, _, 'location', _}, state) do
    state = %{state | location: state.element_acc}
    IO.puts "Location: #{state.location}"
    state
  end

  def sax_event_handler({:endElement, _, 'text', _}, state) do
    state = %{state | text: state.element_acc}
    IO.puts "Title: #{state.title}"
    IO.puts "Text: #{state.text}"
    Logger.info "end of element"
    state
  end

  def sax_event_handler(:endDocument, state), do: state
  def sax_event_handler(_, state), do: state
end
