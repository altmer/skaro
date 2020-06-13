defmodule Skaro.PlaythroughTimeRemote do
  @moduledoc """
  Behaviour that defines API to access remote info about games (IGDB, Giantbomb, etc.)
  """

  @callback find(Map.t()) :: {:ok, Map.t()} | {:error, String.t()}
end
