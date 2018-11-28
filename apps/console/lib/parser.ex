defmodule Console.Parser do
  @open [
    "open"
  ]

  @search [
    "search",
    "find me",
    "find",
    "get",
    "get me",
    "google",
    "what do you know",
    "tell me"
  ]

  @sub_search [
    "about",
    "for"
  ]

  @spec parse(String.t()) :: {String.t(), [String.t()]}
  def parse(string) do
    cond do
      String.contains?(string, @search) ->
        search(string)
      String.contains?(string, @open) ->
        open(string)
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
          |> IO.inspect
          |> Kernel.*(-1)

        list_length = length(word_list) - 1

        _to_search =
          word_list
          |> Enum.slice(search_index, list_length)
          |> Enum.join(" ")
    end
  end

  defp get_system_correct_command(:open, what) do

  end

  @spec get_system_correct_command(atom, String.t()) :: {String.t(), [String.t()]}
  defp get_system_correct_command(:search, what) do
    case :os.type do
      {_, :linux} ->
        {"opera", ["http://google.com/search?q=#{what}"]}
        # "opera http://google.com/search?q=#{what}"
      {_, :darwin} ->
        {"open", ["-a", "Opera", "http://google.com/search?q=#{what}"]}
    end
  end
end
