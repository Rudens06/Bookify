defmodule Bookify.Utils.GenId do
  use Puid, chars: :alphanum, total: 1.0e6, risk: 1.0e12
end
