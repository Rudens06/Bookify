defmodule Bookify.Utils.DateTime do
  def from_today(date_time, trunc_unit) do
    case DateTime.from_naive(date_time, "Etc/UTC") do
      {:ok, date_time_dt} ->
        DateTime.diff(date_time_dt, DateTime.utc_now(), trunc_unit)

      {:error, _} ->
        "Invalid date"
    end
  end

  def to_human_readable_date(%DateTime{} = datetime) do
    datetime
    |> DateTime.to_date()
  end

  def to_human_readable_date(%NaiveDateTime{} = naive_datetime) do
    naive_datetime
    |> NaiveDateTime.to_date()
  end
end
