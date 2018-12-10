defmodule Console.Parser do
  @open [
    "open",
    "turn on",
    "show",
    "show me",
    "see"
  ]

  @search [
    "search",
    "find me",
    "find",
    "get",
    "get me",
    "google",
    "what do you know",
    "tell me",
    "look for",
  ]

  @sub_search [
    "about",
    "for"
  ]

  @close [
    "turn off",
    "close",
    "shut",
    "close",
    "kill"
  ]

  @spec parse(String.t()) :: {String.t(), [String.t()]} | {:error, :dont_understand}
  def parse(string) do
    lower_cased = String.downcase(string)

    cond do
      String.contains?(lower_cased, @search) ->
        search(lower_cased)
      String.contains?(lower_cased, @open) ->
        open(lower_cased)
      String.contains?(lower_cased, @close) ->
        close(lower_cased)
      true ->
        {:error, :dont_understand}
    end
  end

  @spec search(String.t()) :: {String.t(), [String.t()]}
  def search(string) do
    thing_to_search =
      thing_to_search(string)
      |> URI.encode

    _command = get_system_correct_command(:search, thing_to_search)
  end

  def open(string) do
    thing_to_open = thing_to_open(string)

    _command = get_system_correct_command(:open, thing_to_open)
  end

  def close(string) do
    thing_to_close = thing_to_close(string)

    _command = {"kill", thing_to_close}
  end

  def thing_to_close(string) do
    word_list =
      string
      |> String.split()

    close_index =
      word_list
      |> Enum.reverse()
      |> Enum.find_index(fn x -> x in @close end)
      |> Kernel.*(-1)

    list_length = length(word_list) - 1

    _to_close =
      word_list
      |> Enum.slice(close_index, list_length)
      |> Enum.join("\ ")
  end

  def thing_to_open(string) do
    word_list =
      string
      |> String.split()

    open_index =
      word_list
      |> Enum.reverse()
      |> Enum.find_index(fn x -> x in @open end)
      |> Kernel.*(-1)

    list_length = length(word_list) - 1

    _to_open =
      word_list
      |> Enum.slice(open_index, list_length)
      |> Enum.join("\ ")
  end

  @spec thing_to_search(String.t()) :: String.t()
  def thing_to_search(string) do
    cond do
      String.contains?(string, @sub_search) ->
        word_list =
          string
          |> String.split()

        sub_search_index =
          word_list
          |> Enum.reverse()
          |> Enum.find_index(fn x -> x in @sub_search end)
          |> Kernel.*(-1)

        list_length = length(word_list) - 1

        _to_search =
          word_list
          |> Enum.slice(sub_search_index, list_length)
          |> Enum.join(" ")
      true ->
        word_list =
          string
          |> String.split()

        search_index =
          word_list
          |> Enum.reverse()
          |> Enum.find_index(fn x -> x in @search end)
          |> Kernel.*(-1)

        list_length = length(word_list) - 1

        _to_search =
          word_list
          |> Enum.slice(search_index, list_length)
          |> Enum.join(" ")
    end
  end

  defp get_system_correct_command(:open, what) do
    case :os.type do
      {_, :linux} ->
        mime = MIME.from_path(what)
        program = get_program(:linux, mime)

        {program, [what]}
      {_, :darwin} ->
        ext = Path.extname(what)
        program = get_program(:mac, ext)

        {"open", ["-a", program, what], program, what}
    end
  end

  @spec get_system_correct_command(atom, String.t()) :: {String.t(), [String.t()]} | {String.t(), [String.t()], String.t()}
  defp get_system_correct_command(:search, what) do
    case :os.type do
      {_, :linux} ->
        {"opera", ["http://google.com/search?q=#{what}"]}
      {_, :darwin} ->
        {"open", ["-a", "Google Chrome", "http://google.com/search?q=#{what}"], "Chrome", what}
    end
  end

  defp get_program(:linux, mime) do
    {program_string, _} = System.cmd("xdg-mime", ["query", "default", mime])
    [program | _] = String.split(program_string, ".")
    program
  end
  defp get_program(:mac, ext) do
    {programs_string, _} = System.cmd("duti", ["-x", ext])
    [program | _] =
      programs_string
      |> String.split("\n")
    program
  end
end
