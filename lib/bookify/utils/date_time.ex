defmodule BookifyWeb.Utils.DateTime do
  def from_today(date_time, trunc_unit) do
    case DateTime.from_naive(date_time, "Etc/UTC") do
      {:ok, date_time_dt} ->
        DateTime.diff(date_time_dt, DateTime.utc_now(), trunc_unit)

      {:error, _} ->
        "Invalid date"
    end
  end
end
