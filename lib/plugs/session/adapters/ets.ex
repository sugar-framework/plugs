defmodule Plugs.Session.Adapters.Ets do
  @behaviour Plugs.Session.Adapter

  @table :_plugs_session
  @max_tries 5000

  def init(opts), do: opts

  def get(sid) do
    check_table
    case :ets.lookup(@table, sid) do
      [data] -> data
      _             -> []
    end
  end

  def put(sid, data, tries \\ 0) when tries < @max_tries do
    check_table
    if :ets.insert(@table, [{sid, data}]) do
      :ok
    else
      put sid, data, tries + 1
    end
  end
  def put(sid, _data ,tries) do
    {:error, "Unable to save data for '#{sid}' after #{tries} attempts."}
  end

  defp check_table do
    case :ets.info @table do
      :undefined -> :ets.new @table, [:set, :named_table]
      _ -> :ok
    end
  end
end