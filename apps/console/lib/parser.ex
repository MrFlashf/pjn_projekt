defmodule Console.Parser do
  @open [
    "otwórz",
    "odpal",
    "włącz",
    "wlacz"
  ]

  @search [
    "wyszukaj",
    "znajdź",
    "znajdz",
    "wygoogluj",
    "wygugluj"
  ]

  def parse(string) do
    is_search = String.contains?(string, @search)

    cond do
      String.contains?(string, @search) ->
        search(string)
      String.contains?(string, @open) ->
        open(string)
    end
  end

  def search(string) do
    thing_to_search =
      thing_to_search(string)
      |> URI.encode

    command = get_system_correct_command(:search, thing_to_search)

    IO.inspect command

    url = "google.com/search?q=#{thing_to_search}"


    System.cmd("opera", [url])
  end

  def open(string) do

  end

  def thing_to_search(string) do
    regex =
      ~r/.+:(.+)/
      |> Regex.run(string)
    case regex do
      nil ->
        {:error, :wrong_string}
      [_, result] ->
        result
    end
  end

  defp get_system_correct_command(:open, what) do

  end

  defp get_system_correct_command(:search, what) do
    case :os.type do
      {_, :linux} ->
        {"opera", ["http://google.com/search?q=#{what}"]}
      {_, :darwin} ->
        {"open", ["-a", "Opera", "http://google.com/search?q=#{what}"]}
    end
  end
end
