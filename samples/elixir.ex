defmodule Ergolight.Sample do
  @moduledoc "Exercise atoms, module names, sigils, guards and pipelines."
  @version "1.0.0"

  defstruct [:id, status: :draft]

  @type t :: %__MODULE__{id: integer(), status: atom()}

  def paid?(%__MODULE__{status: :paid}), do: true
  def paid?(_), do: false

  def render(order) when is_map(order) do
    ~s/#{@version}:#{order.id}:#{order.status}/
  end

  def summarize(orders) do
    orders
    |> Enum.filter(&paid?/1)
    |> Enum.map(&render/1)
  end
end

